
obj/user/pingpongs.debug:     file format elf32-i386


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
  80003c:	e8 bc 10 00 00       	call   8010fd <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 f0 0a 00 00       	call   800b43 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 27 80 00       	push   $0x802780
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d9 0a 00 00       	call   800b43 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 27 80 00       	push   $0x80279a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 f9 10 00 00       	call   801180 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 7d 10 00 00       	call   801117 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 90 0a 00 00       	call   800b43 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 27 80 00       	push   $0x8027b0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 96 10 00 00       	call   801180 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
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
  800109:	e8 35 0a 00 00       	call   800b43 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 8f 12 00 00       	call   8013de <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 a9 09 00 00       	call   800b02 <sys_env_destroy>
  800159:	83 c4 10             	add    $0x10,%esp
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 37 09 00 00       	call   800ac5 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 4f 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 dc 08 00 00       	call   800ac5 <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 d1                	mov    %edx,%ecx
  80021a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800220:	8b 45 10             	mov    0x10(%ebp),%eax
  800223:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800226:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800229:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800230:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800233:	72 05                	jb     80023a <printnum+0x35>
  800235:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800238:	77 3e                	ja     800278 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	ff 75 18             	pushl  0x18(%ebp)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	53                   	push   %ebx
  800244:	50                   	push   %eax
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 57 22 00 00       	call   8024b0 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 13                	jmp    80027f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	85 db                	test   %ebx,%ebx
  80027d:	7f ed                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027f:	83 ec 08             	sub    $0x8,%esp
  800282:	56                   	push   %esi
  800283:	83 ec 04             	sub    $0x4,%esp
  800286:	ff 75 e4             	pushl  -0x1c(%ebp)
  800289:	ff 75 e0             	pushl  -0x20(%ebp)
  80028c:	ff 75 dc             	pushl  -0x24(%ebp)
  80028f:	ff 75 d8             	pushl  -0x28(%ebp)
  800292:	e8 49 23 00 00       	call   8025e0 <__umoddi3>
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	0f be 80 e0 27 80 00 	movsbl 0x8027e0(%eax),%eax
  8002a1:	50                   	push   %eax
  8002a2:	ff d7                	call   *%edi
  8002a4:	83 c4 10             	add    $0x10,%esp
}
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b2:	83 fa 01             	cmp    $0x1,%edx
  8002b5:	7e 0e                	jle    8002c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
  8002c3:	eb 22                	jmp    8002e7 <getuint+0x38>
	else if (lflag)
  8002c5:	85 d2                	test   %edx,%edx
  8002c7:	74 10                	je     8002d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	eb 0e                	jmp    8002e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
  80031e:	83 c4 10             	add    $0x10,%esp
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 90 03 00 00    	je     8006cf <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 c8             	movzbl %al,%ecx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 21 03 00 00    	ja     8006b4 <vprintfmt+0x391>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003be:	83 fa 09             	cmp    $0x9,%edx
  8003c1:	77 39                	ja     8003fc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d9:	eb 27                	jmp    800402 <vprintfmt+0xdf>
  8003db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003de:	85 c0                	test   %eax,%eax
  8003e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e5:	0f 49 c8             	cmovns %eax,%ecx
  8003e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	eb 8c                	jmp    80037c <vprintfmt+0x59>
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fa:	eb 80                	jmp    80037c <vprintfmt+0x59>
  8003fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ff:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800402:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800406:	0f 89 70 ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  80040c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800419:	e9 5e ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800424:	e9 53 ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 50 04             	lea    0x4(%eax),%edx
  80042f:	89 55 14             	mov    %edx,0x14(%ebp)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	53                   	push   %ebx
  800436:	ff 30                	pushl  (%eax)
  800438:	ff d6                	call   *%esi
			break;
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800440:	e9 04 ff ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	99                   	cltd   
  800451:	31 d0                	xor    %edx,%eax
  800453:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800455:	83 f8 0f             	cmp    $0xf,%eax
  800458:	7f 0b                	jg     800465 <vprintfmt+0x142>
  80045a:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	75 18                	jne    80047d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800465:	50                   	push   %eax
  800466:	68 f8 27 80 00       	push   $0x8027f8
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 94 fe ff ff       	call   800306 <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800478:	e9 cc fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047d:	52                   	push   %edx
  80047e:	68 59 2d 80 00       	push   $0x802d59
  800483:	53                   	push   %ebx
  800484:	56                   	push   %esi
  800485:	e8 7c fe ff ff       	call   800306 <printfmt>
  80048a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800490:	e9 b4 fe ff ff       	jmp    800349 <vprintfmt+0x26>
  800495:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800498:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049b:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	ba f1 27 80 00       	mov    $0x8027f1,%edx
  8004b0:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b7:	0f 84 92 00 00 00    	je     80054f <vprintfmt+0x22c>
  8004bd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004c1:	0f 8e 96 00 00 00    	jle    80055d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	51                   	push   %ecx
  8004cb:	57                   	push   %edi
  8004cc:	e8 86 02 00 00       	call   800757 <strnlen>
  8004d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d4:	29 c1                	sub    %eax,%ecx
  8004d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004dc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	eb 0f                	jmp    8004f9 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 ff                	test   %edi,%edi
  8004fb:	7f ed                	jg     8004ea <vprintfmt+0x1c7>
  8004fd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800500:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800503:	85 c9                	test   %ecx,%ecx
  800505:	b8 00 00 00 00       	mov    $0x0,%eax
  80050a:	0f 49 c1             	cmovns %ecx,%eax
  80050d:	29 c1                	sub    %eax,%ecx
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	89 cb                	mov    %ecx,%ebx
  80051a:	eb 4d                	jmp    800569 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800520:	74 1b                	je     80053d <vprintfmt+0x21a>
  800522:	0f be c0             	movsbl %al,%eax
  800525:	83 e8 20             	sub    $0x20,%eax
  800528:	83 f8 5e             	cmp    $0x5e,%eax
  80052b:	76 10                	jbe    80053d <vprintfmt+0x21a>
					putch('?', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 75 0c             	pushl  0xc(%ebp)
  800533:	6a 3f                	push   $0x3f
  800535:	ff 55 08             	call   *0x8(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 0d                	jmp    80054a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	52                   	push   %edx
  800544:	ff 55 08             	call   *0x8(%ebp)
  800547:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	83 eb 01             	sub    $0x1,%ebx
  80054d:	eb 1a                	jmp    800569 <vprintfmt+0x246>
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055b:	eb 0c                	jmp    800569 <vprintfmt+0x246>
  80055d:	89 75 08             	mov    %esi,0x8(%ebp)
  800560:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800566:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800569:	83 c7 01             	add    $0x1,%edi
  80056c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800570:	0f be d0             	movsbl %al,%edx
  800573:	85 d2                	test   %edx,%edx
  800575:	74 23                	je     80059a <vprintfmt+0x277>
  800577:	85 f6                	test   %esi,%esi
  800579:	78 a1                	js     80051c <vprintfmt+0x1f9>
  80057b:	83 ee 01             	sub    $0x1,%esi
  80057e:	79 9c                	jns    80051c <vprintfmt+0x1f9>
  800580:	89 df                	mov    %ebx,%edi
  800582:	8b 75 08             	mov    0x8(%ebp),%esi
  800585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800588:	eb 18                	jmp    8005a2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	53                   	push   %ebx
  80058e:	6a 20                	push   $0x20
  800590:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800592:	83 ef 01             	sub    $0x1,%edi
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	eb 08                	jmp    8005a2 <vprintfmt+0x27f>
  80059a:	89 df                	mov    %ebx,%edi
  80059c:	8b 75 08             	mov    0x8(%ebp),%esi
  80059f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a2:	85 ff                	test   %edi,%edi
  8005a4:	7f e4                	jg     80058a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 9b fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ae:	83 fa 01             	cmp    $0x1,%edx
  8005b1:	7e 16                	jle    8005c9 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 50 08             	lea    0x8(%eax),%edx
  8005b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bc:	8b 50 04             	mov    0x4(%eax),%edx
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c7:	eb 32                	jmp    8005fb <vprintfmt+0x2d8>
	else if (lflag)
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	74 18                	je     8005e5 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	eb 16                	jmp    8005fb <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 04             	lea    0x4(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f3:	89 c1                	mov    %eax,%ecx
  8005f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800601:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800606:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060a:	79 74                	jns    800680 <vprintfmt+0x35d>
				putch('-', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 2d                	push   $0x2d
  800612:	ff d6                	call   *%esi
				num = -(long long) num;
  800614:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800617:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061a:	f7 d8                	neg    %eax
  80061c:	83 d2 00             	adc    $0x0,%edx
  80061f:	f7 da                	neg    %edx
  800621:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800624:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800629:	eb 55                	jmp    800680 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 7c fc ff ff       	call   8002af <getuint>
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800638:	eb 46                	jmp    800680 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 6d fc ff ff       	call   8002af <getuint>
                        base = 8;
  800642:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800647:	eb 37                	jmp    800680 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 30                	push   $0x30
  80064f:	ff d6                	call   *%esi
			putch('x', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 78                	push   $0x78
  800657:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800669:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800671:	eb 0d                	jmp    800680 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 34 fc ff ff       	call   8002af <getuint>
			base = 16;
  80067b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800680:	83 ec 0c             	sub    $0xc,%esp
  800683:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800687:	57                   	push   %edi
  800688:	ff 75 e0             	pushl  -0x20(%ebp)
  80068b:	51                   	push   %ecx
  80068c:	52                   	push   %edx
  80068d:	50                   	push   %eax
  80068e:	89 da                	mov    %ebx,%edx
  800690:	89 f0                	mov    %esi,%eax
  800692:	e8 6e fb ff ff       	call   800205 <printnum>
			break;
  800697:	83 c4 20             	add    $0x20,%esp
  80069a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069d:	e9 a7 fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	51                   	push   %ecx
  8006a7:	ff d6                	call   *%esi
			break;
  8006a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006af:	e9 95 fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 25                	push   $0x25
  8006ba:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 03                	jmp    8006c4 <vprintfmt+0x3a1>
  8006c1:	83 ef 01             	sub    $0x1,%edi
  8006c4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c8:	75 f7                	jne    8006c1 <vprintfmt+0x39e>
  8006ca:	e9 7a fc ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d2:	5b                   	pop    %ebx
  8006d3:	5e                   	pop    %esi
  8006d4:	5f                   	pop    %edi
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 18             	sub    $0x18,%esp
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	74 26                	je     80071e <vsnprintf+0x47>
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	7e 22                	jle    80071e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fc:	ff 75 14             	pushl  0x14(%ebp)
  8006ff:	ff 75 10             	pushl  0x10(%ebp)
  800702:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	68 e9 02 80 00       	push   $0x8002e9
  80070b:	e8 13 fc ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800710:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800713:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb 05                	jmp    800723 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072e:	50                   	push   %eax
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	ff 75 08             	pushl  0x8(%ebp)
  800738:	e8 9a ff ff ff       	call   8006d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	eb 03                	jmp    80074f <strlen+0x10>
		n++;
  80074c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800753:	75 f7                	jne    80074c <strlen+0xd>
		n++;
	return n;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	ba 00 00 00 00       	mov    $0x0,%edx
  800765:	eb 03                	jmp    80076a <strnlen+0x13>
		n++;
  800767:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	39 c2                	cmp    %eax,%edx
  80076c:	74 08                	je     800776 <strnlen+0x1f>
  80076e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800772:	75 f3                	jne    800767 <strnlen+0x10>
  800774:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c2 01             	add    $0x1,%edx
  800787:	83 c1 01             	add    $0x1,%ecx
  80078a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800791:	84 db                	test   %bl,%bl
  800793:	75 ef                	jne    800784 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800795:	5b                   	pop    %ebx
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079f:	53                   	push   %ebx
  8007a0:	e8 9a ff ff ff       	call   80073f <strlen>
  8007a5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	01 d8                	add    %ebx,%eax
  8007ad:	50                   	push   %eax
  8007ae:	e8 c5 ff ff ff       	call   800778 <strcpy>
	return dst;
}
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c5:	89 f3                	mov    %esi,%ebx
  8007c7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ca:	89 f2                	mov    %esi,%edx
  8007cc:	eb 0f                	jmp    8007dd <strncpy+0x23>
		*dst++ = *src;
  8007ce:	83 c2 01             	add    $0x1,%edx
  8007d1:	0f b6 01             	movzbl (%ecx),%eax
  8007d4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007da:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	39 da                	cmp    %ebx,%edx
  8007df:	75 ed                	jne    8007ce <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e1:	89 f0                	mov    %esi,%eax
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	74 21                	je     80081c <strlcpy+0x35>
  8007fb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ff:	89 f2                	mov    %esi,%edx
  800801:	eb 09                	jmp    80080c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800803:	83 c2 01             	add    $0x1,%edx
  800806:	83 c1 01             	add    $0x1,%ecx
  800809:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080c:	39 c2                	cmp    %eax,%edx
  80080e:	74 09                	je     800819 <strlcpy+0x32>
  800810:	0f b6 19             	movzbl (%ecx),%ebx
  800813:	84 db                	test   %bl,%bl
  800815:	75 ec                	jne    800803 <strlcpy+0x1c>
  800817:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800819:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081c:	29 f0                	sub    %esi,%eax
}
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082b:	eb 06                	jmp    800833 <strcmp+0x11>
		p++, q++;
  80082d:	83 c1 01             	add    $0x1,%ecx
  800830:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800833:	0f b6 01             	movzbl (%ecx),%eax
  800836:	84 c0                	test   %al,%al
  800838:	74 04                	je     80083e <strcmp+0x1c>
  80083a:	3a 02                	cmp    (%edx),%al
  80083c:	74 ef                	je     80082d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083e:	0f b6 c0             	movzbl %al,%eax
  800841:	0f b6 12             	movzbl (%edx),%edx
  800844:	29 d0                	sub    %edx,%eax
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	89 c3                	mov    %eax,%ebx
  800854:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800857:	eb 06                	jmp    80085f <strncmp+0x17>
		n--, p++, q++;
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085f:	39 d8                	cmp    %ebx,%eax
  800861:	74 15                	je     800878 <strncmp+0x30>
  800863:	0f b6 08             	movzbl (%eax),%ecx
  800866:	84 c9                	test   %cl,%cl
  800868:	74 04                	je     80086e <strncmp+0x26>
  80086a:	3a 0a                	cmp    (%edx),%cl
  80086c:	74 eb                	je     800859 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 00             	movzbl (%eax),%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
  800876:	eb 05                	jmp    80087d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088a:	eb 07                	jmp    800893 <strchr+0x13>
		if (*s == c)
  80088c:	38 ca                	cmp    %cl,%dl
  80088e:	74 0f                	je     80089f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 10             	movzbl (%eax),%edx
  800896:	84 d2                	test   %dl,%dl
  800898:	75 f2                	jne    80088c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	eb 03                	jmp    8008b0 <strfind+0xf>
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	74 04                	je     8008bb <strfind+0x1a>
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	75 f2                	jne    8008ad <strfind+0xc>
			break;
	return (char *) s;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	74 36                	je     800903 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d3:	75 28                	jne    8008fd <memset+0x40>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 23                	jne    8008fd <memset+0x40>
		c &= 0xFF;
  8008da:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008de:	89 d3                	mov    %edx,%ebx
  8008e0:	c1 e3 08             	shl    $0x8,%ebx
  8008e3:	89 d6                	mov    %edx,%esi
  8008e5:	c1 e6 18             	shl    $0x18,%esi
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	c1 e0 10             	shl    $0x10,%eax
  8008ed:	09 f0                	or     %esi,%eax
  8008ef:	09 c2                	or     %eax,%edx
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f8:	fc                   	cld    
  8008f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fb:	eb 06                	jmp    800903 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800900:	fc                   	cld    
  800901:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800903:	89 f8                	mov    %edi,%eax
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 75 0c             	mov    0xc(%ebp),%esi
  800915:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800918:	39 c6                	cmp    %eax,%esi
  80091a:	73 35                	jae    800951 <memmove+0x47>
  80091c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091f:	39 d0                	cmp    %edx,%eax
  800921:	73 2e                	jae    800951 <memmove+0x47>
		s += n;
		d += n;
  800923:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800926:	89 d6                	mov    %edx,%esi
  800928:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	75 13                	jne    800945 <memmove+0x3b>
  800932:	f6 c1 03             	test   $0x3,%cl
  800935:	75 0e                	jne    800945 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800937:	83 ef 04             	sub    $0x4,%edi
  80093a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800940:	fd                   	std    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 09                	jmp    80094e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800945:	83 ef 01             	sub    $0x1,%edi
  800948:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094b:	fd                   	std    
  80094c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094e:	fc                   	cld    
  80094f:	eb 1d                	jmp    80096e <memmove+0x64>
  800951:	89 f2                	mov    %esi,%edx
  800953:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	f6 c2 03             	test   $0x3,%dl
  800958:	75 0f                	jne    800969 <memmove+0x5f>
  80095a:	f6 c1 03             	test   $0x3,%cl
  80095d:	75 0a                	jne    800969 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800962:	89 c7                	mov    %eax,%edi
  800964:	fc                   	cld    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb 05                	jmp    80096e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800969:	89 c7                	mov    %eax,%edi
  80096b:	fc                   	cld    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800975:	ff 75 10             	pushl  0x10(%ebp)
  800978:	ff 75 0c             	pushl  0xc(%ebp)
  80097b:	ff 75 08             	pushl  0x8(%ebp)
  80097e:	e8 87 ff ff ff       	call   80090a <memmove>
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800990:	89 c6                	mov    %eax,%esi
  800992:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800995:	eb 1a                	jmp    8009b1 <memcmp+0x2c>
		if (*s1 != *s2)
  800997:	0f b6 08             	movzbl (%eax),%ecx
  80099a:	0f b6 1a             	movzbl (%edx),%ebx
  80099d:	38 d9                	cmp    %bl,%cl
  80099f:	74 0a                	je     8009ab <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a1:	0f b6 c1             	movzbl %cl,%eax
  8009a4:	0f b6 db             	movzbl %bl,%ebx
  8009a7:	29 d8                	sub    %ebx,%eax
  8009a9:	eb 0f                	jmp    8009ba <memcmp+0x35>
		s1++, s2++;
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	39 f0                	cmp    %esi,%eax
  8009b3:	75 e2                	jne    800997 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c7:	89 c2                	mov    %eax,%edx
  8009c9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009cc:	eb 07                	jmp    8009d5 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	38 08                	cmp    %cl,(%eax)
  8009d0:	74 07                	je     8009d9 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	39 d0                	cmp    %edx,%eax
  8009d7:	72 f5                	jb     8009ce <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e7:	eb 03                	jmp    8009ec <strtol+0x11>
		s++;
  8009e9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	0f b6 01             	movzbl (%ecx),%eax
  8009ef:	3c 09                	cmp    $0x9,%al
  8009f1:	74 f6                	je     8009e9 <strtol+0xe>
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f2                	je     8009e9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f7:	3c 2b                	cmp    $0x2b,%al
  8009f9:	75 0a                	jne    800a05 <strtol+0x2a>
		s++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800a03:	eb 10                	jmp    800a15 <strtol+0x3a>
  800a05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0a:	3c 2d                	cmp    $0x2d,%al
  800a0c:	75 07                	jne    800a15 <strtol+0x3a>
		s++, neg = 1;
  800a0e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a11:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	0f 94 c0             	sete   %al
  800a1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a20:	75 19                	jne    800a3b <strtol+0x60>
  800a22:	80 39 30             	cmpb   $0x30,(%ecx)
  800a25:	75 14                	jne    800a3b <strtol+0x60>
  800a27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2b:	0f 85 82 00 00 00    	jne    800ab3 <strtol+0xd8>
		s += 2, base = 16;
  800a31:	83 c1 02             	add    $0x2,%ecx
  800a34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a39:	eb 16                	jmp    800a51 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a3b:	84 c0                	test   %al,%al
  800a3d:	74 12                	je     800a51 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 08                	jne    800a51 <strtol+0x76>
		s++, base = 8;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a59:	0f b6 11             	movzbl (%ecx),%edx
  800a5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5f:	89 f3                	mov    %esi,%ebx
  800a61:	80 fb 09             	cmp    $0x9,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x93>
			dig = *s - '0';
  800a66:	0f be d2             	movsbl %dl,%edx
  800a69:	83 ea 30             	sub    $0x30,%edx
  800a6c:	eb 22                	jmp    800a90 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 08                	ja     800a80 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 57             	sub    $0x57,%edx
  800a7e:	eb 10                	jmp    800a90 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 16                	ja     800aa0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a93:	7d 0f                	jge    800aa4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9e:	eb b9                	jmp    800a59 <strtol+0x7e>
  800aa0:	89 c2                	mov    %eax,%edx
  800aa2:	eb 02                	jmp    800aa6 <strtol+0xcb>
  800aa4:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaa:	74 0d                	je     800ab9 <strtol+0xde>
		*endptr = (char *) s;
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	89 0e                	mov    %ecx,(%esi)
  800ab1:	eb 06                	jmp    800ab9 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	84 c0                	test   %al,%al
  800ab5:	75 92                	jne    800a49 <strtol+0x6e>
  800ab7:	eb 98                	jmp    800a51 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab9:	f7 da                	neg    %edx
  800abb:	85 ff                	test   %edi,%edi
  800abd:	0f 45 c2             	cmovne %edx,%eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	89 c3                	mov    %eax,%ebx
  800ad8:	89 c7                	mov    %eax,%edi
  800ada:	89 c6                	mov    %eax,%esi
  800adc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 01 00 00 00       	mov    $0x1,%eax
  800af3:	89 d1                	mov    %edx,%ecx
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	89 d7                	mov    %edx,%edi
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b10:	b8 03 00 00 00       	mov    $0x3,%eax
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 cb                	mov    %ecx,%ebx
  800b1a:	89 cf                	mov    %ecx,%edi
  800b1c:	89 ce                	mov    %ecx,%esi
  800b1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	7e 17                	jle    800b3b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	50                   	push   %eax
  800b28:	6a 03                	push   $0x3
  800b2a:	68 1f 2b 80 00       	push   $0x802b1f
  800b2f:	6a 22                	push   $0x22
  800b31:	68 3c 2b 80 00       	push   $0x802b3c
  800b36:	e8 54 18 00 00       	call   80238f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_yield>:

void
sys_yield(void)
{      
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b8a:	be 00 00 00 00       	mov    $0x0,%esi
  800b8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9d:	89 f7                	mov    %esi,%edi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 04                	push   $0x4
  800bab:	68 1f 2b 80 00       	push   $0x802b1f
  800bb0:	6a 22                	push   $0x22
  800bb2:	68 3c 2b 80 00       	push   $0x802b3c
  800bb7:	e8 d3 17 00 00       	call   80238f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bcd:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bde:	8b 75 18             	mov    0x18(%ebp),%esi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 05                	push   $0x5
  800bed:	68 1f 2b 80 00       	push   $0x802b1f
  800bf2:	6a 22                	push   $0x22
  800bf4:	68 3c 2b 80 00       	push   $0x802b3c
  800bf9:	e8 91 17 00 00       	call   80238f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 06 00 00 00       	mov    $0x6,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 06                	push   $0x6
  800c2f:	68 1f 2b 80 00       	push   $0x802b1f
  800c34:	6a 22                	push   $0x22
  800c36:	68 3c 2b 80 00       	push   $0x802b3c
  800c3b:	e8 4f 17 00 00       	call   80238f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 08                	push   $0x8
  800c71:	68 1f 2b 80 00       	push   $0x802b1f
  800c76:	6a 22                	push   $0x22
  800c78:	68 3c 2b 80 00       	push   $0x802b3c
  800c7d:	e8 0d 17 00 00       	call   80238f <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 09                	push   $0x9
  800cb3:	68 1f 2b 80 00       	push   $0x802b1f
  800cb8:	6a 22                	push   $0x22
  800cba:	68 3c 2b 80 00       	push   $0x802b3c
  800cbf:	e8 cb 16 00 00       	call   80238f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 0a                	push   $0xa
  800cf5:	68 1f 2b 80 00       	push   $0x802b1f
  800cfa:	6a 22                	push   $0x22
  800cfc:	68 3c 2b 80 00       	push   $0x802b3c
  800d01:	e8 89 16 00 00       	call   80238f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d14:	be 00 00 00 00       	mov    $0x0,%esi
  800d19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 cb                	mov    %ecx,%ebx
  800d49:	89 cf                	mov    %ecx,%edi
  800d4b:	89 ce                	mov    %ecx,%esi
  800d4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 0d                	push   $0xd
  800d59:	68 1f 2b 80 00       	push   $0x802b1f
  800d5e:	6a 22                	push   $0x22
  800d60:	68 3c 2b 80 00       	push   $0x802b3c
  800d65:	e8 25 16 00 00       	call   80238f <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 d3                	mov    %edx,%ebx
  800d86:	89 d7                	mov    %edx,%edi
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 cb                	mov    %ecx,%ebx
  800da9:	89 cf                	mov    %ecx,%edi
  800dab:	89 ce                	mov    %ecx,%esi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 17                	jle    800dca <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	6a 0f                	push   $0xf
  800db9:	68 1f 2b 80 00       	push   $0x802b1f
  800dbe:	6a 22                	push   $0x22
  800dc0:	68 3c 2b 80 00       	push   $0x802b3c
  800dc5:	e8 c5 15 00 00       	call   80238f <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_recv>:

int
sys_recv(void *addr)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ddb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de0:	b8 10 00 00 00       	mov    $0x10,%eax
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	89 cb                	mov    %ecx,%ebx
  800dea:	89 cf                	mov    %ecx,%edi
  800dec:	89 ce                	mov    %ecx,%esi
  800dee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7e 17                	jle    800e0b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	50                   	push   %eax
  800df8:	6a 10                	push   $0x10
  800dfa:	68 1f 2b 80 00       	push   $0x802b1f
  800dff:	6a 22                	push   $0x22
  800e01:	68 3c 2b 80 00       	push   $0x802b3c
  800e06:	e8 84 15 00 00       	call   80238f <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	53                   	push   %ebx
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e1d:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e1f:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e23:	74 2e                	je     800e53 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e25:	89 c2                	mov    %eax,%edx
  800e27:	c1 ea 16             	shr    $0x16,%edx
  800e2a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e31:	f6 c2 01             	test   $0x1,%dl
  800e34:	74 1d                	je     800e53 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	c1 ea 0c             	shr    $0xc,%edx
  800e3b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e42:	f6 c1 01             	test   $0x1,%cl
  800e45:	74 0c                	je     800e53 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e4e:	f6 c6 08             	test   $0x8,%dh
  800e51:	75 14                	jne    800e67 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	68 4c 2b 80 00       	push   $0x802b4c
  800e5b:	6a 21                	push   $0x21
  800e5d:	68 df 2b 80 00       	push   $0x802bdf
  800e62:	e8 28 15 00 00       	call   80238f <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e6c:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	6a 07                	push   $0x7
  800e73:	68 00 f0 7f 00       	push   $0x7ff000
  800e78:	6a 00                	push   $0x0
  800e7a:	e8 02 fd ff ff       	call   800b81 <sys_page_alloc>
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	79 14                	jns    800e9a <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e86:	83 ec 04             	sub    $0x4,%esp
  800e89:	68 ea 2b 80 00       	push   $0x802bea
  800e8e:	6a 2b                	push   $0x2b
  800e90:	68 df 2b 80 00       	push   $0x802bdf
  800e95:	e8 f5 14 00 00       	call   80238f <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e9a:	83 ec 04             	sub    $0x4,%esp
  800e9d:	68 00 10 00 00       	push   $0x1000
  800ea2:	53                   	push   %ebx
  800ea3:	68 00 f0 7f 00       	push   $0x7ff000
  800ea8:	e8 5d fa ff ff       	call   80090a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800ead:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eb4:	53                   	push   %ebx
  800eb5:	6a 00                	push   $0x0
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 01 fd ff ff       	call   800bc4 <sys_page_map>
  800ec3:	83 c4 20             	add    $0x20,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 14                	jns    800ede <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 00 2c 80 00       	push   $0x802c00
  800ed2:	6a 2e                	push   $0x2e
  800ed4:	68 df 2b 80 00       	push   $0x802bdf
  800ed9:	e8 b1 14 00 00       	call   80238f <_panic>
        sys_page_unmap(0, PFTEMP); 
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	68 00 f0 7f 00       	push   $0x7ff000
  800ee6:	6a 00                	push   $0x0
  800ee8:	e8 19 fd ff ff       	call   800c06 <sys_page_unmap>
  800eed:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800efe:	68 13 0e 80 00       	push   $0x800e13
  800f03:	e8 cd 14 00 00       	call   8023d5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f08:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0d:	cd 30                	int    $0x30
  800f0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f12:	83 c4 10             	add    $0x10,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	79 12                	jns    800f2b <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f19:	50                   	push   %eax
  800f1a:	68 14 2c 80 00       	push   $0x802c14
  800f1f:	6a 6d                	push   $0x6d
  800f21:	68 df 2b 80 00       	push   $0x802bdf
  800f26:	e8 64 14 00 00       	call   80238f <_panic>
  800f2b:	89 c7                	mov    %eax,%edi
  800f2d:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f32:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f36:	75 21                	jne    800f59 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f38:	e8 06 fc ff ff       	call   800b43 <sys_getenvid>
  800f3d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f42:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f45:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4a:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f54:	e9 9c 01 00 00       	jmp    8010f5 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	c1 e8 16             	shr    $0x16,%eax
  800f5e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f65:	a8 01                	test   $0x1,%al
  800f67:	0f 84 f3 00 00 00    	je     801060 <fork+0x16b>
  800f6d:	89 d8                	mov    %ebx,%eax
  800f6f:	c1 e8 0c             	shr    $0xc,%eax
  800f72:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	0f 84 de 00 00 00    	je     801060 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f82:	89 c6                	mov    %eax,%esi
  800f84:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f87:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8e:	f6 c6 04             	test   $0x4,%dh
  800f91:	74 37                	je     800fca <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa2:	50                   	push   %eax
  800fa3:	56                   	push   %esi
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 17 fc ff ff       	call   800bc4 <sys_page_map>
  800fad:	83 c4 20             	add    $0x20,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	0f 89 a8 00 00 00    	jns    801060 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  800fb8:	50                   	push   %eax
  800fb9:	68 70 2b 80 00       	push   $0x802b70
  800fbe:	6a 49                	push   $0x49
  800fc0:	68 df 2b 80 00       	push   $0x802bdf
  800fc5:	e8 c5 13 00 00       	call   80238f <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800fca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd1:	f6 c6 08             	test   $0x8,%dh
  800fd4:	75 0b                	jne    800fe1 <fork+0xec>
  800fd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdd:	a8 02                	test   $0x2,%al
  800fdf:	74 57                	je     801038 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	68 05 08 00 00       	push   $0x805
  800fe9:	56                   	push   %esi
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	6a 00                	push   $0x0
  800fee:	e8 d1 fb ff ff       	call   800bc4 <sys_page_map>
  800ff3:	83 c4 20             	add    $0x20,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	79 12                	jns    80100c <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  800ffa:	50                   	push   %eax
  800ffb:	68 70 2b 80 00       	push   $0x802b70
  801000:	6a 4c                	push   $0x4c
  801002:	68 df 2b 80 00       	push   $0x802bdf
  801007:	e8 83 13 00 00       	call   80238f <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	68 05 08 00 00       	push   $0x805
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 a5 fb ff ff       	call   800bc4 <sys_page_map>
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	79 3a                	jns    801060 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801026:	50                   	push   %eax
  801027:	68 94 2b 80 00       	push   $0x802b94
  80102c:	6a 4e                	push   $0x4e
  80102e:	68 df 2b 80 00       	push   $0x802bdf
  801033:	e8 57 13 00 00       	call   80238f <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	6a 05                	push   $0x5
  80103d:	56                   	push   %esi
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	6a 00                	push   $0x0
  801042:	e8 7d fb ff ff       	call   800bc4 <sys_page_map>
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	79 12                	jns    801060 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80104e:	50                   	push   %eax
  80104f:	68 bc 2b 80 00       	push   $0x802bbc
  801054:	6a 50                	push   $0x50
  801056:	68 df 2b 80 00       	push   $0x802bdf
  80105b:	e8 2f 13 00 00       	call   80238f <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801060:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801066:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80106c:	0f 85 e7 fe ff ff    	jne    800f59 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	6a 07                	push   $0x7
  801077:	68 00 f0 bf ee       	push   $0xeebff000
  80107c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107f:	e8 fd fa ff ff       	call   800b81 <sys_page_alloc>
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 14                	jns    80109f <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	68 24 2c 80 00       	push   $0x802c24
  801093:	6a 76                	push   $0x76
  801095:	68 df 2b 80 00       	push   $0x802bdf
  80109a:	e8 f0 12 00 00       	call   80238f <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	68 44 24 80 00       	push   $0x802444
  8010a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010aa:	e8 1d fc ff ff       	call   800ccc <sys_env_set_pgfault_upcall>
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 14                	jns    8010ca <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8010b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b9:	68 3e 2c 80 00       	push   $0x802c3e
  8010be:	6a 79                	push   $0x79
  8010c0:	68 df 2b 80 00       	push   $0x802bdf
  8010c5:	e8 c5 12 00 00       	call   80238f <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8010ca:	83 ec 08             	sub    $0x8,%esp
  8010cd:	6a 02                	push   $0x2
  8010cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d2:	e8 71 fb ff ff       	call   800c48 <sys_env_set_status>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 14                	jns    8010f2 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8010de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e1:	68 5b 2c 80 00       	push   $0x802c5b
  8010e6:	6a 7b                	push   $0x7b
  8010e8:	68 df 2b 80 00       	push   $0x802bdf
  8010ed:	e8 9d 12 00 00       	call   80238f <_panic>
        return forkid;
  8010f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <sfork>:

// Challenge!
int
sfork(void)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801103:	68 72 2c 80 00       	push   $0x802c72
  801108:	68 83 00 00 00       	push   $0x83
  80110d:	68 df 2b 80 00       	push   $0x802bdf
  801112:	e8 78 12 00 00       	call   80238f <_panic>

00801117 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	8b 75 08             	mov    0x8(%ebp),%esi
  80111f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801122:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801125:	85 c0                	test   %eax,%eax
  801127:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80112c:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	50                   	push   %eax
  801133:	e8 f9 fb ff ff       	call   800d31 <sys_ipc_recv>
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	79 16                	jns    801155 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80113f:	85 f6                	test   %esi,%esi
  801141:	74 06                	je     801149 <ipc_recv+0x32>
  801143:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801149:	85 db                	test   %ebx,%ebx
  80114b:	74 2c                	je     801179 <ipc_recv+0x62>
  80114d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801153:	eb 24                	jmp    801179 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801155:	85 f6                	test   %esi,%esi
  801157:	74 0a                	je     801163 <ipc_recv+0x4c>
  801159:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80115e:	8b 40 74             	mov    0x74(%eax),%eax
  801161:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801163:	85 db                	test   %ebx,%ebx
  801165:	74 0a                	je     801171 <ipc_recv+0x5a>
  801167:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80116c:	8b 40 78             	mov    0x78(%eax),%eax
  80116f:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801171:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801176:	8b 40 70             	mov    0x70(%eax),%eax
}
  801179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	57                   	push   %edi
  801184:	56                   	push   %esi
  801185:	53                   	push   %ebx
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80118f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801192:	85 db                	test   %ebx,%ebx
  801194:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801199:	0f 44 d8             	cmove  %eax,%ebx
  80119c:	eb 1c                	jmp    8011ba <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80119e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011a1:	74 12                	je     8011b5 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8011a3:	50                   	push   %eax
  8011a4:	68 88 2c 80 00       	push   $0x802c88
  8011a9:	6a 39                	push   $0x39
  8011ab:	68 a3 2c 80 00       	push   $0x802ca3
  8011b0:	e8 da 11 00 00       	call   80238f <_panic>
                 sys_yield();
  8011b5:	e8 a8 f9 ff ff       	call   800b62 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011ba:	ff 75 14             	pushl  0x14(%ebp)
  8011bd:	53                   	push   %ebx
  8011be:	56                   	push   %esi
  8011bf:	57                   	push   %edi
  8011c0:	e8 49 fb ff ff       	call   800d0e <sys_ipc_try_send>
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 d2                	js     80119e <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8011cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011df:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011e8:	8b 52 50             	mov    0x50(%edx),%edx
  8011eb:	39 ca                	cmp    %ecx,%edx
  8011ed:	75 0d                	jne    8011fc <ipc_find_env+0x28>
			return envs[i].env_id;
  8011ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011f2:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8011f7:	8b 40 08             	mov    0x8(%eax),%eax
  8011fa:	eb 0e                	jmp    80120a <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011fc:	83 c0 01             	add    $0x1,%eax
  8011ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801204:	75 d9                	jne    8011df <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801206:	66 b8 00 00          	mov    $0x0,%ax
}
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	05 00 00 00 30       	add    $0x30000000,%eax
  801217:	c1 e8 0c             	shr    $0xc,%eax
}
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121f:	8b 45 08             	mov    0x8(%ebp),%eax
  801222:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801227:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80122c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801239:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80123e:	89 c2                	mov    %eax,%edx
  801240:	c1 ea 16             	shr    $0x16,%edx
  801243:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	74 11                	je     801260 <fd_alloc+0x2d>
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 ea 0c             	shr    $0xc,%edx
  801254:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125b:	f6 c2 01             	test   $0x1,%dl
  80125e:	75 09                	jne    801269 <fd_alloc+0x36>
			*fd_store = fd;
  801260:	89 01                	mov    %eax,(%ecx)
			return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	eb 17                	jmp    801280 <fd_alloc+0x4d>
  801269:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80126e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801273:	75 c9                	jne    80123e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801275:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80127b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801288:	83 f8 1f             	cmp    $0x1f,%eax
  80128b:	77 36                	ja     8012c3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80128d:	c1 e0 0c             	shl    $0xc,%eax
  801290:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801295:	89 c2                	mov    %eax,%edx
  801297:	c1 ea 16             	shr    $0x16,%edx
  80129a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a1:	f6 c2 01             	test   $0x1,%dl
  8012a4:	74 24                	je     8012ca <fd_lookup+0x48>
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 0c             	shr    $0xc,%edx
  8012ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 1a                	je     8012d1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	eb 13                	jmp    8012d6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb 0c                	jmp    8012d6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cf:	eb 05                	jmp    8012d6 <fd_lookup+0x54>
  8012d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e6:	eb 13                	jmp    8012fb <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8012e8:	39 08                	cmp    %ecx,(%eax)
  8012ea:	75 0c                	jne    8012f8 <dev_lookup+0x20>
			*dev = devtab[i];
  8012ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f6:	eb 36                	jmp    80132e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f8:	83 c2 01             	add    $0x1,%edx
  8012fb:	8b 04 95 2c 2d 80 00 	mov    0x802d2c(,%edx,4),%eax
  801302:	85 c0                	test   %eax,%eax
  801304:	75 e2                	jne    8012e8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801306:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80130b:	8b 40 48             	mov    0x48(%eax),%eax
  80130e:	83 ec 04             	sub    $0x4,%esp
  801311:	51                   	push   %ecx
  801312:	50                   	push   %eax
  801313:	68 b0 2c 80 00       	push   $0x802cb0
  801318:	e8 d4 ee ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80131d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801320:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80132e:	c9                   	leave  
  80132f:	c3                   	ret    

00801330 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	56                   	push   %esi
  801334:	53                   	push   %ebx
  801335:	83 ec 10             	sub    $0x10,%esp
  801338:	8b 75 08             	mov    0x8(%ebp),%esi
  80133b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801342:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801348:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134b:	50                   	push   %eax
  80134c:	e8 31 ff ff ff       	call   801282 <fd_lookup>
  801351:	83 c4 08             	add    $0x8,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 05                	js     80135d <fd_close+0x2d>
	    || fd != fd2)
  801358:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135b:	74 0c                	je     801369 <fd_close+0x39>
		return (must_exist ? r : 0);
  80135d:	84 db                	test   %bl,%bl
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	0f 44 c2             	cmove  %edx,%eax
  801367:	eb 41                	jmp    8013aa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	ff 36                	pushl  (%esi)
  801372:	e8 61 ff ff ff       	call   8012d8 <dev_lookup>
  801377:	89 c3                	mov    %eax,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 1a                	js     80139a <fd_close+0x6a>
		if (dev->dev_close)
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801386:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80138b:	85 c0                	test   %eax,%eax
  80138d:	74 0b                	je     80139a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	56                   	push   %esi
  801393:	ff d0                	call   *%eax
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	56                   	push   %esi
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 61 f8 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	89 d8                	mov    %ebx,%eax
}
  8013aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	ff 75 08             	pushl  0x8(%ebp)
  8013be:	e8 bf fe ff ff       	call   801282 <fd_lookup>
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	85 d2                	test   %edx,%edx
  8013ca:	78 10                	js     8013dc <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	6a 01                	push   $0x1
  8013d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d4:	e8 57 ff ff ff       	call   801330 <fd_close>
  8013d9:	83 c4 10             	add    $0x10,%esp
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <close_all>:

void
close_all(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	53                   	push   %ebx
  8013ee:	e8 be ff ff ff       	call   8013b1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	83 c3 01             	add    $0x1,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	83 fb 20             	cmp    $0x20,%ebx
  8013fc:	75 ec                	jne    8013ea <close_all+0xc>
		close(i);
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	57                   	push   %edi
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 2c             	sub    $0x2c,%esp
  80140c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80140f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	ff 75 08             	pushl  0x8(%ebp)
  801416:	e8 67 fe ff ff       	call   801282 <fd_lookup>
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	83 c4 08             	add    $0x8,%esp
  801420:	85 d2                	test   %edx,%edx
  801422:	0f 88 c1 00 00 00    	js     8014e9 <dup+0xe6>
		return r;
	close(newfdnum);
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	56                   	push   %esi
  80142c:	e8 80 ff ff ff       	call   8013b1 <close>

	newfd = INDEX2FD(newfdnum);
  801431:	89 f3                	mov    %esi,%ebx
  801433:	c1 e3 0c             	shl    $0xc,%ebx
  801436:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80143c:	83 c4 04             	add    $0x4,%esp
  80143f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801442:	e8 d5 fd ff ff       	call   80121c <fd2data>
  801447:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801449:	89 1c 24             	mov    %ebx,(%esp)
  80144c:	e8 cb fd ff ff       	call   80121c <fd2data>
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801457:	89 f8                	mov    %edi,%eax
  801459:	c1 e8 16             	shr    $0x16,%eax
  80145c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801463:	a8 01                	test   $0x1,%al
  801465:	74 37                	je     80149e <dup+0x9b>
  801467:	89 f8                	mov    %edi,%eax
  801469:	c1 e8 0c             	shr    $0xc,%eax
  80146c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801473:	f6 c2 01             	test   $0x1,%dl
  801476:	74 26                	je     80149e <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801478:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147f:	83 ec 0c             	sub    $0xc,%esp
  801482:	25 07 0e 00 00       	and    $0xe07,%eax
  801487:	50                   	push   %eax
  801488:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148b:	6a 00                	push   $0x0
  80148d:	57                   	push   %edi
  80148e:	6a 00                	push   $0x0
  801490:	e8 2f f7 ff ff       	call   800bc4 <sys_page_map>
  801495:	89 c7                	mov    %eax,%edi
  801497:	83 c4 20             	add    $0x20,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 2e                	js     8014cc <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a1:	89 d0                	mov    %edx,%eax
  8014a3:	c1 e8 0c             	shr    $0xc,%eax
  8014a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b5:	50                   	push   %eax
  8014b6:	53                   	push   %ebx
  8014b7:	6a 00                	push   $0x0
  8014b9:	52                   	push   %edx
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 03 f7 ff ff       	call   800bc4 <sys_page_map>
  8014c1:	89 c7                	mov    %eax,%edi
  8014c3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014c6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c8:	85 ff                	test   %edi,%edi
  8014ca:	79 1d                	jns    8014e9 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	53                   	push   %ebx
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 2f f7 ff ff       	call   800c06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 22 f7 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	89 f8                	mov    %edi,%eax
}
  8014e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    

