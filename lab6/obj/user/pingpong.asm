
obj/user/pingpong.debug:     file format elf32-i386


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
  80003c:	e8 74 0e 00 00       	call   800eb5 <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	74 25                	je     80006f <umain+0x3c>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 b4 0a 00 00       	call   800b03 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 40 27 80 00       	push   $0x802740
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 d4 10 00 00       	call   801140 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 58 10 00 00       	call   8010d7 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 7a 0a 00 00       	call   800b03 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 27 80 00       	push   $0x802756
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
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
  8000a9:	e8 92 10 00 00       	call   801140 <ipc_send>
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
  8000c9:	e8 35 0a 00 00       	call   800b03 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 8f 12 00 00       	call   80139e <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a9 09 00 00       	call   800ac2 <sys_env_destroy>
  800119:	83 c4 10             	add    $0x10,%esp
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 37 09 00 00       	call   800a85 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 4f 01 00 00       	call   8002e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 dc 08 00 00       	call   800a85 <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 d1                	mov    %edx,%ecx
  8001da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f0:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001f3:	72 05                	jb     8001fa <printnum+0x35>
  8001f5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001f8:	77 3e                	ja     800238 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	53                   	push   %ebx
  800204:	50                   	push   %eax
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 57 22 00 00       	call   802470 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 13                	jmp    80023f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	7f ed                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	83 ec 04             	sub    $0x4,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 49 23 00 00       	call   8025a0 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 73 27 80 00 	movsbl 0x802773(%eax),%eax
  800261:	50                   	push   %eax
  800262:	ff d7                	call   *%edi
  800264:	83 c4 10             	add    $0x10,%esp
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
	else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	50                   	push   %eax
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 05 00 00 00       	call   8002e3 <vprintfmt>
	va_end(ap);
  8002de:	83 c4 10             	add    $0x10,%esp
}
  8002e1:	c9                   	leave  
  8002e2:	c3                   	ret    

