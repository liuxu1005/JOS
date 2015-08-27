
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
  80003c:	e8 1b 10 00 00       	call   80105c <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 f0 0a 00 00       	call   800b43 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 40 22 80 00       	push   $0x802240
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d9 0a 00 00       	call   800b43 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 5a 22 80 00       	push   $0x80225a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 58 10 00 00       	call   8010df <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 dc 0f 00 00       	call   801076 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 90 0a 00 00       	call   800b43 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 70 22 80 00       	push   $0x802270
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 f5 0f 00 00       	call   8010df <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80014a:	e8 e9 11 00 00       	call   801338 <close_all>
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
  800254:	e8 37 1d 00 00       	call   801f90 <__udivdi3>
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
  800292:	e8 29 1e 00 00       	call   8020c0 <__umoddi3>
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
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
  800396:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
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
  80045a:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	75 18                	jne    80047d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800465:	50                   	push   %eax
  800466:	68 b8 22 80 00       	push   $0x8022b8
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
  80047e:	68 15 28 80 00       	push   $0x802815
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
  8004ab:	ba b1 22 80 00       	mov    $0x8022b1,%edx
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
  800b2a:	68 df 25 80 00       	push   $0x8025df
  800b2f:	6a 23                	push   $0x23
  800b31:	68 fc 25 80 00       	push   $0x8025fc
  800b36:	e8 3d 13 00 00       	call   801e78 <_panic>

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
  800bab:	68 df 25 80 00       	push   $0x8025df
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 fc 25 80 00       	push   $0x8025fc
  800bb7:	e8 bc 12 00 00       	call   801e78 <_panic>

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
  800bed:	68 df 25 80 00       	push   $0x8025df
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 fc 25 80 00       	push   $0x8025fc
  800bf9:	e8 7a 12 00 00       	call   801e78 <_panic>

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
  800c2f:	68 df 25 80 00       	push   $0x8025df
  800c34:	6a 23                	push   $0x23
  800c36:	68 fc 25 80 00       	push   $0x8025fc
  800c3b:	e8 38 12 00 00       	call   801e78 <_panic>

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
  800c71:	68 df 25 80 00       	push   $0x8025df
  800c76:	6a 23                	push   $0x23
  800c78:	68 fc 25 80 00       	push   $0x8025fc
  800c7d:	e8 f6 11 00 00       	call   801e78 <_panic>
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
  800cb3:	68 df 25 80 00       	push   $0x8025df
  800cb8:	6a 23                	push   $0x23
  800cba:	68 fc 25 80 00       	push   $0x8025fc
  800cbf:	e8 b4 11 00 00       	call   801e78 <_panic>

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
  800cf5:	68 df 25 80 00       	push   $0x8025df
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 fc 25 80 00       	push   $0x8025fc
  800d01:	e8 72 11 00 00       	call   801e78 <_panic>

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
  800d59:	68 df 25 80 00       	push   $0x8025df
  800d5e:	6a 23                	push   $0x23
  800d60:	68 fc 25 80 00       	push   $0x8025fc
  800d65:	e8 0e 11 00 00       	call   801e78 <_panic>

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

00800d72 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d7c:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d7e:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d82:	74 2e                	je     800db2 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	c1 ea 16             	shr    $0x16,%edx
  800d89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d90:	f6 c2 01             	test   $0x1,%dl
  800d93:	74 1d                	je     800db2 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	c1 ea 0c             	shr    $0xc,%edx
  800d9a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800da1:	f6 c1 01             	test   $0x1,%cl
  800da4:	74 0c                	je     800db2 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800da6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800dad:	f6 c6 08             	test   $0x8,%dh
  800db0:	75 14                	jne    800dc6 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	68 0c 26 80 00       	push   $0x80260c
  800dba:	6a 21                	push   $0x21
  800dbc:	68 9f 26 80 00       	push   $0x80269f
  800dc1:	e8 b2 10 00 00       	call   801e78 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800dc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcb:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	6a 07                	push   $0x7
  800dd2:	68 00 f0 7f 00       	push   $0x7ff000
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 a3 fd ff ff       	call   800b81 <sys_page_alloc>
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	79 14                	jns    800df9 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 aa 26 80 00       	push   $0x8026aa
  800ded:	6a 2b                	push   $0x2b
  800def:	68 9f 26 80 00       	push   $0x80269f
  800df4:	e8 7f 10 00 00       	call   801e78 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	68 00 10 00 00       	push   $0x1000
  800e01:	53                   	push   %ebx
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	e8 fe fa ff ff       	call   80090a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e0c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e13:	53                   	push   %ebx
  800e14:	6a 00                	push   $0x0
  800e16:	68 00 f0 7f 00       	push   $0x7ff000
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 a2 fd ff ff       	call   800bc4 <sys_page_map>
  800e22:	83 c4 20             	add    $0x20,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 14                	jns    800e3d <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	68 c0 26 80 00       	push   $0x8026c0
  800e31:	6a 2e                	push   $0x2e
  800e33:	68 9f 26 80 00       	push   $0x80269f
  800e38:	e8 3b 10 00 00       	call   801e78 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	68 00 f0 7f 00       	push   $0x7ff000
  800e45:	6a 00                	push   $0x0
  800e47:	e8 ba fd ff ff       	call   800c06 <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e5d:	68 72 0d 80 00       	push   $0x800d72
  800e62:	e8 57 10 00 00       	call   801ebe <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e67:	b8 07 00 00 00       	mov    $0x7,%eax
  800e6c:	cd 30                	int    $0x30
  800e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	79 12                	jns    800e8a <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e78:	50                   	push   %eax
  800e79:	68 d4 26 80 00       	push   $0x8026d4
  800e7e:	6a 6d                	push   $0x6d
  800e80:	68 9f 26 80 00       	push   $0x80269f
  800e85:	e8 ee 0f 00 00       	call   801e78 <_panic>
  800e8a:	89 c7                	mov    %eax,%edi
  800e8c:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e95:	75 21                	jne    800eb8 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e97:	e8 a7 fc ff ff       	call   800b43 <sys_getenvid>
  800e9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ea1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea9:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb3:	e9 9c 01 00 00       	jmp    801054 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	c1 e8 16             	shr    $0x16,%eax
  800ebd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec4:	a8 01                	test   $0x1,%al
  800ec6:	0f 84 f3 00 00 00    	je     800fbf <fork+0x16b>
  800ecc:	89 d8                	mov    %ebx,%eax
  800ece:	c1 e8 0c             	shr    $0xc,%eax
  800ed1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed8:	f6 c2 01             	test   $0x1,%dl
  800edb:	0f 84 de 00 00 00    	je     800fbf <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800ee1:	89 c6                	mov    %eax,%esi
  800ee3:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800ee6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eed:	f6 c6 04             	test   $0x4,%dh
  800ef0:	74 37                	je     800f29 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800ef2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	25 07 0e 00 00       	and    $0xe07,%eax
  800f01:	50                   	push   %eax
  800f02:	56                   	push   %esi
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	6a 00                	push   $0x0
  800f07:	e8 b8 fc ff ff       	call   800bc4 <sys_page_map>
  800f0c:	83 c4 20             	add    $0x20,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	0f 89 a8 00 00 00    	jns    800fbf <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800f17:	50                   	push   %eax
  800f18:	68 30 26 80 00       	push   $0x802630
  800f1d:	6a 49                	push   $0x49
  800f1f:	68 9f 26 80 00       	push   $0x80269f
  800f24:	e8 4f 0f 00 00       	call   801e78 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f29:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f30:	f6 c6 08             	test   $0x8,%dh
  800f33:	75 0b                	jne    800f40 <fork+0xec>
  800f35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3c:	a8 02                	test   $0x2,%al
  800f3e:	74 57                	je     800f97 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	68 05 08 00 00       	push   $0x805
  800f48:	56                   	push   %esi
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	6a 00                	push   $0x0
  800f4d:	e8 72 fc ff ff       	call   800bc4 <sys_page_map>
  800f52:	83 c4 20             	add    $0x20,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	79 12                	jns    800f6b <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800f59:	50                   	push   %eax
  800f5a:	68 30 26 80 00       	push   $0x802630
  800f5f:	6a 4c                	push   $0x4c
  800f61:	68 9f 26 80 00       	push   $0x80269f
  800f66:	e8 0d 0f 00 00       	call   801e78 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	68 05 08 00 00       	push   $0x805
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	56                   	push   %esi
  800f77:	6a 00                	push   $0x0
  800f79:	e8 46 fc ff ff       	call   800bc4 <sys_page_map>
  800f7e:	83 c4 20             	add    $0x20,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	79 3a                	jns    800fbf <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  800f85:	50                   	push   %eax
  800f86:	68 54 26 80 00       	push   $0x802654
  800f8b:	6a 4e                	push   $0x4e
  800f8d:	68 9f 26 80 00       	push   $0x80269f
  800f92:	e8 e1 0e 00 00       	call   801e78 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	6a 05                	push   $0x5
  800f9c:	56                   	push   %esi
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 1e fc ff ff       	call   800bc4 <sys_page_map>
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	79 12                	jns    800fbf <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  800fad:	50                   	push   %eax
  800fae:	68 7c 26 80 00       	push   $0x80267c
  800fb3:	6a 50                	push   $0x50
  800fb5:	68 9f 26 80 00       	push   $0x80269f
  800fba:	e8 b9 0e 00 00       	call   801e78 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800fbf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fcb:	0f 85 e7 fe ff ff    	jne    800eb8 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800fd1:	83 ec 04             	sub    $0x4,%esp
  800fd4:	6a 07                	push   $0x7
  800fd6:	68 00 f0 bf ee       	push   $0xeebff000
  800fdb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fde:	e8 9e fb ff ff       	call   800b81 <sys_page_alloc>
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	79 14                	jns    800ffe <fork+0x1aa>
                panic("user stack alloc failure\n");	
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 e4 26 80 00       	push   $0x8026e4
  800ff2:	6a 76                	push   $0x76
  800ff4:	68 9f 26 80 00       	push   $0x80269f
  800ff9:	e8 7a 0e 00 00       	call   801e78 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	68 2d 1f 80 00       	push   $0x801f2d
  801006:	ff 75 e4             	pushl  -0x1c(%ebp)
  801009:	e8 be fc ff ff       	call   800ccc <sys_env_set_pgfault_upcall>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	79 14                	jns    801029 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801015:	ff 75 e4             	pushl  -0x1c(%ebp)
  801018:	68 fe 26 80 00       	push   $0x8026fe
  80101d:	6a 79                	push   $0x79
  80101f:	68 9f 26 80 00       	push   $0x80269f
  801024:	e8 4f 0e 00 00       	call   801e78 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	6a 02                	push   $0x2
  80102e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801031:	e8 12 fc ff ff       	call   800c48 <sys_env_set_status>
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	79 14                	jns    801051 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80103d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801040:	68 1b 27 80 00       	push   $0x80271b
  801045:	6a 7b                	push   $0x7b
  801047:	68 9f 26 80 00       	push   $0x80269f
  80104c:	e8 27 0e 00 00       	call   801e78 <_panic>
        return forkid;
  801051:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sfork>:

// Challenge!
int
sfork(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801062:	68 32 27 80 00       	push   $0x802732
  801067:	68 83 00 00 00       	push   $0x83
  80106c:	68 9f 26 80 00       	push   $0x80269f
  801071:	e8 02 0e 00 00       	call   801e78 <_panic>

00801076 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	8b 75 08             	mov    0x8(%ebp),%esi
  80107e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801081:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801084:	85 c0                	test   %eax,%eax
  801086:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80108b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	50                   	push   %eax
  801092:	e8 9a fc ff ff       	call   800d31 <sys_ipc_recv>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 16                	jns    8010b4 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80109e:	85 f6                	test   %esi,%esi
  8010a0:	74 06                	je     8010a8 <ipc_recv+0x32>
  8010a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8010a8:	85 db                	test   %ebx,%ebx
  8010aa:	74 2c                	je     8010d8 <ipc_recv+0x62>
  8010ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b2:	eb 24                	jmp    8010d8 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8010b4:	85 f6                	test   %esi,%esi
  8010b6:	74 0a                	je     8010c2 <ipc_recv+0x4c>
  8010b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010bd:	8b 40 74             	mov    0x74(%eax),%eax
  8010c0:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8010c2:	85 db                	test   %ebx,%ebx
  8010c4:	74 0a                	je     8010d0 <ipc_recv+0x5a>
  8010c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8010cb:	8b 40 78             	mov    0x78(%eax),%eax
  8010ce:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8010d0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8010f1:	85 db                	test   %ebx,%ebx
  8010f3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010f8:	0f 44 d8             	cmove  %eax,%ebx
  8010fb:	eb 1c                	jmp    801119 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8010fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801100:	74 12                	je     801114 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801102:	50                   	push   %eax
  801103:	68 48 27 80 00       	push   $0x802748
  801108:	6a 39                	push   $0x39
  80110a:	68 63 27 80 00       	push   $0x802763
  80110f:	e8 64 0d 00 00       	call   801e78 <_panic>
                 sys_yield();
  801114:	e8 49 fa ff ff       	call   800b62 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801119:	ff 75 14             	pushl  0x14(%ebp)
  80111c:	53                   	push   %ebx
  80111d:	56                   	push   %esi
  80111e:	57                   	push   %edi
  80111f:	e8 ea fb ff ff       	call   800d0e <sys_ipc_try_send>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 d2                	js     8010fd <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80112b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80113e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801141:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801147:	8b 52 50             	mov    0x50(%edx),%edx
  80114a:	39 ca                	cmp    %ecx,%edx
  80114c:	75 0d                	jne    80115b <ipc_find_env+0x28>
			return envs[i].env_id;
  80114e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801151:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801156:	8b 40 08             	mov    0x8(%eax),%eax
  801159:	eb 0e                	jmp    801169 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80115b:	83 c0 01             	add    $0x1,%eax
  80115e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801163:	75 d9                	jne    80113e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801165:	66 b8 00 00          	mov    $0x0,%ax
}
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	05 00 00 00 30       	add    $0x30000000,%eax
  801176:	c1 e8 0c             	shr    $0xc,%eax
}
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801186:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801198:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 16             	shr    $0x16,%edx
  8011a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 11                	je     8011bf <fd_alloc+0x2d>
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 0c             	shr    $0xc,%edx
  8011b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ba:	f6 c2 01             	test   $0x1,%dl
  8011bd:	75 09                	jne    8011c8 <fd_alloc+0x36>
			*fd_store = fd;
  8011bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c6:	eb 17                	jmp    8011df <fd_alloc+0x4d>
  8011c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d2:	75 c9                	jne    80119d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e7:	83 f8 1f             	cmp    $0x1f,%eax
  8011ea:	77 36                	ja     801222 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ec:	c1 e0 0c             	shl    $0xc,%eax
  8011ef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	c1 ea 16             	shr    $0x16,%edx
  8011f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801200:	f6 c2 01             	test   $0x1,%dl
  801203:	74 24                	je     801229 <fd_lookup+0x48>
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 0c             	shr    $0xc,%edx
  80120a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 1a                	je     801230 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801216:	8b 55 0c             	mov    0xc(%ebp),%edx
  801219:	89 02                	mov    %eax,(%edx)
	return 0;
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	eb 13                	jmp    801235 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801222:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801227:	eb 0c                	jmp    801235 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801229:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122e:	eb 05                	jmp    801235 <fd_lookup+0x54>
  801230:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801240:	ba ec 27 80 00       	mov    $0x8027ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801245:	eb 13                	jmp    80125a <dev_lookup+0x23>
  801247:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80124a:	39 08                	cmp    %ecx,(%eax)
  80124c:	75 0c                	jne    80125a <dev_lookup+0x23>
			*dev = devtab[i];
  80124e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801251:	89 01                	mov    %eax,(%ecx)
			return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	eb 2e                	jmp    801288 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125a:	8b 02                	mov    (%edx),%eax
  80125c:	85 c0                	test   %eax,%eax
  80125e:	75 e7                	jne    801247 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801260:	a1 08 40 80 00       	mov    0x804008,%eax
  801265:	8b 40 48             	mov    0x48(%eax),%eax
  801268:	83 ec 04             	sub    $0x4,%esp
  80126b:	51                   	push   %ecx
  80126c:	50                   	push   %eax
  80126d:	68 70 27 80 00       	push   $0x802770
  801272:	e8 7a ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 10             	sub    $0x10,%esp
  801292:	8b 75 08             	mov    0x8(%ebp),%esi
  801295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a2:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a5:	50                   	push   %eax
  8012a6:	e8 36 ff ff ff       	call   8011e1 <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 05                	js     8012b7 <fd_close+0x2d>
	    || fd != fd2)
  8012b2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b5:	74 0c                	je     8012c3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012b7:	84 db                	test   %bl,%bl
  8012b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012be:	0f 44 c2             	cmove  %edx,%eax
  8012c1:	eb 41                	jmp    801304 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	ff 36                	pushl  (%esi)
  8012cc:	e8 66 ff ff ff       	call   801237 <dev_lookup>
  8012d1:	89 c3                	mov    %eax,%ebx
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 1a                	js     8012f4 <fd_close+0x6a>
		if (dev->dev_close)
  8012da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	74 0b                	je     8012f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	56                   	push   %esi
  8012ed:	ff d0                	call   *%eax
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	56                   	push   %esi
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 07 f9 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	89 d8                	mov    %ebx,%eax
}
  801304:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 c4 fe ff ff       	call   8011e1 <fd_lookup>
  80131d:	89 c2                	mov    %eax,%edx
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	85 d2                	test   %edx,%edx
  801324:	78 10                	js     801336 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	6a 01                	push   $0x1
  80132b:	ff 75 f4             	pushl  -0xc(%ebp)
  80132e:	e8 57 ff ff ff       	call   80128a <fd_close>
  801333:	83 c4 10             	add    $0x10,%esp
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <close_all>:

void
close_all(void)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801344:	83 ec 0c             	sub    $0xc,%esp
  801347:	53                   	push   %ebx
  801348:	e8 be ff ff ff       	call   80130b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80134d:	83 c3 01             	add    $0x1,%ebx
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	83 fb 20             	cmp    $0x20,%ebx
  801356:	75 ec                	jne    801344 <close_all+0xc>
		close(i);
}
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	83 ec 2c             	sub    $0x2c,%esp
  801366:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801369:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 6c fe ff ff       	call   8011e1 <fd_lookup>
  801375:	89 c2                	mov    %eax,%edx
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	85 d2                	test   %edx,%edx
  80137c:	0f 88 c1 00 00 00    	js     801443 <dup+0xe6>
		return r;
	close(newfdnum);
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	56                   	push   %esi
  801386:	e8 80 ff ff ff       	call   80130b <close>

	newfd = INDEX2FD(newfdnum);
  80138b:	89 f3                	mov    %esi,%ebx
  80138d:	c1 e3 0c             	shl    $0xc,%ebx
  801390:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801396:	83 c4 04             	add    $0x4,%esp
  801399:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139c:	e8 da fd ff ff       	call   80117b <fd2data>
  8013a1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a3:	89 1c 24             	mov    %ebx,(%esp)
  8013a6:	e8 d0 fd ff ff       	call   80117b <fd2data>
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b1:	89 f8                	mov    %edi,%eax
  8013b3:	c1 e8 16             	shr    $0x16,%eax
  8013b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013bd:	a8 01                	test   $0x1,%al
  8013bf:	74 37                	je     8013f8 <dup+0x9b>
  8013c1:	89 f8                	mov    %edi,%eax
  8013c3:	c1 e8 0c             	shr    $0xc,%eax
  8013c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013cd:	f6 c2 01             	test   $0x1,%dl
  8013d0:	74 26                	je     8013f8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e1:	50                   	push   %eax
  8013e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e5:	6a 00                	push   $0x0
  8013e7:	57                   	push   %edi
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 d5 f7 ff ff       	call   800bc4 <sys_page_map>
  8013ef:	89 c7                	mov    %eax,%edi
  8013f1:	83 c4 20             	add    $0x20,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 2e                	js     801426 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	c1 e8 0c             	shr    $0xc,%eax
  801400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	25 07 0e 00 00       	and    $0xe07,%eax
  80140f:	50                   	push   %eax
  801410:	53                   	push   %ebx
  801411:	6a 00                	push   $0x0
  801413:	52                   	push   %edx
  801414:	6a 00                	push   $0x0
  801416:	e8 a9 f7 ff ff       	call   800bc4 <sys_page_map>
  80141b:	89 c7                	mov    %eax,%edi
  80141d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801420:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801422:	85 ff                	test   %edi,%edi
  801424:	79 1d                	jns    801443 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	53                   	push   %ebx
  80142a:	6a 00                	push   $0x0
  80142c:	e8 d5 f7 ff ff       	call   800c06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	ff 75 d4             	pushl  -0x2c(%ebp)
  801437:	6a 00                	push   $0x0
  801439:	e8 c8 f7 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	89 f8                	mov    %edi,%eax
}
  801443:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 14             	sub    $0x14,%esp
  801452:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801455:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	53                   	push   %ebx
  80145a:	e8 82 fd ff ff       	call   8011e1 <fd_lookup>
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	89 c2                	mov    %eax,%edx
  801464:	85 c0                	test   %eax,%eax
  801466:	78 6d                	js     8014d5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	ff 30                	pushl  (%eax)
  801474:	e8 be fd ff ff       	call   801237 <dev_lookup>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 4c                	js     8014cc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801480:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801483:	8b 42 08             	mov    0x8(%edx),%eax
  801486:	83 e0 03             	and    $0x3,%eax
  801489:	83 f8 01             	cmp    $0x1,%eax
  80148c:	75 21                	jne    8014af <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148e:	a1 08 40 80 00       	mov    0x804008,%eax
  801493:	8b 40 48             	mov    0x48(%eax),%eax
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	53                   	push   %ebx
  80149a:	50                   	push   %eax
  80149b:	68 b1 27 80 00       	push   $0x8027b1
  8014a0:	e8 4c ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ad:	eb 26                	jmp    8014d5 <read+0x8a>
	}
	if (!dev->dev_read)
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	8b 40 08             	mov    0x8(%eax),%eax
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	74 17                	je     8014d0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	ff 75 10             	pushl  0x10(%ebp)
  8014bf:	ff 75 0c             	pushl  0xc(%ebp)
  8014c2:	52                   	push   %edx
  8014c3:	ff d0                	call   *%eax
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	eb 09                	jmp    8014d5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	eb 05                	jmp    8014d5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f0:	eb 21                	jmp    801513 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	29 d8                	sub    %ebx,%eax
  8014f9:	50                   	push   %eax
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	03 45 0c             	add    0xc(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	57                   	push   %edi
  801501:	e8 45 ff ff ff       	call   80144b <read>
		if (m < 0)
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 0c                	js     801519 <readn+0x3d>
			return m;
		if (m == 0)
  80150d:	85 c0                	test   %eax,%eax
  80150f:	74 06                	je     801517 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801511:	01 c3                	add    %eax,%ebx
  801513:	39 f3                	cmp    %esi,%ebx
  801515:	72 db                	jb     8014f2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801517:	89 d8                	mov    %ebx,%eax
}
  801519:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5e                   	pop    %esi
  80151e:	5f                   	pop    %edi
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    

