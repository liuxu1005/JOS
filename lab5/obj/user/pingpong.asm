
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
  80003c:	e8 d3 0d 00 00       	call   800e14 <fork>
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
  800054:	68 00 22 80 00       	push   $0x802200
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 33 10 00 00       	call   80109f <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 b7 0f 00 00       	call   801036 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 7a 0a 00 00       	call   800b03 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 16 22 80 00       	push   $0x802216
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
  8000a9:	e8 f1 0f 00 00       	call   80109f <ipc_send>
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
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80010a:	e8 e9 11 00 00       	call   8012f8 <close_all>
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
  800214:	e8 37 1d 00 00       	call   801f50 <__udivdi3>
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
  800252:	e8 29 1e 00 00       	call   802080 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 33 22 80 00 	movsbl 0x802233(%eax),%eax
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
  800356:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
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
  80041a:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	75 18                	jne    80043d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800425:	50                   	push   %eax
  800426:	68 4b 22 80 00       	push   $0x80224b
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
  80043e:	68 95 27 80 00       	push   $0x802795
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
  80046b:	ba 44 22 80 00       	mov    $0x802244,%edx
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
  800aea:	68 5f 25 80 00       	push   $0x80255f
  800aef:	6a 23                	push   $0x23
  800af1:	68 7c 25 80 00       	push   $0x80257c
  800af6:	e8 3d 13 00 00       	call   801e38 <_panic>

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
  800b6b:	68 5f 25 80 00       	push   $0x80255f
  800b70:	6a 23                	push   $0x23
  800b72:	68 7c 25 80 00       	push   $0x80257c
  800b77:	e8 bc 12 00 00       	call   801e38 <_panic>

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
  800bad:	68 5f 25 80 00       	push   $0x80255f
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 7c 25 80 00       	push   $0x80257c
  800bb9:	e8 7a 12 00 00       	call   801e38 <_panic>

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
  800bef:	68 5f 25 80 00       	push   $0x80255f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 7c 25 80 00       	push   $0x80257c
  800bfb:	e8 38 12 00 00       	call   801e38 <_panic>

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
  800c31:	68 5f 25 80 00       	push   $0x80255f
  800c36:	6a 23                	push   $0x23
  800c38:	68 7c 25 80 00       	push   $0x80257c
  800c3d:	e8 f6 11 00 00       	call   801e38 <_panic>
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
  800c73:	68 5f 25 80 00       	push   $0x80255f
  800c78:	6a 23                	push   $0x23
  800c7a:	68 7c 25 80 00       	push   $0x80257c
  800c7f:	e8 b4 11 00 00       	call   801e38 <_panic>

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
  800cb5:	68 5f 25 80 00       	push   $0x80255f
  800cba:	6a 23                	push   $0x23
  800cbc:	68 7c 25 80 00       	push   $0x80257c
  800cc1:	e8 72 11 00 00       	call   801e38 <_panic>

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
  800d19:	68 5f 25 80 00       	push   $0x80255f
  800d1e:	6a 23                	push   $0x23
  800d20:	68 7c 25 80 00       	push   $0x80257c
  800d25:	e8 0e 11 00 00       	call   801e38 <_panic>

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

00800d32 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	53                   	push   %ebx
  800d36:	83 ec 04             	sub    $0x4,%esp
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d3c:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d3e:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d42:	74 2e                	je     800d72 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	c1 ea 16             	shr    $0x16,%edx
  800d49:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d50:	f6 c2 01             	test   $0x1,%dl
  800d53:	74 1d                	je     800d72 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	c1 ea 0c             	shr    $0xc,%edx
  800d5a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d61:	f6 c1 01             	test   $0x1,%cl
  800d64:	74 0c                	je     800d72 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d6d:	f6 c6 08             	test   $0x8,%dh
  800d70:	75 14                	jne    800d86 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	68 8c 25 80 00       	push   $0x80258c
  800d7a:	6a 21                	push   $0x21
  800d7c:	68 1f 26 80 00       	push   $0x80261f
  800d81:	e8 b2 10 00 00       	call   801e38 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800d86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8b:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	6a 07                	push   $0x7
  800d92:	68 00 f0 7f 00       	push   $0x7ff000
  800d97:	6a 00                	push   $0x0
  800d99:	e8 a3 fd ff ff       	call   800b41 <sys_page_alloc>
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	79 14                	jns    800db9 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	68 2a 26 80 00       	push   $0x80262a
  800dad:	6a 2b                	push   $0x2b
  800daf:	68 1f 26 80 00       	push   $0x80261f
  800db4:	e8 7f 10 00 00       	call   801e38 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	68 00 10 00 00       	push   $0x1000
  800dc1:	53                   	push   %ebx
  800dc2:	68 00 f0 7f 00       	push   $0x7ff000
  800dc7:	e8 fe fa ff ff       	call   8008ca <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800dcc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dd3:	53                   	push   %ebx
  800dd4:	6a 00                	push   $0x0
  800dd6:	68 00 f0 7f 00       	push   $0x7ff000
  800ddb:	6a 00                	push   $0x0
  800ddd:	e8 a2 fd ff ff       	call   800b84 <sys_page_map>
  800de2:	83 c4 20             	add    $0x20,%esp
  800de5:	85 c0                	test   %eax,%eax
  800de7:	79 14                	jns    800dfd <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	68 40 26 80 00       	push   $0x802640
  800df1:	6a 2e                	push   $0x2e
  800df3:	68 1f 26 80 00       	push   $0x80261f
  800df8:	e8 3b 10 00 00       	call   801e38 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800dfd:	83 ec 08             	sub    $0x8,%esp
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	6a 00                	push   $0x0
  800e07:	e8 ba fd ff ff       	call   800bc6 <sys_page_unmap>
  800e0c:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e1d:	68 32 0d 80 00       	push   $0x800d32
  800e22:	e8 57 10 00 00       	call   801e7e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e27:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2c:	cd 30                	int    $0x30
  800e2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	85 c0                	test   %eax,%eax
  800e36:	79 12                	jns    800e4a <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e38:	50                   	push   %eax
  800e39:	68 54 26 80 00       	push   $0x802654
  800e3e:	6a 6d                	push   $0x6d
  800e40:	68 1f 26 80 00       	push   $0x80261f
  800e45:	e8 ee 0f 00 00       	call   801e38 <_panic>
  800e4a:	89 c7                	mov    %eax,%edi
  800e4c:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e51:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e55:	75 21                	jne    800e78 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e57:	e8 a7 fc ff ff       	call   800b03 <sys_getenvid>
  800e5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e69:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	e9 9c 01 00 00       	jmp    801014 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e78:	89 d8                	mov    %ebx,%eax
  800e7a:	c1 e8 16             	shr    $0x16,%eax
  800e7d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e84:	a8 01                	test   $0x1,%al
  800e86:	0f 84 f3 00 00 00    	je     800f7f <fork+0x16b>
  800e8c:	89 d8                	mov    %ebx,%eax
  800e8e:	c1 e8 0c             	shr    $0xc,%eax
  800e91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e98:	f6 c2 01             	test   $0x1,%dl
  800e9b:	0f 84 de 00 00 00    	je     800f7f <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800ea1:	89 c6                	mov    %eax,%esi
  800ea3:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800ea6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ead:	f6 c6 04             	test   $0x4,%dh
  800eb0:	74 37                	je     800ee9 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800eb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	25 07 0e 00 00       	and    $0xe07,%eax
  800ec1:	50                   	push   %eax
  800ec2:	56                   	push   %esi
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 b8 fc ff ff       	call   800b84 <sys_page_map>
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	0f 89 a8 00 00 00    	jns    800f7f <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800ed7:	50                   	push   %eax
  800ed8:	68 b0 25 80 00       	push   $0x8025b0
  800edd:	6a 49                	push   $0x49
  800edf:	68 1f 26 80 00       	push   $0x80261f
  800ee4:	e8 4f 0f 00 00       	call   801e38 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800ee9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef0:	f6 c6 08             	test   $0x8,%dh
  800ef3:	75 0b                	jne    800f00 <fork+0xec>
  800ef5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efc:	a8 02                	test   $0x2,%al
  800efe:	74 57                	je     800f57 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	68 05 08 00 00       	push   $0x805
  800f08:	56                   	push   %esi
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	6a 00                	push   $0x0
  800f0d:	e8 72 fc ff ff       	call   800b84 <sys_page_map>
  800f12:	83 c4 20             	add    $0x20,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	79 12                	jns    800f2b <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800f19:	50                   	push   %eax
  800f1a:	68 b0 25 80 00       	push   $0x8025b0
  800f1f:	6a 4c                	push   $0x4c
  800f21:	68 1f 26 80 00       	push   $0x80261f
  800f26:	e8 0d 0f 00 00       	call   801e38 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	68 05 08 00 00       	push   $0x805
  800f33:	56                   	push   %esi
  800f34:	6a 00                	push   $0x0
  800f36:	56                   	push   %esi
  800f37:	6a 00                	push   $0x0
  800f39:	e8 46 fc ff ff       	call   800b84 <sys_page_map>
  800f3e:	83 c4 20             	add    $0x20,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 3a                	jns    800f7f <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  800f45:	50                   	push   %eax
  800f46:	68 d4 25 80 00       	push   $0x8025d4
  800f4b:	6a 4e                	push   $0x4e
  800f4d:	68 1f 26 80 00       	push   $0x80261f
  800f52:	e8 e1 0e 00 00       	call   801e38 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	6a 05                	push   $0x5
  800f5c:	56                   	push   %esi
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 1e fc ff ff       	call   800b84 <sys_page_map>
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	79 12                	jns    800f7f <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  800f6d:	50                   	push   %eax
  800f6e:	68 fc 25 80 00       	push   $0x8025fc
  800f73:	6a 50                	push   $0x50
  800f75:	68 1f 26 80 00       	push   $0x80261f
  800f7a:	e8 b9 0e 00 00       	call   801e38 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800f7f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f85:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f8b:	0f 85 e7 fe ff ff    	jne    800e78 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	6a 07                	push   $0x7
  800f96:	68 00 f0 bf ee       	push   $0xeebff000
  800f9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9e:	e8 9e fb ff ff       	call   800b41 <sys_page_alloc>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 14                	jns    800fbe <fork+0x1aa>
                panic("user stack alloc failure\n");	
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	68 64 26 80 00       	push   $0x802664
  800fb2:	6a 76                	push   $0x76
  800fb4:	68 1f 26 80 00       	push   $0x80261f
  800fb9:	e8 7a 0e 00 00       	call   801e38 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	68 ed 1e 80 00       	push   $0x801eed
  800fc6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc9:	e8 be fc ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	79 14                	jns    800fe9 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  800fd5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd8:	68 7e 26 80 00       	push   $0x80267e
  800fdd:	6a 79                	push   $0x79
  800fdf:	68 1f 26 80 00       	push   $0x80261f
  800fe4:	e8 4f 0e 00 00       	call   801e38 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	6a 02                	push   $0x2
  800fee:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff1:	e8 12 fc ff ff       	call   800c08 <sys_env_set_status>
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 14                	jns    801011 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  800ffd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801000:	68 9b 26 80 00       	push   $0x80269b
  801005:	6a 7b                	push   $0x7b
  801007:	68 1f 26 80 00       	push   $0x80261f
  80100c:	e8 27 0e 00 00       	call   801e38 <_panic>
        return forkid;
  801011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801014:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sfork>:

