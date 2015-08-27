
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
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 80 23 80 00       	push   $0x802380
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 a4 0a 00 00       	call   800afe <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 a0 23 80 00       	push   $0x8023a0
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
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 cc 23 80 00       	push   $0x8023cc
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
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000e6:	e8 96 0e 00 00       	call   800f81 <close_all>
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
  8001f0:	e8 bb 1e 00 00       	call   8020b0 <__udivdi3>
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
  80022e:	e8 ad 1f 00 00       	call   8021e0 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 80 f5 23 80 00 	movsbl 0x8023f5(%eax),%eax
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
  800332:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
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
  8003f6:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8003fd:	85 d2                	test   %edx,%edx
  8003ff:	75 18                	jne    800419 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800401:	50                   	push   %eax
  800402:	68 0d 24 80 00       	push   $0x80240d
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
  80041a:	68 f5 27 80 00       	push   $0x8027f5
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
  800447:	ba 06 24 80 00       	mov    $0x802406,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800ac6:	68 1f 27 80 00       	push   $0x80271f
  800acb:	6a 22                	push   $0x22
  800acd:	68 3c 27 80 00       	push   $0x80273c
  800ad2:	e8 5b 14 00 00       	call   801f32 <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800b47:	68 1f 27 80 00       	push   $0x80271f
  800b4c:	6a 22                	push   $0x22
  800b4e:	68 3c 27 80 00       	push   $0x80273c
  800b53:	e8 da 13 00 00       	call   801f32 <_panic>

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
	// return value.
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
  800b89:	68 1f 27 80 00       	push   $0x80271f
  800b8e:	6a 22                	push   $0x22
  800b90:	68 3c 27 80 00       	push   $0x80273c
  800b95:	e8 98 13 00 00       	call   801f32 <_panic>

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
	// return value.
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
  800bcb:	68 1f 27 80 00       	push   $0x80271f
  800bd0:	6a 22                	push   $0x22
  800bd2:	68 3c 27 80 00       	push   $0x80273c
  800bd7:	e8 56 13 00 00       	call   801f32 <_panic>

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
	// return value.
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
  800c0d:	68 1f 27 80 00       	push   $0x80271f
  800c12:	6a 22                	push   $0x22
  800c14:	68 3c 27 80 00       	push   $0x80273c
  800c19:	e8 14 13 00 00       	call   801f32 <_panic>
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
	// return value.
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
  800c4f:	68 1f 27 80 00       	push   $0x80271f
  800c54:	6a 22                	push   $0x22
  800c56:	68 3c 27 80 00       	push   $0x80273c
  800c5b:	e8 d2 12 00 00       	call   801f32 <_panic>

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
	// return value.
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
  800c91:	68 1f 27 80 00       	push   $0x80271f
  800c96:	6a 22                	push   $0x22
  800c98:	68 3c 27 80 00       	push   $0x80273c
  800c9d:	e8 90 12 00 00       	call   801f32 <_panic>

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
	// return value.
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
	// return value.
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
  800cf5:	68 1f 27 80 00       	push   $0x80271f
  800cfa:	6a 22                	push   $0x22
  800cfc:	68 3c 27 80 00       	push   $0x80273c
  800d01:	e8 2c 12 00 00       	call   801f32 <_panic>

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

00800d0e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d14:	ba 00 00 00 00       	mov    $0x0,%edx
  800d19:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1e:	89 d1                	mov    %edx,%ecx
  800d20:	89 d3                	mov    %edx,%ebx
  800d22:	89 d7                	mov    %edx,%edi
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 cb                	mov    %ecx,%ebx
  800d45:	89 cf                	mov    %ecx,%edi
  800d47:	89 ce                	mov    %ecx,%esi
  800d49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 17                	jle    800d66 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	50                   	push   %eax
  800d53:	6a 0f                	push   $0xf
  800d55:	68 1f 27 80 00       	push   $0x80271f
  800d5a:	6a 22                	push   $0x22
  800d5c:	68 3c 27 80 00       	push   $0x80273c
  800d61:	e8 cc 11 00 00       	call   801f32 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_recv>:

int
sys_recv(void *addr)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 10                	push   $0x10
  800d96:	68 1f 27 80 00       	push   $0x80271f
  800d9b:	6a 22                	push   $0x22
  800d9d:	68 3c 27 80 00       	push   $0x80273c
  800da2:	e8 8b 11 00 00       	call   801f32 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	05 00 00 00 30       	add    $0x30000000,%eax
  800dba:	c1 e8 0c             	shr    $0xc,%eax
}
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc5:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800dca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	c1 ea 16             	shr    $0x16,%edx
  800de6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ded:	f6 c2 01             	test   $0x1,%dl
  800df0:	74 11                	je     800e03 <fd_alloc+0x2d>
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	c1 ea 0c             	shr    $0xc,%edx
  800df7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfe:	f6 c2 01             	test   $0x1,%dl
  800e01:	75 09                	jne    800e0c <fd_alloc+0x36>
			*fd_store = fd;
  800e03:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e05:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0a:	eb 17                	jmp    800e23 <fd_alloc+0x4d>
  800e0c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e11:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e16:	75 c9                	jne    800de1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e18:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e1e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e2b:	83 f8 1f             	cmp    $0x1f,%eax
  800e2e:	77 36                	ja     800e66 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e30:	c1 e0 0c             	shl    $0xc,%eax
  800e33:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e38:	89 c2                	mov    %eax,%edx
  800e3a:	c1 ea 16             	shr    $0x16,%edx
  800e3d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e44:	f6 c2 01             	test   $0x1,%dl
  800e47:	74 24                	je     800e6d <fd_lookup+0x48>
  800e49:	89 c2                	mov    %eax,%edx
  800e4b:	c1 ea 0c             	shr    $0xc,%edx
  800e4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e55:	f6 c2 01             	test   $0x1,%dl
  800e58:	74 1a                	je     800e74 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5d:	89 02                	mov    %eax,(%edx)
	return 0;
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	eb 13                	jmp    800e79 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6b:	eb 0c                	jmp    800e79 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e72:	eb 05                	jmp    800e79 <fd_lookup+0x54>
  800e74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 08             	sub    $0x8,%esp
  800e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	eb 13                	jmp    800e9e <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800e8b:	39 08                	cmp    %ecx,(%eax)
  800e8d:	75 0c                	jne    800e9b <dev_lookup+0x20>
			*dev = devtab[i];
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	eb 36                	jmp    800ed1 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e9b:	83 c2 01             	add    $0x1,%edx
  800e9e:	8b 04 95 c8 27 80 00 	mov    0x8027c8(,%edx,4),%eax
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	75 e2                	jne    800e8b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea9:	a1 08 40 80 00       	mov    0x804008,%eax
  800eae:	8b 40 48             	mov    0x48(%eax),%eax
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	51                   	push   %ecx
  800eb5:	50                   	push   %eax
  800eb6:	68 4c 27 80 00       	push   $0x80274c
  800ebb:	e8 cd f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    

00800ed3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 10             	sub    $0x10,%esp
  800edb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ede:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee4:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eeb:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eee:	50                   	push   %eax
  800eef:	e8 31 ff ff ff       	call   800e25 <fd_lookup>
  800ef4:	83 c4 08             	add    $0x8,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 05                	js     800f00 <fd_close+0x2d>
	    || fd != fd2)
  800efb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800efe:	74 0c                	je     800f0c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f00:	84 db                	test   %bl,%bl
  800f02:	ba 00 00 00 00       	mov    $0x0,%edx
  800f07:	0f 44 c2             	cmove  %edx,%eax
  800f0a:	eb 41                	jmp    800f4d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f0c:	83 ec 08             	sub    $0x8,%esp
  800f0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	ff 36                	pushl  (%esi)
  800f15:	e8 61 ff ff ff       	call   800e7b <dev_lookup>
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	78 1a                	js     800f3d <fd_close+0x6a>
		if (dev->dev_close)
  800f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f26:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	74 0b                	je     800f3d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	56                   	push   %esi
  800f36:	ff d0                	call   *%eax
  800f38:	89 c3                	mov    %eax,%ebx
  800f3a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	56                   	push   %esi
  800f41:	6a 00                	push   $0x0
  800f43:	e8 5a fc ff ff       	call   800ba2 <sys_page_unmap>
	return r;
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	89 d8                	mov    %ebx,%eax
}
  800f4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5d:	50                   	push   %eax
  800f5e:	ff 75 08             	pushl  0x8(%ebp)
  800f61:	e8 bf fe ff ff       	call   800e25 <fd_lookup>
  800f66:	89 c2                	mov    %eax,%edx
  800f68:	83 c4 08             	add    $0x8,%esp
  800f6b:	85 d2                	test   %edx,%edx
  800f6d:	78 10                	js     800f7f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	6a 01                	push   $0x1
  800f74:	ff 75 f4             	pushl  -0xc(%ebp)
  800f77:	e8 57 ff ff ff       	call   800ed3 <fd_close>
  800f7c:	83 c4 10             	add    $0x10,%esp
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <close_all>:

void
close_all(void)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	53                   	push   %ebx
  800f85:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f88:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	53                   	push   %ebx
  800f91:	e8 be ff ff ff       	call   800f54 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f96:	83 c3 01             	add    $0x1,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	83 fb 20             	cmp    $0x20,%ebx
  800f9f:	75 ec                	jne    800f8d <close_all+0xc>
		close(i);
}
  800fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 2c             	sub    $0x2c,%esp
  800faf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fb2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	ff 75 08             	pushl  0x8(%ebp)
  800fb9:	e8 67 fe ff ff       	call   800e25 <fd_lookup>
  800fbe:	89 c2                	mov    %eax,%edx
  800fc0:	83 c4 08             	add    $0x8,%esp
  800fc3:	85 d2                	test   %edx,%edx
  800fc5:	0f 88 c1 00 00 00    	js     80108c <dup+0xe6>
		return r;
	close(newfdnum);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	56                   	push   %esi
  800fcf:	e8 80 ff ff ff       	call   800f54 <close>

	newfd = INDEX2FD(newfdnum);
  800fd4:	89 f3                	mov    %esi,%ebx
  800fd6:	c1 e3 0c             	shl    $0xc,%ebx
  800fd9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fdf:	83 c4 04             	add    $0x4,%esp
  800fe2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe5:	e8 d5 fd ff ff       	call   800dbf <fd2data>
  800fea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fec:	89 1c 24             	mov    %ebx,(%esp)
  800fef:	e8 cb fd ff ff       	call   800dbf <fd2data>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ffa:	89 f8                	mov    %edi,%eax
  800ffc:	c1 e8 16             	shr    $0x16,%eax
  800fff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801006:	a8 01                	test   $0x1,%al
  801008:	74 37                	je     801041 <dup+0x9b>
  80100a:	89 f8                	mov    %edi,%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
  80100f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801016:	f6 c2 01             	test   $0x1,%dl
  801019:	74 26                	je     801041 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80101b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	25 07 0e 00 00       	and    $0xe07,%eax
  80102a:	50                   	push   %eax
  80102b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102e:	6a 00                	push   $0x0
  801030:	57                   	push   %edi
  801031:	6a 00                	push   $0x0
  801033:	e8 28 fb ff ff       	call   800b60 <sys_page_map>
  801038:	89 c7                	mov    %eax,%edi
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 2e                	js     80106f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801041:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801044:	89 d0                	mov    %edx,%eax
  801046:	c1 e8 0c             	shr    $0xc,%eax
  801049:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	25 07 0e 00 00       	and    $0xe07,%eax
  801058:	50                   	push   %eax
  801059:	53                   	push   %ebx
  80105a:	6a 00                	push   $0x0
  80105c:	52                   	push   %edx
  80105d:	6a 00                	push   $0x0
  80105f:	e8 fc fa ff ff       	call   800b60 <sys_page_map>
  801064:	89 c7                	mov    %eax,%edi
  801066:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801069:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106b:	85 ff                	test   %edi,%edi
  80106d:	79 1d                	jns    80108c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	53                   	push   %ebx
  801073:	6a 00                	push   $0x0
  801075:	e8 28 fb ff ff       	call   800ba2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80107a:	83 c4 08             	add    $0x8,%esp
  80107d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801080:	6a 00                	push   $0x0
  801082:	e8 1b fb ff ff       	call   800ba2 <sys_page_unmap>
	return r;
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	89 f8                	mov    %edi,%eax
}
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 14             	sub    $0x14,%esp
  80109b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	53                   	push   %ebx
  8010a3:	e8 7d fd ff ff       	call   800e25 <fd_lookup>
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 6d                	js     80111e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b7:	50                   	push   %eax
  8010b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bb:	ff 30                	pushl  (%eax)
  8010bd:	e8 b9 fd ff ff       	call   800e7b <dev_lookup>
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 4c                	js     801115 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010cc:	8b 42 08             	mov    0x8(%edx),%eax
  8010cf:	83 e0 03             	and    $0x3,%eax
  8010d2:	83 f8 01             	cmp    $0x1,%eax
  8010d5:	75 21                	jne    8010f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010dc:	8b 40 48             	mov    0x48(%eax),%eax
  8010df:	83 ec 04             	sub    $0x4,%esp
  8010e2:	53                   	push   %ebx
  8010e3:	50                   	push   %eax
  8010e4:	68 8d 27 80 00       	push   $0x80278d
  8010e9:	e8 9f f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010f6:	eb 26                	jmp    80111e <read+0x8a>
	}
	if (!dev->dev_read)
  8010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fb:	8b 40 08             	mov    0x8(%eax),%eax
  8010fe:	85 c0                	test   %eax,%eax
  801100:	74 17                	je     801119 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801102:	83 ec 04             	sub    $0x4,%esp
  801105:	ff 75 10             	pushl  0x10(%ebp)
  801108:	ff 75 0c             	pushl  0xc(%ebp)
  80110b:	52                   	push   %edx
  80110c:	ff d0                	call   *%eax
  80110e:	89 c2                	mov    %eax,%edx
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	eb 09                	jmp    80111e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801115:	89 c2                	mov    %eax,%edx
  801117:	eb 05                	jmp    80111e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801119:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80111e:	89 d0                	mov    %edx,%eax
  801120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801131:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801134:	bb 00 00 00 00       	mov    $0x0,%ebx
  801139:	eb 21                	jmp    80115c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80113b:	83 ec 04             	sub    $0x4,%esp
  80113e:	89 f0                	mov    %esi,%eax
  801140:	29 d8                	sub    %ebx,%eax
  801142:	50                   	push   %eax
  801143:	89 d8                	mov    %ebx,%eax
  801145:	03 45 0c             	add    0xc(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	57                   	push   %edi
  80114a:	e8 45 ff ff ff       	call   801094 <read>
		if (m < 0)
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 0c                	js     801162 <readn+0x3d>
			return m;
		if (m == 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	74 06                	je     801160 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80115a:	01 c3                	add    %eax,%ebx
  80115c:	39 f3                	cmp    %esi,%ebx
  80115e:	72 db                	jb     80113b <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801160:	89 d8                	mov    %ebx,%eax
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	53                   	push   %ebx
  80116e:	83 ec 14             	sub    $0x14,%esp
  801171:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801174:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801177:	50                   	push   %eax
  801178:	53                   	push   %ebx
  801179:	e8 a7 fc ff ff       	call   800e25 <fd_lookup>
  80117e:	83 c4 08             	add    $0x8,%esp
  801181:	89 c2                	mov    %eax,%edx
  801183:	85 c0                	test   %eax,%eax
  801185:	78 68                	js     8011ef <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801191:	ff 30                	pushl  (%eax)
  801193:	e8 e3 fc ff ff       	call   800e7b <dev_lookup>
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 47                	js     8011e6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a6:	75 21                	jne    8011c9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ad:	8b 40 48             	mov    0x48(%eax),%eax
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	53                   	push   %ebx
  8011b4:	50                   	push   %eax
  8011b5:	68 a9 27 80 00       	push   $0x8027a9
  8011ba:	e8 ce ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c7:	eb 26                	jmp    8011ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8011cf:	85 d2                	test   %edx,%edx
  8011d1:	74 17                	je     8011ea <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	ff 75 10             	pushl  0x10(%ebp)
  8011d9:	ff 75 0c             	pushl  0xc(%ebp)
  8011dc:	50                   	push   %eax
  8011dd:	ff d2                	call   *%edx
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	eb 09                	jmp    8011ef <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	eb 05                	jmp    8011ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 1d fc ff ff       	call   800e25 <fd_lookup>
  801208:	83 c4 08             	add    $0x8,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 0e                	js     80121d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80120f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801212:	8b 55 0c             	mov    0xc(%ebp),%edx
  801215:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	83 ec 14             	sub    $0x14,%esp
  801226:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801229:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	53                   	push   %ebx
  80122e:	e8 f2 fb ff ff       	call   800e25 <fd_lookup>
  801233:	83 c4 08             	add    $0x8,%esp
  801236:	89 c2                	mov    %eax,%edx
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 65                	js     8012a1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801246:	ff 30                	pushl  (%eax)
  801248:	e8 2e fc ff ff       	call   800e7b <dev_lookup>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 44                	js     801298 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801254:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801257:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80125b:	75 21                	jne    80127e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80125d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801262:	8b 40 48             	mov    0x48(%eax),%eax
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	53                   	push   %ebx
  801269:	50                   	push   %eax
  80126a:	68 6c 27 80 00       	push   $0x80276c
  80126f:	e8 19 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80127c:	eb 23                	jmp    8012a1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80127e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801281:	8b 52 18             	mov    0x18(%edx),%edx
  801284:	85 d2                	test   %edx,%edx
  801286:	74 14                	je     80129c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	ff 75 0c             	pushl  0xc(%ebp)
  80128e:	50                   	push   %eax
  80128f:	ff d2                	call   *%edx
  801291:	89 c2                	mov    %eax,%edx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb 09                	jmp    8012a1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801298:	89 c2                	mov    %eax,%edx
  80129a:	eb 05                	jmp    8012a1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80129c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012a1:	89 d0                	mov    %edx,%eax
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 14             	sub    $0x14,%esp
  8012af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b5:	50                   	push   %eax
  8012b6:	ff 75 08             	pushl  0x8(%ebp)
  8012b9:	e8 67 fb ff ff       	call   800e25 <fd_lookup>
  8012be:	83 c4 08             	add    $0x8,%esp
  8012c1:	89 c2                	mov    %eax,%edx
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 58                	js     80131f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d1:	ff 30                	pushl  (%eax)
  8012d3:	e8 a3 fb ff ff       	call   800e7b <dev_lookup>
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 37                	js     801316 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012e6:	74 32                	je     80131a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f2:	00 00 00 
	stat->st_isdir = 0;
  8012f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012fc:	00 00 00 
	stat->st_dev = dev;
  8012ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	53                   	push   %ebx
  801309:	ff 75 f0             	pushl  -0x10(%ebp)
  80130c:	ff 50 14             	call   *0x14(%eax)
  80130f:	89 c2                	mov    %eax,%edx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	eb 09                	jmp    80131f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	89 c2                	mov    %eax,%edx
  801318:	eb 05                	jmp    80131f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80131a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80131f:	89 d0                	mov    %edx,%eax
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	6a 00                	push   $0x0
  801330:	ff 75 08             	pushl  0x8(%ebp)
  801333:	e8 09 02 00 00       	call   801541 <open>
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 db                	test   %ebx,%ebx
  80133f:	78 1b                	js     80135c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	ff 75 0c             	pushl  0xc(%ebp)
  801347:	53                   	push   %ebx
  801348:	e8 5b ff ff ff       	call   8012a8 <fstat>
  80134d:	89 c6                	mov    %eax,%esi
	close(fd);
  80134f:	89 1c 24             	mov    %ebx,(%esp)
  801352:	e8 fd fb ff ff       	call   800f54 <close>
	return r;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	89 f0                	mov    %esi,%eax
}
  80135c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	89 c6                	mov    %eax,%esi
  80136a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80136c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801373:	75 12                	jne    801387 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801375:	83 ec 0c             	sub    $0xc,%esp
  801378:	6a 01                	push   $0x1
  80137a:	e8 b6 0c 00 00       	call   802035 <ipc_find_env>
  80137f:	a3 00 40 80 00       	mov    %eax,0x804000
  801384:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801387:	6a 07                	push   $0x7
  801389:	68 00 50 80 00       	push   $0x805000
  80138e:	56                   	push   %esi
  80138f:	ff 35 00 40 80 00    	pushl  0x804000
  801395:	e8 47 0c 00 00       	call   801fe1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80139a:	83 c4 0c             	add    $0xc,%esp
  80139d:	6a 00                	push   $0x0
  80139f:	53                   	push   %ebx
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 d1 0b 00 00       	call   801f78 <ipc_recv>
}
  8013a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8013d1:	e8 8d ff ff ff       	call   801363 <fsipc>
}
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f3:	e8 6b ff ff ff       	call   801363 <fsipc>
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	8b 40 0c             	mov    0xc(%eax),%eax
  80140a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80140f:	ba 00 00 00 00       	mov    $0x0,%edx
  801414:	b8 05 00 00 00       	mov    $0x5,%eax
  801419:	e8 45 ff ff ff       	call   801363 <fsipc>
  80141e:	89 c2                	mov    %eax,%edx
  801420:	85 d2                	test   %edx,%edx
  801422:	78 2c                	js     801450 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	68 00 50 80 00       	push   $0x805000
  80142c:	53                   	push   %ebx
  80142d:	e8 e2 f2 ff ff       	call   800714 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801432:	a1 80 50 80 00       	mov    0x805080,%eax
  801437:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80143d:	a1 84 50 80 00       	mov    0x805084,%eax
  801442:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	57                   	push   %edi
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
  801464:	8b 40 0c             	mov    0xc(%eax),%eax
  801467:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80146c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80146f:	eb 3d                	jmp    8014ae <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801471:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801477:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80147c:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	57                   	push   %edi
  801483:	53                   	push   %ebx
  801484:	68 08 50 80 00       	push   $0x805008
  801489:	e8 18 f4 ff ff       	call   8008a6 <memmove>
                fsipcbuf.write.req_n = tmp; 
  80148e:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 04 00 00 00       	mov    $0x4,%eax
  80149e:	e8 c0 fe ff ff       	call   801363 <fsipc>
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 0d                	js     8014b7 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8014aa:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8014ac:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014ae:	85 f6                	test   %esi,%esi
  8014b0:	75 bf                	jne    801471 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8014b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014d2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e2:	e8 7c fe ff ff       	call   801363 <fsipc>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 4b                	js     801538 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014ed:	39 c6                	cmp    %eax,%esi
  8014ef:	73 16                	jae    801507 <devfile_read+0x48>
  8014f1:	68 dc 27 80 00       	push   $0x8027dc
  8014f6:	68 e3 27 80 00       	push   $0x8027e3
  8014fb:	6a 7c                	push   $0x7c
  8014fd:	68 f8 27 80 00       	push   $0x8027f8
  801502:	e8 2b 0a 00 00       	call   801f32 <_panic>
	assert(r <= PGSIZE);
  801507:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150c:	7e 16                	jle    801524 <devfile_read+0x65>
  80150e:	68 03 28 80 00       	push   $0x802803
  801513:	68 e3 27 80 00       	push   $0x8027e3
  801518:	6a 7d                	push   $0x7d
  80151a:	68 f8 27 80 00       	push   $0x8027f8
  80151f:	e8 0e 0a 00 00       	call   801f32 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	50                   	push   %eax
  801528:	68 00 50 80 00       	push   $0x805000
  80152d:	ff 75 0c             	pushl  0xc(%ebp)
  801530:	e8 71 f3 ff ff       	call   8008a6 <memmove>
	return r;
  801535:	83 c4 10             	add    $0x10,%esp
}
  801538:	89 d8                	mov    %ebx,%eax
  80153a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153d:	5b                   	pop    %ebx
  80153e:	5e                   	pop    %esi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 20             	sub    $0x20,%esp
  801548:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80154b:	53                   	push   %ebx
  80154c:	e8 8a f1 ff ff       	call   8006db <strlen>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801559:	7f 67                	jg     8015c2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155b:	83 ec 0c             	sub    $0xc,%esp
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	e8 6f f8 ff ff       	call   800dd6 <fd_alloc>
  801567:	83 c4 10             	add    $0x10,%esp
		return r;
  80156a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 57                	js     8015c7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	68 00 50 80 00       	push   $0x805000
  801579:	e8 96 f1 ff ff       	call   800714 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801581:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801586:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801589:	b8 01 00 00 00       	mov    $0x1,%eax
  80158e:	e8 d0 fd ff ff       	call   801363 <fsipc>
  801593:	89 c3                	mov    %eax,%ebx
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	79 14                	jns    8015b0 <open+0x6f>
		fd_close(fd, 0);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	6a 00                	push   $0x0
  8015a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a4:	e8 2a f9 ff ff       	call   800ed3 <fd_close>
		return r;
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	89 da                	mov    %ebx,%edx
  8015ae:	eb 17                	jmp    8015c7 <open+0x86>
	}

	return fd2num(fd);
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b6:	e8 f4 f7 ff ff       	call   800daf <fd2num>
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	eb 05                	jmp    8015c7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015c2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8015de:	e8 80 fd ff ff       	call   801363 <fsipc>
}
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    