00801521 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 14             	sub    $0x14,%esp
  801528:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	53                   	push   %ebx
  801530:	e8 ac fc ff ff       	call   8011e1 <fd_lookup>
  801535:	83 c4 08             	add    $0x8,%esp
  801538:	89 c2                	mov    %eax,%edx
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 68                	js     8015a6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801548:	ff 30                	pushl  (%eax)
  80154a:	e8 e8 fc ff ff       	call   801237 <dev_lookup>
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 47                	js     80159d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155d:	75 21                	jne    801580 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80155f:	a1 08 40 80 00       	mov    0x804008,%eax
  801564:	8b 40 48             	mov    0x48(%eax),%eax
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	53                   	push   %ebx
  80156b:	50                   	push   %eax
  80156c:	68 cd 27 80 00       	push   $0x8027cd
  801571:	e8 7b ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157e:	eb 26                	jmp    8015a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801580:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801583:	8b 52 0c             	mov    0xc(%edx),%edx
  801586:	85 d2                	test   %edx,%edx
  801588:	74 17                	je     8015a1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158a:	83 ec 04             	sub    $0x4,%esp
  80158d:	ff 75 10             	pushl  0x10(%ebp)
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	50                   	push   %eax
  801594:	ff d2                	call   *%edx
  801596:	89 c2                	mov    %eax,%edx
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	eb 09                	jmp    8015a6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	eb 05                	jmp    8015a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015a6:	89 d0                	mov    %edx,%eax
  8015a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	ff 75 08             	pushl  0x8(%ebp)
  8015ba:	e8 22 fc ff ff       	call   8011e1 <fd_lookup>
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 0e                	js     8015d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 14             	sub    $0x14,%esp
  8015dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	53                   	push   %ebx
  8015e5:	e8 f7 fb ff ff       	call   8011e1 <fd_lookup>
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 65                	js     801658 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fd:	ff 30                	pushl  (%eax)
  8015ff:	e8 33 fc ff ff       	call   801237 <dev_lookup>
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 44                	js     80164f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801612:	75 21                	jne    801635 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801614:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801619:	8b 40 48             	mov    0x48(%eax),%eax
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	53                   	push   %ebx
  801620:	50                   	push   %eax
  801621:	68 90 27 80 00       	push   $0x802790
  801626:	e8 c6 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801633:	eb 23                	jmp    801658 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801635:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801638:	8b 52 18             	mov    0x18(%edx),%edx
  80163b:	85 d2                	test   %edx,%edx
  80163d:	74 14                	je     801653 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	ff d2                	call   *%edx
  801648:	89 c2                	mov    %eax,%edx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	eb 09                	jmp    801658 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164f:	89 c2                	mov    %eax,%edx
  801651:	eb 05                	jmp    801658 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801653:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801658:	89 d0                	mov    %edx,%eax
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	83 ec 14             	sub    $0x14,%esp
  801666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801669:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 6c fb ff ff       	call   8011e1 <fd_lookup>
  801675:	83 c4 08             	add    $0x8,%esp
  801678:	89 c2                	mov    %eax,%edx
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 58                	js     8016d6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801688:	ff 30                	pushl  (%eax)
  80168a:	e8 a8 fb ff ff       	call   801237 <dev_lookup>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 37                	js     8016cd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801699:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80169d:	74 32                	je     8016d1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80169f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016a9:	00 00 00 
	stat->st_isdir = 0;
  8016ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b3:	00 00 00 
	stat->st_dev = dev;
  8016b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	53                   	push   %ebx
  8016c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c3:	ff 50 14             	call   *0x14(%eax)
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	eb 09                	jmp    8016d6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	eb 05                	jmp    8016d6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016d6:	89 d0                	mov    %edx,%eax
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	6a 00                	push   $0x0
  8016e7:	ff 75 08             	pushl  0x8(%ebp)
  8016ea:	e8 09 02 00 00       	call   8018f8 <open>
  8016ef:	89 c3                	mov    %eax,%ebx
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	85 db                	test   %ebx,%ebx
  8016f6:	78 1b                	js     801713 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	53                   	push   %ebx
  8016ff:	e8 5b ff ff ff       	call   80165f <fstat>
  801704:	89 c6                	mov    %eax,%esi
	close(fd);
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 fd fb ff ff       	call   80130b <close>
	return r;
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	89 f0                	mov    %esi,%eax
}
  801713:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	89 c6                	mov    %eax,%esi
  801721:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801723:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80172a:	75 12                	jne    80173e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80172c:	83 ec 0c             	sub    $0xc,%esp
  80172f:	6a 01                	push   $0x1
  801731:	e8 fd f9 ff ff       	call   801133 <ipc_find_env>
  801736:	a3 00 40 80 00       	mov    %eax,0x804000
  80173b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80173e:	6a 07                	push   $0x7
  801740:	68 00 50 80 00       	push   $0x805000
  801745:	56                   	push   %esi
  801746:	ff 35 00 40 80 00    	pushl  0x804000
  80174c:	e8 8e f9 ff ff       	call   8010df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801751:	83 c4 0c             	add    $0xc,%esp
  801754:	6a 00                	push   $0x0
  801756:	53                   	push   %ebx
  801757:	6a 00                	push   $0x0
  801759:	e8 18 f9 ff ff       	call   801076 <ipc_recv>
}
  80175e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801776:	8b 45 0c             	mov    0xc(%ebp),%eax
  801779:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	b8 02 00 00 00       	mov    $0x2,%eax
  801788:	e8 8d ff ff ff       	call   80171a <fsipc>
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	8b 40 0c             	mov    0xc(%eax),%eax
  80179b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8017aa:	e8 6b ff ff ff       	call   80171a <fsipc>
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d0:	e8 45 ff ff ff       	call   80171a <fsipc>
  8017d5:	89 c2                	mov    %eax,%edx
  8017d7:	85 d2                	test   %edx,%edx
  8017d9:	78 2c                	js     801807 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	68 00 50 80 00       	push   $0x805000
  8017e3:	53                   	push   %ebx
  8017e4:	e8 8f ef ff ff       	call   800778 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	57                   	push   %edi
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801823:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801826:	eb 3d                	jmp    801865 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801828:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80182e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801833:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801836:	83 ec 04             	sub    $0x4,%esp
  801839:	57                   	push   %edi
  80183a:	53                   	push   %ebx
  80183b:	68 08 50 80 00       	push   $0x805008
  801840:	e8 c5 f0 ff ff       	call   80090a <memmove>
                fsipcbuf.write.req_n = tmp; 
  801845:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80184b:	ba 00 00 00 00       	mov    $0x0,%edx
  801850:	b8 04 00 00 00       	mov    $0x4,%eax
  801855:	e8 c0 fe ff ff       	call   80171a <fsipc>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 0d                	js     80186e <devfile_write+0x62>
		        return r;
                n -= tmp;
  801861:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801863:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801865:	85 f6                	test   %esi,%esi
  801867:	75 bf                	jne    801828 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801869:	89 d8                	mov    %ebx,%eax
  80186b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80186e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5f                   	pop    %edi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	56                   	push   %esi
  80187a:	53                   	push   %ebx
  80187b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	8b 40 0c             	mov    0xc(%eax),%eax
  801884:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801889:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 03 00 00 00       	mov    $0x3,%eax
  801899:	e8 7c fe ff ff       	call   80171a <fsipc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 4b                	js     8018ef <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a4:	39 c6                	cmp    %eax,%esi
  8018a6:	73 16                	jae    8018be <devfile_read+0x48>
  8018a8:	68 fc 27 80 00       	push   $0x8027fc
  8018ad:	68 03 28 80 00       	push   $0x802803
  8018b2:	6a 7c                	push   $0x7c
  8018b4:	68 18 28 80 00       	push   $0x802818
  8018b9:	e8 ba 05 00 00       	call   801e78 <_panic>
	assert(r <= PGSIZE);
  8018be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c3:	7e 16                	jle    8018db <devfile_read+0x65>
  8018c5:	68 23 28 80 00       	push   $0x802823
  8018ca:	68 03 28 80 00       	push   $0x802803
  8018cf:	6a 7d                	push   $0x7d
  8018d1:	68 18 28 80 00       	push   $0x802818
  8018d6:	e8 9d 05 00 00       	call   801e78 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018db:	83 ec 04             	sub    $0x4,%esp
  8018de:	50                   	push   %eax
  8018df:	68 00 50 80 00       	push   $0x805000
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	e8 1e f0 ff ff       	call   80090a <memmove>
	return r;
  8018ec:	83 c4 10             	add    $0x10,%esp
}
  8018ef:	89 d8                	mov    %ebx,%eax
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 20             	sub    $0x20,%esp
  8018ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801902:	53                   	push   %ebx
  801903:	e8 37 ee ff ff       	call   80073f <strlen>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801910:	7f 67                	jg     801979 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	e8 74 f8 ff ff       	call   801192 <fd_alloc>
  80191e:	83 c4 10             	add    $0x10,%esp
		return r;
  801921:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801923:	85 c0                	test   %eax,%eax
  801925:	78 57                	js     80197e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	53                   	push   %ebx
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	e8 43 ee ff ff       	call   800778 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801940:	b8 01 00 00 00       	mov    $0x1,%eax
  801945:	e8 d0 fd ff ff       	call   80171a <fsipc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	79 14                	jns    801967 <open+0x6f>
		fd_close(fd, 0);
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	6a 00                	push   $0x0
  801958:	ff 75 f4             	pushl  -0xc(%ebp)
  80195b:	e8 2a f9 ff ff       	call   80128a <fd_close>
		return r;
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	89 da                	mov    %ebx,%edx
  801965:	eb 17                	jmp    80197e <open+0x86>
	}

	return fd2num(fd);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 f4             	pushl  -0xc(%ebp)
  80196d:	e8 f9 f7 ff ff       	call   80116b <fd2num>
  801972:	89 c2                	mov    %eax,%edx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb 05                	jmp    80197e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801979:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197e:	89 d0                	mov    %edx,%eax
  801980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198b:	ba 00 00 00 00       	mov    $0x0,%edx
  801990:	b8 08 00 00 00       	mov    $0x8,%eax
  801995:	e8 80 fd ff ff       	call   80171a <fsipc>
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
  8019a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	ff 75 08             	pushl  0x8(%ebp)
  8019aa:	e8 cc f7 ff ff       	call   80117b <fd2data>
  8019af:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019b1:	83 c4 08             	add    $0x8,%esp
  8019b4:	68 2f 28 80 00       	push   $0x80282f
  8019b9:	53                   	push   %ebx
  8019ba:	e8 b9 ed ff ff       	call   800778 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019bf:	8b 56 04             	mov    0x4(%esi),%edx
  8019c2:	89 d0                	mov    %edx,%eax
  8019c4:	2b 06                	sub    (%esi),%eax
  8019c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d3:	00 00 00 
	stat->st_dev = &devpipe;
  8019d6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019dd:	30 80 00 
	return 0;
}
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5d                   	pop    %ebp
  8019eb:	c3                   	ret    

