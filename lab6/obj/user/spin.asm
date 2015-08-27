
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 40 27 80 00       	push   $0x802740
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 63 0e 00 00       	call   800eac <fork>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 12                	jne    800064 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800052:	83 ec 0c             	sub    $0xc,%esp
  800055:	68 b8 27 80 00       	push   $0x8027b8
  80005a:	e8 49 01 00 00       	call   8001a8 <cprintf>
  80005f:	83 c4 10             	add    $0x10,%esp
		while (1)
			/* do nothing */;
  800062:	eb fe                	jmp    800062 <umain+0x2f>
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 27 80 00       	push   $0x802768
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 a3 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  800076:	e8 9e 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  80007b:	e8 99 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  800080:	e8 94 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  800085:	e8 8f 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  80008a:	e8 8a 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  80008f:	e8 85 0a 00 00       	call   800b19 <sys_yield>
	sys_yield();
  800094:	e8 80 0a 00 00       	call   800b19 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 0c 0a 00 00       	call   800ab9 <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000c0:	e8 35 0a 00 00       	call   800afa <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
  8000f1:	83 c4 10             	add    $0x10,%esp
}
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 9a 11 00 00       	call   8012a0 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 a9 09 00 00       	call   800ab9 <sys_env_destroy>
  800110:	83 c4 10             	add    $0x10,%esp
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 37 09 00 00       	call   800a7c <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 4f 01 00 00       	call   8002da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 dc 08 00 00       	call   800a7c <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 d1                	mov    %edx,%ecx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e7:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001ea:	72 05                	jb     8001f1 <printnum+0x35>
  8001ec:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001ef:	77 3e                	ja     80022f <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	50                   	push   %eax
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 50 22 00 00       	call   802460 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 42 23 00 00       	call   802590 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 e0 27 80 00 	movsbl 0x8027e0(%eax),%eax
  800258:	50                   	push   %eax
  800259:	ff d7                	call   *%edi
  80025b:	83 c4 10             	add    $0x10,%esp
}
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800269:	83 fa 01             	cmp    $0x1,%edx
  80026c:	7e 0e                	jle    80027c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 08             	lea    0x8(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	8b 52 04             	mov    0x4(%edx),%edx
  80027a:	eb 22                	jmp    80029e <getuint+0x38>
	else if (lflag)
  80027c:	85 d2                	test   %edx,%edx
  80027e:	74 10                	je     800290 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
  80028e:	eb 0e                	jmp    80029e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8002af:	73 0a                	jae    8002bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	88 02                	mov    %al,(%edx)
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c6:	50                   	push   %eax
  8002c7:	ff 75 10             	pushl  0x10(%ebp)
  8002ca:	ff 75 0c             	pushl  0xc(%ebp)
  8002cd:	ff 75 08             	pushl  0x8(%ebp)
  8002d0:	e8 05 00 00 00       	call   8002da <vprintfmt>
	va_end(ap);
  8002d5:	83 c4 10             	add    $0x10,%esp
}
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
  8002e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ec:	eb 12                	jmp    800300 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	0f 84 90 03 00 00    	je     800686 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	53                   	push   %ebx
  8002fa:	50                   	push   %eax
  8002fb:	ff d6                	call   *%esi
  8002fd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800300:	83 c7 01             	add    $0x1,%edi
  800303:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800307:	83 f8 25             	cmp    $0x25,%eax
  80030a:	75 e2                	jne    8002ee <vprintfmt+0x14>
  80030c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800310:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800317:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
  80032a:	eb 07                	jmp    800333 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8d 47 01             	lea    0x1(%edi),%eax
  800336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800339:	0f b6 07             	movzbl (%edi),%eax
  80033c:	0f b6 c8             	movzbl %al,%ecx
  80033f:	83 e8 23             	sub    $0x23,%eax
  800342:	3c 55                	cmp    $0x55,%al
  800344:	0f 87 21 03 00 00    	ja     80066b <vprintfmt+0x391>
  80034a:	0f b6 c0             	movzbl %al,%eax
  80034d:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800357:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035b:	eb d6                	jmp    800333 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800360:	b8 00 00 00 00       	mov    $0x0,%eax
  800365:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800368:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800372:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800375:	83 fa 09             	cmp    $0x9,%edx
  800378:	77 39                	ja     8003b3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037d:	eb e9                	jmp    800368 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 48 04             	lea    0x4(%eax),%ecx
  800385:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800388:	8b 00                	mov    (%eax),%eax
  80038a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800390:	eb 27                	jmp    8003b9 <vprintfmt+0xdf>
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	85 c0                	test   %eax,%eax
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039c:	0f 49 c8             	cmovns %eax,%ecx
  80039f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a5:	eb 8c                	jmp    800333 <vprintfmt+0x59>
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003aa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b1:	eb 80                	jmp    800333 <vprintfmt+0x59>
  8003b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bd:	0f 89 70 ff ff ff    	jns    800333 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d0:	e9 5e ff ff ff       	jmp    800333 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003db:	e9 53 ff ff ff       	jmp    800333 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	53                   	push   %ebx
  8003ed:	ff 30                	pushl  (%eax)
  8003ef:	ff d6                	call   *%esi
			break;
  8003f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f7:	e9 04 ff ff ff       	jmp    800300 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	99                   	cltd   
  800408:	31 d0                	xor    %edx,%eax
  80040a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040c:	83 f8 0f             	cmp    $0xf,%eax
  80040f:	7f 0b                	jg     80041c <vprintfmt+0x142>
  800411:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800418:	85 d2                	test   %edx,%edx
  80041a:	75 18                	jne    800434 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80041c:	50                   	push   %eax
  80041d:	68 f8 27 80 00       	push   $0x8027f8
  800422:	53                   	push   %ebx
  800423:	56                   	push   %esi
  800424:	e8 94 fe ff ff       	call   8002bd <printfmt>
  800429:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042f:	e9 cc fe ff ff       	jmp    800300 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800434:	52                   	push   %edx
  800435:	68 31 2d 80 00       	push   $0x802d31
  80043a:	53                   	push   %ebx
  80043b:	56                   	push   %esi
  80043c:	e8 7c fe ff ff       	call   8002bd <printfmt>
  800441:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	e9 b4 fe ff ff       	jmp    800300 <vprintfmt+0x26>
  80044c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80044f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800452:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800460:	85 ff                	test   %edi,%edi
  800462:	ba f1 27 80 00       	mov    $0x8027f1,%edx
  800467:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80046a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046e:	0f 84 92 00 00 00    	je     800506 <vprintfmt+0x22c>
  800474:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800478:	0f 8e 96 00 00 00    	jle    800514 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	51                   	push   %ecx
  800482:	57                   	push   %edi
  800483:	e8 86 02 00 00       	call   80070e <strnlen>
  800488:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80048b:	29 c1                	sub    %eax,%ecx
  80048d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800493:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800497:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	eb 0f                	jmp    8004b0 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	53                   	push   %ebx
  8004a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	83 ef 01             	sub    $0x1,%edi
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	85 ff                	test   %edi,%edi
  8004b2:	7f ed                	jg     8004a1 <vprintfmt+0x1c7>
  8004b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ba:	85 c9                	test   %ecx,%ecx
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	0f 49 c1             	cmovns %ecx,%eax
  8004c4:	29 c1                	sub    %eax,%ecx
  8004c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cf:	89 cb                	mov    %ecx,%ebx
  8004d1:	eb 4d                	jmp    800520 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d7:	74 1b                	je     8004f4 <vprintfmt+0x21a>
  8004d9:	0f be c0             	movsbl %al,%eax
  8004dc:	83 e8 20             	sub    $0x20,%eax
  8004df:	83 f8 5e             	cmp    $0x5e,%eax
  8004e2:	76 10                	jbe    8004f4 <vprintfmt+0x21a>
					putch('?', putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ea:	6a 3f                	push   $0x3f
  8004ec:	ff 55 08             	call   *0x8(%ebp)
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb 0d                	jmp    800501 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	ff 75 0c             	pushl  0xc(%ebp)
  8004fa:	52                   	push   %edx
  8004fb:	ff 55 08             	call   *0x8(%ebp)
  8004fe:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800501:	83 eb 01             	sub    $0x1,%ebx
  800504:	eb 1a                	jmp    800520 <vprintfmt+0x246>
  800506:	89 75 08             	mov    %esi,0x8(%ebp)
  800509:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800512:	eb 0c                	jmp    800520 <vprintfmt+0x246>
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800520:	83 c7 01             	add    $0x1,%edi
  800523:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800527:	0f be d0             	movsbl %al,%edx
  80052a:	85 d2                	test   %edx,%edx
  80052c:	74 23                	je     800551 <vprintfmt+0x277>
  80052e:	85 f6                	test   %esi,%esi
  800530:	78 a1                	js     8004d3 <vprintfmt+0x1f9>
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	79 9c                	jns    8004d3 <vprintfmt+0x1f9>
  800537:	89 df                	mov    %ebx,%edi
  800539:	8b 75 08             	mov    0x8(%ebp),%esi
  80053c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053f:	eb 18                	jmp    800559 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	6a 20                	push   $0x20
  800547:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800549:	83 ef 01             	sub    $0x1,%edi
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb 08                	jmp    800559 <vprintfmt+0x27f>
  800551:	89 df                	mov    %ebx,%edi
  800553:	8b 75 08             	mov    0x8(%ebp),%esi
  800556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800559:	85 ff                	test   %edi,%edi
  80055b:	7f e4                	jg     800541 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800560:	e9 9b fd ff ff       	jmp    800300 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800565:	83 fa 01             	cmp    $0x1,%edx
  800568:	7e 16                	jle    800580 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 08             	lea    0x8(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 50 04             	mov    0x4(%eax),%edx
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057e:	eb 32                	jmp    8005b2 <vprintfmt+0x2d8>
	else if (lflag)
  800580:	85 d2                	test   %edx,%edx
  800582:	74 18                	je     80059c <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 50 04             	lea    0x4(%eax),%edx
  80058a:	89 55 14             	mov    %edx,0x14(%ebp)
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800592:	89 c1                	mov    %eax,%ecx
  800594:	c1 f9 1f             	sar    $0x1f,%ecx
  800597:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059a:	eb 16                	jmp    8005b2 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 c1                	mov    %eax,%ecx
  8005ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8005af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c1:	79 74                	jns    800637 <vprintfmt+0x35d>
				putch('-', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 2d                	push   $0x2d
  8005c9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d1:	f7 d8                	neg    %eax
  8005d3:	83 d2 00             	adc    $0x0,%edx
  8005d6:	f7 da                	neg    %edx
  8005d8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005db:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e0:	eb 55                	jmp    800637 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 7c fc ff ff       	call   800266 <getuint>
			base = 10;
  8005ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ef:	eb 46                	jmp    800637 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 6d fc ff ff       	call   800266 <getuint>
                        base = 8;
  8005f9:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005fe:	eb 37                	jmp    800637 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	6a 30                	push   $0x30
  800606:	ff d6                	call   *%esi
			putch('x', putdat);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 78                	push   $0x78
  80060e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800620:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800623:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800628:	eb 0d                	jmp    800637 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 34 fc ff ff       	call   800266 <getuint>
			base = 16;
  800632:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800637:	83 ec 0c             	sub    $0xc,%esp
  80063a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063e:	57                   	push   %edi
  80063f:	ff 75 e0             	pushl  -0x20(%ebp)
  800642:	51                   	push   %ecx
  800643:	52                   	push   %edx
  800644:	50                   	push   %eax
  800645:	89 da                	mov    %ebx,%edx
  800647:	89 f0                	mov    %esi,%eax
  800649:	e8 6e fb ff ff       	call   8001bc <printnum>
			break;
  80064e:	83 c4 20             	add    $0x20,%esp
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800654:	e9 a7 fc ff ff       	jmp    800300 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	51                   	push   %ecx
  80065e:	ff d6                	call   *%esi
			break;
  800660:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800666:	e9 95 fc ff ff       	jmp    800300 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 25                	push   $0x25
  800671:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	eb 03                	jmp    80067b <vprintfmt+0x3a1>
  800678:	83 ef 01             	sub    $0x1,%edi
  80067b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067f:	75 f7                	jne    800678 <vprintfmt+0x39e>
  800681:	e9 7a fc ff ff       	jmp    800300 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800686:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800689:	5b                   	pop    %ebx
  80068a:	5e                   	pop    %esi
  80068b:	5f                   	pop    %edi
  80068c:	5d                   	pop    %ebp
  80068d:	c3                   	ret    

0080068e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	83 ec 18             	sub    $0x18,%esp
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	74 26                	je     8006d5 <vsnprintf+0x47>
  8006af:	85 d2                	test   %edx,%edx
  8006b1:	7e 22                	jle    8006d5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b3:	ff 75 14             	pushl  0x14(%ebp)
  8006b6:	ff 75 10             	pushl  0x10(%ebp)
  8006b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	68 a0 02 80 00       	push   $0x8002a0
  8006c2:	e8 13 fc ff ff       	call   8002da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	eb 05                	jmp    8006da <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e5:	50                   	push   %eax
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	ff 75 08             	pushl  0x8(%ebp)
  8006ef:	e8 9a ff ff ff       	call   80068e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	eb 03                	jmp    800706 <strlen+0x10>
		n++;
  800703:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070a:	75 f7                	jne    800703 <strlen+0xd>
		n++;
	return n;
}
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800714:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	ba 00 00 00 00       	mov    $0x0,%edx
  80071c:	eb 03                	jmp    800721 <strnlen+0x13>
		n++;
  80071e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	39 c2                	cmp    %eax,%edx
  800723:	74 08                	je     80072d <strnlen+0x1f>
  800725:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800729:	75 f3                	jne    80071e <strnlen+0x10>
  80072b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800739:	89 c2                	mov    %eax,%edx
  80073b:	83 c2 01             	add    $0x1,%edx
  80073e:	83 c1 01             	add    $0x1,%ecx
  800741:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800745:	88 5a ff             	mov    %bl,-0x1(%edx)
  800748:	84 db                	test   %bl,%bl
  80074a:	75 ef                	jne    80073b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074c:	5b                   	pop    %ebx
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	53                   	push   %ebx
  800757:	e8 9a ff ff ff       	call   8006f6 <strlen>
  80075c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	01 d8                	add    %ebx,%eax
  800764:	50                   	push   %eax
  800765:	e8 c5 ff ff ff       	call   80072f <strcpy>
	return dst;
}
  80076a:	89 d8                	mov    %ebx,%eax
  80076c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	56                   	push   %esi
  800775:	53                   	push   %ebx
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	89 f3                	mov    %esi,%ebx
  80077e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	89 f2                	mov    %esi,%edx
  800783:	eb 0f                	jmp    800794 <strncpy+0x23>
		*dst++ = *src;
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	0f b6 01             	movzbl (%ecx),%eax
  80078b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078e:	80 39 01             	cmpb   $0x1,(%ecx)
  800791:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800794:	39 da                	cmp    %ebx,%edx
  800796:	75 ed                	jne    800785 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800798:	89 f0                	mov    %esi,%eax
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 21                	je     8007d3 <strlcpy+0x35>
  8007b2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b6:	89 f2                	mov    %esi,%edx
  8007b8:	eb 09                	jmp    8007c3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ba:	83 c2 01             	add    $0x1,%edx
  8007bd:	83 c1 01             	add    $0x1,%ecx
  8007c0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c3:	39 c2                	cmp    %eax,%edx
  8007c5:	74 09                	je     8007d0 <strlcpy+0x32>
  8007c7:	0f b6 19             	movzbl (%ecx),%ebx
  8007ca:	84 db                	test   %bl,%bl
  8007cc:	75 ec                	jne    8007ba <strlcpy+0x1c>
  8007ce:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d3:	29 f0                	sub    %esi,%eax
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e2:	eb 06                	jmp    8007ea <strcmp+0x11>
		p++, q++;
  8007e4:	83 c1 01             	add    $0x1,%ecx
  8007e7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	84 c0                	test   %al,%al
  8007ef:	74 04                	je     8007f5 <strcmp+0x1c>
  8007f1:	3a 02                	cmp    (%edx),%al
  8007f3:	74 ef                	je     8007e4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f5:	0f b6 c0             	movzbl %al,%eax
  8007f8:	0f b6 12             	movzbl (%edx),%edx
  8007fb:	29 d0                	sub    %edx,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 c3                	mov    %eax,%ebx
  80080b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080e:	eb 06                	jmp    800816 <strncmp+0x17>
		n--, p++, q++;
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800816:	39 d8                	cmp    %ebx,%eax
  800818:	74 15                	je     80082f <strncmp+0x30>
  80081a:	0f b6 08             	movzbl (%eax),%ecx
  80081d:	84 c9                	test   %cl,%cl
  80081f:	74 04                	je     800825 <strncmp+0x26>
  800821:	3a 0a                	cmp    (%edx),%cl
  800823:	74 eb                	je     800810 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800825:	0f b6 00             	movzbl (%eax),%eax
  800828:	0f b6 12             	movzbl (%edx),%edx
  80082b:	29 d0                	sub    %edx,%eax
  80082d:	eb 05                	jmp    800834 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800841:	eb 07                	jmp    80084a <strchr+0x13>
		if (*s == c)
  800843:	38 ca                	cmp    %cl,%dl
  800845:	74 0f                	je     800856 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
  80084d:	84 d2                	test   %dl,%dl
  80084f:	75 f2                	jne    800843 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800862:	eb 03                	jmp    800867 <strfind+0xf>
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80086a:	84 d2                	test   %dl,%dl
  80086c:	74 04                	je     800872 <strfind+0x1a>
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	75 f2                	jne    800864 <strfind+0xc>
			break;
	return (char *) s;
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800880:	85 c9                	test   %ecx,%ecx
  800882:	74 36                	je     8008ba <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800884:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088a:	75 28                	jne    8008b4 <memset+0x40>
  80088c:	f6 c1 03             	test   $0x3,%cl
  80088f:	75 23                	jne    8008b4 <memset+0x40>
		c &= 0xFF;
  800891:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800895:	89 d3                	mov    %edx,%ebx
  800897:	c1 e3 08             	shl    $0x8,%ebx
  80089a:	89 d6                	mov    %edx,%esi
  80089c:	c1 e6 18             	shl    $0x18,%esi
  80089f:	89 d0                	mov    %edx,%eax
  8008a1:	c1 e0 10             	shl    $0x10,%eax
  8008a4:	09 f0                	or     %esi,%eax
  8008a6:	09 c2                	or     %eax,%edx
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008af:	fc                   	cld    
  8008b0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b2:	eb 06                	jmp    8008ba <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b7:	fc                   	cld    
  8008b8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ba:	89 f8                	mov    %edi,%eax
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5f                   	pop    %edi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cf:	39 c6                	cmp    %eax,%esi
  8008d1:	73 35                	jae    800908 <memmove+0x47>
  8008d3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d6:	39 d0                	cmp    %edx,%eax
  8008d8:	73 2e                	jae    800908 <memmove+0x47>
		s += n;
		d += n;
  8008da:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008dd:	89 d6                	mov    %edx,%esi
  8008df:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e7:	75 13                	jne    8008fc <memmove+0x3b>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 0e                	jne    8008fc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ee:	83 ef 04             	sub    $0x4,%edi
  8008f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f7:	fd                   	std    
  8008f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fa:	eb 09                	jmp    800905 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fc:	83 ef 01             	sub    $0x1,%edi
  8008ff:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800902:	fd                   	std    
  800903:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800905:	fc                   	cld    
  800906:	eb 1d                	jmp    800925 <memmove+0x64>
  800908:	89 f2                	mov    %esi,%edx
  80090a:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090c:	f6 c2 03             	test   $0x3,%dl
  80090f:	75 0f                	jne    800920 <memmove+0x5f>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0a                	jne    800920 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800916:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800919:	89 c7                	mov    %eax,%edi
  80091b:	fc                   	cld    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 05                	jmp    800925 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 87 ff ff ff       	call   8008c1 <memmove>
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
  800947:	89 c6                	mov    %eax,%esi
  800949:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094c:	eb 1a                	jmp    800968 <memcmp+0x2c>
		if (*s1 != *s2)
  80094e:	0f b6 08             	movzbl (%eax),%ecx
  800951:	0f b6 1a             	movzbl (%edx),%ebx
  800954:	38 d9                	cmp    %bl,%cl
  800956:	74 0a                	je     800962 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800958:	0f b6 c1             	movzbl %cl,%eax
  80095b:	0f b6 db             	movzbl %bl,%ebx
  80095e:	29 d8                	sub    %ebx,%eax
  800960:	eb 0f                	jmp    800971 <memcmp+0x35>
		s1++, s2++;
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800968:	39 f0                	cmp    %esi,%eax
  80096a:	75 e2                	jne    80094e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097e:	89 c2                	mov    %eax,%edx
  800980:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800983:	eb 07                	jmp    80098c <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	38 08                	cmp    %cl,(%eax)
  800987:	74 07                	je     800990 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	39 d0                	cmp    %edx,%eax
  80098e:	72 f5                	jb     800985 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099e:	eb 03                	jmp    8009a3 <strtol+0x11>
		s++;
  8009a0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	3c 09                	cmp    $0x9,%al
  8009a8:	74 f6                	je     8009a0 <strtol+0xe>
  8009aa:	3c 20                	cmp    $0x20,%al
  8009ac:	74 f2                	je     8009a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ae:	3c 2b                	cmp    $0x2b,%al
  8009b0:	75 0a                	jne    8009bc <strtol+0x2a>
		s++;
  8009b2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ba:	eb 10                	jmp    8009cc <strtol+0x3a>
  8009bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c1:	3c 2d                	cmp    $0x2d,%al
  8009c3:	75 07                	jne    8009cc <strtol+0x3a>
		s++, neg = 1;
  8009c5:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009c8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cc:	85 db                	test   %ebx,%ebx
  8009ce:	0f 94 c0             	sete   %al
  8009d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d7:	75 19                	jne    8009f2 <strtol+0x60>
  8009d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dc:	75 14                	jne    8009f2 <strtol+0x60>
  8009de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e2:	0f 85 82 00 00 00    	jne    800a6a <strtol+0xd8>
		s += 2, base = 16;
  8009e8:	83 c1 02             	add    $0x2,%ecx
  8009eb:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f0:	eb 16                	jmp    800a08 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009f2:	84 c0                	test   %al,%al
  8009f4:	74 12                	je     800a08 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fb:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fe:	75 08                	jne    800a08 <strtol+0x76>
		s++, base = 8;
  800a00:	83 c1 01             	add    $0x1,%ecx
  800a03:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a10:	0f b6 11             	movzbl (%ecx),%edx
  800a13:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	80 fb 09             	cmp    $0x9,%bl
  800a1b:	77 08                	ja     800a25 <strtol+0x93>
			dig = *s - '0';
  800a1d:	0f be d2             	movsbl %dl,%edx
  800a20:	83 ea 30             	sub    $0x30,%edx
  800a23:	eb 22                	jmp    800a47 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a25:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	80 fb 19             	cmp    $0x19,%bl
  800a2d:	77 08                	ja     800a37 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a2f:	0f be d2             	movsbl %dl,%edx
  800a32:	83 ea 57             	sub    $0x57,%edx
  800a35:	eb 10                	jmp    800a47 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a37:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3a:	89 f3                	mov    %esi,%ebx
  800a3c:	80 fb 19             	cmp    $0x19,%bl
  800a3f:	77 16                	ja     800a57 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a47:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4a:	7d 0f                	jge    800a5b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a53:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a55:	eb b9                	jmp    800a10 <strtol+0x7e>
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	eb 02                	jmp    800a5d <strtol+0xcb>
  800a5b:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a61:	74 0d                	je     800a70 <strtol+0xde>
		*endptr = (char *) s;
  800a63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a66:	89 0e                	mov    %ecx,(%esi)
  800a68:	eb 06                	jmp    800a70 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	84 c0                	test   %al,%al
  800a6c:	75 92                	jne    800a00 <strtol+0x6e>
  800a6e:	eb 98                	jmp    800a08 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a70:	f7 da                	neg    %edx
  800a72:	85 ff                	test   %edi,%edi
  800a74:	0f 45 c2             	cmovne %edx,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	89 c7                	mov    %eax,%edi
  800a91:	89 c6                	mov    %eax,%esi
  800a93:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aaa:	89 d1                	mov    %edx,%ecx
  800aac:	89 d3                	mov    %edx,%ebx
  800aae:	89 d7                	mov    %edx,%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ac2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac7:	b8 03 00 00 00       	mov    $0x3,%eax
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 cb                	mov    %ecx,%ebx
  800ad1:	89 cf                	mov    %ecx,%edi
  800ad3:	89 ce                	mov    %ecx,%esi
  800ad5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	7e 17                	jle    800af2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	50                   	push   %eax
  800adf:	6a 03                	push   $0x3
  800ae1:	68 1f 2b 80 00       	push   $0x802b1f
  800ae6:	6a 22                	push   $0x22
  800ae8:	68 3c 2b 80 00       	push   $0x802b3c
  800aed:	e8 5f 17 00 00       	call   802251 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_yield>:

void
sys_yield(void)
{      
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b29:	89 d1                	mov    %edx,%ecx
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	89 d7                	mov    %edx,%edi
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b41:	be 00 00 00 00       	mov    $0x0,%esi
  800b46:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b54:	89 f7                	mov    %esi,%edi
  800b56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 04                	push   $0x4
  800b62:	68 1f 2b 80 00       	push   $0x802b1f
  800b67:	6a 22                	push   $0x22
  800b69:	68 3c 2b 80 00       	push   $0x802b3c
  800b6e:	e8 de 16 00 00       	call   802251 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b84:	b8 05 00 00 00       	mov    $0x5,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b95:	8b 75 18             	mov    0x18(%ebp),%esi
  800b98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 05                	push   $0x5
  800ba4:	68 1f 2b 80 00       	push   $0x802b1f
  800ba9:	6a 22                	push   $0x22
  800bab:	68 3c 2b 80 00       	push   $0x802b3c
  800bb0:	e8 9c 16 00 00       	call   802251 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcb:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	89 df                	mov    %ebx,%edi
  800bd8:	89 de                	mov    %ebx,%esi
  800bda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 06                	push   $0x6
  800be6:	68 1f 2b 80 00       	push   $0x802b1f
  800beb:	6a 22                	push   $0x22
  800bed:	68 3c 2b 80 00       	push   $0x802b3c
  800bf2:	e8 5a 16 00 00       	call   802251 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 08                	push   $0x8
  800c28:	68 1f 2b 80 00       	push   $0x802b1f
  800c2d:	6a 22                	push   $0x22
  800c2f:	68 3c 2b 80 00       	push   $0x802b3c
  800c34:	e8 18 16 00 00       	call   802251 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 09                	push   $0x9
  800c6a:	68 1f 2b 80 00       	push   $0x802b1f
  800c6f:	6a 22                	push   $0x22
  800c71:	68 3c 2b 80 00       	push   $0x802b3c
  800c76:	e8 d6 15 00 00       	call   802251 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 0a                	push   $0xa
  800cac:	68 1f 2b 80 00       	push   $0x802b1f
  800cb1:	6a 22                	push   $0x22
  800cb3:	68 3c 2b 80 00       	push   $0x802b3c
  800cb8:	e8 94 15 00 00       	call   802251 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 cb                	mov    %ecx,%ebx
  800d00:	89 cf                	mov    %ecx,%edi
  800d02:	89 ce                	mov    %ecx,%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 0d                	push   $0xd
  800d10:	68 1f 2b 80 00       	push   $0x802b1f
  800d15:	6a 22                	push   $0x22
  800d17:	68 3c 2b 80 00       	push   $0x802b3c
  800d1c:	e8 30 15 00 00       	call   802251 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d39:	89 d1                	mov    %edx,%ecx
  800d3b:	89 d3                	mov    %edx,%ebx
  800d3d:	89 d7                	mov    %edx,%edi
  800d3f:	89 d6                	mov    %edx,%esi
  800d41:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d56:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 cb                	mov    %ecx,%ebx
  800d60:	89 cf                	mov    %ecx,%edi
  800d62:	89 ce                	mov    %ecx,%esi
  800d64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 17                	jle    800d81 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 0f                	push   $0xf
  800d70:	68 1f 2b 80 00       	push   $0x802b1f
  800d75:	6a 22                	push   $0x22
  800d77:	68 3c 2b 80 00       	push   $0x802b3c
  800d7c:	e8 d0 14 00 00       	call   802251 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_recv>:

int
sys_recv(void *addr)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d97:	b8 10 00 00 00       	mov    $0x10,%eax
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 cb                	mov    %ecx,%ebx
  800da1:	89 cf                	mov    %ecx,%edi
  800da3:	89 ce                	mov    %ecx,%esi
  800da5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 10                	push   $0x10
  800db1:	68 1f 2b 80 00       	push   $0x802b1f
  800db6:	6a 22                	push   $0x22
  800db8:	68 3c 2b 80 00       	push   $0x802b3c
  800dbd:	e8 8f 14 00 00       	call   802251 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 04             	sub    $0x4,%esp
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dd4:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800dd6:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dda:	74 2e                	je     800e0a <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ddc:	89 c2                	mov    %eax,%edx
  800dde:	c1 ea 16             	shr    $0x16,%edx
  800de1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de8:	f6 c2 01             	test   $0x1,%dl
  800deb:	74 1d                	je     800e0a <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ded:	89 c2                	mov    %eax,%edx
  800def:	c1 ea 0c             	shr    $0xc,%edx
  800df2:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800df9:	f6 c1 01             	test   $0x1,%cl
  800dfc:	74 0c                	je     800e0a <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dfe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e05:	f6 c6 08             	test   $0x8,%dh
  800e08:	75 14                	jne    800e1e <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 4c 2b 80 00       	push   $0x802b4c
  800e12:	6a 21                	push   $0x21
  800e14:	68 df 2b 80 00       	push   $0x802bdf
  800e19:	e8 33 14 00 00       	call   802251 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e23:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	6a 07                	push   $0x7
  800e2a:	68 00 f0 7f 00       	push   $0x7ff000
  800e2f:	6a 00                	push   $0x0
  800e31:	e8 02 fd ff ff       	call   800b38 <sys_page_alloc>
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	79 14                	jns    800e51 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e3d:	83 ec 04             	sub    $0x4,%esp
  800e40:	68 ea 2b 80 00       	push   $0x802bea
  800e45:	6a 2b                	push   $0x2b
  800e47:	68 df 2b 80 00       	push   $0x802bdf
  800e4c:	e8 00 14 00 00       	call   802251 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	68 00 10 00 00       	push   $0x1000
  800e59:	53                   	push   %ebx
  800e5a:	68 00 f0 7f 00       	push   $0x7ff000
  800e5f:	e8 5d fa ff ff       	call   8008c1 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e64:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e6b:	53                   	push   %ebx
  800e6c:	6a 00                	push   $0x0
  800e6e:	68 00 f0 7f 00       	push   $0x7ff000
  800e73:	6a 00                	push   $0x0
  800e75:	e8 01 fd ff ff       	call   800b7b <sys_page_map>
  800e7a:	83 c4 20             	add    $0x20,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	79 14                	jns    800e95 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	68 00 2c 80 00       	push   $0x802c00
  800e89:	6a 2e                	push   $0x2e
  800e8b:	68 df 2b 80 00       	push   $0x802bdf
  800e90:	e8 bc 13 00 00       	call   802251 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e95:	83 ec 08             	sub    $0x8,%esp
  800e98:	68 00 f0 7f 00       	push   $0x7ff000
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 19 fd ff ff       	call   800bbd <sys_page_unmap>
  800ea4:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800ea7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800eb5:	68 ca 0d 80 00       	push   $0x800dca
  800eba:	e8 d8 13 00 00       	call   802297 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ebf:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec4:	cd 30                	int    $0x30
  800ec6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	79 12                	jns    800ee2 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800ed0:	50                   	push   %eax
  800ed1:	68 14 2c 80 00       	push   $0x802c14
  800ed6:	6a 6d                	push   $0x6d
  800ed8:	68 df 2b 80 00       	push   $0x802bdf
  800edd:	e8 6f 13 00 00       	call   802251 <_panic>
  800ee2:	89 c7                	mov    %eax,%edi
  800ee4:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800ee9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eed:	75 21                	jne    800f10 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800eef:	e8 06 fc ff ff       	call   800afa <sys_getenvid>
  800ef4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800efc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f01:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	e9 9c 01 00 00       	jmp    8010ac <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	c1 e8 16             	shr    $0x16,%eax
  800f15:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1c:	a8 01                	test   $0x1,%al
  800f1e:	0f 84 f3 00 00 00    	je     801017 <fork+0x16b>
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	c1 e8 0c             	shr    $0xc,%eax
  800f29:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	0f 84 de 00 00 00    	je     801017 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f39:	89 c6                	mov    %eax,%esi
  800f3b:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f3e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f45:	f6 c6 04             	test   $0x4,%dh
  800f48:	74 37                	je     800f81 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	25 07 0e 00 00       	and    $0xe07,%eax
  800f59:	50                   	push   %eax
  800f5a:	56                   	push   %esi
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 17 fc ff ff       	call   800b7b <sys_page_map>
  800f64:	83 c4 20             	add    $0x20,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	0f 89 a8 00 00 00    	jns    801017 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  800f6f:	50                   	push   %eax
  800f70:	68 70 2b 80 00       	push   $0x802b70
  800f75:	6a 49                	push   $0x49
  800f77:	68 df 2b 80 00       	push   $0x802bdf
  800f7c:	e8 d0 12 00 00       	call   802251 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f88:	f6 c6 08             	test   $0x8,%dh
  800f8b:	75 0b                	jne    800f98 <fork+0xec>
  800f8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f94:	a8 02                	test   $0x2,%al
  800f96:	74 57                	je     800fef <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	68 05 08 00 00       	push   $0x805
  800fa0:	56                   	push   %esi
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 d1 fb ff ff       	call   800b7b <sys_page_map>
  800faa:	83 c4 20             	add    $0x20,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	79 12                	jns    800fc3 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  800fb1:	50                   	push   %eax
  800fb2:	68 70 2b 80 00       	push   $0x802b70
  800fb7:	6a 4c                	push   $0x4c
  800fb9:	68 df 2b 80 00       	push   $0x802bdf
  800fbe:	e8 8e 12 00 00       	call   802251 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	68 05 08 00 00       	push   $0x805
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	56                   	push   %esi
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 a5 fb ff ff       	call   800b7b <sys_page_map>
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 3a                	jns    801017 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  800fdd:	50                   	push   %eax
  800fde:	68 94 2b 80 00       	push   $0x802b94
  800fe3:	6a 4e                	push   $0x4e
  800fe5:	68 df 2b 80 00       	push   $0x802bdf
  800fea:	e8 62 12 00 00       	call   802251 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	6a 05                	push   $0x5
  800ff4:	56                   	push   %esi
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 7d fb ff ff       	call   800b7b <sys_page_map>
  800ffe:	83 c4 20             	add    $0x20,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	79 12                	jns    801017 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  801005:	50                   	push   %eax
  801006:	68 bc 2b 80 00       	push   $0x802bbc
  80100b:	6a 50                	push   $0x50
  80100d:	68 df 2b 80 00       	push   $0x802bdf
  801012:	e8 3a 12 00 00       	call   802251 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801017:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801023:	0f 85 e7 fe ff ff    	jne    800f10 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	6a 07                	push   $0x7
  80102e:	68 00 f0 bf ee       	push   $0xeebff000
  801033:	ff 75 e4             	pushl  -0x1c(%ebp)
  801036:	e8 fd fa ff ff       	call   800b38 <sys_page_alloc>
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	79 14                	jns    801056 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	68 24 2c 80 00       	push   $0x802c24
  80104a:	6a 76                	push   $0x76
  80104c:	68 df 2b 80 00       	push   $0x802bdf
  801051:	e8 fb 11 00 00       	call   802251 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	68 06 23 80 00       	push   $0x802306
  80105e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801061:	e8 1d fc ff ff       	call   800c83 <sys_env_set_pgfault_upcall>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 14                	jns    801081 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  80106d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801070:	68 3e 2c 80 00       	push   $0x802c3e
  801075:	6a 79                	push   $0x79
  801077:	68 df 2b 80 00       	push   $0x802bdf
  80107c:	e8 d0 11 00 00       	call   802251 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	6a 02                	push   $0x2
  801086:	ff 75 e4             	pushl  -0x1c(%ebp)
  801089:	e8 71 fb ff ff       	call   800bff <sys_env_set_status>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 14                	jns    8010a9 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801095:	ff 75 e4             	pushl  -0x1c(%ebp)
  801098:	68 5b 2c 80 00       	push   $0x802c5b
  80109d:	6a 7b                	push   $0x7b
  80109f:	68 df 2b 80 00       	push   $0x802bdf
  8010a4:	e8 a8 11 00 00       	call   802251 <_panic>
        return forkid;
  8010a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ba:	68 72 2c 80 00       	push   $0x802c72
  8010bf:	68 83 00 00 00       	push   $0x83
  8010c4:	68 df 2b 80 00       	push   $0x802bdf
  8010c9:	e8 83 11 00 00       	call   802251 <_panic>

008010ce <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d9:	c1 e8 0c             	shr    $0xc,%eax
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e4:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8010e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ee:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801100:	89 c2                	mov    %eax,%edx
  801102:	c1 ea 16             	shr    $0x16,%edx
  801105:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110c:	f6 c2 01             	test   $0x1,%dl
  80110f:	74 11                	je     801122 <fd_alloc+0x2d>
  801111:	89 c2                	mov    %eax,%edx
  801113:	c1 ea 0c             	shr    $0xc,%edx
  801116:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111d:	f6 c2 01             	test   $0x1,%dl
  801120:	75 09                	jne    80112b <fd_alloc+0x36>
			*fd_store = fd;
  801122:	89 01                	mov    %eax,(%ecx)
			return 0;
  801124:	b8 00 00 00 00       	mov    $0x0,%eax
  801129:	eb 17                	jmp    801142 <fd_alloc+0x4d>
  80112b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801130:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801135:	75 c9                	jne    801100 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801137:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80113d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114a:	83 f8 1f             	cmp    $0x1f,%eax
  80114d:	77 36                	ja     801185 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80114f:	c1 e0 0c             	shl    $0xc,%eax
  801152:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 16             	shr    $0x16,%edx
  80115c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	74 24                	je     80118c <fd_lookup+0x48>
  801168:	89 c2                	mov    %eax,%edx
  80116a:	c1 ea 0c             	shr    $0xc,%edx
  80116d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801174:	f6 c2 01             	test   $0x1,%dl
  801177:	74 1a                	je     801193 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117c:	89 02                	mov    %eax,(%edx)
	return 0;
  80117e:	b8 00 00 00 00       	mov    $0x0,%eax
  801183:	eb 13                	jmp    801198 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118a:	eb 0c                	jmp    801198 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801191:	eb 05                	jmp    801198 <fd_lookup+0x54>
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a8:	eb 13                	jmp    8011bd <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8011aa:	39 08                	cmp    %ecx,(%eax)
  8011ac:	75 0c                	jne    8011ba <dev_lookup+0x20>
			*dev = devtab[i];
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb 36                	jmp    8011f0 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ba:	83 c2 01             	add    $0x1,%edx
  8011bd:	8b 04 95 04 2d 80 00 	mov    0x802d04(,%edx,4),%eax
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	75 e2                	jne    8011aa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011cd:	8b 40 48             	mov    0x48(%eax),%eax
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	51                   	push   %ecx
  8011d4:	50                   	push   %eax
  8011d5:	68 88 2c 80 00       	push   $0x802c88
  8011da:	e8 c9 ef ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8011df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 10             	sub    $0x10,%esp
  8011fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801203:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801204:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80120a:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80120d:	50                   	push   %eax
  80120e:	e8 31 ff ff ff       	call   801144 <fd_lookup>
  801213:	83 c4 08             	add    $0x8,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 05                	js     80121f <fd_close+0x2d>
	    || fd != fd2)
  80121a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121d:	74 0c                	je     80122b <fd_close+0x39>
		return (must_exist ? r : 0);
  80121f:	84 db                	test   %bl,%bl
  801221:	ba 00 00 00 00       	mov    $0x0,%edx
  801226:	0f 44 c2             	cmove  %edx,%eax
  801229:	eb 41                	jmp    80126c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 36                	pushl  (%esi)
  801234:	e8 61 ff ff ff       	call   80119a <dev_lookup>
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 1a                	js     80125c <fd_close+0x6a>
		if (dev->dev_close)
  801242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801245:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801248:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124d:	85 c0                	test   %eax,%eax
  80124f:	74 0b                	je     80125c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	56                   	push   %esi
  801255:	ff d0                	call   *%eax
  801257:	89 c3                	mov    %eax,%ebx
  801259:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	56                   	push   %esi
  801260:	6a 00                	push   $0x0
  801262:	e8 56 f9 ff ff       	call   800bbd <sys_page_unmap>
	return r;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	89 d8                	mov    %ebx,%eax
}
  80126c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 bf fe ff ff       	call   801144 <fd_lookup>
  801285:	89 c2                	mov    %eax,%edx
  801287:	83 c4 08             	add    $0x8,%esp
  80128a:	85 d2                	test   %edx,%edx
  80128c:	78 10                	js     80129e <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	6a 01                	push   $0x1
  801293:	ff 75 f4             	pushl  -0xc(%ebp)
  801296:	e8 57 ff ff ff       	call   8011f2 <fd_close>
  80129b:	83 c4 10             	add    $0x10,%esp
}
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <close_all>:

void
close_all(void)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ac:	83 ec 0c             	sub    $0xc,%esp
  8012af:	53                   	push   %ebx
  8012b0:	e8 be ff ff ff       	call   801273 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b5:	83 c3 01             	add    $0x1,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	83 fb 20             	cmp    $0x20,%ebx
  8012be:	75 ec                	jne    8012ac <close_all+0xc>
		close(i);
}
  8012c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c3:	c9                   	leave  
  8012c4:	c3                   	ret    

008012c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	57                   	push   %edi
  8012c9:	56                   	push   %esi
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 2c             	sub    $0x2c,%esp
  8012ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	ff 75 08             	pushl  0x8(%ebp)
  8012d8:	e8 67 fe ff ff       	call   801144 <fd_lookup>
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	83 c4 08             	add    $0x8,%esp
  8012e2:	85 d2                	test   %edx,%edx
  8012e4:	0f 88 c1 00 00 00    	js     8013ab <dup+0xe6>
		return r;
	close(newfdnum);
  8012ea:	83 ec 0c             	sub    $0xc,%esp
  8012ed:	56                   	push   %esi
  8012ee:	e8 80 ff ff ff       	call   801273 <close>

	newfd = INDEX2FD(newfdnum);
  8012f3:	89 f3                	mov    %esi,%ebx
  8012f5:	c1 e3 0c             	shl    $0xc,%ebx
  8012f8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012fe:	83 c4 04             	add    $0x4,%esp
  801301:	ff 75 e4             	pushl  -0x1c(%ebp)
  801304:	e8 d5 fd ff ff       	call   8010de <fd2data>
  801309:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80130b:	89 1c 24             	mov    %ebx,(%esp)
  80130e:	e8 cb fd ff ff       	call   8010de <fd2data>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801319:	89 f8                	mov    %edi,%eax
  80131b:	c1 e8 16             	shr    $0x16,%eax
  80131e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801325:	a8 01                	test   $0x1,%al
  801327:	74 37                	je     801360 <dup+0x9b>
  801329:	89 f8                	mov    %edi,%eax
  80132b:	c1 e8 0c             	shr    $0xc,%eax
  80132e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801335:	f6 c2 01             	test   $0x1,%dl
  801338:	74 26                	je     801360 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80133a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	25 07 0e 00 00       	and    $0xe07,%eax
  801349:	50                   	push   %eax
  80134a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134d:	6a 00                	push   $0x0
  80134f:	57                   	push   %edi
  801350:	6a 00                	push   $0x0
  801352:	e8 24 f8 ff ff       	call   800b7b <sys_page_map>
  801357:	89 c7                	mov    %eax,%edi
  801359:	83 c4 20             	add    $0x20,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 2e                	js     80138e <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801360:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801363:	89 d0                	mov    %edx,%eax
  801365:	c1 e8 0c             	shr    $0xc,%eax
  801368:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	25 07 0e 00 00       	and    $0xe07,%eax
  801377:	50                   	push   %eax
  801378:	53                   	push   %ebx
  801379:	6a 00                	push   $0x0
  80137b:	52                   	push   %edx
  80137c:	6a 00                	push   $0x0
  80137e:	e8 f8 f7 ff ff       	call   800b7b <sys_page_map>
  801383:	89 c7                	mov    %eax,%edi
  801385:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801388:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138a:	85 ff                	test   %edi,%edi
  80138c:	79 1d                	jns    8013ab <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	53                   	push   %ebx
  801392:	6a 00                	push   $0x0
  801394:	e8 24 f8 ff ff       	call   800bbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801399:	83 c4 08             	add    $0x8,%esp
  80139c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139f:	6a 00                	push   $0x0
  8013a1:	e8 17 f8 ff ff       	call   800bbd <sys_page_unmap>
	return r;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	89 f8                	mov    %edi,%eax
}
  8013ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5f                   	pop    %edi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 14             	sub    $0x14,%esp
  8013ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	53                   	push   %ebx
  8013c2:	e8 7d fd ff ff       	call   801144 <fd_lookup>
  8013c7:	83 c4 08             	add    $0x8,%esp
  8013ca:	89 c2                	mov    %eax,%edx
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 6d                	js     80143d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013da:	ff 30                	pushl  (%eax)
  8013dc:	e8 b9 fd ff ff       	call   80119a <dev_lookup>
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 4c                	js     801434 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013eb:	8b 42 08             	mov    0x8(%edx),%eax
  8013ee:	83 e0 03             	and    $0x3,%eax
  8013f1:	83 f8 01             	cmp    $0x1,%eax
  8013f4:	75 21                	jne    801417 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8013fb:	8b 40 48             	mov    0x48(%eax),%eax
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	53                   	push   %ebx
  801402:	50                   	push   %eax
  801403:	68 c9 2c 80 00       	push   $0x802cc9
  801408:	e8 9b ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801415:	eb 26                	jmp    80143d <read+0x8a>
	}
	if (!dev->dev_read)
  801417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141a:	8b 40 08             	mov    0x8(%eax),%eax
  80141d:	85 c0                	test   %eax,%eax
  80141f:	74 17                	je     801438 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	ff 75 10             	pushl  0x10(%ebp)
  801427:	ff 75 0c             	pushl  0xc(%ebp)
  80142a:	52                   	push   %edx
  80142b:	ff d0                	call   *%eax
  80142d:	89 c2                	mov    %eax,%edx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	eb 09                	jmp    80143d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801434:	89 c2                	mov    %eax,%edx
  801436:	eb 05                	jmp    80143d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801438:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80143d:	89 d0                	mov    %edx,%eax
  80143f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	57                   	push   %edi
  801448:	56                   	push   %esi
  801449:	53                   	push   %ebx
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801450:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801453:	bb 00 00 00 00       	mov    $0x0,%ebx
  801458:	eb 21                	jmp    80147b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145a:	83 ec 04             	sub    $0x4,%esp
  80145d:	89 f0                	mov    %esi,%eax
  80145f:	29 d8                	sub    %ebx,%eax
  801461:	50                   	push   %eax
  801462:	89 d8                	mov    %ebx,%eax
  801464:	03 45 0c             	add    0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	57                   	push   %edi
  801469:	e8 45 ff ff ff       	call   8013b3 <read>
		if (m < 0)
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 0c                	js     801481 <readn+0x3d>
			return m;
		if (m == 0)
  801475:	85 c0                	test   %eax,%eax
  801477:	74 06                	je     80147f <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801479:	01 c3                	add    %eax,%ebx
  80147b:	39 f3                	cmp    %esi,%ebx
  80147d:	72 db                	jb     80145a <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80147f:	89 d8                	mov    %ebx,%eax
}
  801481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 14             	sub    $0x14,%esp
  801490:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801493:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	53                   	push   %ebx
  801498:	e8 a7 fc ff ff       	call   801144 <fd_lookup>
  80149d:	83 c4 08             	add    $0x8,%esp
  8014a0:	89 c2                	mov    %eax,%edx
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 68                	js     80150e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b0:	ff 30                	pushl  (%eax)
  8014b2:	e8 e3 fc ff ff       	call   80119a <dev_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 47                	js     801505 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c5:	75 21                	jne    8014e8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8014cc:	8b 40 48             	mov    0x48(%eax),%eax
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	53                   	push   %ebx
  8014d3:	50                   	push   %eax
  8014d4:	68 e5 2c 80 00       	push   $0x802ce5
  8014d9:	e8 ca ec ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e6:	eb 26                	jmp    80150e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ee:	85 d2                	test   %edx,%edx
  8014f0:	74 17                	je     801509 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	ff 75 10             	pushl  0x10(%ebp)
  8014f8:	ff 75 0c             	pushl  0xc(%ebp)
  8014fb:	50                   	push   %eax
  8014fc:	ff d2                	call   *%edx
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	eb 09                	jmp    80150e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801505:	89 c2                	mov    %eax,%edx
  801507:	eb 05                	jmp    80150e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801509:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150e:	89 d0                	mov    %edx,%eax
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <seek>:

int
seek(int fdnum, off_t offset)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	ff 75 08             	pushl  0x8(%ebp)
  801522:	e8 1d fc ff ff       	call   801144 <fd_lookup>
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 0e                	js     80153c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801531:	8b 55 0c             	mov    0xc(%ebp),%edx
  801534:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 14             	sub    $0x14,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	53                   	push   %ebx
  80154d:	e8 f2 fb ff ff       	call   801144 <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	89 c2                	mov    %eax,%edx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 65                	js     8015c0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	ff 30                	pushl  (%eax)
  801567:	e8 2e fc ff ff       	call   80119a <dev_lookup>
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 44                	js     8015b7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157a:	75 21                	jne    80159d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	53                   	push   %ebx
  801588:	50                   	push   %eax
  801589:	68 a8 2c 80 00       	push   $0x802ca8
  80158e:	e8 15 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159b:	eb 23                	jmp    8015c0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a0:	8b 52 18             	mov    0x18(%edx),%edx
  8015a3:	85 d2                	test   %edx,%edx
  8015a5:	74 14                	je     8015bb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	ff 75 0c             	pushl  0xc(%ebp)
  8015ad:	50                   	push   %eax
  8015ae:	ff d2                	call   *%edx
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	eb 09                	jmp    8015c0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	eb 05                	jmp    8015c0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015c0:	89 d0                	mov    %edx,%eax
  8015c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 14             	sub    $0x14,%esp
  8015ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	e8 67 fb ff ff       	call   801144 <fd_lookup>
  8015dd:	83 c4 08             	add    $0x8,%esp
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 58                	js     80163e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	ff 30                	pushl  (%eax)
  8015f2:	e8 a3 fb ff ff       	call   80119a <dev_lookup>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 37                	js     801635 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801601:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801605:	74 32                	je     801639 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801607:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80160a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801611:	00 00 00 
	stat->st_isdir = 0;
  801614:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161b:	00 00 00 
	stat->st_dev = dev;
  80161e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	53                   	push   %ebx
  801628:	ff 75 f0             	pushl  -0x10(%ebp)
  80162b:	ff 50 14             	call   *0x14(%eax)
  80162e:	89 c2                	mov    %eax,%edx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 09                	jmp    80163e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801635:	89 c2                	mov    %eax,%edx
  801637:	eb 05                	jmp    80163e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801639:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163e:	89 d0                	mov    %edx,%eax
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	6a 00                	push   $0x0
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 09 02 00 00       	call   801860 <open>
  801657:	89 c3                	mov    %eax,%ebx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 db                	test   %ebx,%ebx
  80165e:	78 1b                	js     80167b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	53                   	push   %ebx
  801667:	e8 5b ff ff ff       	call   8015c7 <fstat>
  80166c:	89 c6                	mov    %eax,%esi
	close(fd);
  80166e:	89 1c 24             	mov    %ebx,(%esp)
  801671:	e8 fd fb ff ff       	call   801273 <close>
	return r;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	89 f0                	mov    %esi,%eax
}
  80167b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	89 c6                	mov    %eax,%esi
  801689:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80168b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801692:	75 12                	jne    8016a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	6a 01                	push   $0x1
  801699:	e8 49 0d 00 00       	call   8023e7 <ipc_find_env>
  80169e:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a6:	6a 07                	push   $0x7
  8016a8:	68 00 50 80 00       	push   $0x805000
  8016ad:	56                   	push   %esi
  8016ae:	ff 35 00 40 80 00    	pushl  0x804000
  8016b4:	e8 da 0c 00 00       	call   802393 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b9:	83 c4 0c             	add    $0xc,%esp
  8016bc:	6a 00                	push   $0x0
  8016be:	53                   	push   %ebx
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 64 0c 00 00       	call   80232a <ipc_recv>
}
  8016c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8016f0:	e8 8d ff ff ff       	call   801682 <fsipc>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 40 0c             	mov    0xc(%eax),%eax
  801703:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801708:	ba 00 00 00 00       	mov    $0x0,%edx
  80170d:	b8 06 00 00 00       	mov    $0x6,%eax
  801712:	e8 6b ff ff ff       	call   801682 <fsipc>
}
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	53                   	push   %ebx
  80171d:	83 ec 04             	sub    $0x4,%esp
  801720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	8b 40 0c             	mov    0xc(%eax),%eax
  801729:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 05 00 00 00       	mov    $0x5,%eax
  801738:	e8 45 ff ff ff       	call   801682 <fsipc>
  80173d:	89 c2                	mov    %eax,%edx
  80173f:	85 d2                	test   %edx,%edx
  801741:	78 2c                	js     80176f <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	68 00 50 80 00       	push   $0x805000
  80174b:	53                   	push   %ebx
  80174c:	e8 de ef ff ff       	call   80072f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801751:	a1 80 50 80 00       	mov    0x805080,%eax
  801756:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80175c:	a1 84 50 80 00       	mov    0x805084,%eax
  801761:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	57                   	push   %edi
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	8b 40 0c             	mov    0xc(%eax),%eax
  801786:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80178b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80178e:	eb 3d                	jmp    8017cd <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801790:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801796:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80179b:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	57                   	push   %edi
  8017a2:	53                   	push   %ebx
  8017a3:	68 08 50 80 00       	push   $0x805008
  8017a8:	e8 14 f1 ff ff       	call   8008c1 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8017ad:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8017bd:	e8 c0 fe ff ff       	call   801682 <fsipc>
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 0d                	js     8017d6 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8017c9:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8017cb:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017cd:	85 f6                	test   %esi,%esi
  8017cf:	75 bf                	jne    801790 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8017d1:	89 d8                	mov    %ebx,%eax
  8017d3:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8017d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5f                   	pop    %edi
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801801:	e8 7c fe ff ff       	call   801682 <fsipc>
  801806:	89 c3                	mov    %eax,%ebx
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 4b                	js     801857 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80180c:	39 c6                	cmp    %eax,%esi
  80180e:	73 16                	jae    801826 <devfile_read+0x48>
  801810:	68 18 2d 80 00       	push   $0x802d18
  801815:	68 1f 2d 80 00       	push   $0x802d1f
  80181a:	6a 7c                	push   $0x7c
  80181c:	68 34 2d 80 00       	push   $0x802d34
  801821:	e8 2b 0a 00 00       	call   802251 <_panic>
	assert(r <= PGSIZE);
  801826:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182b:	7e 16                	jle    801843 <devfile_read+0x65>
  80182d:	68 3f 2d 80 00       	push   $0x802d3f
  801832:	68 1f 2d 80 00       	push   $0x802d1f
  801837:	6a 7d                	push   $0x7d
  801839:	68 34 2d 80 00       	push   $0x802d34
  80183e:	e8 0e 0a 00 00       	call   802251 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	50                   	push   %eax
  801847:	68 00 50 80 00       	push   $0x805000
  80184c:	ff 75 0c             	pushl  0xc(%ebp)
  80184f:	e8 6d f0 ff ff       	call   8008c1 <memmove>
	return r;
  801854:	83 c4 10             	add    $0x10,%esp
}
  801857:	89 d8                	mov    %ebx,%eax
  801859:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5e                   	pop    %esi
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 20             	sub    $0x20,%esp
  801867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80186a:	53                   	push   %ebx
  80186b:	e8 86 ee ff ff       	call   8006f6 <strlen>
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801878:	7f 67                	jg     8018e1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	e8 6f f8 ff ff       	call   8010f5 <fd_alloc>
  801886:	83 c4 10             	add    $0x10,%esp
		return r;
  801889:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 57                	js     8018e6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	53                   	push   %ebx
  801893:	68 00 50 80 00       	push   $0x805000
  801898:	e8 92 ee ff ff       	call   80072f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ad:	e8 d0 fd ff ff       	call   801682 <fsipc>
  8018b2:	89 c3                	mov    %eax,%ebx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	79 14                	jns    8018cf <open+0x6f>
		fd_close(fd, 0);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	6a 00                	push   $0x0
  8018c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c3:	e8 2a f9 ff ff       	call   8011f2 <fd_close>
		return r;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	89 da                	mov    %ebx,%edx
  8018cd:	eb 17                	jmp    8018e6 <open+0x86>
	}

	return fd2num(fd);
  8018cf:	83 ec 0c             	sub    $0xc,%esp
  8018d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d5:	e8 f4 f7 ff ff       	call   8010ce <fd2num>
  8018da:	89 c2                	mov    %eax,%edx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	eb 05                	jmp    8018e6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018e6:	89 d0                	mov    %edx,%eax
  8018e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8018fd:	e8 80 fd ff ff       	call   801682 <fsipc>
}
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80190a:	68 4b 2d 80 00       	push   $0x802d4b
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	e8 18 ee ff ff       	call   80072f <strcpy>
	return 0;
}
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 10             	sub    $0x10,%esp
  801925:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801928:	53                   	push   %ebx
  801929:	e8 f1 0a 00 00       	call   80241f <pageref>
  80192e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801936:	83 f8 01             	cmp    $0x1,%eax
  801939:	75 10                	jne    80194b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	ff 73 0c             	pushl  0xc(%ebx)
  801941:	e8 ca 02 00 00       	call   801c10 <nsipc_close>
  801946:	89 c2                	mov    %eax,%edx
  801948:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80194b:	89 d0                	mov    %edx,%eax
  80194d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801958:	6a 00                	push   $0x0
  80195a:	ff 75 10             	pushl  0x10(%ebp)
  80195d:	ff 75 0c             	pushl  0xc(%ebp)
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	ff 70 0c             	pushl  0xc(%eax)
  801966:	e8 82 03 00 00       	call   801ced <nsipc_send>
}
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801973:	6a 00                	push   $0x0
  801975:	ff 75 10             	pushl  0x10(%ebp)
  801978:	ff 75 0c             	pushl  0xc(%ebp)
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	ff 70 0c             	pushl  0xc(%eax)
  801981:	e8 fb 02 00 00       	call   801c81 <nsipc_recv>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80198e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801991:	52                   	push   %edx
  801992:	50                   	push   %eax
  801993:	e8 ac f7 ff ff       	call   801144 <fd_lookup>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 17                	js     8019b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80199f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a2:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019a8:	39 08                	cmp    %ecx,(%eax)
  8019aa:	75 05                	jne    8019b1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8019af:	eb 05                	jmp    8019b6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 1c             	sub    $0x1c,%esp
  8019c0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c5:	50                   	push   %eax
  8019c6:	e8 2a f7 ff ff       	call   8010f5 <fd_alloc>
  8019cb:	89 c3                	mov    %eax,%ebx
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 1b                	js     8019ef <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019d4:	83 ec 04             	sub    $0x4,%esp
  8019d7:	68 07 04 00 00       	push   $0x407
  8019dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019df:	6a 00                	push   $0x0
  8019e1:	e8 52 f1 ff ff       	call   800b38 <sys_page_alloc>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	79 10                	jns    8019ff <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	56                   	push   %esi
  8019f3:	e8 18 02 00 00       	call   801c10 <nsipc_close>
		return r;
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	89 d8                	mov    %ebx,%eax
  8019fd:	eb 24                	jmp    801a23 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a08:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0d:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801a14:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	52                   	push   %edx
  801a1b:	e8 ae f6 ff ff       	call   8010ce <fd2num>
  801a20:	83 c4 10             	add    $0x10,%esp
}
  801a23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	e8 50 ff ff ff       	call   801988 <fd2sockid>
		return r;
  801a38:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 1f                	js     801a5d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	ff 75 10             	pushl  0x10(%ebp)
  801a44:	ff 75 0c             	pushl  0xc(%ebp)
  801a47:	50                   	push   %eax
  801a48:	e8 1c 01 00 00       	call   801b69 <nsipc_accept>
  801a4d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a50:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 07                	js     801a5d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a56:	e8 5d ff ff ff       	call   8019b8 <alloc_sockfd>
  801a5b:	89 c1                	mov    %eax,%ecx
}
  801a5d:	89 c8                	mov    %ecx,%eax
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	e8 19 ff ff ff       	call   801988 <fd2sockid>
  801a6f:	89 c2                	mov    %eax,%edx
  801a71:	85 d2                	test   %edx,%edx
  801a73:	78 12                	js     801a87 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801a75:	83 ec 04             	sub    $0x4,%esp
  801a78:	ff 75 10             	pushl  0x10(%ebp)
  801a7b:	ff 75 0c             	pushl  0xc(%ebp)
  801a7e:	52                   	push   %edx
  801a7f:	e8 35 01 00 00       	call   801bb9 <nsipc_bind>
  801a84:	83 c4 10             	add    $0x10,%esp
}
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <shutdown>:

int
shutdown(int s, int how)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	e8 f1 fe ff ff       	call   801988 <fd2sockid>
  801a97:	89 c2                	mov    %eax,%edx
  801a99:	85 d2                	test   %edx,%edx
  801a9b:	78 0f                	js     801aac <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	ff 75 0c             	pushl  0xc(%ebp)
  801aa3:	52                   	push   %edx
  801aa4:	e8 45 01 00 00       	call   801bee <nsipc_shutdown>
  801aa9:	83 c4 10             	add    $0x10,%esp
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	e8 cc fe ff ff       	call   801988 <fd2sockid>
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	85 d2                	test   %edx,%edx
  801ac0:	78 12                	js     801ad4 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	ff 75 10             	pushl  0x10(%ebp)
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	52                   	push   %edx
  801acc:	e8 59 01 00 00       	call   801c2a <nsipc_connect>
  801ad1:	83 c4 10             	add    $0x10,%esp
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <listen>:

int
listen(int s, int backlog)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801adc:	8b 45 08             	mov    0x8(%ebp),%eax
  801adf:	e8 a4 fe ff ff       	call   801988 <fd2sockid>
  801ae4:	89 c2                	mov    %eax,%edx
  801ae6:	85 d2                	test   %edx,%edx
  801ae8:	78 0f                	js     801af9 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801aea:	83 ec 08             	sub    $0x8,%esp
  801aed:	ff 75 0c             	pushl  0xc(%ebp)
  801af0:	52                   	push   %edx
  801af1:	e8 69 01 00 00       	call   801c5f <nsipc_listen>
  801af6:	83 c4 10             	add    $0x10,%esp
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b01:	ff 75 10             	pushl  0x10(%ebp)
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	ff 75 08             	pushl  0x8(%ebp)
  801b0a:	e8 3c 02 00 00       	call   801d4b <nsipc_socket>
  801b0f:	89 c2                	mov    %eax,%edx
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 d2                	test   %edx,%edx
  801b16:	78 05                	js     801b1d <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801b18:	e8 9b fe ff ff       	call   8019b8 <alloc_sockfd>
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	53                   	push   %ebx
  801b23:	83 ec 04             	sub    $0x4,%esp
  801b26:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b28:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b2f:	75 12                	jne    801b43 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	6a 02                	push   $0x2
  801b36:	e8 ac 08 00 00       	call   8023e7 <ipc_find_env>
  801b3b:	a3 04 40 80 00       	mov    %eax,0x804004
  801b40:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b43:	6a 07                	push   $0x7
  801b45:	68 00 60 80 00       	push   $0x806000
  801b4a:	53                   	push   %ebx
  801b4b:	ff 35 04 40 80 00    	pushl  0x804004
  801b51:	e8 3d 08 00 00       	call   802393 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b56:	83 c4 0c             	add    $0xc,%esp
  801b59:	6a 00                	push   $0x0
  801b5b:	6a 00                	push   $0x0
  801b5d:	6a 00                	push   $0x0
  801b5f:	e8 c6 07 00 00       	call   80232a <ipc_recv>
}
  801b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b71:	8b 45 08             	mov    0x8(%ebp),%eax
  801b74:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b79:	8b 06                	mov    (%esi),%eax
  801b7b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b80:	b8 01 00 00 00       	mov    $0x1,%eax
  801b85:	e8 95 ff ff ff       	call   801b1f <nsipc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 20                	js     801bb0 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	ff 35 10 60 80 00    	pushl  0x806010
  801b99:	68 00 60 80 00       	push   $0x806000
  801b9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ba1:	e8 1b ed ff ff       	call   8008c1 <memmove>
		*addrlen = ret->ret_addrlen;
  801ba6:	a1 10 60 80 00       	mov    0x806010,%eax
  801bab:	89 06                	mov    %eax,(%esi)
  801bad:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bcb:	53                   	push   %ebx
  801bcc:	ff 75 0c             	pushl  0xc(%ebp)
  801bcf:	68 04 60 80 00       	push   $0x806004
  801bd4:	e8 e8 ec ff ff       	call   8008c1 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bd9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bdf:	b8 02 00 00 00       	mov    $0x2,%eax
  801be4:	e8 36 ff ff ff       	call   801b1f <nsipc>
}
  801be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bff:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c04:	b8 03 00 00 00       	mov    $0x3,%eax
  801c09:	e8 11 ff ff ff       	call   801b1f <nsipc>
}
  801c0e:	c9                   	leave  
  801c0f:	c3                   	ret    