008015e5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015eb:	68 0f 28 80 00       	push   $0x80280f
  8015f0:	ff 75 0c             	pushl  0xc(%ebp)
  8015f3:	e8 1c f1 ff ff       	call   800714 <strcpy>
	return 0;
}
  8015f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 10             	sub    $0x10,%esp
  801606:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801609:	53                   	push   %ebx
  80160a:	e8 5e 0a 00 00       	call   80206d <pageref>
  80160f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801612:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801617:	83 f8 01             	cmp    $0x1,%eax
  80161a:	75 10                	jne    80162c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	ff 73 0c             	pushl  0xc(%ebx)
  801622:	e8 ca 02 00 00       	call   8018f1 <nsipc_close>
  801627:	89 c2                	mov    %eax,%edx
  801629:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80162c:	89 d0                	mov    %edx,%eax
  80162e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801639:	6a 00                	push   $0x0
  80163b:	ff 75 10             	pushl  0x10(%ebp)
  80163e:	ff 75 0c             	pushl  0xc(%ebp)
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	ff 70 0c             	pushl  0xc(%eax)
  801647:	e8 82 03 00 00       	call   8019ce <nsipc_send>
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801654:	6a 00                	push   $0x0
  801656:	ff 75 10             	pushl  0x10(%ebp)
  801659:	ff 75 0c             	pushl  0xc(%ebp)
  80165c:	8b 45 08             	mov    0x8(%ebp),%eax
  80165f:	ff 70 0c             	pushl  0xc(%eax)
  801662:	e8 fb 02 00 00       	call   801962 <nsipc_recv>
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80166f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801672:	52                   	push   %edx
  801673:	50                   	push   %eax
  801674:	e8 ac f7 ff ff       	call   800e25 <fd_lookup>
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 17                	js     801697 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801689:	39 08                	cmp    %ecx,(%eax)
  80168b:	75 05                	jne    801692 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80168d:	8b 40 0c             	mov    0xc(%eax),%eax
  801690:	eb 05                	jmp    801697 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801692:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	56                   	push   %esi
  80169d:	53                   	push   %ebx
  80169e:	83 ec 1c             	sub    $0x1c,%esp
  8016a1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	e8 2a f7 ff ff       	call   800dd6 <fd_alloc>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 1b                	js     8016d0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016b5:	83 ec 04             	sub    $0x4,%esp
  8016b8:	68 07 04 00 00       	push   $0x407
  8016bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c0:	6a 00                	push   $0x0
  8016c2:	e8 56 f4 ff ff       	call   800b1d <sys_page_alloc>
  8016c7:	89 c3                	mov    %eax,%ebx
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	79 10                	jns    8016e0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016d0:	83 ec 0c             	sub    $0xc,%esp
  8016d3:	56                   	push   %esi
  8016d4:	e8 18 02 00 00       	call   8018f1 <nsipc_close>
		return r;
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	89 d8                	mov    %ebx,%eax
  8016de:	eb 24                	jmp    801704 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016e0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ee:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8016f5:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	52                   	push   %edx
  8016fc:	e8 ae f6 ff ff       	call   800daf <fd2num>
  801701:	83 c4 10             	add    $0x10,%esp
}
  801704:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801711:	8b 45 08             	mov    0x8(%ebp),%eax
  801714:	e8 50 ff ff ff       	call   801669 <fd2sockid>
		return r;
  801719:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 1f                	js     80173e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80171f:	83 ec 04             	sub    $0x4,%esp
  801722:	ff 75 10             	pushl  0x10(%ebp)
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	50                   	push   %eax
  801729:	e8 1c 01 00 00       	call   80184a <nsipc_accept>
  80172e:	83 c4 10             	add    $0x10,%esp
		return r;
  801731:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801733:	85 c0                	test   %eax,%eax
  801735:	78 07                	js     80173e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801737:	e8 5d ff ff ff       	call   801699 <alloc_sockfd>
  80173c:	89 c1                	mov    %eax,%ecx
}
  80173e:	89 c8                	mov    %ecx,%eax
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	e8 19 ff ff ff       	call   801669 <fd2sockid>
  801750:	89 c2                	mov    %eax,%edx
  801752:	85 d2                	test   %edx,%edx
  801754:	78 12                	js     801768 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801756:	83 ec 04             	sub    $0x4,%esp
  801759:	ff 75 10             	pushl  0x10(%ebp)
  80175c:	ff 75 0c             	pushl  0xc(%ebp)
  80175f:	52                   	push   %edx
  801760:	e8 35 01 00 00       	call   80189a <nsipc_bind>
  801765:	83 c4 10             	add    $0x10,%esp
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <shutdown>:

int
shutdown(int s, int how)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	e8 f1 fe ff ff       	call   801669 <fd2sockid>
  801778:	89 c2                	mov    %eax,%edx
  80177a:	85 d2                	test   %edx,%edx
  80177c:	78 0f                	js     80178d <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  80177e:	83 ec 08             	sub    $0x8,%esp
  801781:	ff 75 0c             	pushl  0xc(%ebp)
  801784:	52                   	push   %edx
  801785:	e8 45 01 00 00       	call   8018cf <nsipc_shutdown>
  80178a:	83 c4 10             	add    $0x10,%esp
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	e8 cc fe ff ff       	call   801669 <fd2sockid>
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	85 d2                	test   %edx,%edx
  8017a1:	78 12                	js     8017b5 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  8017a3:	83 ec 04             	sub    $0x4,%esp
  8017a6:	ff 75 10             	pushl  0x10(%ebp)
  8017a9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ac:	52                   	push   %edx
  8017ad:	e8 59 01 00 00       	call   80190b <nsipc_connect>
  8017b2:	83 c4 10             	add    $0x10,%esp
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <listen>:

int
listen(int s, int backlog)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	e8 a4 fe ff ff       	call   801669 <fd2sockid>
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	85 d2                	test   %edx,%edx
  8017c9:	78 0f                	js     8017da <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	ff 75 0c             	pushl  0xc(%ebp)
  8017d1:	52                   	push   %edx
  8017d2:	e8 69 01 00 00       	call   801940 <nsipc_listen>
  8017d7:	83 c4 10             	add    $0x10,%esp
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017e2:	ff 75 10             	pushl  0x10(%ebp)
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	ff 75 08             	pushl  0x8(%ebp)
  8017eb:	e8 3c 02 00 00       	call   801a2c <nsipc_socket>
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	85 d2                	test   %edx,%edx
  8017f7:	78 05                	js     8017fe <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8017f9:	e8 9b fe ff ff       	call   801699 <alloc_sockfd>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801809:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801810:	75 12                	jne    801824 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	6a 02                	push   $0x2
  801817:	e8 19 08 00 00       	call   802035 <ipc_find_env>
  80181c:	a3 04 40 80 00       	mov    %eax,0x804004
  801821:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801824:	6a 07                	push   $0x7
  801826:	68 00 60 80 00       	push   $0x806000
  80182b:	53                   	push   %ebx
  80182c:	ff 35 04 40 80 00    	pushl  0x804004
  801832:	e8 aa 07 00 00       	call   801fe1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801837:	83 c4 0c             	add    $0xc,%esp
  80183a:	6a 00                	push   $0x0
  80183c:	6a 00                	push   $0x0
  80183e:	6a 00                	push   $0x0
  801840:	e8 33 07 00 00       	call   801f78 <ipc_recv>
}
  801845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80185a:	8b 06                	mov    (%esi),%eax
  80185c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801861:	b8 01 00 00 00       	mov    $0x1,%eax
  801866:	e8 95 ff ff ff       	call   801800 <nsipc>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 20                	js     801891 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	ff 35 10 60 80 00    	pushl  0x806010
  80187a:	68 00 60 80 00       	push   $0x806000
  80187f:	ff 75 0c             	pushl  0xc(%ebp)
  801882:	e8 1f f0 ff ff       	call   8008a6 <memmove>
		*addrlen = ret->ret_addrlen;
  801887:	a1 10 60 80 00       	mov    0x806010,%eax
  80188c:	89 06                	mov    %eax,(%esi)
  80188e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801891:	89 d8                	mov    %ebx,%eax
  801893:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    