008002e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 2c             	sub    $0x2c,%esp
  8002ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f5:	eb 12                	jmp    800309 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	0f 84 90 03 00 00    	je     80068f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	53                   	push   %ebx
  800303:	50                   	push   %eax
  800304:	ff d6                	call   *%esi
  800306:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	83 c7 01             	add    $0x1,%edi
  80030c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800310:	83 f8 25             	cmp    $0x25,%eax
  800313:	75 e2                	jne    8002f7 <vprintfmt+0x14>
  800315:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800319:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800320:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	eb 07                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800338:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8d 47 01             	lea    0x1(%edi),%eax
  80033f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800342:	0f b6 07             	movzbl (%edi),%eax
  800345:	0f b6 c8             	movzbl %al,%ecx
  800348:	83 e8 23             	sub    $0x23,%eax
  80034b:	3c 55                	cmp    $0x55,%al
  80034d:	0f 87 21 03 00 00    	ja     800674 <vprintfmt+0x391>
  800353:	0f b6 c0             	movzbl %al,%eax
  800356:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800364:	eb d6                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037e:	83 fa 09             	cmp    $0x9,%edx
  800381:	77 39                	ja     8003bc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb e9                	jmp    800371 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 48 04             	lea    0x4(%eax),%ecx
  80038e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800391:	8b 00                	mov    (%eax),%eax
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800399:	eb 27                	jmp    8003c2 <vprintfmt+0xdf>
  80039b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	0f 49 c8             	cmovns %eax,%ecx
  8003a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	eb 8c                	jmp    80033c <vprintfmt+0x59>
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ba:	eb 80                	jmp    80033c <vprintfmt+0x59>
  8003bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c6:	0f 89 70 ff ff ff    	jns    80033c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d9:	e9 5e ff ff ff       	jmp    80033c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003de:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e4:	e9 53 ff ff ff       	jmp    80033c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	53                   	push   %ebx
  8003f6:	ff 30                	pushl  (%eax)
  8003f8:	ff d6                	call   *%esi
			break;
  8003fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800400:	e9 04 ff ff ff       	jmp    800309 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	99                   	cltd   
  800411:	31 d0                	xor    %edx,%eax
  800413:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800415:	83 f8 0f             	cmp    $0xf,%eax
  800418:	7f 0b                	jg     800425 <vprintfmt+0x142>
  80041a:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	75 18                	jne    80043d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800425:	50                   	push   %eax
  800426:	68 8b 27 80 00       	push   $0x80278b
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 94 fe ff ff       	call   8002c6 <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800438:	e9 cc fe ff ff       	jmp    800309 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043d:	52                   	push   %edx
  80043e:	68 d9 2c 80 00       	push   $0x802cd9
  800443:	53                   	push   %ebx
  800444:	56                   	push   %esi
  800445:	e8 7c fe ff ff       	call   8002c6 <printfmt>
  80044a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800450:	e9 b4 fe ff ff       	jmp    800309 <vprintfmt+0x26>
  800455:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800469:	85 ff                	test   %edi,%edi
  80046b:	ba 84 27 80 00       	mov    $0x802784,%edx
  800470:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800473:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800477:	0f 84 92 00 00 00    	je     80050f <vprintfmt+0x22c>
  80047d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800481:	0f 8e 96 00 00 00    	jle    80051d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	51                   	push   %ecx
  80048b:	57                   	push   %edi
  80048c:	e8 86 02 00 00       	call   800717 <strnlen>
  800491:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	eb 0f                	jmp    8004b9 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ef 01             	sub    $0x1,%edi
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	7f ed                	jg     8004aa <vprintfmt+0x1c7>
  8004bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c3:	85 c9                	test   %ecx,%ecx
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	0f 49 c1             	cmovns %ecx,%eax
  8004cd:	29 c1                	sub    %eax,%ecx
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	89 cb                	mov    %ecx,%ebx
  8004da:	eb 4d                	jmp    800529 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e0:	74 1b                	je     8004fd <vprintfmt+0x21a>
  8004e2:	0f be c0             	movsbl %al,%eax
  8004e5:	83 e8 20             	sub    $0x20,%eax
  8004e8:	83 f8 5e             	cmp    $0x5e,%eax
  8004eb:	76 10                	jbe    8004fd <vprintfmt+0x21a>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 0d                	jmp    80050a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	52                   	push   %edx
  800504:	ff 55 08             	call   *0x8(%ebp)
  800507:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	83 eb 01             	sub    $0x1,%ebx
  80050d:	eb 1a                	jmp    800529 <vprintfmt+0x246>
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051b:	eb 0c                	jmp    800529 <vprintfmt+0x246>
  80051d:	89 75 08             	mov    %esi,0x8(%ebp)
  800520:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800523:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800526:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800530:	0f be d0             	movsbl %al,%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	74 23                	je     80055a <vprintfmt+0x277>
  800537:	85 f6                	test   %esi,%esi
  800539:	78 a1                	js     8004dc <vprintfmt+0x1f9>
  80053b:	83 ee 01             	sub    $0x1,%esi
  80053e:	79 9c                	jns    8004dc <vprintfmt+0x1f9>
  800540:	89 df                	mov    %ebx,%edi
  800542:	8b 75 08             	mov    0x8(%ebp),%esi
  800545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800548:	eb 18                	jmp    800562 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 20                	push   $0x20
  800550:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	83 ef 01             	sub    $0x1,%edi
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	eb 08                	jmp    800562 <vprintfmt+0x27f>
  80055a:	89 df                	mov    %ebx,%edi
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800562:	85 ff                	test   %edi,%edi
  800564:	7f e4                	jg     80054a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800569:	e9 9b fd ff ff       	jmp    800309 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056e:	83 fa 01             	cmp    $0x1,%edx
  800571:	7e 16                	jle    800589 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 08             	lea    0x8(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 50 04             	mov    0x4(%eax),%edx
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	eb 32                	jmp    8005bb <vprintfmt+0x2d8>
	else if (lflag)
  800589:	85 d2                	test   %edx,%edx
  80058b:	74 18                	je     8005a5 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 c1                	mov    %eax,%ecx
  80059d:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a3:	eb 16                	jmp    8005bb <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 c1                	mov    %eax,%ecx
  8005b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ca:	79 74                	jns    800640 <vprintfmt+0x35d>
				putch('-', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 2d                	push   $0x2d
  8005d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005da:	f7 d8                	neg    %eax
  8005dc:	83 d2 00             	adc    $0x0,%edx
  8005df:	f7 da                	neg    %edx
  8005e1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e9:	eb 55                	jmp    800640 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 7c fc ff ff       	call   80026f <getuint>
			base = 10;
  8005f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f8:	eb 46                	jmp    800640 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 6d fc ff ff       	call   80026f <getuint>
                        base = 8;
  800602:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800607:	eb 37                	jmp    800640 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 30                	push   $0x30
  80060f:	ff d6                	call   *%esi
			putch('x', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 78                	push   $0x78
  800617:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800629:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 34 fc ff ff       	call   80026f <getuint>
			base = 16;
  80063b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800647:	57                   	push   %edi
  800648:	ff 75 e0             	pushl  -0x20(%ebp)
  80064b:	51                   	push   %ecx
  80064c:	52                   	push   %edx
  80064d:	50                   	push   %eax
  80064e:	89 da                	mov    %ebx,%edx
  800650:	89 f0                	mov    %esi,%eax
  800652:	e8 6e fb ff ff       	call   8001c5 <printnum>
			break;
  800657:	83 c4 20             	add    $0x20,%esp
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065d:	e9 a7 fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	51                   	push   %ecx
  800667:	ff d6                	call   *%esi
			break;
  800669:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066f:	e9 95 fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 25                	push   $0x25
  80067a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	eb 03                	jmp    800684 <vprintfmt+0x3a1>
  800681:	83 ef 01             	sub    $0x1,%edi
  800684:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800688:	75 f7                	jne    800681 <vprintfmt+0x39e>
  80068a:	e9 7a fc ff ff       	jmp    800309 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800692:	5b                   	pop    %ebx
  800693:	5e                   	pop    %esi
  800694:	5f                   	pop    %edi
  800695:	5d                   	pop    %ebp
  800696:	c3                   	ret    

00800697 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 18             	sub    $0x18,%esp
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 26                	je     8006de <vsnprintf+0x47>
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	7e 22                	jle    8006de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bc:	ff 75 14             	pushl  0x14(%ebp)
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c5:	50                   	push   %eax
  8006c6:	68 a9 02 80 00       	push   $0x8002a9
  8006cb:	e8 13 fc ff ff       	call   8002e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb 05                	jmp    8006e3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ee:	50                   	push   %eax
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	ff 75 08             	pushl  0x8(%ebp)
  8006f8:	e8 9a ff ff ff       	call   800697 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800705:	b8 00 00 00 00       	mov    $0x0,%eax
  80070a:	eb 03                	jmp    80070f <strlen+0x10>
		n++;
  80070c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800713:	75 f7                	jne    80070c <strlen+0xd>
		n++;
	return n;
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
  800725:	eb 03                	jmp    80072a <strnlen+0x13>
		n++;
  800727:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072a:	39 c2                	cmp    %eax,%edx
  80072c:	74 08                	je     800736 <strnlen+0x1f>
  80072e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800732:	75 f3                	jne    800727 <strnlen+0x10>
  800734:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800742:	89 c2                	mov    %eax,%edx
  800744:	83 c2 01             	add    $0x1,%edx
  800747:	83 c1 01             	add    $0x1,%ecx
  80074a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800751:	84 db                	test   %bl,%bl
  800753:	75 ef                	jne    800744 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800755:	5b                   	pop    %ebx
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075f:	53                   	push   %ebx
  800760:	e8 9a ff ff ff       	call   8006ff <strlen>
  800765:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800768:	ff 75 0c             	pushl  0xc(%ebp)
  80076b:	01 d8                	add    %ebx,%eax
  80076d:	50                   	push   %eax
  80076e:	e8 c5 ff ff ff       	call   800738 <strcpy>
	return dst;
}
  800773:	89 d8                	mov    %ebx,%eax
  800775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	56                   	push   %esi
  80077e:	53                   	push   %ebx
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800785:	89 f3                	mov    %esi,%ebx
  800787:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078a:	89 f2                	mov    %esi,%edx
  80078c:	eb 0f                	jmp    80079d <strncpy+0x23>
		*dst++ = *src;
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	0f b6 01             	movzbl (%ecx),%eax
  800794:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800797:	80 39 01             	cmpb   $0x1,(%ecx)
  80079a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	39 da                	cmp    %ebx,%edx
  80079f:	75 ed                	jne    80078e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	74 21                	je     8007dc <strlcpy+0x35>
  8007bb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bf:	89 f2                	mov    %esi,%edx
  8007c1:	eb 09                	jmp    8007cc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cc:	39 c2                	cmp    %eax,%edx
  8007ce:	74 09                	je     8007d9 <strlcpy+0x32>
  8007d0:	0f b6 19             	movzbl (%ecx),%ebx
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ec                	jne    8007c3 <strlcpy+0x1c>
  8007d7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dc:	29 f0                	sub    %esi,%eax
}
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007eb:	eb 06                	jmp    8007f3 <strcmp+0x11>
		p++, q++;
  8007ed:	83 c1 01             	add    $0x1,%ecx
  8007f0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 04                	je     8007fe <strcmp+0x1c>
  8007fa:	3a 02                	cmp    (%edx),%al
  8007fc:	74 ef                	je     8007ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 c0             	movzbl %al,%eax
  800801:	0f b6 12             	movzbl (%edx),%edx
  800804:	29 d0                	sub    %edx,%eax
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	89 c3                	mov    %eax,%ebx
  800814:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800817:	eb 06                	jmp    80081f <strncmp+0x17>
		n--, p++, q++;
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081f:	39 d8                	cmp    %ebx,%eax
  800821:	74 15                	je     800838 <strncmp+0x30>
  800823:	0f b6 08             	movzbl (%eax),%ecx
  800826:	84 c9                	test   %cl,%cl
  800828:	74 04                	je     80082e <strncmp+0x26>
  80082a:	3a 0a                	cmp    (%edx),%cl
  80082c:	74 eb                	je     800819 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 00             	movzbl (%eax),%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
  800836:	eb 05                	jmp    80083d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083d:	5b                   	pop    %ebx
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084a:	eb 07                	jmp    800853 <strchr+0x13>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 0f                	je     80085f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	0f b6 10             	movzbl (%eax),%edx
  800856:	84 d2                	test   %dl,%dl
  800858:	75 f2                	jne    80084c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 03                	jmp    800870 <strfind+0xf>
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800873:	84 d2                	test   %dl,%dl
  800875:	74 04                	je     80087b <strfind+0x1a>
  800877:	38 ca                	cmp    %cl,%dl
  800879:	75 f2                	jne    80086d <strfind+0xc>
			break;
	return (char *) s;
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 7d 08             	mov    0x8(%ebp),%edi
  800886:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 36                	je     8008c3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800893:	75 28                	jne    8008bd <memset+0x40>
  800895:	f6 c1 03             	test   $0x3,%cl
  800898:	75 23                	jne    8008bd <memset+0x40>
		c &= 0xFF;
  80089a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089e:	89 d3                	mov    %edx,%ebx
  8008a0:	c1 e3 08             	shl    $0x8,%ebx
  8008a3:	89 d6                	mov    %edx,%esi
  8008a5:	c1 e6 18             	shl    $0x18,%esi
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	c1 e0 10             	shl    $0x10,%eax
  8008ad:	09 f0                	or     %esi,%eax
  8008af:	09 c2                	or     %eax,%edx
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b8:	fc                   	cld    
  8008b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bb:	eb 06                	jmp    8008c3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	fc                   	cld    
  8008c1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d8:	39 c6                	cmp    %eax,%esi
  8008da:	73 35                	jae    800911 <memmove+0x47>
  8008dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008df:	39 d0                	cmp    %edx,%eax
  8008e1:	73 2e                	jae    800911 <memmove+0x47>
		s += n;
		d += n;
  8008e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f0:	75 13                	jne    800905 <memmove+0x3b>
  8008f2:	f6 c1 03             	test   $0x3,%cl
  8008f5:	75 0e                	jne    800905 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f7:	83 ef 04             	sub    $0x4,%edi
  8008fa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800900:	fd                   	std    
  800901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800903:	eb 09                	jmp    80090e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800905:	83 ef 01             	sub    $0x1,%edi
  800908:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090b:	fd                   	std    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090e:	fc                   	cld    
  80090f:	eb 1d                	jmp    80092e <memmove+0x64>
  800911:	89 f2                	mov    %esi,%edx
  800913:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	f6 c2 03             	test   $0x3,%dl
  800918:	75 0f                	jne    800929 <memmove+0x5f>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 0a                	jne    800929 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800922:	89 c7                	mov    %eax,%edi
  800924:	fc                   	cld    
  800925:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800927:	eb 05                	jmp    80092e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	ff 75 0c             	pushl  0xc(%ebp)
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 87 ff ff ff       	call   8008ca <memmove>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c6                	mov    %eax,%esi
  800952:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800955:	eb 1a                	jmp    800971 <memcmp+0x2c>
		if (*s1 != *s2)
  800957:	0f b6 08             	movzbl (%eax),%ecx
  80095a:	0f b6 1a             	movzbl (%edx),%ebx
  80095d:	38 d9                	cmp    %bl,%cl
  80095f:	74 0a                	je     80096b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c1             	movzbl %cl,%eax
  800964:	0f b6 db             	movzbl %bl,%ebx
  800967:	29 d8                	sub    %ebx,%eax
  800969:	eb 0f                	jmp    80097a <memcmp+0x35>
		s1++, s2++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	39 f0                	cmp    %esi,%eax
  800973:	75 e2                	jne    800957 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800987:	89 c2                	mov    %eax,%edx
  800989:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098c:	eb 07                	jmp    800995 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	38 08                	cmp    %cl,(%eax)
  800990:	74 07                	je     800999 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	39 d0                	cmp    %edx,%eax
  800997:	72 f5                	jb     80098e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	eb 03                	jmp    8009ac <strtol+0x11>
		s++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	3c 09                	cmp    $0x9,%al
  8009b1:	74 f6                	je     8009a9 <strtol+0xe>
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f2                	je     8009a9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b7:	3c 2b                	cmp    $0x2b,%al
  8009b9:	75 0a                	jne    8009c5 <strtol+0x2a>
		s++;
  8009bb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	eb 10                	jmp    8009d5 <strtol+0x3a>
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ca:	3c 2d                	cmp    $0x2d,%al
  8009cc:	75 07                	jne    8009d5 <strtol+0x3a>
		s++, neg = 1;
  8009ce:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009d1:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d5:	85 db                	test   %ebx,%ebx
  8009d7:	0f 94 c0             	sete   %al
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 19                	jne    8009fb <strtol+0x60>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 14                	jne    8009fb <strtol+0x60>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	0f 85 82 00 00 00    	jne    800a73 <strtol+0xd8>
		s += 2, base = 16;
  8009f1:	83 c1 02             	add    $0x2,%ecx
  8009f4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f9:	eb 16                	jmp    800a11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009fb:	84 c0                	test   %al,%al
  8009fd:	74 12                	je     800a11 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a04:	80 39 30             	cmpb   $0x30,(%ecx)
  800a07:	75 08                	jne    800a11 <strtol+0x76>
		s++, base = 8;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a19:	0f b6 11             	movzbl (%ecx),%edx
  800a1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 09             	cmp    $0x9,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x93>
			dig = *s - '0';
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 30             	sub    $0x30,%edx
  800a2c:	eb 22                	jmp    800a50 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a31:	89 f3                	mov    %esi,%ebx
  800a33:	80 fb 19             	cmp    $0x19,%bl
  800a36:	77 08                	ja     800a40 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a38:	0f be d2             	movsbl %dl,%edx
  800a3b:	83 ea 57             	sub    $0x57,%edx
  800a3e:	eb 10                	jmp    800a50 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a43:	89 f3                	mov    %esi,%ebx
  800a45:	80 fb 19             	cmp    $0x19,%bl
  800a48:	77 16                	ja     800a60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a4a:	0f be d2             	movsbl %dl,%edx
  800a4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a53:	7d 0f                	jge    800a64 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5e:	eb b9                	jmp    800a19 <strtol+0x7e>
  800a60:	89 c2                	mov    %eax,%edx
  800a62:	eb 02                	jmp    800a66 <strtol+0xcb>
  800a64:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 0d                	je     800a79 <strtol+0xde>
		*endptr = (char *) s;
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	89 0e                	mov    %ecx,(%esi)
  800a71:	eb 06                	jmp    800a79 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	84 c0                	test   %al,%al
  800a75:	75 92                	jne    800a09 <strtol+0x6e>
  800a77:	eb 98                	jmp    800a11 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a79:	f7 da                	neg    %edx
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	0f 45 c2             	cmovne %edx,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	89 c3                	mov    %eax,%ebx
  800a98:	89 c7                	mov    %eax,%edi
  800a9a:	89 c6                	mov    %eax,%esi
  800a9c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab3:	89 d1                	mov    %edx,%ecx
  800ab5:	89 d3                	mov    %edx,%ebx
  800ab7:	89 d7                	mov    %edx,%edi
  800ab9:	89 d6                	mov    %edx,%esi
  800abb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800acb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	89 cb                	mov    %ecx,%ebx
  800ada:	89 cf                	mov    %ecx,%edi
  800adc:	89 ce                	mov    %ecx,%esi
  800ade:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	7e 17                	jle    800afb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae4:	83 ec 0c             	sub    $0xc,%esp
  800ae7:	50                   	push   %eax
  800ae8:	6a 03                	push   $0x3
  800aea:	68 9f 2a 80 00       	push   $0x802a9f
  800aef:	6a 22                	push   $0x22
  800af1:	68 bc 2a 80 00       	push   $0x802abc
  800af6:	e8 54 18 00 00       	call   80234f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b13:	89 d1                	mov    %edx,%ecx
  800b15:	89 d3                	mov    %edx,%ebx
  800b17:	89 d7                	mov    %edx,%edi
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_yield>:

void
sys_yield(void)
{      
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b4a:	be 00 00 00 00       	mov    $0x0,%esi
  800b4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5d:	89 f7                	mov    %esi,%edi
  800b5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 17                	jle    800b7c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 04                	push   $0x4
  800b6b:	68 9f 2a 80 00       	push   $0x802a9f
  800b70:	6a 22                	push   $0x22
  800b72:	68 bc 2a 80 00       	push   $0x802abc
  800b77:	e8 d3 17 00 00       	call   80234f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9e:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 05                	push   $0x5
  800bad:	68 9f 2a 80 00       	push   $0x802a9f
  800bb2:	6a 22                	push   $0x22
  800bb4:	68 bc 2a 80 00       	push   $0x802abc
  800bb9:	e8 91 17 00 00       	call   80234f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 df                	mov    %ebx,%edi
  800be1:	89 de                	mov    %ebx,%esi
  800be3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 06                	push   $0x6
  800bef:	68 9f 2a 80 00       	push   $0x802a9f
  800bf4:	6a 22                	push   $0x22
  800bf6:	68 bc 2a 80 00       	push   $0x802abc
  800bfb:	e8 4f 17 00 00       	call   80234f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 08                	push   $0x8
  800c31:	68 9f 2a 80 00       	push   $0x802a9f
  800c36:	6a 22                	push   $0x22
  800c38:	68 bc 2a 80 00       	push   $0x802abc
  800c3d:	e8 0d 17 00 00       	call   80234f <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 09                	push   $0x9
  800c73:	68 9f 2a 80 00       	push   $0x802a9f
  800c78:	6a 22                	push   $0x22
  800c7a:	68 bc 2a 80 00       	push   $0x802abc
  800c7f:	e8 cb 16 00 00       	call   80234f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 0a                	push   $0xa
  800cb5:	68 9f 2a 80 00       	push   $0x802a9f
  800cba:	6a 22                	push   $0x22
  800cbc:	68 bc 2a 80 00       	push   $0x802abc
  800cc1:	e8 89 16 00 00       	call   80234f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 0d                	push   $0xd
  800d19:	68 9f 2a 80 00       	push   $0x802a9f
  800d1e:	6a 22                	push   $0x22
  800d20:	68 bc 2a 80 00       	push   $0x802abc
  800d25:	e8 25 16 00 00       	call   80234f <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d38:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d42:	89 d1                	mov    %edx,%ecx
  800d44:	89 d3                	mov    %edx,%ebx
  800d46:	89 d7                	mov    %edx,%edi
  800d48:	89 d6                	mov    %edx,%esi
  800d4a:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 cb                	mov    %ecx,%ebx
  800d69:	89 cf                	mov    %ecx,%edi
  800d6b:	89 ce                	mov    %ecx,%esi
  800d6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 17                	jle    800d8a <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	50                   	push   %eax
  800d77:	6a 0f                	push   $0xf
  800d79:	68 9f 2a 80 00       	push   $0x802a9f
  800d7e:	6a 22                	push   $0x22
  800d80:	68 bc 2a 80 00       	push   $0x802abc
  800d85:	e8 c5 15 00 00       	call   80234f <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_recv>:

int
sys_recv(void *addr)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da0:	b8 10 00 00 00       	mov    $0x10,%eax
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	89 cb                	mov    %ecx,%ebx
  800daa:	89 cf                	mov    %ecx,%edi
  800dac:	89 ce                	mov    %ecx,%esi
  800dae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 17                	jle    800dcb <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 10                	push   $0x10
  800dba:	68 9f 2a 80 00       	push   $0x802a9f
  800dbf:	6a 22                	push   $0x22
  800dc1:	68 bc 2a 80 00       	push   $0x802abc
  800dc6:	e8 84 15 00 00       	call   80234f <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ddd:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ddf:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800de3:	74 2e                	je     800e13 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	c1 ea 16             	shr    $0x16,%edx
  800dea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df1:	f6 c2 01             	test   $0x1,%dl
  800df4:	74 1d                	je     800e13 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 0c             	shr    $0xc,%edx
  800dfb:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e02:	f6 c1 01             	test   $0x1,%cl
  800e05:	74 0c                	je     800e13 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e0e:	f6 c6 08             	test   $0x8,%dh
  800e11:	75 14                	jne    800e27 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	68 cc 2a 80 00       	push   $0x802acc
  800e1b:	6a 21                	push   $0x21
  800e1d:	68 5f 2b 80 00       	push   $0x802b5f
  800e22:	e8 28 15 00 00       	call   80234f <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2c:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	6a 07                	push   $0x7
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 02 fd ff ff       	call   800b41 <sys_page_alloc>
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	79 14                	jns    800e5a <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	68 6a 2b 80 00       	push   $0x802b6a
  800e4e:	6a 2b                	push   $0x2b
  800e50:	68 5f 2b 80 00       	push   $0x802b5f
  800e55:	e8 f5 14 00 00       	call   80234f <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	68 00 10 00 00       	push   $0x1000
  800e62:	53                   	push   %ebx
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	e8 5d fa ff ff       	call   8008ca <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e6d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e74:	53                   	push   %ebx
  800e75:	6a 00                	push   $0x0
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 01 fd ff ff       	call   800b84 <sys_page_map>
  800e83:	83 c4 20             	add    $0x20,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	79 14                	jns    800e9e <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 80 2b 80 00       	push   $0x802b80
  800e92:	6a 2e                	push   $0x2e
  800e94:	68 5f 2b 80 00       	push   $0x802b5f
  800e99:	e8 b1 14 00 00       	call   80234f <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	68 00 f0 7f 00       	push   $0x7ff000
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 19 fd ff ff       	call   800bc6 <sys_page_unmap>
  800ead:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800ebe:	68 d3 0d 80 00       	push   $0x800dd3
  800ec3:	e8 cd 14 00 00       	call   802395 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ec8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecd:	cd 30                	int    $0x30
  800ecf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	79 12                	jns    800eeb <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800ed9:	50                   	push   %eax
  800eda:	68 94 2b 80 00       	push   $0x802b94
  800edf:	6a 6d                	push   $0x6d
  800ee1:	68 5f 2b 80 00       	push   $0x802b5f
  800ee6:	e8 64 14 00 00       	call   80234f <_panic>
  800eeb:	89 c7                	mov    %eax,%edi
  800eed:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800ef2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef6:	75 21                	jne    800f19 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800ef8:	e8 06 fc ff ff       	call   800b03 <sys_getenvid>
  800efd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f02:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f05:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f0a:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f14:	e9 9c 01 00 00       	jmp    8010b5 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	c1 e8 16             	shr    $0x16,%eax
  800f1e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f25:	a8 01                	test   $0x1,%al
  800f27:	0f 84 f3 00 00 00    	je     801020 <fork+0x16b>
  800f2d:	89 d8                	mov    %ebx,%eax
  800f2f:	c1 e8 0c             	shr    $0xc,%eax
  800f32:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	0f 84 de 00 00 00    	je     801020 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f42:	89 c6                	mov    %eax,%esi
  800f44:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f47:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f4e:	f6 c6 04             	test   $0x4,%dh
  800f51:	74 37                	je     800f8a <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f62:	50                   	push   %eax
  800f63:	56                   	push   %esi
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	6a 00                	push   $0x0
  800f68:	e8 17 fc ff ff       	call   800b84 <sys_page_map>
  800f6d:	83 c4 20             	add    $0x20,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	0f 89 a8 00 00 00    	jns    801020 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  800f78:	50                   	push   %eax
  800f79:	68 f0 2a 80 00       	push   $0x802af0
  800f7e:	6a 49                	push   $0x49
  800f80:	68 5f 2b 80 00       	push   $0x802b5f
  800f85:	e8 c5 13 00 00       	call   80234f <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f8a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f91:	f6 c6 08             	test   $0x8,%dh
  800f94:	75 0b                	jne    800fa1 <fork+0xec>
  800f96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9d:	a8 02                	test   $0x2,%al
  800f9f:	74 57                	je     800ff8 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	68 05 08 00 00       	push   $0x805
  800fa9:	56                   	push   %esi
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	6a 00                	push   $0x0
  800fae:	e8 d1 fb ff ff       	call   800b84 <sys_page_map>
  800fb3:	83 c4 20             	add    $0x20,%esp
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	79 12                	jns    800fcc <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  800fba:	50                   	push   %eax
  800fbb:	68 f0 2a 80 00       	push   $0x802af0
  800fc0:	6a 4c                	push   $0x4c
  800fc2:	68 5f 2b 80 00       	push   $0x802b5f
  800fc7:	e8 83 13 00 00       	call   80234f <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	68 05 08 00 00       	push   $0x805
  800fd4:	56                   	push   %esi
  800fd5:	6a 00                	push   $0x0
  800fd7:	56                   	push   %esi
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 a5 fb ff ff       	call   800b84 <sys_page_map>
  800fdf:	83 c4 20             	add    $0x20,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 3a                	jns    801020 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  800fe6:	50                   	push   %eax
  800fe7:	68 14 2b 80 00       	push   $0x802b14
  800fec:	6a 4e                	push   $0x4e
  800fee:	68 5f 2b 80 00       	push   $0x802b5f
  800ff3:	e8 57 13 00 00       	call   80234f <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	6a 05                	push   $0x5
  800ffd:	56                   	push   %esi
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	6a 00                	push   $0x0
  801002:	e8 7d fb ff ff       	call   800b84 <sys_page_map>
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 12                	jns    801020 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80100e:	50                   	push   %eax
  80100f:	68 3c 2b 80 00       	push   $0x802b3c
  801014:	6a 50                	push   $0x50
  801016:	68 5f 2b 80 00       	push   $0x802b5f
  80101b:	e8 2f 13 00 00       	call   80234f <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801020:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801026:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80102c:	0f 85 e7 fe ff ff    	jne    800f19 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	6a 07                	push   $0x7
  801037:	68 00 f0 bf ee       	push   $0xeebff000
  80103c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103f:	e8 fd fa ff ff       	call   800b41 <sys_page_alloc>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 14                	jns    80105f <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 a4 2b 80 00       	push   $0x802ba4
  801053:	6a 76                	push   $0x76
  801055:	68 5f 2b 80 00       	push   $0x802b5f
  80105a:	e8 f0 12 00 00       	call   80234f <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80105f:	83 ec 08             	sub    $0x8,%esp
  801062:	68 04 24 80 00       	push   $0x802404
  801067:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106a:	e8 1d fc ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	79 14                	jns    80108a <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801076:	ff 75 e4             	pushl  -0x1c(%ebp)
  801079:	68 be 2b 80 00       	push   $0x802bbe
  80107e:	6a 79                	push   $0x79
  801080:	68 5f 2b 80 00       	push   $0x802b5f
  801085:	e8 c5 12 00 00       	call   80234f <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	6a 02                	push   $0x2
  80108f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801092:	e8 71 fb ff ff       	call   800c08 <sys_env_set_status>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 14                	jns    8010b2 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80109e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a1:	68 db 2b 80 00       	push   $0x802bdb
  8010a6:	6a 7b                	push   $0x7b
  8010a8:	68 5f 2b 80 00       	push   $0x802b5f
  8010ad:	e8 9d 12 00 00       	call   80234f <_panic>
        return forkid;
  8010b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sfork>:

// Challenge!
int
sfork(void)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c3:	68 f2 2b 80 00       	push   $0x802bf2
  8010c8:	68 83 00 00 00       	push   $0x83
  8010cd:	68 5f 2b 80 00       	push   $0x802b5f
  8010d2:	e8 78 12 00 00       	call   80234f <_panic>

008010d7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
  8010dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8010df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010ec:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	50                   	push   %eax
  8010f3:	e8 f9 fb ff ff       	call   800cf1 <sys_ipc_recv>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 16                	jns    801115 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8010ff:	85 f6                	test   %esi,%esi
  801101:	74 06                	je     801109 <ipc_recv+0x32>
  801103:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801109:	85 db                	test   %ebx,%ebx
  80110b:	74 2c                	je     801139 <ipc_recv+0x62>
  80110d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801113:	eb 24                	jmp    801139 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801115:	85 f6                	test   %esi,%esi
  801117:	74 0a                	je     801123 <ipc_recv+0x4c>
  801119:	a1 08 40 80 00       	mov    0x804008,%eax
  80111e:	8b 40 74             	mov    0x74(%eax),%eax
  801121:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801123:	85 db                	test   %ebx,%ebx
  801125:	74 0a                	je     801131 <ipc_recv+0x5a>
  801127:	a1 08 40 80 00       	mov    0x804008,%eax
  80112c:	8b 40 78             	mov    0x78(%eax),%eax
  80112f:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801131:	a1 08 40 80 00       	mov    0x804008,%eax
  801136:	8b 40 70             	mov    0x70(%eax),%eax
}
  801139:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80114f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801152:	85 db                	test   %ebx,%ebx
  801154:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801159:	0f 44 d8             	cmove  %eax,%ebx
  80115c:	eb 1c                	jmp    80117a <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80115e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801161:	74 12                	je     801175 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801163:	50                   	push   %eax
  801164:	68 08 2c 80 00       	push   $0x802c08
  801169:	6a 39                	push   $0x39
  80116b:	68 23 2c 80 00       	push   $0x802c23
  801170:	e8 da 11 00 00       	call   80234f <_panic>
                 sys_yield();
  801175:	e8 a8 f9 ff ff       	call   800b22 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80117a:	ff 75 14             	pushl  0x14(%ebp)
  80117d:	53                   	push   %ebx
  80117e:	56                   	push   %esi
  80117f:	57                   	push   %edi
  801180:	e8 49 fb ff ff       	call   800cce <sys_ipc_try_send>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 d2                	js     80115e <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80119f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011a8:	8b 52 50             	mov    0x50(%edx),%edx
  8011ab:	39 ca                	cmp    %ecx,%edx
  8011ad:	75 0d                	jne    8011bc <ipc_find_env+0x28>
			return envs[i].env_id;
  8011af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011b2:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8011b7:	8b 40 08             	mov    0x8(%eax),%eax
  8011ba:	eb 0e                	jmp    8011ca <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011bc:	83 c0 01             	add    $0x1,%eax
  8011bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c4:	75 d9                	jne    80119f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011c6:	66 b8 00 00          	mov    $0x0,%ax
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 16             	shr    $0x16,%edx
  801203:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	74 11                	je     801220 <fd_alloc+0x2d>
  80120f:	89 c2                	mov    %eax,%edx
  801211:	c1 ea 0c             	shr    $0xc,%edx
  801214:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121b:	f6 c2 01             	test   $0x1,%dl
  80121e:	75 09                	jne    801229 <fd_alloc+0x36>
			*fd_store = fd;
  801220:	89 01                	mov    %eax,(%ecx)
			return 0;
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	eb 17                	jmp    801240 <fd_alloc+0x4d>
  801229:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80122e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801233:	75 c9                	jne    8011fe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801235:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80123b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801248:	83 f8 1f             	cmp    $0x1f,%eax
  80124b:	77 36                	ja     801283 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124d:	c1 e0 0c             	shl    $0xc,%eax
  801250:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 16             	shr    $0x16,%edx
  80125a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801261:	f6 c2 01             	test   $0x1,%dl
  801264:	74 24                	je     80128a <fd_lookup+0x48>
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 0c             	shr    $0xc,%edx
  80126b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	74 1a                	je     801291 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127a:	89 02                	mov    %eax,(%edx)
	return 0;
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
  801281:	eb 13                	jmp    801296 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801288:	eb 0c                	jmp    801296 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128f:	eb 05                	jmp    801296 <fd_lookup+0x54>
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a6:	eb 13                	jmp    8012bb <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8012a8:	39 08                	cmp    %ecx,(%eax)
  8012aa:	75 0c                	jne    8012b8 <dev_lookup+0x20>
			*dev = devtab[i];
  8012ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b6:	eb 36                	jmp    8012ee <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b8:	83 c2 01             	add    $0x1,%edx
  8012bb:	8b 04 95 ac 2c 80 00 	mov    0x802cac(,%edx,4),%eax
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	75 e2                	jne    8012a8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8012cb:	8b 40 48             	mov    0x48(%eax),%eax
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	51                   	push   %ecx
  8012d2:	50                   	push   %eax
  8012d3:	68 30 2c 80 00       	push   $0x802c30
  8012d8:	e8 d4 ee ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8012dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 10             	sub    $0x10,%esp
  8012f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801302:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801308:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130b:	50                   	push   %eax
  80130c:	e8 31 ff ff ff       	call   801242 <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 05                	js     80131d <fd_close+0x2d>
	    || fd != fd2)
  801318:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131b:	74 0c                	je     801329 <fd_close+0x39>
		return (must_exist ? r : 0);
  80131d:	84 db                	test   %bl,%bl
  80131f:	ba 00 00 00 00       	mov    $0x0,%edx
  801324:	0f 44 c2             	cmove  %edx,%eax
  801327:	eb 41                	jmp    80136a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 36                	pushl  (%esi)
  801332:	e8 61 ff ff ff       	call   801298 <dev_lookup>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 1a                	js     80135a <fd_close+0x6a>
		if (dev->dev_close)
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 0b                	je     80135a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	56                   	push   %esi
  801353:	ff d0                	call   *%eax
  801355:	89 c3                	mov    %eax,%ebx
  801357:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	56                   	push   %esi
  80135e:	6a 00                	push   $0x0
  801360:	e8 61 f8 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	89 d8                	mov    %ebx,%eax
}
  80136a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 75 08             	pushl  0x8(%ebp)
  80137e:	e8 bf fe ff ff       	call   801242 <fd_lookup>
  801383:	89 c2                	mov    %eax,%edx
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 d2                	test   %edx,%edx
  80138a:	78 10                	js     80139c <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	6a 01                	push   $0x1
  801391:	ff 75 f4             	pushl  -0xc(%ebp)
  801394:	e8 57 ff ff ff       	call   8012f0 <fd_close>
  801399:	83 c4 10             	add    $0x10,%esp
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <close_all>:

void
close_all(void)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	e8 be ff ff ff       	call   801371 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	83 c3 01             	add    $0x1,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	83 fb 20             	cmp    $0x20,%ebx
  8013bc:	75 ec                	jne    8013aa <close_all+0xc>
		close(i);
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	57                   	push   %edi
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 2c             	sub    $0x2c,%esp
  8013cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 08             	pushl  0x8(%ebp)
  8013d6:	e8 67 fe ff ff       	call   801242 <fd_lookup>
  8013db:	89 c2                	mov    %eax,%edx
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	85 d2                	test   %edx,%edx
  8013e2:	0f 88 c1 00 00 00    	js     8014a9 <dup+0xe6>
		return r;
	close(newfdnum);
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	56                   	push   %esi
  8013ec:	e8 80 ff ff ff       	call   801371 <close>

	newfd = INDEX2FD(newfdnum);
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	c1 e3 0c             	shl    $0xc,%ebx
  8013f6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fc:	83 c4 04             	add    $0x4,%esp
  8013ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801402:	e8 d5 fd ff ff       	call   8011dc <fd2data>
  801407:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801409:	89 1c 24             	mov    %ebx,(%esp)
  80140c:	e8 cb fd ff ff       	call   8011dc <fd2data>
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801417:	89 f8                	mov    %edi,%eax
  801419:	c1 e8 16             	shr    $0x16,%eax
  80141c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801423:	a8 01                	test   $0x1,%al
  801425:	74 37                	je     80145e <dup+0x9b>
  801427:	89 f8                	mov    %edi,%eax
  801429:	c1 e8 0c             	shr    $0xc,%eax
  80142c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801433:	f6 c2 01             	test   $0x1,%dl
  801436:	74 26                	je     80145e <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801438:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	25 07 0e 00 00       	and    $0xe07,%eax
  801447:	50                   	push   %eax
  801448:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144b:	6a 00                	push   $0x0
  80144d:	57                   	push   %edi
  80144e:	6a 00                	push   $0x0
  801450:	e8 2f f7 ff ff       	call   800b84 <sys_page_map>
  801455:	89 c7                	mov    %eax,%edi
  801457:	83 c4 20             	add    $0x20,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 2e                	js     80148c <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801461:	89 d0                	mov    %edx,%eax
  801463:	c1 e8 0c             	shr    $0xc,%eax
  801466:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	25 07 0e 00 00       	and    $0xe07,%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	6a 00                	push   $0x0
  801479:	52                   	push   %edx
  80147a:	6a 00                	push   $0x0
  80147c:	e8 03 f7 ff ff       	call   800b84 <sys_page_map>
  801481:	89 c7                	mov    %eax,%edi
  801483:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801486:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801488:	85 ff                	test   %edi,%edi
  80148a:	79 1d                	jns    8014a9 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	53                   	push   %ebx
  801490:	6a 00                	push   $0x0
  801492:	e8 2f f7 ff ff       	call   800bc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149d:	6a 00                	push   $0x0
  80149f:	e8 22 f7 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	89 f8                	mov    %edi,%eax
}
  8014a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5f                   	pop    %edi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 14             	sub    $0x14,%esp
  8014b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	53                   	push   %ebx
  8014c0:	e8 7d fd ff ff       	call   801242 <fd_lookup>
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	89 c2                	mov    %eax,%edx
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 6d                	js     80153b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	ff 30                	pushl  (%eax)
  8014da:	e8 b9 fd ff ff       	call   801298 <dev_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 4c                	js     801532 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e9:	8b 42 08             	mov    0x8(%edx),%eax
  8014ec:	83 e0 03             	and    $0x3,%eax
  8014ef:	83 f8 01             	cmp    $0x1,%eax
  8014f2:	75 21                	jne    801515 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8014f9:	8b 40 48             	mov    0x48(%eax),%eax
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	53                   	push   %ebx
  801500:	50                   	push   %eax
  801501:	68 71 2c 80 00       	push   $0x802c71
  801506:	e8 a6 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801513:	eb 26                	jmp    80153b <read+0x8a>
	}
	if (!dev->dev_read)
  801515:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801518:	8b 40 08             	mov    0x8(%eax),%eax
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 17                	je     801536 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	ff 75 10             	pushl  0x10(%ebp)
  801525:	ff 75 0c             	pushl  0xc(%ebp)
  801528:	52                   	push   %edx
  801529:	ff d0                	call   *%eax
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	eb 09                	jmp    80153b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	89 c2                	mov    %eax,%edx
  801534:	eb 05                	jmp    80153b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801536:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	57                   	push   %edi
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801551:	bb 00 00 00 00       	mov    $0x0,%ebx
  801556:	eb 21                	jmp    801579 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	89 f0                	mov    %esi,%eax
  80155d:	29 d8                	sub    %ebx,%eax
  80155f:	50                   	push   %eax
  801560:	89 d8                	mov    %ebx,%eax
  801562:	03 45 0c             	add    0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	57                   	push   %edi
  801567:	e8 45 ff ff ff       	call   8014b1 <read>
		if (m < 0)
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 0c                	js     80157f <readn+0x3d>
			return m;
		if (m == 0)
  801573:	85 c0                	test   %eax,%eax
  801575:	74 06                	je     80157d <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801577:	01 c3                	add    %eax,%ebx
  801579:	39 f3                	cmp    %esi,%ebx
  80157b:	72 db                	jb     801558 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80157d:	89 d8                	mov    %ebx,%eax
}
  80157f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	83 ec 14             	sub    $0x14,%esp
  80158e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801591:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	53                   	push   %ebx
  801596:	e8 a7 fc ff ff       	call   801242 <fd_lookup>
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 68                	js     80160c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	ff 30                	pushl  (%eax)
  8015b0:	e8 e3 fc ff ff       	call   801298 <dev_lookup>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 47                	js     801603 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c3:	75 21                	jne    8015e6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ca:	8b 40 48             	mov    0x48(%eax),%eax
  8015cd:	83 ec 04             	sub    $0x4,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	50                   	push   %eax
  8015d2:	68 8d 2c 80 00       	push   $0x802c8d
  8015d7:	e8 d5 eb ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e4:	eb 26                	jmp    80160c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ec:	85 d2                	test   %edx,%edx
  8015ee:	74 17                	je     801607 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f0:	83 ec 04             	sub    $0x4,%esp
  8015f3:	ff 75 10             	pushl  0x10(%ebp)
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	50                   	push   %eax
  8015fa:	ff d2                	call   *%edx
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb 09                	jmp    80160c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	89 c2                	mov    %eax,%edx
  801605:	eb 05                	jmp    80160c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801607:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160c:	89 d0                	mov    %edx,%eax
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <seek>:

