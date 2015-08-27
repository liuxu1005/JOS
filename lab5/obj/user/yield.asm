
obj/user/yield.debug:     file format elf32-i386


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
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 80 1e 80 00       	push   $0x801e80
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 a4 0a 00 00       	call   800afe <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 a0 1e 80 00       	push   $0x801ea0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
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
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 cc 1e 80 00       	push   $0x801ecc
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
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
  8000a5:	e8 35 0a 00 00       	call   800adf <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 f0 0d 00 00       	call   800edb <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 a9 09 00 00       	call   800a9e <sys_env_destroy>
  8000f5:	83 c4 10             	add    $0x10,%esp
}
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 37 09 00 00       	call   800a61 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 4f 01 00 00       	call   8002bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 dc 08 00 00       	call   800a61 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 d1                	mov    %edx,%ecx
  8001b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001cc:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001cf:	72 05                	jb     8001d6 <printnum+0x35>
  8001d1:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001d4:	77 3e                	ja     800214 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	ff 75 18             	pushl  0x18(%ebp)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	53                   	push   %ebx
  8001e0:	50                   	push   %eax
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 ab 19 00 00       	call   801ba0 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 13                	jmp    80021b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	85 db                	test   %ebx,%ebx
  800219:	7f ed                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	83 ec 04             	sub    $0x4,%esp
  800222:	ff 75 e4             	pushl  -0x1c(%ebp)
  800225:	ff 75 e0             	pushl  -0x20(%ebp)
  800228:	ff 75 dc             	pushl  -0x24(%ebp)
  80022b:	ff 75 d8             	pushl  -0x28(%ebp)
  80022e:	e8 9d 1a 00 00       	call   801cd0 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 80 f5 1e 80 00 	movsbl 0x801ef5(%eax),%eax
  80023d:	50                   	push   %eax
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
}
  800243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800246:	5b                   	pop    %ebx
  800247:	5e                   	pop    %esi
  800248:	5f                   	pop    %edi
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024e:	83 fa 01             	cmp    $0x1,%edx
  800251:	7e 0e                	jle    800261 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800253:	8b 10                	mov    (%eax),%edx
  800255:	8d 4a 08             	lea    0x8(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 02                	mov    (%edx),%eax
  80025c:	8b 52 04             	mov    0x4(%edx),%edx
  80025f:	eb 22                	jmp    800283 <getuint+0x38>
	else if (lflag)
  800261:	85 d2                	test   %edx,%edx
  800263:	74 10                	je     800275 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800265:	8b 10                	mov    (%eax),%edx
  800267:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	eb 0e                	jmp    800283 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800275:	8b 10                	mov    (%eax),%edx
  800277:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027a:	89 08                	mov    %ecx,(%eax)
  80027c:	8b 02                	mov    (%edx),%eax
  80027e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 0a                	jae    8002a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800296:	8d 4a 01             	lea    0x1(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	88 02                	mov    %al,(%edx)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	50                   	push   %eax
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	e8 05 00 00 00       	call   8002bf <vprintfmt>
	va_end(ap);
  8002ba:	83 c4 10             	add    $0x10,%esp
}
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 2c             	sub    $0x2c,%esp
  8002c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d1:	eb 12                	jmp    8002e5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	0f 84 90 03 00 00    	je     80066b <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	53                   	push   %ebx
  8002df:	50                   	push   %eax
  8002e0:	ff d6                	call   *%esi
  8002e2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e5:	83 c7 01             	add    $0x1,%edi
  8002e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ec:	83 f8 25             	cmp    $0x25,%eax
  8002ef:	75 e2                	jne    8002d3 <vprintfmt+0x14>
  8002f1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800303:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	eb 07                	jmp    800318 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800314:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8d 47 01             	lea    0x1(%edi),%eax
  80031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031e:	0f b6 07             	movzbl (%edi),%eax
  800321:	0f b6 c8             	movzbl %al,%ecx
  800324:	83 e8 23             	sub    $0x23,%eax
  800327:	3c 55                	cmp    $0x55,%al
  800329:	0f 87 21 03 00 00    	ja     800650 <vprintfmt+0x391>
  80032f:	0f b6 c0             	movzbl %al,%eax
  800332:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800340:	eb d6                	jmp    800318 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	b8 00 00 00 00       	mov    $0x0,%eax
  80034a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800350:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800354:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800357:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035a:	83 fa 09             	cmp    $0x9,%edx
  80035d:	77 39                	ja     800398 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800362:	eb e9                	jmp    80034d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8d 48 04             	lea    0x4(%eax),%ecx
  80036a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800375:	eb 27                	jmp    80039e <vprintfmt+0xdf>
  800377:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037a:	85 c0                	test   %eax,%eax
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800381:	0f 49 c8             	cmovns %eax,%ecx
  800384:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038a:	eb 8c                	jmp    800318 <vprintfmt+0x59>
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800396:	eb 80                	jmp    800318 <vprintfmt+0x59>
  800398:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a2:	0f 89 70 ff ff ff    	jns    800318 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b5:	e9 5e ff ff ff       	jmp    800318 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ba:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c0:	e9 53 ff ff ff       	jmp    800318 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 50 04             	lea    0x4(%eax),%edx
  8003cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	53                   	push   %ebx
  8003d2:	ff 30                	pushl  (%eax)
  8003d4:	ff d6                	call   *%esi
			break;
  8003d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003dc:	e9 04 ff ff ff       	jmp    8002e5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	99                   	cltd   
  8003ed:	31 d0                	xor    %edx,%eax
  8003ef:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f1:	83 f8 0f             	cmp    $0xf,%eax
  8003f4:	7f 0b                	jg     800401 <vprintfmt+0x142>
  8003f6:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8003fd:	85 d2                	test   %edx,%edx
  8003ff:	75 18                	jne    800419 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800401:	50                   	push   %eax
  800402:	68 0d 1f 80 00       	push   $0x801f0d
  800407:	53                   	push   %ebx
  800408:	56                   	push   %esi
  800409:	e8 94 fe ff ff       	call   8002a2 <printfmt>
  80040e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800414:	e9 cc fe ff ff       	jmp    8002e5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800419:	52                   	push   %edx
  80041a:	68 f1 22 80 00       	push   $0x8022f1
  80041f:	53                   	push   %ebx
  800420:	56                   	push   %esi
  800421:	e8 7c fe ff ff       	call   8002a2 <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042c:	e9 b4 fe ff ff       	jmp    8002e5 <vprintfmt+0x26>
  800431:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800434:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800437:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800445:	85 ff                	test   %edi,%edi
  800447:	ba 06 1f 80 00       	mov    $0x801f06,%edx
  80044c:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80044f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800453:	0f 84 92 00 00 00    	je     8004eb <vprintfmt+0x22c>
  800459:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80045d:	0f 8e 96 00 00 00    	jle    8004f9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	51                   	push   %ecx
  800467:	57                   	push   %edi
  800468:	e8 86 02 00 00       	call   8006f3 <strnlen>
  80046d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800470:	29 c1                	sub    %eax,%ecx
  800472:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800475:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800478:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800482:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	eb 0f                	jmp    800495 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	53                   	push   %ebx
  80048a:	ff 75 e0             	pushl  -0x20(%ebp)
  80048d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	83 ef 01             	sub    $0x1,%edi
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 ff                	test   %edi,%edi
  800497:	7f ed                	jg     800486 <vprintfmt+0x1c7>
  800499:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049f:	85 c9                	test   %ecx,%ecx
  8004a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a6:	0f 49 c1             	cmovns %ecx,%eax
  8004a9:	29 c1                	sub    %eax,%ecx
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	89 cb                	mov    %ecx,%ebx
  8004b6:	eb 4d                	jmp    800505 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bc:	74 1b                	je     8004d9 <vprintfmt+0x21a>
  8004be:	0f be c0             	movsbl %al,%eax
  8004c1:	83 e8 20             	sub    $0x20,%eax
  8004c4:	83 f8 5e             	cmp    $0x5e,%eax
  8004c7:	76 10                	jbe    8004d9 <vprintfmt+0x21a>
					putch('?', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	6a 3f                	push   $0x3f
  8004d1:	ff 55 08             	call   *0x8(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	eb 0d                	jmp    8004e6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 0c             	pushl  0xc(%ebp)
  8004df:	52                   	push   %edx
  8004e0:	ff 55 08             	call   *0x8(%ebp)
  8004e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	83 eb 01             	sub    $0x1,%ebx
  8004e9:	eb 1a                	jmp    800505 <vprintfmt+0x246>
  8004eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f7:	eb 0c                	jmp    800505 <vprintfmt+0x246>
  8004f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800502:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800505:	83 c7 01             	add    $0x1,%edi
  800508:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050c:	0f be d0             	movsbl %al,%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	74 23                	je     800536 <vprintfmt+0x277>
  800513:	85 f6                	test   %esi,%esi
  800515:	78 a1                	js     8004b8 <vprintfmt+0x1f9>
  800517:	83 ee 01             	sub    $0x1,%esi
  80051a:	79 9c                	jns    8004b8 <vprintfmt+0x1f9>
  80051c:	89 df                	mov    %ebx,%edi
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	eb 18                	jmp    80053e <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	53                   	push   %ebx
  80052a:	6a 20                	push   $0x20
  80052c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052e:	83 ef 01             	sub    $0x1,%edi
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	eb 08                	jmp    80053e <vprintfmt+0x27f>
  800536:	89 df                	mov    %ebx,%edi
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053e:	85 ff                	test   %edi,%edi
  800540:	7f e4                	jg     800526 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800545:	e9 9b fd ff ff       	jmp    8002e5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054a:	83 fa 01             	cmp    $0x1,%edx
  80054d:	7e 16                	jle    800565 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 08             	lea    0x8(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 50 04             	mov    0x4(%eax),%edx
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800563:	eb 32                	jmp    800597 <vprintfmt+0x2d8>
	else if (lflag)
  800565:	85 d2                	test   %edx,%edx
  800567:	74 18                	je     800581 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	89 c1                	mov    %eax,%ecx
  800579:	c1 f9 1f             	sar    $0x1f,%ecx
  80057c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057f:	eb 16                	jmp    800597 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 c1                	mov    %eax,%ecx
  800591:	c1 f9 1f             	sar    $0x1f,%ecx
  800594:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800597:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a6:	79 74                	jns    80061c <vprintfmt+0x35d>
				putch('-', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 2d                	push   $0x2d
  8005ae:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b6:	f7 d8                	neg    %eax
  8005b8:	83 d2 00             	adc    $0x0,%edx
  8005bb:	f7 da                	neg    %edx
  8005bd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c5:	eb 55                	jmp    80061c <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ca:	e8 7c fc ff ff       	call   80024b <getuint>
			base = 10;
  8005cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d4:	eb 46                	jmp    80061c <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 6d fc ff ff       	call   80024b <getuint>
                        base = 8;
  8005de:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005e3:	eb 37                	jmp    80061c <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 30                	push   $0x30
  8005eb:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ed:	83 c4 08             	add    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 78                	push   $0x78
  8005f3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800605:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800608:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060d:	eb 0d                	jmp    80061c <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	e8 34 fc ff ff       	call   80024b <getuint>
			base = 16;
  800617:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061c:	83 ec 0c             	sub    $0xc,%esp
  80061f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800623:	57                   	push   %edi
  800624:	ff 75 e0             	pushl  -0x20(%ebp)
  800627:	51                   	push   %ecx
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 da                	mov    %ebx,%edx
  80062c:	89 f0                	mov    %esi,%eax
  80062e:	e8 6e fb ff ff       	call   8001a1 <printnum>
			break;
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800639:	e9 a7 fc ff ff       	jmp    8002e5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	51                   	push   %ecx
  800643:	ff d6                	call   *%esi
			break;
  800645:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064b:	e9 95 fc ff ff       	jmp    8002e5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 25                	push   $0x25
  800656:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	eb 03                	jmp    800660 <vprintfmt+0x3a1>
  80065d:	83 ef 01             	sub    $0x1,%edi
  800660:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800664:	75 f7                	jne    80065d <vprintfmt+0x39e>
  800666:	e9 7a fc ff ff       	jmp    8002e5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	83 ec 18             	sub    $0x18,%esp
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800682:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800686:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800689:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800690:	85 c0                	test   %eax,%eax
  800692:	74 26                	je     8006ba <vsnprintf+0x47>
  800694:	85 d2                	test   %edx,%edx
  800696:	7e 22                	jle    8006ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800698:	ff 75 14             	pushl  0x14(%ebp)
  80069b:	ff 75 10             	pushl  0x10(%ebp)
  80069e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a1:	50                   	push   %eax
  8006a2:	68 85 02 80 00       	push   $0x800285
  8006a7:	e8 13 fc ff ff       	call   8002bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	eb 05                	jmp    8006bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ca:	50                   	push   %eax
  8006cb:	ff 75 10             	pushl  0x10(%ebp)
  8006ce:	ff 75 0c             	pushl  0xc(%ebp)
  8006d1:	ff 75 08             	pushl  0x8(%ebp)
  8006d4:	e8 9a ff ff ff       	call   800673 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	eb 03                	jmp    8006eb <strlen+0x10>
		n++;
  8006e8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ef:	75 f7                	jne    8006e8 <strlen+0xd>
		n++;
	return n;
}
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800701:	eb 03                	jmp    800706 <strnlen+0x13>
		n++;
  800703:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800706:	39 c2                	cmp    %eax,%edx
  800708:	74 08                	je     800712 <strnlen+0x1f>
  80070a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070e:	75 f3                	jne    800703 <strnlen+0x10>
  800710:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071e:	89 c2                	mov    %eax,%edx
  800720:	83 c2 01             	add    $0x1,%edx
  800723:	83 c1 01             	add    $0x1,%ecx
  800726:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072d:	84 db                	test   %bl,%bl
  80072f:	75 ef                	jne    800720 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800731:	5b                   	pop    %ebx
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	53                   	push   %ebx
  800738:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073b:	53                   	push   %ebx
  80073c:	e8 9a ff ff ff       	call   8006db <strlen>
  800741:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800744:	ff 75 0c             	pushl  0xc(%ebp)
  800747:	01 d8                	add    %ebx,%eax
  800749:	50                   	push   %eax
  80074a:	e8 c5 ff ff ff       	call   800714 <strcpy>
	return dst;
}
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	56                   	push   %esi
  80075a:	53                   	push   %ebx
  80075b:	8b 75 08             	mov    0x8(%ebp),%esi
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800761:	89 f3                	mov    %esi,%ebx
  800763:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800766:	89 f2                	mov    %esi,%edx
  800768:	eb 0f                	jmp    800779 <strncpy+0x23>
		*dst++ = *src;
  80076a:	83 c2 01             	add    $0x1,%edx
  80076d:	0f b6 01             	movzbl (%ecx),%eax
  800770:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800773:	80 39 01             	cmpb   $0x1,(%ecx)
  800776:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800779:	39 da                	cmp    %ebx,%edx
  80077b:	75 ed                	jne    80076a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077d:	89 f0                	mov    %esi,%eax
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	8b 75 08             	mov    0x8(%ebp),%esi
  80078b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078e:	8b 55 10             	mov    0x10(%ebp),%edx
  800791:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800793:	85 d2                	test   %edx,%edx
  800795:	74 21                	je     8007b8 <strlcpy+0x35>
  800797:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079b:	89 f2                	mov    %esi,%edx
  80079d:	eb 09                	jmp    8007a8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	83 c1 01             	add    $0x1,%ecx
  8007a5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 09                	je     8007b5 <strlcpy+0x32>
  8007ac:	0f b6 19             	movzbl (%ecx),%ebx
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ec                	jne    80079f <strlcpy+0x1c>
  8007b3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b8:	29 f0                	sub    %esi,%eax
}
  8007ba:	5b                   	pop    %ebx
  8007bb:	5e                   	pop    %esi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c7:	eb 06                	jmp    8007cf <strcmp+0x11>
		p++, q++;
  8007c9:	83 c1 01             	add    $0x1,%ecx
  8007cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cf:	0f b6 01             	movzbl (%ecx),%eax
  8007d2:	84 c0                	test   %al,%al
  8007d4:	74 04                	je     8007da <strcmp+0x1c>
  8007d6:	3a 02                	cmp    (%edx),%al
  8007d8:	74 ef                	je     8007c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007da:	0f b6 c0             	movzbl %al,%eax
  8007dd:	0f b6 12             	movzbl (%edx),%edx
  8007e0:	29 d0                	sub    %edx,%eax
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ee:	89 c3                	mov    %eax,%ebx
  8007f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f3:	eb 06                	jmp    8007fb <strncmp+0x17>
		n--, p++, q++;
  8007f5:	83 c0 01             	add    $0x1,%eax
  8007f8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fb:	39 d8                	cmp    %ebx,%eax
  8007fd:	74 15                	je     800814 <strncmp+0x30>
  8007ff:	0f b6 08             	movzbl (%eax),%ecx
  800802:	84 c9                	test   %cl,%cl
  800804:	74 04                	je     80080a <strncmp+0x26>
  800806:	3a 0a                	cmp    (%edx),%cl
  800808:	74 eb                	je     8007f5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080a:	0f b6 00             	movzbl (%eax),%eax
  80080d:	0f b6 12             	movzbl (%edx),%edx
  800810:	29 d0                	sub    %edx,%eax
  800812:	eb 05                	jmp    800819 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800819:	5b                   	pop    %ebx
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800826:	eb 07                	jmp    80082f <strchr+0x13>
		if (*s == c)
  800828:	38 ca                	cmp    %cl,%dl
  80082a:	74 0f                	je     80083b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082c:	83 c0 01             	add    $0x1,%eax
  80082f:	0f b6 10             	movzbl (%eax),%edx
  800832:	84 d2                	test   %dl,%dl
  800834:	75 f2                	jne    800828 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800847:	eb 03                	jmp    80084c <strfind+0xf>
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084f:	84 d2                	test   %dl,%dl
  800851:	74 04                	je     800857 <strfind+0x1a>
  800853:	38 ca                	cmp    %cl,%dl
  800855:	75 f2                	jne    800849 <strfind+0xc>
			break;
	return (char *) s;
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	57                   	push   %edi
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800862:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800865:	85 c9                	test   %ecx,%ecx
  800867:	74 36                	je     80089f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800869:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086f:	75 28                	jne    800899 <memset+0x40>
  800871:	f6 c1 03             	test   $0x3,%cl
  800874:	75 23                	jne    800899 <memset+0x40>
		c &= 0xFF;
  800876:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087a:	89 d3                	mov    %edx,%ebx
  80087c:	c1 e3 08             	shl    $0x8,%ebx
  80087f:	89 d6                	mov    %edx,%esi
  800881:	c1 e6 18             	shl    $0x18,%esi
  800884:	89 d0                	mov    %edx,%eax
  800886:	c1 e0 10             	shl    $0x10,%eax
  800889:	09 f0                	or     %esi,%eax
  80088b:	09 c2                	or     %eax,%edx
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800891:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800894:	fc                   	cld    
  800895:	f3 ab                	rep stos %eax,%es:(%edi)
  800897:	eb 06                	jmp    80089f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089c:	fc                   	cld    
  80089d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089f:	89 f8                	mov    %edi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5f                   	pop    %edi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	57                   	push   %edi
  8008aa:	56                   	push   %esi
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b4:	39 c6                	cmp    %eax,%esi
  8008b6:	73 35                	jae    8008ed <memmove+0x47>
  8008b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bb:	39 d0                	cmp    %edx,%eax
  8008bd:	73 2e                	jae    8008ed <memmove+0x47>
		s += n;
		d += n;
  8008bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cc:	75 13                	jne    8008e1 <memmove+0x3b>
  8008ce:	f6 c1 03             	test   $0x3,%cl
  8008d1:	75 0e                	jne    8008e1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d3:	83 ef 04             	sub    $0x4,%edi
  8008d6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008dc:	fd                   	std    
  8008dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008df:	eb 09                	jmp    8008ea <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e1:	83 ef 01             	sub    $0x1,%edi
  8008e4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e7:	fd                   	std    
  8008e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ea:	fc                   	cld    
  8008eb:	eb 1d                	jmp    80090a <memmove+0x64>
  8008ed:	89 f2                	mov    %esi,%edx
  8008ef:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f1:	f6 c2 03             	test   $0x3,%dl
  8008f4:	75 0f                	jne    800905 <memmove+0x5f>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 0a                	jne    800905 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008fe:	89 c7                	mov    %eax,%edi
  800900:	fc                   	cld    
  800901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800903:	eb 05                	jmp    80090a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800905:	89 c7                	mov    %eax,%edi
  800907:	fc                   	cld    
  800908:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090a:	5e                   	pop    %esi
  80090b:	5f                   	pop    %edi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800911:	ff 75 10             	pushl  0x10(%ebp)
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	ff 75 08             	pushl  0x8(%ebp)
  80091a:	e8 87 ff ff ff       	call   8008a6 <memmove>
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 c6                	mov    %eax,%esi
  80092e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	eb 1a                	jmp    80094d <memcmp+0x2c>
		if (*s1 != *s2)
  800933:	0f b6 08             	movzbl (%eax),%ecx
  800936:	0f b6 1a             	movzbl (%edx),%ebx
  800939:	38 d9                	cmp    %bl,%cl
  80093b:	74 0a                	je     800947 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093d:	0f b6 c1             	movzbl %cl,%eax
  800940:	0f b6 db             	movzbl %bl,%ebx
  800943:	29 d8                	sub    %ebx,%eax
  800945:	eb 0f                	jmp    800956 <memcmp+0x35>
		s1++, s2++;
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094d:	39 f0                	cmp    %esi,%eax
  80094f:	75 e2                	jne    800933 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800963:	89 c2                	mov    %eax,%edx
  800965:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800968:	eb 07                	jmp    800971 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	38 08                	cmp    %cl,(%eax)
  80096c:	74 07                	je     800975 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	39 d0                	cmp    %edx,%eax
  800973:	72 f5                	jb     80096a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800983:	eb 03                	jmp    800988 <strtol+0x11>
		s++;
  800985:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800988:	0f b6 01             	movzbl (%ecx),%eax
  80098b:	3c 09                	cmp    $0x9,%al
  80098d:	74 f6                	je     800985 <strtol+0xe>
  80098f:	3c 20                	cmp    $0x20,%al
  800991:	74 f2                	je     800985 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800993:	3c 2b                	cmp    $0x2b,%al
  800995:	75 0a                	jne    8009a1 <strtol+0x2a>
		s++;
  800997:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099a:	bf 00 00 00 00       	mov    $0x0,%edi
  80099f:	eb 10                	jmp    8009b1 <strtol+0x3a>
  8009a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a6:	3c 2d                	cmp    $0x2d,%al
  8009a8:	75 07                	jne    8009b1 <strtol+0x3a>
		s++, neg = 1;
  8009aa:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009ad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b1:	85 db                	test   %ebx,%ebx
  8009b3:	0f 94 c0             	sete   %al
  8009b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bc:	75 19                	jne    8009d7 <strtol+0x60>
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 14                	jne    8009d7 <strtol+0x60>
  8009c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c7:	0f 85 82 00 00 00    	jne    800a4f <strtol+0xd8>
		s += 2, base = 16;
  8009cd:	83 c1 02             	add    $0x2,%ecx
  8009d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d5:	eb 16                	jmp    8009ed <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009d7:	84 c0                	test   %al,%al
  8009d9:	74 12                	je     8009ed <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e3:	75 08                	jne    8009ed <strtol+0x76>
		s++, base = 8;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f5:	0f b6 11             	movzbl (%ecx),%edx
  8009f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x93>
			dig = *s - '0';
  800a02:	0f be d2             	movsbl %dl,%edx
  800a05:	83 ea 30             	sub    $0x30,%edx
  800a08:	eb 22                	jmp    800a2c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 19             	cmp    $0x19,%bl
  800a12:	77 08                	ja     800a1c <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 57             	sub    $0x57,%edx
  800a1a:	eb 10                	jmp    800a2c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 16                	ja     800a3c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2f:	7d 0f                	jge    800a40 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3a:	eb b9                	jmp    8009f5 <strtol+0x7e>
  800a3c:	89 c2                	mov    %eax,%edx
  800a3e:	eb 02                	jmp    800a42 <strtol+0xcb>
  800a40:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a46:	74 0d                	je     800a55 <strtol+0xde>
		*endptr = (char *) s;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	89 0e                	mov    %ecx,(%esi)
  800a4d:	eb 06                	jmp    800a55 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	84 c0                	test   %al,%al
  800a51:	75 92                	jne    8009e5 <strtol+0x6e>
  800a53:	eb 98                	jmp    8009ed <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a55:	f7 da                	neg    %edx
  800a57:	85 ff                	test   %edi,%edi
  800a59:	0f 45 c2             	cmovne %edx,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	89 c6                	mov    %eax,%esi
  800a78:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8f:	89 d1                	mov    %edx,%ecx
  800a91:	89 d3                	mov    %edx,%ebx
  800a93:	89 d7                	mov    %edx,%edi
  800a95:	89 d6                	mov    %edx,%esi
  800a97:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aac:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab4:	89 cb                	mov    %ecx,%ebx
  800ab6:	89 cf                	mov    %ecx,%edi
  800ab8:	89 ce                	mov    %ecx,%esi
  800aba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abc:	85 c0                	test   %eax,%eax
  800abe:	7e 17                	jle    800ad7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac0:	83 ec 0c             	sub    $0xc,%esp
  800ac3:	50                   	push   %eax
  800ac4:	6a 03                	push   $0x3
  800ac6:	68 1f 22 80 00       	push   $0x80221f
  800acb:	6a 23                	push   $0x23
  800acd:	68 3c 22 80 00       	push   $0x80223c
  800ad2:	e8 44 0f 00 00       	call   801a1b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 02 00 00 00       	mov    $0x2,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_yield>:

void
sys_yield(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	be 00 00 00 00       	mov    $0x0,%esi
  800b2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b39:	89 f7                	mov    %esi,%edi
  800b3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 04                	push   $0x4
  800b47:	68 1f 22 80 00       	push   $0x80221f
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 3c 22 80 00       	push   $0x80223c
  800b53:	e8 c3 0e 00 00       	call   801a1b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 05                	push   $0x5
  800b89:	68 1f 22 80 00       	push   $0x80221f
  800b8e:	6a 23                	push   $0x23
  800b90:	68 3c 22 80 00       	push   $0x80223c
  800b95:	e8 81 0e 00 00       	call   801a1b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	89 df                	mov    %ebx,%edi
  800bbd:	89 de                	mov    %ebx,%esi
  800bbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 06                	push   $0x6
  800bcb:	68 1f 22 80 00       	push   $0x80221f
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 3c 22 80 00       	push   $0x80223c
  800bd7:	e8 3f 0e 00 00       	call   801a1b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 df                	mov    %ebx,%edi
  800bff:	89 de                	mov    %ebx,%esi
  800c01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 08                	push   $0x8
  800c0d:	68 1f 22 80 00       	push   $0x80221f
  800c12:	6a 23                	push   $0x23
  800c14:	68 3c 22 80 00       	push   $0x80223c
  800c19:	e8 fd 0d 00 00       	call   801a1b <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c34:	b8 09 00 00 00       	mov    $0x9,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 df                	mov    %ebx,%edi
  800c41:	89 de                	mov    %ebx,%esi
  800c43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 09                	push   $0x9
  800c4f:	68 1f 22 80 00       	push   $0x80221f
  800c54:	6a 23                	push   $0x23
  800c56:	68 3c 22 80 00       	push   $0x80223c
  800c5b:	e8 bb 0d 00 00       	call   801a1b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 df                	mov    %ebx,%edi
  800c83:	89 de                	mov    %ebx,%esi
  800c85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 0a                	push   $0xa
  800c91:	68 1f 22 80 00       	push   $0x80221f
  800c96:	6a 23                	push   $0x23
  800c98:	68 3c 22 80 00       	push   $0x80223c
  800c9d:	e8 79 0d 00 00       	call   801a1b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	be 00 00 00 00       	mov    $0x0,%esi
  800cb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 cb                	mov    %ecx,%ebx
  800ce5:	89 cf                	mov    %ecx,%edi
  800ce7:	89 ce                	mov    %ecx,%esi
  800ce9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 0d                	push   $0xd
  800cf5:	68 1f 22 80 00       	push   $0x80221f
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 3c 22 80 00       	push   $0x80223c
  800d01:	e8 15 0d 00 00       	call   801a1b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	05 00 00 00 30       	add    $0x30000000,%eax
  800d19:	c1 e8 0c             	shr    $0xc,%eax
}
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
  800d24:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d2e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d40:	89 c2                	mov    %eax,%edx
  800d42:	c1 ea 16             	shr    $0x16,%edx
  800d45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d4c:	f6 c2 01             	test   $0x1,%dl
  800d4f:	74 11                	je     800d62 <fd_alloc+0x2d>
  800d51:	89 c2                	mov    %eax,%edx
  800d53:	c1 ea 0c             	shr    $0xc,%edx
  800d56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d5d:	f6 c2 01             	test   $0x1,%dl
  800d60:	75 09                	jne    800d6b <fd_alloc+0x36>
			*fd_store = fd;
  800d62:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
  800d69:	eb 17                	jmp    800d82 <fd_alloc+0x4d>
  800d6b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d70:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d75:	75 c9                	jne    800d40 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d77:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d7d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d8a:	83 f8 1f             	cmp    $0x1f,%eax
  800d8d:	77 36                	ja     800dc5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d8f:	c1 e0 0c             	shl    $0xc,%eax
  800d92:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d97:	89 c2                	mov    %eax,%edx
  800d99:	c1 ea 16             	shr    $0x16,%edx
  800d9c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da3:	f6 c2 01             	test   $0x1,%dl
  800da6:	74 24                	je     800dcc <fd_lookup+0x48>
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	c1 ea 0c             	shr    $0xc,%edx
  800dad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db4:	f6 c2 01             	test   $0x1,%dl
  800db7:	74 1a                	je     800dd3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbc:	89 02                	mov    %eax,(%edx)
	return 0;
  800dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc3:	eb 13                	jmp    800dd8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dca:	eb 0c                	jmp    800dd8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd1:	eb 05                	jmp    800dd8 <fd_lookup+0x54>
  800dd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 08             	sub    $0x8,%esp
  800de0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de3:	ba c8 22 80 00       	mov    $0x8022c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800de8:	eb 13                	jmp    800dfd <dev_lookup+0x23>
  800dea:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ded:	39 08                	cmp    %ecx,(%eax)
  800def:	75 0c                	jne    800dfd <dev_lookup+0x23>
			*dev = devtab[i];
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfb:	eb 2e                	jmp    800e2b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dfd:	8b 02                	mov    (%edx),%eax
  800dff:	85 c0                	test   %eax,%eax
  800e01:	75 e7                	jne    800dea <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e03:	a1 04 40 80 00       	mov    0x804004,%eax
  800e08:	8b 40 48             	mov    0x48(%eax),%eax
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	51                   	push   %ecx
  800e0f:	50                   	push   %eax
  800e10:	68 4c 22 80 00       	push   $0x80224c
  800e15:	e8 73 f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    

00800e2d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 10             	sub    $0x10,%esp
  800e35:	8b 75 08             	mov    0x8(%ebp),%esi
  800e38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e3e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e45:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e48:	50                   	push   %eax
  800e49:	e8 36 ff ff ff       	call   800d84 <fd_lookup>
  800e4e:	83 c4 08             	add    $0x8,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 05                	js     800e5a <fd_close+0x2d>
	    || fd != fd2)
  800e55:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e58:	74 0c                	je     800e66 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e5a:	84 db                	test   %bl,%bl
  800e5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e61:	0f 44 c2             	cmove  %edx,%eax
  800e64:	eb 41                	jmp    800ea7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e6c:	50                   	push   %eax
  800e6d:	ff 36                	pushl  (%esi)
  800e6f:	e8 66 ff ff ff       	call   800dda <dev_lookup>
  800e74:	89 c3                	mov    %eax,%ebx
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	78 1a                	js     800e97 <fd_close+0x6a>
		if (dev->dev_close)
  800e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e80:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	74 0b                	je     800e97 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	56                   	push   %esi
  800e90:	ff d0                	call   *%eax
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	56                   	push   %esi
  800e9b:	6a 00                	push   $0x0
  800e9d:	e8 00 fd ff ff       	call   800ba2 <sys_page_unmap>
	return r;
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	89 d8                	mov    %ebx,%eax
}
  800ea7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb7:	50                   	push   %eax
  800eb8:	ff 75 08             	pushl  0x8(%ebp)
  800ebb:	e8 c4 fe ff ff       	call   800d84 <fd_lookup>
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	83 c4 08             	add    $0x8,%esp
  800ec5:	85 d2                	test   %edx,%edx
  800ec7:	78 10                	js     800ed9 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	6a 01                	push   $0x1
  800ece:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed1:	e8 57 ff ff ff       	call   800e2d <fd_close>
  800ed6:	83 c4 10             	add    $0x10,%esp
}
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <close_all>:

void
close_all(void)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	53                   	push   %ebx
  800edf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ee7:	83 ec 0c             	sub    $0xc,%esp
  800eea:	53                   	push   %ebx
  800eeb:	e8 be ff ff ff       	call   800eae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef0:	83 c3 01             	add    $0x1,%ebx
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	83 fb 20             	cmp    $0x20,%ebx
  800ef9:	75 ec                	jne    800ee7 <close_all+0xc>
		close(i);
}
  800efb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 2c             	sub    $0x2c,%esp
  800f09:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f0c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f0f:	50                   	push   %eax
  800f10:	ff 75 08             	pushl  0x8(%ebp)
  800f13:	e8 6c fe ff ff       	call   800d84 <fd_lookup>
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	83 c4 08             	add    $0x8,%esp
  800f1d:	85 d2                	test   %edx,%edx
  800f1f:	0f 88 c1 00 00 00    	js     800fe6 <dup+0xe6>
		return r;
	close(newfdnum);
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	56                   	push   %esi
  800f29:	e8 80 ff ff ff       	call   800eae <close>

	newfd = INDEX2FD(newfdnum);
  800f2e:	89 f3                	mov    %esi,%ebx
  800f30:	c1 e3 0c             	shl    $0xc,%ebx
  800f33:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f39:	83 c4 04             	add    $0x4,%esp
  800f3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3f:	e8 da fd ff ff       	call   800d1e <fd2data>
  800f44:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f46:	89 1c 24             	mov    %ebx,(%esp)
  800f49:	e8 d0 fd ff ff       	call   800d1e <fd2data>
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f54:	89 f8                	mov    %edi,%eax
  800f56:	c1 e8 16             	shr    $0x16,%eax
  800f59:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f60:	a8 01                	test   $0x1,%al
  800f62:	74 37                	je     800f9b <dup+0x9b>
  800f64:	89 f8                	mov    %edi,%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f70:	f6 c2 01             	test   $0x1,%dl
  800f73:	74 26                	je     800f9b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f75:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f84:	50                   	push   %eax
  800f85:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f88:	6a 00                	push   $0x0
  800f8a:	57                   	push   %edi
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 ce fb ff ff       	call   800b60 <sys_page_map>
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 2e                	js     800fc9 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f9e:	89 d0                	mov    %edx,%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
  800fa3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb2:	50                   	push   %eax
  800fb3:	53                   	push   %ebx
  800fb4:	6a 00                	push   $0x0
  800fb6:	52                   	push   %edx
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 a2 fb ff ff       	call   800b60 <sys_page_map>
  800fbe:	89 c7                	mov    %eax,%edi
  800fc0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc5:	85 ff                	test   %edi,%edi
  800fc7:	79 1d                	jns    800fe6 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fc9:	83 ec 08             	sub    $0x8,%esp
  800fcc:	53                   	push   %ebx
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 ce fb ff ff       	call   800ba2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 c1 fb ff ff       	call   800ba2 <sys_page_unmap>
	return r;
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	89 f8                	mov    %edi,%eax
}
  800fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 14             	sub    $0x14,%esp
  800ff5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ff8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	53                   	push   %ebx
  800ffd:	e8 82 fd ff ff       	call   800d84 <fd_lookup>
  801002:	83 c4 08             	add    $0x8,%esp
  801005:	89 c2                	mov    %eax,%edx
  801007:	85 c0                	test   %eax,%eax
  801009:	78 6d                	js     801078 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801015:	ff 30                	pushl  (%eax)
  801017:	e8 be fd ff ff       	call   800dda <dev_lookup>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 4c                	js     80106f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801023:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801026:	8b 42 08             	mov    0x8(%edx),%eax
  801029:	83 e0 03             	and    $0x3,%eax
  80102c:	83 f8 01             	cmp    $0x1,%eax
  80102f:	75 21                	jne    801052 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801031:	a1 04 40 80 00       	mov    0x804004,%eax
  801036:	8b 40 48             	mov    0x48(%eax),%eax
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	53                   	push   %ebx
  80103d:	50                   	push   %eax
  80103e:	68 8d 22 80 00       	push   $0x80228d
  801043:	e8 45 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801050:	eb 26                	jmp    801078 <read+0x8a>
	}
	if (!dev->dev_read)
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801055:	8b 40 08             	mov    0x8(%eax),%eax
  801058:	85 c0                	test   %eax,%eax
  80105a:	74 17                	je     801073 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	ff 75 10             	pushl  0x10(%ebp)
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	52                   	push   %edx
  801066:	ff d0                	call   *%eax
  801068:	89 c2                	mov    %eax,%edx
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	eb 09                	jmp    801078 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106f:	89 c2                	mov    %eax,%edx
  801071:	eb 05                	jmp    801078 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801073:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801078:	89 d0                	mov    %edx,%eax
  80107a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801093:	eb 21                	jmp    8010b6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	89 f0                	mov    %esi,%eax
  80109a:	29 d8                	sub    %ebx,%eax
  80109c:	50                   	push   %eax
  80109d:	89 d8                	mov    %ebx,%eax
  80109f:	03 45 0c             	add    0xc(%ebp),%eax
  8010a2:	50                   	push   %eax
  8010a3:	57                   	push   %edi
  8010a4:	e8 45 ff ff ff       	call   800fee <read>
		if (m < 0)
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 0c                	js     8010bc <readn+0x3d>
			return m;
		if (m == 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	74 06                	je     8010ba <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b4:	01 c3                	add    %eax,%ebx
  8010b6:	39 f3                	cmp    %esi,%ebx
  8010b8:	72 db                	jb     801095 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8010ba:	89 d8                	mov    %ebx,%eax
}
  8010bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 14             	sub    $0x14,%esp
  8010cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	53                   	push   %ebx
  8010d3:	e8 ac fc ff ff       	call   800d84 <fd_lookup>
  8010d8:	83 c4 08             	add    $0x8,%esp
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 68                	js     801149 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e1:	83 ec 08             	sub    $0x8,%esp
  8010e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e7:	50                   	push   %eax
  8010e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010eb:	ff 30                	pushl  (%eax)
  8010ed:	e8 e8 fc ff ff       	call   800dda <dev_lookup>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 47                	js     801140 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801100:	75 21                	jne    801123 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801102:	a1 04 40 80 00       	mov    0x804004,%eax
  801107:	8b 40 48             	mov    0x48(%eax),%eax
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	53                   	push   %ebx
  80110e:	50                   	push   %eax
  80110f:	68 a9 22 80 00       	push   $0x8022a9
  801114:	e8 74 f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801121:	eb 26                	jmp    801149 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801123:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801126:	8b 52 0c             	mov    0xc(%edx),%edx
  801129:	85 d2                	test   %edx,%edx
  80112b:	74 17                	je     801144 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	ff 75 10             	pushl  0x10(%ebp)
  801133:	ff 75 0c             	pushl  0xc(%ebp)
  801136:	50                   	push   %eax
  801137:	ff d2                	call   *%edx
  801139:	89 c2                	mov    %eax,%edx
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	eb 09                	jmp    801149 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801140:	89 c2                	mov    %eax,%edx
  801142:	eb 05                	jmp    801149 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801144:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801149:	89 d0                	mov    %edx,%eax
  80114b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <seek>:

int
seek(int fdnum, off_t offset)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801156:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	ff 75 08             	pushl  0x8(%ebp)
  80115d:	e8 22 fc ff ff       	call   800d84 <fd_lookup>
  801162:	83 c4 08             	add    $0x8,%esp
  801165:	85 c0                	test   %eax,%eax
  801167:	78 0e                	js     801177 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801169:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80116c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	53                   	push   %ebx
  80117d:	83 ec 14             	sub    $0x14,%esp
  801180:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801183:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801186:	50                   	push   %eax
  801187:	53                   	push   %ebx
  801188:	e8 f7 fb ff ff       	call   800d84 <fd_lookup>
  80118d:	83 c4 08             	add    $0x8,%esp
  801190:	89 c2                	mov    %eax,%edx
  801192:	85 c0                	test   %eax,%eax
  801194:	78 65                	js     8011fb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a0:	ff 30                	pushl  (%eax)
  8011a2:	e8 33 fc ff ff       	call   800dda <dev_lookup>
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 44                	js     8011f2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b5:	75 21                	jne    8011d8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011b7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011bc:	8b 40 48             	mov    0x48(%eax),%eax
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	53                   	push   %ebx
  8011c3:	50                   	push   %eax
  8011c4:	68 6c 22 80 00       	push   $0x80226c
  8011c9:	e8 bf ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d6:	eb 23                	jmp    8011fb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011db:	8b 52 18             	mov    0x18(%edx),%edx
  8011de:	85 d2                	test   %edx,%edx
  8011e0:	74 14                	je     8011f6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	ff 75 0c             	pushl  0xc(%ebp)
  8011e8:	50                   	push   %eax
  8011e9:	ff d2                	call   *%edx
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	eb 09                	jmp    8011fb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	eb 05                	jmp    8011fb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011fb:	89 d0                	mov    %edx,%eax
  8011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	53                   	push   %ebx
  801206:	83 ec 14             	sub    $0x14,%esp
  801209:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 6c fb ff ff       	call   800d84 <fd_lookup>
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 58                	js     801279 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122b:	ff 30                	pushl  (%eax)
  80122d:	e8 a8 fb ff ff       	call   800dda <dev_lookup>
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 37                	js     801270 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801239:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801240:	74 32                	je     801274 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801242:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801245:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80124c:	00 00 00 
	stat->st_isdir = 0;
  80124f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801256:	00 00 00 
	stat->st_dev = dev;
  801259:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	53                   	push   %ebx
  801263:	ff 75 f0             	pushl  -0x10(%ebp)
  801266:	ff 50 14             	call   *0x14(%eax)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	eb 09                	jmp    801279 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801270:	89 c2                	mov    %eax,%edx
  801272:	eb 05                	jmp    801279 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801274:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801279:	89 d0                	mov    %edx,%eax
  80127b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	6a 00                	push   $0x0
  80128a:	ff 75 08             	pushl  0x8(%ebp)
  80128d:	e8 09 02 00 00       	call   80149b <open>
  801292:	89 c3                	mov    %eax,%ebx
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 db                	test   %ebx,%ebx
  801299:	78 1b                	js     8012b6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	ff 75 0c             	pushl  0xc(%ebp)
  8012a1:	53                   	push   %ebx
  8012a2:	e8 5b ff ff ff       	call   801202 <fstat>
  8012a7:	89 c6                	mov    %eax,%esi
	close(fd);
  8012a9:	89 1c 24             	mov    %ebx,(%esp)
  8012ac:	e8 fd fb ff ff       	call   800eae <close>
	return r;
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	89 f0                	mov    %esi,%eax
}
  8012b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
  8012c2:	89 c6                	mov    %eax,%esi
  8012c4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012c6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012cd:	75 12                	jne    8012e1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	6a 01                	push   $0x1
  8012d4:	e8 45 08 00 00       	call   801b1e <ipc_find_env>
  8012d9:	a3 00 40 80 00       	mov    %eax,0x804000
  8012de:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e1:	6a 07                	push   $0x7
  8012e3:	68 00 50 80 00       	push   $0x805000
  8012e8:	56                   	push   %esi
  8012e9:	ff 35 00 40 80 00    	pushl  0x804000
  8012ef:	e8 d6 07 00 00       	call   801aca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012f4:	83 c4 0c             	add    $0xc,%esp
  8012f7:	6a 00                	push   $0x0
  8012f9:	53                   	push   %ebx
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 60 07 00 00       	call   801a61 <ipc_recv>
}
  801301:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	8b 40 0c             	mov    0xc(%eax),%eax
  801314:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801319:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801321:	ba 00 00 00 00       	mov    $0x0,%edx
  801326:	b8 02 00 00 00       	mov    $0x2,%eax
  80132b:	e8 8d ff ff ff       	call   8012bd <fsipc>
}
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	8b 40 0c             	mov    0xc(%eax),%eax
  80133e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801343:	ba 00 00 00 00       	mov    $0x0,%edx
  801348:	b8 06 00 00 00       	mov    $0x6,%eax
  80134d:	e8 6b ff ff ff       	call   8012bd <fsipc>
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	53                   	push   %ebx
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80135e:	8b 45 08             	mov    0x8(%ebp),%eax
  801361:	8b 40 0c             	mov    0xc(%eax),%eax
  801364:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801369:	ba 00 00 00 00       	mov    $0x0,%edx
  80136e:	b8 05 00 00 00       	mov    $0x5,%eax
  801373:	e8 45 ff ff ff       	call   8012bd <fsipc>
  801378:	89 c2                	mov    %eax,%edx
  80137a:	85 d2                	test   %edx,%edx
  80137c:	78 2c                	js     8013aa <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	68 00 50 80 00       	push   $0x805000
  801386:	53                   	push   %ebx
  801387:	e8 88 f3 ff ff       	call   800714 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80138c:	a1 80 50 80 00       	mov    0x805080,%eax
  801391:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801397:	a1 84 50 80 00       	mov    0x805084,%eax
  80139c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	57                   	push   %edi
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c1:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8013c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8013c9:	eb 3d                	jmp    801408 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8013cb:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8013d1:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8013d6:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	57                   	push   %edi
  8013dd:	53                   	push   %ebx
  8013de:	68 08 50 80 00       	push   $0x805008
  8013e3:	e8 be f4 ff ff       	call   8008a6 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8013e8:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f8:	e8 c0 fe ff ff       	call   8012bd <fsipc>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 0d                	js     801411 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801404:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801406:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801408:	85 f6                	test   %esi,%esi
  80140a:	75 bf                	jne    8013cb <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80140c:	89 d8                	mov    %ebx,%eax
  80140e:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801411:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5f                   	pop    %edi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    