00801c10 <nsipc_close>:

int
nsipc_close(int s)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c16:	8b 45 08             	mov    0x8(%ebp),%eax
  801c19:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c1e:	b8 04 00 00 00       	mov    $0x4,%eax
  801c23:	e8 f7 fe ff ff       	call   801b1f <nsipc>
}
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	53                   	push   %ebx
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c3c:	53                   	push   %ebx
  801c3d:	ff 75 0c             	pushl  0xc(%ebp)
  801c40:	68 04 60 80 00       	push   $0x806004
  801c45:	e8 77 ec ff ff       	call   8008c1 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c4a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c50:	b8 05 00 00 00       	mov    $0x5,%eax
  801c55:	e8 c5 fe ff ff       	call   801b1f <nsipc>
}
  801c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c70:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c75:	b8 06 00 00 00       	mov    $0x6,%eax
  801c7a:	e8 a0 fe ff ff       	call   801b1f <nsipc>
}
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	56                   	push   %esi
  801c85:	53                   	push   %ebx
  801c86:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c91:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c97:	8b 45 14             	mov    0x14(%ebp),%eax
  801c9a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c9f:	b8 07 00 00 00       	mov    $0x7,%eax
  801ca4:	e8 76 fe ff ff       	call   801b1f <nsipc>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 35                	js     801ce4 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801caf:	39 f0                	cmp    %esi,%eax
  801cb1:	7f 07                	jg     801cba <nsipc_recv+0x39>
  801cb3:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cb8:	7e 16                	jle    801cd0 <nsipc_recv+0x4f>
  801cba:	68 57 2d 80 00       	push   $0x802d57
  801cbf:	68 1f 2d 80 00       	push   $0x802d1f
  801cc4:	6a 62                	push   $0x62
  801cc6:	68 6c 2d 80 00       	push   $0x802d6c
  801ccb:	e8 81 05 00 00       	call   802251 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cd0:	83 ec 04             	sub    $0x4,%esp
  801cd3:	50                   	push   %eax
  801cd4:	68 00 60 80 00       	push   $0x806000
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	e8 e0 eb ff ff       	call   8008c1 <memmove>
  801ce1:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ce4:	89 d8                	mov    %ebx,%eax
  801ce6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 04             	sub    $0x4,%esp
  801cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cff:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d05:	7e 16                	jle    801d1d <nsipc_send+0x30>
  801d07:	68 78 2d 80 00       	push   $0x802d78
  801d0c:	68 1f 2d 80 00       	push   $0x802d1f
  801d11:	6a 6d                	push   $0x6d
  801d13:	68 6c 2d 80 00       	push   $0x802d6c
  801d18:	e8 34 05 00 00       	call   802251 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d1d:	83 ec 04             	sub    $0x4,%esp
  801d20:	53                   	push   %ebx
  801d21:	ff 75 0c             	pushl  0xc(%ebp)
  801d24:	68 0c 60 80 00       	push   $0x80600c
  801d29:	e8 93 eb ff ff       	call   8008c1 <memmove>
	nsipcbuf.send.req_size = size;
  801d2e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d34:	8b 45 14             	mov    0x14(%ebp),%eax
  801d37:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d3c:	b8 08 00 00 00       	mov    $0x8,%eax
  801d41:	e8 d9 fd ff ff       	call   801b1f <nsipc>
}
  801d46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d51:	8b 45 08             	mov    0x8(%ebp),%eax
  801d54:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d61:	8b 45 10             	mov    0x10(%ebp),%eax
  801d64:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d69:	b8 09 00 00 00       	mov    $0x9,%eax
  801d6e:	e8 ac fd ff ff       	call   801b1f <nsipc>
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
  801d7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d7d:	83 ec 0c             	sub    $0xc,%esp
  801d80:	ff 75 08             	pushl  0x8(%ebp)
  801d83:	e8 56 f3 ff ff       	call   8010de <fd2data>
  801d88:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d8a:	83 c4 08             	add    $0x8,%esp
  801d8d:	68 84 2d 80 00       	push   $0x802d84
  801d92:	53                   	push   %ebx
  801d93:	e8 97 e9 ff ff       	call   80072f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d98:	8b 56 04             	mov    0x4(%esi),%edx
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	2b 06                	sub    (%esi),%eax
  801d9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801da5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dac:	00 00 00 
	stat->st_dev = &devpipe;
  801daf:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801db6:	30 80 00 
	return 0;
}
  801db9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	53                   	push   %ebx
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dcf:	53                   	push   %ebx
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 e6 ed ff ff       	call   800bbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dd7:	89 1c 24             	mov    %ebx,(%esp)
  801dda:	e8 ff f2 ff ff       	call   8010de <fd2data>
  801ddf:	83 c4 08             	add    $0x8,%esp
  801de2:	50                   	push   %eax
  801de3:	6a 00                	push   $0x0
  801de5:	e8 d3 ed ff ff       	call   800bbd <sys_page_unmap>
}
  801dea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	57                   	push   %edi
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	83 ec 1c             	sub    $0x1c,%esp
  801df8:	89 c6                	mov    %eax,%esi
  801dfa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dfd:	a1 08 40 80 00       	mov    0x804008,%eax
  801e02:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e05:	83 ec 0c             	sub    $0xc,%esp
  801e08:	56                   	push   %esi
  801e09:	e8 11 06 00 00       	call   80241f <pageref>
  801e0e:	89 c7                	mov    %eax,%edi
  801e10:	83 c4 04             	add    $0x4,%esp
  801e13:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e16:	e8 04 06 00 00       	call   80241f <pageref>
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	39 c7                	cmp    %eax,%edi
  801e20:	0f 94 c2             	sete   %dl
  801e23:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e26:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801e2c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e2f:	39 fb                	cmp    %edi,%ebx
  801e31:	74 19                	je     801e4c <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801e33:	84 d2                	test   %dl,%dl
  801e35:	74 c6                	je     801dfd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e37:	8b 51 58             	mov    0x58(%ecx),%edx
  801e3a:	50                   	push   %eax
  801e3b:	52                   	push   %edx
  801e3c:	53                   	push   %ebx
  801e3d:	68 8b 2d 80 00       	push   $0x802d8b
  801e42:	e8 61 e3 ff ff       	call   8001a8 <cprintf>
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	eb b1                	jmp    801dfd <_pipeisclosed+0xe>
	}
}
  801e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 28             	sub    $0x28,%esp
  801e5d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e60:	56                   	push   %esi
  801e61:	e8 78 f2 ff ff       	call   8010de <fd2data>
  801e66:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	bf 00 00 00 00       	mov    $0x0,%edi
  801e70:	eb 4b                	jmp    801ebd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e72:	89 da                	mov    %ebx,%edx
  801e74:	89 f0                	mov    %esi,%eax
  801e76:	e8 74 ff ff ff       	call   801def <_pipeisclosed>
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	75 48                	jne    801ec7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e7f:	e8 95 ec ff ff       	call   800b19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e84:	8b 43 04             	mov    0x4(%ebx),%eax
  801e87:	8b 0b                	mov    (%ebx),%ecx
  801e89:	8d 51 20             	lea    0x20(%ecx),%edx
  801e8c:	39 d0                	cmp    %edx,%eax
  801e8e:	73 e2                	jae    801e72 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	c1 fa 1f             	sar    $0x1f,%edx
  801e9f:	89 d1                	mov    %edx,%ecx
  801ea1:	c1 e9 1b             	shr    $0x1b,%ecx
  801ea4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ea7:	83 e2 1f             	and    $0x1f,%edx
  801eaa:	29 ca                	sub    %ecx,%edx
  801eac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eb0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eb4:	83 c0 01             	add    $0x1,%eax
  801eb7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eba:	83 c7 01             	add    $0x1,%edi
  801ebd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ec0:	75 c2                	jne    801e84 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec5:	eb 05                	jmp    801ecc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 18             	sub    $0x18,%esp
  801edd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ee0:	57                   	push   %edi
  801ee1:	e8 f8 f1 ff ff       	call   8010de <fd2data>
  801ee6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ef0:	eb 3d                	jmp    801f2f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ef2:	85 db                	test   %ebx,%ebx
  801ef4:	74 04                	je     801efa <devpipe_read+0x26>
				return i;
  801ef6:	89 d8                	mov    %ebx,%eax
  801ef8:	eb 44                	jmp    801f3e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801efa:	89 f2                	mov    %esi,%edx
  801efc:	89 f8                	mov    %edi,%eax
  801efe:	e8 ec fe ff ff       	call   801def <_pipeisclosed>
  801f03:	85 c0                	test   %eax,%eax
  801f05:	75 32                	jne    801f39 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f07:	e8 0d ec ff ff       	call   800b19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f0c:	8b 06                	mov    (%esi),%eax
  801f0e:	3b 46 04             	cmp    0x4(%esi),%eax
  801f11:	74 df                	je     801ef2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f13:	99                   	cltd   
  801f14:	c1 ea 1b             	shr    $0x1b,%edx
  801f17:	01 d0                	add    %edx,%eax
  801f19:	83 e0 1f             	and    $0x1f,%eax
  801f1c:	29 d0                	sub    %edx,%eax
  801f1e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f26:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f29:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2c:	83 c3 01             	add    $0x1,%ebx
  801f2f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f32:	75 d8                	jne    801f0c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f34:	8b 45 10             	mov    0x10(%ebp),%eax
  801f37:	eb 05                	jmp    801f3e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5f                   	pop    %edi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	56                   	push   %esi
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	e8 9e f1 ff ff       	call   8010f5 <fd_alloc>
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	0f 88 2c 01 00 00    	js     802090 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f64:	83 ec 04             	sub    $0x4,%esp
  801f67:	68 07 04 00 00       	push   $0x407
  801f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 c2 eb ff ff       	call   800b38 <sys_page_alloc>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	0f 88 0d 01 00 00    	js     802090 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f83:	83 ec 0c             	sub    $0xc,%esp
  801f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f89:	50                   	push   %eax
  801f8a:	e8 66 f1 ff ff       	call   8010f5 <fd_alloc>
  801f8f:	89 c3                	mov    %eax,%ebx
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	85 c0                	test   %eax,%eax
  801f96:	0f 88 e2 00 00 00    	js     80207e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9c:	83 ec 04             	sub    $0x4,%esp
  801f9f:	68 07 04 00 00       	push   $0x407
  801fa4:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 8a eb ff ff       	call   800b38 <sys_page_alloc>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	0f 88 c3 00 00 00    	js     80207e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc1:	e8 18 f1 ff ff       	call   8010de <fd2data>
  801fc6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc8:	83 c4 0c             	add    $0xc,%esp
  801fcb:	68 07 04 00 00       	push   $0x407
  801fd0:	50                   	push   %eax
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 60 eb ff ff       	call   800b38 <sys_page_alloc>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	0f 88 89 00 00 00    	js     80206e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	ff 75 f0             	pushl  -0x10(%ebp)
  801feb:	e8 ee f0 ff ff       	call   8010de <fd2data>
  801ff0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ff7:	50                   	push   %eax
  801ff8:	6a 00                	push   $0x0
  801ffa:	56                   	push   %esi
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 79 eb ff ff       	call   800b7b <sys_page_map>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	83 c4 20             	add    $0x20,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 55                	js     802060 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80200b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802026:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802029:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80202b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80202e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	ff 75 f4             	pushl  -0xc(%ebp)
  80203b:	e8 8e f0 ff ff       	call   8010ce <fd2num>
  802040:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802043:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802045:	83 c4 04             	add    $0x4,%esp
  802048:	ff 75 f0             	pushl  -0x10(%ebp)
  80204b:	e8 7e f0 ff ff       	call   8010ce <fd2num>
  802050:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802053:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	ba 00 00 00 00       	mov    $0x0,%edx
  80205e:	eb 30                	jmp    802090 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802060:	83 ec 08             	sub    $0x8,%esp
  802063:	56                   	push   %esi
  802064:	6a 00                	push   $0x0
  802066:	e8 52 eb ff ff       	call   800bbd <sys_page_unmap>
  80206b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80206e:	83 ec 08             	sub    $0x8,%esp
  802071:	ff 75 f0             	pushl  -0x10(%ebp)
  802074:	6a 00                	push   $0x0
  802076:	e8 42 eb ff ff       	call   800bbd <sys_page_unmap>
  80207b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80207e:	83 ec 08             	sub    $0x8,%esp
  802081:	ff 75 f4             	pushl  -0xc(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 32 eb ff ff       	call   800bbd <sys_page_unmap>
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802090:	89 d0                	mov    %edx,%eax
  802092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802095:	5b                   	pop    %ebx
  802096:	5e                   	pop    %esi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    

00802099 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a2:	50                   	push   %eax
  8020a3:	ff 75 08             	pushl  0x8(%ebp)
  8020a6:	e8 99 f0 ff ff       	call   801144 <fd_lookup>
  8020ab:	89 c2                	mov    %eax,%edx
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	85 d2                	test   %edx,%edx
  8020b2:	78 18                	js     8020cc <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ba:	e8 1f f0 ff ff       	call   8010de <fd2data>
	return _pipeisclosed(fd, p);
  8020bf:	89 c2                	mov    %eax,%edx
  8020c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c4:	e8 26 fd ff ff       	call   801def <_pipeisclosed>
  8020c9:	83 c4 10             	add    $0x10,%esp
}
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020de:	68 a3 2d 80 00       	push   $0x802da3
  8020e3:	ff 75 0c             	pushl  0xc(%ebp)
  8020e6:	e8 44 e6 ff ff       	call   80072f <strcpy>
	return 0;
}
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f0:	c9                   	leave  
  8020f1:	c3                   	ret    

