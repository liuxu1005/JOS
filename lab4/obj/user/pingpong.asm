
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 89 0d 00 00       	call   800dca <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	74 25                	je     80006f <umain+0x3c>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ac 0a 00 00       	call   800afb <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 40 14 80 00       	push   $0x801440
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 a6 0f 00 00       	call   801012 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 2a 0f 00 00       	call   800fa9 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 14 80 00       	push   $0x801456
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 64 0f 00 00       	call   801012 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000c9:	e8 2d 0a 00 00       	call   800afb <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
  8000fa:	83 c4 10             	add    $0x10,%esp
}
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 a9 09 00 00       	call   800aba <sys_env_destroy>
  800111:	83 c4 10             	add    $0x10,%esp
}
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 37 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 4f 01 00 00       	call   8002db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 dc 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 d1                	mov    %edx,%ecx
  8001d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e8:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001eb:	72 05                	jb     8001f2 <printnum+0x35>
  8001ed:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001f0:	77 3e                	ja     800230 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	ff 75 18             	pushl  0x18(%ebp)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	53                   	push   %ebx
  8001fc:	50                   	push   %eax
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 6f 0f 00 00       	call   801180 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9e ff ff ff       	call   8001bd <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 13                	jmp    800237 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	pushl  0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800230:	83 eb 01             	sub    $0x1,%ebx
  800233:	85 db                	test   %ebx,%ebx
  800235:	7f ed                	jg     800224 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	83 ec 04             	sub    $0x4,%esp
  80023e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800241:	ff 75 e0             	pushl  -0x20(%ebp)
  800244:	ff 75 dc             	pushl  -0x24(%ebp)
  800247:	ff 75 d8             	pushl  -0x28(%ebp)
  80024a:	e8 61 10 00 00       	call   8012b0 <__umoddi3>
  80024f:	83 c4 14             	add    $0x14,%esp
  800252:	0f be 80 73 14 80 00 	movsbl 0x801473(%eax),%eax
  800259:	50                   	push   %eax
  80025a:	ff d7                	call   *%edi
  80025c:	83 c4 10             	add    $0x10,%esp
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026a:	83 fa 01             	cmp    $0x1,%edx
  80026d:	7e 0e                	jle    80027d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	8d 4a 08             	lea    0x8(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 02                	mov    (%edx),%eax
  800278:	8b 52 04             	mov    0x4(%edx),%edx
  80027b:	eb 22                	jmp    80029f <getuint+0x38>
	else if (lflag)
  80027d:	85 d2                	test   %edx,%edx
  80027f:	74 10                	je     800291 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
  80028f:	eb 0e                	jmp    80029f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b0:	73 0a                	jae    8002bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	88 02                	mov    %al,(%edx)
}
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 10             	pushl  0x10(%ebp)
  8002cb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ce:	ff 75 08             	pushl  0x8(%ebp)
  8002d1:	e8 05 00 00 00       	call   8002db <vprintfmt>
	va_end(ap);
  8002d6:	83 c4 10             	add    $0x10,%esp
}
  8002d9:	c9                   	leave  
  8002da:	c3                   	ret    