int
seek(int fdnum, off_t offset)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801619:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 1d fc ff ff       	call   801242 <fd_lookup>
  801625:	83 c4 08             	add    $0x8,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 0e                	js     80163a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80162f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801632:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801635:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 14             	sub    $0x14,%esp
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	53                   	push   %ebx
  80164b:	e8 f2 fb ff ff       	call   801242 <fd_lookup>
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	89 c2                	mov    %eax,%edx
  801655:	85 c0                	test   %eax,%eax
  801657:	78 65                	js     8016be <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	ff 30                	pushl  (%eax)
  801665:	e8 2e fc ff ff       	call   801298 <dev_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 44                	js     8016b5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801674:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801678:	75 21                	jne    80169b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80167f:	8b 40 48             	mov    0x48(%eax),%eax
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	53                   	push   %ebx
  801686:	50                   	push   %eax
  801687:	68 50 2c 80 00       	push   $0x802c50
  80168c:	e8 20 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801699:	eb 23                	jmp    8016be <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169e:	8b 52 18             	mov    0x18(%edx),%edx
  8016a1:	85 d2                	test   %edx,%edx
  8016a3:	74 14                	je     8016b9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	ff 75 0c             	pushl  0xc(%ebp)
  8016ab:	50                   	push   %eax
  8016ac:	ff d2                	call   *%edx
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 09                	jmp    8016be <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	eb 05                	jmp    8016be <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016be:	89 d0                	mov    %edx,%eax
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 14             	sub    $0x14,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	50                   	push   %eax
  8016d3:	ff 75 08             	pushl  0x8(%ebp)
  8016d6:	e8 67 fb ff ff       	call   801242 <fd_lookup>
  8016db:	83 c4 08             	add    $0x8,%esp
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	78 58                	js     80173c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ea:	50                   	push   %eax
  8016eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ee:	ff 30                	pushl  (%eax)
  8016f0:	e8 a3 fb ff ff       	call   801298 <dev_lookup>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 37                	js     801733 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801703:	74 32                	je     801737 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801705:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801708:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170f:	00 00 00 
	stat->st_isdir = 0;
  801712:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801719:	00 00 00 
	stat->st_dev = dev;
  80171c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	53                   	push   %ebx
  801726:	ff 75 f0             	pushl  -0x10(%ebp)
  801729:	ff 50 14             	call   *0x14(%eax)
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	eb 09                	jmp    80173c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801733:	89 c2                	mov    %eax,%edx
  801735:	eb 05                	jmp    80173c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801737:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173c:	89 d0                	mov    %edx,%eax
  80173e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	6a 00                	push   $0x0
  80174d:	ff 75 08             	pushl  0x8(%ebp)
  801750:	e8 09 02 00 00       	call   80195e <open>
  801755:	89 c3                	mov    %eax,%ebx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 db                	test   %ebx,%ebx
  80175c:	78 1b                	js     801779 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	ff 75 0c             	pushl  0xc(%ebp)
  801764:	53                   	push   %ebx
  801765:	e8 5b ff ff ff       	call   8016c5 <fstat>
  80176a:	89 c6                	mov    %eax,%esi
	close(fd);
  80176c:	89 1c 24             	mov    %ebx,(%esp)
  80176f:	e8 fd fb ff ff       	call   801371 <close>
	return r;
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	89 f0                	mov    %esi,%eax
}
  801779:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	89 c6                	mov    %eax,%esi
  801787:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801789:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801790:	75 12                	jne    8017a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	6a 01                	push   $0x1
  801797:	e8 f8 f9 ff ff       	call   801194 <ipc_find_env>
  80179c:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a4:	6a 07                	push   $0x7
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	56                   	push   %esi
  8017ac:	ff 35 00 40 80 00    	pushl  0x804000
  8017b2:	e8 89 f9 ff ff       	call   801140 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b7:	83 c4 0c             	add    $0xc,%esp
  8017ba:	6a 00                	push   $0x0
  8017bc:	53                   	push   %ebx
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 13 f9 ff ff       	call   8010d7 <ipc_recv>
}
  8017c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017df:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ee:	e8 8d ff ff ff       	call   801780 <fsipc>
}
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	b8 06 00 00 00       	mov    $0x6,%eax
  801810:	e8 6b ff ff ff       	call   801780 <fsipc>
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	8b 40 0c             	mov    0xc(%eax),%eax
  801827:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182c:	ba 00 00 00 00       	mov    $0x0,%edx
  801831:	b8 05 00 00 00       	mov    $0x5,%eax
  801836:	e8 45 ff ff ff       	call   801780 <fsipc>
  80183b:	89 c2                	mov    %eax,%edx
  80183d:	85 d2                	test   %edx,%edx
  80183f:	78 2c                	js     80186d <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	53                   	push   %ebx
  80184a:	e8 e9 ee ff ff       	call   800738 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184f:	a1 80 50 80 00       	mov    0x805080,%eax
  801854:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185a:	a1 84 50 80 00       	mov    0x805084,%eax
  80185f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	57                   	push   %edi
  801876:	56                   	push   %esi
  801877:	53                   	push   %ebx
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	8b 40 0c             	mov    0xc(%eax),%eax
  801884:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80188c:	eb 3d                	jmp    8018cb <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80188e:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801894:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801899:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	57                   	push   %edi
  8018a0:	53                   	push   %ebx
  8018a1:	68 08 50 80 00       	push   $0x805008
  8018a6:	e8 1f f0 ff ff       	call   8008ca <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018ab:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bb:	e8 c0 fe ff ff       	call   801780 <fsipc>
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 0d                	js     8018d4 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8018c7:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8018c9:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018cb:	85 f6                	test   %esi,%esi
  8018cd:	75 bf                	jne    80188e <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8018d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d7:	5b                   	pop    %ebx
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ef:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ff:	e8 7c fe ff ff       	call   801780 <fsipc>
  801904:	89 c3                	mov    %eax,%ebx
  801906:	85 c0                	test   %eax,%eax
  801908:	78 4b                	js     801955 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80190a:	39 c6                	cmp    %eax,%esi
  80190c:	73 16                	jae    801924 <devfile_read+0x48>
  80190e:	68 c0 2c 80 00       	push   $0x802cc0
  801913:	68 c7 2c 80 00       	push   $0x802cc7
  801918:	6a 7c                	push   $0x7c
  80191a:	68 dc 2c 80 00       	push   $0x802cdc
  80191f:	e8 2b 0a 00 00       	call   80234f <_panic>
	assert(r <= PGSIZE);
  801924:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801929:	7e 16                	jle    801941 <devfile_read+0x65>
  80192b:	68 e7 2c 80 00       	push   $0x802ce7
  801930:	68 c7 2c 80 00       	push   $0x802cc7
  801935:	6a 7d                	push   $0x7d
  801937:	68 dc 2c 80 00       	push   $0x802cdc
  80193c:	e8 0e 0a 00 00       	call   80234f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801941:	83 ec 04             	sub    $0x4,%esp
  801944:	50                   	push   %eax
  801945:	68 00 50 80 00       	push   $0x805000
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	e8 78 ef ff ff       	call   8008ca <memmove>
	return r;
  801952:	83 c4 10             	add    $0x10,%esp
}
  801955:	89 d8                	mov    %ebx,%eax
  801957:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 20             	sub    $0x20,%esp
  801965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801968:	53                   	push   %ebx
  801969:	e8 91 ed ff ff       	call   8006ff <strlen>
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801976:	7f 67                	jg     8019df <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	e8 6f f8 ff ff       	call   8011f3 <fd_alloc>
  801984:	83 c4 10             	add    $0x10,%esp
		return r;
  801987:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 57                	js     8019e4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	53                   	push   %ebx
  801991:	68 00 50 80 00       	push   $0x805000
  801996:	e8 9d ed ff ff       	call   800738 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ab:	e8 d0 fd ff ff       	call   801780 <fsipc>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	79 14                	jns    8019cd <open+0x6f>
		fd_close(fd, 0);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	6a 00                	push   $0x0
  8019be:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c1:	e8 2a f9 ff ff       	call   8012f0 <fd_close>
		return r;
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	89 da                	mov    %ebx,%edx
  8019cb:	eb 17                	jmp    8019e4 <open+0x86>
	}

	return fd2num(fd);
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d3:	e8 f4 f7 ff ff       	call   8011cc <fd2num>
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	eb 05                	jmp    8019e4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019df:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019e4:	89 d0                	mov    %edx,%eax
  8019e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fb:	e8 80 fd ff ff       	call   801780 <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a08:	68 f3 2c 80 00       	push   $0x802cf3
  801a0d:	ff 75 0c             	pushl  0xc(%ebp)
  801a10:	e8 23 ed ff ff       	call   800738 <strcpy>
	return 0;
}
  801a15:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 10             	sub    $0x10,%esp
  801a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a26:	53                   	push   %ebx
  801a27:	e8 fc 09 00 00       	call   802428 <pageref>
  801a2c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a34:	83 f8 01             	cmp    $0x1,%eax
  801a37:	75 10                	jne    801a49 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a39:	83 ec 0c             	sub    $0xc,%esp
  801a3c:	ff 73 0c             	pushl  0xc(%ebx)
  801a3f:	e8 ca 02 00 00       	call   801d0e <nsipc_close>
  801a44:	89 c2                	mov    %eax,%edx
  801a46:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a49:	89 d0                	mov    %edx,%eax
  801a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a56:	6a 00                	push   $0x0
  801a58:	ff 75 10             	pushl  0x10(%ebp)
  801a5b:	ff 75 0c             	pushl  0xc(%ebp)
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	ff 70 0c             	pushl  0xc(%eax)
  801a64:	e8 82 03 00 00       	call   801deb <nsipc_send>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a71:	6a 00                	push   $0x0
  801a73:	ff 75 10             	pushl  0x10(%ebp)
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	ff 70 0c             	pushl  0xc(%eax)
  801a7f:	e8 fb 02 00 00       	call   801d7f <nsipc_recv>
}
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a8c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a8f:	52                   	push   %edx
  801a90:	50                   	push   %eax
  801a91:	e8 ac f7 ff ff       	call   801242 <fd_lookup>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 17                	js     801ab4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801aa6:	39 08                	cmp    %ecx,(%eax)
  801aa8:	75 05                	jne    801aaf <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  801aad:	eb 05                	jmp    801ab4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aaf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	83 ec 1c             	sub    $0x1c,%esp
  801abe:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ac0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac3:	50                   	push   %eax
  801ac4:	e8 2a f7 ff ff       	call   8011f3 <fd_alloc>
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 1b                	js     801aed <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ad2:	83 ec 04             	sub    $0x4,%esp
  801ad5:	68 07 04 00 00       	push   $0x407
  801ada:	ff 75 f4             	pushl  -0xc(%ebp)
  801add:	6a 00                	push   $0x0
  801adf:	e8 5d f0 ff ff       	call   800b41 <sys_page_alloc>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	79 10                	jns    801afd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	56                   	push   %esi
  801af1:	e8 18 02 00 00       	call   801d0e <nsipc_close>
		return r;
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	89 d8                	mov    %ebx,%eax
  801afb:	eb 24                	jmp    801b21 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801afd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b0b:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b12:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	52                   	push   %edx
  801b19:	e8 ae f6 ff ff       	call   8011cc <fd2num>
  801b1e:	83 c4 10             	add    $0x10,%esp
}
  801b21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	e8 50 ff ff ff       	call   801a86 <fd2sockid>
		return r;
  801b36:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 1f                	js     801b5b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	50                   	push   %eax
  801b46:	e8 1c 01 00 00       	call   801c67 <nsipc_accept>
  801b4b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b4e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 07                	js     801b5b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b54:	e8 5d ff ff ff       	call   801ab6 <alloc_sockfd>
  801b59:	89 c1                	mov    %eax,%ecx
}
  801b5b:	89 c8                	mov    %ecx,%eax
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b65:	8b 45 08             	mov    0x8(%ebp),%eax
  801b68:	e8 19 ff ff ff       	call   801a86 <fd2sockid>
  801b6d:	89 c2                	mov    %eax,%edx
  801b6f:	85 d2                	test   %edx,%edx
  801b71:	78 12                	js     801b85 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	ff 75 10             	pushl  0x10(%ebp)
  801b79:	ff 75 0c             	pushl  0xc(%ebp)
  801b7c:	52                   	push   %edx
  801b7d:	e8 35 01 00 00       	call   801cb7 <nsipc_bind>
  801b82:	83 c4 10             	add    $0x10,%esp
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <shutdown>:

int
shutdown(int s, int how)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	e8 f1 fe ff ff       	call   801a86 <fd2sockid>
  801b95:	89 c2                	mov    %eax,%edx
  801b97:	85 d2                	test   %edx,%edx
  801b99:	78 0f                	js     801baa <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ba1:	52                   	push   %edx
  801ba2:	e8 45 01 00 00       	call   801cec <nsipc_shutdown>
  801ba7:	83 c4 10             	add    $0x10,%esp
}
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb5:	e8 cc fe ff ff       	call   801a86 <fd2sockid>
  801bba:	89 c2                	mov    %eax,%edx
  801bbc:	85 d2                	test   %edx,%edx
  801bbe:	78 12                	js     801bd2 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	ff 75 10             	pushl  0x10(%ebp)
  801bc6:	ff 75 0c             	pushl  0xc(%ebp)
  801bc9:	52                   	push   %edx
  801bca:	e8 59 01 00 00       	call   801d28 <nsipc_connect>
  801bcf:	83 c4 10             	add    $0x10,%esp
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <listen>:

int
listen(int s, int backlog)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bda:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdd:	e8 a4 fe ff ff       	call   801a86 <fd2sockid>
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	85 d2                	test   %edx,%edx
  801be6:	78 0f                	js     801bf7 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	ff 75 0c             	pushl  0xc(%ebp)
  801bee:	52                   	push   %edx
  801bef:	e8 69 01 00 00       	call   801d5d <nsipc_listen>
  801bf4:	83 c4 10             	add    $0x10,%esp
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bff:	ff 75 10             	pushl  0x10(%ebp)
  801c02:	ff 75 0c             	pushl  0xc(%ebp)
  801c05:	ff 75 08             	pushl  0x8(%ebp)
  801c08:	e8 3c 02 00 00       	call   801e49 <nsipc_socket>
  801c0d:	89 c2                	mov    %eax,%edx
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	85 d2                	test   %edx,%edx
  801c14:	78 05                	js     801c1b <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801c16:	e8 9b fe ff ff       	call   801ab6 <alloc_sockfd>
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	53                   	push   %ebx
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c26:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c2d:	75 12                	jne    801c41 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c2f:	83 ec 0c             	sub    $0xc,%esp
  801c32:	6a 02                	push   $0x2
  801c34:	e8 5b f5 ff ff       	call   801194 <ipc_find_env>
  801c39:	a3 04 40 80 00       	mov    %eax,0x804004
  801c3e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c41:	6a 07                	push   $0x7
  801c43:	68 00 60 80 00       	push   $0x806000
  801c48:	53                   	push   %ebx
  801c49:	ff 35 04 40 80 00    	pushl  0x804004
  801c4f:	e8 ec f4 ff ff       	call   801140 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c54:	83 c4 0c             	add    $0xc,%esp
  801c57:	6a 00                	push   $0x0
  801c59:	6a 00                	push   $0x0
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 75 f4 ff ff       	call   8010d7 <ipc_recv>
}
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	56                   	push   %esi
  801c6b:	53                   	push   %ebx
  801c6c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c77:	8b 06                	mov    (%esi),%eax
  801c79:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c83:	e8 95 ff ff ff       	call   801c1d <nsipc>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 20                	js     801cae <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c8e:	83 ec 04             	sub    $0x4,%esp
  801c91:	ff 35 10 60 80 00    	pushl  0x806010
  801c97:	68 00 60 80 00       	push   $0x806000
  801c9c:	ff 75 0c             	pushl  0xc(%ebp)
  801c9f:	e8 26 ec ff ff       	call   8008ca <memmove>
		*addrlen = ret->ret_addrlen;
  801ca4:	a1 10 60 80 00       	mov    0x806010,%eax
  801ca9:	89 06                	mov    %eax,(%esi)
  801cab:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cae:	89 d8                	mov    %ebx,%eax
  801cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cc9:	53                   	push   %ebx
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	68 04 60 80 00       	push   $0x806004
  801cd2:	e8 f3 eb ff ff       	call   8008ca <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cd7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cdd:	b8 02 00 00 00       	mov    $0x2,%eax
  801ce2:	e8 36 ff ff ff       	call   801c1d <nsipc>
}
  801ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d02:	b8 03 00 00 00       	mov    $0x3,%eax
  801d07:	e8 11 ff ff ff       	call   801c1d <nsipc>
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <nsipc_close>:

int
nsipc_close(int s)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d1c:	b8 04 00 00 00       	mov    $0x4,%eax
  801d21:	e8 f7 fe ff ff       	call   801c1d <nsipc>
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 08             	sub    $0x8,%esp
  801d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d3a:	53                   	push   %ebx
  801d3b:	ff 75 0c             	pushl  0xc(%ebp)
  801d3e:	68 04 60 80 00       	push   $0x806004
  801d43:	e8 82 eb ff ff       	call   8008ca <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d48:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d4e:	b8 05 00 00 00       	mov    $0x5,%eax
  801d53:	e8 c5 fe ff ff       	call   801c1d <nsipc>
}
  801d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d73:	b8 06 00 00 00       	mov    $0x6,%eax
  801d78:	e8 a0 fe ff ff       	call   801c1d <nsipc>
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d8f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d95:	8b 45 14             	mov    0x14(%ebp),%eax
  801d98:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d9d:	b8 07 00 00 00       	mov    $0x7,%eax
  801da2:	e8 76 fe ff ff       	call   801c1d <nsipc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 35                	js     801de2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dad:	39 f0                	cmp    %esi,%eax
  801daf:	7f 07                	jg     801db8 <nsipc_recv+0x39>
  801db1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801db6:	7e 16                	jle    801dce <nsipc_recv+0x4f>
  801db8:	68 ff 2c 80 00       	push   $0x802cff
  801dbd:	68 c7 2c 80 00       	push   $0x802cc7
  801dc2:	6a 62                	push   $0x62
  801dc4:	68 14 2d 80 00       	push   $0x802d14
  801dc9:	e8 81 05 00 00       	call   80234f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	50                   	push   %eax
  801dd2:	68 00 60 80 00       	push   $0x806000
  801dd7:	ff 75 0c             	pushl  0xc(%ebp)
  801dda:	e8 eb ea ff ff       	call   8008ca <memmove>
  801ddf:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801de2:	89 d8                	mov    %ebx,%eax
  801de4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	53                   	push   %ebx
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dfd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e03:	7e 16                	jle    801e1b <nsipc_send+0x30>
  801e05:	68 20 2d 80 00       	push   $0x802d20
  801e0a:	68 c7 2c 80 00       	push   $0x802cc7
  801e0f:	6a 6d                	push   $0x6d
  801e11:	68 14 2d 80 00       	push   $0x802d14
  801e16:	e8 34 05 00 00       	call   80234f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	53                   	push   %ebx
  801e1f:	ff 75 0c             	pushl  0xc(%ebp)
  801e22:	68 0c 60 80 00       	push   $0x80600c
  801e27:	e8 9e ea ff ff       	call   8008ca <memmove>
	nsipcbuf.send.req_size = size;
  801e2c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e32:	8b 45 14             	mov    0x14(%ebp),%eax
  801e35:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e3a:	b8 08 00 00 00       	mov    $0x8,%eax
  801e3f:	e8 d9 fd ff ff       	call   801c1d <nsipc>
}
  801e44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    

00801e49 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e67:	b8 09 00 00 00       	mov    $0x9,%eax
  801e6c:	e8 ac fd ff ff       	call   801c1d <nsipc>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 08             	pushl  0x8(%ebp)
  801e81:	e8 56 f3 ff ff       	call   8011dc <fd2data>
  801e86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e88:	83 c4 08             	add    $0x8,%esp
  801e8b:	68 2c 2d 80 00       	push   $0x802d2c
  801e90:	53                   	push   %ebx
  801e91:	e8 a2 e8 ff ff       	call   800738 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e96:	8b 56 04             	mov    0x4(%esi),%edx
  801e99:	89 d0                	mov    %edx,%eax
  801e9b:	2b 06                	sub    (%esi),%eax
  801e9d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ea3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eaa:	00 00 00 
	stat->st_dev = &devpipe;
  801ead:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801eb4:	30 80 00 
	return 0;
}
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	53                   	push   %ebx
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ecd:	53                   	push   %ebx
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 f1 ec ff ff       	call   800bc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed5:	89 1c 24             	mov    %ebx,(%esp)
  801ed8:	e8 ff f2 ff ff       	call   8011dc <fd2data>
  801edd:	83 c4 08             	add    $0x8,%esp
  801ee0:	50                   	push   %eax
  801ee1:	6a 00                	push   $0x0
  801ee3:	e8 de ec ff ff       	call   800bc6 <sys_page_unmap>
}
  801ee8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	57                   	push   %edi
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 1c             	sub    $0x1c,%esp
  801ef6:	89 c6                	mov    %eax,%esi
  801ef8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801efb:	a1 08 40 80 00       	mov    0x804008,%eax
  801f00:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	56                   	push   %esi
  801f07:	e8 1c 05 00 00       	call   802428 <pageref>
  801f0c:	89 c7                	mov    %eax,%edi
  801f0e:	83 c4 04             	add    $0x4,%esp
  801f11:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f14:	e8 0f 05 00 00       	call   802428 <pageref>
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	39 c7                	cmp    %eax,%edi
  801f1e:	0f 94 c2             	sete   %dl
  801f21:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801f24:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801f2a:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f2d:	39 fb                	cmp    %edi,%ebx
  801f2f:	74 19                	je     801f4a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801f31:	84 d2                	test   %dl,%dl
  801f33:	74 c6                	je     801efb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f35:	8b 51 58             	mov    0x58(%ecx),%edx
  801f38:	50                   	push   %eax
  801f39:	52                   	push   %edx
  801f3a:	53                   	push   %ebx
  801f3b:	68 33 2d 80 00       	push   $0x802d33
  801f40:	e8 6c e2 ff ff       	call   8001b1 <cprintf>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	eb b1                	jmp    801efb <_pipeisclosed+0xe>
	}
}
  801f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	83 ec 28             	sub    $0x28,%esp
  801f5b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f5e:	56                   	push   %esi
  801f5f:	e8 78 f2 ff ff       	call   8011dc <fd2data>
  801f64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	bf 00 00 00 00       	mov    $0x0,%edi
  801f6e:	eb 4b                	jmp    801fbb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f70:	89 da                	mov    %ebx,%edx
  801f72:	89 f0                	mov    %esi,%eax
  801f74:	e8 74 ff ff ff       	call   801eed <_pipeisclosed>
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	75 48                	jne    801fc5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f7d:	e8 a0 eb ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f82:	8b 43 04             	mov    0x4(%ebx),%eax
  801f85:	8b 0b                	mov    (%ebx),%ecx
  801f87:	8d 51 20             	lea    0x20(%ecx),%edx
  801f8a:	39 d0                	cmp    %edx,%eax
  801f8c:	73 e2                	jae    801f70 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f91:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f95:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f98:	89 c2                	mov    %eax,%edx
  801f9a:	c1 fa 1f             	sar    $0x1f,%edx
  801f9d:	89 d1                	mov    %edx,%ecx
  801f9f:	c1 e9 1b             	shr    $0x1b,%ecx
  801fa2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fa5:	83 e2 1f             	and    $0x1f,%edx
  801fa8:	29 ca                	sub    %ecx,%edx
  801faa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fb2:	83 c0 01             	add    $0x1,%eax
  801fb5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb8:	83 c7 01             	add    $0x1,%edi
  801fbb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fbe:	75 c2                	jne    801f82 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc3:	eb 05                	jmp    801fca <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	83 ec 18             	sub    $0x18,%esp
  801fdb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fde:	57                   	push   %edi
  801fdf:	e8 f8 f1 ff ff       	call   8011dc <fd2data>
  801fe4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fee:	eb 3d                	jmp    80202d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff0:	85 db                	test   %ebx,%ebx
  801ff2:	74 04                	je     801ff8 <devpipe_read+0x26>
				return i;
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	eb 44                	jmp    80203c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ff8:	89 f2                	mov    %esi,%edx
  801ffa:	89 f8                	mov    %edi,%eax
  801ffc:	e8 ec fe ff ff       	call   801eed <_pipeisclosed>
  802001:	85 c0                	test   %eax,%eax
  802003:	75 32                	jne    802037 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802005:	e8 18 eb ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80200a:	8b 06                	mov    (%esi),%eax
  80200c:	3b 46 04             	cmp    0x4(%esi),%eax
  80200f:	74 df                	je     801ff0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802011:	99                   	cltd   
  802012:	c1 ea 1b             	shr    $0x1b,%edx
  802015:	01 d0                	add    %edx,%eax
  802017:	83 e0 1f             	and    $0x1f,%eax
  80201a:	29 d0                	sub    %edx,%eax
  80201c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802024:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802027:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202a:	83 c3 01             	add    $0x1,%ebx
  80202d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802030:	75 d8                	jne    80200a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802032:	8b 45 10             	mov    0x10(%ebp),%eax
  802035:	eb 05                	jmp    80203c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80203c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	56                   	push   %esi
  802048:	53                   	push   %ebx
  802049:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80204c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	e8 9e f1 ff ff       	call   8011f3 <fd_alloc>
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	89 c2                	mov    %eax,%edx
  80205a:	85 c0                	test   %eax,%eax
  80205c:	0f 88 2c 01 00 00    	js     80218e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802062:	83 ec 04             	sub    $0x4,%esp
  802065:	68 07 04 00 00       	push   $0x407
  80206a:	ff 75 f4             	pushl  -0xc(%ebp)
  80206d:	6a 00                	push   $0x0
  80206f:	e8 cd ea ff ff       	call   800b41 <sys_page_alloc>
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	89 c2                	mov    %eax,%edx
  802079:	85 c0                	test   %eax,%eax
  80207b:	0f 88 0d 01 00 00    	js     80218e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802087:	50                   	push   %eax
  802088:	e8 66 f1 ff ff       	call   8011f3 <fd_alloc>
  80208d:	89 c3                	mov    %eax,%ebx
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	85 c0                	test   %eax,%eax
  802094:	0f 88 e2 00 00 00    	js     80217c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209a:	83 ec 04             	sub    $0x4,%esp
  80209d:	68 07 04 00 00       	push   $0x407
  8020a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a5:	6a 00                	push   $0x0
  8020a7:	e8 95 ea ff ff       	call   800b41 <sys_page_alloc>
  8020ac:	89 c3                	mov    %eax,%ebx
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	0f 88 c3 00 00 00    	js     80217c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020b9:	83 ec 0c             	sub    $0xc,%esp
  8020bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bf:	e8 18 f1 ff ff       	call   8011dc <fd2data>
  8020c4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c6:	83 c4 0c             	add    $0xc,%esp
  8020c9:	68 07 04 00 00       	push   $0x407
  8020ce:	50                   	push   %eax
  8020cf:	6a 00                	push   $0x0
  8020d1:	e8 6b ea ff ff       	call   800b41 <sys_page_alloc>
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	0f 88 89 00 00 00    	js     80216c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e9:	e8 ee f0 ff ff       	call   8011dc <fd2data>
  8020ee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020f5:	50                   	push   %eax
  8020f6:	6a 00                	push   $0x0
  8020f8:	56                   	push   %esi
  8020f9:	6a 00                	push   $0x0
  8020fb:	e8 84 ea ff ff       	call   800b84 <sys_page_map>
  802100:	89 c3                	mov    %eax,%ebx
  802102:	83 c4 20             	add    $0x20,%esp
  802105:	85 c0                	test   %eax,%eax
  802107:	78 55                	js     80215e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802109:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802112:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802117:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80211e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802127:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802129:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802133:	83 ec 0c             	sub    $0xc,%esp
  802136:	ff 75 f4             	pushl  -0xc(%ebp)
  802139:	e8 8e f0 ff ff       	call   8011cc <fd2num>
  80213e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802141:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802143:	83 c4 04             	add    $0x4,%esp
  802146:	ff 75 f0             	pushl  -0x10(%ebp)
  802149:	e8 7e f0 ff ff       	call   8011cc <fd2num>
  80214e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802151:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	ba 00 00 00 00       	mov    $0x0,%edx
  80215c:	eb 30                	jmp    80218e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80215e:	83 ec 08             	sub    $0x8,%esp
  802161:	56                   	push   %esi
  802162:	6a 00                	push   $0x0
  802164:	e8 5d ea ff ff       	call   800bc6 <sys_page_unmap>
  802169:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80216c:	83 ec 08             	sub    $0x8,%esp
  80216f:	ff 75 f0             	pushl  -0x10(%ebp)
  802172:	6a 00                	push   $0x0
  802174:	e8 4d ea ff ff       	call   800bc6 <sys_page_unmap>
  802179:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80217c:	83 ec 08             	sub    $0x8,%esp
  80217f:	ff 75 f4             	pushl  -0xc(%ebp)
  802182:	6a 00                	push   $0x0
  802184:	e8 3d ea ff ff       	call   800bc6 <sys_page_unmap>
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80218e:	89 d0                	mov    %edx,%eax
  802190:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    