008014f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 14             	sub    $0x14,%esp
  8014f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	53                   	push   %ebx
  801500:	e8 7d fd ff ff       	call   801282 <fd_lookup>
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	89 c2                	mov    %eax,%edx
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 6d                	js     80157b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801518:	ff 30                	pushl  (%eax)
  80151a:	e8 b9 fd ff ff       	call   8012d8 <dev_lookup>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 4c                	js     801572 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801526:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801529:	8b 42 08             	mov    0x8(%edx),%eax
  80152c:	83 e0 03             	and    $0x3,%eax
  80152f:	83 f8 01             	cmp    $0x1,%eax
  801532:	75 21                	jne    801555 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801534:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801539:	8b 40 48             	mov    0x48(%eax),%eax
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	53                   	push   %ebx
  801540:	50                   	push   %eax
  801541:	68 f1 2c 80 00       	push   $0x802cf1
  801546:	e8 a6 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801553:	eb 26                	jmp    80157b <read+0x8a>
	}
	if (!dev->dev_read)
  801555:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801558:	8b 40 08             	mov    0x8(%eax),%eax
  80155b:	85 c0                	test   %eax,%eax
  80155d:	74 17                	je     801576 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	ff 75 10             	pushl  0x10(%ebp)
  801565:	ff 75 0c             	pushl  0xc(%ebp)
  801568:	52                   	push   %edx
  801569:	ff d0                	call   *%eax
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	eb 09                	jmp    80157b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801572:	89 c2                	mov    %eax,%edx
  801574:	eb 05                	jmp    80157b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801576:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801591:	bb 00 00 00 00       	mov    $0x0,%ebx
  801596:	eb 21                	jmp    8015b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801598:	83 ec 04             	sub    $0x4,%esp
  80159b:	89 f0                	mov    %esi,%eax
  80159d:	29 d8                	sub    %ebx,%eax
  80159f:	50                   	push   %eax
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	03 45 0c             	add    0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	57                   	push   %edi
  8015a7:	e8 45 ff ff ff       	call   8014f1 <read>
		if (m < 0)
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 0c                	js     8015bf <readn+0x3d>
			return m;
		if (m == 0)
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	74 06                	je     8015bd <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b7:	01 c3                	add    %eax,%ebx
  8015b9:	39 f3                	cmp    %esi,%ebx
  8015bb:	72 db                	jb     801598 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015bd:	89 d8                	mov    %ebx,%eax
}
  8015bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c2:	5b                   	pop    %ebx
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 14             	sub    $0x14,%esp
  8015ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	53                   	push   %ebx
  8015d6:	e8 a7 fc ff ff       	call   801282 <fd_lookup>
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 68                	js     80164c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	ff 30                	pushl  (%eax)
  8015f0:	e8 e3 fc ff ff       	call   8012d8 <dev_lookup>
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 47                	js     801643 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801603:	75 21                	jne    801626 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801605:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80160a:	8b 40 48             	mov    0x48(%eax),%eax
  80160d:	83 ec 04             	sub    $0x4,%esp
  801610:	53                   	push   %ebx
  801611:	50                   	push   %eax
  801612:	68 0d 2d 80 00       	push   $0x802d0d
  801617:	e8 d5 eb ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801624:	eb 26                	jmp    80164c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801626:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801629:	8b 52 0c             	mov    0xc(%edx),%edx
  80162c:	85 d2                	test   %edx,%edx
  80162e:	74 17                	je     801647 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801630:	83 ec 04             	sub    $0x4,%esp
  801633:	ff 75 10             	pushl  0x10(%ebp)
  801636:	ff 75 0c             	pushl  0xc(%ebp)
  801639:	50                   	push   %eax
  80163a:	ff d2                	call   *%edx
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	eb 09                	jmp    80164c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801643:	89 c2                	mov    %eax,%edx
  801645:	eb 05                	jmp    80164c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801647:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80164c:	89 d0                	mov    %edx,%eax
  80164e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <seek>:

int
seek(int fdnum, off_t offset)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801659:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	ff 75 08             	pushl  0x8(%ebp)
  801660:	e8 1d fc ff ff       	call   801282 <fd_lookup>
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 0e                	js     80167a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80166c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80166f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801672:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 14             	sub    $0x14,%esp
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	53                   	push   %ebx
  80168b:	e8 f2 fb ff ff       	call   801282 <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	89 c2                	mov    %eax,%edx
  801695:	85 c0                	test   %eax,%eax
  801697:	78 65                	js     8016fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a3:	ff 30                	pushl  (%eax)
  8016a5:	e8 2e fc ff ff       	call   8012d8 <dev_lookup>
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 44                	js     8016f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b8:	75 21                	jne    8016db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ba:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016bf:	8b 40 48             	mov    0x48(%eax),%eax
  8016c2:	83 ec 04             	sub    $0x4,%esp
  8016c5:	53                   	push   %ebx
  8016c6:	50                   	push   %eax
  8016c7:	68 d0 2c 80 00       	push   $0x802cd0
  8016cc:	e8 20 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d9:	eb 23                	jmp    8016fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016de:	8b 52 18             	mov    0x18(%edx),%edx
  8016e1:	85 d2                	test   %edx,%edx
  8016e3:	74 14                	je     8016f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	50                   	push   %eax
  8016ec:	ff d2                	call   *%edx
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	eb 09                	jmp    8016fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	eb 05                	jmp    8016fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016fe:	89 d0                	mov    %edx,%eax
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	53                   	push   %ebx
  801709:	83 ec 14             	sub    $0x14,%esp
  80170c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	ff 75 08             	pushl  0x8(%ebp)
  801716:	e8 67 fb ff ff       	call   801282 <fd_lookup>
  80171b:	83 c4 08             	add    $0x8,%esp
  80171e:	89 c2                	mov    %eax,%edx
  801720:	85 c0                	test   %eax,%eax
  801722:	78 58                	js     80177c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172e:	ff 30                	pushl  (%eax)
  801730:	e8 a3 fb ff ff       	call   8012d8 <dev_lookup>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 37                	js     801773 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80173c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801743:	74 32                	je     801777 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801745:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801748:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174f:	00 00 00 
	stat->st_isdir = 0;
  801752:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801759:	00 00 00 
	stat->st_dev = dev;
  80175c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	53                   	push   %ebx
  801766:	ff 75 f0             	pushl  -0x10(%ebp)
  801769:	ff 50 14             	call   *0x14(%eax)
  80176c:	89 c2                	mov    %eax,%edx
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	eb 09                	jmp    80177c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801773:	89 c2                	mov    %eax,%edx
  801775:	eb 05                	jmp    80177c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801777:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80177c:	89 d0                	mov    %edx,%eax
  80177e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	6a 00                	push   $0x0
  80178d:	ff 75 08             	pushl  0x8(%ebp)
  801790:	e8 09 02 00 00       	call   80199e <open>
  801795:	89 c3                	mov    %eax,%ebx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 db                	test   %ebx,%ebx
  80179c:	78 1b                	js     8017b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	53                   	push   %ebx
  8017a5:	e8 5b ff ff ff       	call   801705 <fstat>
  8017aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ac:	89 1c 24             	mov    %ebx,(%esp)
  8017af:	e8 fd fb ff ff       	call   8013b1 <close>
	return r;
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	89 f0                	mov    %esi,%eax
}
  8017b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	89 c6                	mov    %eax,%esi
  8017c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d0:	75 12                	jne    8017e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	6a 01                	push   $0x1
  8017d7:	e8 f8 f9 ff ff       	call   8011d4 <ipc_find_env>
  8017dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8017e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e4:	6a 07                	push   $0x7
  8017e6:	68 00 50 80 00       	push   $0x805000
  8017eb:	56                   	push   %esi
  8017ec:	ff 35 00 40 80 00    	pushl  0x804000
  8017f2:	e8 89 f9 ff ff       	call   801180 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f7:	83 c4 0c             	add    $0xc,%esp
  8017fa:	6a 00                	push   $0x0
  8017fc:	53                   	push   %ebx
  8017fd:	6a 00                	push   $0x0
  8017ff:	e8 13 f9 ff ff       	call   801117 <ipc_recv>
}
  801804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
  801829:	b8 02 00 00 00       	mov    $0x2,%eax
  80182e:	e8 8d ff ff ff       	call   8017c0 <fsipc>
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	8b 40 0c             	mov    0xc(%eax),%eax
  801841:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 06 00 00 00       	mov    $0x6,%eax
  801850:	e8 6b ff ff ff       	call   8017c0 <fsipc>
}
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 40 0c             	mov    0xc(%eax),%eax
  801867:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186c:	ba 00 00 00 00       	mov    $0x0,%edx
  801871:	b8 05 00 00 00       	mov    $0x5,%eax
  801876:	e8 45 ff ff ff       	call   8017c0 <fsipc>
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	85 d2                	test   %edx,%edx
  80187f:	78 2c                	js     8018ad <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	68 00 50 80 00       	push   $0x805000
  801889:	53                   	push   %ebx
  80188a:	e8 e9 ee ff ff       	call   800778 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188f:	a1 80 50 80 00       	mov    0x805080,%eax
  801894:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80189a:	a1 84 50 80 00       	mov    0x805084,%eax
  80189f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	57                   	push   %edi
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c4:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8018c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018cc:	eb 3d                	jmp    80190b <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8018ce:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8018d4:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8018d9:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8018dc:	83 ec 04             	sub    $0x4,%esp
  8018df:	57                   	push   %edi
  8018e0:	53                   	push   %ebx
  8018e1:	68 08 50 80 00       	push   $0x805008
  8018e6:	e8 1f f0 ff ff       	call   80090a <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018eb:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018fb:	e8 c0 fe ff ff       	call   8017c0 <fsipc>
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	78 0d                	js     801914 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801907:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801909:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80190b:	85 f6                	test   %esi,%esi
  80190d:	75 bf                	jne    8018ce <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801914:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5f                   	pop    %edi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
  801927:	8b 40 0c             	mov    0xc(%eax),%eax
  80192a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80192f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	b8 03 00 00 00       	mov    $0x3,%eax
  80193f:	e8 7c fe ff ff       	call   8017c0 <fsipc>
  801944:	89 c3                	mov    %eax,%ebx
  801946:	85 c0                	test   %eax,%eax
  801948:	78 4b                	js     801995 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80194a:	39 c6                	cmp    %eax,%esi
  80194c:	73 16                	jae    801964 <devfile_read+0x48>
  80194e:	68 40 2d 80 00       	push   $0x802d40
  801953:	68 47 2d 80 00       	push   $0x802d47
  801958:	6a 7c                	push   $0x7c
  80195a:	68 5c 2d 80 00       	push   $0x802d5c
  80195f:	e8 2b 0a 00 00       	call   80238f <_panic>
	assert(r <= PGSIZE);
  801964:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801969:	7e 16                	jle    801981 <devfile_read+0x65>
  80196b:	68 67 2d 80 00       	push   $0x802d67
  801970:	68 47 2d 80 00       	push   $0x802d47
  801975:	6a 7d                	push   $0x7d
  801977:	68 5c 2d 80 00       	push   $0x802d5c
  80197c:	e8 0e 0a 00 00       	call   80238f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801981:	83 ec 04             	sub    $0x4,%esp
  801984:	50                   	push   %eax
  801985:	68 00 50 80 00       	push   $0x805000
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	e8 78 ef ff ff       	call   80090a <memmove>
	return r;
  801992:	83 c4 10             	add    $0x10,%esp
}
  801995:	89 d8                	mov    %ebx,%eax
  801997:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 20             	sub    $0x20,%esp
  8019a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a8:	53                   	push   %ebx
  8019a9:	e8 91 ed ff ff       	call   80073f <strlen>
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b6:	7f 67                	jg     801a1f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b8:	83 ec 0c             	sub    $0xc,%esp
  8019bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019be:	50                   	push   %eax
  8019bf:	e8 6f f8 ff ff       	call   801233 <fd_alloc>
  8019c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 57                	js     801a24 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	53                   	push   %ebx
  8019d1:	68 00 50 80 00       	push   $0x805000
  8019d6:	e8 9d ed ff ff       	call   800778 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019de:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019eb:	e8 d0 fd ff ff       	call   8017c0 <fsipc>
  8019f0:	89 c3                	mov    %eax,%ebx
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	79 14                	jns    801a0d <open+0x6f>
		fd_close(fd, 0);
  8019f9:	83 ec 08             	sub    $0x8,%esp
  8019fc:	6a 00                	push   $0x0
  8019fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801a01:	e8 2a f9 ff ff       	call   801330 <fd_close>
		return r;
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	89 da                	mov    %ebx,%edx
  801a0b:	eb 17                	jmp    801a24 <open+0x86>
	}

	return fd2num(fd);
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	ff 75 f4             	pushl  -0xc(%ebp)
  801a13:	e8 f4 f7 ff ff       	call   80120c <fd2num>
  801a18:	89 c2                	mov    %eax,%edx
  801a1a:	83 c4 10             	add    $0x10,%esp
  801a1d:	eb 05                	jmp    801a24 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a1f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a24:	89 d0                	mov    %edx,%eax
  801a26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3b:	e8 80 fd ff ff       	call   8017c0 <fsipc>
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a48:	68 73 2d 80 00       	push   $0x802d73
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	e8 23 ed ff ff       	call   800778 <strcpy>
	return 0;
}
  801a55:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 10             	sub    $0x10,%esp
  801a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a66:	53                   	push   %ebx
  801a67:	e8 fc 09 00 00       	call   802468 <pageref>
  801a6c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a74:	83 f8 01             	cmp    $0x1,%eax
  801a77:	75 10                	jne    801a89 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff 73 0c             	pushl  0xc(%ebx)
  801a7f:	e8 ca 02 00 00       	call   801d4e <nsipc_close>
  801a84:	89 c2                	mov    %eax,%edx
  801a86:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a89:	89 d0                	mov    %edx,%eax
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a96:	6a 00                	push   $0x0
  801a98:	ff 75 10             	pushl  0x10(%ebp)
  801a9b:	ff 75 0c             	pushl  0xc(%ebp)
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	ff 70 0c             	pushl  0xc(%eax)
  801aa4:	e8 82 03 00 00       	call   801e2b <nsipc_send>
}
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ab1:	6a 00                	push   $0x0
  801ab3:	ff 75 10             	pushl  0x10(%ebp)
  801ab6:	ff 75 0c             	pushl  0xc(%ebp)
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	ff 70 0c             	pushl  0xc(%eax)
  801abf:	e8 fb 02 00 00       	call   801dbf <nsipc_recv>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801acc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801acf:	52                   	push   %edx
  801ad0:	50                   	push   %eax
  801ad1:	e8 ac f7 ff ff       	call   801282 <fd_lookup>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	78 17                	js     801af4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ae6:	39 08                	cmp    %ecx,(%eax)
  801ae8:	75 05                	jne    801aef <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801aea:	8b 40 0c             	mov    0xc(%eax),%eax
  801aed:	eb 05                	jmp    801af4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	83 ec 1c             	sub    $0x1c,%esp
  801afe:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b03:	50                   	push   %eax
  801b04:	e8 2a f7 ff ff       	call   801233 <fd_alloc>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 1b                	js     801b2d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	68 07 04 00 00       	push   $0x407
  801b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 5d f0 ff ff       	call   800b81 <sys_page_alloc>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	79 10                	jns    801b3d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	56                   	push   %esi
  801b31:	e8 18 02 00 00       	call   801d4e <nsipc_close>
		return r;
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	89 d8                	mov    %ebx,%eax
  801b3b:	eb 24                	jmp    801b61 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b46:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b4b:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b52:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	52                   	push   %edx
  801b59:	e8 ae f6 ff ff       	call   80120c <fd2num>
  801b5e:	83 c4 10             	add    $0x10,%esp
}
  801b61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	e8 50 ff ff ff       	call   801ac6 <fd2sockid>
		return r;
  801b76:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 1f                	js     801b9b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	ff 75 10             	pushl  0x10(%ebp)
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	50                   	push   %eax
  801b86:	e8 1c 01 00 00       	call   801ca7 <nsipc_accept>
  801b8b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b8e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 07                	js     801b9b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b94:	e8 5d ff ff ff       	call   801af6 <alloc_sockfd>
  801b99:	89 c1                	mov    %eax,%ecx
}
  801b9b:	89 c8                	mov    %ecx,%eax
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba8:	e8 19 ff ff ff       	call   801ac6 <fd2sockid>
  801bad:	89 c2                	mov    %eax,%edx
  801baf:	85 d2                	test   %edx,%edx
  801bb1:	78 12                	js     801bc5 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801bb3:	83 ec 04             	sub    $0x4,%esp
  801bb6:	ff 75 10             	pushl  0x10(%ebp)
  801bb9:	ff 75 0c             	pushl  0xc(%ebp)
  801bbc:	52                   	push   %edx
  801bbd:	e8 35 01 00 00       	call   801cf7 <nsipc_bind>
  801bc2:	83 c4 10             	add    $0x10,%esp
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <shutdown>:

int
shutdown(int s, int how)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd0:	e8 f1 fe ff ff       	call   801ac6 <fd2sockid>
  801bd5:	89 c2                	mov    %eax,%edx
  801bd7:	85 d2                	test   %edx,%edx
  801bd9:	78 0f                	js     801bea <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801bdb:	83 ec 08             	sub    $0x8,%esp
  801bde:	ff 75 0c             	pushl  0xc(%ebp)
  801be1:	52                   	push   %edx
  801be2:	e8 45 01 00 00       	call   801d2c <nsipc_shutdown>
  801be7:	83 c4 10             	add    $0x10,%esp
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf5:	e8 cc fe ff ff       	call   801ac6 <fd2sockid>
  801bfa:	89 c2                	mov    %eax,%edx
  801bfc:	85 d2                	test   %edx,%edx
  801bfe:	78 12                	js     801c12 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c00:	83 ec 04             	sub    $0x4,%esp
  801c03:	ff 75 10             	pushl  0x10(%ebp)
  801c06:	ff 75 0c             	pushl  0xc(%ebp)
  801c09:	52                   	push   %edx
  801c0a:	e8 59 01 00 00       	call   801d68 <nsipc_connect>
  801c0f:	83 c4 10             	add    $0x10,%esp
}
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <listen>:

int
listen(int s, int backlog)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	e8 a4 fe ff ff       	call   801ac6 <fd2sockid>
  801c22:	89 c2                	mov    %eax,%edx
  801c24:	85 d2                	test   %edx,%edx
  801c26:	78 0f                	js     801c37 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c28:	83 ec 08             	sub    $0x8,%esp
  801c2b:	ff 75 0c             	pushl  0xc(%ebp)
  801c2e:	52                   	push   %edx
  801c2f:	e8 69 01 00 00       	call   801d9d <nsipc_listen>
  801c34:	83 c4 10             	add    $0x10,%esp
}
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c3f:	ff 75 10             	pushl  0x10(%ebp)
  801c42:	ff 75 0c             	pushl  0xc(%ebp)
  801c45:	ff 75 08             	pushl  0x8(%ebp)
  801c48:	e8 3c 02 00 00       	call   801e89 <nsipc_socket>
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	85 d2                	test   %edx,%edx
  801c54:	78 05                	js     801c5b <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801c56:	e8 9b fe ff ff       	call   801af6 <alloc_sockfd>
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	53                   	push   %ebx
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c66:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c6d:	75 12                	jne    801c81 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	6a 02                	push   $0x2
  801c74:	e8 5b f5 ff ff       	call   8011d4 <ipc_find_env>
  801c79:	a3 04 40 80 00       	mov    %eax,0x804004
  801c7e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c81:	6a 07                	push   $0x7
  801c83:	68 00 60 80 00       	push   $0x806000
  801c88:	53                   	push   %ebx
  801c89:	ff 35 04 40 80 00    	pushl  0x804004
  801c8f:	e8 ec f4 ff ff       	call   801180 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c94:	83 c4 0c             	add    $0xc,%esp
  801c97:	6a 00                	push   $0x0
  801c99:	6a 00                	push   $0x0
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 75 f4 ff ff       	call   801117 <ipc_recv>
}
  801ca2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	56                   	push   %esi
  801cab:	53                   	push   %ebx
  801cac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cb7:	8b 06                	mov    (%esi),%eax
  801cb9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc3:	e8 95 ff ff ff       	call   801c5d <nsipc>
  801cc8:	89 c3                	mov    %eax,%ebx
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 20                	js     801cee <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cce:	83 ec 04             	sub    $0x4,%esp
  801cd1:	ff 35 10 60 80 00    	pushl  0x806010
  801cd7:	68 00 60 80 00       	push   $0x806000
  801cdc:	ff 75 0c             	pushl  0xc(%ebp)
  801cdf:	e8 26 ec ff ff       	call   80090a <memmove>
		*addrlen = ret->ret_addrlen;
  801ce4:	a1 10 60 80 00       	mov    0x806010,%eax
  801ce9:	89 06                	mov    %eax,(%esi)
  801ceb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 08             	sub    $0x8,%esp
  801cfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d09:	53                   	push   %ebx
  801d0a:	ff 75 0c             	pushl  0xc(%ebp)
  801d0d:	68 04 60 80 00       	push   $0x806004
  801d12:	e8 f3 eb ff ff       	call   80090a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d17:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d1d:	b8 02 00 00 00       	mov    $0x2,%eax
  801d22:	e8 36 ff ff ff       	call   801c5d <nsipc>
}
  801d27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d42:	b8 03 00 00 00       	mov    $0x3,%eax
  801d47:	e8 11 ff ff ff       	call   801c5d <nsipc>
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <nsipc_close>:

int
nsipc_close(int s)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d5c:	b8 04 00 00 00       	mov    $0x4,%eax
  801d61:	e8 f7 fe ff ff       	call   801c5d <nsipc>
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	53                   	push   %ebx
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d7a:	53                   	push   %ebx
  801d7b:	ff 75 0c             	pushl  0xc(%ebp)
  801d7e:	68 04 60 80 00       	push   $0x806004
  801d83:	e8 82 eb ff ff       	call   80090a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d88:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d8e:	b8 05 00 00 00       	mov    $0x5,%eax
  801d93:	e8 c5 fe ff ff       	call   801c5d <nsipc>
}
  801d98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dae:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801db3:	b8 06 00 00 00       	mov    $0x6,%eax
  801db8:	e8 a0 fe ff ff       	call   801c5d <nsipc>
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dcf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dd5:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ddd:	b8 07 00 00 00       	mov    $0x7,%eax
  801de2:	e8 76 fe ff ff       	call   801c5d <nsipc>
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 35                	js     801e22 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ded:	39 f0                	cmp    %esi,%eax
  801def:	7f 07                	jg     801df8 <nsipc_recv+0x39>
  801df1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801df6:	7e 16                	jle    801e0e <nsipc_recv+0x4f>
  801df8:	68 7f 2d 80 00       	push   $0x802d7f
  801dfd:	68 47 2d 80 00       	push   $0x802d47
  801e02:	6a 62                	push   $0x62
  801e04:	68 94 2d 80 00       	push   $0x802d94
  801e09:	e8 81 05 00 00       	call   80238f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e0e:	83 ec 04             	sub    $0x4,%esp
  801e11:	50                   	push   %eax
  801e12:	68 00 60 80 00       	push   $0x806000
  801e17:	ff 75 0c             	pushl  0xc(%ebp)
  801e1a:	e8 eb ea ff ff       	call   80090a <memmove>
  801e1f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e22:	89 d8                	mov    %ebx,%eax
  801e24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	53                   	push   %ebx
  801e2f:	83 ec 04             	sub    $0x4,%esp
  801e32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e3d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e43:	7e 16                	jle    801e5b <nsipc_send+0x30>
  801e45:	68 a0 2d 80 00       	push   $0x802da0
  801e4a:	68 47 2d 80 00       	push   $0x802d47
  801e4f:	6a 6d                	push   $0x6d
  801e51:	68 94 2d 80 00       	push   $0x802d94
  801e56:	e8 34 05 00 00       	call   80238f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e5b:	83 ec 04             	sub    $0x4,%esp
  801e5e:	53                   	push   %ebx
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	68 0c 60 80 00       	push   $0x80600c
  801e67:	e8 9e ea ff ff       	call   80090a <memmove>
	nsipcbuf.send.req_size = size;
  801e6c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e72:	8b 45 14             	mov    0x14(%ebp),%eax
  801e75:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e7a:	b8 08 00 00 00       	mov    $0x8,%eax
  801e7f:	e8 d9 fd ff ff       	call   801c5d <nsipc>
}
  801e84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ea7:	b8 09 00 00 00       	mov    $0x9,%eax
  801eac:	e8 ac fd ff ff       	call   801c5d <nsipc>
}
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ebb:	83 ec 0c             	sub    $0xc,%esp
  801ebe:	ff 75 08             	pushl  0x8(%ebp)
  801ec1:	e8 56 f3 ff ff       	call   80121c <fd2data>
  801ec6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ec8:	83 c4 08             	add    $0x8,%esp
  801ecb:	68 ac 2d 80 00       	push   $0x802dac
  801ed0:	53                   	push   %ebx
  801ed1:	e8 a2 e8 ff ff       	call   800778 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ed6:	8b 56 04             	mov    0x4(%esi),%edx
  801ed9:	89 d0                	mov    %edx,%eax
  801edb:	2b 06                	sub    (%esi),%eax
  801edd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eea:	00 00 00 
	stat->st_dev = &devpipe;
  801eed:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ef4:	30 80 00 
	return 0;
}
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	53                   	push   %ebx
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f0d:	53                   	push   %ebx
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 f1 ec ff ff       	call   800c06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f15:	89 1c 24             	mov    %ebx,(%esp)
  801f18:	e8 ff f2 ff ff       	call   80121c <fd2data>
  801f1d:	83 c4 08             	add    $0x8,%esp
  801f20:	50                   	push   %eax
  801f21:	6a 00                	push   $0x0
  801f23:	e8 de ec ff ff       	call   800c06 <sys_page_unmap>
}
  801f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	57                   	push   %edi
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	83 ec 1c             	sub    $0x1c,%esp
  801f36:	89 c6                	mov    %eax,%esi
  801f38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f3b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f40:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	56                   	push   %esi
  801f47:	e8 1c 05 00 00       	call   802468 <pageref>
  801f4c:	89 c7                	mov    %eax,%edi
  801f4e:	83 c4 04             	add    $0x4,%esp
  801f51:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f54:	e8 0f 05 00 00       	call   802468 <pageref>
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	39 c7                	cmp    %eax,%edi
  801f5e:	0f 94 c2             	sete   %dl
  801f61:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801f64:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801f6a:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f6d:	39 fb                	cmp    %edi,%ebx
  801f6f:	74 19                	je     801f8a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801f71:	84 d2                	test   %dl,%dl
  801f73:	74 c6                	je     801f3b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f75:	8b 51 58             	mov    0x58(%ecx),%edx
  801f78:	50                   	push   %eax
  801f79:	52                   	push   %edx
  801f7a:	53                   	push   %ebx
  801f7b:	68 b3 2d 80 00       	push   $0x802db3
  801f80:	e8 6c e2 ff ff       	call   8001f1 <cprintf>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	eb b1                	jmp    801f3b <_pipeisclosed+0xe>
	}
}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	57                   	push   %edi
  801f96:	56                   	push   %esi
  801f97:	53                   	push   %ebx
  801f98:	83 ec 28             	sub    $0x28,%esp
  801f9b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f9e:	56                   	push   %esi
  801f9f:	e8 78 f2 ff ff       	call   80121c <fd2data>
  801fa4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	bf 00 00 00 00       	mov    $0x0,%edi
  801fae:	eb 4b                	jmp    801ffb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fb0:	89 da                	mov    %ebx,%edx
  801fb2:	89 f0                	mov    %esi,%eax
  801fb4:	e8 74 ff ff ff       	call   801f2d <_pipeisclosed>
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	75 48                	jne    802005 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fbd:	e8 a0 eb ff ff       	call   800b62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fc2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fc5:	8b 0b                	mov    (%ebx),%ecx
  801fc7:	8d 51 20             	lea    0x20(%ecx),%edx
  801fca:	39 d0                	cmp    %edx,%eax
  801fcc:	73 e2                	jae    801fb0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fd1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fd5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fd8:	89 c2                	mov    %eax,%edx
  801fda:	c1 fa 1f             	sar    $0x1f,%edx
  801fdd:	89 d1                	mov    %edx,%ecx
  801fdf:	c1 e9 1b             	shr    $0x1b,%ecx
  801fe2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fe5:	83 e2 1f             	and    $0x1f,%edx
  801fe8:	29 ca                	sub    %ecx,%edx
  801fea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ff2:	83 c0 01             	add    $0x1,%eax
  801ff5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff8:	83 c7 01             	add    $0x1,%edi
  801ffb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ffe:	75 c2                	jne    801fc2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802000:	8b 45 10             	mov    0x10(%ebp),%eax
  802003:	eb 05                	jmp    80200a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802005:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80200a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    