// Challenge!
int
sfork(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801022:	68 b2 26 80 00       	push   $0x8026b2
  801027:	68 83 00 00 00       	push   $0x83
  80102c:	68 1f 26 80 00       	push   $0x80261f
  801031:	e8 02 0e 00 00       	call   801e38 <_panic>

00801036 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	8b 75 08             	mov    0x8(%ebp),%esi
  80103e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801041:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801044:	85 c0                	test   %eax,%eax
  801046:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80104b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	50                   	push   %eax
  801052:	e8 9a fc ff ff       	call   800cf1 <sys_ipc_recv>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	79 16                	jns    801074 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80105e:	85 f6                	test   %esi,%esi
  801060:	74 06                	je     801068 <ipc_recv+0x32>
  801062:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801068:	85 db                	test   %ebx,%ebx
  80106a:	74 2c                	je     801098 <ipc_recv+0x62>
  80106c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801072:	eb 24                	jmp    801098 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801074:	85 f6                	test   %esi,%esi
  801076:	74 0a                	je     801082 <ipc_recv+0x4c>
  801078:	a1 04 40 80 00       	mov    0x804004,%eax
  80107d:	8b 40 74             	mov    0x74(%eax),%eax
  801080:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801082:	85 db                	test   %ebx,%ebx
  801084:	74 0a                	je     801090 <ipc_recv+0x5a>
  801086:	a1 04 40 80 00       	mov    0x804004,%eax
  80108b:	8b 40 78             	mov    0x78(%eax),%eax
  80108e:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801090:	a1 04 40 80 00       	mov    0x804004,%eax
  801095:	8b 40 70             	mov    0x70(%eax),%eax
}
  801098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8010b1:	85 db                	test   %ebx,%ebx
  8010b3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010b8:	0f 44 d8             	cmove  %eax,%ebx
  8010bb:	eb 1c                	jmp    8010d9 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8010bd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010c0:	74 12                	je     8010d4 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8010c2:	50                   	push   %eax
  8010c3:	68 c8 26 80 00       	push   $0x8026c8
  8010c8:	6a 39                	push   $0x39
  8010ca:	68 e3 26 80 00       	push   $0x8026e3
  8010cf:	e8 64 0d 00 00       	call   801e38 <_panic>
                 sys_yield();
  8010d4:	e8 49 fa ff ff       	call   800b22 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8010d9:	ff 75 14             	pushl  0x14(%ebp)
  8010dc:	53                   	push   %ebx
  8010dd:	56                   	push   %esi
  8010de:	57                   	push   %edi
  8010df:	e8 ea fb ff ff       	call   800cce <sys_ipc_try_send>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 d2                	js     8010bd <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8010eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010fe:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801101:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801107:	8b 52 50             	mov    0x50(%edx),%edx
  80110a:	39 ca                	cmp    %ecx,%edx
  80110c:	75 0d                	jne    80111b <ipc_find_env+0x28>
			return envs[i].env_id;
  80110e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801111:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801116:	8b 40 08             	mov    0x8(%eax),%eax
  801119:	eb 0e                	jmp    801129 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80111b:	83 c0 01             	add    $0x1,%eax
  80111e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801123:	75 d9                	jne    8010fe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801125:	66 b8 00 00          	mov    $0x0,%ax
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	05 00 00 00 30       	add    $0x30000000,%eax
  801136:	c1 e8 0c             	shr    $0xc,%eax
}
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801146:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801158:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80115d:	89 c2                	mov    %eax,%edx
  80115f:	c1 ea 16             	shr    $0x16,%edx
  801162:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801169:	f6 c2 01             	test   $0x1,%dl
  80116c:	74 11                	je     80117f <fd_alloc+0x2d>
  80116e:	89 c2                	mov    %eax,%edx
  801170:	c1 ea 0c             	shr    $0xc,%edx
  801173:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117a:	f6 c2 01             	test   $0x1,%dl
  80117d:	75 09                	jne    801188 <fd_alloc+0x36>
			*fd_store = fd;
  80117f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
  801186:	eb 17                	jmp    80119f <fd_alloc+0x4d>
  801188:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80118d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801192:	75 c9                	jne    80115d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801194:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80119a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a7:	83 f8 1f             	cmp    $0x1f,%eax
  8011aa:	77 36                	ja     8011e2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ac:	c1 e0 0c             	shl    $0xc,%eax
  8011af:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	c1 ea 16             	shr    $0x16,%edx
  8011b9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c0:	f6 c2 01             	test   $0x1,%dl
  8011c3:	74 24                	je     8011e9 <fd_lookup+0x48>
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	c1 ea 0c             	shr    $0xc,%edx
  8011ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d1:	f6 c2 01             	test   $0x1,%dl
  8011d4:	74 1a                	je     8011f0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e0:	eb 13                	jmp    8011f5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e7:	eb 0c                	jmp    8011f5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ee:	eb 05                	jmp    8011f5 <fd_lookup+0x54>
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 08             	sub    $0x8,%esp
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801200:	ba 6c 27 80 00       	mov    $0x80276c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801205:	eb 13                	jmp    80121a <dev_lookup+0x23>
  801207:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80120a:	39 08                	cmp    %ecx,(%eax)
  80120c:	75 0c                	jne    80121a <dev_lookup+0x23>
			*dev = devtab[i];
  80120e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801211:	89 01                	mov    %eax,(%ecx)
			return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
  801218:	eb 2e                	jmp    801248 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80121a:	8b 02                	mov    (%edx),%eax
  80121c:	85 c0                	test   %eax,%eax
  80121e:	75 e7                	jne    801207 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801220:	a1 04 40 80 00       	mov    0x804004,%eax
  801225:	8b 40 48             	mov    0x48(%eax),%eax
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	51                   	push   %ecx
  80122c:	50                   	push   %eax
  80122d:	68 f0 26 80 00       	push   $0x8026f0
  801232:	e8 7a ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 10             	sub    $0x10,%esp
  801252:	8b 75 08             	mov    0x8(%ebp),%esi
  801255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801262:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801265:	50                   	push   %eax
  801266:	e8 36 ff ff ff       	call   8011a1 <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 05                	js     801277 <fd_close+0x2d>
	    || fd != fd2)
  801272:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801275:	74 0c                	je     801283 <fd_close+0x39>
		return (must_exist ? r : 0);
  801277:	84 db                	test   %bl,%bl
  801279:	ba 00 00 00 00       	mov    $0x0,%edx
  80127e:	0f 44 c2             	cmove  %edx,%eax
  801281:	eb 41                	jmp    8012c4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	ff 36                	pushl  (%esi)
  80128c:	e8 66 ff ff ff       	call   8011f7 <dev_lookup>
  801291:	89 c3                	mov    %eax,%ebx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 1a                	js     8012b4 <fd_close+0x6a>
		if (dev->dev_close)
  80129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	74 0b                	je     8012b4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	56                   	push   %esi
  8012ad:	ff d0                	call   *%eax
  8012af:	89 c3                	mov    %eax,%ebx
  8012b1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	56                   	push   %esi
  8012b8:	6a 00                	push   $0x0
  8012ba:	e8 07 f9 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	89 d8                	mov    %ebx,%eax
}
  8012c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c7:	5b                   	pop    %ebx
  8012c8:	5e                   	pop    %esi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	ff 75 08             	pushl  0x8(%ebp)
  8012d8:	e8 c4 fe ff ff       	call   8011a1 <fd_lookup>
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	83 c4 08             	add    $0x8,%esp
  8012e2:	85 d2                	test   %edx,%edx
  8012e4:	78 10                	js     8012f6 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	6a 01                	push   $0x1
  8012eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ee:	e8 57 ff ff ff       	call   80124a <fd_close>
  8012f3:	83 c4 10             	add    $0x10,%esp
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <close_all>:

void
close_all(void)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	53                   	push   %ebx
  801308:	e8 be ff ff ff       	call   8012cb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130d:	83 c3 01             	add    $0x1,%ebx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	83 fb 20             	cmp    $0x20,%ebx
  801316:	75 ec                	jne    801304 <close_all+0xc>
		close(i);
}
  801318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	57                   	push   %edi
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
  801323:	83 ec 2c             	sub    $0x2c,%esp
  801326:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801329:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	pushl  0x8(%ebp)
  801330:	e8 6c fe ff ff       	call   8011a1 <fd_lookup>
  801335:	89 c2                	mov    %eax,%edx
  801337:	83 c4 08             	add    $0x8,%esp
  80133a:	85 d2                	test   %edx,%edx
  80133c:	0f 88 c1 00 00 00    	js     801403 <dup+0xe6>
		return r;
	close(newfdnum);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	56                   	push   %esi
  801346:	e8 80 ff ff ff       	call   8012cb <close>

	newfd = INDEX2FD(newfdnum);
  80134b:	89 f3                	mov    %esi,%ebx
  80134d:	c1 e3 0c             	shl    $0xc,%ebx
  801350:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801356:	83 c4 04             	add    $0x4,%esp
  801359:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135c:	e8 da fd ff ff       	call   80113b <fd2data>
  801361:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 d0 fd ff ff       	call   80113b <fd2data>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801371:	89 f8                	mov    %edi,%eax
  801373:	c1 e8 16             	shr    $0x16,%eax
  801376:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137d:	a8 01                	test   $0x1,%al
  80137f:	74 37                	je     8013b8 <dup+0x9b>
  801381:	89 f8                	mov    %edi,%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
  801386:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 26                	je     8013b8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a1:	50                   	push   %eax
  8013a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a5:	6a 00                	push   $0x0
  8013a7:	57                   	push   %edi
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 d5 f7 ff ff       	call   800b84 <sys_page_map>
  8013af:	89 c7                	mov    %eax,%edi
  8013b1:	83 c4 20             	add    $0x20,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 2e                	js     8013e6 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	c1 e8 0c             	shr    $0xc,%eax
  8013c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cf:	50                   	push   %eax
  8013d0:	53                   	push   %ebx
  8013d1:	6a 00                	push   $0x0
  8013d3:	52                   	push   %edx
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 a9 f7 ff ff       	call   800b84 <sys_page_map>
  8013db:	89 c7                	mov    %eax,%edi
  8013dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	79 1d                	jns    801403 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 d5 f7 ff ff       	call   800bc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 c8 f7 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 f8                	mov    %edi,%eax
}
  801403:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 14             	sub    $0x14,%esp
  801412:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	53                   	push   %ebx
  80141a:	e8 82 fd ff ff       	call   8011a1 <fd_lookup>
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 c0                	test   %eax,%eax
  801426:	78 6d                	js     801495 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	ff 30                	pushl  (%eax)
  801434:	e8 be fd ff ff       	call   8011f7 <dev_lookup>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 4c                	js     80148c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801440:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801443:	8b 42 08             	mov    0x8(%edx),%eax
  801446:	83 e0 03             	and    $0x3,%eax
  801449:	83 f8 01             	cmp    $0x1,%eax
  80144c:	75 21                	jne    80146f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144e:	a1 04 40 80 00       	mov    0x804004,%eax
  801453:	8b 40 48             	mov    0x48(%eax),%eax
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	53                   	push   %ebx
  80145a:	50                   	push   %eax
  80145b:	68 31 27 80 00       	push   $0x802731
  801460:	e8 4c ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146d:	eb 26                	jmp    801495 <read+0x8a>
	}
	if (!dev->dev_read)
  80146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801472:	8b 40 08             	mov    0x8(%eax),%eax
  801475:	85 c0                	test   %eax,%eax
  801477:	74 17                	je     801490 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	ff 75 10             	pushl  0x10(%ebp)
  80147f:	ff 75 0c             	pushl  0xc(%ebp)
  801482:	52                   	push   %edx
  801483:	ff d0                	call   *%eax
  801485:	89 c2                	mov    %eax,%edx
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	eb 09                	jmp    801495 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	eb 05                	jmp    801495 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801490:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801495:	89 d0                	mov    %edx,%eax
  801497:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	57                   	push   %edi
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b0:	eb 21                	jmp    8014d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b2:	83 ec 04             	sub    $0x4,%esp
  8014b5:	89 f0                	mov    %esi,%eax
  8014b7:	29 d8                	sub    %ebx,%eax
  8014b9:	50                   	push   %eax
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	03 45 0c             	add    0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	57                   	push   %edi
  8014c1:	e8 45 ff ff ff       	call   80140b <read>
		if (m < 0)
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 0c                	js     8014d9 <readn+0x3d>
			return m;
		if (m == 0)
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	74 06                	je     8014d7 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d1:	01 c3                	add    %eax,%ebx
  8014d3:	39 f3                	cmp    %esi,%ebx
  8014d5:	72 db                	jb     8014b2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014d7:	89 d8                	mov    %ebx,%eax
}
  8014d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014dc:	5b                   	pop    %ebx
  8014dd:	5e                   	pop    %esi
  8014de:	5f                   	pop    %edi
  8014df:	5d                   	pop    %ebp
  8014e0:	c3                   	ret    