00801419 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	56                   	push   %esi
  80141d:	53                   	push   %ebx
  80141e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 40 0c             	mov    0xc(%eax),%eax
  801427:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80142c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
  801437:	b8 03 00 00 00       	mov    $0x3,%eax
  80143c:	e8 7c fe ff ff       	call   8012bd <fsipc>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	85 c0                	test   %eax,%eax
  801445:	78 4b                	js     801492 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801447:	39 c6                	cmp    %eax,%esi
  801449:	73 16                	jae    801461 <devfile_read+0x48>
  80144b:	68 d8 22 80 00       	push   $0x8022d8
  801450:	68 df 22 80 00       	push   $0x8022df
  801455:	6a 7c                	push   $0x7c
  801457:	68 f4 22 80 00       	push   $0x8022f4
  80145c:	e8 ba 05 00 00       	call   801a1b <_panic>
	assert(r <= PGSIZE);
  801461:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801466:	7e 16                	jle    80147e <devfile_read+0x65>
  801468:	68 ff 22 80 00       	push   $0x8022ff
  80146d:	68 df 22 80 00       	push   $0x8022df
  801472:	6a 7d                	push   $0x7d
  801474:	68 f4 22 80 00       	push   $0x8022f4
  801479:	e8 9d 05 00 00       	call   801a1b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80147e:	83 ec 04             	sub    $0x4,%esp
  801481:	50                   	push   %eax
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	ff 75 0c             	pushl  0xc(%ebp)
  80148a:	e8 17 f4 ff ff       	call   8008a6 <memmove>
	return r;
  80148f:	83 c4 10             	add    $0x10,%esp
}
  801492:	89 d8                	mov    %ebx,%eax
  801494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 20             	sub    $0x20,%esp
  8014a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014a5:	53                   	push   %ebx
  8014a6:	e8 30 f2 ff ff       	call   8006db <strlen>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b3:	7f 67                	jg     80151c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	e8 74 f8 ff ff       	call   800d35 <fd_alloc>
  8014c1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 57                	js     801521 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	68 00 50 80 00       	push   $0x805000
  8014d3:	e8 3c f2 ff ff       	call   800714 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014db:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e8:	e8 d0 fd ff ff       	call   8012bd <fsipc>
  8014ed:	89 c3                	mov    %eax,%ebx
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	79 14                	jns    80150a <open+0x6f>
		fd_close(fd, 0);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	6a 00                	push   $0x0
  8014fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fe:	e8 2a f9 ff ff       	call   800e2d <fd_close>
		return r;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	89 da                	mov    %ebx,%edx
  801508:	eb 17                	jmp    801521 <open+0x86>
	}

	return fd2num(fd);
  80150a:	83 ec 0c             	sub    $0xc,%esp
  80150d:	ff 75 f4             	pushl  -0xc(%ebp)
  801510:	e8 f9 f7 ff ff       	call   800d0e <fd2num>
  801515:	89 c2                	mov    %eax,%edx
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	eb 05                	jmp    801521 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80151c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801521:	89 d0                	mov    %edx,%eax
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	b8 08 00 00 00       	mov    $0x8,%eax
  801538:	e8 80 fd ff ff       	call   8012bd <fsipc>
}
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	ff 75 08             	pushl  0x8(%ebp)
  80154d:	e8 cc f7 ff ff       	call   800d1e <fd2data>
  801552:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801554:	83 c4 08             	add    $0x8,%esp
  801557:	68 0b 23 80 00       	push   $0x80230b
  80155c:	53                   	push   %ebx
  80155d:	e8 b2 f1 ff ff       	call   800714 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801562:	8b 56 04             	mov    0x4(%esi),%edx
  801565:	89 d0                	mov    %edx,%eax
  801567:	2b 06                	sub    (%esi),%eax
  801569:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80156f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801576:	00 00 00 
	stat->st_dev = &devpipe;
  801579:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801580:	30 80 00 
	return 0;
}
  801583:	b8 00 00 00 00       	mov    $0x0,%eax
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801599:	53                   	push   %ebx
  80159a:	6a 00                	push   $0x0
  80159c:	e8 01 f6 ff ff       	call   800ba2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a1:	89 1c 24             	mov    %ebx,(%esp)
  8015a4:	e8 75 f7 ff ff       	call   800d1e <fd2data>
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	50                   	push   %eax
  8015ad:	6a 00                	push   $0x0
  8015af:	e8 ee f5 ff ff       	call   800ba2 <sys_page_unmap>
}
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 1c             	sub    $0x1c,%esp
  8015c2:	89 c6                	mov    %eax,%esi
  8015c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	56                   	push   %esi
  8015d3:	e8 7e 05 00 00       	call   801b56 <pageref>
  8015d8:	89 c7                	mov    %eax,%edi
  8015da:	83 c4 04             	add    $0x4,%esp
  8015dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e0:	e8 71 05 00 00       	call   801b56 <pageref>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	39 c7                	cmp    %eax,%edi
  8015ea:	0f 94 c2             	sete   %dl
  8015ed:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8015f0:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8015f6:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8015f9:	39 fb                	cmp    %edi,%ebx
  8015fb:	74 19                	je     801616 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8015fd:	84 d2                	test   %dl,%dl
  8015ff:	74 c6                	je     8015c7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801601:	8b 51 58             	mov    0x58(%ecx),%edx
  801604:	50                   	push   %eax
  801605:	52                   	push   %edx
  801606:	53                   	push   %ebx
  801607:	68 12 23 80 00       	push   $0x802312
  80160c:	e8 7c eb ff ff       	call   80018d <cprintf>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb b1                	jmp    8015c7 <_pipeisclosed+0xe>
	}
}
  801616:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5f                   	pop    %edi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	57                   	push   %edi
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 28             	sub    $0x28,%esp
  801627:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80162a:	56                   	push   %esi
  80162b:	e8 ee f6 ff ff       	call   800d1e <fd2data>
  801630:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	bf 00 00 00 00       	mov    $0x0,%edi
  80163a:	eb 4b                	jmp    801687 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80163c:	89 da                	mov    %ebx,%edx
  80163e:	89 f0                	mov    %esi,%eax
  801640:	e8 74 ff ff ff       	call   8015b9 <_pipeisclosed>
  801645:	85 c0                	test   %eax,%eax
  801647:	75 48                	jne    801691 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801649:	e8 b0 f4 ff ff       	call   800afe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80164e:	8b 43 04             	mov    0x4(%ebx),%eax
  801651:	8b 0b                	mov    (%ebx),%ecx
  801653:	8d 51 20             	lea    0x20(%ecx),%edx
  801656:	39 d0                	cmp    %edx,%eax
  801658:	73 e2                	jae    80163c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80165a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801661:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801664:	89 c2                	mov    %eax,%edx
  801666:	c1 fa 1f             	sar    $0x1f,%edx
  801669:	89 d1                	mov    %edx,%ecx
  80166b:	c1 e9 1b             	shr    $0x1b,%ecx
  80166e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801671:	83 e2 1f             	and    $0x1f,%edx
  801674:	29 ca                	sub    %ecx,%edx
  801676:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80167a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80167e:	83 c0 01             	add    $0x1,%eax
  801681:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801684:	83 c7 01             	add    $0x1,%edi
  801687:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80168a:	75 c2                	jne    80164e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80168c:	8b 45 10             	mov    0x10(%ebp),%eax
  80168f:	eb 05                	jmp    801696 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	57                   	push   %edi
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 18             	sub    $0x18,%esp
  8016a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016aa:	57                   	push   %edi
  8016ab:	e8 6e f6 ff ff       	call   800d1e <fd2data>
  8016b0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ba:	eb 3d                	jmp    8016f9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016bc:	85 db                	test   %ebx,%ebx
  8016be:	74 04                	je     8016c4 <devpipe_read+0x26>
				return i;
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	eb 44                	jmp    801708 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016c4:	89 f2                	mov    %esi,%edx
  8016c6:	89 f8                	mov    %edi,%eax
  8016c8:	e8 ec fe ff ff       	call   8015b9 <_pipeisclosed>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	75 32                	jne    801703 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016d1:	e8 28 f4 ff ff       	call   800afe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016d6:	8b 06                	mov    (%esi),%eax
  8016d8:	3b 46 04             	cmp    0x4(%esi),%eax
  8016db:	74 df                	je     8016bc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016dd:	99                   	cltd   
  8016de:	c1 ea 1b             	shr    $0x1b,%edx
  8016e1:	01 d0                	add    %edx,%eax
  8016e3:	83 e0 1f             	and    $0x1f,%eax
  8016e6:	29 d0                	sub    %edx,%eax
  8016e8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016f3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f6:	83 c3 01             	add    $0x1,%ebx
  8016f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016fc:	75 d8                	jne    8016d6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801701:	eb 05                	jmp    801708 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801703:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5f                   	pop    %edi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	56                   	push   %esi
  801714:	53                   	push   %ebx
  801715:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801718:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	e8 14 f6 ff ff       	call   800d35 <fd_alloc>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	89 c2                	mov    %eax,%edx
  801726:	85 c0                	test   %eax,%eax
  801728:	0f 88 2c 01 00 00    	js     80185a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	68 07 04 00 00       	push   $0x407
  801736:	ff 75 f4             	pushl  -0xc(%ebp)
  801739:	6a 00                	push   $0x0
  80173b:	e8 dd f3 ff ff       	call   800b1d <sys_page_alloc>
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	89 c2                	mov    %eax,%edx
  801745:	85 c0                	test   %eax,%eax
  801747:	0f 88 0d 01 00 00    	js     80185a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	e8 dc f5 ff ff       	call   800d35 <fd_alloc>
  801759:	89 c3                	mov    %eax,%ebx
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	85 c0                	test   %eax,%eax
  801760:	0f 88 e2 00 00 00    	js     801848 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801766:	83 ec 04             	sub    $0x4,%esp
  801769:	68 07 04 00 00       	push   $0x407
  80176e:	ff 75 f0             	pushl  -0x10(%ebp)
  801771:	6a 00                	push   $0x0
  801773:	e8 a5 f3 ff ff       	call   800b1d <sys_page_alloc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	0f 88 c3 00 00 00    	js     801848 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801785:	83 ec 0c             	sub    $0xc,%esp
  801788:	ff 75 f4             	pushl  -0xc(%ebp)
  80178b:	e8 8e f5 ff ff       	call   800d1e <fd2data>
  801790:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801792:	83 c4 0c             	add    $0xc,%esp
  801795:	68 07 04 00 00       	push   $0x407
  80179a:	50                   	push   %eax
  80179b:	6a 00                	push   $0x0
  80179d:	e8 7b f3 ff ff       	call   800b1d <sys_page_alloc>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	0f 88 89 00 00 00    	js     801838 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b5:	e8 64 f5 ff ff       	call   800d1e <fd2data>
  8017ba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c1:	50                   	push   %eax
  8017c2:	6a 00                	push   $0x0
  8017c4:	56                   	push   %esi
  8017c5:	6a 00                	push   $0x0
  8017c7:	e8 94 f3 ff ff       	call   800b60 <sys_page_map>
  8017cc:	89 c3                	mov    %eax,%ebx
  8017ce:	83 c4 20             	add    $0x20,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 55                	js     80182a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017d5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017de:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	ff 75 f4             	pushl  -0xc(%ebp)
  801805:	e8 04 f5 ff ff       	call   800d0e <fd2num>
  80180a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80180d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80180f:	83 c4 04             	add    $0x4,%esp
  801812:	ff 75 f0             	pushl  -0x10(%ebp)
  801815:	e8 f4 f4 ff ff       	call   800d0e <fd2num>
  80181a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80181d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	eb 30                	jmp    80185a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	56                   	push   %esi
  80182e:	6a 00                	push   $0x0
  801830:	e8 6d f3 ff ff       	call   800ba2 <sys_page_unmap>
  801835:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	ff 75 f0             	pushl  -0x10(%ebp)
  80183e:	6a 00                	push   $0x0
  801840:	e8 5d f3 ff ff       	call   800ba2 <sys_page_unmap>
  801845:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	ff 75 f4             	pushl  -0xc(%ebp)
  80184e:	6a 00                	push   $0x0
  801850:	e8 4d f3 ff ff       	call   800ba2 <sys_page_unmap>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80185a:	89 d0                	mov    %edx,%eax
  80185c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	ff 75 08             	pushl  0x8(%ebp)
  801870:	e8 0f f5 ff ff       	call   800d84 <fd_lookup>
  801875:	89 c2                	mov    %eax,%edx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 d2                	test   %edx,%edx
  80187c:	78 18                	js     801896 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	ff 75 f4             	pushl  -0xc(%ebp)
  801884:	e8 95 f4 ff ff       	call   800d1e <fd2data>
	return _pipeisclosed(fd, p);
  801889:	89 c2                	mov    %eax,%edx
  80188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188e:	e8 26 fd ff ff       	call   8015b9 <_pipeisclosed>
  801893:	83 c4 10             	add    $0x10,%esp
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018a8:	68 2a 23 80 00       	push   $0x80232a
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	e8 5f ee ff ff       	call   800714 <strcpy>
	return 0;
}
  8018b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018cd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d3:	eb 2d                	jmp    801902 <devcons_write+0x46>
		m = n - tot;
  8018d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018d8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018da:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018dd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018e2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	03 45 0c             	add    0xc(%ebp),%eax
  8018ec:	50                   	push   %eax
  8018ed:	57                   	push   %edi
  8018ee:	e8 b3 ef ff ff       	call   8008a6 <memmove>
		sys_cputs(buf, m);
  8018f3:	83 c4 08             	add    $0x8,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	57                   	push   %edi
  8018f8:	e8 64 f1 ff ff       	call   800a61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018fd:	01 de                	add    %ebx,%esi
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	89 f0                	mov    %esi,%eax
  801904:	3b 75 10             	cmp    0x10(%ebp),%esi
  801907:	72 cc                	jb     8018d5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801909:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80191c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801920:	75 07                	jne    801929 <devcons_read+0x18>
  801922:	eb 28                	jmp    80194c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801924:	e8 d5 f1 ff ff       	call   800afe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801929:	e8 51 f1 ff ff       	call   800a7f <sys_cgetc>
  80192e:	85 c0                	test   %eax,%eax
  801930:	74 f2                	je     801924 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801932:	85 c0                	test   %eax,%eax
  801934:	78 16                	js     80194c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801936:	83 f8 04             	cmp    $0x4,%eax
  801939:	74 0c                	je     801947 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80193b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193e:	88 02                	mov    %al,(%edx)
	return 1;
  801940:	b8 01 00 00 00       	mov    $0x1,%eax
  801945:	eb 05                	jmp    80194c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80195a:	6a 01                	push   $0x1
  80195c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80195f:	50                   	push   %eax
  801960:	e8 fc f0 ff ff       	call   800a61 <sys_cputs>
  801965:	83 c4 10             	add    $0x10,%esp
}
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <getchar>:

int
getchar(void)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801970:	6a 01                	push   $0x1
  801972:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	6a 00                	push   $0x0
  801978:	e8 71 f6 ff ff       	call   800fee <read>
	if (r < 0)
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	85 c0                	test   %eax,%eax
  801982:	78 0f                	js     801993 <getchar+0x29>
		return r;
	if (r < 1)
  801984:	85 c0                	test   %eax,%eax
  801986:	7e 06                	jle    80198e <getchar+0x24>
		return -E_EOF;
	return c;
  801988:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80198c:	eb 05                	jmp    801993 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80198e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199e:	50                   	push   %eax
  80199f:	ff 75 08             	pushl  0x8(%ebp)
  8019a2:	e8 dd f3 ff ff       	call   800d84 <fd_lookup>
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 11                	js     8019bf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b7:	39 10                	cmp    %edx,(%eax)
  8019b9:	0f 94 c0             	sete   %al
  8019bc:	0f b6 c0             	movzbl %al,%eax
}
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <opencons>:

int
opencons(void)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ca:	50                   	push   %eax
  8019cb:	e8 65 f3 ff ff       	call   800d35 <fd_alloc>
  8019d0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 3e                	js     801a17 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	68 07 04 00 00       	push   $0x407
  8019e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 32 f1 ff ff       	call   800b1d <sys_page_alloc>
  8019eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ee:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 23                	js     801a17 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019f4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	50                   	push   %eax
  801a0d:	e8 fc f2 ff ff       	call   800d0e <fd2num>
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	83 c4 10             	add    $0x10,%esp
}
  801a17:	89 d0                	mov    %edx,%eax
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a20:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a23:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a29:	e8 b1 f0 ff ff       	call   800adf <sys_getenvid>
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	ff 75 08             	pushl  0x8(%ebp)
  801a37:	56                   	push   %esi
  801a38:	50                   	push   %eax
  801a39:	68 38 23 80 00       	push   $0x802338
  801a3e:	e8 4a e7 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a43:	83 c4 18             	add    $0x18,%esp
  801a46:	53                   	push   %ebx
  801a47:	ff 75 10             	pushl  0x10(%ebp)
  801a4a:	e8 ed e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801a4f:	c7 04 24 23 23 80 00 	movl   $0x802323,(%esp)
  801a56:	e8 32 e7 ff ff       	call   80018d <cprintf>
  801a5b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a5e:	cc                   	int3   
  801a5f:	eb fd                	jmp    801a5e <_panic+0x43>

