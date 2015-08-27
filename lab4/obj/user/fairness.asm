
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 9e 0a 00 00       	call   800ade <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 6d 0c 00 00       	call   800ccb <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 10 80 00       	push   $0x8010c0
  80006a:	e8 1d 01 00 00       	call   80018c <cprintf>
		}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 10 80 00       	push   $0x8010d1
  800083:	e8 04 01 00 00       	call   80018c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 98 0c 00 00       	call   800d34 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000ac:	e8 2d 0a 00 00       	call   800ade <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
  8000dd:	83 c4 10             	add    $0x10,%esp
}
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 a9 09 00 00       	call   800a9d <sys_env_destroy>
  8000f4:	83 c4 10             	add    $0x10,%esp
}
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 37 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 4f 01 00 00       	call   8002be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 dc 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 d1                	mov    %edx,%ecx
  8001b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001cb:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001ce:	72 05                	jb     8001d5 <printnum+0x35>
  8001d0:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001d3:	77 3e                	ja     800213 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	ff 75 18             	pushl  0x18(%ebp)
  8001db:	83 eb 01             	sub    $0x1,%ebx
  8001de:	53                   	push   %ebx
  8001df:	50                   	push   %eax
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 1c 0c 00 00       	call   800e10 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 9e ff ff ff       	call   8001a0 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 13                	jmp    80021a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	pushl  0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800213:	83 eb 01             	sub    $0x1,%ebx
  800216:	85 db                	test   %ebx,%ebx
  800218:	7f ed                	jg     800207 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	56                   	push   %esi
  80021e:	83 ec 04             	sub    $0x4,%esp
  800221:	ff 75 e4             	pushl  -0x1c(%ebp)
  800224:	ff 75 e0             	pushl  -0x20(%ebp)
  800227:	ff 75 dc             	pushl  -0x24(%ebp)
  80022a:	ff 75 d8             	pushl  -0x28(%ebp)
  80022d:	e8 0e 0d 00 00       	call   800f40 <__umoddi3>
  800232:	83 c4 14             	add    $0x14,%esp
  800235:	0f be 80 f2 10 80 00 	movsbl 0x8010f2(%eax),%eax
  80023c:	50                   	push   %eax
  80023d:	ff d7                	call   *%edi
  80023f:	83 c4 10             	add    $0x10,%esp
}
  800242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024d:	83 fa 01             	cmp    $0x1,%edx
  800250:	7e 0e                	jle    800260 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 08             	lea    0x8(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x38>
	else if (lflag)
  800260:	85 d2                	test   %edx,%edx
  800262:	74 10                	je     800274 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	3b 50 04             	cmp    0x4(%eax),%edx
  800293:	73 0a                	jae    80029f <sprintputch+0x1b>
		*b->buf++ = ch;
  800295:	8d 4a 01             	lea    0x1(%edx),%ecx
  800298:	89 08                	mov    %ecx,(%eax)
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	88 02                	mov    %al,(%edx)
}
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 10             	pushl  0x10(%ebp)
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	e8 05 00 00 00       	call   8002be <vprintfmt>
	va_end(ap);
  8002b9:	83 c4 10             	add    $0x10,%esp
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 2c             	sub    $0x2c,%esp
  8002c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d0:	eb 12                	jmp    8002e4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	0f 84 90 03 00 00    	je     80066a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002da:	83 ec 08             	sub    $0x8,%esp
  8002dd:	53                   	push   %ebx
  8002de:	50                   	push   %eax
  8002df:	ff d6                	call   *%esi
  8002e1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e4:	83 c7 01             	add    $0x1,%edi
  8002e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002eb:	83 f8 25             	cmp    $0x25,%eax
  8002ee:	75 e2                	jne    8002d2 <vprintfmt+0x14>
  8002f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800302:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 07                	jmp    800317 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800313:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800317:	8d 47 01             	lea    0x1(%edi),%eax
  80031a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031d:	0f b6 07             	movzbl (%edi),%eax
  800320:	0f b6 c8             	movzbl %al,%ecx
  800323:	83 e8 23             	sub    $0x23,%eax
  800326:	3c 55                	cmp    $0x55,%al
  800328:	0f 87 21 03 00 00    	ja     80064f <vprintfmt+0x391>
  80032e:	0f b6 c0             	movzbl %al,%eax
  800331:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033f:	eb d6                	jmp    800317 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800344:	b8 00 00 00 00       	mov    $0x0,%eax
  800349:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800353:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800356:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800359:	83 fa 09             	cmp    $0x9,%edx
  80035c:	77 39                	ja     800397 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800361:	eb e9                	jmp    80034c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800363:	8b 45 14             	mov    0x14(%ebp),%eax
  800366:	8d 48 04             	lea    0x4(%eax),%ecx
  800369:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036c:	8b 00                	mov    (%eax),%eax
  80036e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800374:	eb 27                	jmp    80039d <vprintfmt+0xdf>
  800376:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800379:	85 c0                	test   %eax,%eax
  80037b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800380:	0f 49 c8             	cmovns %eax,%ecx
  800383:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	eb 8c                	jmp    800317 <vprintfmt+0x59>
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800395:	eb 80                	jmp    800317 <vprintfmt+0x59>
  800397:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a1:	0f 89 70 ff ff ff    	jns    800317 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b4:	e9 5e ff ff ff       	jmp    800317 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bf:	e9 53 ff ff ff       	jmp    800317 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	53                   	push   %ebx
  8003d1:	ff 30                	pushl  (%eax)
  8003d3:	ff d6                	call   *%esi
			break;
  8003d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003db:	e9 04 ff ff ff       	jmp    8002e4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	8b 00                	mov    (%eax),%eax
  8003eb:	99                   	cltd   
  8003ec:	31 d0                	xor    %edx,%eax
  8003ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f0:	83 f8 09             	cmp    $0x9,%eax
  8003f3:	7f 0b                	jg     800400 <vprintfmt+0x142>
  8003f5:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8003fc:	85 d2                	test   %edx,%edx
  8003fe:	75 18                	jne    800418 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800400:	50                   	push   %eax
  800401:	68 0a 11 80 00       	push   $0x80110a
  800406:	53                   	push   %ebx
  800407:	56                   	push   %esi
  800408:	e8 94 fe ff ff       	call   8002a1 <printfmt>
  80040d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 cc fe ff ff       	jmp    8002e4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800418:	52                   	push   %edx
  800419:	68 13 11 80 00       	push   $0x801113
  80041e:	53                   	push   %ebx
  80041f:	56                   	push   %esi
  800420:	e8 7c fe ff ff       	call   8002a1 <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042b:	e9 b4 fe ff ff       	jmp    8002e4 <vprintfmt+0x26>
  800430:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800433:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800436:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800444:	85 ff                	test   %edi,%edi
  800446:	ba 03 11 80 00       	mov    $0x801103,%edx
  80044b:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80044e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800452:	0f 84 92 00 00 00    	je     8004ea <vprintfmt+0x22c>
  800458:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80045c:	0f 8e 96 00 00 00    	jle    8004f8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	51                   	push   %ecx
  800466:	57                   	push   %edi
  800467:	e8 86 02 00 00       	call   8006f2 <strnlen>
  80046c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046f:	29 c1                	sub    %eax,%ecx
  800471:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800477:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800481:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	eb 0f                	jmp    800494 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	ff 75 e0             	pushl  -0x20(%ebp)
  80048c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	83 ef 01             	sub    $0x1,%edi
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	85 ff                	test   %edi,%edi
  800496:	7f ed                	jg     800485 <vprintfmt+0x1c7>
  800498:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 49 c1             	cmovns %ecx,%eax
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	89 cb                	mov    %ecx,%ebx
  8004b5:	eb 4d                	jmp    800504 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bb:	74 1b                	je     8004d8 <vprintfmt+0x21a>
  8004bd:	0f be c0             	movsbl %al,%eax
  8004c0:	83 e8 20             	sub    $0x20,%eax
  8004c3:	83 f8 5e             	cmp    $0x5e,%eax
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x21a>
					putch('?', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ce:	6a 3f                	push   $0x3f
  8004d0:	ff 55 08             	call   *0x8(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	eb 0d                	jmp    8004e5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	52                   	push   %edx
  8004df:	ff 55 08             	call   *0x8(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e5:	83 eb 01             	sub    $0x1,%ebx
  8004e8:	eb 1a                	jmp    800504 <vprintfmt+0x246>
  8004ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f6:	eb 0c                	jmp    800504 <vprintfmt+0x246>
  8004f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800501:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800504:	83 c7 01             	add    $0x1,%edi
  800507:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050b:	0f be d0             	movsbl %al,%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	74 23                	je     800535 <vprintfmt+0x277>
  800512:	85 f6                	test   %esi,%esi
  800514:	78 a1                	js     8004b7 <vprintfmt+0x1f9>
  800516:	83 ee 01             	sub    $0x1,%esi
  800519:	79 9c                	jns    8004b7 <vprintfmt+0x1f9>
  80051b:	89 df                	mov    %ebx,%edi
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800523:	eb 18                	jmp    80053d <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052d:	83 ef 01             	sub    $0x1,%edi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb 08                	jmp    80053d <vprintfmt+0x27f>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7f e4                	jg     800525 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800544:	e9 9b fd ff ff       	jmp    8002e4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800549:	83 fa 01             	cmp    $0x1,%edx
  80054c:	7e 16                	jle    800564 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 08             	lea    0x8(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 50 04             	mov    0x4(%eax),%edx
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800562:	eb 32                	jmp    800596 <vprintfmt+0x2d8>
	else if (lflag)
  800564:	85 d2                	test   %edx,%edx
  800566:	74 18                	je     800580 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800576:	89 c1                	mov    %eax,%ecx
  800578:	c1 f9 1f             	sar    $0x1f,%ecx
  80057b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057e:	eb 16                	jmp    800596 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	89 c1                	mov    %eax,%ecx
  800590:	c1 f9 1f             	sar    $0x1f,%ecx
  800593:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800599:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a5:	79 74                	jns    80061b <vprintfmt+0x35d>
				putch('-', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 2d                	push   $0x2d
  8005ad:	ff d6                	call   *%esi
				num = -(long long) num;
  8005af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b5:	f7 d8                	neg    %eax
  8005b7:	83 d2 00             	adc    $0x0,%edx
  8005ba:	f7 da                	neg    %edx
  8005bc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c4:	eb 55                	jmp    80061b <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	e8 7c fc ff ff       	call   80024a <getuint>
			base = 10;
  8005ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d3:	eb 46                	jmp    80061b <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 6d fc ff ff       	call   80024a <getuint>
                        base = 8;
  8005dd:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005e2:	eb 37                	jmp    80061b <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 30                	push   $0x30
  8005ea:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ec:	83 c4 08             	add    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 78                	push   $0x78
  8005f2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800604:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800607:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060c:	eb 0d                	jmp    80061b <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 34 fc ff ff       	call   80024a <getuint>
			base = 16;
  800616:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061b:	83 ec 0c             	sub    $0xc,%esp
  80061e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800622:	57                   	push   %edi
  800623:	ff 75 e0             	pushl  -0x20(%ebp)
  800626:	51                   	push   %ecx
  800627:	52                   	push   %edx
  800628:	50                   	push   %eax
  800629:	89 da                	mov    %ebx,%edx
  80062b:	89 f0                	mov    %esi,%eax
  80062d:	e8 6e fb ff ff       	call   8001a0 <printnum>
			break;
  800632:	83 c4 20             	add    $0x20,%esp
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800638:	e9 a7 fc ff ff       	jmp    8002e4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	51                   	push   %ecx
  800642:	ff d6                	call   *%esi
			break;
  800644:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064a:	e9 95 fc ff ff       	jmp    8002e4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 25                	push   $0x25
  800655:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	eb 03                	jmp    80065f <vprintfmt+0x3a1>
  80065c:	83 ef 01             	sub    $0x1,%edi
  80065f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800663:	75 f7                	jne    80065c <vprintfmt+0x39e>
  800665:	e9 7a fc ff ff       	jmp    8002e4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5f                   	pop    %edi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 18             	sub    $0x18,%esp
  800678:	8b 45 08             	mov    0x8(%ebp),%eax
  80067b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800681:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800685:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068f:	85 c0                	test   %eax,%eax
  800691:	74 26                	je     8006b9 <vsnprintf+0x47>
  800693:	85 d2                	test   %edx,%edx
  800695:	7e 22                	jle    8006b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800697:	ff 75 14             	pushl  0x14(%ebp)
  80069a:	ff 75 10             	pushl  0x10(%ebp)
  80069d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a0:	50                   	push   %eax
  8006a1:	68 84 02 80 00       	push   $0x800284
  8006a6:	e8 13 fc ff ff       	call   8002be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb 05                	jmp    8006be <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c9:	50                   	push   %eax
  8006ca:	ff 75 10             	pushl  0x10(%ebp)
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	ff 75 08             	pushl  0x8(%ebp)
  8006d3:	e8 9a ff ff ff       	call   800672 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e5:	eb 03                	jmp    8006ea <strlen+0x10>
		n++;
  8006e7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ee:	75 f7                	jne    8006e7 <strlen+0xd>
		n++;
	return n;
}
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800700:	eb 03                	jmp    800705 <strnlen+0x13>
		n++;
  800702:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800705:	39 c2                	cmp    %eax,%edx
  800707:	74 08                	je     800711 <strnlen+0x1f>
  800709:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070d:	75 f3                	jne    800702 <strnlen+0x10>
  80070f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071d:	89 c2                	mov    %eax,%edx
  80071f:	83 c2 01             	add    $0x1,%edx
  800722:	83 c1 01             	add    $0x1,%ecx
  800725:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800729:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072c:	84 db                	test   %bl,%bl
  80072e:	75 ef                	jne    80071f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800730:	5b                   	pop    %ebx
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	53                   	push   %ebx
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073a:	53                   	push   %ebx
  80073b:	e8 9a ff ff ff       	call   8006da <strlen>
  800740:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800743:	ff 75 0c             	pushl  0xc(%ebp)
  800746:	01 d8                	add    %ebx,%eax
  800748:	50                   	push   %eax
  800749:	e8 c5 ff ff ff       	call   800713 <strcpy>
	return dst;
}
  80074e:	89 d8                	mov    %ebx,%eax
  800750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	8b 75 08             	mov    0x8(%ebp),%esi
  80075d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800760:	89 f3                	mov    %esi,%ebx
  800762:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800765:	89 f2                	mov    %esi,%edx
  800767:	eb 0f                	jmp    800778 <strncpy+0x23>
		*dst++ = *src;
  800769:	83 c2 01             	add    $0x1,%edx
  80076c:	0f b6 01             	movzbl (%ecx),%eax
  80076f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800772:	80 39 01             	cmpb   $0x1,(%ecx)
  800775:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800778:	39 da                	cmp    %ebx,%edx
  80077a:	75 ed                	jne    800769 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077c:	89 f0                	mov    %esi,%eax
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	56                   	push   %esi
  800786:	53                   	push   %ebx
  800787:	8b 75 08             	mov    0x8(%ebp),%esi
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078d:	8b 55 10             	mov    0x10(%ebp),%edx
  800790:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	74 21                	je     8007b7 <strlcpy+0x35>
  800796:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079a:	89 f2                	mov    %esi,%edx
  80079c:	eb 09                	jmp    8007a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079e:	83 c2 01             	add    $0x1,%edx
  8007a1:	83 c1 01             	add    $0x1,%ecx
  8007a4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a7:	39 c2                	cmp    %eax,%edx
  8007a9:	74 09                	je     8007b4 <strlcpy+0x32>
  8007ab:	0f b6 19             	movzbl (%ecx),%ebx
  8007ae:	84 db                	test   %bl,%bl
  8007b0:	75 ec                	jne    80079e <strlcpy+0x1c>
  8007b2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b7:	29 f0                	sub    %esi,%eax
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c6:	eb 06                	jmp    8007ce <strcmp+0x11>
		p++, q++;
  8007c8:	83 c1 01             	add    $0x1,%ecx
  8007cb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ce:	0f b6 01             	movzbl (%ecx),%eax
  8007d1:	84 c0                	test   %al,%al
  8007d3:	74 04                	je     8007d9 <strcmp+0x1c>
  8007d5:	3a 02                	cmp    (%edx),%al
  8007d7:	74 ef                	je     8007c8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d9:	0f b6 c0             	movzbl %al,%eax
  8007dc:	0f b6 12             	movzbl (%edx),%edx
  8007df:	29 d0                	sub    %edx,%eax
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 c3                	mov    %eax,%ebx
  8007ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f2:	eb 06                	jmp    8007fa <strncmp+0x17>
		n--, p++, q++;
  8007f4:	83 c0 01             	add    $0x1,%eax
  8007f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fa:	39 d8                	cmp    %ebx,%eax
  8007fc:	74 15                	je     800813 <strncmp+0x30>
  8007fe:	0f b6 08             	movzbl (%eax),%ecx
  800801:	84 c9                	test   %cl,%cl
  800803:	74 04                	je     800809 <strncmp+0x26>
  800805:	3a 0a                	cmp    (%edx),%cl
  800807:	74 eb                	je     8007f4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800809:	0f b6 00             	movzbl (%eax),%eax
  80080c:	0f b6 12             	movzbl (%edx),%edx
  80080f:	29 d0                	sub    %edx,%eax
  800811:	eb 05                	jmp    800818 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800825:	eb 07                	jmp    80082e <strchr+0x13>
		if (*s == c)
  800827:	38 ca                	cmp    %cl,%dl
  800829:	74 0f                	je     80083a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082b:	83 c0 01             	add    $0x1,%eax
  80082e:	0f b6 10             	movzbl (%eax),%edx
  800831:	84 d2                	test   %dl,%dl
  800833:	75 f2                	jne    800827 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800846:	eb 03                	jmp    80084b <strfind+0xf>
  800848:	83 c0 01             	add    $0x1,%eax
  80084b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084e:	84 d2                	test   %dl,%dl
  800850:	74 04                	je     800856 <strfind+0x1a>
  800852:	38 ca                	cmp    %cl,%dl
  800854:	75 f2                	jne    800848 <strfind+0xc>
			break;
	return (char *) s;
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	57                   	push   %edi
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800861:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800864:	85 c9                	test   %ecx,%ecx
  800866:	74 36                	je     80089e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800868:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086e:	75 28                	jne    800898 <memset+0x40>
  800870:	f6 c1 03             	test   $0x3,%cl
  800873:	75 23                	jne    800898 <memset+0x40>
		c &= 0xFF;
  800875:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800879:	89 d3                	mov    %edx,%ebx
  80087b:	c1 e3 08             	shl    $0x8,%ebx
  80087e:	89 d6                	mov    %edx,%esi
  800880:	c1 e6 18             	shl    $0x18,%esi
  800883:	89 d0                	mov    %edx,%eax
  800885:	c1 e0 10             	shl    $0x10,%eax
  800888:	09 f0                	or     %esi,%eax
  80088a:	09 c2                	or     %eax,%edx
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800890:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800893:	fc                   	cld    
  800894:	f3 ab                	rep stos %eax,%es:(%edi)
  800896:	eb 06                	jmp    80089e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800898:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089b:	fc                   	cld    
  80089c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089e:	89 f8                	mov    %edi,%eax
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5f                   	pop    %edi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b3:	39 c6                	cmp    %eax,%esi
  8008b5:	73 35                	jae    8008ec <memmove+0x47>
  8008b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ba:	39 d0                	cmp    %edx,%eax
  8008bc:	73 2e                	jae    8008ec <memmove+0x47>
		s += n;
		d += n;
  8008be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008c1:	89 d6                	mov    %edx,%esi
  8008c3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cb:	75 13                	jne    8008e0 <memmove+0x3b>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 0e                	jne    8008e0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d2:	83 ef 04             	sub    $0x4,%edi
  8008d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008db:	fd                   	std    
  8008dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008de:	eb 09                	jmp    8008e9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e0:	83 ef 01             	sub    $0x1,%edi
  8008e3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e6:	fd                   	std    
  8008e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e9:	fc                   	cld    
  8008ea:	eb 1d                	jmp    800909 <memmove+0x64>
  8008ec:	89 f2                	mov    %esi,%edx
  8008ee:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	f6 c2 03             	test   $0x3,%dl
  8008f3:	75 0f                	jne    800904 <memmove+0x5f>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 0a                	jne    800904 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008fd:	89 c7                	mov    %eax,%edi
  8008ff:	fc                   	cld    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 05                	jmp    800909 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800904:	89 c7                	mov    %eax,%edi
  800906:	fc                   	cld    
  800907:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800910:	ff 75 10             	pushl  0x10(%ebp)
  800913:	ff 75 0c             	pushl  0xc(%ebp)
  800916:	ff 75 08             	pushl  0x8(%ebp)
  800919:	e8 87 ff ff ff       	call   8008a5 <memmove>
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092b:	89 c6                	mov    %eax,%esi
  80092d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800930:	eb 1a                	jmp    80094c <memcmp+0x2c>
		if (*s1 != *s2)
  800932:	0f b6 08             	movzbl (%eax),%ecx
  800935:	0f b6 1a             	movzbl (%edx),%ebx
  800938:	38 d9                	cmp    %bl,%cl
  80093a:	74 0a                	je     800946 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093c:	0f b6 c1             	movzbl %cl,%eax
  80093f:	0f b6 db             	movzbl %bl,%ebx
  800942:	29 d8                	sub    %ebx,%eax
  800944:	eb 0f                	jmp    800955 <memcmp+0x35>
		s1++, s2++;
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094c:	39 f0                	cmp    %esi,%eax
  80094e:	75 e2                	jne    800932 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800962:	89 c2                	mov    %eax,%edx
  800964:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800967:	eb 07                	jmp    800970 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	38 08                	cmp    %cl,(%eax)
  80096b:	74 07                	je     800974 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	39 d0                	cmp    %edx,%eax
  800972:	72 f5                	jb     800969 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800982:	eb 03                	jmp    800987 <strtol+0x11>
		s++;
  800984:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	0f b6 01             	movzbl (%ecx),%eax
  80098a:	3c 09                	cmp    $0x9,%al
  80098c:	74 f6                	je     800984 <strtol+0xe>
  80098e:	3c 20                	cmp    $0x20,%al
  800990:	74 f2                	je     800984 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800992:	3c 2b                	cmp    $0x2b,%al
  800994:	75 0a                	jne    8009a0 <strtol+0x2a>
		s++;
  800996:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800999:	bf 00 00 00 00       	mov    $0x0,%edi
  80099e:	eb 10                	jmp    8009b0 <strtol+0x3a>
  8009a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a5:	3c 2d                	cmp    $0x2d,%al
  8009a7:	75 07                	jne    8009b0 <strtol+0x3a>
		s++, neg = 1;
  8009a9:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009ac:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b0:	85 db                	test   %ebx,%ebx
  8009b2:	0f 94 c0             	sete   %al
  8009b5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bb:	75 19                	jne    8009d6 <strtol+0x60>
  8009bd:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c0:	75 14                	jne    8009d6 <strtol+0x60>
  8009c2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c6:	0f 85 82 00 00 00    	jne    800a4e <strtol+0xd8>
		s += 2, base = 16;
  8009cc:	83 c1 02             	add    $0x2,%ecx
  8009cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d4:	eb 16                	jmp    8009ec <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009d6:	84 c0                	test   %al,%al
  8009d8:	74 12                	je     8009ec <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009da:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009df:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e2:	75 08                	jne    8009ec <strtol+0x76>
		s++, base = 8;
  8009e4:	83 c1 01             	add    $0x1,%ecx
  8009e7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f4:	0f b6 11             	movzbl (%ecx),%edx
  8009f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fa:	89 f3                	mov    %esi,%ebx
  8009fc:	80 fb 09             	cmp    $0x9,%bl
  8009ff:	77 08                	ja     800a09 <strtol+0x93>
			dig = *s - '0';
  800a01:	0f be d2             	movsbl %dl,%edx
  800a04:	83 ea 30             	sub    $0x30,%edx
  800a07:	eb 22                	jmp    800a2b <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0c:	89 f3                	mov    %esi,%ebx
  800a0e:	80 fb 19             	cmp    $0x19,%bl
  800a11:	77 08                	ja     800a1b <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a13:	0f be d2             	movsbl %dl,%edx
  800a16:	83 ea 57             	sub    $0x57,%edx
  800a19:	eb 10                	jmp    800a2b <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 19             	cmp    $0x19,%bl
  800a23:	77 16                	ja     800a3b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2e:	7d 0f                	jge    800a3f <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a39:	eb b9                	jmp    8009f4 <strtol+0x7e>
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	eb 02                	jmp    800a41 <strtol+0xcb>
  800a3f:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a45:	74 0d                	je     800a54 <strtol+0xde>
		*endptr = (char *) s;
  800a47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4a:	89 0e                	mov    %ecx,(%esi)
  800a4c:	eb 06                	jmp    800a54 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4e:	84 c0                	test   %al,%al
  800a50:	75 92                	jne    8009e4 <strtol+0x6e>
  800a52:	eb 98                	jmp    8009ec <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a54:	f7 da                	neg    %edx
  800a56:	85 ff                	test   %edi,%edi
  800a58:	0f 45 c2             	cmovne %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 17                	jle    800ad6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	6a 03                	push   $0x3
  800ac5:	68 48 13 80 00       	push   $0x801348
  800aca:	6a 23                	push   $0x23
  800acc:	68 65 13 80 00       	push   $0x801365
  800ad1:	e8 ea 02 00 00       	call   800dc0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_yield>:

void
sys_yield(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	be 00 00 00 00       	mov    $0x0,%esi
  800b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	89 f7                	mov    %esi,%edi
  800b3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 04                	push   $0x4
  800b46:	68 48 13 80 00       	push   $0x801348
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 65 13 80 00       	push   $0x801365
  800b52:	e8 69 02 00 00       	call   800dc0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 05                	push   $0x5
  800b88:	68 48 13 80 00       	push   $0x801348
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 65 13 80 00       	push   $0x801365
  800b94:	e8 27 02 00 00       	call   800dc0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	89 df                	mov    %ebx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 06                	push   $0x6
  800bca:	68 48 13 80 00       	push   $0x801348
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 65 13 80 00       	push   $0x801365
  800bd6:	e8 e5 01 00 00       	call   800dc0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 08                	push   $0x8
  800c0c:	68 48 13 80 00       	push   $0x801348
  800c11:	6a 23                	push   $0x23
  800c13:	68 65 13 80 00       	push   $0x801365
  800c18:	e8 a3 01 00 00       	call   800dc0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 09 00 00 00       	mov    $0x9,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 09                	push   $0x9
  800c4e:	68 48 13 80 00       	push   $0x801348
  800c53:	6a 23                	push   $0x23
  800c55:	68 65 13 80 00       	push   $0x801365
  800c5a:	e8 61 01 00 00       	call   800dc0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	be 00 00 00 00       	mov    $0x0,%esi
  800c72:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c83:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c98:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 cb                	mov    %ecx,%ebx
  800ca2:	89 cf                	mov    %ecx,%edi
  800ca4:	89 ce                	mov    %ecx,%esi
  800ca6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 0c                	push   $0xc
  800cb2:	68 48 13 80 00       	push   $0x801348
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 65 13 80 00       	push   $0x801365
  800cbe:	e8 fd 00 00 00       	call   800dc0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800ce0:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	e8 9e ff ff ff       	call   800c8a <sys_ipc_recv>
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	79 16                	jns    800d09 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  800cf3:	85 f6                	test   %esi,%esi
  800cf5:	74 06                	je     800cfd <ipc_recv+0x32>
  800cf7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  800cfd:	85 db                	test   %ebx,%ebx
  800cff:	74 2c                	je     800d2d <ipc_recv+0x62>
  800d01:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800d07:	eb 24                	jmp    800d2d <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  800d09:	85 f6                	test   %esi,%esi
  800d0b:	74 0a                	je     800d17 <ipc_recv+0x4c>
  800d0d:	a1 04 20 80 00       	mov    0x802004,%eax
  800d12:	8b 40 74             	mov    0x74(%eax),%eax
  800d15:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  800d17:	85 db                	test   %ebx,%ebx
  800d19:	74 0a                	je     800d25 <ipc_recv+0x5a>
  800d1b:	a1 04 20 80 00       	mov    0x802004,%eax
  800d20:	8b 40 78             	mov    0x78(%eax),%eax
  800d23:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  800d25:	a1 04 20 80 00       	mov    0x802004,%eax
  800d2a:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  800d46:	85 db                	test   %ebx,%ebx
  800d48:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800d4d:	0f 44 d8             	cmove  %eax,%ebx
  800d50:	eb 1c                	jmp    800d6e <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  800d52:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800d55:	74 12                	je     800d69 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  800d57:	50                   	push   %eax
  800d58:	68 73 13 80 00       	push   $0x801373
  800d5d:	6a 39                	push   $0x39
  800d5f:	68 8e 13 80 00       	push   $0x80138e
  800d64:	e8 57 00 00 00       	call   800dc0 <_panic>
                 sys_yield();
  800d69:	e8 8f fd ff ff       	call   800afd <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800d6e:	ff 75 14             	pushl  0x14(%ebp)
  800d71:	53                   	push   %ebx
  800d72:	56                   	push   %esi
  800d73:	57                   	push   %edi
  800d74:	e8 ee fe ff ff       	call   800c67 <sys_ipc_try_send>
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 d2                	js     800d52 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d93:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d96:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d9c:	8b 52 50             	mov    0x50(%edx),%edx
  800d9f:	39 ca                	cmp    %ecx,%edx
  800da1:	75 0d                	jne    800db0 <ipc_find_env+0x28>
			return envs[i].env_id;
  800da3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800da6:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  800dab:	8b 40 08             	mov    0x8(%eax),%eax
  800dae:	eb 0e                	jmp    800dbe <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800db0:	83 c0 01             	add    $0x1,%eax
  800db3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800db8:	75 d9                	jne    800d93 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dba:	66 b8 00 00          	mov    $0x0,%ax
}
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dc5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dce:	e8 0b fd ff ff       	call   800ade <sys_getenvid>
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	ff 75 0c             	pushl  0xc(%ebp)
  800dd9:	ff 75 08             	pushl  0x8(%ebp)
  800ddc:	56                   	push   %esi
  800ddd:	50                   	push   %eax
  800dde:	68 98 13 80 00       	push   $0x801398
  800de3:	e8 a4 f3 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de8:	83 c4 18             	add    $0x18,%esp
  800deb:	53                   	push   %ebx
  800dec:	ff 75 10             	pushl  0x10(%ebp)
  800def:	e8 47 f3 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  800df4:	c7 04 24 8c 13 80 00 	movl   $0x80138c,(%esp)
  800dfb:	e8 8c f3 ff ff       	call   80018c <cprintf>
  800e00:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e03:	cc                   	int3   
  800e04:	eb fd                	jmp    800e03 <_panic+0x43>
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	83 ec 10             	sub    $0x10,%esp
  800e16:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800e1a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800e1e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e26:	85 d2                	test   %edx,%edx
  800e28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e2c:	89 34 24             	mov    %esi,(%esp)
  800e2f:	89 c8                	mov    %ecx,%eax
  800e31:	75 35                	jne    800e68 <__udivdi3+0x58>
  800e33:	39 f1                	cmp    %esi,%ecx
  800e35:	0f 87 bd 00 00 00    	ja     800ef8 <__udivdi3+0xe8>
  800e3b:	85 c9                	test   %ecx,%ecx
  800e3d:	89 cd                	mov    %ecx,%ebp
  800e3f:	75 0b                	jne    800e4c <__udivdi3+0x3c>
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	31 d2                	xor    %edx,%edx
  800e48:	f7 f1                	div    %ecx
  800e4a:	89 c5                	mov    %eax,%ebp
  800e4c:	89 f0                	mov    %esi,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 f5                	div    %ebp
  800e52:	89 c6                	mov    %eax,%esi
  800e54:	89 f8                	mov    %edi,%eax
  800e56:	f7 f5                	div    %ebp
  800e58:	89 f2                	mov    %esi,%edx
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
  800e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e68:	3b 14 24             	cmp    (%esp),%edx
  800e6b:	77 7b                	ja     800ee8 <__udivdi3+0xd8>
  800e6d:	0f bd f2             	bsr    %edx,%esi
  800e70:	83 f6 1f             	xor    $0x1f,%esi
  800e73:	0f 84 97 00 00 00    	je     800f10 <__udivdi3+0x100>
  800e79:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e7e:	89 d7                	mov    %edx,%edi
  800e80:	89 f1                	mov    %esi,%ecx
  800e82:	29 f5                	sub    %esi,%ebp
  800e84:	d3 e7                	shl    %cl,%edi
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	89 e9                	mov    %ebp,%ecx
  800e8a:	d3 ea                	shr    %cl,%edx
  800e8c:	89 f1                	mov    %esi,%ecx
  800e8e:	09 fa                	or     %edi,%edx
  800e90:	8b 3c 24             	mov    (%esp),%edi
  800e93:	d3 e0                	shl    %cl,%eax
  800e95:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e99:	89 e9                	mov    %ebp,%ecx
  800e9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ea3:	89 fa                	mov    %edi,%edx
  800ea5:	d3 ea                	shr    %cl,%edx
  800ea7:	89 f1                	mov    %esi,%ecx
  800ea9:	d3 e7                	shl    %cl,%edi
  800eab:	89 e9                	mov    %ebp,%ecx
  800ead:	d3 e8                	shr    %cl,%eax
  800eaf:	09 c7                	or     %eax,%edi
  800eb1:	89 f8                	mov    %edi,%eax
  800eb3:	f7 74 24 08          	divl   0x8(%esp)
  800eb7:	89 d5                	mov    %edx,%ebp
  800eb9:	89 c7                	mov    %eax,%edi
  800ebb:	f7 64 24 0c          	mull   0xc(%esp)
  800ebf:	39 d5                	cmp    %edx,%ebp
  800ec1:	89 14 24             	mov    %edx,(%esp)
  800ec4:	72 11                	jb     800ed7 <__udivdi3+0xc7>
  800ec6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eca:	89 f1                	mov    %esi,%ecx
  800ecc:	d3 e2                	shl    %cl,%edx
  800ece:	39 c2                	cmp    %eax,%edx
  800ed0:	73 5e                	jae    800f30 <__udivdi3+0x120>
  800ed2:	3b 2c 24             	cmp    (%esp),%ebp
  800ed5:	75 59                	jne    800f30 <__udivdi3+0x120>
  800ed7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800eda:	31 f6                	xor    %esi,%esi
  800edc:	89 f2                	mov    %esi,%edx
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	31 f6                	xor    %esi,%esi
  800eea:	31 c0                	xor    %eax,%eax
  800eec:	89 f2                	mov    %esi,%edx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	89 f2                	mov    %esi,%edx
  800efa:	31 f6                	xor    %esi,%esi
  800efc:	89 f8                	mov    %edi,%eax
  800efe:	f7 f1                	div    %ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f14:	76 0b                	jbe    800f21 <__udivdi3+0x111>
  800f16:	31 c0                	xor    %eax,%eax
  800f18:	3b 14 24             	cmp    (%esp),%edx
  800f1b:	0f 83 37 ff ff ff    	jae    800e58 <__udivdi3+0x48>
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	e9 2d ff ff ff       	jmp    800e58 <__udivdi3+0x48>
  800f2b:	90                   	nop
  800f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 f8                	mov    %edi,%eax
  800f32:	31 f6                	xor    %esi,%esi
  800f34:	e9 1f ff ff ff       	jmp    800e58 <__udivdi3+0x48>
  800f39:	66 90                	xchg   %ax,%ax
  800f3b:	66 90                	xchg   %ax,%ax
  800f3d:	66 90                	xchg   %ax,%ax
  800f3f:	90                   	nop

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	83 ec 20             	sub    $0x20,%esp
  800f46:	8b 44 24 34          	mov    0x34(%esp),%eax
  800f4a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f4e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f52:	89 c6                	mov    %eax,%esi
  800f54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f58:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f5c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800f60:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f64:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f68:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	89 c2                	mov    %eax,%edx
  800f70:	75 1e                	jne    800f90 <__umoddi3+0x50>
  800f72:	39 f7                	cmp    %esi,%edi
  800f74:	76 52                	jbe    800fc8 <__umoddi3+0x88>
  800f76:	89 c8                	mov    %ecx,%eax
  800f78:	89 f2                	mov    %esi,%edx
  800f7a:	f7 f7                	div    %edi
  800f7c:	89 d0                	mov    %edx,%eax
  800f7e:	31 d2                	xor    %edx,%edx
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	89 f6                	mov    %esi,%esi
  800f89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f90:	39 f0                	cmp    %esi,%eax
  800f92:	77 5c                	ja     800ff0 <__umoddi3+0xb0>
  800f94:	0f bd e8             	bsr    %eax,%ebp
  800f97:	83 f5 1f             	xor    $0x1f,%ebp
  800f9a:	75 64                	jne    801000 <__umoddi3+0xc0>
  800f9c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800fa0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800fa4:	0f 86 f6 00 00 00    	jbe    8010a0 <__umoddi3+0x160>
  800faa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800fae:	0f 82 ec 00 00 00    	jb     8010a0 <__umoddi3+0x160>
  800fb4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fb8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    
  800fc3:	90                   	nop
  800fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	85 ff                	test   %edi,%edi
  800fca:	89 fd                	mov    %edi,%ebp
  800fcc:	75 0b                	jne    800fd9 <__umoddi3+0x99>
  800fce:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f7                	div    %edi
  800fd7:	89 c5                	mov    %eax,%ebp
  800fd9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	f7 f5                	div    %ebp
  800fe1:	89 c8                	mov    %ecx,%eax
  800fe3:	f7 f5                	div    %ebp
  800fe5:	eb 95                	jmp    800f7c <__umoddi3+0x3c>
  800fe7:	89 f6                	mov    %esi,%esi
  800fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	83 c4 20             	add    $0x20,%esp
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    
  800ffb:	90                   	nop
  800ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801000:	b8 20 00 00 00       	mov    $0x20,%eax
  801005:	89 e9                	mov    %ebp,%ecx
  801007:	29 e8                	sub    %ebp,%eax
  801009:	d3 e2                	shl    %cl,%edx
  80100b:	89 c7                	mov    %eax,%edi
  80100d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801011:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801015:	89 f9                	mov    %edi,%ecx
  801017:	d3 e8                	shr    %cl,%eax
  801019:	89 c1                	mov    %eax,%ecx
  80101b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80101f:	09 d1                	or     %edx,%ecx
  801021:	89 fa                	mov    %edi,%edx
  801023:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801027:	89 e9                	mov    %ebp,%ecx
  801029:	d3 e0                	shl    %cl,%eax
  80102b:	89 f9                	mov    %edi,%ecx
  80102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801031:	89 f0                	mov    %esi,%eax
  801033:	d3 e8                	shr    %cl,%eax
  801035:	89 e9                	mov    %ebp,%ecx
  801037:	89 c7                	mov    %eax,%edi
  801039:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80103d:	d3 e6                	shl    %cl,%esi
  80103f:	89 d1                	mov    %edx,%ecx
  801041:	89 fa                	mov    %edi,%edx
  801043:	d3 e8                	shr    %cl,%eax
  801045:	89 e9                	mov    %ebp,%ecx
  801047:	09 f0                	or     %esi,%eax
  801049:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80104d:	f7 74 24 10          	divl   0x10(%esp)
  801051:	d3 e6                	shl    %cl,%esi
  801053:	89 d1                	mov    %edx,%ecx
  801055:	f7 64 24 0c          	mull   0xc(%esp)
  801059:	39 d1                	cmp    %edx,%ecx
  80105b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80105f:	89 d7                	mov    %edx,%edi
  801061:	89 c6                	mov    %eax,%esi
  801063:	72 0a                	jb     80106f <__umoddi3+0x12f>
  801065:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801069:	73 10                	jae    80107b <__umoddi3+0x13b>
  80106b:	39 d1                	cmp    %edx,%ecx
  80106d:	75 0c                	jne    80107b <__umoddi3+0x13b>
  80106f:	89 d7                	mov    %edx,%edi
  801071:	89 c6                	mov    %eax,%esi
  801073:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801077:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80107b:	89 ca                	mov    %ecx,%edx
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801083:	29 f0                	sub    %esi,%eax
  801085:	19 fa                	sbb    %edi,%edx
  801087:	d3 e8                	shr    %cl,%eax
  801089:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80108e:	89 d7                	mov    %edx,%edi
  801090:	d3 e7                	shl    %cl,%edi
  801092:	89 e9                	mov    %ebp,%ecx
  801094:	09 f8                	or     %edi,%eax
  801096:	d3 ea                	shr    %cl,%edx
  801098:	83 c4 20             	add    $0x20,%esp
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    
  80109f:	90                   	nop
  8010a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a4:	29 f9                	sub    %edi,%ecx
  8010a6:	19 c6                	sbb    %eax,%esi
  8010a8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010ac:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010b0:	e9 ff fe ff ff       	jmp    800fb4 <__umoddi3+0x74>