008002db <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	57                   	push   %edi
  8002df:	56                   	push   %esi
  8002e0:	53                   	push   %ebx
  8002e1:	83 ec 2c             	sub    $0x2c,%esp
  8002e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ea:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ed:	eb 12                	jmp    800301 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ef:	85 c0                	test   %eax,%eax
  8002f1:	0f 84 90 03 00 00    	je     800687 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002f7:	83 ec 08             	sub    $0x8,%esp
  8002fa:	53                   	push   %ebx
  8002fb:	50                   	push   %eax
  8002fc:	ff d6                	call   *%esi
  8002fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800301:	83 c7 01             	add    $0x1,%edi
  800304:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800308:	83 f8 25             	cmp    $0x25,%eax
  80030b:	75 e2                	jne    8002ef <vprintfmt+0x14>
  80030d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800311:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800318:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
  80032b:	eb 07                	jmp    800334 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800330:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8d 47 01             	lea    0x1(%edi),%eax
  800337:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033a:	0f b6 07             	movzbl (%edi),%eax
  80033d:	0f b6 c8             	movzbl %al,%ecx
  800340:	83 e8 23             	sub    $0x23,%eax
  800343:	3c 55                	cmp    $0x55,%al
  800345:	0f 87 21 03 00 00    	ja     80066c <vprintfmt+0x391>
  80034b:	0f b6 c0             	movzbl %al,%eax
  80034e:	ff 24 85 40 15 80 00 	jmp    *0x801540(,%eax,4)
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800358:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035c:	eb d6                	jmp    800334 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800361:	b8 00 00 00 00       	mov    $0x0,%eax
  800366:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800369:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800370:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800373:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800376:	83 fa 09             	cmp    $0x9,%edx
  800379:	77 39                	ja     8003b4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037e:	eb e9                	jmp    800369 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 48 04             	lea    0x4(%eax),%ecx
  800386:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800389:	8b 00                	mov    (%eax),%eax
  80038b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800391:	eb 27                	jmp    8003ba <vprintfmt+0xdf>
  800393:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800396:	85 c0                	test   %eax,%eax
  800398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039d:	0f 49 c8             	cmovns %eax,%ecx
  8003a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a6:	eb 8c                	jmp    800334 <vprintfmt+0x59>
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b2:	eb 80                	jmp    800334 <vprintfmt+0x59>
  8003b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003be:	0f 89 70 ff ff ff    	jns    800334 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d1:	e9 5e ff ff ff       	jmp    800334 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003dc:	e9 53 ff ff ff       	jmp    800334 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	53                   	push   %ebx
  8003ee:	ff 30                	pushl  (%eax)
  8003f0:	ff d6                	call   *%esi
			break;
  8003f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f8:	e9 04 ff ff ff       	jmp    800301 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	8b 00                	mov    (%eax),%eax
  800408:	99                   	cltd   
  800409:	31 d0                	xor    %edx,%eax
  80040b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040d:	83 f8 09             	cmp    $0x9,%eax
  800410:	7f 0b                	jg     80041d <vprintfmt+0x142>
  800412:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  800419:	85 d2                	test   %edx,%edx
  80041b:	75 18                	jne    800435 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80041d:	50                   	push   %eax
  80041e:	68 8b 14 80 00       	push   $0x80148b
  800423:	53                   	push   %ebx
  800424:	56                   	push   %esi
  800425:	e8 94 fe ff ff       	call   8002be <printfmt>
  80042a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800430:	e9 cc fe ff ff       	jmp    800301 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800435:	52                   	push   %edx
  800436:	68 94 14 80 00       	push   $0x801494
  80043b:	53                   	push   %ebx
  80043c:	56                   	push   %esi
  80043d:	e8 7c fe ff ff       	call   8002be <printfmt>
  800442:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800448:	e9 b4 fe ff ff       	jmp    800301 <vprintfmt+0x26>
  80044d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800450:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800453:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800461:	85 ff                	test   %edi,%edi
  800463:	ba 84 14 80 00       	mov    $0x801484,%edx
  800468:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80046b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046f:	0f 84 92 00 00 00    	je     800507 <vprintfmt+0x22c>
  800475:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800479:	0f 8e 96 00 00 00    	jle    800515 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	51                   	push   %ecx
  800483:	57                   	push   %edi
  800484:	e8 86 02 00 00       	call   80070f <strnlen>
  800489:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80048c:	29 c1                	sub    %eax,%ecx
  80048e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800494:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	eb 0f                	jmp    8004b1 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ef 01             	sub    $0x1,%edi
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	7f ed                	jg     8004a2 <vprintfmt+0x1c7>
  8004b5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bb:	85 c9                	test   %ecx,%ecx
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	0f 49 c1             	cmovns %ecx,%eax
  8004c5:	29 c1                	sub    %eax,%ecx
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	89 cb                	mov    %ecx,%ebx
  8004d2:	eb 4d                	jmp    800521 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d8:	74 1b                	je     8004f5 <vprintfmt+0x21a>
  8004da:	0f be c0             	movsbl %al,%eax
  8004dd:	83 e8 20             	sub    $0x20,%eax
  8004e0:	83 f8 5e             	cmp    $0x5e,%eax
  8004e3:	76 10                	jbe    8004f5 <vprintfmt+0x21a>
					putch('?', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	ff 55 08             	call   *0x8(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 0d                	jmp    800502 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	52                   	push   %edx
  8004fc:	ff 55 08             	call   *0x8(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 eb 01             	sub    $0x1,%ebx
  800505:	eb 1a                	jmp    800521 <vprintfmt+0x246>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb 0c                	jmp    800521 <vprintfmt+0x246>
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800521:	83 c7 01             	add    $0x1,%edi
  800524:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800528:	0f be d0             	movsbl %al,%edx
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 23                	je     800552 <vprintfmt+0x277>
  80052f:	85 f6                	test   %esi,%esi
  800531:	78 a1                	js     8004d4 <vprintfmt+0x1f9>
  800533:	83 ee 01             	sub    $0x1,%esi
  800536:	79 9c                	jns    8004d4 <vprintfmt+0x1f9>
  800538:	89 df                	mov    %ebx,%edi
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	eb 18                	jmp    80055a <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb 08                	jmp    80055a <vprintfmt+0x27f>
  800552:	89 df                	mov    %ebx,%edi
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f e4                	jg     800542 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800561:	e9 9b fd ff ff       	jmp    800301 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800566:	83 fa 01             	cmp    $0x1,%edx
  800569:	7e 16                	jle    800581 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 08             	lea    0x8(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 50 04             	mov    0x4(%eax),%edx
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	eb 32                	jmp    8005b3 <vprintfmt+0x2d8>
	else if (lflag)
  800581:	85 d2                	test   %edx,%edx
  800583:	74 18                	je     80059d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	89 c1                	mov    %eax,%ecx
  800595:	c1 f9 1f             	sar    $0x1f,%ecx
  800598:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059b:	eb 16                	jmp    8005b3 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c2:	79 74                	jns    800638 <vprintfmt+0x35d>
				putch('-', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 2d                	push   $0x2d
  8005ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d2:	f7 d8                	neg    %eax
  8005d4:	83 d2 00             	adc    $0x0,%edx
  8005d7:	f7 da                	neg    %edx
  8005d9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e1:	eb 55                	jmp    800638 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 7c fc ff ff       	call   800267 <getuint>
			base = 10;
  8005eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f0:	eb 46                	jmp    800638 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 6d fc ff ff       	call   800267 <getuint>
                        base = 8;
  8005fa:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005ff:	eb 37                	jmp    800638 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 30                	push   $0x30
  800607:	ff d6                	call   *%esi
			putch('x', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 78                	push   $0x78
  80060f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800621:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800624:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 34 fc ff ff       	call   800267 <getuint>
			base = 16;
  800633:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063f:	57                   	push   %edi
  800640:	ff 75 e0             	pushl  -0x20(%ebp)
  800643:	51                   	push   %ecx
  800644:	52                   	push   %edx
  800645:	50                   	push   %eax
  800646:	89 da                	mov    %ebx,%edx
  800648:	89 f0                	mov    %esi,%eax
  80064a:	e8 6e fb ff ff       	call   8001bd <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800655:	e9 a7 fc ff ff       	jmp    800301 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	51                   	push   %ecx
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800667:	e9 95 fc ff ff       	jmp    800301 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 25                	push   $0x25
  800672:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	eb 03                	jmp    80067c <vprintfmt+0x3a1>
  800679:	83 ef 01             	sub    $0x1,%edi
  80067c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800680:	75 f7                	jne    800679 <vprintfmt+0x39e>
  800682:	e9 7a fc ff ff       	jmp    800301 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5f                   	pop    %edi
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    

0080068f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	83 ec 18             	sub    $0x18,%esp
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 26                	je     8006d6 <vsnprintf+0x47>
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	7e 22                	jle    8006d6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b4:	ff 75 14             	pushl  0x14(%ebp)
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	68 a1 02 80 00       	push   $0x8002a1
  8006c3:	e8 13 fc ff ff       	call   8002db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	eb 05                	jmp    8006db <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e6:	50                   	push   %eax
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	ff 75 08             	pushl  0x8(%ebp)
  8006f0:	e8 9a ff ff ff       	call   80068f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	eb 03                	jmp    800707 <strlen+0x10>
		n++;
  800704:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800707:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070b:	75 f7                	jne    800704 <strlen+0xd>
		n++;
	return n;
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800715:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800718:	ba 00 00 00 00       	mov    $0x0,%edx
  80071d:	eb 03                	jmp    800722 <strnlen+0x13>
		n++;
  80071f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800722:	39 c2                	cmp    %eax,%edx
  800724:	74 08                	je     80072e <strnlen+0x1f>
  800726:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80072a:	75 f3                	jne    80071f <strnlen+0x10>
  80072c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073a:	89 c2                	mov    %eax,%edx
  80073c:	83 c2 01             	add    $0x1,%edx
  80073f:	83 c1 01             	add    $0x1,%ecx
  800742:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800746:	88 5a ff             	mov    %bl,-0x1(%edx)
  800749:	84 db                	test   %bl,%bl
  80074b:	75 ef                	jne    80073c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074d:	5b                   	pop    %ebx
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800757:	53                   	push   %ebx
  800758:	e8 9a ff ff ff       	call   8006f7 <strlen>
  80075d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800760:	ff 75 0c             	pushl  0xc(%ebp)
  800763:	01 d8                	add    %ebx,%eax
  800765:	50                   	push   %eax
  800766:	e8 c5 ff ff ff       	call   800730 <strcpy>
	return dst;
}
  80076b:	89 d8                	mov    %ebx,%eax
  80076d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077d:	89 f3                	mov    %esi,%ebx
  80077f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800782:	89 f2                	mov    %esi,%edx
  800784:	eb 0f                	jmp    800795 <strncpy+0x23>
		*dst++ = *src;
  800786:	83 c2 01             	add    $0x1,%edx
  800789:	0f b6 01             	movzbl (%ecx),%eax
  80078c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078f:	80 39 01             	cmpb   $0x1,(%ecx)
  800792:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800795:	39 da                	cmp    %ebx,%edx
  800797:	75 ed                	jne    800786 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800799:	89 f0                	mov    %esi,%eax
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ad:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	74 21                	je     8007d4 <strlcpy+0x35>
  8007b3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b7:	89 f2                	mov    %esi,%edx
  8007b9:	eb 09                	jmp    8007c4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007bb:	83 c2 01             	add    $0x1,%edx
  8007be:	83 c1 01             	add    $0x1,%ecx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c4:	39 c2                	cmp    %eax,%edx
  8007c6:	74 09                	je     8007d1 <strlcpy+0x32>
  8007c8:	0f b6 19             	movzbl (%ecx),%ebx
  8007cb:	84 db                	test   %bl,%bl
  8007cd:	75 ec                	jne    8007bb <strlcpy+0x1c>
  8007cf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d4:	29 f0                	sub    %esi,%eax
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e3:	eb 06                	jmp    8007eb <strcmp+0x11>
		p++, q++;
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007eb:	0f b6 01             	movzbl (%ecx),%eax
  8007ee:	84 c0                	test   %al,%al
  8007f0:	74 04                	je     8007f6 <strcmp+0x1c>
  8007f2:	3a 02                	cmp    (%edx),%al
  8007f4:	74 ef                	je     8007e5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f6:	0f b6 c0             	movzbl %al,%eax
  8007f9:	0f b6 12             	movzbl (%edx),%edx
  8007fc:	29 d0                	sub    %edx,%eax
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	89 c3                	mov    %eax,%ebx
  80080c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080f:	eb 06                	jmp    800817 <strncmp+0x17>
		n--, p++, q++;
  800811:	83 c0 01             	add    $0x1,%eax
  800814:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800817:	39 d8                	cmp    %ebx,%eax
  800819:	74 15                	je     800830 <strncmp+0x30>
  80081b:	0f b6 08             	movzbl (%eax),%ecx
  80081e:	84 c9                	test   %cl,%cl
  800820:	74 04                	je     800826 <strncmp+0x26>
  800822:	3a 0a                	cmp    (%edx),%cl
  800824:	74 eb                	je     800811 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800826:	0f b6 00             	movzbl (%eax),%eax
  800829:	0f b6 12             	movzbl (%edx),%edx
  80082c:	29 d0                	sub    %edx,%eax
  80082e:	eb 05                	jmp    800835 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800842:	eb 07                	jmp    80084b <strchr+0x13>
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	74 0f                	je     800857 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800848:	83 c0 01             	add    $0x1,%eax
  80084b:	0f b6 10             	movzbl (%eax),%edx
  80084e:	84 d2                	test   %dl,%dl
  800850:	75 f2                	jne    800844 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800863:	eb 03                	jmp    800868 <strfind+0xf>
  800865:	83 c0 01             	add    $0x1,%eax
  800868:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80086b:	84 d2                	test   %dl,%dl
  80086d:	74 04                	je     800873 <strfind+0x1a>
  80086f:	38 ca                	cmp    %cl,%dl
  800871:	75 f2                	jne    800865 <strfind+0xc>
			break;
	return (char *) s;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	57                   	push   %edi
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 36                	je     8008bb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800885:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088b:	75 28                	jne    8008b5 <memset+0x40>
  80088d:	f6 c1 03             	test   $0x3,%cl
  800890:	75 23                	jne    8008b5 <memset+0x40>
		c &= 0xFF;
  800892:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800896:	89 d3                	mov    %edx,%ebx
  800898:	c1 e3 08             	shl    $0x8,%ebx
  80089b:	89 d6                	mov    %edx,%esi
  80089d:	c1 e6 18             	shl    $0x18,%esi
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	c1 e0 10             	shl    $0x10,%eax
  8008a5:	09 f0                	or     %esi,%eax
  8008a7:	09 c2                	or     %eax,%edx
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ad:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b0:	fc                   	cld    
  8008b1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b3:	eb 06                	jmp    8008bb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b8:	fc                   	cld    
  8008b9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d0:	39 c6                	cmp    %eax,%esi
  8008d2:	73 35                	jae    800909 <memmove+0x47>
  8008d4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d7:	39 d0                	cmp    %edx,%eax
  8008d9:	73 2e                	jae    800909 <memmove+0x47>
		s += n;
		d += n;
  8008db:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e8:	75 13                	jne    8008fd <memmove+0x3b>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 0e                	jne    8008fd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ef:	83 ef 04             	sub    $0x4,%edi
  8008f2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f8:	fd                   	std    
  8008f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fb:	eb 09                	jmp    800906 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fd:	83 ef 01             	sub    $0x1,%edi
  800900:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	fd                   	std    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800906:	fc                   	cld    
  800907:	eb 1d                	jmp    800926 <memmove+0x64>
  800909:	89 f2                	mov    %esi,%edx
  80090b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	f6 c2 03             	test   $0x3,%dl
  800910:	75 0f                	jne    800921 <memmove+0x5f>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 0a                	jne    800921 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800917:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091a:	89 c7                	mov    %eax,%edi
  80091c:	fc                   	cld    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 05                	jmp    800926 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092d:	ff 75 10             	pushl  0x10(%ebp)
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	ff 75 08             	pushl  0x8(%ebp)
  800936:	e8 87 ff ff ff       	call   8008c2 <memmove>
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	89 c6                	mov    %eax,%esi
  80094a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094d:	eb 1a                	jmp    800969 <memcmp+0x2c>
		if (*s1 != *s2)
  80094f:	0f b6 08             	movzbl (%eax),%ecx
  800952:	0f b6 1a             	movzbl (%edx),%ebx
  800955:	38 d9                	cmp    %bl,%cl
  800957:	74 0a                	je     800963 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800959:	0f b6 c1             	movzbl %cl,%eax
  80095c:	0f b6 db             	movzbl %bl,%ebx
  80095f:	29 d8                	sub    %ebx,%eax
  800961:	eb 0f                	jmp    800972 <memcmp+0x35>
		s1++, s2++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800969:	39 f0                	cmp    %esi,%eax
  80096b:	75 e2                	jne    80094f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097f:	89 c2                	mov    %eax,%edx
  800981:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800984:	eb 07                	jmp    80098d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800986:	38 08                	cmp    %cl,(%eax)
  800988:	74 07                	je     800991 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	39 d0                	cmp    %edx,%eax
  80098f:	72 f5                	jb     800986 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099f:	eb 03                	jmp    8009a4 <strtol+0x11>
		s++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a4:	0f b6 01             	movzbl (%ecx),%eax
  8009a7:	3c 09                	cmp    $0x9,%al
  8009a9:	74 f6                	je     8009a1 <strtol+0xe>
  8009ab:	3c 20                	cmp    $0x20,%al
  8009ad:	74 f2                	je     8009a1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009af:	3c 2b                	cmp    $0x2b,%al
  8009b1:	75 0a                	jne    8009bd <strtol+0x2a>
		s++;
  8009b3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bb:	eb 10                	jmp    8009cd <strtol+0x3a>
  8009bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c2:	3c 2d                	cmp    $0x2d,%al
  8009c4:	75 07                	jne    8009cd <strtol+0x3a>
		s++, neg = 1;
  8009c6:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009c9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cd:	85 db                	test   %ebx,%ebx
  8009cf:	0f 94 c0             	sete   %al
  8009d2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d8:	75 19                	jne    8009f3 <strtol+0x60>
  8009da:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dd:	75 14                	jne    8009f3 <strtol+0x60>
  8009df:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e3:	0f 85 82 00 00 00    	jne    800a6b <strtol+0xd8>
		s += 2, base = 16;
  8009e9:	83 c1 02             	add    $0x2,%ecx
  8009ec:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f1:	eb 16                	jmp    800a09 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009f3:	84 c0                	test   %al,%al
  8009f5:	74 12                	je     800a09 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ff:	75 08                	jne    800a09 <strtol+0x76>
		s++, base = 8;
  800a01:	83 c1 01             	add    $0x1,%ecx
  800a04:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a11:	0f b6 11             	movzbl (%ecx),%edx
  800a14:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	80 fb 09             	cmp    $0x9,%bl
  800a1c:	77 08                	ja     800a26 <strtol+0x93>
			dig = *s - '0';
  800a1e:	0f be d2             	movsbl %dl,%edx
  800a21:	83 ea 30             	sub    $0x30,%edx
  800a24:	eb 22                	jmp    800a48 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a26:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	80 fb 19             	cmp    $0x19,%bl
  800a2e:	77 08                	ja     800a38 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a30:	0f be d2             	movsbl %dl,%edx
  800a33:	83 ea 57             	sub    $0x57,%edx
  800a36:	eb 10                	jmp    800a48 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 19             	cmp    $0x19,%bl
  800a40:	77 16                	ja     800a58 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a48:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4b:	7d 0f                	jge    800a5c <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a54:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a56:	eb b9                	jmp    800a11 <strtol+0x7e>
  800a58:	89 c2                	mov    %eax,%edx
  800a5a:	eb 02                	jmp    800a5e <strtol+0xcb>
  800a5c:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a62:	74 0d                	je     800a71 <strtol+0xde>
		*endptr = (char *) s;
  800a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a67:	89 0e                	mov    %ecx,(%esi)
  800a69:	eb 06                	jmp    800a71 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6b:	84 c0                	test   %al,%al
  800a6d:	75 92                	jne    800a01 <strtol+0x6e>
  800a6f:	eb 98                	jmp    800a09 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a71:	f7 da                	neg    %edx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	0f 45 c2             	cmovne %edx,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 cb                	mov    %ecx,%ebx
  800ad2:	89 cf                	mov    %ecx,%edi
  800ad4:	89 ce                	mov    %ecx,%esi
  800ad6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 03                	push   $0x3
  800ae2:	68 c8 16 80 00       	push   $0x8016c8
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 e5 16 80 00       	push   $0x8016e5
  800aee:	e8 ab 05 00 00       	call   80109e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 04                	push   $0x4
  800b63:	68 c8 16 80 00       	push   $0x8016c8
  800b68:	6a 23                	push   $0x23
  800b6a:	68 e5 16 80 00       	push   $0x8016e5
  800b6f:	e8 2a 05 00 00       	call   80109e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b96:	8b 75 18             	mov    0x18(%ebp),%esi
  800b99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 05                	push   $0x5
  800ba5:	68 c8 16 80 00       	push   $0x8016c8
  800baa:	6a 23                	push   $0x23
  800bac:	68 e5 16 80 00       	push   $0x8016e5
  800bb1:	e8 e8 04 00 00       	call   80109e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 06                	push   $0x6
  800be7:	68 c8 16 80 00       	push   $0x8016c8
  800bec:	6a 23                	push   $0x23
  800bee:	68 e5 16 80 00       	push   $0x8016e5
  800bf3:	e8 a6 04 00 00       	call   80109e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 08                	push   $0x8
  800c29:	68 c8 16 80 00       	push   $0x8016c8
  800c2e:	6a 23                	push   $0x23
  800c30:	68 e5 16 80 00       	push   $0x8016e5
  800c35:	e8 64 04 00 00       	call   80109e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 09                	push   $0x9
  800c6b:	68 c8 16 80 00       	push   $0x8016c8
  800c70:	6a 23                	push   $0x23
  800c72:	68 e5 16 80 00       	push   $0x8016e5
  800c77:	e8 22 04 00 00       	call   80109e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	be 00 00 00 00       	mov    $0x0,%esi
  800c8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 cb                	mov    %ecx,%ebx
  800cbf:	89 cf                	mov    %ecx,%edi
  800cc1:	89 ce                	mov    %ecx,%esi
  800cc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 0c                	push   $0xc
  800ccf:	68 c8 16 80 00       	push   $0x8016c8
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 e5 16 80 00       	push   $0x8016e5
  800cdb:	e8 be 03 00 00       	call   80109e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 04             	sub    $0x4,%esp
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800cf2:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800cf4:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800cf8:	74 2e                	je     800d28 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800cfa:	89 c2                	mov    %eax,%edx
  800cfc:	c1 ea 16             	shr    $0x16,%edx
  800cff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d06:	f6 c2 01             	test   $0x1,%dl
  800d09:	74 1d                	je     800d28 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	c1 ea 0c             	shr    $0xc,%edx
  800d10:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d17:	f6 c1 01             	test   $0x1,%cl
  800d1a:	74 0c                	je     800d28 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d23:	f6 c6 08             	test   $0x8,%dh
  800d26:	75 14                	jne    800d3c <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d28:	83 ec 04             	sub    $0x4,%esp
  800d2b:	68 f4 16 80 00       	push   $0x8016f4
  800d30:	6a 21                	push   $0x21
  800d32:	68 87 17 80 00       	push   $0x801787
  800d37:	e8 62 03 00 00       	call   80109e <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800d3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d41:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	6a 07                	push   $0x7
  800d48:	68 00 f0 7f 00       	push   $0x7ff000
  800d4d:	6a 00                	push   $0x0
  800d4f:	e8 e5 fd ff ff       	call   800b39 <sys_page_alloc>
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 14                	jns    800d6f <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800d5b:	83 ec 04             	sub    $0x4,%esp
  800d5e:	68 92 17 80 00       	push   $0x801792
  800d63:	6a 2b                	push   $0x2b
  800d65:	68 87 17 80 00       	push   $0x801787
  800d6a:	e8 2f 03 00 00       	call   80109e <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	68 00 10 00 00       	push   $0x1000
  800d77:	53                   	push   %ebx
  800d78:	68 00 f0 7f 00       	push   $0x7ff000
  800d7d:	e8 40 fb ff ff       	call   8008c2 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800d82:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d89:	53                   	push   %ebx
  800d8a:	6a 00                	push   $0x0
  800d8c:	68 00 f0 7f 00       	push   $0x7ff000
  800d91:	6a 00                	push   $0x0
  800d93:	e8 e4 fd ff ff       	call   800b7c <sys_page_map>
  800d98:	83 c4 20             	add    $0x20,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	79 14                	jns    800db3 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 a8 17 80 00       	push   $0x8017a8
  800da7:	6a 2e                	push   $0x2e
  800da9:	68 87 17 80 00       	push   $0x801787
  800dae:	e8 eb 02 00 00       	call   80109e <_panic>
        sys_page_unmap(0, PFTEMP); 
  800db3:	83 ec 08             	sub    $0x8,%esp
  800db6:	68 00 f0 7f 00       	push   $0x7ff000
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 fc fd ff ff       	call   800bbe <sys_page_unmap>
  800dc2:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc8:	c9                   	leave  
  800dc9:	c3                   	ret    

00800dca <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800dd3:	68 e8 0c 80 00       	push   $0x800ce8
  800dd8:	e8 07 03 00 00       	call   8010e4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ddd:	b8 07 00 00 00       	mov    $0x7,%eax
  800de2:	cd 30                	int    $0x30
  800de4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	79 12                	jns    800e00 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800dee:	50                   	push   %eax
  800def:	68 bc 17 80 00       	push   $0x8017bc
  800df4:	6a 6d                	push   $0x6d
  800df6:	68 87 17 80 00       	push   $0x801787
  800dfb:	e8 9e 02 00 00       	call   80109e <_panic>
  800e00:	89 c7                	mov    %eax,%edi
  800e02:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e07:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e0b:	75 21                	jne    800e2e <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e0d:	e8 e9 fc ff ff       	call   800afb <sys_getenvid>
  800e12:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e17:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e1a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e1f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e24:	b8 00 00 00 00       	mov    $0x0,%eax
  800e29:	e9 59 01 00 00       	jmp    800f87 <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e2e:	89 d8                	mov    %ebx,%eax
  800e30:	c1 e8 16             	shr    $0x16,%eax
  800e33:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e3a:	a8 01                	test   $0x1,%al
  800e3c:	0f 84 b0 00 00 00    	je     800ef2 <fork+0x128>
  800e42:	89 d8                	mov    %ebx,%eax
  800e44:	c1 e8 0c             	shr    $0xc,%eax
  800e47:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	0f 84 9b 00 00 00    	je     800ef2 <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800e5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e63:	f6 c6 08             	test   $0x8,%dh
  800e66:	75 0b                	jne    800e73 <fork+0xa9>
  800e68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6f:	a8 02                	test   $0x2,%al
  800e71:	74 57                	je     800eca <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	68 05 08 00 00       	push   $0x805
  800e7b:	56                   	push   %esi
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 f7 fc ff ff       	call   800b7c <sys_page_map>
  800e85:	83 c4 20             	add    $0x20,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 12                	jns    800e9e <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800e8c:	50                   	push   %eax
  800e8d:	68 18 17 80 00       	push   $0x801718
  800e92:	6a 4a                	push   $0x4a
  800e94:	68 87 17 80 00       	push   $0x801787
  800e99:	e8 00 02 00 00       	call   80109e <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	68 05 08 00 00       	push   $0x805
  800ea6:	56                   	push   %esi
  800ea7:	6a 00                	push   $0x0
  800ea9:	56                   	push   %esi
  800eaa:	6a 00                	push   $0x0
  800eac:	e8 cb fc ff ff       	call   800b7c <sys_page_map>
  800eb1:	83 c4 20             	add    $0x20,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	79 3a                	jns    800ef2 <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800eb8:	50                   	push   %eax
  800eb9:	68 3c 17 80 00       	push   $0x80173c
  800ebe:	6a 4c                	push   $0x4c
  800ec0:	68 87 17 80 00       	push   $0x801787
  800ec5:	e8 d4 01 00 00       	call   80109e <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	6a 05                	push   $0x5
  800ecf:	56                   	push   %esi
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 a3 fc ff ff       	call   800b7c <sys_page_map>
  800ed9:	83 c4 20             	add    $0x20,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	79 12                	jns    800ef2 <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800ee0:	50                   	push   %eax
  800ee1:	68 64 17 80 00       	push   $0x801764
  800ee6:	6a 4f                	push   $0x4f
  800ee8:	68 87 17 80 00       	push   $0x801787
  800eed:	e8 ac 01 00 00       	call   80109e <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800ef2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ef8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800efe:	0f 85 2a ff ff ff    	jne    800e2e <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	6a 07                	push   $0x7
  800f09:	68 00 f0 bf ee       	push   $0xeebff000
  800f0e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f11:	e8 23 fc ff ff       	call   800b39 <sys_page_alloc>
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 14                	jns    800f31 <fork+0x167>
                panic("user stack alloc failure\n");	
  800f1d:	83 ec 04             	sub    $0x4,%esp
  800f20:	68 cc 17 80 00       	push   $0x8017cc
  800f25:	6a 76                	push   $0x76
  800f27:	68 87 17 80 00       	push   $0x801787
  800f2c:	e8 6d 01 00 00       	call   80109e <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	68 53 11 80 00       	push   $0x801153
  800f39:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3c:	e8 01 fd ff ff       	call   800c42 <sys_env_set_pgfault_upcall>
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 14                	jns    800f5c <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  800f48:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f4b:	68 e6 17 80 00       	push   $0x8017e6
  800f50:	6a 79                	push   $0x79
  800f52:	68 87 17 80 00       	push   $0x801787
  800f57:	e8 42 01 00 00       	call   80109e <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	6a 02                	push   $0x2
  800f61:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f64:	e8 97 fc ff ff       	call   800c00 <sys_env_set_status>
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 14                	jns    800f84 <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  800f70:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f73:	68 03 18 80 00       	push   $0x801803
  800f78:	6a 7b                	push   $0x7b
  800f7a:	68 87 17 80 00       	push   $0x801787
  800f7f:	e8 1a 01 00 00       	call   80109e <_panic>
        return forkid;
  800f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sfork>:

// Challenge!
int
sfork(void)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f95:	68 1a 18 80 00       	push   $0x80181a
  800f9a:	68 83 00 00 00       	push   $0x83
  800f9f:	68 87 17 80 00       	push   $0x801787
  800fa4:	e8 f5 00 00 00       	call   80109e <_panic>

00800fa9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800fbe:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	50                   	push   %eax
  800fc5:	e8 dd fc ff ff       	call   800ca7 <sys_ipc_recv>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 16                	jns    800fe7 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  800fd1:	85 f6                	test   %esi,%esi
  800fd3:	74 06                	je     800fdb <ipc_recv+0x32>
  800fd5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  800fdb:	85 db                	test   %ebx,%ebx
  800fdd:	74 2c                	je     80100b <ipc_recv+0x62>
  800fdf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800fe5:	eb 24                	jmp    80100b <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  800fe7:	85 f6                	test   %esi,%esi
  800fe9:	74 0a                	je     800ff5 <ipc_recv+0x4c>
  800feb:	a1 04 20 80 00       	mov    0x802004,%eax
  800ff0:	8b 40 74             	mov    0x74(%eax),%eax
  800ff3:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  800ff5:	85 db                	test   %ebx,%ebx
  800ff7:	74 0a                	je     801003 <ipc_recv+0x5a>
  800ff9:	a1 04 20 80 00       	mov    0x802004,%eax
  800ffe:	8b 40 78             	mov    0x78(%eax),%eax
  801001:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801003:	a1 04 20 80 00       	mov    0x802004,%eax
  801008:	8b 40 70             	mov    0x70(%eax),%eax
}
  80100b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80101e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801021:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801024:	85 db                	test   %ebx,%ebx
  801026:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80102b:	0f 44 d8             	cmove  %eax,%ebx
  80102e:	eb 1c                	jmp    80104c <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801030:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801033:	74 12                	je     801047 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801035:	50                   	push   %eax
  801036:	68 30 18 80 00       	push   $0x801830
  80103b:	6a 39                	push   $0x39
  80103d:	68 4b 18 80 00       	push   $0x80184b
  801042:	e8 57 00 00 00       	call   80109e <_panic>
                 sys_yield();
  801047:	e8 ce fa ff ff       	call   800b1a <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80104c:	ff 75 14             	pushl  0x14(%ebp)
  80104f:	53                   	push   %ebx
  801050:	56                   	push   %esi
  801051:	57                   	push   %edi
  801052:	e8 2d fc ff ff       	call   800c84 <sys_ipc_try_send>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 d2                	js     801030 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80105e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801071:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801074:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80107a:	8b 52 50             	mov    0x50(%edx),%edx
  80107d:	39 ca                	cmp    %ecx,%edx
  80107f:	75 0d                	jne    80108e <ipc_find_env+0x28>
			return envs[i].env_id;
  801081:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801084:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801089:	8b 40 08             	mov    0x8(%eax),%eax
  80108c:	eb 0e                	jmp    80109c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80108e:	83 c0 01             	add    $0x1,%eax
  801091:	3d 00 04 00 00       	cmp    $0x400,%eax
  801096:	75 d9                	jne    801071 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801098:	66 b8 00 00          	mov    $0x0,%ax
}
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010a3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010a6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010ac:	e8 4a fa ff ff       	call   800afb <sys_getenvid>
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	ff 75 0c             	pushl  0xc(%ebp)
  8010b7:	ff 75 08             	pushl  0x8(%ebp)
  8010ba:	56                   	push   %esi
  8010bb:	50                   	push   %eax
  8010bc:	68 58 18 80 00       	push   $0x801858
  8010c1:	e8 e3 f0 ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010c6:	83 c4 18             	add    $0x18,%esp
  8010c9:	53                   	push   %ebx
  8010ca:	ff 75 10             	pushl  0x10(%ebp)
  8010cd:	e8 86 f0 ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  8010d2:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  8010d9:	e8 cb f0 ff ff       	call   8001a9 <cprintf>
  8010de:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e1:	cc                   	int3   
  8010e2:	eb fd                	jmp    8010e1 <_panic+0x43>

008010e4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010ea:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010f1:	75 2c                	jne    80111f <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	6a 07                	push   $0x7
  8010f8:	68 00 f0 bf ee       	push   $0xeebff000
  8010fd:	6a 00                	push   $0x0
  8010ff:	e8 35 fa ff ff       	call   800b39 <sys_page_alloc>
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	74 14                	je     80111f <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  80110b:	83 ec 04             	sub    $0x4,%esp
  80110e:	68 7c 18 80 00       	push   $0x80187c
  801113:	6a 21                	push   $0x21
  801115:	68 e0 18 80 00       	push   $0x8018e0
  80111a:	e8 7f ff ff ff       	call   80109e <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801127:	83 ec 08             	sub    $0x8,%esp
  80112a:	68 53 11 80 00       	push   $0x801153
  80112f:	6a 00                	push   $0x0
  801131:	e8 0c fb ff ff       	call   800c42 <sys_env_set_pgfault_upcall>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	79 14                	jns    801151 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	68 a8 18 80 00       	push   $0x8018a8
  801145:	6a 29                	push   $0x29
  801147:	68 e0 18 80 00       	push   $0x8018e0
  80114c:	e8 4d ff ff ff       	call   80109e <_panic>
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801153:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801154:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801159:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80115b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80115e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801163:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801167:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80116b:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80116d:	83 c4 08             	add    $0x8,%esp
        popal
  801170:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801171:	83 c4 04             	add    $0x4,%esp
        popfl
  801174:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801175:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801176:	c3                   	ret    
  801177:	66 90                	xchg   %ax,%ax
  801179:	66 90                	xchg   %ax,%ax
  80117b:	66 90                	xchg   %ax,%ax
  80117d:	66 90                	xchg   %ax,%ax
  80117f:	90                   	nop

00801180 <__udivdi3>:
  801180:	55                   	push   %ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	83 ec 10             	sub    $0x10,%esp
  801186:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80118a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80118e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801192:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801196:	85 d2                	test   %edx,%edx
  801198:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80119c:	89 34 24             	mov    %esi,(%esp)
  80119f:	89 c8                	mov    %ecx,%eax
  8011a1:	75 35                	jne    8011d8 <__udivdi3+0x58>
  8011a3:	39 f1                	cmp    %esi,%ecx
  8011a5:	0f 87 bd 00 00 00    	ja     801268 <__udivdi3+0xe8>
  8011ab:	85 c9                	test   %ecx,%ecx
  8011ad:	89 cd                	mov    %ecx,%ebp
  8011af:	75 0b                	jne    8011bc <__udivdi3+0x3c>
  8011b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	f7 f1                	div    %ecx
  8011ba:	89 c5                	mov    %eax,%ebp
  8011bc:	89 f0                	mov    %esi,%eax
  8011be:	31 d2                	xor    %edx,%edx
  8011c0:	f7 f5                	div    %ebp
  8011c2:	89 c6                	mov    %eax,%esi
  8011c4:	89 f8                	mov    %edi,%eax
  8011c6:	f7 f5                	div    %ebp
  8011c8:	89 f2                	mov    %esi,%edx
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    
  8011d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	3b 14 24             	cmp    (%esp),%edx
  8011db:	77 7b                	ja     801258 <__udivdi3+0xd8>
  8011dd:	0f bd f2             	bsr    %edx,%esi
  8011e0:	83 f6 1f             	xor    $0x1f,%esi
  8011e3:	0f 84 97 00 00 00    	je     801280 <__udivdi3+0x100>
  8011e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8011ee:	89 d7                	mov    %edx,%edi
  8011f0:	89 f1                	mov    %esi,%ecx
  8011f2:	29 f5                	sub    %esi,%ebp
  8011f4:	d3 e7                	shl    %cl,%edi
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	89 e9                	mov    %ebp,%ecx
  8011fa:	d3 ea                	shr    %cl,%edx
  8011fc:	89 f1                	mov    %esi,%ecx
  8011fe:	09 fa                	or     %edi,%edx
  801200:	8b 3c 24             	mov    (%esp),%edi
  801203:	d3 e0                	shl    %cl,%eax
  801205:	89 54 24 08          	mov    %edx,0x8(%esp)
  801209:	89 e9                	mov    %ebp,%ecx
  80120b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801213:	89 fa                	mov    %edi,%edx
  801215:	d3 ea                	shr    %cl,%edx
  801217:	89 f1                	mov    %esi,%ecx
  801219:	d3 e7                	shl    %cl,%edi
  80121b:	89 e9                	mov    %ebp,%ecx
  80121d:	d3 e8                	shr    %cl,%eax
  80121f:	09 c7                	or     %eax,%edi
  801221:	89 f8                	mov    %edi,%eax
  801223:	f7 74 24 08          	divl   0x8(%esp)
  801227:	89 d5                	mov    %edx,%ebp
  801229:	89 c7                	mov    %eax,%edi
  80122b:	f7 64 24 0c          	mull   0xc(%esp)
  80122f:	39 d5                	cmp    %edx,%ebp
  801231:	89 14 24             	mov    %edx,(%esp)
  801234:	72 11                	jb     801247 <__udivdi3+0xc7>
  801236:	8b 54 24 04          	mov    0x4(%esp),%edx
  80123a:	89 f1                	mov    %esi,%ecx
  80123c:	d3 e2                	shl    %cl,%edx
  80123e:	39 c2                	cmp    %eax,%edx
  801240:	73 5e                	jae    8012a0 <__udivdi3+0x120>
  801242:	3b 2c 24             	cmp    (%esp),%ebp
  801245:	75 59                	jne    8012a0 <__udivdi3+0x120>
  801247:	8d 47 ff             	lea    -0x1(%edi),%eax
  80124a:	31 f6                	xor    %esi,%esi
  80124c:	89 f2                	mov    %esi,%edx
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    
  801255:	8d 76 00             	lea    0x0(%esi),%esi
  801258:	31 f6                	xor    %esi,%esi
  80125a:	31 c0                	xor    %eax,%eax
  80125c:	89 f2                	mov    %esi,%edx
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    
  801265:	8d 76 00             	lea    0x0(%esi),%esi
  801268:	89 f2                	mov    %esi,%edx
  80126a:	31 f6                	xor    %esi,%esi
  80126c:	89 f8                	mov    %edi,%eax
  80126e:	f7 f1                	div    %ecx
  801270:	89 f2                	mov    %esi,%edx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	5e                   	pop    %esi
  801276:	5f                   	pop    %edi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801284:	76 0b                	jbe    801291 <__udivdi3+0x111>
  801286:	31 c0                	xor    %eax,%eax
  801288:	3b 14 24             	cmp    (%esp),%edx
  80128b:	0f 83 37 ff ff ff    	jae    8011c8 <__udivdi3+0x48>
  801291:	b8 01 00 00 00       	mov    $0x1,%eax
  801296:	e9 2d ff ff ff       	jmp    8011c8 <__udivdi3+0x48>
  80129b:	90                   	nop
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	89 f8                	mov    %edi,%eax
  8012a2:	31 f6                	xor    %esi,%esi
  8012a4:	e9 1f ff ff ff       	jmp    8011c8 <__udivdi3+0x48>
  8012a9:	66 90                	xchg   %ax,%ax
  8012ab:	66 90                	xchg   %ax,%ax
  8012ad:	66 90                	xchg   %ax,%ax
  8012af:	90                   	nop

008012b0 <__umoddi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	83 ec 20             	sub    $0x20,%esp
  8012b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8012ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012c2:	89 c6                	mov    %eax,%esi
  8012c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8012d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8012d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	75 1e                	jne    801300 <__umoddi3+0x50>
  8012e2:	39 f7                	cmp    %esi,%edi
  8012e4:	76 52                	jbe    801338 <__umoddi3+0x88>
  8012e6:	89 c8                	mov    %ecx,%eax
  8012e8:	89 f2                	mov    %esi,%edx
  8012ea:	f7 f7                	div    %edi
  8012ec:	89 d0                	mov    %edx,%eax
  8012ee:	31 d2                	xor    %edx,%edx
  8012f0:	83 c4 20             	add    $0x20,%esp
  8012f3:	5e                   	pop    %esi
  8012f4:	5f                   	pop    %edi
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    
  8012f7:	89 f6                	mov    %esi,%esi
  8012f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801300:	39 f0                	cmp    %esi,%eax
  801302:	77 5c                	ja     801360 <__umoddi3+0xb0>
  801304:	0f bd e8             	bsr    %eax,%ebp
  801307:	83 f5 1f             	xor    $0x1f,%ebp
  80130a:	75 64                	jne    801370 <__umoddi3+0xc0>
  80130c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801310:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801314:	0f 86 f6 00 00 00    	jbe    801410 <__umoddi3+0x160>
  80131a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80131e:	0f 82 ec 00 00 00    	jb     801410 <__umoddi3+0x160>
  801324:	8b 44 24 14          	mov    0x14(%esp),%eax
  801328:	8b 54 24 18          	mov    0x18(%esp),%edx
  80132c:	83 c4 20             	add    $0x20,%esp
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	90                   	nop
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	85 ff                	test   %edi,%edi
  80133a:	89 fd                	mov    %edi,%ebp
  80133c:	75 0b                	jne    801349 <__umoddi3+0x99>
  80133e:	b8 01 00 00 00       	mov    $0x1,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f7                	div    %edi
  801347:	89 c5                	mov    %eax,%ebp
  801349:	8b 44 24 10          	mov    0x10(%esp),%eax
  80134d:	31 d2                	xor    %edx,%edx
  80134f:	f7 f5                	div    %ebp
  801351:	89 c8                	mov    %ecx,%eax
  801353:	f7 f5                	div    %ebp
  801355:	eb 95                	jmp    8012ec <__umoddi3+0x3c>
  801357:	89 f6                	mov    %esi,%esi
  801359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	83 c4 20             	add    $0x20,%esp
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    
  80136b:	90                   	nop
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	b8 20 00 00 00       	mov    $0x20,%eax
  801375:	89 e9                	mov    %ebp,%ecx
  801377:	29 e8                	sub    %ebp,%eax
  801379:	d3 e2                	shl    %cl,%edx
  80137b:	89 c7                	mov    %eax,%edi
  80137d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801381:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801385:	89 f9                	mov    %edi,%ecx
  801387:	d3 e8                	shr    %cl,%eax
  801389:	89 c1                	mov    %eax,%ecx
  80138b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80138f:	09 d1                	or     %edx,%ecx
  801391:	89 fa                	mov    %edi,%edx
  801393:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801397:	89 e9                	mov    %ebp,%ecx
  801399:	d3 e0                	shl    %cl,%eax
  80139b:	89 f9                	mov    %edi,%ecx
  80139d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a1:	89 f0                	mov    %esi,%eax
  8013a3:	d3 e8                	shr    %cl,%eax
  8013a5:	89 e9                	mov    %ebp,%ecx
  8013a7:	89 c7                	mov    %eax,%edi
  8013a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013ad:	d3 e6                	shl    %cl,%esi
  8013af:	89 d1                	mov    %edx,%ecx
  8013b1:	89 fa                	mov    %edi,%edx
  8013b3:	d3 e8                	shr    %cl,%eax
  8013b5:	89 e9                	mov    %ebp,%ecx
  8013b7:	09 f0                	or     %esi,%eax
  8013b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8013bd:	f7 74 24 10          	divl   0x10(%esp)
  8013c1:	d3 e6                	shl    %cl,%esi
  8013c3:	89 d1                	mov    %edx,%ecx
  8013c5:	f7 64 24 0c          	mull   0xc(%esp)
  8013c9:	39 d1                	cmp    %edx,%ecx
  8013cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8013cf:	89 d7                	mov    %edx,%edi
  8013d1:	89 c6                	mov    %eax,%esi
  8013d3:	72 0a                	jb     8013df <__umoddi3+0x12f>
  8013d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8013d9:	73 10                	jae    8013eb <__umoddi3+0x13b>
  8013db:	39 d1                	cmp    %edx,%ecx
  8013dd:	75 0c                	jne    8013eb <__umoddi3+0x13b>
  8013df:	89 d7                	mov    %edx,%edi
  8013e1:	89 c6                	mov    %eax,%esi
  8013e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8013e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8013eb:	89 ca                	mov    %ecx,%edx
  8013ed:	89 e9                	mov    %ebp,%ecx
  8013ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8013f3:	29 f0                	sub    %esi,%eax
  8013f5:	19 fa                	sbb    %edi,%edx
  8013f7:	d3 e8                	shr    %cl,%eax
  8013f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8013fe:	89 d7                	mov    %edx,%edi
  801400:	d3 e7                	shl    %cl,%edi
  801402:	89 e9                	mov    %ebp,%ecx
  801404:	09 f8                	or     %edi,%eax
  801406:	d3 ea                	shr    %cl,%edx
  801408:	83 c4 20             	add    $0x20,%esp
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    
  80140f:	90                   	nop
  801410:	8b 74 24 10          	mov    0x10(%esp),%esi
  801414:	29 f9                	sub    %edi,%ecx
  801416:	19 c6                	sbb    %eax,%esi
  801418:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80141c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801420:	e9 ff fe ff ff       	jmp    801324 <__umoddi3+0x74>