008014e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 14             	sub    $0x14,%esp
  8014e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	53                   	push   %ebx
  8014f0:	e8 ac fc ff ff       	call   8011a1 <fd_lookup>
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 68                	js     801566 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801508:	ff 30                	pushl  (%eax)
  80150a:	e8 e8 fc ff ff       	call   8011f7 <dev_lookup>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 47                	js     80155d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151d:	75 21                	jne    801540 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80151f:	a1 04 40 80 00       	mov    0x804004,%eax
  801524:	8b 40 48             	mov    0x48(%eax),%eax
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	53                   	push   %ebx
  80152b:	50                   	push   %eax
  80152c:	68 4d 27 80 00       	push   $0x80274d
  801531:	e8 7b ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153e:	eb 26                	jmp    801566 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801540:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801543:	8b 52 0c             	mov    0xc(%edx),%edx
  801546:	85 d2                	test   %edx,%edx
  801548:	74 17                	je     801561 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	ff 75 10             	pushl  0x10(%ebp)
  801550:	ff 75 0c             	pushl  0xc(%ebp)
  801553:	50                   	push   %eax
  801554:	ff d2                	call   *%edx
  801556:	89 c2                	mov    %eax,%edx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	eb 09                	jmp    801566 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155d:	89 c2                	mov    %eax,%edx
  80155f:	eb 05                	jmp    801566 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801561:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801566:	89 d0                	mov    %edx,%eax
  801568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <seek>:

int
seek(int fdnum, off_t offset)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801573:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	ff 75 08             	pushl  0x8(%ebp)
  80157a:	e8 22 fc ff ff       	call   8011a1 <fd_lookup>
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 0e                	js     801594 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801586:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801589:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80158f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	53                   	push   %ebx
  8015a5:	e8 f7 fb ff ff       	call   8011a1 <fd_lookup>
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 65                	js     801618 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 33 fc ff ff       	call   8011f7 <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 44                	js     80160f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d2:	75 21                	jne    8015f5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015d4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d9:	8b 40 48             	mov    0x48(%eax),%eax
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	53                   	push   %ebx
  8015e0:	50                   	push   %eax
  8015e1:	68 10 27 80 00       	push   $0x802710
  8015e6:	e8 c6 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f3:	eb 23                	jmp    801618 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f8:	8b 52 18             	mov    0x18(%edx),%edx
  8015fb:	85 d2                	test   %edx,%edx
  8015fd:	74 14                	je     801613 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	50                   	push   %eax
  801606:	ff d2                	call   *%edx
  801608:	89 c2                	mov    %eax,%edx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	eb 09                	jmp    801618 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	89 c2                	mov    %eax,%edx
  801611:	eb 05                	jmp    801618 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801613:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801618:	89 d0                	mov    %edx,%eax
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 14             	sub    $0x14,%esp
  801626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 6c fb ff ff       	call   8011a1 <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	89 c2                	mov    %eax,%edx
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 58                	js     801696 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801648:	ff 30                	pushl  (%eax)
  80164a:	e8 a8 fb ff ff       	call   8011f7 <dev_lookup>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 37                	js     80168d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801659:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80165d:	74 32                	je     801691 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80165f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801662:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801669:	00 00 00 
	stat->st_isdir = 0;
  80166c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801673:	00 00 00 
	stat->st_dev = dev;
  801676:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	53                   	push   %ebx
  801680:	ff 75 f0             	pushl  -0x10(%ebp)
  801683:	ff 50 14             	call   *0x14(%eax)
  801686:	89 c2                	mov    %eax,%edx
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb 09                	jmp    801696 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	eb 05                	jmp    801696 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801691:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801696:	89 d0                	mov    %edx,%eax
  801698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	56                   	push   %esi
  8016a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	6a 00                	push   $0x0
  8016a7:	ff 75 08             	pushl  0x8(%ebp)
  8016aa:	e8 09 02 00 00       	call   8018b8 <open>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 db                	test   %ebx,%ebx
  8016b6:	78 1b                	js     8016d3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	ff 75 0c             	pushl  0xc(%ebp)
  8016be:	53                   	push   %ebx
  8016bf:	e8 5b ff ff ff       	call   80161f <fstat>
  8016c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c6:	89 1c 24             	mov    %ebx,(%esp)
  8016c9:	e8 fd fb ff ff       	call   8012cb <close>
	return r;
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	89 f0                	mov    %esi,%eax
}
  8016d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
  8016df:	89 c6                	mov    %eax,%esi
  8016e1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ea:	75 12                	jne    8016fe <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	6a 01                	push   $0x1
  8016f1:	e8 fd f9 ff ff       	call   8010f3 <ipc_find_env>
  8016f6:	a3 00 40 80 00       	mov    %eax,0x804000
  8016fb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016fe:	6a 07                	push   $0x7
  801700:	68 00 50 80 00       	push   $0x805000
  801705:	56                   	push   %esi
  801706:	ff 35 00 40 80 00    	pushl  0x804000
  80170c:	e8 8e f9 ff ff       	call   80109f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801711:	83 c4 0c             	add    $0xc,%esp
  801714:	6a 00                	push   $0x0
  801716:	53                   	push   %ebx
  801717:	6a 00                	push   $0x0
  801719:	e8 18 f9 ff ff       	call   801036 <ipc_recv>
}
  80171e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	8b 40 0c             	mov    0xc(%eax),%eax
  801731:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801736:	8b 45 0c             	mov    0xc(%ebp),%eax
  801739:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 02 00 00 00       	mov    $0x2,%eax
  801748:	e8 8d ff ff ff       	call   8016da <fsipc>
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	8b 40 0c             	mov    0xc(%eax),%eax
  80175b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 06 00 00 00       	mov    $0x6,%eax
  80176a:	e8 6b ff ff ff       	call   8016da <fsipc>
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	83 ec 04             	sub    $0x4,%esp
  801778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	8b 40 0c             	mov    0xc(%eax),%eax
  801781:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801786:	ba 00 00 00 00       	mov    $0x0,%edx
  80178b:	b8 05 00 00 00       	mov    $0x5,%eax
  801790:	e8 45 ff ff ff       	call   8016da <fsipc>
  801795:	89 c2                	mov    %eax,%edx
  801797:	85 d2                	test   %edx,%edx
  801799:	78 2c                	js     8017c7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	68 00 50 80 00       	push   $0x805000
  8017a3:	53                   	push   %ebx
  8017a4:	e8 8f ef ff ff       	call   800738 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	57                   	push   %edi
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 40 0c             	mov    0xc(%eax),%eax
  8017de:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8017e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017e6:	eb 3d                	jmp    801825 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8017e8:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8017ee:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8017f3:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	57                   	push   %edi
  8017fa:	53                   	push   %ebx
  8017fb:	68 08 50 80 00       	push   $0x805008
  801800:	e8 c5 f0 ff ff       	call   8008ca <memmove>
                fsipcbuf.write.req_n = tmp; 
  801805:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	b8 04 00 00 00       	mov    $0x4,%eax
  801815:	e8 c0 fe ff ff       	call   8016da <fsipc>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 0d                	js     80182e <devfile_write+0x62>
		        return r;
                n -= tmp;
  801821:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801823:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801825:	85 f6                	test   %esi,%esi
  801827:	75 bf                	jne    8017e8 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801829:	89 d8                	mov    %ebx,%eax
  80182b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80182e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801831:	5b                   	pop    %ebx
  801832:	5e                   	pop    %esi
  801833:	5f                   	pop    %edi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 40 0c             	mov    0xc(%eax),%eax
  801844:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801849:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 03 00 00 00       	mov    $0x3,%eax
  801859:	e8 7c fe ff ff       	call   8016da <fsipc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	85 c0                	test   %eax,%eax
  801862:	78 4b                	js     8018af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801864:	39 c6                	cmp    %eax,%esi
  801866:	73 16                	jae    80187e <devfile_read+0x48>
  801868:	68 7c 27 80 00       	push   $0x80277c
  80186d:	68 83 27 80 00       	push   $0x802783
  801872:	6a 7c                	push   $0x7c
  801874:	68 98 27 80 00       	push   $0x802798
  801879:	e8 ba 05 00 00       	call   801e38 <_panic>
	assert(r <= PGSIZE);
  80187e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801883:	7e 16                	jle    80189b <devfile_read+0x65>
  801885:	68 a3 27 80 00       	push   $0x8027a3
  80188a:	68 83 27 80 00       	push   $0x802783
  80188f:	6a 7d                	push   $0x7d
  801891:	68 98 27 80 00       	push   $0x802798
  801896:	e8 9d 05 00 00       	call   801e38 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	50                   	push   %eax
  80189f:	68 00 50 80 00       	push   $0x805000
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	e8 1e f0 ff ff       	call   8008ca <memmove>
	return r;
  8018ac:	83 c4 10             	add    $0x10,%esp
}
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 20             	sub    $0x20,%esp
  8018bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c2:	53                   	push   %ebx
  8018c3:	e8 37 ee ff ff       	call   8006ff <strlen>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d0:	7f 67                	jg     801939 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d8:	50                   	push   %eax
  8018d9:	e8 74 f8 ff ff       	call   801152 <fd_alloc>
  8018de:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 57                	js     80193e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	68 00 50 80 00       	push   $0x805000
  8018f0:	e8 43 ee ff ff       	call   800738 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801900:	b8 01 00 00 00       	mov    $0x1,%eax
  801905:	e8 d0 fd ff ff       	call   8016da <fsipc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	79 14                	jns    801927 <open+0x6f>
		fd_close(fd, 0);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	6a 00                	push   $0x0
  801918:	ff 75 f4             	pushl  -0xc(%ebp)
  80191b:	e8 2a f9 ff ff       	call   80124a <fd_close>
		return r;
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	89 da                	mov    %ebx,%edx
  801925:	eb 17                	jmp    80193e <open+0x86>
	}

	return fd2num(fd);
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	e8 f9 f7 ff ff       	call   80112b <fd2num>
  801932:	89 c2                	mov    %eax,%edx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	eb 05                	jmp    80193e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801939:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80193e:	89 d0                	mov    %edx,%eax
  801940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	b8 08 00 00 00       	mov    $0x8,%eax
  801955:	e8 80 fd ff ff       	call   8016da <fsipc>
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	ff 75 08             	pushl  0x8(%ebp)
  80196a:	e8 cc f7 ff ff       	call   80113b <fd2data>
  80196f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801971:	83 c4 08             	add    $0x8,%esp
  801974:	68 af 27 80 00       	push   $0x8027af
  801979:	53                   	push   %ebx
  80197a:	e8 b9 ed ff ff       	call   800738 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80197f:	8b 56 04             	mov    0x4(%esi),%edx
  801982:	89 d0                	mov    %edx,%eax
  801984:	2b 06                	sub    (%esi),%eax
  801986:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80198c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801993:	00 00 00 
	stat->st_dev = &devpipe;
  801996:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80199d:	30 80 00 
	return 0;
}
  8019a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    