0080189a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 08             	sub    $0x8,%esp
  8018a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018ac:	53                   	push   %ebx
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	68 04 60 80 00       	push   $0x806004
  8018b5:	e8 ec ef ff ff       	call   8008a6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018ba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c5:	e8 36 ff ff ff       	call   801800 <nsipc>
}
  8018ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ea:	e8 11 ff ff ff       	call   801800 <nsipc>
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <nsipc_close>:

int
nsipc_close(int s)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801904:	e8 f7 fe ff ff       	call   801800 <nsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80191d:	53                   	push   %ebx
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	68 04 60 80 00       	push   $0x806004
  801926:	e8 7b ef ff ff       	call   8008a6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80192b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801931:	b8 05 00 00 00       	mov    $0x5,%eax
  801936:	e8 c5 fe ff ff       	call   801800 <nsipc>
}
  80193b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801956:	b8 06 00 00 00       	mov    $0x6,%eax
  80195b:	e8 a0 fe ff ff       	call   801800 <nsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801972:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801978:	8b 45 14             	mov    0x14(%ebp),%eax
  80197b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801980:	b8 07 00 00 00       	mov    $0x7,%eax
  801985:	e8 76 fe ff ff       	call   801800 <nsipc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 35                	js     8019c5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801990:	39 f0                	cmp    %esi,%eax
  801992:	7f 07                	jg     80199b <nsipc_recv+0x39>
  801994:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801999:	7e 16                	jle    8019b1 <nsipc_recv+0x4f>
  80199b:	68 1b 28 80 00       	push   $0x80281b
  8019a0:	68 e3 27 80 00       	push   $0x8027e3
  8019a5:	6a 62                	push   $0x62
  8019a7:	68 30 28 80 00       	push   $0x802830
  8019ac:	e8 81 05 00 00       	call   801f32 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019b1:	83 ec 04             	sub    $0x4,%esp
  8019b4:	50                   	push   %eax
  8019b5:	68 00 60 80 00       	push   $0x806000
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	e8 e4 ee ff ff       	call   8008a6 <memmove>
  8019c2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019c5:	89 d8                	mov    %ebx,%eax
  8019c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 04             	sub    $0x4,%esp
  8019d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019db:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019e0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019e6:	7e 16                	jle    8019fe <nsipc_send+0x30>
  8019e8:	68 3c 28 80 00       	push   $0x80283c
  8019ed:	68 e3 27 80 00       	push   $0x8027e3
  8019f2:	6a 6d                	push   $0x6d
  8019f4:	68 30 28 80 00       	push   $0x802830
  8019f9:	e8 34 05 00 00       	call   801f32 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019fe:	83 ec 04             	sub    $0x4,%esp
  801a01:	53                   	push   %ebx
  801a02:	ff 75 0c             	pushl  0xc(%ebp)
  801a05:	68 0c 60 80 00       	push   $0x80600c
  801a0a:	e8 97 ee ff ff       	call   8008a6 <memmove>
	nsipcbuf.send.req_size = size;
  801a0f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a15:	8b 45 14             	mov    0x14(%ebp),%eax
  801a18:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a1d:	b8 08 00 00 00       	mov    $0x8,%eax
  801a22:	e8 d9 fd ff ff       	call   801800 <nsipc>
}
  801a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a42:	8b 45 10             	mov    0x10(%ebp),%eax
  801a45:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a4a:	b8 09 00 00 00       	mov    $0x9,%eax
  801a4f:	e8 ac fd ff ff       	call   801800 <nsipc>
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	ff 75 08             	pushl  0x8(%ebp)
  801a64:	e8 56 f3 ff ff       	call   800dbf <fd2data>
  801a69:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a6b:	83 c4 08             	add    $0x8,%esp
  801a6e:	68 48 28 80 00       	push   $0x802848
  801a73:	53                   	push   %ebx
  801a74:	e8 9b ec ff ff       	call   800714 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a79:	8b 56 04             	mov    0x4(%esi),%edx
  801a7c:	89 d0                	mov    %edx,%eax
  801a7e:	2b 06                	sub    (%esi),%eax
  801a80:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a86:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a8d:	00 00 00 
	stat->st_dev = &devpipe;
  801a90:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a97:	30 80 00 
	return 0;
}
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa2:	5b                   	pop    %ebx
  801aa3:	5e                   	pop    %esi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab0:	53                   	push   %ebx
  801ab1:	6a 00                	push   $0x0
  801ab3:	e8 ea f0 ff ff       	call   800ba2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ab8:	89 1c 24             	mov    %ebx,(%esp)
  801abb:	e8 ff f2 ff ff       	call   800dbf <fd2data>
  801ac0:	83 c4 08             	add    $0x8,%esp
  801ac3:	50                   	push   %eax
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 d7 f0 ff ff       	call   800ba2 <sys_page_unmap>
}
  801acb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 1c             	sub    $0x1c,%esp
  801ad9:	89 c6                	mov    %eax,%esi
  801adb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ade:	a1 08 40 80 00       	mov    0x804008,%eax
  801ae3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	56                   	push   %esi
  801aea:	e8 7e 05 00 00       	call   80206d <pageref>
  801aef:	89 c7                	mov    %eax,%edi
  801af1:	83 c4 04             	add    $0x4,%esp
  801af4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af7:	e8 71 05 00 00       	call   80206d <pageref>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	39 c7                	cmp    %eax,%edi
  801b01:	0f 94 c2             	sete   %dl
  801b04:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801b07:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801b0d:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801b10:	39 fb                	cmp    %edi,%ebx
  801b12:	74 19                	je     801b2d <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801b14:	84 d2                	test   %dl,%dl
  801b16:	74 c6                	je     801ade <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b18:	8b 51 58             	mov    0x58(%ecx),%edx
  801b1b:	50                   	push   %eax
  801b1c:	52                   	push   %edx
  801b1d:	53                   	push   %ebx
  801b1e:	68 4f 28 80 00       	push   $0x80284f
  801b23:	e8 65 e6 ff ff       	call   80018d <cprintf>
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	eb b1                	jmp    801ade <_pipeisclosed+0xe>
	}
}
  801b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5f                   	pop    %edi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	57                   	push   %edi
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 28             	sub    $0x28,%esp
  801b3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b41:	56                   	push   %esi
  801b42:	e8 78 f2 ff ff       	call   800dbf <fd2data>
  801b47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b51:	eb 4b                	jmp    801b9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b53:	89 da                	mov    %ebx,%edx
  801b55:	89 f0                	mov    %esi,%eax
  801b57:	e8 74 ff ff ff       	call   801ad0 <_pipeisclosed>
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	75 48                	jne    801ba8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b60:	e8 99 ef ff ff       	call   800afe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b65:	8b 43 04             	mov    0x4(%ebx),%eax
  801b68:	8b 0b                	mov    (%ebx),%ecx
  801b6a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b6d:	39 d0                	cmp    %edx,%eax
  801b6f:	73 e2                	jae    801b53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b7b:	89 c2                	mov    %eax,%edx
  801b7d:	c1 fa 1f             	sar    $0x1f,%edx
  801b80:	89 d1                	mov    %edx,%ecx
  801b82:	c1 e9 1b             	shr    $0x1b,%ecx
  801b85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b88:	83 e2 1f             	and    $0x1f,%edx
  801b8b:	29 ca                	sub    %ecx,%edx
  801b8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b95:	83 c0 01             	add    $0x1,%eax
  801b98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9b:	83 c7 01             	add    $0x1,%edi
  801b9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba1:	75 c2                	jne    801b65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba6:	eb 05                	jmp    801bad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	57                   	push   %edi
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 18             	sub    $0x18,%esp
  801bbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bc1:	57                   	push   %edi
  801bc2:	e8 f8 f1 ff ff       	call   800dbf <fd2data>
  801bc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd1:	eb 3d                	jmp    801c10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd3:	85 db                	test   %ebx,%ebx
  801bd5:	74 04                	je     801bdb <devpipe_read+0x26>
				return i;
  801bd7:	89 d8                	mov    %ebx,%eax
  801bd9:	eb 44                	jmp    801c1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bdb:	89 f2                	mov    %esi,%edx
  801bdd:	89 f8                	mov    %edi,%eax
  801bdf:	e8 ec fe ff ff       	call   801ad0 <_pipeisclosed>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	75 32                	jne    801c1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801be8:	e8 11 ef ff ff       	call   800afe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bed:	8b 06                	mov    (%esi),%eax
  801bef:	3b 46 04             	cmp    0x4(%esi),%eax
  801bf2:	74 df                	je     801bd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf4:	99                   	cltd   
  801bf5:	c1 ea 1b             	shr    $0x1b,%edx
  801bf8:	01 d0                	add    %edx,%eax
  801bfa:	83 e0 1f             	and    $0x1f,%eax
  801bfd:	29 d0                	sub    %edx,%eax
  801bff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0d:	83 c3 01             	add    $0x1,%ebx
  801c10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c13:	75 d8                	jne    801bed <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c15:	8b 45 10             	mov    0x10(%ebp),%eax
  801c18:	eb 05                	jmp    801c1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5e                   	pop    %esi
  801c24:	5f                   	pop    %edi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c32:	50                   	push   %eax
  801c33:	e8 9e f1 ff ff       	call   800dd6 <fd_alloc>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	89 c2                	mov    %eax,%edx
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	0f 88 2c 01 00 00    	js     801d71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c45:	83 ec 04             	sub    $0x4,%esp
  801c48:	68 07 04 00 00       	push   $0x407
  801c4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c50:	6a 00                	push   $0x0
  801c52:	e8 c6 ee ff ff       	call   800b1d <sys_page_alloc>
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	0f 88 0d 01 00 00    	js     801d71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c64:	83 ec 0c             	sub    $0xc,%esp
  801c67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	e8 66 f1 ff ff       	call   800dd6 <fd_alloc>
  801c70:	89 c3                	mov    %eax,%ebx
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	0f 88 e2 00 00 00    	js     801d5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7d:	83 ec 04             	sub    $0x4,%esp
  801c80:	68 07 04 00 00       	push   $0x407
  801c85:	ff 75 f0             	pushl  -0x10(%ebp)
  801c88:	6a 00                	push   $0x0
  801c8a:	e8 8e ee ff ff       	call   800b1d <sys_page_alloc>
  801c8f:	89 c3                	mov    %eax,%ebx
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	0f 88 c3 00 00 00    	js     801d5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	e8 18 f1 ff ff       	call   800dbf <fd2data>
  801ca7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca9:	83 c4 0c             	add    $0xc,%esp
  801cac:	68 07 04 00 00       	push   $0x407
  801cb1:	50                   	push   %eax
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 64 ee ff ff       	call   800b1d <sys_page_alloc>
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	0f 88 89 00 00 00    	js     801d4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccc:	e8 ee f0 ff ff       	call   800dbf <fd2data>
  801cd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cd8:	50                   	push   %eax
  801cd9:	6a 00                	push   $0x0
  801cdb:	56                   	push   %esi
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 7d ee ff ff       	call   800b60 <sys_page_map>
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	83 c4 20             	add    $0x20,%esp
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 55                	js     801d41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1c:	e8 8e f0 ff ff       	call   800daf <fd2num>
  801d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d26:	83 c4 04             	add    $0x4,%esp
  801d29:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2c:	e8 7e f0 ff ff       	call   800daf <fd2num>
  801d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3f:	eb 30                	jmp    801d71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d41:	83 ec 08             	sub    $0x8,%esp
  801d44:	56                   	push   %esi
  801d45:	6a 00                	push   $0x0
  801d47:	e8 56 ee ff ff       	call   800ba2 <sys_page_unmap>
  801d4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	ff 75 f0             	pushl  -0x10(%ebp)
  801d55:	6a 00                	push   $0x0
  801d57:	e8 46 ee ff ff       	call   800ba2 <sys_page_unmap>
  801d5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	ff 75 f4             	pushl  -0xc(%ebp)
  801d65:	6a 00                	push   $0x0
  801d67:	e8 36 ee ff ff       	call   800ba2 <sys_page_unmap>
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d71:	89 d0                	mov    %edx,%eax
  801d73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5e                   	pop    %esi
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	ff 75 08             	pushl  0x8(%ebp)
  801d87:	e8 99 f0 ff ff       	call   800e25 <fd_lookup>
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 d2                	test   %edx,%edx
  801d93:	78 18                	js     801dad <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9b:	e8 1f f0 ff ff       	call   800dbf <fd2data>
	return _pipeisclosed(fd, p);
  801da0:	89 c2                	mov    %eax,%edx
  801da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da5:	e8 26 fd ff ff       	call   801ad0 <_pipeisclosed>
  801daa:	83 c4 10             	add    $0x10,%esp
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    

