
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
  80003a:	68 00 22 80 00       	push   $0x802200
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 c2 0d 00 00       	call   800e0b <fork>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 12                	jne    800064 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800052:	83 ec 0c             	sub    $0xc,%esp
  800055:	68 78 22 80 00       	push   $0x802278
  80005a:	e8 49 01 00 00       	call   8001a8 <cprintf>
  80005f:	83 c4 10             	add    $0x10,%esp
		while (1)
			/* do nothing */;
  800062:	eb fe                	jmp    800062 <umain+0x2f>
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 28 22 80 00       	push   $0x802228
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
  800099:	c7 04 24 50 22 80 00 	movl   $0x802250,(%esp)
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
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800101:	e8 f4 10 00 00       	call   8011fa <close_all>
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
  80020b:	e8 40 1d 00 00       	call   801f50 <__udivdi3>
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
  800249:	e8 32 1e 00 00       	call   802080 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
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
  80034d:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
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
  800411:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800418:	85 d2                	test   %edx,%edx
  80041a:	75 18                	jne    800434 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80041c:	50                   	push   %eax
  80041d:	68 b8 22 80 00       	push   $0x8022b8
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
  800435:	68 ed 27 80 00       	push   $0x8027ed
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
  800462:	ba b1 22 80 00       	mov    $0x8022b1,%edx
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
  800ae1:	68 df 25 80 00       	push   $0x8025df
  800ae6:	6a 23                	push   $0x23
  800ae8:	68 fc 25 80 00       	push   $0x8025fc
  800aed:	e8 48 12 00 00       	call   801d3a <_panic>

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
  800b62:	68 df 25 80 00       	push   $0x8025df
  800b67:	6a 23                	push   $0x23
  800b69:	68 fc 25 80 00       	push   $0x8025fc
  800b6e:	e8 c7 11 00 00       	call   801d3a <_panic>

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
  800ba4:	68 df 25 80 00       	push   $0x8025df
  800ba9:	6a 23                	push   $0x23
  800bab:	68 fc 25 80 00       	push   $0x8025fc
  800bb0:	e8 85 11 00 00       	call   801d3a <_panic>

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
  800be6:	68 df 25 80 00       	push   $0x8025df
  800beb:	6a 23                	push   $0x23
  800bed:	68 fc 25 80 00       	push   $0x8025fc
  800bf2:	e8 43 11 00 00       	call   801d3a <_panic>

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
  800c28:	68 df 25 80 00       	push   $0x8025df
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 fc 25 80 00       	push   $0x8025fc
  800c34:	e8 01 11 00 00       	call   801d3a <_panic>
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
  800c6a:	68 df 25 80 00       	push   $0x8025df
  800c6f:	6a 23                	push   $0x23
  800c71:	68 fc 25 80 00       	push   $0x8025fc
  800c76:	e8 bf 10 00 00       	call   801d3a <_panic>

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
  800cac:	68 df 25 80 00       	push   $0x8025df
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 fc 25 80 00       	push   $0x8025fc
  800cb8:	e8 7d 10 00 00       	call   801d3a <_panic>

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
  800d10:	68 df 25 80 00       	push   $0x8025df
  800d15:	6a 23                	push   $0x23
  800d17:	68 fc 25 80 00       	push   $0x8025fc
  800d1c:	e8 19 10 00 00       	call   801d3a <_panic>

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

00800d29 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 04             	sub    $0x4,%esp
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d33:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d35:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d39:	74 2e                	je     800d69 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	c1 ea 16             	shr    $0x16,%edx
  800d40:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d47:	f6 c2 01             	test   $0x1,%dl
  800d4a:	74 1d                	je     800d69 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d4c:	89 c2                	mov    %eax,%edx
  800d4e:	c1 ea 0c             	shr    $0xc,%edx
  800d51:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d58:	f6 c1 01             	test   $0x1,%cl
  800d5b:	74 0c                	je     800d69 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d5d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d64:	f6 c6 08             	test   $0x8,%dh
  800d67:	75 14                	jne    800d7d <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d69:	83 ec 04             	sub    $0x4,%esp
  800d6c:	68 0c 26 80 00       	push   $0x80260c
  800d71:	6a 21                	push   $0x21
  800d73:	68 9f 26 80 00       	push   $0x80269f
  800d78:	e8 bd 0f 00 00       	call   801d3a <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800d7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d82:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	6a 07                	push   $0x7
  800d89:	68 00 f0 7f 00       	push   $0x7ff000
  800d8e:	6a 00                	push   $0x0
  800d90:	e8 a3 fd ff ff       	call   800b38 <sys_page_alloc>
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	79 14                	jns    800db0 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 aa 26 80 00       	push   $0x8026aa
  800da4:	6a 2b                	push   $0x2b
  800da6:	68 9f 26 80 00       	push   $0x80269f
  800dab:	e8 8a 0f 00 00       	call   801d3a <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	68 00 10 00 00       	push   $0x1000
  800db8:	53                   	push   %ebx
  800db9:	68 00 f0 7f 00       	push   $0x7ff000
  800dbe:	e8 fe fa ff ff       	call   8008c1 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800dc3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dca:	53                   	push   %ebx
  800dcb:	6a 00                	push   $0x0
  800dcd:	68 00 f0 7f 00       	push   $0x7ff000
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 a2 fd ff ff       	call   800b7b <sys_page_map>
  800dd9:	83 c4 20             	add    $0x20,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	79 14                	jns    800df4 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	68 c0 26 80 00       	push   $0x8026c0
  800de8:	6a 2e                	push   $0x2e
  800dea:	68 9f 26 80 00       	push   $0x80269f
  800def:	e8 46 0f 00 00       	call   801d3a <_panic>
        sys_page_unmap(0, PFTEMP); 
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	68 00 f0 7f 00       	push   $0x7ff000
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 ba fd ff ff       	call   800bbd <sys_page_unmap>
  800e03:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    