008020f2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fe:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802103:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802109:	eb 2d                	jmp    802138 <devcons_write+0x46>
		m = n - tot;
  80210b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80210e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802110:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802113:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802118:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80211b:	83 ec 04             	sub    $0x4,%esp
  80211e:	53                   	push   %ebx
  80211f:	03 45 0c             	add    0xc(%ebp),%eax
  802122:	50                   	push   %eax
  802123:	57                   	push   %edi
  802124:	e8 98 e7 ff ff       	call   8008c1 <memmove>
		sys_cputs(buf, m);
  802129:	83 c4 08             	add    $0x8,%esp
  80212c:	53                   	push   %ebx
  80212d:	57                   	push   %edi
  80212e:	e8 49 e9 ff ff       	call   800a7c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802133:	01 de                	add    %ebx,%esi
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	89 f0                	mov    %esi,%eax
  80213a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80213d:	72 cc                	jb     80210b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80213f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802142:	5b                   	pop    %ebx
  802143:	5e                   	pop    %esi
  802144:	5f                   	pop    %edi
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    

00802147 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80214d:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802152:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802156:	75 07                	jne    80215f <devcons_read+0x18>
  802158:	eb 28                	jmp    802182 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80215a:	e8 ba e9 ff ff       	call   800b19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80215f:	e8 36 e9 ff ff       	call   800a9a <sys_cgetc>
  802164:	85 c0                	test   %eax,%eax
  802166:	74 f2                	je     80215a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802168:	85 c0                	test   %eax,%eax
  80216a:	78 16                	js     802182 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80216c:	83 f8 04             	cmp    $0x4,%eax
  80216f:	74 0c                	je     80217d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802171:	8b 55 0c             	mov    0xc(%ebp),%edx
  802174:	88 02                	mov    %al,(%edx)
	return 1;
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	eb 05                	jmp    802182 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80217d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802182:	c9                   	leave  
  802183:	c3                   	ret    