008019ec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019f6:	53                   	push   %ebx
  8019f7:	6a 00                	push   $0x0
  8019f9:	e8 08 f2 ff ff       	call   800c06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019fe:	89 1c 24             	mov    %ebx,(%esp)
  801a01:	e8 75 f7 ff ff       	call   80117b <fd2data>
  801a06:	83 c4 08             	add    $0x8,%esp
  801a09:	50                   	push   %eax
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 f5 f1 ff ff       	call   800c06 <sys_page_unmap>
}
  801a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	57                   	push   %edi
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	83 ec 1c             	sub    $0x1c,%esp
  801a1f:	89 c6                	mov    %eax,%esi
  801a21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a24:	a1 08 40 80 00       	mov    0x804008,%eax
  801a29:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	56                   	push   %esi
  801a30:	e8 1c 05 00 00       	call   801f51 <pageref>
  801a35:	89 c7                	mov    %eax,%edi
  801a37:	83 c4 04             	add    $0x4,%esp
  801a3a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3d:	e8 0f 05 00 00       	call   801f51 <pageref>
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	39 c7                	cmp    %eax,%edi
  801a47:	0f 94 c2             	sete   %dl
  801a4a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a4d:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a53:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a56:	39 fb                	cmp    %edi,%ebx
  801a58:	74 19                	je     801a73 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801a5a:	84 d2                	test   %dl,%dl
  801a5c:	74 c6                	je     801a24 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a5e:	8b 51 58             	mov    0x58(%ecx),%edx
  801a61:	50                   	push   %eax
  801a62:	52                   	push   %edx
  801a63:	53                   	push   %ebx
  801a64:	68 36 28 80 00       	push   $0x802836
  801a69:	e8 83 e7 ff ff       	call   8001f1 <cprintf>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	eb b1                	jmp    801a24 <_pipeisclosed+0xe>
	}
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	57                   	push   %edi
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 28             	sub    $0x28,%esp
  801a84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a87:	56                   	push   %esi
  801a88:	e8 ee f6 ff ff       	call   80117b <fd2data>
  801a8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	bf 00 00 00 00       	mov    $0x0,%edi
  801a97:	eb 4b                	jmp    801ae4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a99:	89 da                	mov    %ebx,%edx
  801a9b:	89 f0                	mov    %esi,%eax
  801a9d:	e8 74 ff ff ff       	call   801a16 <_pipeisclosed>
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	75 48                	jne    801aee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa6:	e8 b7 f0 ff ff       	call   800b62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aab:	8b 43 04             	mov    0x4(%ebx),%eax
  801aae:	8b 0b                	mov    (%ebx),%ecx
  801ab0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab3:	39 d0                	cmp    %edx,%eax
  801ab5:	73 e2                	jae    801a99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801abe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	c1 fa 1f             	sar    $0x1f,%edx
  801ac6:	89 d1                	mov    %edx,%ecx
  801ac8:	c1 e9 1b             	shr    $0x1b,%ecx
  801acb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ace:	83 e2 1f             	and    $0x1f,%edx
  801ad1:	29 ca                	sub    %ecx,%edx
  801ad3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801adb:	83 c0 01             	add    $0x1,%eax
  801ade:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae1:	83 c7 01             	add    $0x1,%edi
  801ae4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae7:	75 c2                	jne    801aab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aec:	eb 05                	jmp    801af3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 18             	sub    $0x18,%esp
  801b04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b07:	57                   	push   %edi
  801b08:	e8 6e f6 ff ff       	call   80117b <fd2data>
  801b0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b17:	eb 3d                	jmp    801b56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b19:	85 db                	test   %ebx,%ebx
  801b1b:	74 04                	je     801b21 <devpipe_read+0x26>
				return i;
  801b1d:	89 d8                	mov    %ebx,%eax
  801b1f:	eb 44                	jmp    801b65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b21:	89 f2                	mov    %esi,%edx
  801b23:	89 f8                	mov    %edi,%eax
  801b25:	e8 ec fe ff ff       	call   801a16 <_pipeisclosed>
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	75 32                	jne    801b60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2e:	e8 2f f0 ff ff       	call   800b62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b33:	8b 06                	mov    (%esi),%eax
  801b35:	3b 46 04             	cmp    0x4(%esi),%eax
  801b38:	74 df                	je     801b19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3a:	99                   	cltd   
  801b3b:	c1 ea 1b             	shr    $0x1b,%edx
  801b3e:	01 d0                	add    %edx,%eax
  801b40:	83 e0 1f             	and    $0x1f,%eax
  801b43:	29 d0                	sub    %edx,%eax
  801b45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b53:	83 c3 01             	add    $0x1,%ebx
  801b56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b59:	75 d8                	jne    801b33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5e:	eb 05                	jmp    801b65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5f                   	pop    %edi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 14 f6 ff ff       	call   801192 <fd_alloc>
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	89 c2                	mov    %eax,%edx
  801b83:	85 c0                	test   %eax,%eax
  801b85:	0f 88 2c 01 00 00    	js     801cb7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8b:	83 ec 04             	sub    $0x4,%esp
  801b8e:	68 07 04 00 00       	push   $0x407
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	6a 00                	push   $0x0
  801b98:	e8 e4 ef ff ff       	call   800b81 <sys_page_alloc>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	89 c2                	mov    %eax,%edx
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	0f 88 0d 01 00 00    	js     801cb7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb0:	50                   	push   %eax
  801bb1:	e8 dc f5 ff ff       	call   801192 <fd_alloc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 88 e2 00 00 00    	js     801ca5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc3:	83 ec 04             	sub    $0x4,%esp
  801bc6:	68 07 04 00 00       	push   $0x407
  801bcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 ac ef ff ff       	call   800b81 <sys_page_alloc>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	0f 88 c3 00 00 00    	js     801ca5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f4             	pushl  -0xc(%ebp)
  801be8:	e8 8e f5 ff ff       	call   80117b <fd2data>
  801bed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 c4 0c             	add    $0xc,%esp
  801bf2:	68 07 04 00 00       	push   $0x407
  801bf7:	50                   	push   %eax
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 82 ef ff ff       	call   800b81 <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 89 00 00 00    	js     801c95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c12:	e8 64 f5 ff ff       	call   80117b <fd2data>
  801c17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1e:	50                   	push   %eax
  801c1f:	6a 00                	push   $0x0
  801c21:	56                   	push   %esi
  801c22:	6a 00                	push   $0x0
  801c24:	e8 9b ef ff ff       	call   800bc4 <sys_page_map>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 20             	add    $0x20,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 55                	js     801c87 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c62:	e8 04 f5 ff ff       	call   80116b <fd2num>
  801c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c6c:	83 c4 04             	add    $0x4,%esp
  801c6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c72:	e8 f4 f4 ff ff       	call   80116b <fd2num>
  801c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	ba 00 00 00 00       	mov    $0x0,%edx
  801c85:	eb 30                	jmp    801cb7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	56                   	push   %esi
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 74 ef ff ff       	call   800c06 <sys_page_unmap>
  801c92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 64 ef ff ff       	call   800c06 <sys_page_unmap>
  801ca2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca5:	83 ec 08             	sub    $0x8,%esp
  801ca8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cab:	6a 00                	push   $0x0
  801cad:	e8 54 ef ff ff       	call   800c06 <sys_page_unmap>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb7:	89 d0                	mov    %edx,%eax
  801cb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbc:	5b                   	pop    %ebx
  801cbd:	5e                   	pop    %esi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc9:	50                   	push   %eax
  801cca:	ff 75 08             	pushl  0x8(%ebp)
  801ccd:	e8 0f f5 ff ff       	call   8011e1 <fd_lookup>
  801cd2:	89 c2                	mov    %eax,%edx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	78 18                	js     801cf3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce1:	e8 95 f4 ff ff       	call   80117b <fd2data>
	return _pipeisclosed(fd, p);
  801ce6:	89 c2                	mov    %eax,%edx
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	e8 26 fd ff ff       	call   801a16 <_pipeisclosed>
  801cf0:	83 c4 10             	add    $0x10,%esp
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d05:	68 4e 28 80 00       	push   $0x80284e
  801d0a:	ff 75 0c             	pushl  0xc(%ebp)
  801d0d:	e8 66 ea ff ff       	call   800778 <strcpy>
	return 0;
}
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	57                   	push   %edi
  801d1d:	56                   	push   %esi
  801d1e:	53                   	push   %ebx
  801d1f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d25:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d2a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d30:	eb 2d                	jmp    801d5f <devcons_write+0x46>
		m = n - tot;
  801d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d35:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d37:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d3a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d3f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d42:	83 ec 04             	sub    $0x4,%esp
  801d45:	53                   	push   %ebx
  801d46:	03 45 0c             	add    0xc(%ebp),%eax
  801d49:	50                   	push   %eax
  801d4a:	57                   	push   %edi
  801d4b:	e8 ba eb ff ff       	call   80090a <memmove>
		sys_cputs(buf, m);
  801d50:	83 c4 08             	add    $0x8,%esp
  801d53:	53                   	push   %ebx
  801d54:	57                   	push   %edi
  801d55:	e8 6b ed ff ff       	call   800ac5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5a:	01 de                	add    %ebx,%esi
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d64:	72 cc                	jb     801d32 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d69:	5b                   	pop    %ebx
  801d6a:	5e                   	pop    %esi
  801d6b:	5f                   	pop    %edi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7d:	75 07                	jne    801d86 <devcons_read+0x18>
  801d7f:	eb 28                	jmp    801da9 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d81:	e8 dc ed ff ff       	call   800b62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d86:	e8 58 ed ff ff       	call   800ae3 <sys_cgetc>
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	74 f2                	je     801d81 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 16                	js     801da9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d93:	83 f8 04             	cmp    $0x4,%eax
  801d96:	74 0c                	je     801da4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9b:	88 02                	mov    %al,(%edx)
	return 1;
  801d9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801da2:	eb 05                	jmp    801da9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db1:	8b 45 08             	mov    0x8(%ebp),%eax
  801db4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db7:	6a 01                	push   $0x1
  801db9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbc:	50                   	push   %eax
  801dbd:	e8 03 ed ff ff       	call   800ac5 <sys_cputs>
  801dc2:	83 c4 10             	add    $0x10,%esp
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <getchar>:

int
getchar(void)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dcd:	6a 01                	push   $0x1
  801dcf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd2:	50                   	push   %eax
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 71 f6 ff ff       	call   80144b <read>
	if (r < 0)
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 0f                	js     801df0 <getchar+0x29>
		return r;
	if (r < 1)
  801de1:	85 c0                	test   %eax,%eax
  801de3:	7e 06                	jle    801deb <getchar+0x24>
		return -E_EOF;
	return c;
  801de5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de9:	eb 05                	jmp    801df0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801deb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	ff 75 08             	pushl  0x8(%ebp)
  801dff:	e8 dd f3 ff ff       	call   8011e1 <fd_lookup>
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 11                	js     801e1c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e14:	39 10                	cmp    %edx,(%eax)
  801e16:	0f 94 c0             	sete   %al
  801e19:	0f b6 c0             	movzbl %al,%eax
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <opencons>:

int
opencons(void)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	e8 65 f3 ff ff       	call   801192 <fd_alloc>
  801e2d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e30:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 3e                	js     801e74 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e36:	83 ec 04             	sub    $0x4,%esp
  801e39:	68 07 04 00 00       	push   $0x407
  801e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e41:	6a 00                	push   $0x0
  801e43:	e8 39 ed ff ff       	call   800b81 <sys_page_alloc>
  801e48:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 23                	js     801e74 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e51:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	50                   	push   %eax
  801e6a:	e8 fc f2 ff ff       	call   80116b <fd2num>
  801e6f:	89 c2                	mov    %eax,%edx
  801e71:	83 c4 10             	add    $0x10,%esp
}
  801e74:	89 d0                	mov    %edx,%eax
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e7d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e80:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e86:	e8 b8 ec ff ff       	call   800b43 <sys_getenvid>
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	ff 75 08             	pushl  0x8(%ebp)
  801e94:	56                   	push   %esi
  801e95:	50                   	push   %eax
  801e96:	68 5c 28 80 00       	push   $0x80285c
  801e9b:	e8 51 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ea0:	83 c4 18             	add    $0x18,%esp
  801ea3:	53                   	push   %ebx
  801ea4:	ff 75 10             	pushl  0x10(%ebp)
  801ea7:	e8 f4 e2 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801eac:	c7 04 24 19 27 80 00 	movl   $0x802719,(%esp)
  801eb3:	e8 39 e3 ff ff       	call   8001f1 <cprintf>
  801eb8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ebb:	cc                   	int3   
  801ebc:	eb fd                	jmp    801ebb <_panic+0x43>