00800e0b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e14:	68 29 0d 80 00       	push   $0x800d29
  800e19:	e8 62 0f 00 00       	call   801d80 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e1e:	b8 07 00 00 00       	mov    $0x7,%eax
  800e23:	cd 30                	int    $0x30
  800e25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	79 12                	jns    800e41 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e2f:	50                   	push   %eax
  800e30:	68 d4 26 80 00       	push   $0x8026d4
  800e35:	6a 6d                	push   $0x6d
  800e37:	68 9f 26 80 00       	push   $0x80269f
  800e3c:	e8 f9 0e 00 00       	call   801d3a <_panic>
  800e41:	89 c7                	mov    %eax,%edi
  800e43:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e4c:	75 21                	jne    800e6f <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e4e:	e8 a7 fc ff ff       	call   800afa <sys_getenvid>
  800e53:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e58:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e60:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6a:	e9 9c 01 00 00       	jmp    80100b <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	c1 e8 16             	shr    $0x16,%eax
  800e74:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7b:	a8 01                	test   $0x1,%al
  800e7d:	0f 84 f3 00 00 00    	je     800f76 <fork+0x16b>
  800e83:	89 d8                	mov    %ebx,%eax
  800e85:	c1 e8 0c             	shr    $0xc,%eax
  800e88:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e8f:	f6 c2 01             	test   $0x1,%dl
  800e92:	0f 84 de 00 00 00    	je     800f76 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800e98:	89 c6                	mov    %eax,%esi
  800e9a:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800e9d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea4:	f6 c6 04             	test   $0x4,%dh
  800ea7:	74 37                	je     800ee0 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800ea9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	25 07 0e 00 00       	and    $0xe07,%eax
  800eb8:	50                   	push   %eax
  800eb9:	56                   	push   %esi
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 b8 fc ff ff       	call   800b7b <sys_page_map>
  800ec3:	83 c4 20             	add    $0x20,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	0f 89 a8 00 00 00    	jns    800f76 <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800ece:	50                   	push   %eax
  800ecf:	68 30 26 80 00       	push   $0x802630
  800ed4:	6a 49                	push   $0x49
  800ed6:	68 9f 26 80 00       	push   $0x80269f
  800edb:	e8 5a 0e 00 00       	call   801d3a <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800ee0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee7:	f6 c6 08             	test   $0x8,%dh
  800eea:	75 0b                	jne    800ef7 <fork+0xec>
  800eec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef3:	a8 02                	test   $0x2,%al
  800ef5:	74 57                	je     800f4e <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800ef7:	83 ec 0c             	sub    $0xc,%esp
  800efa:	68 05 08 00 00       	push   $0x805
  800eff:	56                   	push   %esi
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	6a 00                	push   $0x0
  800f04:	e8 72 fc ff ff       	call   800b7b <sys_page_map>
  800f09:	83 c4 20             	add    $0x20,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	79 12                	jns    800f22 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800f10:	50                   	push   %eax
  800f11:	68 30 26 80 00       	push   $0x802630
  800f16:	6a 4c                	push   $0x4c
  800f18:	68 9f 26 80 00       	push   $0x80269f
  800f1d:	e8 18 0e 00 00       	call   801d3a <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	68 05 08 00 00       	push   $0x805
  800f2a:	56                   	push   %esi
  800f2b:	6a 00                	push   $0x0
  800f2d:	56                   	push   %esi
  800f2e:	6a 00                	push   $0x0
  800f30:	e8 46 fc ff ff       	call   800b7b <sys_page_map>
  800f35:	83 c4 20             	add    $0x20,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 3a                	jns    800f76 <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 54 26 80 00       	push   $0x802654
  800f42:	6a 4e                	push   $0x4e
  800f44:	68 9f 26 80 00       	push   $0x80269f
  800f49:	e8 ec 0d 00 00       	call   801d3a <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	6a 05                	push   $0x5
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	6a 00                	push   $0x0
  800f58:	e8 1e fc ff ff       	call   800b7b <sys_page_map>
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 12                	jns    800f76 <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  800f64:	50                   	push   %eax
  800f65:	68 7c 26 80 00       	push   $0x80267c
  800f6a:	6a 50                	push   $0x50
  800f6c:	68 9f 26 80 00       	push   $0x80269f
  800f71:	e8 c4 0d 00 00       	call   801d3a <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800f76:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f7c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f82:	0f 85 e7 fe ff ff    	jne    800e6f <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	6a 07                	push   $0x7
  800f8d:	68 00 f0 bf ee       	push   $0xeebff000
  800f92:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f95:	e8 9e fb ff ff       	call   800b38 <sys_page_alloc>
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	79 14                	jns    800fb5 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	68 e4 26 80 00       	push   $0x8026e4
  800fa9:	6a 76                	push   $0x76
  800fab:	68 9f 26 80 00       	push   $0x80269f
  800fb0:	e8 85 0d 00 00       	call   801d3a <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	68 ef 1d 80 00       	push   $0x801def
  800fbd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc0:	e8 be fc ff ff       	call   800c83 <sys_env_set_pgfault_upcall>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 14                	jns    800fe0 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  800fcc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fcf:	68 fe 26 80 00       	push   $0x8026fe
  800fd4:	6a 79                	push   $0x79
  800fd6:	68 9f 26 80 00       	push   $0x80269f
  800fdb:	e8 5a 0d 00 00       	call   801d3a <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	6a 02                	push   $0x2
  800fe5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe8:	e8 12 fc ff ff       	call   800bff <sys_env_set_status>
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	79 14                	jns    801008 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	68 1b 27 80 00       	push   $0x80271b
  800ffc:	6a 7b                	push   $0x7b
  800ffe:	68 9f 26 80 00       	push   $0x80269f
  801003:	e8 32 0d 00 00       	call   801d3a <_panic>
        return forkid;
  801008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80100b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sfork>:

// Challenge!
int
sfork(void)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801019:	68 32 27 80 00       	push   $0x802732
  80101e:	68 83 00 00 00       	push   $0x83
  801023:	68 9f 26 80 00       	push   $0x80269f
  801028:	e8 0d 0d 00 00       	call   801d3a <_panic>

