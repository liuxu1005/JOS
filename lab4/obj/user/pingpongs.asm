
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 8e 0f 00 00       	call   800fcf <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 14 80 00       	push   $0x801480
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 14 80 00       	push   $0x80149a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 cb 0f 00 00       	call   801052 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 4f 0f 00 00       	call   800fe9 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 14 80 00       	push   $0x8014b0
  8000c2:	e8 22 01 00 00       	call   8001e9 <cprintf>
		if (val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 68 0f 00 00       	call   801052 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800109:	e8 2d 0a 00 00       	call   800b3b <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
  80013a:	83 c4 10             	add    $0x10,%esp
}
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 a9 09 00 00       	call   800afa <sys_env_destroy>
  800151:	83 c4 10             	add    $0x10,%esp
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 37 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a8:	00 00 00 
	b.cnt = 0;
  8001ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	68 56 01 80 00       	push   $0x800156
  8001c7:	e8 4f 01 00 00       	call   80031b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 dc 08 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	e8 9d ff ff ff       	call   800198 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	89 c7                	mov    %eax,%edi
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 d1                	mov    %edx,%ecx
  800212:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800215:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800218:	8b 45 10             	mov    0x10(%ebp),%eax
  80021b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800221:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800228:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80022b:	72 05                	jb     800232 <printnum+0x35>
  80022d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800230:	77 3e                	ja     800270 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	53                   	push   %ebx
  80023c:	50                   	push   %eax
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	ff 75 e4             	pushl  -0x1c(%ebp)
  800243:	ff 75 e0             	pushl  -0x20(%ebp)
  800246:	ff 75 dc             	pushl  -0x24(%ebp)
  800249:	ff 75 d8             	pushl  -0x28(%ebp)
  80024c:	e8 6f 0f 00 00       	call   8011c0 <__udivdi3>
  800251:	83 c4 18             	add    $0x18,%esp
  800254:	52                   	push   %edx
  800255:	50                   	push   %eax
  800256:	89 f2                	mov    %esi,%edx
  800258:	89 f8                	mov    %edi,%eax
  80025a:	e8 9e ff ff ff       	call   8001fd <printnum>
  80025f:	83 c4 20             	add    $0x20,%esp
  800262:	eb 13                	jmp    800277 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	ff d7                	call   *%edi
  80026d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800270:	83 eb 01             	sub    $0x1,%ebx
  800273:	85 db                	test   %ebx,%ebx
  800275:	7f ed                	jg     800264 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	56                   	push   %esi
  80027b:	83 ec 04             	sub    $0x4,%esp
  80027e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800281:	ff 75 e0             	pushl  -0x20(%ebp)
  800284:	ff 75 dc             	pushl  -0x24(%ebp)
  800287:	ff 75 d8             	pushl  -0x28(%ebp)
  80028a:	e8 61 10 00 00       	call   8012f0 <__umoddi3>
  80028f:	83 c4 14             	add    $0x14,%esp
  800292:	0f be 80 e0 14 80 00 	movsbl 0x8014e0(%eax),%eax
  800299:	50                   	push   %eax
  80029a:	ff d7                	call   *%edi
  80029c:	83 c4 10             	add    $0x10,%esp
}
  80029f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002aa:	83 fa 01             	cmp    $0x1,%edx
  8002ad:	7e 0e                	jle    8002bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	8b 52 04             	mov    0x4(%edx),%edx
  8002bb:	eb 22                	jmp    8002df <getuint+0x38>
	else if (lflag)
  8002bd:	85 d2                	test   %edx,%edx
  8002bf:	74 10                	je     8002d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cf:	eb 0e                	jmp    8002df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 02                	mov    %al,(%edx)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800304:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800307:	50                   	push   %eax
  800308:	ff 75 10             	pushl  0x10(%ebp)
  80030b:	ff 75 0c             	pushl  0xc(%ebp)
  80030e:	ff 75 08             	pushl  0x8(%ebp)
  800311:	e8 05 00 00 00       	call   80031b <vprintfmt>
	va_end(ap);
  800316:	83 c4 10             	add    $0x10,%esp
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 2c             	sub    $0x2c,%esp
  800324:	8b 75 08             	mov    0x8(%ebp),%esi
  800327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032d:	eb 12                	jmp    800341 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032f:	85 c0                	test   %eax,%eax
  800331:	0f 84 90 03 00 00    	je     8006c7 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	53                   	push   %ebx
  80033b:	50                   	push   %eax
  80033c:	ff d6                	call   *%esi
  80033e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	83 c7 01             	add    $0x1,%edi
  800344:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800348:	83 f8 25             	cmp    $0x25,%eax
  80034b:	75 e2                	jne    80032f <vprintfmt+0x14>
  80034d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800351:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800358:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800366:	ba 00 00 00 00       	mov    $0x0,%edx
  80036b:	eb 07                	jmp    800374 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800370:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8d 47 01             	lea    0x1(%edi),%eax
  800377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037a:	0f b6 07             	movzbl (%edi),%eax
  80037d:	0f b6 c8             	movzbl %al,%ecx
  800380:	83 e8 23             	sub    $0x23,%eax
  800383:	3c 55                	cmp    $0x55,%al
  800385:	0f 87 21 03 00 00    	ja     8006ac <vprintfmt+0x391>
  80038b:	0f b6 c0             	movzbl %al,%eax
  80038e:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039c:	eb d6                	jmp    800374 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003b6:	83 fa 09             	cmp    $0x9,%edx
  8003b9:	77 39                	ja     8003f4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003be:	eb e9                	jmp    8003a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d1:	eb 27                	jmp    8003fa <vprintfmt+0xdf>
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003dd:	0f 49 c8             	cmovns %eax,%ecx
  8003e0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	eb 8c                	jmp    800374 <vprintfmt+0x59>
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003eb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f2:	eb 80                	jmp    800374 <vprintfmt+0x59>
  8003f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fe:	0f 89 70 ff ff ff    	jns    800374 <vprintfmt+0x59>
				width = precision, precision = -1;
  800404:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800411:	e9 5e ff ff ff       	jmp    800374 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800416:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041c:	e9 53 ff ff ff       	jmp    800374 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	53                   	push   %ebx
  80042e:	ff 30                	pushl  (%eax)
  800430:	ff d6                	call   *%esi
			break;
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800438:	e9 04 ff ff ff       	jmp    800341 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 00                	mov    (%eax),%eax
  800448:	99                   	cltd   
  800449:	31 d0                	xor    %edx,%eax
  80044b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 09             	cmp    $0x9,%eax
  800450:	7f 0b                	jg     80045d <vprintfmt+0x142>
  800452:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	75 18                	jne    800475 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045d:	50                   	push   %eax
  80045e:	68 f8 14 80 00       	push   $0x8014f8
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 94 fe ff ff       	call   8002fe <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800470:	e9 cc fe ff ff       	jmp    800341 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800475:	52                   	push   %edx
  800476:	68 01 15 80 00       	push   $0x801501
  80047b:	53                   	push   %ebx
  80047c:	56                   	push   %esi
  80047d:	e8 7c fe ff ff       	call   8002fe <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800488:	e9 b4 fe ff ff       	jmp    800341 <vprintfmt+0x26>
  80048d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800490:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800493:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a1:	85 ff                	test   %edi,%edi
  8004a3:	ba f1 14 80 00       	mov    $0x8014f1,%edx
  8004a8:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004ab:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004af:	0f 84 92 00 00 00    	je     800547 <vprintfmt+0x22c>
  8004b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004b9:	0f 8e 96 00 00 00    	jle    800555 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	51                   	push   %ecx
  8004c3:	57                   	push   %edi
  8004c4:	e8 86 02 00 00       	call   80074f <strnlen>
  8004c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004cc:	29 c1                	sub    %eax,%ecx
  8004ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e0:	eb 0f                	jmp    8004f1 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	83 ef 01             	sub    $0x1,%edi
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	7f ed                	jg     8004e2 <vprintfmt+0x1c7>
  8004f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fb:	85 c9                	test   %ecx,%ecx
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	0f 49 c1             	cmovns %ecx,%eax
  800505:	29 c1                	sub    %eax,%ecx
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	89 cb                	mov    %ecx,%ebx
  800512:	eb 4d                	jmp    800561 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800514:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800518:	74 1b                	je     800535 <vprintfmt+0x21a>
  80051a:	0f be c0             	movsbl %al,%eax
  80051d:	83 e8 20             	sub    $0x20,%eax
  800520:	83 f8 5e             	cmp    $0x5e,%eax
  800523:	76 10                	jbe    800535 <vprintfmt+0x21a>
					putch('?', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	6a 3f                	push   $0x3f
  80052d:	ff 55 08             	call   *0x8(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb 0d                	jmp    800542 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	52                   	push   %edx
  80053c:	ff 55 08             	call   *0x8(%ebp)
  80053f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800542:	83 eb 01             	sub    $0x1,%ebx
  800545:	eb 1a                	jmp    800561 <vprintfmt+0x246>
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800553:	eb 0c                	jmp    800561 <vprintfmt+0x246>
  800555:	89 75 08             	mov    %esi,0x8(%ebp)
  800558:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800561:	83 c7 01             	add    $0x1,%edi
  800564:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800568:	0f be d0             	movsbl %al,%edx
  80056b:	85 d2                	test   %edx,%edx
  80056d:	74 23                	je     800592 <vprintfmt+0x277>
  80056f:	85 f6                	test   %esi,%esi
  800571:	78 a1                	js     800514 <vprintfmt+0x1f9>
  800573:	83 ee 01             	sub    $0x1,%esi
  800576:	79 9c                	jns    800514 <vprintfmt+0x1f9>
  800578:	89 df                	mov    %ebx,%edi
  80057a:	8b 75 08             	mov    0x8(%ebp),%esi
  80057d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800580:	eb 18                	jmp    80059a <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	6a 20                	push   $0x20
  800588:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058a:	83 ef 01             	sub    $0x1,%edi
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	eb 08                	jmp    80059a <vprintfmt+0x27f>
  800592:	89 df                	mov    %ebx,%edi
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	85 ff                	test   %edi,%edi
  80059c:	7f e4                	jg     800582 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	e9 9b fd ff ff       	jmp    800341 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a6:	83 fa 01             	cmp    $0x1,%edx
  8005a9:	7e 16                	jle    8005c1 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 08             	lea    0x8(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 50 04             	mov    0x4(%eax),%edx
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bf:	eb 32                	jmp    8005f3 <vprintfmt+0x2d8>
	else if (lflag)
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	74 18                	je     8005dd <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 c1                	mov    %eax,%ecx
  8005d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005db:	eb 16                	jmp    8005f3 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800602:	79 74                	jns    800678 <vprintfmt+0x35d>
				putch('-', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 2d                	push   $0x2d
  80060a:	ff d6                	call   *%esi
				num = -(long long) num;
  80060c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800612:	f7 d8                	neg    %eax
  800614:	83 d2 00             	adc    $0x0,%edx
  800617:	f7 da                	neg    %edx
  800619:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800621:	eb 55                	jmp    800678 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 7c fc ff ff       	call   8002a7 <getuint>
			base = 10;
  80062b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800630:	eb 46                	jmp    800678 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 6d fc ff ff       	call   8002a7 <getuint>
                        base = 8;
  80063a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80063f:	eb 37                	jmp    800678 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
			putch('x', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 78                	push   $0x78
  80064f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800661:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800664:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800669:	eb 0d                	jmp    800678 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 34 fc ff ff       	call   8002a7 <getuint>
			base = 16;
  800673:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800678:	83 ec 0c             	sub    $0xc,%esp
  80067b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067f:	57                   	push   %edi
  800680:	ff 75 e0             	pushl  -0x20(%ebp)
  800683:	51                   	push   %ecx
  800684:	52                   	push   %edx
  800685:	50                   	push   %eax
  800686:	89 da                	mov    %ebx,%edx
  800688:	89 f0                	mov    %esi,%eax
  80068a:	e8 6e fb ff ff       	call   8001fd <printnum>
			break;
  80068f:	83 c4 20             	add    $0x20,%esp
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	e9 a7 fc ff ff       	jmp    800341 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	51                   	push   %ecx
  80069f:	ff d6                	call   *%esi
			break;
  8006a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a7:	e9 95 fc ff ff       	jmp    800341 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 25                	push   $0x25
  8006b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb 03                	jmp    8006bc <vprintfmt+0x3a1>
  8006b9:	83 ef 01             	sub    $0x1,%edi
  8006bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c0:	75 f7                	jne    8006b9 <vprintfmt+0x39e>
  8006c2:	e9 7a fc ff ff       	jmp    800341 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5f                   	pop    %edi
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 18             	sub    $0x18,%esp
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 26                	je     800716 <vsnprintf+0x47>
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	7e 22                	jle    800716 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f4:	ff 75 14             	pushl  0x14(%ebp)
  8006f7:	ff 75 10             	pushl  0x10(%ebp)
  8006fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	68 e1 02 80 00       	push   $0x8002e1
  800703:	e8 13 fc ff ff       	call   80031b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb 05                	jmp    80071b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    

0080071d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800726:	50                   	push   %eax
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	ff 75 08             	pushl  0x8(%ebp)
  800730:	e8 9a ff ff ff       	call   8006cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    

00800737 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073d:	b8 00 00 00 00       	mov    $0x0,%eax
  800742:	eb 03                	jmp    800747 <strlen+0x10>
		n++;
  800744:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800747:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074b:	75 f7                	jne    800744 <strlen+0xd>
		n++;
	return n;
}
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800755:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800758:	ba 00 00 00 00       	mov    $0x0,%edx
  80075d:	eb 03                	jmp    800762 <strnlen+0x13>
		n++;
  80075f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	39 c2                	cmp    %eax,%edx
  800764:	74 08                	je     80076e <strnlen+0x1f>
  800766:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076a:	75 f3                	jne    80075f <strnlen+0x10>
  80076c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c2 01             	add    $0x1,%edx
  80077f:	83 c1 01             	add    $0x1,%ecx
  800782:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800786:	88 5a ff             	mov    %bl,-0x1(%edx)
  800789:	84 db                	test   %bl,%bl
  80078b:	75 ef                	jne    80077c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078d:	5b                   	pop    %ebx
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800797:	53                   	push   %ebx
  800798:	e8 9a ff ff ff       	call   800737 <strlen>
  80079d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a0:	ff 75 0c             	pushl  0xc(%ebp)
  8007a3:	01 d8                	add    %ebx,%eax
  8007a5:	50                   	push   %eax
  8007a6:	e8 c5 ff ff ff       	call   800770 <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bd:	89 f3                	mov    %esi,%ebx
  8007bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c2:	89 f2                	mov    %esi,%edx
  8007c4:	eb 0f                	jmp    8007d5 <strncpy+0x23>
		*dst++ = *src;
  8007c6:	83 c2 01             	add    $0x1,%edx
  8007c9:	0f b6 01             	movzbl (%ecx),%eax
  8007cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	39 da                	cmp    %ebx,%edx
  8007d7:	75 ed                	jne    8007c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d9:	89 f0                	mov    %esi,%eax
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ef:	85 d2                	test   %edx,%edx
  8007f1:	74 21                	je     800814 <strlcpy+0x35>
  8007f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f7:	89 f2                	mov    %esi,%edx
  8007f9:	eb 09                	jmp    800804 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fb:	83 c2 01             	add    $0x1,%edx
  8007fe:	83 c1 01             	add    $0x1,%ecx
  800801:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800804:	39 c2                	cmp    %eax,%edx
  800806:	74 09                	je     800811 <strlcpy+0x32>
  800808:	0f b6 19             	movzbl (%ecx),%ebx
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ec                	jne    8007fb <strlcpy+0x1c>
  80080f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800811:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800814:	29 f0                	sub    %esi,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800823:	eb 06                	jmp    80082b <strcmp+0x11>
		p++, q++;
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082b:	0f b6 01             	movzbl (%ecx),%eax
  80082e:	84 c0                	test   %al,%al
  800830:	74 04                	je     800836 <strcmp+0x1c>
  800832:	3a 02                	cmp    (%edx),%al
  800834:	74 ef                	je     800825 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	0f b6 c0             	movzbl %al,%eax
  800839:	0f b6 12             	movzbl (%edx),%edx
  80083c:	29 d0                	sub    %edx,%eax
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	89 c3                	mov    %eax,%ebx
  80084c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084f:	eb 06                	jmp    800857 <strncmp+0x17>
		n--, p++, q++;
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800857:	39 d8                	cmp    %ebx,%eax
  800859:	74 15                	je     800870 <strncmp+0x30>
  80085b:	0f b6 08             	movzbl (%eax),%ecx
  80085e:	84 c9                	test   %cl,%cl
  800860:	74 04                	je     800866 <strncmp+0x26>
  800862:	3a 0a                	cmp    (%edx),%cl
  800864:	74 eb                	je     800851 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800866:	0f b6 00             	movzbl (%eax),%eax
  800869:	0f b6 12             	movzbl (%edx),%edx
  80086c:	29 d0                	sub    %edx,%eax
  80086e:	eb 05                	jmp    800875 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800875:	5b                   	pop    %ebx
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800882:	eb 07                	jmp    80088b <strchr+0x13>
		if (*s == c)
  800884:	38 ca                	cmp    %cl,%dl
  800886:	74 0f                	je     800897 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800888:	83 c0 01             	add    $0x1,%eax
  80088b:	0f b6 10             	movzbl (%eax),%edx
  80088e:	84 d2                	test   %dl,%dl
  800890:	75 f2                	jne    800884 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	eb 03                	jmp    8008a8 <strfind+0xf>
  8008a5:	83 c0 01             	add    $0x1,%eax
  8008a8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	74 04                	je     8008b3 <strfind+0x1a>
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	75 f2                	jne    8008a5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	57                   	push   %edi
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c1:	85 c9                	test   %ecx,%ecx
  8008c3:	74 36                	je     8008fb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 28                	jne    8008f5 <memset+0x40>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 23                	jne    8008f5 <memset+0x40>
		c &= 0xFF;
  8008d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d6:	89 d3                	mov    %edx,%ebx
  8008d8:	c1 e3 08             	shl    $0x8,%ebx
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	c1 e6 18             	shl    $0x18,%esi
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	c1 e0 10             	shl    $0x10,%eax
  8008e5:	09 f0                	or     %esi,%eax
  8008e7:	09 c2                	or     %eax,%edx
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ed:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f0:	fc                   	cld    
  8008f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f3:	eb 06                	jmp    8008fb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f8:	fc                   	cld    
  8008f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fb:	89 f8                	mov    %edi,%eax
  8008fd:	5b                   	pop    %ebx
  8008fe:	5e                   	pop    %esi
  8008ff:	5f                   	pop    %edi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800910:	39 c6                	cmp    %eax,%esi
  800912:	73 35                	jae    800949 <memmove+0x47>
  800914:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800917:	39 d0                	cmp    %edx,%eax
  800919:	73 2e                	jae    800949 <memmove+0x47>
		s += n;
		d += n;
  80091b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80091e:	89 d6                	mov    %edx,%esi
  800920:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800928:	75 13                	jne    80093d <memmove+0x3b>
  80092a:	f6 c1 03             	test   $0x3,%cl
  80092d:	75 0e                	jne    80093d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092f:	83 ef 04             	sub    $0x4,%edi
  800932:	8d 72 fc             	lea    -0x4(%edx),%esi
  800935:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800938:	fd                   	std    
  800939:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093b:	eb 09                	jmp    800946 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093d:	83 ef 01             	sub    $0x1,%edi
  800940:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800943:	fd                   	std    
  800944:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800946:	fc                   	cld    
  800947:	eb 1d                	jmp    800966 <memmove+0x64>
  800949:	89 f2                	mov    %esi,%edx
  80094b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	f6 c2 03             	test   $0x3,%dl
  800950:	75 0f                	jne    800961 <memmove+0x5f>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 0a                	jne    800961 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800957:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095a:	89 c7                	mov    %eax,%edi
  80095c:	fc                   	cld    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 05                	jmp    800966 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096d:	ff 75 10             	pushl  0x10(%ebp)
  800970:	ff 75 0c             	pushl  0xc(%ebp)
  800973:	ff 75 08             	pushl  0x8(%ebp)
  800976:	e8 87 ff ff ff       	call   800902 <memmove>
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 c6                	mov    %eax,%esi
  80098a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098d:	eb 1a                	jmp    8009a9 <memcmp+0x2c>
		if (*s1 != *s2)
  80098f:	0f b6 08             	movzbl (%eax),%ecx
  800992:	0f b6 1a             	movzbl (%edx),%ebx
  800995:	38 d9                	cmp    %bl,%cl
  800997:	74 0a                	je     8009a3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800999:	0f b6 c1             	movzbl %cl,%eax
  80099c:	0f b6 db             	movzbl %bl,%ebx
  80099f:	29 d8                	sub    %ebx,%eax
  8009a1:	eb 0f                	jmp    8009b2 <memcmp+0x35>
		s1++, s2++;
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a9:	39 f0                	cmp    %esi,%eax
  8009ab:	75 e2                	jne    80098f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c4:	eb 07                	jmp    8009cd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c6:	38 08                	cmp    %cl,(%eax)
  8009c8:	74 07                	je     8009d1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	39 d0                	cmp    %edx,%eax
  8009cf:	72 f5                	jb     8009c6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009df:	eb 03                	jmp    8009e4 <strtol+0x11>
		s++;
  8009e1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	0f b6 01             	movzbl (%ecx),%eax
  8009e7:	3c 09                	cmp    $0x9,%al
  8009e9:	74 f6                	je     8009e1 <strtol+0xe>
  8009eb:	3c 20                	cmp    $0x20,%al
  8009ed:	74 f2                	je     8009e1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ef:	3c 2b                	cmp    $0x2b,%al
  8009f1:	75 0a                	jne    8009fd <strtol+0x2a>
		s++;
  8009f3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fb:	eb 10                	jmp    800a0d <strtol+0x3a>
  8009fd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a02:	3c 2d                	cmp    $0x2d,%al
  800a04:	75 07                	jne    800a0d <strtol+0x3a>
		s++, neg = 1;
  800a06:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a09:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0d:	85 db                	test   %ebx,%ebx
  800a0f:	0f 94 c0             	sete   %al
  800a12:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a18:	75 19                	jne    800a33 <strtol+0x60>
  800a1a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1d:	75 14                	jne    800a33 <strtol+0x60>
  800a1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a23:	0f 85 82 00 00 00    	jne    800aab <strtol+0xd8>
		s += 2, base = 16;
  800a29:	83 c1 02             	add    $0x2,%ecx
  800a2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a31:	eb 16                	jmp    800a49 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a33:	84 c0                	test   %al,%al
  800a35:	74 12                	je     800a49 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a37:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3f:	75 08                	jne    800a49 <strtol+0x76>
		s++, base = 8;
  800a41:	83 c1 01             	add    $0x1,%ecx
  800a44:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a51:	0f b6 11             	movzbl (%ecx),%edx
  800a54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 09             	cmp    $0x9,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0x93>
			dig = *s - '0';
  800a5e:	0f be d2             	movsbl %dl,%edx
  800a61:	83 ea 30             	sub    $0x30,%edx
  800a64:	eb 22                	jmp    800a88 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a66:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a69:	89 f3                	mov    %esi,%ebx
  800a6b:	80 fb 19             	cmp    $0x19,%bl
  800a6e:	77 08                	ja     800a78 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a70:	0f be d2             	movsbl %dl,%edx
  800a73:	83 ea 57             	sub    $0x57,%edx
  800a76:	eb 10                	jmp    800a88 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a78:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 19             	cmp    $0x19,%bl
  800a80:	77 16                	ja     800a98 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a88:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8b:	7d 0f                	jge    800a9c <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a94:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a96:	eb b9                	jmp    800a51 <strtol+0x7e>
  800a98:	89 c2                	mov    %eax,%edx
  800a9a:	eb 02                	jmp    800a9e <strtol+0xcb>
  800a9c:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa2:	74 0d                	je     800ab1 <strtol+0xde>
		*endptr = (char *) s;
  800aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa7:	89 0e                	mov    %ecx,(%esi)
  800aa9:	eb 06                	jmp    800ab1 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aab:	84 c0                	test   %al,%al
  800aad:	75 92                	jne    800a41 <strtol+0x6e>
  800aaf:	eb 98                	jmp    800a49 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab1:	f7 da                	neg    %edx
  800ab3:	85 ff                	test   %edi,%edi
  800ab5:	0f 45 c2             	cmovne %edx,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	89 c6                	mov    %eax,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cgetc>:

int
sys_cgetc(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b08:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 cb                	mov    %ecx,%ebx
  800b12:	89 cf                	mov    %ecx,%edi
  800b14:	89 ce                	mov    %ecx,%esi
  800b16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	7e 17                	jle    800b33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	6a 03                	push   $0x3
  800b22:	68 28 17 80 00       	push   $0x801728
  800b27:	6a 23                	push   $0x23
  800b29:	68 45 17 80 00       	push   $0x801745
  800b2e:	e8 ab 05 00 00       	call   8010de <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	be 00 00 00 00       	mov    $0x0,%esi
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	89 f7                	mov    %esi,%edi
  800b97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 04                	push   $0x4
  800ba3:	68 28 17 80 00       	push   $0x801728
  800ba8:	6a 23                	push   $0x23
  800baa:	68 45 17 80 00       	push   $0x801745
  800baf:	e8 2a 05 00 00       	call   8010de <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 05                	push   $0x5
  800be5:	68 28 17 80 00       	push   $0x801728
  800bea:	6a 23                	push   $0x23
  800bec:	68 45 17 80 00       	push   $0x801745
  800bf1:	e8 e8 04 00 00       	call   8010de <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 df                	mov    %ebx,%edi
  800c19:	89 de                	mov    %ebx,%esi
  800c1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 06                	push   $0x6
  800c27:	68 28 17 80 00       	push   $0x801728
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 45 17 80 00       	push   $0x801745
  800c33:	e8 a6 04 00 00       	call   8010de <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 08                	push   $0x8
  800c69:	68 28 17 80 00       	push   $0x801728
  800c6e:	6a 23                	push   $0x23
  800c70:	68 45 17 80 00       	push   $0x801745
  800c75:	e8 64 04 00 00       	call   8010de <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 09                	push   $0x9
  800cab:	68 28 17 80 00       	push   $0x801728
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 45 17 80 00       	push   $0x801745
  800cb7:	e8 22 04 00 00       	call   8010de <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 cb                	mov    %ecx,%ebx
  800cff:	89 cf                	mov    %ecx,%edi
  800d01:	89 ce                	mov    %ecx,%esi
  800d03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 17                	jle    800d20 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 0c                	push   $0xc
  800d0f:	68 28 17 80 00       	push   $0x801728
  800d14:	6a 23                	push   $0x23
  800d16:	68 45 17 80 00       	push   $0x801745
  800d1b:	e8 be 03 00 00       	call   8010de <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 04             	sub    $0x4,%esp
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d32:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d34:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d38:	74 2e                	je     800d68 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	c1 ea 16             	shr    $0x16,%edx
  800d3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d46:	f6 c2 01             	test   $0x1,%dl
  800d49:	74 1d                	je     800d68 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d4b:	89 c2                	mov    %eax,%edx
  800d4d:	c1 ea 0c             	shr    $0xc,%edx
  800d50:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d57:	f6 c1 01             	test   $0x1,%cl
  800d5a:	74 0c                	je     800d68 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d63:	f6 c6 08             	test   $0x8,%dh
  800d66:	75 14                	jne    800d7c <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d68:	83 ec 04             	sub    $0x4,%esp
  800d6b:	68 54 17 80 00       	push   $0x801754
  800d70:	6a 21                	push   $0x21
  800d72:	68 e7 17 80 00       	push   $0x8017e7
  800d77:	e8 62 03 00 00       	call   8010de <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800d7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d81:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	6a 07                	push   $0x7
  800d88:	68 00 f0 7f 00       	push   $0x7ff000
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 e5 fd ff ff       	call   800b79 <sys_page_alloc>
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 14                	jns    800daf <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 f2 17 80 00       	push   $0x8017f2
  800da3:	6a 2b                	push   $0x2b
  800da5:	68 e7 17 80 00       	push   $0x8017e7
  800daa:	e8 2f 03 00 00       	call   8010de <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	68 00 10 00 00       	push   $0x1000
  800db7:	53                   	push   %ebx
  800db8:	68 00 f0 7f 00       	push   $0x7ff000
  800dbd:	e8 40 fb ff ff       	call   800902 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800dc2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dc9:	53                   	push   %ebx
  800dca:	6a 00                	push   $0x0
  800dcc:	68 00 f0 7f 00       	push   $0x7ff000
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 e4 fd ff ff       	call   800bbc <sys_page_map>
  800dd8:	83 c4 20             	add    $0x20,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	79 14                	jns    800df3 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 08 18 80 00       	push   $0x801808
  800de7:	6a 2e                	push   $0x2e
  800de9:	68 e7 17 80 00       	push   $0x8017e7
  800dee:	e8 eb 02 00 00       	call   8010de <_panic>
        sys_page_unmap(0, PFTEMP); 
  800df3:	83 ec 08             	sub    $0x8,%esp
  800df6:	68 00 f0 7f 00       	push   $0x7ff000
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 fc fd ff ff       	call   800bfe <sys_page_unmap>
  800e02:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e13:	68 28 0d 80 00       	push   $0x800d28
  800e18:	e8 07 03 00 00       	call   801124 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e1d:	b8 07 00 00 00       	mov    $0x7,%eax
  800e22:	cd 30                	int    $0x30
  800e24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	79 12                	jns    800e40 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e2e:	50                   	push   %eax
  800e2f:	68 1c 18 80 00       	push   $0x80181c
  800e34:	6a 6d                	push   $0x6d
  800e36:	68 e7 17 80 00       	push   $0x8017e7
  800e3b:	e8 9e 02 00 00       	call   8010de <_panic>
  800e40:	89 c7                	mov    %eax,%edi
  800e42:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e4b:	75 21                	jne    800e6e <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e4d:	e8 e9 fc ff ff       	call   800b3b <sys_getenvid>
  800e52:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e57:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e5a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e5f:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
  800e69:	e9 59 01 00 00       	jmp    800fc7 <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e6e:	89 d8                	mov    %ebx,%eax
  800e70:	c1 e8 16             	shr    $0x16,%eax
  800e73:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7a:	a8 01                	test   $0x1,%al
  800e7c:	0f 84 b0 00 00 00    	je     800f32 <fork+0x128>
  800e82:	89 d8                	mov    %ebx,%eax
  800e84:	c1 e8 0c             	shr    $0xc,%eax
  800e87:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	0f 84 9b 00 00 00    	je     800f32 <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800e97:	89 c6                	mov    %eax,%esi
  800e99:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800e9c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea3:	f6 c6 08             	test   $0x8,%dh
  800ea6:	75 0b                	jne    800eb3 <fork+0xa9>
  800ea8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eaf:	a8 02                	test   $0x2,%al
  800eb1:	74 57                	je     800f0a <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	68 05 08 00 00       	push   $0x805
  800ebb:	56                   	push   %esi
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 f7 fc ff ff       	call   800bbc <sys_page_map>
  800ec5:	83 c4 20             	add    $0x20,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	79 12                	jns    800ede <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 78 17 80 00       	push   $0x801778
  800ed2:	6a 4a                	push   $0x4a
  800ed4:	68 e7 17 80 00       	push   $0x8017e7
  800ed9:	e8 00 02 00 00       	call   8010de <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800ede:	83 ec 0c             	sub    $0xc,%esp
  800ee1:	68 05 08 00 00       	push   $0x805
  800ee6:	56                   	push   %esi
  800ee7:	6a 00                	push   $0x0
  800ee9:	56                   	push   %esi
  800eea:	6a 00                	push   $0x0
  800eec:	e8 cb fc ff ff       	call   800bbc <sys_page_map>
  800ef1:	83 c4 20             	add    $0x20,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	79 3a                	jns    800f32 <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800ef8:	50                   	push   %eax
  800ef9:	68 9c 17 80 00       	push   $0x80179c
  800efe:	6a 4c                	push   $0x4c
  800f00:	68 e7 17 80 00       	push   $0x8017e7
  800f05:	e8 d4 01 00 00       	call   8010de <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	6a 05                	push   $0x5
  800f0f:	56                   	push   %esi
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	6a 00                	push   $0x0
  800f14:	e8 a3 fc ff ff       	call   800bbc <sys_page_map>
  800f19:	83 c4 20             	add    $0x20,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	79 12                	jns    800f32 <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800f20:	50                   	push   %eax
  800f21:	68 c4 17 80 00       	push   $0x8017c4
  800f26:	6a 4f                	push   $0x4f
  800f28:	68 e7 17 80 00       	push   $0x8017e7
  800f2d:	e8 ac 01 00 00       	call   8010de <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800f32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f38:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f3e:	0f 85 2a ff ff ff    	jne    800e6e <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	6a 07                	push   $0x7
  800f49:	68 00 f0 bf ee       	push   $0xeebff000
  800f4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f51:	e8 23 fc ff ff       	call   800b79 <sys_page_alloc>
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	79 14                	jns    800f71 <fork+0x167>
                panic("user stack alloc failure\n");	
  800f5d:	83 ec 04             	sub    $0x4,%esp
  800f60:	68 2c 18 80 00       	push   $0x80182c
  800f65:	6a 76                	push   $0x76
  800f67:	68 e7 17 80 00       	push   $0x8017e7
  800f6c:	e8 6d 01 00 00       	call   8010de <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	68 93 11 80 00       	push   $0x801193
  800f79:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7c:	e8 01 fd ff ff       	call   800c82 <sys_env_set_pgfault_upcall>
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 14                	jns    800f9c <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  800f88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8b:	68 46 18 80 00       	push   $0x801846
  800f90:	6a 79                	push   $0x79
  800f92:	68 e7 17 80 00       	push   $0x8017e7
  800f97:	e8 42 01 00 00       	call   8010de <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	6a 02                	push   $0x2
  800fa1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa4:	e8 97 fc ff ff       	call   800c40 <sys_env_set_status>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	79 14                	jns    800fc4 <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  800fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb3:	68 63 18 80 00       	push   $0x801863
  800fb8:	6a 7b                	push   $0x7b
  800fba:	68 e7 17 80 00       	push   $0x8017e7
  800fbf:	e8 1a 01 00 00       	call   8010de <_panic>
        return forkid;
  800fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sfork>:

// Challenge!
int
sfork(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fd5:	68 7a 18 80 00       	push   $0x80187a
  800fda:	68 83 00 00 00       	push   $0x83
  800fdf:	68 e7 17 80 00       	push   $0x8017e7
  800fe4:	e8 f5 00 00 00       	call   8010de <_panic>

00800fe9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800ffe:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	50                   	push   %eax
  801005:	e8 dd fc ff ff       	call   800ce7 <sys_ipc_recv>
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 16                	jns    801027 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801011:	85 f6                	test   %esi,%esi
  801013:	74 06                	je     80101b <ipc_recv+0x32>
  801015:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80101b:	85 db                	test   %ebx,%ebx
  80101d:	74 2c                	je     80104b <ipc_recv+0x62>
  80101f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801025:	eb 24                	jmp    80104b <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801027:	85 f6                	test   %esi,%esi
  801029:	74 0a                	je     801035 <ipc_recv+0x4c>
  80102b:	a1 08 20 80 00       	mov    0x802008,%eax
  801030:	8b 40 74             	mov    0x74(%eax),%eax
  801033:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801035:	85 db                	test   %ebx,%ebx
  801037:	74 0a                	je     801043 <ipc_recv+0x5a>
  801039:	a1 08 20 80 00       	mov    0x802008,%eax
  80103e:	8b 40 78             	mov    0x78(%eax),%eax
  801041:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801043:	a1 08 20 80 00       	mov    0x802008,%eax
  801048:	8b 40 70             	mov    0x70(%eax),%eax
}
  80104b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80105e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801064:	85 db                	test   %ebx,%ebx
  801066:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80106b:	0f 44 d8             	cmove  %eax,%ebx
  80106e:	eb 1c                	jmp    80108c <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801070:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801073:	74 12                	je     801087 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801075:	50                   	push   %eax
  801076:	68 90 18 80 00       	push   $0x801890
  80107b:	6a 39                	push   $0x39
  80107d:	68 ab 18 80 00       	push   $0x8018ab
  801082:	e8 57 00 00 00       	call   8010de <_panic>
                 sys_yield();
  801087:	e8 ce fa ff ff       	call   800b5a <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80108c:	ff 75 14             	pushl  0x14(%ebp)
  80108f:	53                   	push   %ebx
  801090:	56                   	push   %esi
  801091:	57                   	push   %edi
  801092:	e8 2d fc ff ff       	call   800cc4 <sys_ipc_try_send>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 d2                	js     801070 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010b1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010b4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010ba:	8b 52 50             	mov    0x50(%edx),%edx
  8010bd:	39 ca                	cmp    %ecx,%edx
  8010bf:	75 0d                	jne    8010ce <ipc_find_env+0x28>
			return envs[i].env_id;
  8010c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c4:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8010c9:	8b 40 08             	mov    0x8(%eax),%eax
  8010cc:	eb 0e                	jmp    8010dc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010ce:	83 c0 01             	add    $0x1,%eax
  8010d1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010d6:	75 d9                	jne    8010b1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010d8:	66 b8 00 00          	mov    $0x0,%ax
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010e3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010e6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010ec:	e8 4a fa ff ff       	call   800b3b <sys_getenvid>
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	ff 75 0c             	pushl  0xc(%ebp)
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	56                   	push   %esi
  8010fb:	50                   	push   %eax
  8010fc:	68 b8 18 80 00       	push   $0x8018b8
  801101:	e8 e3 f0 ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801106:	83 c4 18             	add    $0x18,%esp
  801109:	53                   	push   %ebx
  80110a:	ff 75 10             	pushl  0x10(%ebp)
  80110d:	e8 86 f0 ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  801112:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  801119:	e8 cb f0 ff ff       	call   8001e9 <cprintf>
  80111e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801121:	cc                   	int3   
  801122:	eb fd                	jmp    801121 <_panic+0x43>

00801124 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80112a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801131:	75 2c                	jne    80115f <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	6a 07                	push   $0x7
  801138:	68 00 f0 bf ee       	push   $0xeebff000
  80113d:	6a 00                	push   $0x0
  80113f:	e8 35 fa ff ff       	call   800b79 <sys_page_alloc>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	74 14                	je     80115f <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	68 dc 18 80 00       	push   $0x8018dc
  801153:	6a 21                	push   $0x21
  801155:	68 40 19 80 00       	push   $0x801940
  80115a:	e8 7f ff ff ff       	call   8010de <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	a3 0c 20 80 00       	mov    %eax,0x80200c
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	68 93 11 80 00       	push   $0x801193
  80116f:	6a 00                	push   $0x0
  801171:	e8 0c fb ff ff       	call   800c82 <sys_env_set_pgfault_upcall>
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	79 14                	jns    801191 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	68 08 19 80 00       	push   $0x801908
  801185:	6a 29                	push   $0x29
  801187:	68 40 19 80 00       	push   $0x801940
  80118c:	e8 4d ff ff ff       	call   8010de <_panic>
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801193:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801194:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801199:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80119b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80119e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8011a3:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8011a7:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8011ab:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8011ad:	83 c4 08             	add    $0x8,%esp
        popal
  8011b0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8011b1:	83 c4 04             	add    $0x4,%esp
        popfl
  8011b4:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8011b5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8011b6:	c3                   	ret    
  8011b7:	66 90                	xchg   %ax,%ax
  8011b9:	66 90                	xchg   %ax,%ax
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 10             	sub    $0x10,%esp
  8011c6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8011ca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8011ce:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011d2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011dc:	89 34 24             	mov    %esi,(%esp)
  8011df:	89 c8                	mov    %ecx,%eax
  8011e1:	75 35                	jne    801218 <__udivdi3+0x58>
  8011e3:	39 f1                	cmp    %esi,%ecx
  8011e5:	0f 87 bd 00 00 00    	ja     8012a8 <__udivdi3+0xe8>
  8011eb:	85 c9                	test   %ecx,%ecx
  8011ed:	89 cd                	mov    %ecx,%ebp
  8011ef:	75 0b                	jne    8011fc <__udivdi3+0x3c>
  8011f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f6:	31 d2                	xor    %edx,%edx
  8011f8:	f7 f1                	div    %ecx
  8011fa:	89 c5                	mov    %eax,%ebp
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	31 d2                	xor    %edx,%edx
  801200:	f7 f5                	div    %ebp
  801202:	89 c6                	mov    %eax,%esi
  801204:	89 f8                	mov    %edi,%eax
  801206:	f7 f5                	div    %ebp
  801208:	89 f2                	mov    %esi,%edx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	3b 14 24             	cmp    (%esp),%edx
  80121b:	77 7b                	ja     801298 <__udivdi3+0xd8>
  80121d:	0f bd f2             	bsr    %edx,%esi
  801220:	83 f6 1f             	xor    $0x1f,%esi
  801223:	0f 84 97 00 00 00    	je     8012c0 <__udivdi3+0x100>
  801229:	bd 20 00 00 00       	mov    $0x20,%ebp
  80122e:	89 d7                	mov    %edx,%edi
  801230:	89 f1                	mov    %esi,%ecx
  801232:	29 f5                	sub    %esi,%ebp
  801234:	d3 e7                	shl    %cl,%edi
  801236:	89 c2                	mov    %eax,%edx
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	d3 ea                	shr    %cl,%edx
  80123c:	89 f1                	mov    %esi,%ecx
  80123e:	09 fa                	or     %edi,%edx
  801240:	8b 3c 24             	mov    (%esp),%edi
  801243:	d3 e0                	shl    %cl,%eax
  801245:	89 54 24 08          	mov    %edx,0x8(%esp)
  801249:	89 e9                	mov    %ebp,%ecx
  80124b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801253:	89 fa                	mov    %edi,%edx
  801255:	d3 ea                	shr    %cl,%edx
  801257:	89 f1                	mov    %esi,%ecx
  801259:	d3 e7                	shl    %cl,%edi
  80125b:	89 e9                	mov    %ebp,%ecx
  80125d:	d3 e8                	shr    %cl,%eax
  80125f:	09 c7                	or     %eax,%edi
  801261:	89 f8                	mov    %edi,%eax
  801263:	f7 74 24 08          	divl   0x8(%esp)
  801267:	89 d5                	mov    %edx,%ebp
  801269:	89 c7                	mov    %eax,%edi
  80126b:	f7 64 24 0c          	mull   0xc(%esp)
  80126f:	39 d5                	cmp    %edx,%ebp
  801271:	89 14 24             	mov    %edx,(%esp)
  801274:	72 11                	jb     801287 <__udivdi3+0xc7>
  801276:	8b 54 24 04          	mov    0x4(%esp),%edx
  80127a:	89 f1                	mov    %esi,%ecx
  80127c:	d3 e2                	shl    %cl,%edx
  80127e:	39 c2                	cmp    %eax,%edx
  801280:	73 5e                	jae    8012e0 <__udivdi3+0x120>
  801282:	3b 2c 24             	cmp    (%esp),%ebp
  801285:	75 59                	jne    8012e0 <__udivdi3+0x120>
  801287:	8d 47 ff             	lea    -0x1(%edi),%eax
  80128a:	31 f6                	xor    %esi,%esi
  80128c:	89 f2                	mov    %esi,%edx
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	31 f6                	xor    %esi,%esi
  80129a:	31 c0                	xor    %eax,%eax
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	89 f2                	mov    %esi,%edx
  8012aa:	31 f6                	xor    %esi,%esi
  8012ac:	89 f8                	mov    %edi,%eax
  8012ae:	f7 f1                	div    %ecx
  8012b0:	89 f2                	mov    %esi,%edx
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8012c4:	76 0b                	jbe    8012d1 <__udivdi3+0x111>
  8012c6:	31 c0                	xor    %eax,%eax
  8012c8:	3b 14 24             	cmp    (%esp),%edx
  8012cb:	0f 83 37 ff ff ff    	jae    801208 <__udivdi3+0x48>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	e9 2d ff ff ff       	jmp    801208 <__udivdi3+0x48>
  8012db:	90                   	nop
  8012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 f8                	mov    %edi,%eax
  8012e2:	31 f6                	xor    %esi,%esi
  8012e4:	e9 1f ff ff ff       	jmp    801208 <__udivdi3+0x48>
  8012e9:	66 90                	xchg   %ax,%ax
  8012eb:	66 90                	xchg   %ax,%ax
  8012ed:	66 90                	xchg   %ax,%ax
  8012ef:	90                   	nop

008012f0 <__umoddi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 20             	sub    $0x20,%esp
  8012f6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8012fa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012fe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801302:	89 c6                	mov    %eax,%esi
  801304:	89 44 24 10          	mov    %eax,0x10(%esp)
  801308:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80130c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801310:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801314:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801318:	89 74 24 18          	mov    %esi,0x18(%esp)
  80131c:	85 c0                	test   %eax,%eax
  80131e:	89 c2                	mov    %eax,%edx
  801320:	75 1e                	jne    801340 <__umoddi3+0x50>
  801322:	39 f7                	cmp    %esi,%edi
  801324:	76 52                	jbe    801378 <__umoddi3+0x88>
  801326:	89 c8                	mov    %ecx,%eax
  801328:	89 f2                	mov    %esi,%edx
  80132a:	f7 f7                	div    %edi
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	31 d2                	xor    %edx,%edx
  801330:	83 c4 20             	add    $0x20,%esp
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    
  801337:	89 f6                	mov    %esi,%esi
  801339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801340:	39 f0                	cmp    %esi,%eax
  801342:	77 5c                	ja     8013a0 <__umoddi3+0xb0>
  801344:	0f bd e8             	bsr    %eax,%ebp
  801347:	83 f5 1f             	xor    $0x1f,%ebp
  80134a:	75 64                	jne    8013b0 <__umoddi3+0xc0>
  80134c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801350:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801354:	0f 86 f6 00 00 00    	jbe    801450 <__umoddi3+0x160>
  80135a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80135e:	0f 82 ec 00 00 00    	jb     801450 <__umoddi3+0x160>
  801364:	8b 44 24 14          	mov    0x14(%esp),%eax
  801368:	8b 54 24 18          	mov    0x18(%esp),%edx
  80136c:	83 c4 20             	add    $0x20,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	85 ff                	test   %edi,%edi
  80137a:	89 fd                	mov    %edi,%ebp
  80137c:	75 0b                	jne    801389 <__umoddi3+0x99>
  80137e:	b8 01 00 00 00       	mov    $0x1,%eax
  801383:	31 d2                	xor    %edx,%edx
  801385:	f7 f7                	div    %edi
  801387:	89 c5                	mov    %eax,%ebp
  801389:	8b 44 24 10          	mov    0x10(%esp),%eax
  80138d:	31 d2                	xor    %edx,%edx
  80138f:	f7 f5                	div    %ebp
  801391:	89 c8                	mov    %ecx,%eax
  801393:	f7 f5                	div    %ebp
  801395:	eb 95                	jmp    80132c <__umoddi3+0x3c>
  801397:	89 f6                	mov    %esi,%esi
  801399:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	83 c4 20             	add    $0x20,%esp
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
  8013ab:	90                   	nop
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b5:	89 e9                	mov    %ebp,%ecx
  8013b7:	29 e8                	sub    %ebp,%eax
  8013b9:	d3 e2                	shl    %cl,%edx
  8013bb:	89 c7                	mov    %eax,%edi
  8013bd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8013c1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013c5:	89 f9                	mov    %edi,%ecx
  8013c7:	d3 e8                	shr    %cl,%eax
  8013c9:	89 c1                	mov    %eax,%ecx
  8013cb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013cf:	09 d1                	or     %edx,%ecx
  8013d1:	89 fa                	mov    %edi,%edx
  8013d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013d7:	89 e9                	mov    %ebp,%ecx
  8013d9:	d3 e0                	shl    %cl,%eax
  8013db:	89 f9                	mov    %edi,%ecx
  8013dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e1:	89 f0                	mov    %esi,%eax
  8013e3:	d3 e8                	shr    %cl,%eax
  8013e5:	89 e9                	mov    %ebp,%ecx
  8013e7:	89 c7                	mov    %eax,%edi
  8013e9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013ed:	d3 e6                	shl    %cl,%esi
  8013ef:	89 d1                	mov    %edx,%ecx
  8013f1:	89 fa                	mov    %edi,%edx
  8013f3:	d3 e8                	shr    %cl,%eax
  8013f5:	89 e9                	mov    %ebp,%ecx
  8013f7:	09 f0                	or     %esi,%eax
  8013f9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8013fd:	f7 74 24 10          	divl   0x10(%esp)
  801401:	d3 e6                	shl    %cl,%esi
  801403:	89 d1                	mov    %edx,%ecx
  801405:	f7 64 24 0c          	mull   0xc(%esp)
  801409:	39 d1                	cmp    %edx,%ecx
  80140b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80140f:	89 d7                	mov    %edx,%edi
  801411:	89 c6                	mov    %eax,%esi
  801413:	72 0a                	jb     80141f <__umoddi3+0x12f>
  801415:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801419:	73 10                	jae    80142b <__umoddi3+0x13b>
  80141b:	39 d1                	cmp    %edx,%ecx
  80141d:	75 0c                	jne    80142b <__umoddi3+0x13b>
  80141f:	89 d7                	mov    %edx,%edi
  801421:	89 c6                	mov    %eax,%esi
  801423:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801427:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80142b:	89 ca                	mov    %ecx,%edx
  80142d:	89 e9                	mov    %ebp,%ecx
  80142f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801433:	29 f0                	sub    %esi,%eax
  801435:	19 fa                	sbb    %edi,%edx
  801437:	d3 e8                	shr    %cl,%eax
  801439:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80143e:	89 d7                	mov    %edx,%edi
  801440:	d3 e7                	shl    %cl,%edi
  801442:	89 e9                	mov    %ebp,%ecx
  801444:	09 f8                	or     %edi,%eax
  801446:	d3 ea                	shr    %cl,%edx
  801448:	83 c4 20             	add    $0x20,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	8b 74 24 10          	mov    0x10(%esp),%esi
  801454:	29 f9                	sub    %edi,%ecx
  801456:	19 c6                	sbb    %eax,%esi
  801458:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80145c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801460:	e9 ff fe ff ff       	jmp    801364 <__umoddi3+0x74>