008019ac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b6:	53                   	push   %ebx
  8019b7:	6a 00                	push   $0x0
  8019b9:	e8 08 f2 ff ff       	call   800bc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019be:	89 1c 24             	mov    %ebx,(%esp)
  8019c1:	e8 75 f7 ff ff       	call   80113b <fd2data>
  8019c6:	83 c4 08             	add    $0x8,%esp
  8019c9:	50                   	push   %eax
  8019ca:	6a 00                	push   $0x0
  8019cc:	e8 f5 f1 ff ff       	call   800bc6 <sys_page_unmap>
}
  8019d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	57                   	push   %edi
  8019da:	56                   	push   %esi
  8019db:	53                   	push   %ebx
  8019dc:	83 ec 1c             	sub    $0x1c,%esp
  8019df:	89 c6                	mov    %eax,%esi
  8019e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8019e9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019ec:	83 ec 0c             	sub    $0xc,%esp
  8019ef:	56                   	push   %esi
  8019f0:	e8 1c 05 00 00       	call   801f11 <pageref>
  8019f5:	89 c7                	mov    %eax,%edi
  8019f7:	83 c4 04             	add    $0x4,%esp
  8019fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019fd:	e8 0f 05 00 00       	call   801f11 <pageref>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	39 c7                	cmp    %eax,%edi
  801a07:	0f 94 c2             	sete   %dl
  801a0a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a0d:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a13:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a16:	39 fb                	cmp    %edi,%ebx
  801a18:	74 19                	je     801a33 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801a1a:	84 d2                	test   %dl,%dl
  801a1c:	74 c6                	je     8019e4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a1e:	8b 51 58             	mov    0x58(%ecx),%edx
  801a21:	50                   	push   %eax
  801a22:	52                   	push   %edx
  801a23:	53                   	push   %ebx
  801a24:	68 b6 27 80 00       	push   $0x8027b6
  801a29:	e8 83 e7 ff ff       	call   8001b1 <cprintf>
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	eb b1                	jmp    8019e4 <_pipeisclosed+0xe>
	}
}
  801a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	57                   	push   %edi
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	83 ec 28             	sub    $0x28,%esp
  801a44:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a47:	56                   	push   %esi
  801a48:	e8 ee f6 ff ff       	call   80113b <fd2data>
  801a4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	bf 00 00 00 00       	mov    $0x0,%edi
  801a57:	eb 4b                	jmp    801aa4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a59:	89 da                	mov    %ebx,%edx
  801a5b:	89 f0                	mov    %esi,%eax
  801a5d:	e8 74 ff ff ff       	call   8019d6 <_pipeisclosed>
  801a62:	85 c0                	test   %eax,%eax
  801a64:	75 48                	jne    801aae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a66:	e8 b7 f0 ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6e:	8b 0b                	mov    (%ebx),%ecx
  801a70:	8d 51 20             	lea    0x20(%ecx),%edx
  801a73:	39 d0                	cmp    %edx,%eax
  801a75:	73 e2                	jae    801a59 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a81:	89 c2                	mov    %eax,%edx
  801a83:	c1 fa 1f             	sar    $0x1f,%edx
  801a86:	89 d1                	mov    %edx,%ecx
  801a88:	c1 e9 1b             	shr    $0x1b,%ecx
  801a8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a8e:	83 e2 1f             	and    $0x1f,%edx
  801a91:	29 ca                	sub    %ecx,%edx
  801a93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a9b:	83 c0 01             	add    $0x1,%eax
  801a9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa1:	83 c7 01             	add    $0x1,%edi
  801aa4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aa7:	75 c2                	jne    801a6b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aac:	eb 05                	jmp    801ab3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5f                   	pop    %edi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 18             	sub    $0x18,%esp
  801ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac7:	57                   	push   %edi
  801ac8:	e8 6e f6 ff ff       	call   80113b <fd2data>
  801acd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad7:	eb 3d                	jmp    801b16 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad9:	85 db                	test   %ebx,%ebx
  801adb:	74 04                	je     801ae1 <devpipe_read+0x26>
				return i;
  801add:	89 d8                	mov    %ebx,%eax
  801adf:	eb 44                	jmp    801b25 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ae1:	89 f2                	mov    %esi,%edx
  801ae3:	89 f8                	mov    %edi,%eax
  801ae5:	e8 ec fe ff ff       	call   8019d6 <_pipeisclosed>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	75 32                	jne    801b20 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aee:	e8 2f f0 ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801af3:	8b 06                	mov    (%esi),%eax
  801af5:	3b 46 04             	cmp    0x4(%esi),%eax
  801af8:	74 df                	je     801ad9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801afa:	99                   	cltd   
  801afb:	c1 ea 1b             	shr    $0x1b,%edx
  801afe:	01 d0                	add    %edx,%eax
  801b00:	83 e0 1f             	and    $0x1f,%eax
  801b03:	29 d0                	sub    %edx,%eax
  801b05:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b10:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b13:	83 c3 01             	add    $0x1,%ebx
  801b16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b19:	75 d8                	jne    801af3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1e:	eb 05                	jmp    801b25 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5f                   	pop    %edi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	e8 14 f6 ff ff       	call   801152 <fd_alloc>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	85 c0                	test   %eax,%eax
  801b45:	0f 88 2c 01 00 00    	js     801c77 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	68 07 04 00 00       	push   $0x407
  801b53:	ff 75 f4             	pushl  -0xc(%ebp)
  801b56:	6a 00                	push   $0x0
  801b58:	e8 e4 ef ff ff       	call   800b41 <sys_page_alloc>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 0d 01 00 00    	js     801c77 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b6a:	83 ec 0c             	sub    $0xc,%esp
  801b6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b70:	50                   	push   %eax
  801b71:	e8 dc f5 ff ff       	call   801152 <fd_alloc>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	0f 88 e2 00 00 00    	js     801c65 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b83:	83 ec 04             	sub    $0x4,%esp
  801b86:	68 07 04 00 00       	push   $0x407
  801b8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8e:	6a 00                	push   $0x0
  801b90:	e8 ac ef ff ff       	call   800b41 <sys_page_alloc>
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	0f 88 c3 00 00 00    	js     801c65 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba8:	e8 8e f5 ff ff       	call   80113b <fd2data>
  801bad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801baf:	83 c4 0c             	add    $0xc,%esp
  801bb2:	68 07 04 00 00       	push   $0x407
  801bb7:	50                   	push   %eax
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 82 ef ff ff       	call   800b41 <sys_page_alloc>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	0f 88 89 00 00 00    	js     801c55 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd2:	e8 64 f5 ff ff       	call   80113b <fd2data>
  801bd7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bde:	50                   	push   %eax
  801bdf:	6a 00                	push   $0x0
  801be1:	56                   	push   %esi
  801be2:	6a 00                	push   $0x0
  801be4:	e8 9b ef ff ff       	call   800b84 <sys_page_map>
  801be9:	89 c3                	mov    %eax,%ebx
  801beb:	83 c4 20             	add    $0x20,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 55                	js     801c47 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bf2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c10:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c15:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	e8 04 f5 ff ff       	call   80112b <fd2num>
  801c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c2c:	83 c4 04             	add    $0x4,%esp
  801c2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c32:	e8 f4 f4 ff ff       	call   80112b <fd2num>
  801c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	ba 00 00 00 00       	mov    $0x0,%edx
  801c45:	eb 30                	jmp    801c77 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c47:	83 ec 08             	sub    $0x8,%esp
  801c4a:	56                   	push   %esi
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 74 ef ff ff       	call   800bc6 <sys_page_unmap>
  801c52:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 64 ef ff ff       	call   800bc6 <sys_page_unmap>
  801c62:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c65:	83 ec 08             	sub    $0x8,%esp
  801c68:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 54 ef ff ff       	call   800bc6 <sys_page_unmap>
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c77:	89 d0                	mov    %edx,%eax
  801c79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7c:	5b                   	pop    %ebx
  801c7d:	5e                   	pop    %esi
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	ff 75 08             	pushl  0x8(%ebp)
  801c8d:	e8 0f f5 ff ff       	call   8011a1 <fd_lookup>
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 d2                	test   %edx,%edx
  801c99:	78 18                	js     801cb3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c9b:	83 ec 0c             	sub    $0xc,%esp
  801c9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca1:	e8 95 f4 ff ff       	call   80113b <fd2data>
	return _pipeisclosed(fd, p);
  801ca6:	89 c2                	mov    %eax,%edx
  801ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cab:	e8 26 fd ff ff       	call   8019d6 <_pipeisclosed>
  801cb0:	83 c4 10             	add    $0x10,%esp
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cc5:	68 ce 27 80 00       	push   $0x8027ce
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	e8 66 ea ff ff       	call   800738 <strcpy>
	return 0;
}
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    