00802184 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80218a:	8b 45 08             	mov    0x8(%ebp),%eax
  80218d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802190:	6a 01                	push   $0x1
  802192:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802195:	50                   	push   %eax
  802196:	e8 e1 e8 ff ff       	call   800a7c <sys_cputs>
  80219b:	83 c4 10             	add    $0x10,%esp
}
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <getchar>:

int
getchar(void)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021a6:	6a 01                	push   $0x1
  8021a8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	6a 00                	push   $0x0
  8021ae:	e8 00 f2 ff ff       	call   8013b3 <read>
	if (r < 0)
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	78 0f                	js     8021c9 <getchar+0x29>
		return r;
	if (r < 1)
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	7e 06                	jle    8021c4 <getchar+0x24>
		return -E_EOF;
	return c;
  8021be:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021c2:	eb 05                	jmp    8021c9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021c4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d4:	50                   	push   %eax
  8021d5:	ff 75 08             	pushl  0x8(%ebp)
  8021d8:	e8 67 ef ff ff       	call   801144 <fd_lookup>
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 11                	js     8021f5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021ed:	39 10                	cmp    %edx,(%eax)
  8021ef:	0f 94 c0             	sete   %al
  8021f2:	0f b6 c0             	movzbl %al,%eax
}
  8021f5:	c9                   	leave  
  8021f6:	c3                   	ret    

008021f7 <opencons>:

int
opencons(void)
{
  8021f7:	55                   	push   %ebp
  8021f8:	89 e5                	mov    %esp,%ebp
  8021fa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802200:	50                   	push   %eax
  802201:	e8 ef ee ff ff       	call   8010f5 <fd_alloc>
  802206:	83 c4 10             	add    $0x10,%esp
		return r;
  802209:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80220b:	85 c0                	test   %eax,%eax
  80220d:	78 3e                	js     80224d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80220f:	83 ec 04             	sub    $0x4,%esp
  802212:	68 07 04 00 00       	push   $0x407
  802217:	ff 75 f4             	pushl  -0xc(%ebp)
  80221a:	6a 00                	push   $0x0
  80221c:	e8 17 e9 ff ff       	call   800b38 <sys_page_alloc>
  802221:	83 c4 10             	add    $0x10,%esp
		return r;
  802224:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802226:	85 c0                	test   %eax,%eax
  802228:	78 23                	js     80224d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80222a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802230:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802233:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80223f:	83 ec 0c             	sub    $0xc,%esp
  802242:	50                   	push   %eax
  802243:	e8 86 ee ff ff       	call   8010ce <fd2num>
  802248:	89 c2                	mov    %eax,%edx
  80224a:	83 c4 10             	add    $0x10,%esp
}
  80224d:	89 d0                	mov    %edx,%eax
  80224f:	c9                   	leave  
  802250:	c3                   	ret    

00802251 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	56                   	push   %esi
  802255:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802256:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802259:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80225f:	e8 96 e8 ff ff       	call   800afa <sys_getenvid>
  802264:	83 ec 0c             	sub    $0xc,%esp
  802267:	ff 75 0c             	pushl  0xc(%ebp)
  80226a:	ff 75 08             	pushl  0x8(%ebp)
  80226d:	56                   	push   %esi
  80226e:	50                   	push   %eax
  80226f:	68 b0 2d 80 00       	push   $0x802db0
  802274:	e8 2f df ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802279:	83 c4 18             	add    $0x18,%esp
  80227c:	53                   	push   %ebx
  80227d:	ff 75 10             	pushl  0x10(%ebp)
  802280:	e8 d2 de ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  802285:	c7 04 24 d4 27 80 00 	movl   $0x8027d4,(%esp)
  80228c:	e8 17 df ff ff       	call   8001a8 <cprintf>
  802291:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802294:	cc                   	int3   
  802295:	eb fd                	jmp    802294 <_panic+0x43>

00802297 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80229d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022a4:	75 2c                	jne    8022d2 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8022a6:	83 ec 04             	sub    $0x4,%esp
  8022a9:	6a 07                	push   $0x7
  8022ab:	68 00 f0 bf ee       	push   $0xeebff000
  8022b0:	6a 00                	push   $0x0
  8022b2:	e8 81 e8 ff ff       	call   800b38 <sys_page_alloc>
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	85 c0                	test   %eax,%eax
  8022bc:	74 14                	je     8022d2 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8022be:	83 ec 04             	sub    $0x4,%esp
  8022c1:	68 d4 2d 80 00       	push   $0x802dd4
  8022c6:	6a 21                	push   $0x21
  8022c8:	68 38 2e 80 00       	push   $0x802e38
  8022cd:	e8 7f ff ff ff       	call   802251 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d5:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8022da:	83 ec 08             	sub    $0x8,%esp
  8022dd:	68 06 23 80 00       	push   $0x802306
  8022e2:	6a 00                	push   $0x0
  8022e4:	e8 9a e9 ff ff       	call   800c83 <sys_env_set_pgfault_upcall>
  8022e9:	83 c4 10             	add    $0x10,%esp
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	79 14                	jns    802304 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8022f0:	83 ec 04             	sub    $0x4,%esp
  8022f3:	68 00 2e 80 00       	push   $0x802e00
  8022f8:	6a 29                	push   $0x29
  8022fa:	68 38 2e 80 00       	push   $0x802e38
  8022ff:	e8 4d ff ff ff       	call   802251 <_panic>
}
  802304:	c9                   	leave  
  802305:	c3                   	ret    

00802306 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802306:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802307:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80230c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80230e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802311:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802316:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80231a:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80231e:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802320:	83 c4 08             	add    $0x8,%esp
        popal
  802323:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802324:	83 c4 04             	add    $0x4,%esp
        popfl
  802327:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802328:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802329:	c3                   	ret    

0080232a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	56                   	push   %esi
  80232e:	53                   	push   %ebx
  80232f:	8b 75 08             	mov    0x8(%ebp),%esi
  802332:	8b 45 0c             	mov    0xc(%ebp),%eax
  802335:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802338:	85 c0                	test   %eax,%eax
  80233a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80233f:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802342:	83 ec 0c             	sub    $0xc,%esp
  802345:	50                   	push   %eax
  802346:	e8 9d e9 ff ff       	call   800ce8 <sys_ipc_recv>
  80234b:	83 c4 10             	add    $0x10,%esp
  80234e:	85 c0                	test   %eax,%eax
  802350:	79 16                	jns    802368 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802352:	85 f6                	test   %esi,%esi
  802354:	74 06                	je     80235c <ipc_recv+0x32>
  802356:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80235c:	85 db                	test   %ebx,%ebx
  80235e:	74 2c                	je     80238c <ipc_recv+0x62>
  802360:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802366:	eb 24                	jmp    80238c <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802368:	85 f6                	test   %esi,%esi
  80236a:	74 0a                	je     802376 <ipc_recv+0x4c>
  80236c:	a1 08 40 80 00       	mov    0x804008,%eax
  802371:	8b 40 74             	mov    0x74(%eax),%eax
  802374:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802376:	85 db                	test   %ebx,%ebx
  802378:	74 0a                	je     802384 <ipc_recv+0x5a>
  80237a:	a1 08 40 80 00       	mov    0x804008,%eax
  80237f:	8b 40 78             	mov    0x78(%eax),%eax
  802382:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802384:	a1 08 40 80 00       	mov    0x804008,%eax
  802389:	8b 40 70             	mov    0x70(%eax),%eax
}
  80238c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238f:	5b                   	pop    %ebx
  802390:	5e                   	pop    %esi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    

00802393 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	57                   	push   %edi
  802397:	56                   	push   %esi
  802398:	53                   	push   %ebx
  802399:	83 ec 0c             	sub    $0xc,%esp
  80239c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80239f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8023a5:	85 db                	test   %ebx,%ebx
  8023a7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023ac:	0f 44 d8             	cmove  %eax,%ebx
  8023af:	eb 1c                	jmp    8023cd <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8023b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023b4:	74 12                	je     8023c8 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8023b6:	50                   	push   %eax
  8023b7:	68 46 2e 80 00       	push   $0x802e46
  8023bc:	6a 39                	push   $0x39
  8023be:	68 61 2e 80 00       	push   $0x802e61
  8023c3:	e8 89 fe ff ff       	call   802251 <_panic>
                 sys_yield();
  8023c8:	e8 4c e7 ff ff       	call   800b19 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8023cd:	ff 75 14             	pushl  0x14(%ebp)
  8023d0:	53                   	push   %ebx
  8023d1:	56                   	push   %esi
  8023d2:	57                   	push   %edi
  8023d3:	e8 ed e8 ff ff       	call   800cc5 <sys_ipc_try_send>
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	78 d2                	js     8023b1 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8023df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e2:	5b                   	pop    %ebx
  8023e3:	5e                   	pop    %esi
  8023e4:	5f                   	pop    %edi
  8023e5:	5d                   	pop    %ebp
  8023e6:	c3                   	ret    

008023e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023e7:	55                   	push   %ebp
  8023e8:	89 e5                	mov    %esp,%ebp
  8023ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023f2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023fb:	8b 52 50             	mov    0x50(%edx),%edx
  8023fe:	39 ca                	cmp    %ecx,%edx
  802400:	75 0d                	jne    80240f <ipc_find_env+0x28>
			return envs[i].env_id;
  802402:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802405:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80240a:	8b 40 08             	mov    0x8(%eax),%eax
  80240d:	eb 0e                	jmp    80241d <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80240f:	83 c0 01             	add    $0x1,%eax
  802412:	3d 00 04 00 00       	cmp    $0x400,%eax
  802417:	75 d9                	jne    8023f2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802419:	66 b8 00 00          	mov    $0x0,%ax
}
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    