00802197 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a0:	50                   	push   %eax
  8021a1:	ff 75 08             	pushl  0x8(%ebp)
  8021a4:	e8 99 f0 ff ff       	call   801242 <fd_lookup>
  8021a9:	89 c2                	mov    %eax,%edx
  8021ab:	83 c4 10             	add    $0x10,%esp
  8021ae:	85 d2                	test   %edx,%edx
  8021b0:	78 18                	js     8021ca <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b2:	83 ec 0c             	sub    $0xc,%esp
  8021b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b8:	e8 1f f0 ff ff       	call   8011dc <fd2data>
	return _pipeisclosed(fd, p);
  8021bd:	89 c2                	mov    %eax,%edx
  8021bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c2:	e8 26 fd ff ff       	call   801eed <_pipeisclosed>
  8021c7:	83 c4 10             	add    $0x10,%esp
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021dc:	68 4b 2d 80 00       	push   $0x802d4b
  8021e1:	ff 75 0c             	pushl  0xc(%ebp)
  8021e4:	e8 4f e5 ff ff       	call   800738 <strcpy>
	return 0;
}
  8021e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	57                   	push   %edi
  8021f4:	56                   	push   %esi
  8021f5:	53                   	push   %ebx
  8021f6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021fc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802201:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802207:	eb 2d                	jmp    802236 <devcons_write+0x46>
		m = n - tot;
  802209:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80220c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80220e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802211:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802216:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802219:	83 ec 04             	sub    $0x4,%esp
  80221c:	53                   	push   %ebx
  80221d:	03 45 0c             	add    0xc(%ebp),%eax
  802220:	50                   	push   %eax
  802221:	57                   	push   %edi
  802222:	e8 a3 e6 ff ff       	call   8008ca <memmove>
		sys_cputs(buf, m);
  802227:	83 c4 08             	add    $0x8,%esp
  80222a:	53                   	push   %ebx
  80222b:	57                   	push   %edi
  80222c:	e8 54 e8 ff ff       	call   800a85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802231:	01 de                	add    %ebx,%esi
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	89 f0                	mov    %esi,%eax
  802238:	3b 75 10             	cmp    0x10(%ebp),%esi
  80223b:	72 cc                	jb     802209 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80223d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802240:	5b                   	pop    %ebx
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    

00802245 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802250:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802254:	75 07                	jne    80225d <devcons_read+0x18>
  802256:	eb 28                	jmp    802280 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802258:	e8 c5 e8 ff ff       	call   800b22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80225d:	e8 41 e8 ff ff       	call   800aa3 <sys_cgetc>
  802262:	85 c0                	test   %eax,%eax
  802264:	74 f2                	je     802258 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802266:	85 c0                	test   %eax,%eax
  802268:	78 16                	js     802280 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80226a:	83 f8 04             	cmp    $0x4,%eax
  80226d:	74 0c                	je     80227b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80226f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802272:	88 02                	mov    %al,(%edx)
	return 1;
  802274:	b8 01 00 00 00       	mov    $0x1,%eax
  802279:	eb 05                	jmp    802280 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80227b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802280:	c9                   	leave  
  802281:	c3                   	ret    

00802282 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802288:	8b 45 08             	mov    0x8(%ebp),%eax
  80228b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80228e:	6a 01                	push   $0x1
  802290:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802293:	50                   	push   %eax
  802294:	e8 ec e7 ff ff       	call   800a85 <sys_cputs>
  802299:	83 c4 10             	add    $0x10,%esp
}
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <getchar>:

int
getchar(void)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022a4:	6a 01                	push   $0x1
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	50                   	push   %eax
  8022aa:	6a 00                	push   $0x0
  8022ac:	e8 00 f2 ff ff       	call   8014b1 <read>
	if (r < 0)
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	78 0f                	js     8022c7 <getchar+0x29>
		return r;
	if (r < 1)
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	7e 06                	jle    8022c2 <getchar+0x24>
		return -E_EOF;
	return c;
  8022bc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022c0:	eb 05                	jmp    8022c7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022c2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d2:	50                   	push   %eax
  8022d3:	ff 75 08             	pushl  0x8(%ebp)
  8022d6:	e8 67 ef ff ff       	call   801242 <fd_lookup>
  8022db:	83 c4 10             	add    $0x10,%esp
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	78 11                	js     8022f3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022eb:	39 10                	cmp    %edx,(%eax)
  8022ed:	0f 94 c0             	sete   %al
  8022f0:	0f b6 c0             	movzbl %al,%eax
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <opencons>:

int
opencons(void)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fe:	50                   	push   %eax
  8022ff:	e8 ef ee ff ff       	call   8011f3 <fd_alloc>
  802304:	83 c4 10             	add    $0x10,%esp
		return r;
  802307:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802309:	85 c0                	test   %eax,%eax
  80230b:	78 3e                	js     80234b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80230d:	83 ec 04             	sub    $0x4,%esp
  802310:	68 07 04 00 00       	push   $0x407
  802315:	ff 75 f4             	pushl  -0xc(%ebp)
  802318:	6a 00                	push   $0x0
  80231a:	e8 22 e8 ff ff       	call   800b41 <sys_page_alloc>
  80231f:	83 c4 10             	add    $0x10,%esp
		return r;
  802322:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802324:	85 c0                	test   %eax,%eax
  802326:	78 23                	js     80234b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802328:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80232e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802331:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802336:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80233d:	83 ec 0c             	sub    $0xc,%esp
  802340:	50                   	push   %eax
  802341:	e8 86 ee ff ff       	call   8011cc <fd2num>
  802346:	89 c2                	mov    %eax,%edx
  802348:	83 c4 10             	add    $0x10,%esp
}
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	c9                   	leave  
  80234e:	c3                   	ret    

0080234f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802354:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802357:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80235d:	e8 a1 e7 ff ff       	call   800b03 <sys_getenvid>
  802362:	83 ec 0c             	sub    $0xc,%esp
  802365:	ff 75 0c             	pushl  0xc(%ebp)
  802368:	ff 75 08             	pushl  0x8(%ebp)
  80236b:	56                   	push   %esi
  80236c:	50                   	push   %eax
  80236d:	68 58 2d 80 00       	push   $0x802d58
  802372:	e8 3a de ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802377:	83 c4 18             	add    $0x18,%esp
  80237a:	53                   	push   %ebx
  80237b:	ff 75 10             	pushl  0x10(%ebp)
  80237e:	e8 dd dd ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  802383:	c7 04 24 d9 2b 80 00 	movl   $0x802bd9,(%esp)
  80238a:	e8 22 de ff ff       	call   8001b1 <cprintf>
  80238f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802392:	cc                   	int3   
  802393:	eb fd                	jmp    802392 <_panic+0x43>

00802395 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802395:	55                   	push   %ebp
  802396:	89 e5                	mov    %esp,%ebp
  802398:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80239b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023a2:	75 2c                	jne    8023d0 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8023a4:	83 ec 04             	sub    $0x4,%esp
  8023a7:	6a 07                	push   $0x7
  8023a9:	68 00 f0 bf ee       	push   $0xeebff000
  8023ae:	6a 00                	push   $0x0
  8023b0:	e8 8c e7 ff ff       	call   800b41 <sys_page_alloc>
  8023b5:	83 c4 10             	add    $0x10,%esp
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	74 14                	je     8023d0 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8023bc:	83 ec 04             	sub    $0x4,%esp
  8023bf:	68 7c 2d 80 00       	push   $0x802d7c
  8023c4:	6a 21                	push   $0x21
  8023c6:	68 e0 2d 80 00       	push   $0x802de0
  8023cb:	e8 7f ff ff ff       	call   80234f <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d3:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8023d8:	83 ec 08             	sub    $0x8,%esp
  8023db:	68 04 24 80 00       	push   $0x802404
  8023e0:	6a 00                	push   $0x0
  8023e2:	e8 a5 e8 ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	79 14                	jns    802402 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8023ee:	83 ec 04             	sub    $0x4,%esp
  8023f1:	68 a8 2d 80 00       	push   $0x802da8
  8023f6:	6a 29                	push   $0x29
  8023f8:	68 e0 2d 80 00       	push   $0x802de0
  8023fd:	e8 4d ff ff ff       	call   80234f <_panic>
}
  802402:	c9                   	leave  
  802403:	c3                   	ret    

00802404 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802404:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802405:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80240a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80240c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80240f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802414:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802418:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80241c:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80241e:	83 c4 08             	add    $0x8,%esp
        popal
  802421:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802422:	83 c4 04             	add    $0x4,%esp
        popfl
  802425:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802426:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802427:	c3                   	ret    