00801cd9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	57                   	push   %edi
  801cdd:	56                   	push   %esi
  801cde:	53                   	push   %ebx
  801cdf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf0:	eb 2d                	jmp    801d1f <devcons_write+0x46>
		m = n - tot;
  801cf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cf5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cf7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cfa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cff:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d02:	83 ec 04             	sub    $0x4,%esp
  801d05:	53                   	push   %ebx
  801d06:	03 45 0c             	add    0xc(%ebp),%eax
  801d09:	50                   	push   %eax
  801d0a:	57                   	push   %edi
  801d0b:	e8 ba eb ff ff       	call   8008ca <memmove>
		sys_cputs(buf, m);
  801d10:	83 c4 08             	add    $0x8,%esp
  801d13:	53                   	push   %ebx
  801d14:	57                   	push   %edi
  801d15:	e8 6b ed ff ff       	call   800a85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1a:	01 de                	add    %ebx,%esi
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	89 f0                	mov    %esi,%eax
  801d21:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d24:	72 cc                	jb     801cf2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d34:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d3d:	75 07                	jne    801d46 <devcons_read+0x18>
  801d3f:	eb 28                	jmp    801d69 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d41:	e8 dc ed ff ff       	call   800b22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d46:	e8 58 ed ff ff       	call   800aa3 <sys_cgetc>
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	74 f2                	je     801d41 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 16                	js     801d69 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d53:	83 f8 04             	cmp    $0x4,%eax
  801d56:	74 0c                	je     801d64 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5b:	88 02                	mov    %al,(%edx)
	return 1;
  801d5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d62:	eb 05                	jmp    801d69 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d64:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d71:	8b 45 08             	mov    0x8(%ebp),%eax
  801d74:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d77:	6a 01                	push   $0x1
  801d79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	e8 03 ed ff ff       	call   800a85 <sys_cputs>
  801d82:	83 c4 10             	add    $0x10,%esp
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <getchar>:

int
getchar(void)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d8d:	6a 01                	push   $0x1
  801d8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	6a 00                	push   $0x0
  801d95:	e8 71 f6 ff ff       	call   80140b <read>
	if (r < 0)
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 0f                	js     801db0 <getchar+0x29>
		return r;
	if (r < 1)
  801da1:	85 c0                	test   %eax,%eax
  801da3:	7e 06                	jle    801dab <getchar+0x24>
		return -E_EOF;
	return c;
  801da5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801da9:	eb 05                	jmp    801db0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	ff 75 08             	pushl  0x8(%ebp)
  801dbf:	e8 dd f3 ff ff       	call   8011a1 <fd_lookup>
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 11                	js     801ddc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd4:	39 10                	cmp    %edx,(%eax)
  801dd6:	0f 94 c0             	sete   %al
  801dd9:	0f b6 c0             	movzbl %al,%eax
}
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <opencons>:

int
opencons(void)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de7:	50                   	push   %eax
  801de8:	e8 65 f3 ff ff       	call   801152 <fd_alloc>
  801ded:	83 c4 10             	add    $0x10,%esp
		return r;
  801df0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 3e                	js     801e34 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df6:	83 ec 04             	sub    $0x4,%esp
  801df9:	68 07 04 00 00       	push   $0x407
  801dfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801e01:	6a 00                	push   $0x0
  801e03:	e8 39 ed ff ff       	call   800b41 <sys_page_alloc>
  801e08:	83 c4 10             	add    $0x10,%esp
		return r;
  801e0b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 23                	js     801e34 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e11:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e26:	83 ec 0c             	sub    $0xc,%esp
  801e29:	50                   	push   %eax
  801e2a:	e8 fc f2 ff ff       	call   80112b <fd2num>
  801e2f:	89 c2                	mov    %eax,%edx
  801e31:	83 c4 10             	add    $0x10,%esp
}
  801e34:	89 d0                	mov    %edx,%eax
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e3d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e40:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e46:	e8 b8 ec ff ff       	call   800b03 <sys_getenvid>
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	ff 75 0c             	pushl  0xc(%ebp)
  801e51:	ff 75 08             	pushl  0x8(%ebp)
  801e54:	56                   	push   %esi
  801e55:	50                   	push   %eax
  801e56:	68 dc 27 80 00       	push   $0x8027dc
  801e5b:	e8 51 e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e60:	83 c4 18             	add    $0x18,%esp
  801e63:	53                   	push   %ebx
  801e64:	ff 75 10             	pushl  0x10(%ebp)
  801e67:	e8 f4 e2 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e6c:	c7 04 24 99 26 80 00 	movl   $0x802699,(%esp)
  801e73:	e8 39 e3 ff ff       	call   8001b1 <cprintf>
  801e78:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e7b:	cc                   	int3   
  801e7c:	eb fd                	jmp    801e7b <_panic+0x43>

00801e7e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e84:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e8b:	75 2c                	jne    801eb9 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801e8d:	83 ec 04             	sub    $0x4,%esp
  801e90:	6a 07                	push   $0x7
  801e92:	68 00 f0 bf ee       	push   $0xeebff000
  801e97:	6a 00                	push   $0x0
  801e99:	e8 a3 ec ff ff       	call   800b41 <sys_page_alloc>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	74 14                	je     801eb9 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801ea5:	83 ec 04             	sub    $0x4,%esp
  801ea8:	68 00 28 80 00       	push   $0x802800
  801ead:	6a 21                	push   $0x21
  801eaf:	68 64 28 80 00       	push   $0x802864
  801eb4:	e8 7f ff ff ff       	call   801e38 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebc:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ec1:	83 ec 08             	sub    $0x8,%esp
  801ec4:	68 ed 1e 80 00       	push   $0x801eed
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 bc ed ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	79 14                	jns    801eeb <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ed7:	83 ec 04             	sub    $0x4,%esp
  801eda:	68 2c 28 80 00       	push   $0x80282c
  801edf:	6a 29                	push   $0x29
  801ee1:	68 64 28 80 00       	push   $0x802864
  801ee6:	e8 4d ff ff ff       	call   801e38 <_panic>
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eed:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eee:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ef3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ef5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801ef8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801efd:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801f01:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801f05:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801f07:	83 c4 08             	add    $0x8,%esp
        popal
  801f0a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f0b:	83 c4 04             	add    $0x4,%esp
        popfl
  801f0e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801f0f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f10:	c3                   	ret    