00802012 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 18             	sub    $0x18,%esp
  80201b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80201e:	57                   	push   %edi
  80201f:	e8 f8 f1 ff ff       	call   80121c <fd2data>
  802024:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	bb 00 00 00 00       	mov    $0x0,%ebx
  80202e:	eb 3d                	jmp    80206d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802030:	85 db                	test   %ebx,%ebx
  802032:	74 04                	je     802038 <devpipe_read+0x26>
				return i;
  802034:	89 d8                	mov    %ebx,%eax
  802036:	eb 44                	jmp    80207c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802038:	89 f2                	mov    %esi,%edx
  80203a:	89 f8                	mov    %edi,%eax
  80203c:	e8 ec fe ff ff       	call   801f2d <_pipeisclosed>
  802041:	85 c0                	test   %eax,%eax
  802043:	75 32                	jne    802077 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802045:	e8 18 eb ff ff       	call   800b62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80204a:	8b 06                	mov    (%esi),%eax
  80204c:	3b 46 04             	cmp    0x4(%esi),%eax
  80204f:	74 df                	je     802030 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802051:	99                   	cltd   
  802052:	c1 ea 1b             	shr    $0x1b,%edx
  802055:	01 d0                	add    %edx,%eax
  802057:	83 e0 1f             	and    $0x1f,%eax
  80205a:	29 d0                	sub    %edx,%eax
  80205c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802064:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802067:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206a:	83 c3 01             	add    $0x1,%ebx
  80206d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802070:	75 d8                	jne    80204a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802072:	8b 45 10             	mov    0x10(%ebp),%eax
  802075:	eb 05                	jmp    80207c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80207c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80208c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208f:	50                   	push   %eax
  802090:	e8 9e f1 ff ff       	call   801233 <fd_alloc>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	89 c2                	mov    %eax,%edx
  80209a:	85 c0                	test   %eax,%eax
  80209c:	0f 88 2c 01 00 00    	js     8021ce <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a2:	83 ec 04             	sub    $0x4,%esp
  8020a5:	68 07 04 00 00       	push   $0x407
  8020aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 cd ea ff ff       	call   800b81 <sys_page_alloc>
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	89 c2                	mov    %eax,%edx
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	0f 88 0d 01 00 00    	js     8021ce <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020c1:	83 ec 0c             	sub    $0xc,%esp
  8020c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020c7:	50                   	push   %eax
  8020c8:	e8 66 f1 ff ff       	call   801233 <fd_alloc>
  8020cd:	89 c3                	mov    %eax,%ebx
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	0f 88 e2 00 00 00    	js     8021bc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020da:	83 ec 04             	sub    $0x4,%esp
  8020dd:	68 07 04 00 00       	push   $0x407
  8020e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e5:	6a 00                	push   $0x0
  8020e7:	e8 95 ea ff ff       	call   800b81 <sys_page_alloc>
  8020ec:	89 c3                	mov    %eax,%ebx
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	0f 88 c3 00 00 00    	js     8021bc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020f9:	83 ec 0c             	sub    $0xc,%esp
  8020fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ff:	e8 18 f1 ff ff       	call   80121c <fd2data>
  802104:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802106:	83 c4 0c             	add    $0xc,%esp
  802109:	68 07 04 00 00       	push   $0x407
  80210e:	50                   	push   %eax
  80210f:	6a 00                	push   $0x0
  802111:	e8 6b ea ff ff       	call   800b81 <sys_page_alloc>
  802116:	89 c3                	mov    %eax,%ebx
  802118:	83 c4 10             	add    $0x10,%esp
  80211b:	85 c0                	test   %eax,%eax
  80211d:	0f 88 89 00 00 00    	js     8021ac <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802123:	83 ec 0c             	sub    $0xc,%esp
  802126:	ff 75 f0             	pushl  -0x10(%ebp)
  802129:	e8 ee f0 ff ff       	call   80121c <fd2data>
  80212e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802135:	50                   	push   %eax
  802136:	6a 00                	push   $0x0
  802138:	56                   	push   %esi
  802139:	6a 00                	push   $0x0
  80213b:	e8 84 ea ff ff       	call   800bc4 <sys_page_map>
  802140:	89 c3                	mov    %eax,%ebx
  802142:	83 c4 20             	add    $0x20,%esp
  802145:	85 c0                	test   %eax,%eax
  802147:	78 55                	js     80219e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802149:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80214f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802152:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802154:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802157:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80215e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802167:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802169:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80216c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802173:	83 ec 0c             	sub    $0xc,%esp
  802176:	ff 75 f4             	pushl  -0xc(%ebp)
  802179:	e8 8e f0 ff ff       	call   80120c <fd2num>
  80217e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802181:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802183:	83 c4 04             	add    $0x4,%esp
  802186:	ff 75 f0             	pushl  -0x10(%ebp)
  802189:	e8 7e f0 ff ff       	call   80120c <fd2num>
  80218e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802191:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	ba 00 00 00 00       	mov    $0x0,%edx
  80219c:	eb 30                	jmp    8021ce <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80219e:	83 ec 08             	sub    $0x8,%esp
  8021a1:	56                   	push   %esi
  8021a2:	6a 00                	push   $0x0
  8021a4:	e8 5d ea ff ff       	call   800c06 <sys_page_unmap>
  8021a9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021ac:	83 ec 08             	sub    $0x8,%esp
  8021af:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b2:	6a 00                	push   $0x0
  8021b4:	e8 4d ea ff ff       	call   800c06 <sys_page_unmap>
  8021b9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021bc:	83 ec 08             	sub    $0x8,%esp
  8021bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 3d ea ff ff       	call   800c06 <sys_page_unmap>
  8021c9:	83 c4 10             	add    $0x10,%esp
  8021cc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021ce:	89 d0                	mov    %edx,%eax
  8021d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    

008021d7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e0:	50                   	push   %eax
  8021e1:	ff 75 08             	pushl  0x8(%ebp)
  8021e4:	e8 99 f0 ff ff       	call   801282 <fd_lookup>
  8021e9:	89 c2                	mov    %eax,%edx
  8021eb:	83 c4 10             	add    $0x10,%esp
  8021ee:	85 d2                	test   %edx,%edx
  8021f0:	78 18                	js     80220a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021f2:	83 ec 0c             	sub    $0xc,%esp
  8021f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f8:	e8 1f f0 ff ff       	call   80121c <fd2data>
	return _pipeisclosed(fd, p);
  8021fd:	89 c2                	mov    %eax,%edx
  8021ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802202:	e8 26 fd ff ff       	call   801f2d <_pipeisclosed>
  802207:	83 c4 10             	add    $0x10,%esp
}
  80220a:	c9                   	leave  
  80220b:	c3                   	ret    

0080220c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80221c:	68 cb 2d 80 00       	push   $0x802dcb
  802221:	ff 75 0c             	pushl  0xc(%ebp)
  802224:	e8 4f e5 ff ff       	call   800778 <strcpy>
	return 0;
}
  802229:	b8 00 00 00 00       	mov    $0x0,%eax
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	57                   	push   %edi
  802234:	56                   	push   %esi
  802235:	53                   	push   %ebx
  802236:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80223c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802241:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802247:	eb 2d                	jmp    802276 <devcons_write+0x46>
		m = n - tot;
  802249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80224c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80224e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802251:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802256:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802259:	83 ec 04             	sub    $0x4,%esp
  80225c:	53                   	push   %ebx
  80225d:	03 45 0c             	add    0xc(%ebp),%eax
  802260:	50                   	push   %eax
  802261:	57                   	push   %edi
  802262:	e8 a3 e6 ff ff       	call   80090a <memmove>
		sys_cputs(buf, m);
  802267:	83 c4 08             	add    $0x8,%esp
  80226a:	53                   	push   %ebx
  80226b:	57                   	push   %edi
  80226c:	e8 54 e8 ff ff       	call   800ac5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802271:	01 de                	add    %ebx,%esi
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	89 f0                	mov    %esi,%eax
  802278:	3b 75 10             	cmp    0x10(%ebp),%esi
  80227b:	72 cc                	jb     802249 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80227d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80228b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802290:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802294:	75 07                	jne    80229d <devcons_read+0x18>
  802296:	eb 28                	jmp    8022c0 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802298:	e8 c5 e8 ff ff       	call   800b62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80229d:	e8 41 e8 ff ff       	call   800ae3 <sys_cgetc>
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	74 f2                	je     802298 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	78 16                	js     8022c0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022aa:	83 f8 04             	cmp    $0x4,%eax
  8022ad:	74 0c                	je     8022bb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022b2:	88 02                	mov    %al,(%edx)
	return 1;
  8022b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b9:	eb 05                	jmp    8022c0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022c0:	c9                   	leave  
  8022c1:	c3                   	ret    

008022c2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022ce:	6a 01                	push   $0x1
  8022d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d3:	50                   	push   %eax
  8022d4:	e8 ec e7 ff ff       	call   800ac5 <sys_cputs>
  8022d9:	83 c4 10             	add    $0x10,%esp
}
  8022dc:	c9                   	leave  
  8022dd:	c3                   	ret    

008022de <getchar>:

int
getchar(void)
{
  8022de:	55                   	push   %ebp
  8022df:	89 e5                	mov    %esp,%ebp
  8022e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022e4:	6a 01                	push   $0x1
  8022e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022e9:	50                   	push   %eax
  8022ea:	6a 00                	push   $0x0
  8022ec:	e8 00 f2 ff ff       	call   8014f1 <read>
	if (r < 0)
  8022f1:	83 c4 10             	add    $0x10,%esp
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	78 0f                	js     802307 <getchar+0x29>
		return r;
	if (r < 1)
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	7e 06                	jle    802302 <getchar+0x24>
		return -E_EOF;
	return c;
  8022fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802300:	eb 05                	jmp    802307 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802302:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802307:	c9                   	leave  
  802308:	c3                   	ret    

00802309 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80230f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802312:	50                   	push   %eax
  802313:	ff 75 08             	pushl  0x8(%ebp)
  802316:	e8 67 ef ff ff       	call   801282 <fd_lookup>
  80231b:	83 c4 10             	add    $0x10,%esp
  80231e:	85 c0                	test   %eax,%eax
  802320:	78 11                	js     802333 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802325:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80232b:	39 10                	cmp    %edx,(%eax)
  80232d:	0f 94 c0             	sete   %al
  802330:	0f b6 c0             	movzbl %al,%eax
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    

00802335 <opencons>:

int
opencons(void)
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80233b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80233e:	50                   	push   %eax
  80233f:	e8 ef ee ff ff       	call   801233 <fd_alloc>
  802344:	83 c4 10             	add    $0x10,%esp
		return r;
  802347:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 3e                	js     80238b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80234d:	83 ec 04             	sub    $0x4,%esp
  802350:	68 07 04 00 00       	push   $0x407
  802355:	ff 75 f4             	pushl  -0xc(%ebp)
  802358:	6a 00                	push   $0x0
  80235a:	e8 22 e8 ff ff       	call   800b81 <sys_page_alloc>
  80235f:	83 c4 10             	add    $0x10,%esp
		return r;
  802362:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802364:	85 c0                	test   %eax,%eax
  802366:	78 23                	js     80238b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802368:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80236e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802371:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802376:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80237d:	83 ec 0c             	sub    $0xc,%esp
  802380:	50                   	push   %eax
  802381:	e8 86 ee ff ff       	call   80120c <fd2num>
  802386:	89 c2                	mov    %eax,%edx
  802388:	83 c4 10             	add    $0x10,%esp
}
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802394:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802397:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80239d:	e8 a1 e7 ff ff       	call   800b43 <sys_getenvid>
  8023a2:	83 ec 0c             	sub    $0xc,%esp
  8023a5:	ff 75 0c             	pushl  0xc(%ebp)
  8023a8:	ff 75 08             	pushl  0x8(%ebp)
  8023ab:	56                   	push   %esi
  8023ac:	50                   	push   %eax
  8023ad:	68 d8 2d 80 00       	push   $0x802dd8
  8023b2:	e8 3a de ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023b7:	83 c4 18             	add    $0x18,%esp
  8023ba:	53                   	push   %ebx
  8023bb:	ff 75 10             	pushl  0x10(%ebp)
  8023be:	e8 dd dd ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  8023c3:	c7 04 24 59 2c 80 00 	movl   $0x802c59,(%esp)
  8023ca:	e8 22 de ff ff       	call   8001f1 <cprintf>
  8023cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023d2:	cc                   	int3   
  8023d3:	eb fd                	jmp    8023d2 <_panic+0x43>

008023d5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023db:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023e2:	75 2c                	jne    802410 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8023e4:	83 ec 04             	sub    $0x4,%esp
  8023e7:	6a 07                	push   $0x7
  8023e9:	68 00 f0 bf ee       	push   $0xeebff000
  8023ee:	6a 00                	push   $0x0
  8023f0:	e8 8c e7 ff ff       	call   800b81 <sys_page_alloc>
  8023f5:	83 c4 10             	add    $0x10,%esp
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	74 14                	je     802410 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8023fc:	83 ec 04             	sub    $0x4,%esp
  8023ff:	68 fc 2d 80 00       	push   $0x802dfc
  802404:	6a 21                	push   $0x21
  802406:	68 60 2e 80 00       	push   $0x802e60
  80240b:	e8 7f ff ff ff       	call   80238f <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802410:	8b 45 08             	mov    0x8(%ebp),%eax
  802413:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802418:	83 ec 08             	sub    $0x8,%esp
  80241b:	68 44 24 80 00       	push   $0x802444
  802420:	6a 00                	push   $0x0
  802422:	e8 a5 e8 ff ff       	call   800ccc <sys_env_set_pgfault_upcall>
  802427:	83 c4 10             	add    $0x10,%esp
  80242a:	85 c0                	test   %eax,%eax
  80242c:	79 14                	jns    802442 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80242e:	83 ec 04             	sub    $0x4,%esp
  802431:	68 28 2e 80 00       	push   $0x802e28
  802436:	6a 29                	push   $0x29
  802438:	68 60 2e 80 00       	push   $0x802e60
  80243d:	e8 4d ff ff ff       	call   80238f <_panic>
}
  802442:	c9                   	leave  
  802443:	c3                   	ret    

00802444 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802444:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802445:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80244a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80244c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80244f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802454:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802458:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80245c:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80245e:	83 c4 08             	add    $0x8,%esp
        popal
  802461:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802462:	83 c4 04             	add    $0x4,%esp
        popfl
  802465:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802466:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802467:	c3                   	ret    

00802468 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246e:	89 d0                	mov    %edx,%eax
  802470:	c1 e8 16             	shr    $0x16,%eax
  802473:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80247a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80247f:	f6 c1 01             	test   $0x1,%cl
  802482:	74 1d                	je     8024a1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802484:	c1 ea 0c             	shr    $0xc,%edx
  802487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80248e:	f6 c2 01             	test   $0x1,%dl
  802491:	74 0e                	je     8024a1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802493:	c1 ea 0c             	shr    $0xc,%edx
  802496:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80249d:	ef 
  80249e:	0f b7 c0             	movzwl %ax,%eax
}
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    
  8024a3:	66 90                	xchg   %ax,%ax
  8024a5:	66 90                	xchg   %ax,%ax
  8024a7:	66 90                	xchg   %ax,%ax
  8024a9:	66 90                	xchg   %ax,%ax
  8024ab:	66 90                	xchg   %ax,%ax
  8024ad:	66 90                	xchg   %ax,%ax
  8024af:	90                   	nop