00801ebe <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ec4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ecb:	75 2c                	jne    801ef9 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801ecd:	83 ec 04             	sub    $0x4,%esp
  801ed0:	6a 07                	push   $0x7
  801ed2:	68 00 f0 bf ee       	push   $0xeebff000
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 a3 ec ff ff       	call   800b81 <sys_page_alloc>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	74 14                	je     801ef9 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801ee5:	83 ec 04             	sub    $0x4,%esp
  801ee8:	68 80 28 80 00       	push   $0x802880
  801eed:	6a 21                	push   $0x21
  801eef:	68 e4 28 80 00       	push   $0x8028e4
  801ef4:	e8 7f ff ff ff       	call   801e78 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  801efc:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f01:	83 ec 08             	sub    $0x8,%esp
  801f04:	68 2d 1f 80 00       	push   $0x801f2d
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 bc ed ff ff       	call   800ccc <sys_env_set_pgfault_upcall>
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 14                	jns    801f2b <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	68 ac 28 80 00       	push   $0x8028ac
  801f1f:	6a 29                	push   $0x29
  801f21:	68 e4 28 80 00       	push   $0x8028e4
  801f26:	e8 4d ff ff ff       	call   801e78 <_panic>
}
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f2d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f2e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f33:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f35:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801f38:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801f3d:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801f41:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801f45:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801f47:	83 c4 08             	add    $0x8,%esp
        popal
  801f4a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f4b:	83 c4 04             	add    $0x4,%esp
        popfl
  801f4e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801f4f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f50:	c3                   	ret    