00801f11 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f17:	89 d0                	mov    %edx,%eax
  801f19:	c1 e8 16             	shr    $0x16,%eax
  801f1c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f28:	f6 c1 01             	test   $0x1,%cl
  801f2b:	74 1d                	je     801f4a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f2d:	c1 ea 0c             	shr    $0xc,%edx
  801f30:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f37:	f6 c2 01             	test   $0x1,%dl
  801f3a:	74 0e                	je     801f4a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f3c:	c1 ea 0c             	shr    $0xc,%edx
  801f3f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f46:	ef 
  801f47:	0f b7 c0             	movzwl %ax,%eax
}
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	83 ec 10             	sub    $0x10,%esp
  801f56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f66:	85 d2                	test   %edx,%edx
  801f68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f6c:	89 34 24             	mov    %esi,(%esp)
  801f6f:	89 c8                	mov    %ecx,%eax
  801f71:	75 35                	jne    801fa8 <__udivdi3+0x58>
  801f73:	39 f1                	cmp    %esi,%ecx
  801f75:	0f 87 bd 00 00 00    	ja     802038 <__udivdi3+0xe8>
  801f7b:	85 c9                	test   %ecx,%ecx
  801f7d:	89 cd                	mov    %ecx,%ebp
  801f7f:	75 0b                	jne    801f8c <__udivdi3+0x3c>
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	31 d2                	xor    %edx,%edx
  801f88:	f7 f1                	div    %ecx
  801f8a:	89 c5                	mov    %eax,%ebp
  801f8c:	89 f0                	mov    %esi,%eax
  801f8e:	31 d2                	xor    %edx,%edx
  801f90:	f7 f5                	div    %ebp
  801f92:	89 c6                	mov    %eax,%esi
  801f94:	89 f8                	mov    %edi,%eax
  801f96:	f7 f5                	div    %ebp
  801f98:	89 f2                	mov    %esi,%edx
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    
  801fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	3b 14 24             	cmp    (%esp),%edx
  801fab:	77 7b                	ja     802028 <__udivdi3+0xd8>
  801fad:	0f bd f2             	bsr    %edx,%esi
  801fb0:	83 f6 1f             	xor    $0x1f,%esi
  801fb3:	0f 84 97 00 00 00    	je     802050 <__udivdi3+0x100>
  801fb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801fbe:	89 d7                	mov    %edx,%edi
  801fc0:	89 f1                	mov    %esi,%ecx
  801fc2:	29 f5                	sub    %esi,%ebp
  801fc4:	d3 e7                	shl    %cl,%edi
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	d3 ea                	shr    %cl,%edx
  801fcc:	89 f1                	mov    %esi,%ecx
  801fce:	09 fa                	or     %edi,%edx
  801fd0:	8b 3c 24             	mov    (%esp),%edi
  801fd3:	d3 e0                	shl    %cl,%eax
  801fd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fd9:	89 e9                	mov    %ebp,%ecx
  801fdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fe3:	89 fa                	mov    %edi,%edx
  801fe5:	d3 ea                	shr    %cl,%edx
  801fe7:	89 f1                	mov    %esi,%ecx
  801fe9:	d3 e7                	shl    %cl,%edi
  801feb:	89 e9                	mov    %ebp,%ecx
  801fed:	d3 e8                	shr    %cl,%eax
  801fef:	09 c7                	or     %eax,%edi
  801ff1:	89 f8                	mov    %edi,%eax
  801ff3:	f7 74 24 08          	divl   0x8(%esp)
  801ff7:	89 d5                	mov    %edx,%ebp
  801ff9:	89 c7                	mov    %eax,%edi
  801ffb:	f7 64 24 0c          	mull   0xc(%esp)
  801fff:	39 d5                	cmp    %edx,%ebp
  802001:	89 14 24             	mov    %edx,(%esp)
  802004:	72 11                	jb     802017 <__udivdi3+0xc7>
  802006:	8b 54 24 04          	mov    0x4(%esp),%edx
  80200a:	89 f1                	mov    %esi,%ecx
  80200c:	d3 e2                	shl    %cl,%edx
  80200e:	39 c2                	cmp    %eax,%edx
  802010:	73 5e                	jae    802070 <__udivdi3+0x120>
  802012:	3b 2c 24             	cmp    (%esp),%ebp
  802015:	75 59                	jne    802070 <__udivdi3+0x120>
  802017:	8d 47 ff             	lea    -0x1(%edi),%eax
  80201a:	31 f6                	xor    %esi,%esi
  80201c:	89 f2                	mov    %esi,%edx
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	31 f6                	xor    %esi,%esi
  80202a:	31 c0                	xor    %eax,%eax
  80202c:	89 f2                	mov    %esi,%edx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	89 f2                	mov    %esi,%edx
  80203a:	31 f6                	xor    %esi,%esi
  80203c:	89 f8                	mov    %edi,%eax
  80203e:	f7 f1                	div    %ecx
  802040:	89 f2                	mov    %esi,%edx
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802054:	76 0b                	jbe    802061 <__udivdi3+0x111>
  802056:	31 c0                	xor    %eax,%eax
  802058:	3b 14 24             	cmp    (%esp),%edx
  80205b:	0f 83 37 ff ff ff    	jae    801f98 <__udivdi3+0x48>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	e9 2d ff ff ff       	jmp    801f98 <__udivdi3+0x48>
  80206b:	90                   	nop
  80206c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 f8                	mov    %edi,%eax
  802072:	31 f6                	xor    %esi,%esi
  802074:	e9 1f ff ff ff       	jmp    801f98 <__udivdi3+0x48>
  802079:	66 90                	xchg   %ax,%ax
  80207b:	66 90                	xchg   %ax,%ax
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	83 ec 20             	sub    $0x20,%esp
  802086:	8b 44 24 34          	mov    0x34(%esp),%eax
  80208a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80208e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802092:	89 c6                	mov    %eax,%esi
  802094:	89 44 24 10          	mov    %eax,0x10(%esp)
  802098:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80209c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020a8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	89 c2                	mov    %eax,%edx
  8020b0:	75 1e                	jne    8020d0 <__umoddi3+0x50>
  8020b2:	39 f7                	cmp    %esi,%edi
  8020b4:	76 52                	jbe    802108 <__umoddi3+0x88>
  8020b6:	89 c8                	mov    %ecx,%eax
  8020b8:	89 f2                	mov    %esi,%edx
  8020ba:	f7 f7                	div    %edi
  8020bc:	89 d0                	mov    %edx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	83 c4 20             	add    $0x20,%esp
  8020c3:	5e                   	pop    %esi
  8020c4:	5f                   	pop    %edi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    
  8020c7:	89 f6                	mov    %esi,%esi
  8020c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020d0:	39 f0                	cmp    %esi,%eax
  8020d2:	77 5c                	ja     802130 <__umoddi3+0xb0>
  8020d4:	0f bd e8             	bsr    %eax,%ebp
  8020d7:	83 f5 1f             	xor    $0x1f,%ebp
  8020da:	75 64                	jne    802140 <__umoddi3+0xc0>
  8020dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8020e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8020e4:	0f 86 f6 00 00 00    	jbe    8021e0 <__umoddi3+0x160>
  8020ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8020ee:	0f 82 ec 00 00 00    	jb     8021e0 <__umoddi3+0x160>
  8020f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020f8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8020fc:	83 c4 20             	add    $0x20,%esp
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
  802103:	90                   	nop
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	85 ff                	test   %edi,%edi
  80210a:	89 fd                	mov    %edi,%ebp
  80210c:	75 0b                	jne    802119 <__umoddi3+0x99>
  80210e:	b8 01 00 00 00       	mov    $0x1,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 f7                	div    %edi
  802117:	89 c5                	mov    %eax,%ebp
  802119:	8b 44 24 10          	mov    0x10(%esp),%eax
  80211d:	31 d2                	xor    %edx,%edx
  80211f:	f7 f5                	div    %ebp
  802121:	89 c8                	mov    %ecx,%eax
  802123:	f7 f5                	div    %ebp
  802125:	eb 95                	jmp    8020bc <__umoddi3+0x3c>
  802127:	89 f6                	mov    %esi,%esi
  802129:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 20             	add    $0x20,%esp
  802137:	5e                   	pop    %esi
  802138:	5f                   	pop    %edi
  802139:	5d                   	pop    %ebp
  80213a:	c3                   	ret    
  80213b:	90                   	nop
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	b8 20 00 00 00       	mov    $0x20,%eax
  802145:	89 e9                	mov    %ebp,%ecx
  802147:	29 e8                	sub    %ebp,%eax
  802149:	d3 e2                	shl    %cl,%edx
  80214b:	89 c7                	mov    %eax,%edi
  80214d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802151:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 c1                	mov    %eax,%ecx
  80215b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80215f:	09 d1                	or     %edx,%ecx
  802161:	89 fa                	mov    %edi,%edx
  802163:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802167:	89 e9                	mov    %ebp,%ecx
  802169:	d3 e0                	shl    %cl,%eax
  80216b:	89 f9                	mov    %edi,%ecx
  80216d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802171:	89 f0                	mov    %esi,%eax
  802173:	d3 e8                	shr    %cl,%eax
  802175:	89 e9                	mov    %ebp,%ecx
  802177:	89 c7                	mov    %eax,%edi
  802179:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80217d:	d3 e6                	shl    %cl,%esi
  80217f:	89 d1                	mov    %edx,%ecx
  802181:	89 fa                	mov    %edi,%edx
  802183:	d3 e8                	shr    %cl,%eax
  802185:	89 e9                	mov    %ebp,%ecx
  802187:	09 f0                	or     %esi,%eax
  802189:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80218d:	f7 74 24 10          	divl   0x10(%esp)
  802191:	d3 e6                	shl    %cl,%esi
  802193:	89 d1                	mov    %edx,%ecx
  802195:	f7 64 24 0c          	mull   0xc(%esp)
  802199:	39 d1                	cmp    %edx,%ecx
  80219b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80219f:	89 d7                	mov    %edx,%edi
  8021a1:	89 c6                	mov    %eax,%esi
  8021a3:	72 0a                	jb     8021af <__umoddi3+0x12f>
  8021a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021a9:	73 10                	jae    8021bb <__umoddi3+0x13b>
  8021ab:	39 d1                	cmp    %edx,%ecx
  8021ad:	75 0c                	jne    8021bb <__umoddi3+0x13b>
  8021af:	89 d7                	mov    %edx,%edi
  8021b1:	89 c6                	mov    %eax,%esi
  8021b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021bb:	89 ca                	mov    %ecx,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021c3:	29 f0                	sub    %esi,%eax
  8021c5:	19 fa                	sbb    %edi,%edx
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8021ce:	89 d7                	mov    %edx,%edi
  8021d0:	d3 e7                	shl    %cl,%edi
  8021d2:	89 e9                	mov    %ebp,%ecx
  8021d4:	09 f8                	or     %edi,%eax
  8021d6:	d3 ea                	shr    %cl,%edx
  8021d8:	83 c4 20             	add    $0x20,%esp
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    
  8021df:	90                   	nop
  8021e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021e4:	29 f9                	sub    %edi,%ecx
  8021e6:	19 c6                	sbb    %eax,%esi
  8021e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021f0:	e9 ff fe ff ff       	jmp    8020f4 <__umoddi3+0x74>