0080102d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	05 00 00 00 30       	add    $0x30000000,%eax
  801038:	c1 e8 0c             	shr    $0xc,%eax
}
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801040:	8b 45 08             	mov    0x8(%ebp),%eax
  801043:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801048:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80104d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80105f:	89 c2                	mov    %eax,%edx
  801061:	c1 ea 16             	shr    $0x16,%edx
  801064:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106b:	f6 c2 01             	test   $0x1,%dl
  80106e:	74 11                	je     801081 <fd_alloc+0x2d>
  801070:	89 c2                	mov    %eax,%edx
  801072:	c1 ea 0c             	shr    $0xc,%edx
  801075:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107c:	f6 c2 01             	test   $0x1,%dl
  80107f:	75 09                	jne    80108a <fd_alloc+0x36>
			*fd_store = fd;
  801081:	89 01                	mov    %eax,(%ecx)
			return 0;
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
  801088:	eb 17                	jmp    8010a1 <fd_alloc+0x4d>
  80108a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80108f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801094:	75 c9                	jne    80105f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801096:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010a9:	83 f8 1f             	cmp    $0x1f,%eax
  8010ac:	77 36                	ja     8010e4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ae:	c1 e0 0c             	shl    $0xc,%eax
  8010b1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b6:	89 c2                	mov    %eax,%edx
  8010b8:	c1 ea 16             	shr    $0x16,%edx
  8010bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c2:	f6 c2 01             	test   $0x1,%dl
  8010c5:	74 24                	je     8010eb <fd_lookup+0x48>
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	c1 ea 0c             	shr    $0xc,%edx
  8010cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d3:	f6 c2 01             	test   $0x1,%dl
  8010d6:	74 1a                	je     8010f2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010db:	89 02                	mov    %eax,(%edx)
	return 0;
  8010dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e2:	eb 13                	jmp    8010f7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e9:	eb 0c                	jmp    8010f7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f0:	eb 05                	jmp    8010f7 <fd_lookup+0x54>
  8010f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801102:	ba c4 27 80 00       	mov    $0x8027c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801107:	eb 13                	jmp    80111c <dev_lookup+0x23>
  801109:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80110c:	39 08                	cmp    %ecx,(%eax)
  80110e:	75 0c                	jne    80111c <dev_lookup+0x23>
			*dev = devtab[i];
  801110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801113:	89 01                	mov    %eax,(%ecx)
			return 0;
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
  80111a:	eb 2e                	jmp    80114a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111c:	8b 02                	mov    (%edx),%eax
  80111e:	85 c0                	test   %eax,%eax
  801120:	75 e7                	jne    801109 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801122:	a1 04 40 80 00       	mov    0x804004,%eax
  801127:	8b 40 48             	mov    0x48(%eax),%eax
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	51                   	push   %ecx
  80112e:	50                   	push   %eax
  80112f:	68 48 27 80 00       	push   $0x802748
  801134:	e8 6f f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801139:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 10             	sub    $0x10,%esp
  801154:	8b 75 08             	mov    0x8(%ebp),%esi
  801157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801164:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801167:	50                   	push   %eax
  801168:	e8 36 ff ff ff       	call   8010a3 <fd_lookup>
  80116d:	83 c4 08             	add    $0x8,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	78 05                	js     801179 <fd_close+0x2d>
	    || fd != fd2)
  801174:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801177:	74 0c                	je     801185 <fd_close+0x39>
		return (must_exist ? r : 0);
  801179:	84 db                	test   %bl,%bl
  80117b:	ba 00 00 00 00       	mov    $0x0,%edx
  801180:	0f 44 c2             	cmove  %edx,%eax
  801183:	eb 41                	jmp    8011c6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	ff 36                	pushl  (%esi)
  80118e:	e8 66 ff ff ff       	call   8010f9 <dev_lookup>
  801193:	89 c3                	mov    %eax,%ebx
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 1a                	js     8011b6 <fd_close+0x6a>
		if (dev->dev_close)
  80119c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011a2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	74 0b                	je     8011b6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	56                   	push   %esi
  8011af:	ff d0                	call   *%eax
  8011b1:	89 c3                	mov    %eax,%ebx
  8011b3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	56                   	push   %esi
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 fc f9 ff ff       	call   800bbd <sys_page_unmap>
	return r;
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	89 d8                	mov    %ebx,%eax
}
  8011c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d6:	50                   	push   %eax
  8011d7:	ff 75 08             	pushl  0x8(%ebp)
  8011da:	e8 c4 fe ff ff       	call   8010a3 <fd_lookup>
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	78 10                	js     8011f8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	6a 01                	push   $0x1
  8011ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f0:	e8 57 ff ff ff       	call   80114c <fd_close>
  8011f5:	83 c4 10             	add    $0x10,%esp
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <close_all>:

void
close_all(void)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801201:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	53                   	push   %ebx
  80120a:	e8 be ff ff ff       	call   8011cd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80120f:	83 c3 01             	add    $0x1,%ebx
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	83 fb 20             	cmp    $0x20,%ebx
  801218:	75 ec                	jne    801206 <close_all+0xc>
		close(i);
}
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 2c             	sub    $0x2c,%esp
  801228:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 6c fe ff ff       	call   8010a3 <fd_lookup>
  801237:	89 c2                	mov    %eax,%edx
  801239:	83 c4 08             	add    $0x8,%esp
  80123c:	85 d2                	test   %edx,%edx
  80123e:	0f 88 c1 00 00 00    	js     801305 <dup+0xe6>
		return r;
	close(newfdnum);
  801244:	83 ec 0c             	sub    $0xc,%esp
  801247:	56                   	push   %esi
  801248:	e8 80 ff ff ff       	call   8011cd <close>

	newfd = INDEX2FD(newfdnum);
  80124d:	89 f3                	mov    %esi,%ebx
  80124f:	c1 e3 0c             	shl    $0xc,%ebx
  801252:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801258:	83 c4 04             	add    $0x4,%esp
  80125b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125e:	e8 da fd ff ff       	call   80103d <fd2data>
  801263:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801265:	89 1c 24             	mov    %ebx,(%esp)
  801268:	e8 d0 fd ff ff       	call   80103d <fd2data>
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801273:	89 f8                	mov    %edi,%eax
  801275:	c1 e8 16             	shr    $0x16,%eax
  801278:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127f:	a8 01                	test   $0x1,%al
  801281:	74 37                	je     8012ba <dup+0x9b>
  801283:	89 f8                	mov    %edi,%eax
  801285:	c1 e8 0c             	shr    $0xc,%eax
  801288:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 26                	je     8012ba <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801294:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80129b:	83 ec 0c             	sub    $0xc,%esp
  80129e:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a3:	50                   	push   %eax
  8012a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a7:	6a 00                	push   $0x0
  8012a9:	57                   	push   %edi
  8012aa:	6a 00                	push   $0x0
  8012ac:	e8 ca f8 ff ff       	call   800b7b <sys_page_map>
  8012b1:	89 c7                	mov    %eax,%edi
  8012b3:	83 c4 20             	add    $0x20,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 2e                	js     8012e8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012bd:	89 d0                	mov    %edx,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
  8012c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c9:	83 ec 0c             	sub    $0xc,%esp
  8012cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d1:	50                   	push   %eax
  8012d2:	53                   	push   %ebx
  8012d3:	6a 00                	push   $0x0
  8012d5:	52                   	push   %edx
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 9e f8 ff ff       	call   800b7b <sys_page_map>
  8012dd:	89 c7                	mov    %eax,%edi
  8012df:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012e2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e4:	85 ff                	test   %edi,%edi
  8012e6:	79 1d                	jns    801305 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 ca f8 ff ff       	call   800bbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f3:	83 c4 08             	add    $0x8,%esp
  8012f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 bd f8 ff ff       	call   800bbd <sys_page_unmap>
	return r;
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	89 f8                	mov    %edi,%eax
}
  801305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801308:	5b                   	pop    %ebx
  801309:	5e                   	pop    %esi
  80130a:	5f                   	pop    %edi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	53                   	push   %ebx
  801311:	83 ec 14             	sub    $0x14,%esp
  801314:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801317:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	53                   	push   %ebx
  80131c:	e8 82 fd ff ff       	call   8010a3 <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	89 c2                	mov    %eax,%edx
  801326:	85 c0                	test   %eax,%eax
  801328:	78 6d                	js     801397 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	ff 30                	pushl  (%eax)
  801336:	e8 be fd ff ff       	call   8010f9 <dev_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 4c                	js     80138e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801342:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801345:	8b 42 08             	mov    0x8(%edx),%eax
  801348:	83 e0 03             	and    $0x3,%eax
  80134b:	83 f8 01             	cmp    $0x1,%eax
  80134e:	75 21                	jne    801371 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801350:	a1 04 40 80 00       	mov    0x804004,%eax
  801355:	8b 40 48             	mov    0x48(%eax),%eax
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	53                   	push   %ebx
  80135c:	50                   	push   %eax
  80135d:	68 89 27 80 00       	push   $0x802789
  801362:	e8 41 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136f:	eb 26                	jmp    801397 <read+0x8a>
	}
	if (!dev->dev_read)
  801371:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801374:	8b 40 08             	mov    0x8(%eax),%eax
  801377:	85 c0                	test   %eax,%eax
  801379:	74 17                	je     801392 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80137b:	83 ec 04             	sub    $0x4,%esp
  80137e:	ff 75 10             	pushl  0x10(%ebp)
  801381:	ff 75 0c             	pushl  0xc(%ebp)
  801384:	52                   	push   %edx
  801385:	ff d0                	call   *%eax
  801387:	89 c2                	mov    %eax,%edx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	eb 09                	jmp    801397 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138e:	89 c2                	mov    %eax,%edx
  801390:	eb 05                	jmp    801397 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801392:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801397:	89 d0                	mov    %edx,%eax
  801399:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b2:	eb 21                	jmp    8013d5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	89 f0                	mov    %esi,%eax
  8013b9:	29 d8                	sub    %ebx,%eax
  8013bb:	50                   	push   %eax
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	03 45 0c             	add    0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	57                   	push   %edi
  8013c3:	e8 45 ff ff ff       	call   80130d <read>
		if (m < 0)
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 0c                	js     8013db <readn+0x3d>
			return m;
		if (m == 0)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	74 06                	je     8013d9 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d3:	01 c3                	add    %eax,%ebx
  8013d5:	39 f3                	cmp    %esi,%ebx
  8013d7:	72 db                	jb     8013b4 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8013d9:	89 d8                	mov    %ebx,%eax
}
  8013db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 14             	sub    $0x14,%esp
  8013ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f0:	50                   	push   %eax
  8013f1:	53                   	push   %ebx
  8013f2:	e8 ac fc ff ff       	call   8010a3 <fd_lookup>
  8013f7:	83 c4 08             	add    $0x8,%esp
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 68                	js     801468 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801406:	50                   	push   %eax
  801407:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140a:	ff 30                	pushl  (%eax)
  80140c:	e8 e8 fc ff ff       	call   8010f9 <dev_lookup>
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 47                	js     80145f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801418:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80141f:	75 21                	jne    801442 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801421:	a1 04 40 80 00       	mov    0x804004,%eax
  801426:	8b 40 48             	mov    0x48(%eax),%eax
  801429:	83 ec 04             	sub    $0x4,%esp
  80142c:	53                   	push   %ebx
  80142d:	50                   	push   %eax
  80142e:	68 a5 27 80 00       	push   $0x8027a5
  801433:	e8 70 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801440:	eb 26                	jmp    801468 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801442:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801445:	8b 52 0c             	mov    0xc(%edx),%edx
  801448:	85 d2                	test   %edx,%edx
  80144a:	74 17                	je     801463 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	ff 75 10             	pushl  0x10(%ebp)
  801452:	ff 75 0c             	pushl  0xc(%ebp)
  801455:	50                   	push   %eax
  801456:	ff d2                	call   *%edx
  801458:	89 c2                	mov    %eax,%edx
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	eb 09                	jmp    801468 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	89 c2                	mov    %eax,%edx
  801461:	eb 05                	jmp    801468 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801463:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801468:	89 d0                	mov    %edx,%eax
  80146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <seek>:

int
seek(int fdnum, off_t offset)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801475:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	ff 75 08             	pushl  0x8(%ebp)
  80147c:	e8 22 fc ff ff       	call   8010a3 <fd_lookup>
  801481:	83 c4 08             	add    $0x8,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 0e                	js     801496 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801488:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801491:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 14             	sub    $0x14,%esp
  80149f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	53                   	push   %ebx
  8014a7:	e8 f7 fb ff ff       	call   8010a3 <fd_lookup>
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 65                	js     80151a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bf:	ff 30                	pushl  (%eax)
  8014c1:	e8 33 fc ff ff       	call   8010f9 <dev_lookup>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 44                	js     801511 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d4:	75 21                	jne    8014f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014db:	8b 40 48             	mov    0x48(%eax),%eax
  8014de:	83 ec 04             	sub    $0x4,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	50                   	push   %eax
  8014e3:	68 68 27 80 00       	push   $0x802768
  8014e8:	e8 bb ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f5:	eb 23                	jmp    80151a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fa:	8b 52 18             	mov    0x18(%edx),%edx
  8014fd:	85 d2                	test   %edx,%edx
  8014ff:	74 14                	je     801515 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	50                   	push   %eax
  801508:	ff d2                	call   *%edx
  80150a:	89 c2                	mov    %eax,%edx
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	eb 09                	jmp    80151a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801511:	89 c2                	mov    %eax,%edx
  801513:	eb 05                	jmp    80151a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801515:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80151a:	89 d0                	mov    %edx,%eax
  80151c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 14             	sub    $0x14,%esp
  801528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	ff 75 08             	pushl  0x8(%ebp)
  801532:	e8 6c fb ff ff       	call   8010a3 <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 58                	js     801598 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 a8 fb ff ff       	call   8010f9 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 37                	js     80158f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80155f:	74 32                	je     801593 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801561:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801564:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156b:	00 00 00 
	stat->st_isdir = 0;
  80156e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801575:	00 00 00 
	stat->st_dev = dev;
  801578:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	53                   	push   %ebx
  801582:	ff 75 f0             	pushl  -0x10(%ebp)
  801585:	ff 50 14             	call   *0x14(%eax)
  801588:	89 c2                	mov    %eax,%edx
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	eb 09                	jmp    801598 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	89 c2                	mov    %eax,%edx
  801591:	eb 05                	jmp    801598 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801593:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801598:	89 d0                	mov    %edx,%eax
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	56                   	push   %esi
  8015a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	6a 00                	push   $0x0
  8015a9:	ff 75 08             	pushl  0x8(%ebp)
  8015ac:	e8 09 02 00 00       	call   8017ba <open>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	85 db                	test   %ebx,%ebx
  8015b8:	78 1b                	js     8015d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	53                   	push   %ebx
  8015c1:	e8 5b ff ff ff       	call   801521 <fstat>
  8015c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8015c8:	89 1c 24             	mov    %ebx,(%esp)
  8015cb:	e8 fd fb ff ff       	call   8011cd <close>
	return r;
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	89 f0                	mov    %esi,%eax
}
  8015d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	89 c6                	mov    %eax,%esi
  8015e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015ec:	75 12                	jne    801600 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	6a 01                	push   $0x1
  8015f3:	e8 d8 08 00 00       	call   801ed0 <ipc_find_env>
  8015f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8015fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801600:	6a 07                	push   $0x7
  801602:	68 00 50 80 00       	push   $0x805000
  801607:	56                   	push   %esi
  801608:	ff 35 00 40 80 00    	pushl  0x804000
  80160e:	e8 69 08 00 00       	call   801e7c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801613:	83 c4 0c             	add    $0xc,%esp
  801616:	6a 00                	push   $0x0
  801618:	53                   	push   %ebx
  801619:	6a 00                	push   $0x0
  80161b:	e8 f3 07 00 00       	call   801e13 <ipc_recv>
}
  801620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80162d:	8b 45 08             	mov    0x8(%ebp),%eax
  801630:	8b 40 0c             	mov    0xc(%eax),%eax
  801633:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801640:	ba 00 00 00 00       	mov    $0x0,%edx
  801645:	b8 02 00 00 00       	mov    $0x2,%eax
  80164a:	e8 8d ff ff ff       	call   8015dc <fsipc>
}
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801657:	8b 45 08             	mov    0x8(%ebp),%eax
  80165a:	8b 40 0c             	mov    0xc(%eax),%eax
  80165d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	b8 06 00 00 00       	mov    $0x6,%eax
  80166c:	e8 6b ff ff ff       	call   8015dc <fsipc>
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	8b 40 0c             	mov    0xc(%eax),%eax
  801683:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801688:	ba 00 00 00 00       	mov    $0x0,%edx
  80168d:	b8 05 00 00 00       	mov    $0x5,%eax
  801692:	e8 45 ff ff ff       	call   8015dc <fsipc>
  801697:	89 c2                	mov    %eax,%edx
  801699:	85 d2                	test   %edx,%edx
  80169b:	78 2c                	js     8016c9 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	68 00 50 80 00       	push   $0x805000
  8016a5:	53                   	push   %ebx
  8016a6:	e8 84 f0 ff ff       	call   80072f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8016bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	57                   	push   %edi
  8016d2:	56                   	push   %esi
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e0:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8016e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8016e8:	eb 3d                	jmp    801727 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8016ea:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8016f0:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8016f5:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8016f8:	83 ec 04             	sub    $0x4,%esp
  8016fb:	57                   	push   %edi
  8016fc:	53                   	push   %ebx
  8016fd:	68 08 50 80 00       	push   $0x805008
  801702:	e8 ba f1 ff ff       	call   8008c1 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801707:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
  801712:	b8 04 00 00 00       	mov    $0x4,%eax
  801717:	e8 c0 fe ff ff       	call   8015dc <fsipc>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 0d                	js     801730 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801723:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801725:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801727:	85 f6                	test   %esi,%esi
  801729:	75 bf                	jne    8016ea <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80172b:	89 d8                	mov    %ebx,%eax
  80172d:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801730:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5f                   	pop    %edi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801740:	8b 45 08             	mov    0x8(%ebp),%eax
  801743:	8b 40 0c             	mov    0xc(%eax),%eax
  801746:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80174b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	b8 03 00 00 00       	mov    $0x3,%eax
  80175b:	e8 7c fe ff ff       	call   8015dc <fsipc>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	85 c0                	test   %eax,%eax
  801764:	78 4b                	js     8017b1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801766:	39 c6                	cmp    %eax,%esi
  801768:	73 16                	jae    801780 <devfile_read+0x48>
  80176a:	68 d4 27 80 00       	push   $0x8027d4
  80176f:	68 db 27 80 00       	push   $0x8027db
  801774:	6a 7c                	push   $0x7c
  801776:	68 f0 27 80 00       	push   $0x8027f0
  80177b:	e8 ba 05 00 00       	call   801d3a <_panic>
	assert(r <= PGSIZE);
  801780:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801785:	7e 16                	jle    80179d <devfile_read+0x65>
  801787:	68 fb 27 80 00       	push   $0x8027fb
  80178c:	68 db 27 80 00       	push   $0x8027db
  801791:	6a 7d                	push   $0x7d
  801793:	68 f0 27 80 00       	push   $0x8027f0
  801798:	e8 9d 05 00 00       	call   801d3a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	50                   	push   %eax
  8017a1:	68 00 50 80 00       	push   $0x805000
  8017a6:	ff 75 0c             	pushl  0xc(%ebp)
  8017a9:	e8 13 f1 ff ff       	call   8008c1 <memmove>
	return r;
  8017ae:	83 c4 10             	add    $0x10,%esp
}
  8017b1:	89 d8                	mov    %ebx,%eax
  8017b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b6:	5b                   	pop    %ebx
  8017b7:	5e                   	pop    %esi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 20             	sub    $0x20,%esp
  8017c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c4:	53                   	push   %ebx
  8017c5:	e8 2c ef ff ff       	call   8006f6 <strlen>
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d2:	7f 67                	jg     80183b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017da:	50                   	push   %eax
  8017db:	e8 74 f8 ff ff       	call   801054 <fd_alloc>
  8017e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 57                	js     801840 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	53                   	push   %ebx
  8017ed:	68 00 50 80 00       	push   $0x805000
  8017f2:	e8 38 ef ff ff       	call   80072f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fa:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801802:	b8 01 00 00 00       	mov    $0x1,%eax
  801807:	e8 d0 fd ff ff       	call   8015dc <fsipc>
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	85 c0                	test   %eax,%eax
  801813:	79 14                	jns    801829 <open+0x6f>
		fd_close(fd, 0);
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	6a 00                	push   $0x0
  80181a:	ff 75 f4             	pushl  -0xc(%ebp)
  80181d:	e8 2a f9 ff ff       	call   80114c <fd_close>
		return r;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	89 da                	mov    %ebx,%edx
  801827:	eb 17                	jmp    801840 <open+0x86>
	}

	return fd2num(fd);
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	ff 75 f4             	pushl  -0xc(%ebp)
  80182f:	e8 f9 f7 ff ff       	call   80102d <fd2num>
  801834:	89 c2                	mov    %eax,%edx
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	eb 05                	jmp    801840 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80183b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801840:	89 d0                	mov    %edx,%eax
  801842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 08 00 00 00       	mov    $0x8,%eax
  801857:	e8 80 fd ff ff       	call   8015dc <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	ff 75 08             	pushl  0x8(%ebp)
  80186c:	e8 cc f7 ff ff       	call   80103d <fd2data>
  801871:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801873:	83 c4 08             	add    $0x8,%esp
  801876:	68 07 28 80 00       	push   $0x802807
  80187b:	53                   	push   %ebx
  80187c:	e8 ae ee ff ff       	call   80072f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801881:	8b 56 04             	mov    0x4(%esi),%edx
  801884:	89 d0                	mov    %edx,%eax
  801886:	2b 06                	sub    (%esi),%eax
  801888:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80188e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801895:	00 00 00 
	stat->st_dev = &devpipe;
  801898:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80189f:	30 80 00 
	return 0;
}
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 0c             	sub    $0xc,%esp
  8018b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b8:	53                   	push   %ebx
  8018b9:	6a 00                	push   $0x0
  8018bb:	e8 fd f2 ff ff       	call   800bbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018c0:	89 1c 24             	mov    %ebx,(%esp)
  8018c3:	e8 75 f7 ff ff       	call   80103d <fd2data>
  8018c8:	83 c4 08             	add    $0x8,%esp
  8018cb:	50                   	push   %eax
  8018cc:	6a 00                	push   $0x0
  8018ce:	e8 ea f2 ff ff       	call   800bbd <sys_page_unmap>
}
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	57                   	push   %edi
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	83 ec 1c             	sub    $0x1c,%esp
  8018e1:	89 c6                	mov    %eax,%esi
  8018e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8018eb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	56                   	push   %esi
  8018f2:	e8 11 06 00 00       	call   801f08 <pageref>
  8018f7:	89 c7                	mov    %eax,%edi
  8018f9:	83 c4 04             	add    $0x4,%esp
  8018fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ff:	e8 04 06 00 00       	call   801f08 <pageref>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	39 c7                	cmp    %eax,%edi
  801909:	0f 94 c2             	sete   %dl
  80190c:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80190f:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801915:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801918:	39 fb                	cmp    %edi,%ebx
  80191a:	74 19                	je     801935 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80191c:	84 d2                	test   %dl,%dl
  80191e:	74 c6                	je     8018e6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801920:	8b 51 58             	mov    0x58(%ecx),%edx
  801923:	50                   	push   %eax
  801924:	52                   	push   %edx
  801925:	53                   	push   %ebx
  801926:	68 0e 28 80 00       	push   $0x80280e
  80192b:	e8 78 e8 ff ff       	call   8001a8 <cprintf>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	eb b1                	jmp    8018e6 <_pipeisclosed+0xe>
	}
}
  801935:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5f                   	pop    %edi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	57                   	push   %edi
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	83 ec 28             	sub    $0x28,%esp
  801946:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801949:	56                   	push   %esi
  80194a:	e8 ee f6 ff ff       	call   80103d <fd2data>
  80194f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	bf 00 00 00 00       	mov    $0x0,%edi
  801959:	eb 4b                	jmp    8019a6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195b:	89 da                	mov    %ebx,%edx
  80195d:	89 f0                	mov    %esi,%eax
  80195f:	e8 74 ff ff ff       	call   8018d8 <_pipeisclosed>
  801964:	85 c0                	test   %eax,%eax
  801966:	75 48                	jne    8019b0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801968:	e8 ac f1 ff ff       	call   800b19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196d:	8b 43 04             	mov    0x4(%ebx),%eax
  801970:	8b 0b                	mov    (%ebx),%ecx
  801972:	8d 51 20             	lea    0x20(%ecx),%edx
  801975:	39 d0                	cmp    %edx,%eax
  801977:	73 e2                	jae    80195b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801980:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801983:	89 c2                	mov    %eax,%edx
  801985:	c1 fa 1f             	sar    $0x1f,%edx
  801988:	89 d1                	mov    %edx,%ecx
  80198a:	c1 e9 1b             	shr    $0x1b,%ecx
  80198d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801990:	83 e2 1f             	and    $0x1f,%edx
  801993:	29 ca                	sub    %ecx,%edx
  801995:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801999:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80199d:	83 c0 01             	add    $0x1,%eax
  8019a0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a3:	83 c7 01             	add    $0x1,%edi
  8019a6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019a9:	75 c2                	jne    80196d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ae:	eb 05                	jmp    8019b5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	57                   	push   %edi
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 18             	sub    $0x18,%esp
  8019c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019c9:	57                   	push   %edi
  8019ca:	e8 6e f6 ff ff       	call   80103d <fd2data>
  8019cf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d9:	eb 3d                	jmp    801a18 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019db:	85 db                	test   %ebx,%ebx
  8019dd:	74 04                	je     8019e3 <devpipe_read+0x26>
				return i;
  8019df:	89 d8                	mov    %ebx,%eax
  8019e1:	eb 44                	jmp    801a27 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e3:	89 f2                	mov    %esi,%edx
  8019e5:	89 f8                	mov    %edi,%eax
  8019e7:	e8 ec fe ff ff       	call   8018d8 <_pipeisclosed>
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	75 32                	jne    801a22 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019f0:	e8 24 f1 ff ff       	call   800b19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f5:	8b 06                	mov    (%esi),%eax
  8019f7:	3b 46 04             	cmp    0x4(%esi),%eax
  8019fa:	74 df                	je     8019db <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019fc:	99                   	cltd   
  8019fd:	c1 ea 1b             	shr    $0x1b,%edx
  801a00:	01 d0                	add    %edx,%eax
  801a02:	83 e0 1f             	and    $0x1f,%eax
  801a05:	29 d0                	sub    %edx,%eax
  801a07:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a12:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a15:	83 c3 01             	add    $0x1,%ebx
  801a18:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a1b:	75 d8                	jne    8019f5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a1d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a20:	eb 05                	jmp    801a27 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a22:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5f                   	pop    %edi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3a:	50                   	push   %eax
  801a3b:	e8 14 f6 ff ff       	call   801054 <fd_alloc>
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	85 c0                	test   %eax,%eax
  801a47:	0f 88 2c 01 00 00    	js     801b79 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4d:	83 ec 04             	sub    $0x4,%esp
  801a50:	68 07 04 00 00       	push   $0x407
  801a55:	ff 75 f4             	pushl  -0xc(%ebp)
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 d9 f0 ff ff       	call   800b38 <sys_page_alloc>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	89 c2                	mov    %eax,%edx
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 0d 01 00 00    	js     801b79 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a72:	50                   	push   %eax
  801a73:	e8 dc f5 ff ff       	call   801054 <fd_alloc>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	0f 88 e2 00 00 00    	js     801b67 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	68 07 04 00 00       	push   $0x407
  801a8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a90:	6a 00                	push   $0x0
  801a92:	e8 a1 f0 ff ff       	call   800b38 <sys_page_alloc>
  801a97:	89 c3                	mov    %eax,%ebx
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	0f 88 c3 00 00 00    	js     801b67 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aaa:	e8 8e f5 ff ff       	call   80103d <fd2data>
  801aaf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab1:	83 c4 0c             	add    $0xc,%esp
  801ab4:	68 07 04 00 00       	push   $0x407
  801ab9:	50                   	push   %eax
  801aba:	6a 00                	push   $0x0
  801abc:	e8 77 f0 ff ff       	call   800b38 <sys_page_alloc>
  801ac1:	89 c3                	mov    %eax,%ebx
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	0f 88 89 00 00 00    	js     801b57 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad4:	e8 64 f5 ff ff       	call   80103d <fd2data>
  801ad9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ae0:	50                   	push   %eax
  801ae1:	6a 00                	push   $0x0
  801ae3:	56                   	push   %esi
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 90 f0 ff ff       	call   800b7b <sys_page_map>
  801aeb:	89 c3                	mov    %eax,%ebx
  801aed:	83 c4 20             	add    $0x20,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 55                	js     801b49 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b02:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b12:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b17:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	ff 75 f4             	pushl  -0xc(%ebp)
  801b24:	e8 04 f5 ff ff       	call   80102d <fd2num>
  801b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b2e:	83 c4 04             	add    $0x4,%esp
  801b31:	ff 75 f0             	pushl  -0x10(%ebp)
  801b34:	e8 f4 f4 ff ff       	call   80102d <fd2num>
  801b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	ba 00 00 00 00       	mov    $0x0,%edx
  801b47:	eb 30                	jmp    801b79 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b49:	83 ec 08             	sub    $0x8,%esp
  801b4c:	56                   	push   %esi
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 69 f0 ff ff       	call   800bbd <sys_page_unmap>
  801b54:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5d:	6a 00                	push   $0x0
  801b5f:	e8 59 f0 ff ff       	call   800bbd <sys_page_unmap>
  801b64:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6d:	6a 00                	push   $0x0
  801b6f:	e8 49 f0 ff ff       	call   800bbd <sys_page_unmap>
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b79:	89 d0                	mov    %edx,%eax
  801b7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7e:	5b                   	pop    %ebx
  801b7f:	5e                   	pop    %esi
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8b:	50                   	push   %eax
  801b8c:	ff 75 08             	pushl  0x8(%ebp)
  801b8f:	e8 0f f5 ff ff       	call   8010a3 <fd_lookup>
  801b94:	89 c2                	mov    %eax,%edx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 d2                	test   %edx,%edx
  801b9b:	78 18                	js     801bb5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba3:	e8 95 f4 ff ff       	call   80103d <fd2data>
	return _pipeisclosed(fd, p);
  801ba8:	89 c2                	mov    %eax,%edx
  801baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bad:	e8 26 fd ff ff       	call   8018d8 <_pipeisclosed>
  801bb2:	83 c4 10             	add    $0x10,%esp
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc7:	68 26 28 80 00       	push   $0x802826
  801bcc:	ff 75 0c             	pushl  0xc(%ebp)
  801bcf:	e8 5b eb ff ff       	call   80072f <strcpy>
	return 0;
}
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bec:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf2:	eb 2d                	jmp    801c21 <devcons_write+0x46>
		m = n - tot;
  801bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bf7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bf9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bfc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c01:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	53                   	push   %ebx
  801c08:	03 45 0c             	add    0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	57                   	push   %edi
  801c0d:	e8 af ec ff ff       	call   8008c1 <memmove>
		sys_cputs(buf, m);
  801c12:	83 c4 08             	add    $0x8,%esp
  801c15:	53                   	push   %ebx
  801c16:	57                   	push   %edi
  801c17:	e8 60 ee ff ff       	call   800a7c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1c:	01 de                	add    %ebx,%esi
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 f0                	mov    %esi,%eax
  801c23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c26:	72 cc                	jb     801bf4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5f                   	pop    %edi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801c3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3f:	75 07                	jne    801c48 <devcons_read+0x18>
  801c41:	eb 28                	jmp    801c6b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c43:	e8 d1 ee ff ff       	call   800b19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c48:	e8 4d ee ff ff       	call   800a9a <sys_cgetc>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	74 f2                	je     801c43 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 16                	js     801c6b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c55:	83 f8 04             	cmp    $0x4,%eax
  801c58:	74 0c                	je     801c66 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5d:	88 02                	mov    %al,(%edx)
	return 1;
  801c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c64:	eb 05                	jmp    801c6b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c79:	6a 01                	push   $0x1
  801c7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 f8 ed ff ff       	call   800a7c <sys_cputs>
  801c84:	83 c4 10             	add    $0x10,%esp
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <getchar>:

int
getchar(void)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c8f:	6a 01                	push   $0x1
  801c91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	6a 00                	push   $0x0
  801c97:	e8 71 f6 ff ff       	call   80130d <read>
	if (r < 0)
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 0f                	js     801cb2 <getchar+0x29>
		return r;
	if (r < 1)
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	7e 06                	jle    801cad <getchar+0x24>
		return -E_EOF;
	return c;
  801ca7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cab:	eb 05                	jmp    801cb2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbd:	50                   	push   %eax
  801cbe:	ff 75 08             	pushl  0x8(%ebp)
  801cc1:	e8 dd f3 ff ff       	call   8010a3 <fd_lookup>
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 11                	js     801cde <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd6:	39 10                	cmp    %edx,(%eax)
  801cd8:	0f 94 c0             	sete   %al
  801cdb:	0f b6 c0             	movzbl %al,%eax
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <opencons>:

int
opencons(void)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	e8 65 f3 ff ff       	call   801054 <fd_alloc>
  801cef:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	78 3e                	js     801d36 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	68 07 04 00 00       	push   $0x407
  801d00:	ff 75 f4             	pushl  -0xc(%ebp)
  801d03:	6a 00                	push   $0x0
  801d05:	e8 2e ee ff ff       	call   800b38 <sys_page_alloc>
  801d0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 23                	js     801d36 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d13:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	50                   	push   %eax
  801d2c:	e8 fc f2 ff ff       	call   80102d <fd2num>
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	83 c4 10             	add    $0x10,%esp
}
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d3f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d42:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d48:	e8 ad ed ff ff       	call   800afa <sys_getenvid>
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	ff 75 0c             	pushl  0xc(%ebp)
  801d53:	ff 75 08             	pushl  0x8(%ebp)
  801d56:	56                   	push   %esi
  801d57:	50                   	push   %eax
  801d58:	68 34 28 80 00       	push   $0x802834
  801d5d:	e8 46 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d62:	83 c4 18             	add    $0x18,%esp
  801d65:	53                   	push   %ebx
  801d66:	ff 75 10             	pushl  0x10(%ebp)
  801d69:	e8 e9 e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d6e:	c7 04 24 94 22 80 00 	movl   $0x802294,(%esp)
  801d75:	e8 2e e4 ff ff       	call   8001a8 <cprintf>
  801d7a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d7d:	cc                   	int3   
  801d7e:	eb fd                	jmp    801d7d <_panic+0x43>