00801db9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dbf:	68 67 28 80 00       	push   $0x802867
  801dc4:	ff 75 0c             	pushl  0xc(%ebp)
  801dc7:	e8 48 e9 ff ff       	call   800714 <strcpy>
	return 0;
}
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	57                   	push   %edi
  801dd7:	56                   	push   %esi
  801dd8:	53                   	push   %ebx
  801dd9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ddf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dea:	eb 2d                	jmp    801e19 <devcons_write+0x46>
		m = n - tot;
  801dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801def:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801df1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801df4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	53                   	push   %ebx
  801e00:	03 45 0c             	add    0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	57                   	push   %edi
  801e05:	e8 9c ea ff ff       	call   8008a6 <memmove>
		sys_cputs(buf, m);
  801e0a:	83 c4 08             	add    $0x8,%esp
  801e0d:	53                   	push   %ebx
  801e0e:	57                   	push   %edi
  801e0f:	e8 4d ec ff ff       	call   800a61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e14:	01 de                	add    %ebx,%esi
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	89 f0                	mov    %esi,%eax
  801e1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1e:	72 cc                	jb     801dec <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    

00801e28 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801e33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e37:	75 07                	jne    801e40 <devcons_read+0x18>
  801e39:	eb 28                	jmp    801e63 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e3b:	e8 be ec ff ff       	call   800afe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e40:	e8 3a ec ff ff       	call   800a7f <sys_cgetc>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	74 f2                	je     801e3b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 16                	js     801e63 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e4d:	83 f8 04             	cmp    $0x4,%eax
  801e50:	74 0c                	je     801e5e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e55:	88 02                	mov    %al,(%edx)
	return 1;
  801e57:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5c:	eb 05                	jmp    801e63 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e71:	6a 01                	push   $0x1
  801e73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e76:	50                   	push   %eax
  801e77:	e8 e5 eb ff ff       	call   800a61 <sys_cputs>
  801e7c:	83 c4 10             	add    $0x10,%esp
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <getchar>:

int
getchar(void)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e87:	6a 01                	push   $0x1
  801e89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 00 f2 ff ff       	call   801094 <read>
	if (r < 0)
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 0f                	js     801eaa <getchar+0x29>
		return r;
	if (r < 1)
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	7e 06                	jle    801ea5 <getchar+0x24>
		return -E_EOF;
	return c;
  801e9f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea3:	eb 05                	jmp    801eaa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb5:	50                   	push   %eax
  801eb6:	ff 75 08             	pushl  0x8(%ebp)
  801eb9:	e8 67 ef ff ff       	call   800e25 <fd_lookup>
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 11                	js     801ed6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ece:	39 10                	cmp    %edx,(%eax)
  801ed0:	0f 94 c0             	sete   %al
  801ed3:	0f b6 c0             	movzbl %al,%eax
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <opencons>:

int
opencons(void)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ede:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee1:	50                   	push   %eax
  801ee2:	e8 ef ee ff ff       	call   800dd6 <fd_alloc>
  801ee7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eea:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 3e                	js     801f2e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	68 07 04 00 00       	push   $0x407
  801ef8:	ff 75 f4             	pushl  -0xc(%ebp)
  801efb:	6a 00                	push   $0x0
  801efd:	e8 1b ec ff ff       	call   800b1d <sys_page_alloc>
  801f02:	83 c4 10             	add    $0x10,%esp
		return r;
  801f05:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 23                	js     801f2e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f19:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	50                   	push   %eax
  801f24:	e8 86 ee ff ff       	call   800daf <fd2num>
  801f29:	89 c2                	mov    %eax,%edx
  801f2b:	83 c4 10             	add    $0x10,%esp
}
  801f2e:	89 d0                	mov    %edx,%eax
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	56                   	push   %esi
  801f36:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f37:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f3a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f40:	e8 9a eb ff ff       	call   800adf <sys_getenvid>
  801f45:	83 ec 0c             	sub    $0xc,%esp
  801f48:	ff 75 0c             	pushl  0xc(%ebp)
  801f4b:	ff 75 08             	pushl  0x8(%ebp)
  801f4e:	56                   	push   %esi
  801f4f:	50                   	push   %eax
  801f50:	68 74 28 80 00       	push   $0x802874
  801f55:	e8 33 e2 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f5a:	83 c4 18             	add    $0x18,%esp
  801f5d:	53                   	push   %ebx
  801f5e:	ff 75 10             	pushl  0x10(%ebp)
  801f61:	e8 d6 e1 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801f66:	c7 04 24 60 28 80 00 	movl   $0x802860,(%esp)
  801f6d:	e8 1b e2 ff ff       	call   80018d <cprintf>
  801f72:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f75:	cc                   	int3   
  801f76:	eb fd                	jmp    801f75 <_panic+0x43>

00801f78 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	56                   	push   %esi
  801f7c:	53                   	push   %ebx
  801f7d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f86:	85 c0                	test   %eax,%eax
  801f88:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f8d:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	50                   	push   %eax
  801f94:	e8 34 ed ff ff       	call   800ccd <sys_ipc_recv>
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	79 16                	jns    801fb6 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801fa0:	85 f6                	test   %esi,%esi
  801fa2:	74 06                	je     801faa <ipc_recv+0x32>
  801fa4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801faa:	85 db                	test   %ebx,%ebx
  801fac:	74 2c                	je     801fda <ipc_recv+0x62>
  801fae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fb4:	eb 24                	jmp    801fda <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801fb6:	85 f6                	test   %esi,%esi
  801fb8:	74 0a                	je     801fc4 <ipc_recv+0x4c>
  801fba:	a1 08 40 80 00       	mov    0x804008,%eax
  801fbf:	8b 40 74             	mov    0x74(%eax),%eax
  801fc2:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801fc4:	85 db                	test   %ebx,%ebx
  801fc6:	74 0a                	je     801fd2 <ipc_recv+0x5a>
  801fc8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fcd:	8b 40 78             	mov    0x78(%eax),%eax
  801fd0:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801fd2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	57                   	push   %edi
  801fe5:	56                   	push   %esi
  801fe6:	53                   	push   %ebx
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fed:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801ff3:	85 db                	test   %ebx,%ebx
  801ff5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ffa:	0f 44 d8             	cmove  %eax,%ebx
  801ffd:	eb 1c                	jmp    80201b <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802002:	74 12                	je     802016 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802004:	50                   	push   %eax
  802005:	68 98 28 80 00       	push   $0x802898
  80200a:	6a 39                	push   $0x39
  80200c:	68 b3 28 80 00       	push   $0x8028b3
  802011:	e8 1c ff ff ff       	call   801f32 <_panic>
                 sys_yield();
  802016:	e8 e3 ea ff ff       	call   800afe <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80201b:	ff 75 14             	pushl  0x14(%ebp)
  80201e:	53                   	push   %ebx
  80201f:	56                   	push   %esi
  802020:	57                   	push   %edi
  802021:	e8 84 ec ff ff       	call   800caa <sys_ipc_try_send>
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	85 c0                	test   %eax,%eax
  80202b:	78 d2                	js     801fff <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80202d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    

00802035 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802040:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802043:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802049:	8b 52 50             	mov    0x50(%edx),%edx
  80204c:	39 ca                	cmp    %ecx,%edx
  80204e:	75 0d                	jne    80205d <ipc_find_env+0x28>
			return envs[i].env_id;
  802050:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802053:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802058:	8b 40 08             	mov    0x8(%eax),%eax
  80205b:	eb 0e                	jmp    80206b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205d:	83 c0 01             	add    $0x1,%eax
  802060:	3d 00 04 00 00       	cmp    $0x400,%eax
  802065:	75 d9                	jne    802040 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802067:	66 b8 00 00          	mov    $0x0,%ax
}
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    