008024b0 <__udivdi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	83 ec 10             	sub    $0x10,%esp
  8024b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8024ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8024be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8024c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024c6:	85 d2                	test   %edx,%edx
  8024c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024cc:	89 34 24             	mov    %esi,(%esp)
  8024cf:	89 c8                	mov    %ecx,%eax
  8024d1:	75 35                	jne    802508 <__udivdi3+0x58>
  8024d3:	39 f1                	cmp    %esi,%ecx
  8024d5:	0f 87 bd 00 00 00    	ja     802598 <__udivdi3+0xe8>
  8024db:	85 c9                	test   %ecx,%ecx
  8024dd:	89 cd                	mov    %ecx,%ebp
  8024df:	75 0b                	jne    8024ec <__udivdi3+0x3c>
  8024e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e6:	31 d2                	xor    %edx,%edx
  8024e8:	f7 f1                	div    %ecx
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	89 f0                	mov    %esi,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	f7 f5                	div    %ebp
  8024f2:	89 c6                	mov    %eax,%esi
  8024f4:	89 f8                	mov    %edi,%eax
  8024f6:	f7 f5                	div    %ebp
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	83 c4 10             	add    $0x10,%esp
  8024fd:	5e                   	pop    %esi
  8024fe:	5f                   	pop    %edi
  8024ff:	5d                   	pop    %ebp
  802500:	c3                   	ret    
  802501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802508:	3b 14 24             	cmp    (%esp),%edx
  80250b:	77 7b                	ja     802588 <__udivdi3+0xd8>
  80250d:	0f bd f2             	bsr    %edx,%esi
  802510:	83 f6 1f             	xor    $0x1f,%esi
  802513:	0f 84 97 00 00 00    	je     8025b0 <__udivdi3+0x100>
  802519:	bd 20 00 00 00       	mov    $0x20,%ebp
  80251e:	89 d7                	mov    %edx,%edi
  802520:	89 f1                	mov    %esi,%ecx
  802522:	29 f5                	sub    %esi,%ebp
  802524:	d3 e7                	shl    %cl,%edi
  802526:	89 c2                	mov    %eax,%edx
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	d3 ea                	shr    %cl,%edx
  80252c:	89 f1                	mov    %esi,%ecx
  80252e:	09 fa                	or     %edi,%edx
  802530:	8b 3c 24             	mov    (%esp),%edi
  802533:	d3 e0                	shl    %cl,%eax
  802535:	89 54 24 08          	mov    %edx,0x8(%esp)
  802539:	89 e9                	mov    %ebp,%ecx
  80253b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80253f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802543:	89 fa                	mov    %edi,%edx
  802545:	d3 ea                	shr    %cl,%edx
  802547:	89 f1                	mov    %esi,%ecx
  802549:	d3 e7                	shl    %cl,%edi
  80254b:	89 e9                	mov    %ebp,%ecx
  80254d:	d3 e8                	shr    %cl,%eax
  80254f:	09 c7                	or     %eax,%edi
  802551:	89 f8                	mov    %edi,%eax
  802553:	f7 74 24 08          	divl   0x8(%esp)
  802557:	89 d5                	mov    %edx,%ebp
  802559:	89 c7                	mov    %eax,%edi
  80255b:	f7 64 24 0c          	mull   0xc(%esp)
  80255f:	39 d5                	cmp    %edx,%ebp
  802561:	89 14 24             	mov    %edx,(%esp)
  802564:	72 11                	jb     802577 <__udivdi3+0xc7>
  802566:	8b 54 24 04          	mov    0x4(%esp),%edx
  80256a:	89 f1                	mov    %esi,%ecx
  80256c:	d3 e2                	shl    %cl,%edx
  80256e:	39 c2                	cmp    %eax,%edx
  802570:	73 5e                	jae    8025d0 <__udivdi3+0x120>
  802572:	3b 2c 24             	cmp    (%esp),%ebp
  802575:	75 59                	jne    8025d0 <__udivdi3+0x120>
  802577:	8d 47 ff             	lea    -0x1(%edi),%eax
  80257a:	31 f6                	xor    %esi,%esi
  80257c:	89 f2                	mov    %esi,%edx
  80257e:	83 c4 10             	add    $0x10,%esp
  802581:	5e                   	pop    %esi
  802582:	5f                   	pop    %edi
  802583:	5d                   	pop    %ebp
  802584:	c3                   	ret    
  802585:	8d 76 00             	lea    0x0(%esi),%esi
  802588:	31 f6                	xor    %esi,%esi
  80258a:	31 c0                	xor    %eax,%eax
  80258c:	89 f2                	mov    %esi,%edx
  80258e:	83 c4 10             	add    $0x10,%esp
  802591:	5e                   	pop    %esi
  802592:	5f                   	pop    %edi
  802593:	5d                   	pop    %ebp
  802594:	c3                   	ret    
  802595:	8d 76 00             	lea    0x0(%esi),%esi
  802598:	89 f2                	mov    %esi,%edx
  80259a:	31 f6                	xor    %esi,%esi
  80259c:	89 f8                	mov    %edi,%eax
  80259e:	f7 f1                	div    %ecx
  8025a0:	89 f2                	mov    %esi,%edx
  8025a2:	83 c4 10             	add    $0x10,%esp
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8025b4:	76 0b                	jbe    8025c1 <__udivdi3+0x111>
  8025b6:	31 c0                	xor    %eax,%eax
  8025b8:	3b 14 24             	cmp    (%esp),%edx
  8025bb:	0f 83 37 ff ff ff    	jae    8024f8 <__udivdi3+0x48>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	e9 2d ff ff ff       	jmp    8024f8 <__udivdi3+0x48>
  8025cb:	90                   	nop
  8025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	89 f8                	mov    %edi,%eax
  8025d2:	31 f6                	xor    %esi,%esi
  8025d4:	e9 1f ff ff ff       	jmp    8024f8 <__udivdi3+0x48>
  8025d9:	66 90                	xchg   %ax,%ax
  8025db:	66 90                	xchg   %ax,%ax
  8025dd:	66 90                	xchg   %ax,%ax
  8025df:	90                   	nop

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	83 ec 20             	sub    $0x20,%esp
  8025e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8025ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f2:	89 c6                	mov    %eax,%esi
  8025f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802600:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802604:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802608:	89 74 24 18          	mov    %esi,0x18(%esp)
  80260c:	85 c0                	test   %eax,%eax
  80260e:	89 c2                	mov    %eax,%edx
  802610:	75 1e                	jne    802630 <__umoddi3+0x50>
  802612:	39 f7                	cmp    %esi,%edi
  802614:	76 52                	jbe    802668 <__umoddi3+0x88>
  802616:	89 c8                	mov    %ecx,%eax
  802618:	89 f2                	mov    %esi,%edx
  80261a:	f7 f7                	div    %edi
  80261c:	89 d0                	mov    %edx,%eax
  80261e:	31 d2                	xor    %edx,%edx
  802620:	83 c4 20             	add    $0x20,%esp
  802623:	5e                   	pop    %esi
  802624:	5f                   	pop    %edi
  802625:	5d                   	pop    %ebp
  802626:	c3                   	ret    
  802627:	89 f6                	mov    %esi,%esi
  802629:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802630:	39 f0                	cmp    %esi,%eax
  802632:	77 5c                	ja     802690 <__umoddi3+0xb0>
  802634:	0f bd e8             	bsr    %eax,%ebp
  802637:	83 f5 1f             	xor    $0x1f,%ebp
  80263a:	75 64                	jne    8026a0 <__umoddi3+0xc0>
  80263c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802640:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802644:	0f 86 f6 00 00 00    	jbe    802740 <__umoddi3+0x160>
  80264a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80264e:	0f 82 ec 00 00 00    	jb     802740 <__umoddi3+0x160>
  802654:	8b 44 24 14          	mov    0x14(%esp),%eax
  802658:	8b 54 24 18          	mov    0x18(%esp),%edx
  80265c:	83 c4 20             	add    $0x20,%esp
  80265f:	5e                   	pop    %esi
  802660:	5f                   	pop    %edi
  802661:	5d                   	pop    %ebp
  802662:	c3                   	ret    
  802663:	90                   	nop
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	85 ff                	test   %edi,%edi
  80266a:	89 fd                	mov    %edi,%ebp
  80266c:	75 0b                	jne    802679 <__umoddi3+0x99>
  80266e:	b8 01 00 00 00       	mov    $0x1,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f7                	div    %edi
  802677:	89 c5                	mov    %eax,%ebp
  802679:	8b 44 24 10          	mov    0x10(%esp),%eax
  80267d:	31 d2                	xor    %edx,%edx
  80267f:	f7 f5                	div    %ebp
  802681:	89 c8                	mov    %ecx,%eax
  802683:	f7 f5                	div    %ebp
  802685:	eb 95                	jmp    80261c <__umoddi3+0x3c>
  802687:	89 f6                	mov    %esi,%esi
  802689:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	83 c4 20             	add    $0x20,%esp
  802697:	5e                   	pop    %esi
  802698:	5f                   	pop    %edi
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    
  80269b:	90                   	nop
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8026a5:	89 e9                	mov    %ebp,%ecx
  8026a7:	29 e8                	sub    %ebp,%eax
  8026a9:	d3 e2                	shl    %cl,%edx
  8026ab:	89 c7                	mov    %eax,%edi
  8026ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8026b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 c1                	mov    %eax,%ecx
  8026bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026bf:	09 d1                	or     %edx,%ecx
  8026c1:	89 fa                	mov    %edi,%edx
  8026c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026c7:	89 e9                	mov    %ebp,%ecx
  8026c9:	d3 e0                	shl    %cl,%eax
  8026cb:	89 f9                	mov    %edi,%ecx
  8026cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026d1:	89 f0                	mov    %esi,%eax
  8026d3:	d3 e8                	shr    %cl,%eax
  8026d5:	89 e9                	mov    %ebp,%ecx
  8026d7:	89 c7                	mov    %eax,%edi
  8026d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026dd:	d3 e6                	shl    %cl,%esi
  8026df:	89 d1                	mov    %edx,%ecx
  8026e1:	89 fa                	mov    %edi,%edx
  8026e3:	d3 e8                	shr    %cl,%eax
  8026e5:	89 e9                	mov    %ebp,%ecx
  8026e7:	09 f0                	or     %esi,%eax
  8026e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8026ed:	f7 74 24 10          	divl   0x10(%esp)
  8026f1:	d3 e6                	shl    %cl,%esi
  8026f3:	89 d1                	mov    %edx,%ecx
  8026f5:	f7 64 24 0c          	mull   0xc(%esp)
  8026f9:	39 d1                	cmp    %edx,%ecx
  8026fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8026ff:	89 d7                	mov    %edx,%edi
  802701:	89 c6                	mov    %eax,%esi
  802703:	72 0a                	jb     80270f <__umoddi3+0x12f>
  802705:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802709:	73 10                	jae    80271b <__umoddi3+0x13b>
  80270b:	39 d1                	cmp    %edx,%ecx
  80270d:	75 0c                	jne    80271b <__umoddi3+0x13b>
  80270f:	89 d7                	mov    %edx,%edi
  802711:	89 c6                	mov    %eax,%esi
  802713:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802717:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80271b:	89 ca                	mov    %ecx,%edx
  80271d:	89 e9                	mov    %ebp,%ecx
  80271f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802723:	29 f0                	sub    %esi,%eax
  802725:	19 fa                	sbb    %edi,%edx
  802727:	d3 e8                	shr    %cl,%eax
  802729:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80272e:	89 d7                	mov    %edx,%edi
  802730:	d3 e7                	shl    %cl,%edi
  802732:	89 e9                	mov    %ebp,%ecx
  802734:	09 f8                	or     %edi,%eax
  802736:	d3 ea                	shr    %cl,%edx
  802738:	83 c4 20             	add    $0x20,%esp
  80273b:	5e                   	pop    %esi
  80273c:	5f                   	pop    %edi
  80273d:	5d                   	pop    %ebp
  80273e:	c3                   	ret    
  80273f:	90                   	nop
  802740:	8b 74 24 10          	mov    0x10(%esp),%esi
  802744:	29 f9                	sub    %edi,%ecx
  802746:	19 c6                	sbb    %eax,%esi
  802748:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80274c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802750:	e9 ff fe ff ff       	jmp    802654 <__umoddi3+0x74>