00801f51 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f57:	89 d0                	mov    %edx,%eax
  801f59:	c1 e8 16             	shr    $0x16,%eax
  801f5c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f68:	f6 c1 01             	test   $0x1,%cl
  801f6b:	74 1d                	je     801f8a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6d:	c1 ea 0c             	shr    $0xc,%edx
  801f70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f77:	f6 c2 01             	test   $0x1,%dl
  801f7a:	74 0e                	je     801f8a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7c:	c1 ea 0c             	shr    $0xc,%edx
  801f7f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f86:	ef 
  801f87:	0f b7 c0             	movzwl %ax,%eax
}
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	83 ec 10             	sub    $0x10,%esp
  801f96:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f9a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f9e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801fa2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801fa6:	85 d2                	test   %edx,%edx
  801fa8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fac:	89 34 24             	mov    %esi,(%esp)
  801faf:	89 c8                	mov    %ecx,%eax
  801fb1:	75 35                	jne    801fe8 <__udivdi3+0x58>
  801fb3:	39 f1                	cmp    %esi,%ecx
  801fb5:	0f 87 bd 00 00 00    	ja     802078 <__udivdi3+0xe8>
  801fbb:	85 c9                	test   %ecx,%ecx
  801fbd:	89 cd                	mov    %ecx,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f1                	div    %ecx
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 f0                	mov    %esi,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c6                	mov    %eax,%esi
  801fd4:	89 f8                	mov    %edi,%eax
  801fd6:	f7 f5                	div    %ebp
  801fd8:	89 f2                	mov    %esi,%edx
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    
  801fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	3b 14 24             	cmp    (%esp),%edx
  801feb:	77 7b                	ja     802068 <__udivdi3+0xd8>
  801fed:	0f bd f2             	bsr    %edx,%esi
  801ff0:	83 f6 1f             	xor    $0x1f,%esi
  801ff3:	0f 84 97 00 00 00    	je     802090 <__udivdi3+0x100>
  801ff9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801ffe:	89 d7                	mov    %edx,%edi
  802000:	89 f1                	mov    %esi,%ecx
  802002:	29 f5                	sub    %esi,%ebp
  802004:	d3 e7                	shl    %cl,%edi
  802006:	89 c2                	mov    %eax,%edx
  802008:	89 e9                	mov    %ebp,%ecx
  80200a:	d3 ea                	shr    %cl,%edx
  80200c:	89 f1                	mov    %esi,%ecx
  80200e:	09 fa                	or     %edi,%edx
  802010:	8b 3c 24             	mov    (%esp),%edi
  802013:	d3 e0                	shl    %cl,%eax
  802015:	89 54 24 08          	mov    %edx,0x8(%esp)
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802023:	89 fa                	mov    %edi,%edx
  802025:	d3 ea                	shr    %cl,%edx
  802027:	89 f1                	mov    %esi,%ecx
  802029:	d3 e7                	shl    %cl,%edi
  80202b:	89 e9                	mov    %ebp,%ecx
  80202d:	d3 e8                	shr    %cl,%eax
  80202f:	09 c7                	or     %eax,%edi
  802031:	89 f8                	mov    %edi,%eax
  802033:	f7 74 24 08          	divl   0x8(%esp)
  802037:	89 d5                	mov    %edx,%ebp
  802039:	89 c7                	mov    %eax,%edi
  80203b:	f7 64 24 0c          	mull   0xc(%esp)
  80203f:	39 d5                	cmp    %edx,%ebp
  802041:	89 14 24             	mov    %edx,(%esp)
  802044:	72 11                	jb     802057 <__udivdi3+0xc7>
  802046:	8b 54 24 04          	mov    0x4(%esp),%edx
  80204a:	89 f1                	mov    %esi,%ecx
  80204c:	d3 e2                	shl    %cl,%edx
  80204e:	39 c2                	cmp    %eax,%edx
  802050:	73 5e                	jae    8020b0 <__udivdi3+0x120>
  802052:	3b 2c 24             	cmp    (%esp),%ebp
  802055:	75 59                	jne    8020b0 <__udivdi3+0x120>
  802057:	8d 47 ff             	lea    -0x1(%edi),%eax
  80205a:	31 f6                	xor    %esi,%esi
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
  802068:	31 f6                	xor    %esi,%esi
  80206a:	31 c0                	xor    %eax,%eax
  80206c:	89 f2                	mov    %esi,%edx
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	5e                   	pop    %esi
  802072:	5f                   	pop    %edi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    
  802075:	8d 76 00             	lea    0x0(%esi),%esi
  802078:	89 f2                	mov    %esi,%edx
  80207a:	31 f6                	xor    %esi,%esi
  80207c:	89 f8                	mov    %edi,%eax
  80207e:	f7 f1                	div    %ecx
  802080:	89 f2                	mov    %esi,%edx
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802094:	76 0b                	jbe    8020a1 <__udivdi3+0x111>
  802096:	31 c0                	xor    %eax,%eax
  802098:	3b 14 24             	cmp    (%esp),%edx
  80209b:	0f 83 37 ff ff ff    	jae    801fd8 <__udivdi3+0x48>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	e9 2d ff ff ff       	jmp    801fd8 <__udivdi3+0x48>
  8020ab:	90                   	nop
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f8                	mov    %edi,%eax
  8020b2:	31 f6                	xor    %esi,%esi
  8020b4:	e9 1f ff ff ff       	jmp    801fd8 <__udivdi3+0x48>
  8020b9:	66 90                	xchg   %ax,%ax
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	83 ec 20             	sub    $0x20,%esp
  8020c6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8020ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d2:	89 c6                	mov    %eax,%esi
  8020d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020e8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	89 c2                	mov    %eax,%edx
  8020f0:	75 1e                	jne    802110 <__umoddi3+0x50>
  8020f2:	39 f7                	cmp    %esi,%edi
  8020f4:	76 52                	jbe    802148 <__umoddi3+0x88>
  8020f6:	89 c8                	mov    %ecx,%eax
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	f7 f7                	div    %edi
  8020fc:	89 d0                	mov    %edx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	83 c4 20             	add    $0x20,%esp
  802103:	5e                   	pop    %esi
  802104:	5f                   	pop    %edi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	89 f6                	mov    %esi,%esi
  802109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802110:	39 f0                	cmp    %esi,%eax
  802112:	77 5c                	ja     802170 <__umoddi3+0xb0>
  802114:	0f bd e8             	bsr    %eax,%ebp
  802117:	83 f5 1f             	xor    $0x1f,%ebp
  80211a:	75 64                	jne    802180 <__umoddi3+0xc0>
  80211c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802120:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802124:	0f 86 f6 00 00 00    	jbe    802220 <__umoddi3+0x160>
  80212a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80212e:	0f 82 ec 00 00 00    	jb     802220 <__umoddi3+0x160>
  802134:	8b 44 24 14          	mov    0x14(%esp),%eax
  802138:	8b 54 24 18          	mov    0x18(%esp),%edx
  80213c:	83 c4 20             	add    $0x20,%esp
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    
  802143:	90                   	nop
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	85 ff                	test   %edi,%edi
  80214a:	89 fd                	mov    %edi,%ebp
  80214c:	75 0b                	jne    802159 <__umoddi3+0x99>
  80214e:	b8 01 00 00 00       	mov    $0x1,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f7                	div    %edi
  802157:	89 c5                	mov    %eax,%ebp
  802159:	8b 44 24 10          	mov    0x10(%esp),%eax
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	f7 f5                	div    %ebp
  802161:	89 c8                	mov    %ecx,%eax
  802163:	f7 f5                	div    %ebp
  802165:	eb 95                	jmp    8020fc <__umoddi3+0x3c>
  802167:	89 f6                	mov    %esi,%esi
  802169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 20             	add    $0x20,%esp
  802177:	5e                   	pop    %esi
  802178:	5f                   	pop    %edi
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    
  80217b:	90                   	nop
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	b8 20 00 00 00       	mov    $0x20,%eax
  802185:	89 e9                	mov    %ebp,%ecx
  802187:	29 e8                	sub    %ebp,%eax
  802189:	d3 e2                	shl    %cl,%edx
  80218b:	89 c7                	mov    %eax,%edi
  80218d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802191:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 c1                	mov    %eax,%ecx
  80219b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80219f:	09 d1                	or     %edx,%ecx
  8021a1:	89 fa                	mov    %edi,%edx
  8021a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8021a7:	89 e9                	mov    %ebp,%ecx
  8021a9:	d3 e0                	shl    %cl,%eax
  8021ab:	89 f9                	mov    %edi,%ecx
  8021ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	d3 e8                	shr    %cl,%eax
  8021b5:	89 e9                	mov    %ebp,%ecx
  8021b7:	89 c7                	mov    %eax,%edi
  8021b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021bd:	d3 e6                	shl    %cl,%esi
  8021bf:	89 d1                	mov    %edx,%ecx
  8021c1:	89 fa                	mov    %edi,%edx
  8021c3:	d3 e8                	shr    %cl,%eax
  8021c5:	89 e9                	mov    %ebp,%ecx
  8021c7:	09 f0                	or     %esi,%eax
  8021c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8021cd:	f7 74 24 10          	divl   0x10(%esp)
  8021d1:	d3 e6                	shl    %cl,%esi
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	f7 64 24 0c          	mull   0xc(%esp)
  8021d9:	39 d1                	cmp    %edx,%ecx
  8021db:	89 74 24 14          	mov    %esi,0x14(%esp)
  8021df:	89 d7                	mov    %edx,%edi
  8021e1:	89 c6                	mov    %eax,%esi
  8021e3:	72 0a                	jb     8021ef <__umoddi3+0x12f>
  8021e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021e9:	73 10                	jae    8021fb <__umoddi3+0x13b>
  8021eb:	39 d1                	cmp    %edx,%ecx
  8021ed:	75 0c                	jne    8021fb <__umoddi3+0x13b>
  8021ef:	89 d7                	mov    %edx,%edi
  8021f1:	89 c6                	mov    %eax,%esi
  8021f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021fb:	89 ca                	mov    %ecx,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802203:	29 f0                	sub    %esi,%eax
  802205:	19 fa                	sbb    %edi,%edx
  802207:	d3 e8                	shr    %cl,%eax
  802209:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80220e:	89 d7                	mov    %edx,%edi
  802210:	d3 e7                	shl    %cl,%edi
  802212:	89 e9                	mov    %ebp,%ecx
  802214:	09 f8                	or     %edi,%eax
  802216:	d3 ea                	shr    %cl,%edx
  802218:	83 c4 20             	add    $0x20,%esp
  80221b:	5e                   	pop    %esi
  80221c:	5f                   	pop    %edi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    
  80221f:	90                   	nop
  802220:	8b 74 24 10          	mov    0x10(%esp),%esi
  802224:	29 f9                	sub    %edi,%ecx
  802226:	19 c6                	sbb    %eax,%esi
  802228:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80222c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802230:	e9 ff fe ff ff       	jmp    802134 <__umoddi3+0x74>