0080241f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802425:	89 d0                	mov    %edx,%eax
  802427:	c1 e8 16             	shr    $0x16,%eax
  80242a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802431:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802436:	f6 c1 01             	test   $0x1,%cl
  802439:	74 1d                	je     802458 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80243b:	c1 ea 0c             	shr    $0xc,%edx
  80243e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802445:	f6 c2 01             	test   $0x1,%dl
  802448:	74 0e                	je     802458 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80244a:	c1 ea 0c             	shr    $0xc,%edx
  80244d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802454:	ef 
  802455:	0f b7 c0             	movzwl %ax,%eax
}
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__udivdi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 10             	sub    $0x10,%esp
  802466:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80246a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80246e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802472:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802476:	85 d2                	test   %edx,%edx
  802478:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80247c:	89 34 24             	mov    %esi,(%esp)
  80247f:	89 c8                	mov    %ecx,%eax
  802481:	75 35                	jne    8024b8 <__udivdi3+0x58>
  802483:	39 f1                	cmp    %esi,%ecx
  802485:	0f 87 bd 00 00 00    	ja     802548 <__udivdi3+0xe8>
  80248b:	85 c9                	test   %ecx,%ecx
  80248d:	89 cd                	mov    %ecx,%ebp
  80248f:	75 0b                	jne    80249c <__udivdi3+0x3c>
  802491:	b8 01 00 00 00       	mov    $0x1,%eax
  802496:	31 d2                	xor    %edx,%edx
  802498:	f7 f1                	div    %ecx
  80249a:	89 c5                	mov    %eax,%ebp
  80249c:	89 f0                	mov    %esi,%eax
  80249e:	31 d2                	xor    %edx,%edx
  8024a0:	f7 f5                	div    %ebp
  8024a2:	89 c6                	mov    %eax,%esi
  8024a4:	89 f8                	mov    %edi,%eax
  8024a6:	f7 f5                	div    %ebp
  8024a8:	89 f2                	mov    %esi,%edx
  8024aa:	83 c4 10             	add    $0x10,%esp
  8024ad:	5e                   	pop    %esi
  8024ae:	5f                   	pop    %edi
  8024af:	5d                   	pop    %ebp
  8024b0:	c3                   	ret    
  8024b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	3b 14 24             	cmp    (%esp),%edx
  8024bb:	77 7b                	ja     802538 <__udivdi3+0xd8>
  8024bd:	0f bd f2             	bsr    %edx,%esi
  8024c0:	83 f6 1f             	xor    $0x1f,%esi
  8024c3:	0f 84 97 00 00 00    	je     802560 <__udivdi3+0x100>
  8024c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8024ce:	89 d7                	mov    %edx,%edi
  8024d0:	89 f1                	mov    %esi,%ecx
  8024d2:	29 f5                	sub    %esi,%ebp
  8024d4:	d3 e7                	shl    %cl,%edi
  8024d6:	89 c2                	mov    %eax,%edx
  8024d8:	89 e9                	mov    %ebp,%ecx
  8024da:	d3 ea                	shr    %cl,%edx
  8024dc:	89 f1                	mov    %esi,%ecx
  8024de:	09 fa                	or     %edi,%edx
  8024e0:	8b 3c 24             	mov    (%esp),%edi
  8024e3:	d3 e0                	shl    %cl,%eax
  8024e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024e9:	89 e9                	mov    %ebp,%ecx
  8024eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024f3:	89 fa                	mov    %edi,%edx
  8024f5:	d3 ea                	shr    %cl,%edx
  8024f7:	89 f1                	mov    %esi,%ecx
  8024f9:	d3 e7                	shl    %cl,%edi
  8024fb:	89 e9                	mov    %ebp,%ecx
  8024fd:	d3 e8                	shr    %cl,%eax
  8024ff:	09 c7                	or     %eax,%edi
  802501:	89 f8                	mov    %edi,%eax
  802503:	f7 74 24 08          	divl   0x8(%esp)
  802507:	89 d5                	mov    %edx,%ebp
  802509:	89 c7                	mov    %eax,%edi
  80250b:	f7 64 24 0c          	mull   0xc(%esp)
  80250f:	39 d5                	cmp    %edx,%ebp
  802511:	89 14 24             	mov    %edx,(%esp)
  802514:	72 11                	jb     802527 <__udivdi3+0xc7>
  802516:	8b 54 24 04          	mov    0x4(%esp),%edx
  80251a:	89 f1                	mov    %esi,%ecx
  80251c:	d3 e2                	shl    %cl,%edx
  80251e:	39 c2                	cmp    %eax,%edx
  802520:	73 5e                	jae    802580 <__udivdi3+0x120>
  802522:	3b 2c 24             	cmp    (%esp),%ebp
  802525:	75 59                	jne    802580 <__udivdi3+0x120>
  802527:	8d 47 ff             	lea    -0x1(%edi),%eax
  80252a:	31 f6                	xor    %esi,%esi
  80252c:	89 f2                	mov    %esi,%edx
  80252e:	83 c4 10             	add    $0x10,%esp
  802531:	5e                   	pop    %esi
  802532:	5f                   	pop    %edi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    
  802535:	8d 76 00             	lea    0x0(%esi),%esi
  802538:	31 f6                	xor    %esi,%esi
  80253a:	31 c0                	xor    %eax,%eax
  80253c:	89 f2                	mov    %esi,%edx
  80253e:	83 c4 10             	add    $0x10,%esp
  802541:	5e                   	pop    %esi
  802542:	5f                   	pop    %edi
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    
  802545:	8d 76 00             	lea    0x0(%esi),%esi
  802548:	89 f2                	mov    %esi,%edx
  80254a:	31 f6                	xor    %esi,%esi
  80254c:	89 f8                	mov    %edi,%eax
  80254e:	f7 f1                	div    %ecx
  802550:	89 f2                	mov    %esi,%edx
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802564:	76 0b                	jbe    802571 <__udivdi3+0x111>
  802566:	31 c0                	xor    %eax,%eax
  802568:	3b 14 24             	cmp    (%esp),%edx
  80256b:	0f 83 37 ff ff ff    	jae    8024a8 <__udivdi3+0x48>
  802571:	b8 01 00 00 00       	mov    $0x1,%eax
  802576:	e9 2d ff ff ff       	jmp    8024a8 <__udivdi3+0x48>
  80257b:	90                   	nop
  80257c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 f8                	mov    %edi,%eax
  802582:	31 f6                	xor    %esi,%esi
  802584:	e9 1f ff ff ff       	jmp    8024a8 <__udivdi3+0x48>
  802589:	66 90                	xchg   %ax,%ax
  80258b:	66 90                	xchg   %ax,%ax
  80258d:	66 90                	xchg   %ax,%ax
  80258f:	90                   	nop

00802590 <__umoddi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	83 ec 20             	sub    $0x20,%esp
  802596:	8b 44 24 34          	mov    0x34(%esp),%eax
  80259a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80259e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a2:	89 c6                	mov    %eax,%esi
  8025a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8025b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8025b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8025bc:	85 c0                	test   %eax,%eax
  8025be:	89 c2                	mov    %eax,%edx
  8025c0:	75 1e                	jne    8025e0 <__umoddi3+0x50>
  8025c2:	39 f7                	cmp    %esi,%edi
  8025c4:	76 52                	jbe    802618 <__umoddi3+0x88>
  8025c6:	89 c8                	mov    %ecx,%eax
  8025c8:	89 f2                	mov    %esi,%edx
  8025ca:	f7 f7                	div    %edi
  8025cc:	89 d0                	mov    %edx,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	83 c4 20             	add    $0x20,%esp
  8025d3:	5e                   	pop    %esi
  8025d4:	5f                   	pop    %edi
  8025d5:	5d                   	pop    %ebp
  8025d6:	c3                   	ret    
  8025d7:	89 f6                	mov    %esi,%esi
  8025d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8025e0:	39 f0                	cmp    %esi,%eax
  8025e2:	77 5c                	ja     802640 <__umoddi3+0xb0>
  8025e4:	0f bd e8             	bsr    %eax,%ebp
  8025e7:	83 f5 1f             	xor    $0x1f,%ebp
  8025ea:	75 64                	jne    802650 <__umoddi3+0xc0>
  8025ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8025f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8025f4:	0f 86 f6 00 00 00    	jbe    8026f0 <__umoddi3+0x160>
  8025fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8025fe:	0f 82 ec 00 00 00    	jb     8026f0 <__umoddi3+0x160>
  802604:	8b 44 24 14          	mov    0x14(%esp),%eax
  802608:	8b 54 24 18          	mov    0x18(%esp),%edx
  80260c:	83 c4 20             	add    $0x20,%esp
  80260f:	5e                   	pop    %esi
  802610:	5f                   	pop    %edi
  802611:	5d                   	pop    %ebp
  802612:	c3                   	ret    
  802613:	90                   	nop
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	85 ff                	test   %edi,%edi
  80261a:	89 fd                	mov    %edi,%ebp
  80261c:	75 0b                	jne    802629 <__umoddi3+0x99>
  80261e:	b8 01 00 00 00       	mov    $0x1,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f7                	div    %edi
  802627:	89 c5                	mov    %eax,%ebp
  802629:	8b 44 24 10          	mov    0x10(%esp),%eax
  80262d:	31 d2                	xor    %edx,%edx
  80262f:	f7 f5                	div    %ebp
  802631:	89 c8                	mov    %ecx,%eax
  802633:	f7 f5                	div    %ebp
  802635:	eb 95                	jmp    8025cc <__umoddi3+0x3c>
  802637:	89 f6                	mov    %esi,%esi
  802639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 20             	add    $0x20,%esp
  802647:	5e                   	pop    %esi
  802648:	5f                   	pop    %edi
  802649:	5d                   	pop    %ebp
  80264a:	c3                   	ret    
  80264b:	90                   	nop
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	b8 20 00 00 00       	mov    $0x20,%eax
  802655:	89 e9                	mov    %ebp,%ecx
  802657:	29 e8                	sub    %ebp,%eax
  802659:	d3 e2                	shl    %cl,%edx
  80265b:	89 c7                	mov    %eax,%edi
  80265d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802661:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 c1                	mov    %eax,%ecx
  80266b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80266f:	09 d1                	or     %edx,%ecx
  802671:	89 fa                	mov    %edi,%edx
  802673:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802677:	89 e9                	mov    %ebp,%ecx
  802679:	d3 e0                	shl    %cl,%eax
  80267b:	89 f9                	mov    %edi,%ecx
  80267d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802681:	89 f0                	mov    %esi,%eax
  802683:	d3 e8                	shr    %cl,%eax
  802685:	89 e9                	mov    %ebp,%ecx
  802687:	89 c7                	mov    %eax,%edi
  802689:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80268d:	d3 e6                	shl    %cl,%esi
  80268f:	89 d1                	mov    %edx,%ecx
  802691:	89 fa                	mov    %edi,%edx
  802693:	d3 e8                	shr    %cl,%eax
  802695:	89 e9                	mov    %ebp,%ecx
  802697:	09 f0                	or     %esi,%eax
  802699:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80269d:	f7 74 24 10          	divl   0x10(%esp)
  8026a1:	d3 e6                	shl    %cl,%esi
  8026a3:	89 d1                	mov    %edx,%ecx
  8026a5:	f7 64 24 0c          	mull   0xc(%esp)
  8026a9:	39 d1                	cmp    %edx,%ecx
  8026ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8026af:	89 d7                	mov    %edx,%edi
  8026b1:	89 c6                	mov    %eax,%esi
  8026b3:	72 0a                	jb     8026bf <__umoddi3+0x12f>
  8026b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8026b9:	73 10                	jae    8026cb <__umoddi3+0x13b>
  8026bb:	39 d1                	cmp    %edx,%ecx
  8026bd:	75 0c                	jne    8026cb <__umoddi3+0x13b>
  8026bf:	89 d7                	mov    %edx,%edi
  8026c1:	89 c6                	mov    %eax,%esi
  8026c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8026c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8026cb:	89 ca                	mov    %ecx,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026d3:	29 f0                	sub    %esi,%eax
  8026d5:	19 fa                	sbb    %edi,%edx
  8026d7:	d3 e8                	shr    %cl,%eax
  8026d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8026de:	89 d7                	mov    %edx,%edi
  8026e0:	d3 e7                	shl    %cl,%edi
  8026e2:	89 e9                	mov    %ebp,%ecx
  8026e4:	09 f8                	or     %edi,%eax
  8026e6:	d3 ea                	shr    %cl,%edx
  8026e8:	83 c4 20             	add    $0x20,%esp
  8026eb:	5e                   	pop    %esi
  8026ec:	5f                   	pop    %edi
  8026ed:	5d                   	pop    %ebp
  8026ee:	c3                   	ret    
  8026ef:	90                   	nop
  8026f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026f4:	29 f9                	sub    %edi,%ecx
  8026f6:	19 c6                	sbb    %eax,%esi
  8026f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8026fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802700:	e9 ff fe ff ff       	jmp    802604 <__umoddi3+0x74>