00801a61 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a76:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	50                   	push   %eax
  801a7d:	e8 4b f2 ff ff       	call   800ccd <sys_ipc_recv>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	79 16                	jns    801a9f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a89:	85 f6                	test   %esi,%esi
  801a8b:	74 06                	je     801a93 <ipc_recv+0x32>
  801a8d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	74 2c                	je     801ac3 <ipc_recv+0x62>
  801a97:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a9d:	eb 24                	jmp    801ac3 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a9f:	85 f6                	test   %esi,%esi
  801aa1:	74 0a                	je     801aad <ipc_recv+0x4c>
  801aa3:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa8:	8b 40 74             	mov    0x74(%eax),%eax
  801aab:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	74 0a                	je     801abb <ipc_recv+0x5a>
  801ab1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab6:	8b 40 78             	mov    0x78(%eax),%eax
  801ab9:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801abb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	57                   	push   %edi
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae3:	0f 44 d8             	cmove  %eax,%ebx
  801ae6:	eb 1c                	jmp    801b04 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801ae8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aeb:	74 12                	je     801aff <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801aed:	50                   	push   %eax
  801aee:	68 5c 23 80 00       	push   $0x80235c
  801af3:	6a 39                	push   $0x39
  801af5:	68 77 23 80 00       	push   $0x802377
  801afa:	e8 1c ff ff ff       	call   801a1b <_panic>
                 sys_yield();
  801aff:	e8 fa ef ff ff       	call   800afe <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b04:	ff 75 14             	pushl  0x14(%ebp)
  801b07:	53                   	push   %ebx
  801b08:	56                   	push   %esi
  801b09:	57                   	push   %edi
  801b0a:	e8 9b f1 ff ff       	call   800caa <sys_ipc_try_send>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 d2                	js     801ae8 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b32:	8b 52 50             	mov    0x50(%edx),%edx
  801b35:	39 ca                	cmp    %ecx,%edx
  801b37:	75 0d                	jne    801b46 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3c:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b41:	8b 40 08             	mov    0x8(%eax),%eax
  801b44:	eb 0e                	jmp    801b54 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b46:	83 c0 01             	add    $0x1,%eax
  801b49:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4e:	75 d9                	jne    801b29 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b50:	66 b8 00 00          	mov    $0x0,%ax
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5c:	89 d0                	mov    %edx,%eax
  801b5e:	c1 e8 16             	shr    $0x16,%eax
  801b61:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6d:	f6 c1 01             	test   $0x1,%cl
  801b70:	74 1d                	je     801b8f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b72:	c1 ea 0c             	shr    $0xc,%edx
  801b75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7c:	f6 c2 01             	test   $0x1,%dl
  801b7f:	74 0e                	je     801b8f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b81:	c1 ea 0c             	shr    $0xc,%edx
  801b84:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8b:	ef 
  801b8c:	0f b7 c0             	movzwl %ax,%eax
}
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	66 90                	xchg   %ax,%ax
  801b93:	66 90                	xchg   %ax,%ax
  801b95:	66 90                	xchg   %ax,%ax
  801b97:	66 90                	xchg   %ax,%ax
  801b99:	66 90                	xchg   %ax,%ax
  801b9b:	66 90                	xchg   %ax,%ax
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	83 ec 10             	sub    $0x10,%esp
  801ba6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801baa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bae:	8b 74 24 24          	mov    0x24(%esp),%esi
  801bb2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bb6:	85 d2                	test   %edx,%edx
  801bb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bbc:	89 34 24             	mov    %esi,(%esp)
  801bbf:	89 c8                	mov    %ecx,%eax
  801bc1:	75 35                	jne    801bf8 <__udivdi3+0x58>
  801bc3:	39 f1                	cmp    %esi,%ecx
  801bc5:	0f 87 bd 00 00 00    	ja     801c88 <__udivdi3+0xe8>
  801bcb:	85 c9                	test   %ecx,%ecx
  801bcd:	89 cd                	mov    %ecx,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f1                	div    %ecx
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 f0                	mov    %esi,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c6                	mov    %eax,%esi
  801be4:	89 f8                	mov    %edi,%eax
  801be6:	f7 f5                	div    %ebp
  801be8:	89 f2                	mov    %esi,%edx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    
  801bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	3b 14 24             	cmp    (%esp),%edx
  801bfb:	77 7b                	ja     801c78 <__udivdi3+0xd8>
  801bfd:	0f bd f2             	bsr    %edx,%esi
  801c00:	83 f6 1f             	xor    $0x1f,%esi
  801c03:	0f 84 97 00 00 00    	je     801ca0 <__udivdi3+0x100>
  801c09:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c0e:	89 d7                	mov    %edx,%edi
  801c10:	89 f1                	mov    %esi,%ecx
  801c12:	29 f5                	sub    %esi,%ebp
  801c14:	d3 e7                	shl    %cl,%edi
  801c16:	89 c2                	mov    %eax,%edx
  801c18:	89 e9                	mov    %ebp,%ecx
  801c1a:	d3 ea                	shr    %cl,%edx
  801c1c:	89 f1                	mov    %esi,%ecx
  801c1e:	09 fa                	or     %edi,%edx
  801c20:	8b 3c 24             	mov    (%esp),%edi
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c29:	89 e9                	mov    %ebp,%ecx
  801c2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c33:	89 fa                	mov    %edi,%edx
  801c35:	d3 ea                	shr    %cl,%edx
  801c37:	89 f1                	mov    %esi,%ecx
  801c39:	d3 e7                	shl    %cl,%edi
  801c3b:	89 e9                	mov    %ebp,%ecx
  801c3d:	d3 e8                	shr    %cl,%eax
  801c3f:	09 c7                	or     %eax,%edi
  801c41:	89 f8                	mov    %edi,%eax
  801c43:	f7 74 24 08          	divl   0x8(%esp)
  801c47:	89 d5                	mov    %edx,%ebp
  801c49:	89 c7                	mov    %eax,%edi
  801c4b:	f7 64 24 0c          	mull   0xc(%esp)
  801c4f:	39 d5                	cmp    %edx,%ebp
  801c51:	89 14 24             	mov    %edx,(%esp)
  801c54:	72 11                	jb     801c67 <__udivdi3+0xc7>
  801c56:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c5a:	89 f1                	mov    %esi,%ecx
  801c5c:	d3 e2                	shl    %cl,%edx
  801c5e:	39 c2                	cmp    %eax,%edx
  801c60:	73 5e                	jae    801cc0 <__udivdi3+0x120>
  801c62:	3b 2c 24             	cmp    (%esp),%ebp
  801c65:	75 59                	jne    801cc0 <__udivdi3+0x120>
  801c67:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c6a:	31 f6                	xor    %esi,%esi
  801c6c:	89 f2                	mov    %esi,%edx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	8d 76 00             	lea    0x0(%esi),%esi
  801c78:	31 f6                	xor    %esi,%esi
  801c7a:	31 c0                	xor    %eax,%eax
  801c7c:	89 f2                	mov    %esi,%edx
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	31 f6                	xor    %esi,%esi
  801c8c:	89 f8                	mov    %edi,%eax
  801c8e:	f7 f1                	div    %ecx
  801c90:	89 f2                	mov    %esi,%edx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ca4:	76 0b                	jbe    801cb1 <__udivdi3+0x111>
  801ca6:	31 c0                	xor    %eax,%eax
  801ca8:	3b 14 24             	cmp    (%esp),%edx
  801cab:	0f 83 37 ff ff ff    	jae    801be8 <__udivdi3+0x48>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	e9 2d ff ff ff       	jmp    801be8 <__udivdi3+0x48>
  801cbb:	90                   	nop
  801cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 f8                	mov    %edi,%eax
  801cc2:	31 f6                	xor    %esi,%esi
  801cc4:	e9 1f ff ff ff       	jmp    801be8 <__udivdi3+0x48>
  801cc9:	66 90                	xchg   %ax,%ax
  801ccb:	66 90                	xchg   %ax,%ax
  801ccd:	66 90                	xchg   %ax,%ax
  801ccf:	90                   	nop

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	83 ec 20             	sub    $0x20,%esp
  801cd6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801cda:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cde:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce2:	89 c6                	mov    %eax,%esi
  801ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ce8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cec:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801cf0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cf4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cf8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	89 c2                	mov    %eax,%edx
  801d00:	75 1e                	jne    801d20 <__umoddi3+0x50>
  801d02:	39 f7                	cmp    %esi,%edi
  801d04:	76 52                	jbe    801d58 <__umoddi3+0x88>
  801d06:	89 c8                	mov    %ecx,%eax
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	f7 f7                	div    %edi
  801d0c:	89 d0                	mov    %edx,%eax
  801d0e:	31 d2                	xor    %edx,%edx
  801d10:	83 c4 20             	add    $0x20,%esp
  801d13:	5e                   	pop    %esi
  801d14:	5f                   	pop    %edi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    
  801d17:	89 f6                	mov    %esi,%esi
  801d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d20:	39 f0                	cmp    %esi,%eax
  801d22:	77 5c                	ja     801d80 <__umoddi3+0xb0>
  801d24:	0f bd e8             	bsr    %eax,%ebp
  801d27:	83 f5 1f             	xor    $0x1f,%ebp
  801d2a:	75 64                	jne    801d90 <__umoddi3+0xc0>
  801d2c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d30:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d34:	0f 86 f6 00 00 00    	jbe    801e30 <__umoddi3+0x160>
  801d3a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d3e:	0f 82 ec 00 00 00    	jb     801e30 <__umoddi3+0x160>
  801d44:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d48:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d4c:	83 c4 20             	add    $0x20,%esp
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    
  801d53:	90                   	nop
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	85 ff                	test   %edi,%edi
  801d5a:	89 fd                	mov    %edi,%ebp
  801d5c:	75 0b                	jne    801d69 <__umoddi3+0x99>
  801d5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f7                	div    %edi
  801d67:	89 c5                	mov    %eax,%ebp
  801d69:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f5                	div    %ebp
  801d71:	89 c8                	mov    %ecx,%eax
  801d73:	f7 f5                	div    %ebp
  801d75:	eb 95                	jmp    801d0c <__umoddi3+0x3c>
  801d77:	89 f6                	mov    %esi,%esi
  801d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 20             	add    $0x20,%esp
  801d87:	5e                   	pop    %esi
  801d88:	5f                   	pop    %edi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    
  801d8b:	90                   	nop
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	b8 20 00 00 00       	mov    $0x20,%eax
  801d95:	89 e9                	mov    %ebp,%ecx
  801d97:	29 e8                	sub    %ebp,%eax
  801d99:	d3 e2                	shl    %cl,%edx
  801d9b:	89 c7                	mov    %eax,%edi
  801d9d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801da1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801da5:	89 f9                	mov    %edi,%ecx
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 c1                	mov    %eax,%ecx
  801dab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801daf:	09 d1                	or     %edx,%ecx
  801db1:	89 fa                	mov    %edi,%edx
  801db3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801db7:	89 e9                	mov    %ebp,%ecx
  801db9:	d3 e0                	shl    %cl,%eax
  801dbb:	89 f9                	mov    %edi,%ecx
  801dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc1:	89 f0                	mov    %esi,%eax
  801dc3:	d3 e8                	shr    %cl,%eax
  801dc5:	89 e9                	mov    %ebp,%ecx
  801dc7:	89 c7                	mov    %eax,%edi
  801dc9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801dcd:	d3 e6                	shl    %cl,%esi
  801dcf:	89 d1                	mov    %edx,%ecx
  801dd1:	89 fa                	mov    %edi,%edx
  801dd3:	d3 e8                	shr    %cl,%eax
  801dd5:	89 e9                	mov    %ebp,%ecx
  801dd7:	09 f0                	or     %esi,%eax
  801dd9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801ddd:	f7 74 24 10          	divl   0x10(%esp)
  801de1:	d3 e6                	shl    %cl,%esi
  801de3:	89 d1                	mov    %edx,%ecx
  801de5:	f7 64 24 0c          	mull   0xc(%esp)
  801de9:	39 d1                	cmp    %edx,%ecx
  801deb:	89 74 24 14          	mov    %esi,0x14(%esp)
  801def:	89 d7                	mov    %edx,%edi
  801df1:	89 c6                	mov    %eax,%esi
  801df3:	72 0a                	jb     801dff <__umoddi3+0x12f>
  801df5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801df9:	73 10                	jae    801e0b <__umoddi3+0x13b>
  801dfb:	39 d1                	cmp    %edx,%ecx
  801dfd:	75 0c                	jne    801e0b <__umoddi3+0x13b>
  801dff:	89 d7                	mov    %edx,%edi
  801e01:	89 c6                	mov    %eax,%esi
  801e03:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e07:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e0b:	89 ca                	mov    %ecx,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e13:	29 f0                	sub    %esi,%eax
  801e15:	19 fa                	sbb    %edi,%edx
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e1e:	89 d7                	mov    %edx,%edi
  801e20:	d3 e7                	shl    %cl,%edi
  801e22:	89 e9                	mov    %ebp,%ecx
  801e24:	09 f8                	or     %edi,%eax
  801e26:	d3 ea                	shr    %cl,%edx
  801e28:	83 c4 20             	add    $0x20,%esp
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    
  801e2f:	90                   	nop
  801e30:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e34:	29 f9                	sub    %edi,%ecx
  801e36:	19 c6                	sbb    %eax,%esi
  801e38:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e3c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e40:	e9 ff fe ff ff       	jmp    801d44 <__umoddi3+0x74>