0080206d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802073:	89 d0                	mov    %edx,%eax
  802075:	c1 e8 16             	shr    $0x16,%eax
  802078:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802084:	f6 c1 01             	test   $0x1,%cl
  802087:	74 1d                	je     8020a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802089:	c1 ea 0c             	shr    $0xc,%edx
  80208c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802093:	f6 c2 01             	test   $0x1,%dl
  802096:	74 0e                	je     8020a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802098:	c1 ea 0c             	shr    $0xc,%edx
  80209b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a2:	ef 
  8020a3:	0f b7 c0             	movzwl %ax,%eax
}
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	83 ec 10             	sub    $0x10,%esp
  8020b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020c6:	85 d2                	test   %edx,%edx
  8020c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020cc:	89 34 24             	mov    %esi,(%esp)
  8020cf:	89 c8                	mov    %ecx,%eax
  8020d1:	75 35                	jne    802108 <__udivdi3+0x58>
  8020d3:	39 f1                	cmp    %esi,%ecx
  8020d5:	0f 87 bd 00 00 00    	ja     802198 <__udivdi3+0xe8>
  8020db:	85 c9                	test   %ecx,%ecx
  8020dd:	89 cd                	mov    %ecx,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f1                	div    %ecx
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 f0                	mov    %esi,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c6                	mov    %eax,%esi
  8020f4:	89 f8                	mov    %edi,%eax
  8020f6:	f7 f5                	div    %ebp
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    
  802101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802108:	3b 14 24             	cmp    (%esp),%edx
  80210b:	77 7b                	ja     802188 <__udivdi3+0xd8>
  80210d:	0f bd f2             	bsr    %edx,%esi
  802110:	83 f6 1f             	xor    $0x1f,%esi
  802113:	0f 84 97 00 00 00    	je     8021b0 <__udivdi3+0x100>
  802119:	bd 20 00 00 00       	mov    $0x20,%ebp
  80211e:	89 d7                	mov    %edx,%edi
  802120:	89 f1                	mov    %esi,%ecx
  802122:	29 f5                	sub    %esi,%ebp
  802124:	d3 e7                	shl    %cl,%edi
  802126:	89 c2                	mov    %eax,%edx
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	d3 ea                	shr    %cl,%edx
  80212c:	89 f1                	mov    %esi,%ecx
  80212e:	09 fa                	or     %edi,%edx
  802130:	8b 3c 24             	mov    (%esp),%edi
  802133:	d3 e0                	shl    %cl,%eax
  802135:	89 54 24 08          	mov    %edx,0x8(%esp)
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802143:	89 fa                	mov    %edi,%edx
  802145:	d3 ea                	shr    %cl,%edx
  802147:	89 f1                	mov    %esi,%ecx
  802149:	d3 e7                	shl    %cl,%edi
  80214b:	89 e9                	mov    %ebp,%ecx
  80214d:	d3 e8                	shr    %cl,%eax
  80214f:	09 c7                	or     %eax,%edi
  802151:	89 f8                	mov    %edi,%eax
  802153:	f7 74 24 08          	divl   0x8(%esp)
  802157:	89 d5                	mov    %edx,%ebp
  802159:	89 c7                	mov    %eax,%edi
  80215b:	f7 64 24 0c          	mull   0xc(%esp)
  80215f:	39 d5                	cmp    %edx,%ebp
  802161:	89 14 24             	mov    %edx,(%esp)
  802164:	72 11                	jb     802177 <__udivdi3+0xc7>
  802166:	8b 54 24 04          	mov    0x4(%esp),%edx
  80216a:	89 f1                	mov    %esi,%ecx
  80216c:	d3 e2                	shl    %cl,%edx
  80216e:	39 c2                	cmp    %eax,%edx
  802170:	73 5e                	jae    8021d0 <__udivdi3+0x120>
  802172:	3b 2c 24             	cmp    (%esp),%ebp
  802175:	75 59                	jne    8021d0 <__udivdi3+0x120>
  802177:	8d 47 ff             	lea    -0x1(%edi),%eax
  80217a:	31 f6                	xor    %esi,%esi
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	31 f6                	xor    %esi,%esi
  80218a:	31 c0                	xor    %eax,%eax
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	89 f2                	mov    %esi,%edx
  80219a:	31 f6                	xor    %esi,%esi
  80219c:	89 f8                	mov    %edi,%eax
  80219e:	f7 f1                	div    %ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021b4:	76 0b                	jbe    8021c1 <__udivdi3+0x111>
  8021b6:	31 c0                	xor    %eax,%eax
  8021b8:	3b 14 24             	cmp    (%esp),%edx
  8021bb:	0f 83 37 ff ff ff    	jae    8020f8 <__udivdi3+0x48>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	e9 2d ff ff ff       	jmp    8020f8 <__udivdi3+0x48>
  8021cb:	90                   	nop
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 f8                	mov    %edi,%eax
  8021d2:	31 f6                	xor    %esi,%esi
  8021d4:	e9 1f ff ff ff       	jmp    8020f8 <__udivdi3+0x48>
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	83 ec 20             	sub    $0x20,%esp
  8021e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f2:	89 c6                	mov    %eax,%esi
  8021f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802200:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802204:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802208:	89 74 24 18          	mov    %esi,0x18(%esp)
  80220c:	85 c0                	test   %eax,%eax
  80220e:	89 c2                	mov    %eax,%edx
  802210:	75 1e                	jne    802230 <__umoddi3+0x50>
  802212:	39 f7                	cmp    %esi,%edi
  802214:	76 52                	jbe    802268 <__umoddi3+0x88>
  802216:	89 c8                	mov    %ecx,%eax
  802218:	89 f2                	mov    %esi,%edx
  80221a:	f7 f7                	div    %edi
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	83 c4 20             	add    $0x20,%esp
  802223:	5e                   	pop    %esi
  802224:	5f                   	pop    %edi
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    
  802227:	89 f6                	mov    %esi,%esi
  802229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802230:	39 f0                	cmp    %esi,%eax
  802232:	77 5c                	ja     802290 <__umoddi3+0xb0>
  802234:	0f bd e8             	bsr    %eax,%ebp
  802237:	83 f5 1f             	xor    $0x1f,%ebp
  80223a:	75 64                	jne    8022a0 <__umoddi3+0xc0>
  80223c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802240:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802244:	0f 86 f6 00 00 00    	jbe    802340 <__umoddi3+0x160>
  80224a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80224e:	0f 82 ec 00 00 00    	jb     802340 <__umoddi3+0x160>
  802254:	8b 44 24 14          	mov    0x14(%esp),%eax
  802258:	8b 54 24 18          	mov    0x18(%esp),%edx
  80225c:	83 c4 20             	add    $0x20,%esp
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    
  802263:	90                   	nop
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	85 ff                	test   %edi,%edi
  80226a:	89 fd                	mov    %edi,%ebp
  80226c:	75 0b                	jne    802279 <__umoddi3+0x99>
  80226e:	b8 01 00 00 00       	mov    $0x1,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f7                	div    %edi
  802277:	89 c5                	mov    %eax,%ebp
  802279:	8b 44 24 10          	mov    0x10(%esp),%eax
  80227d:	31 d2                	xor    %edx,%edx
  80227f:	f7 f5                	div    %ebp
  802281:	89 c8                	mov    %ecx,%eax
  802283:	f7 f5                	div    %ebp
  802285:	eb 95                	jmp    80221c <__umoddi3+0x3c>
  802287:	89 f6                	mov    %esi,%esi
  802289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 20             	add    $0x20,%esp
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    
  80229b:	90                   	nop
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	29 e8                	sub    %ebp,%eax
  8022a9:	d3 e2                	shl    %cl,%edx
  8022ab:	89 c7                	mov    %eax,%edi
  8022ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 c1                	mov    %eax,%ecx
  8022bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022bf:	09 d1                	or     %edx,%ecx
  8022c1:	89 fa                	mov    %edi,%edx
  8022c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022c7:	89 e9                	mov    %ebp,%ecx
  8022c9:	d3 e0                	shl    %cl,%eax
  8022cb:	89 f9                	mov    %edi,%ecx
  8022cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	d3 e8                	shr    %cl,%eax
  8022d5:	89 e9                	mov    %ebp,%ecx
  8022d7:	89 c7                	mov    %eax,%edi
  8022d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022dd:	d3 e6                	shl    %cl,%esi
  8022df:	89 d1                	mov    %edx,%ecx
  8022e1:	89 fa                	mov    %edi,%edx
  8022e3:	d3 e8                	shr    %cl,%eax
  8022e5:	89 e9                	mov    %ebp,%ecx
  8022e7:	09 f0                	or     %esi,%eax
  8022e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022ed:	f7 74 24 10          	divl   0x10(%esp)
  8022f1:	d3 e6                	shl    %cl,%esi
  8022f3:	89 d1                	mov    %edx,%ecx
  8022f5:	f7 64 24 0c          	mull   0xc(%esp)
  8022f9:	39 d1                	cmp    %edx,%ecx
  8022fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022ff:	89 d7                	mov    %edx,%edi
  802301:	89 c6                	mov    %eax,%esi
  802303:	72 0a                	jb     80230f <__umoddi3+0x12f>
  802305:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802309:	73 10                	jae    80231b <__umoddi3+0x13b>
  80230b:	39 d1                	cmp    %edx,%ecx
  80230d:	75 0c                	jne    80231b <__umoddi3+0x13b>
  80230f:	89 d7                	mov    %edx,%edi
  802311:	89 c6                	mov    %eax,%esi
  802313:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802317:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80231b:	89 ca                	mov    %ecx,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802323:	29 f0                	sub    %esi,%eax
  802325:	19 fa                	sbb    %edi,%edx
  802327:	d3 e8                	shr    %cl,%eax
  802329:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80232e:	89 d7                	mov    %edx,%edi
  802330:	d3 e7                	shl    %cl,%edi
  802332:	89 e9                	mov    %ebp,%ecx
  802334:	09 f8                	or     %edi,%eax
  802336:	d3 ea                	shr    %cl,%edx
  802338:	83 c4 20             	add    $0x20,%esp
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
  80233f:	90                   	nop
  802340:	8b 74 24 10          	mov    0x10(%esp),%esi
  802344:	29 f9                	sub    %edi,%ecx
  802346:	19 c6                	sbb    %eax,%esi
  802348:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80234c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802350:	e9 ff fe ff ff       	jmp    802254 <__umoddi3+0x74>