00801d80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d86:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d8d:	75 2c                	jne    801dbb <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	6a 07                	push   $0x7
  801d94:	68 00 f0 bf ee       	push   $0xeebff000
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 98 ed ff ff       	call   800b38 <sys_page_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	74 14                	je     801dbb <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	68 58 28 80 00       	push   $0x802858
  801daf:	6a 21                	push   $0x21
  801db1:	68 bc 28 80 00       	push   $0x8028bc
  801db6:	e8 7f ff ff ff       	call   801d3a <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	68 ef 1d 80 00       	push   $0x801def
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 b1 ee ff ff       	call   800c83 <sys_env_set_pgfault_upcall>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	79 14                	jns    801ded <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	68 84 28 80 00       	push   $0x802884
  801de1:	6a 29                	push   $0x29
  801de3:	68 bc 28 80 00       	push   $0x8028bc
  801de8:	e8 4d ff ff ff       	call   801d3a <_panic>
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801def:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801df7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801dfa:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801dff:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801e03:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801e07:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801e09:	83 c4 08             	add    $0x8,%esp
        popal
  801e0c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801e0d:	83 c4 04             	add    $0x4,%esp
        popfl
  801e10:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801e11:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e12:	c3                   	ret    

00801e13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801e21:	85 c0                	test   %eax,%eax
  801e23:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e28:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801e2b:	83 ec 0c             	sub    $0xc,%esp
  801e2e:	50                   	push   %eax
  801e2f:	e8 b4 ee ff ff       	call   800ce8 <sys_ipc_recv>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	79 16                	jns    801e51 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801e3b:	85 f6                	test   %esi,%esi
  801e3d:	74 06                	je     801e45 <ipc_recv+0x32>
  801e3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801e45:	85 db                	test   %ebx,%ebx
  801e47:	74 2c                	je     801e75 <ipc_recv+0x62>
  801e49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e4f:	eb 24                	jmp    801e75 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801e51:	85 f6                	test   %esi,%esi
  801e53:	74 0a                	je     801e5f <ipc_recv+0x4c>
  801e55:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5a:	8b 40 74             	mov    0x74(%eax),%eax
  801e5d:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801e5f:	85 db                	test   %ebx,%ebx
  801e61:	74 0a                	je     801e6d <ipc_recv+0x5a>
  801e63:	a1 04 40 80 00       	mov    0x804004,%eax
  801e68:	8b 40 78             	mov    0x78(%eax),%eax
  801e6b:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801e6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e72:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	57                   	push   %edi
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801e8e:	85 db                	test   %ebx,%ebx
  801e90:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e95:	0f 44 d8             	cmove  %eax,%ebx
  801e98:	eb 1c                	jmp    801eb6 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801e9a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9d:	74 12                	je     801eb1 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801e9f:	50                   	push   %eax
  801ea0:	68 ca 28 80 00       	push   $0x8028ca
  801ea5:	6a 39                	push   $0x39
  801ea7:	68 e5 28 80 00       	push   $0x8028e5
  801eac:	e8 89 fe ff ff       	call   801d3a <_panic>
                 sys_yield();
  801eb1:	e8 63 ec ff ff       	call   800b19 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801eb6:	ff 75 14             	pushl  0x14(%ebp)
  801eb9:	53                   	push   %ebx
  801eba:	56                   	push   %esi
  801ebb:	57                   	push   %edi
  801ebc:	e8 04 ee ff ff       	call   800cc5 <sys_ipc_try_send>
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 d2                	js     801e9a <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecb:	5b                   	pop    %ebx
  801ecc:	5e                   	pop    %esi
  801ecd:	5f                   	pop    %edi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801edb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ede:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ee4:	8b 52 50             	mov    0x50(%edx),%edx
  801ee7:	39 ca                	cmp    %ecx,%edx
  801ee9:	75 0d                	jne    801ef8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801eeb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801eee:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ef3:	8b 40 08             	mov    0x8(%eax),%eax
  801ef6:	eb 0e                	jmp    801f06 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ef8:	83 c0 01             	add    $0x1,%eax
  801efb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f00:	75 d9                	jne    801edb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f02:	66 b8 00 00          	mov    $0x0,%ax
}
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0e:	89 d0                	mov    %edx,%eax
  801f10:	c1 e8 16             	shr    $0x16,%eax
  801f13:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1f:	f6 c1 01             	test   $0x1,%cl
  801f22:	74 1d                	je     801f41 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f24:	c1 ea 0c             	shr    $0xc,%edx
  801f27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f2e:	f6 c2 01             	test   $0x1,%dl
  801f31:	74 0e                	je     801f41 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f33:	c1 ea 0c             	shr    $0xc,%edx
  801f36:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f3d:	ef 
  801f3e:	0f b7 c0             	movzwl %ax,%eax
}
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    
  801f43:	66 90                	xchg   %ax,%ax
  801f45:	66 90                	xchg   %ax,%ax
  801f47:	66 90                	xchg   %ax,%ax
  801f49:	66 90                	xchg   %ax,%ax
  801f4b:	66 90                	xchg   %ax,%ax
  801f4d:	66 90                	xchg   %ax,%ax
  801f4f:	90                   	nop

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