00802428 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80242e:	89 d0                	mov    %edx,%eax
  802430:	c1 e8 16             	shr    $0x16,%eax
  802433:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80243a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80243f:	f6 c1 01             	test   $0x1,%cl
  802442:	74 1d                	je     802461 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802444:	c1 ea 0c             	shr    $0xc,%edx
  802447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80244e:	f6 c2 01             	test   $0x1,%dl
  802451:	74 0e                	je     802461 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802453:	c1 ea 0c             	shr    $0xc,%edx
  802456:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80245d:	ef 
  80245e:	0f b7 c0             	movzwl %ax,%eax
}
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	66 90                	xchg   %ax,%ax
  802465:	66 90                	xchg   %ax,%ax
  802467:	66 90                	xchg   %ax,%ax
  802469:	66 90                	xchg   %ax,%ax
  80246b:	66 90                	xchg   %ax,%ax
  80246d:	66 90                	xchg   %ax,%ax
  80246f:	90                   	nop

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	83 ec 10             	sub    $0x10,%esp
  802476:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80247a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80247e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802482:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802486:	85 d2                	test   %edx,%edx
  802488:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80248c:	89 34 24             	mov    %esi,(%esp)
  80248f:	89 c8                	mov    %ecx,%eax
  802491:	75 35                	jne    8024c8 <__udivdi3+0x58>
  802493:	39 f1                	cmp    %esi,%ecx
  802495:	0f 87 bd 00 00 00    	ja     802558 <__udivdi3+0xe8>
  80249b:	85 c9                	test   %ecx,%ecx
  80249d:	89 cd                	mov    %ecx,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f1                	div    %ecx
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 f0                	mov    %esi,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c6                	mov    %eax,%esi
  8024b4:	89 f8                	mov    %edi,%eax
  8024b6:	f7 f5                	div    %ebp
  8024b8:	89 f2                	mov    %esi,%edx
  8024ba:	83 c4 10             	add    $0x10,%esp
  8024bd:	5e                   	pop    %esi
  8024be:	5f                   	pop    %edi
  8024bf:	5d                   	pop    %ebp
  8024c0:	c3                   	ret    
  8024c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	3b 14 24             	cmp    (%esp),%edx
  8024cb:	77 7b                	ja     802548 <__udivdi3+0xd8>
  8024cd:	0f bd f2             	bsr    %edx,%esi
  8024d0:	83 f6 1f             	xor    $0x1f,%esi
  8024d3:	0f 84 97 00 00 00    	je     802570 <__udivdi3+0x100>
  8024d9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8024de:	89 d7                	mov    %edx,%edi
  8024e0:	89 f1                	mov    %esi,%ecx
  8024e2:	29 f5                	sub    %esi,%ebp
  8024e4:	d3 e7                	shl    %cl,%edi
  8024e6:	89 c2                	mov    %eax,%edx
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	d3 ea                	shr    %cl,%edx
  8024ec:	89 f1                	mov    %esi,%ecx
  8024ee:	09 fa                	or     %edi,%edx
  8024f0:	8b 3c 24             	mov    (%esp),%edi
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024f9:	89 e9                	mov    %ebp,%ecx
  8024fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802503:	89 fa                	mov    %edi,%edx
  802505:	d3 ea                	shr    %cl,%edx
  802507:	89 f1                	mov    %esi,%ecx
  802509:	d3 e7                	shl    %cl,%edi
  80250b:	89 e9                	mov    %ebp,%ecx
  80250d:	d3 e8                	shr    %cl,%eax
  80250f:	09 c7                	or     %eax,%edi
  802511:	89 f8                	mov    %edi,%eax
  802513:	f7 74 24 08          	divl   0x8(%esp)
  802517:	89 d5                	mov    %edx,%ebp
  802519:	89 c7                	mov    %eax,%edi
  80251b:	f7 64 24 0c          	mull   0xc(%esp)
  80251f:	39 d5                	cmp    %edx,%ebp
  802521:	89 14 24             	mov    %edx,(%esp)
  802524:	72 11                	jb     802537 <__udivdi3+0xc7>
  802526:	8b 54 24 04          	mov    0x4(%esp),%edx
  80252a:	89 f1                	mov    %esi,%ecx
  80252c:	d3 e2                	shl    %cl,%edx
  80252e:	39 c2                	cmp    %eax,%edx
  802530:	73 5e                	jae    802590 <__udivdi3+0x120>
  802532:	3b 2c 24             	cmp    (%esp),%ebp
  802535:	75 59                	jne    802590 <__udivdi3+0x120>
  802537:	8d 47 ff             	lea    -0x1(%edi),%eax
  80253a:	31 f6                	xor    %esi,%esi
  80253c:	89 f2                	mov    %esi,%edx
  80253e:	83 c4 10             	add    $0x10,%esp
  802541:	5e                   	pop    %esi
  802542:	5f                   	pop    %edi
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    
  802545:	8d 76 00             	lea    0x0(%esi),%esi
  802548:	31 f6                	xor    %esi,%esi
  80254a:	31 c0                	xor    %eax,%eax
  80254c:	89 f2                	mov    %esi,%edx
  80254e:	83 c4 10             	add    $0x10,%esp
  802551:	5e                   	pop    %esi
  802552:	5f                   	pop    %edi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    
  802555:	8d 76 00             	lea    0x0(%esi),%esi
  802558:	89 f2                	mov    %esi,%edx
  80255a:	31 f6                	xor    %esi,%esi
  80255c:	89 f8                	mov    %edi,%eax
  80255e:	f7 f1                	div    %ecx
  802560:	89 f2                	mov    %esi,%edx
  802562:	83 c4 10             	add    $0x10,%esp
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802574:	76 0b                	jbe    802581 <__udivdi3+0x111>
  802576:	31 c0                	xor    %eax,%eax
  802578:	3b 14 24             	cmp    (%esp),%edx
  80257b:	0f 83 37 ff ff ff    	jae    8024b8 <__udivdi3+0x48>
  802581:	b8 01 00 00 00       	mov    $0x1,%eax
  802586:	e9 2d ff ff ff       	jmp    8024b8 <__udivdi3+0x48>
  80258b:	90                   	nop
  80258c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802590:	89 f8                	mov    %edi,%eax
  802592:	31 f6                	xor    %esi,%esi
  802594:	e9 1f ff ff ff       	jmp    8024b8 <__udivdi3+0x48>
  802599:	66 90                	xchg   %ax,%ax
  80259b:	66 90                	xchg   %ax,%ax
  80259d:	66 90                	xchg   %ax,%ax
  80259f:	90                   	nop

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	83 ec 20             	sub    $0x20,%esp
  8025a6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8025aa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b2:	89 c6                	mov    %eax,%esi
  8025b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025b8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025bc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8025c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8025c8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8025cc:	85 c0                	test   %eax,%eax
  8025ce:	89 c2                	mov    %eax,%edx
  8025d0:	75 1e                	jne    8025f0 <__umoddi3+0x50>
  8025d2:	39 f7                	cmp    %esi,%edi
  8025d4:	76 52                	jbe    802628 <__umoddi3+0x88>
  8025d6:	89 c8                	mov    %ecx,%eax
  8025d8:	89 f2                	mov    %esi,%edx
  8025da:	f7 f7                	div    %edi
  8025dc:	89 d0                	mov    %edx,%eax
  8025de:	31 d2                	xor    %edx,%edx
  8025e0:	83 c4 20             	add    $0x20,%esp
  8025e3:	5e                   	pop    %esi
  8025e4:	5f                   	pop    %edi
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    
  8025e7:	89 f6                	mov    %esi,%esi
  8025e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8025f0:	39 f0                	cmp    %esi,%eax
  8025f2:	77 5c                	ja     802650 <__umoddi3+0xb0>
  8025f4:	0f bd e8             	bsr    %eax,%ebp
  8025f7:	83 f5 1f             	xor    $0x1f,%ebp
  8025fa:	75 64                	jne    802660 <__umoddi3+0xc0>
  8025fc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802600:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802604:	0f 86 f6 00 00 00    	jbe    802700 <__umoddi3+0x160>
  80260a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80260e:	0f 82 ec 00 00 00    	jb     802700 <__umoddi3+0x160>
  802614:	8b 44 24 14          	mov    0x14(%esp),%eax
  802618:	8b 54 24 18          	mov    0x18(%esp),%edx
  80261c:	83 c4 20             	add    $0x20,%esp
  80261f:	5e                   	pop    %esi
  802620:	5f                   	pop    %edi
  802621:	5d                   	pop    %ebp
  802622:	c3                   	ret    
  802623:	90                   	nop
  802624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802628:	85 ff                	test   %edi,%edi
  80262a:	89 fd                	mov    %edi,%ebp
  80262c:	75 0b                	jne    802639 <__umoddi3+0x99>
  80262e:	b8 01 00 00 00       	mov    $0x1,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f7                	div    %edi
  802637:	89 c5                	mov    %eax,%ebp
  802639:	8b 44 24 10          	mov    0x10(%esp),%eax
  80263d:	31 d2                	xor    %edx,%edx
  80263f:	f7 f5                	div    %ebp
  802641:	89 c8                	mov    %ecx,%eax
  802643:	f7 f5                	div    %ebp
  802645:	eb 95                	jmp    8025dc <__umoddi3+0x3c>
  802647:	89 f6                	mov    %esi,%esi
  802649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 f2                	mov    %esi,%edx
  802654:	83 c4 20             	add    $0x20,%esp
  802657:	5e                   	pop    %esi
  802658:	5f                   	pop    %edi
  802659:	5d                   	pop    %ebp
  80265a:	c3                   	ret    
  80265b:	90                   	nop
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	b8 20 00 00 00       	mov    $0x20,%eax
  802665:	89 e9                	mov    %ebp,%ecx
  802667:	29 e8                	sub    %ebp,%eax
  802669:	d3 e2                	shl    %cl,%edx
  80266b:	89 c7                	mov    %eax,%edi
  80266d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802671:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802675:	89 f9                	mov    %edi,%ecx
  802677:	d3 e8                	shr    %cl,%eax
  802679:	89 c1                	mov    %eax,%ecx
  80267b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80267f:	09 d1                	or     %edx,%ecx
  802681:	89 fa                	mov    %edi,%edx
  802683:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802687:	89 e9                	mov    %ebp,%ecx
  802689:	d3 e0                	shl    %cl,%eax
  80268b:	89 f9                	mov    %edi,%ecx
  80268d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802691:	89 f0                	mov    %esi,%eax
  802693:	d3 e8                	shr    %cl,%eax
  802695:	89 e9                	mov    %ebp,%ecx
  802697:	89 c7                	mov    %eax,%edi
  802699:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80269d:	d3 e6                	shl    %cl,%esi
  80269f:	89 d1                	mov    %edx,%ecx
  8026a1:	89 fa                	mov    %edi,%edx
  8026a3:	d3 e8                	shr    %cl,%eax
  8026a5:	89 e9                	mov    %ebp,%ecx
  8026a7:	09 f0                	or     %esi,%eax
  8026a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8026ad:	f7 74 24 10          	divl   0x10(%esp)
  8026b1:	d3 e6                	shl    %cl,%esi
  8026b3:	89 d1                	mov    %edx,%ecx
  8026b5:	f7 64 24 0c          	mull   0xc(%esp)
  8026b9:	39 d1                	cmp    %edx,%ecx
  8026bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8026bf:	89 d7                	mov    %edx,%edi
  8026c1:	89 c6                	mov    %eax,%esi
  8026c3:	72 0a                	jb     8026cf <__umoddi3+0x12f>
  8026c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8026c9:	73 10                	jae    8026db <__umoddi3+0x13b>
  8026cb:	39 d1                	cmp    %edx,%ecx
  8026cd:	75 0c                	jne    8026db <__umoddi3+0x13b>
  8026cf:	89 d7                	mov    %edx,%edi
  8026d1:	89 c6                	mov    %eax,%esi
  8026d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8026d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8026db:	89 ca                	mov    %ecx,%edx
  8026dd:	89 e9                	mov    %ebp,%ecx
  8026df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026e3:	29 f0                	sub    %esi,%eax
  8026e5:	19 fa                	sbb    %edi,%edx
  8026e7:	d3 e8                	shr    %cl,%eax
  8026e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8026ee:	89 d7                	mov    %edx,%edi
  8026f0:	d3 e7                	shl    %cl,%edi
  8026f2:	89 e9                	mov    %ebp,%ecx
  8026f4:	09 f8                	or     %edi,%eax
  8026f6:	d3 ea                	shr    %cl,%edx
  8026f8:	83 c4 20             	add    $0x20,%esp
  8026fb:	5e                   	pop    %esi
  8026fc:	5f                   	pop    %edi
  8026fd:	5d                   	pop    %ebp
  8026fe:	c3                   	ret    
  8026ff:	90                   	nop
  802700:	8b 74 24 10          	mov    0x10(%esp),%esi
  802704:	29 f9                	sub    %edi,%ecx
  802706:	19 c6                	sbb    %eax,%esi
  802708:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80270c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802710:	e9 ff fe ff ff       	jmp    802614 <__umoddi3+0x74>
