
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 10 80 00       	push   $0x801000
  80003e:	e8 ca 01 00 00       	call   80020d <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 40 20 80 00 	cmpl   $0x0,0x802040(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 7b 10 80 00       	push   $0x80107b
  80005b:	6a 11                	push   $0x11
  80005d:	68 98 10 80 00       	push   $0x801098
  800062:	e8 cd 00 00 00       	call   800134 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 40 20 80 00 	mov    %eax,0x802040(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 40 20 80 00 	cmp    0x802040(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 20 10 80 00       	push   $0x801020
  80009b:	6a 16                	push   $0x16
  80009d:	68 98 10 80 00       	push   $0x801098
  8000a2:	e8 8d 00 00 00       	call   800134 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 48 10 80 00       	push   $0x801048
  8000b9:	e8 4f 01 00 00       	call   80020d <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 40 30 c0 00 00 	movl   $0x0,0xc03040
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 a7 10 80 00       	push   $0x8010a7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 98 10 80 00       	push   $0x801098
  8000d7:	e8 58 00 00 00       	call   800134 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000e7:	e8 73 0a 00 00       	call   800b5f <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 40 20 c0 00       	mov    %eax,0xc02040

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
  800118:	83 c4 10             	add    $0x10,%esp
}
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800128:	6a 00                	push   $0x0
  80012a:	e8 ef 09 00 00       	call   800b1e <sys_env_destroy>
  80012f:	83 c4 10             	add    $0x10,%esp
}
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800142:	e8 18 0a 00 00       	call   800b5f <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 c8 10 80 00       	push   $0x8010c8
  800157:	e8 b1 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 54 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 96 10 80 00 	movl   $0x801096,(%esp)
  80016f:	e8 99 00 00 00       	call   80020d <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 1a                	jne    8001b3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 37 09 00 00       	call   800ae1 <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	ff 75 0c             	pushl  0xc(%ebp)
  8001dc:	ff 75 08             	pushl  0x8(%ebp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	68 7a 01 80 00       	push   $0x80017a
  8001eb:	e8 4f 01 00 00       	call   80033f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f0:	83 c4 08             	add    $0x8,%esp
  8001f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	e8 dc 08 00 00       	call   800ae1 <sys_cputs>

	return b.cnt;
}
  800205:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800213:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800216:	50                   	push   %eax
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 9d ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 1c             	sub    $0x1c,%esp
  80022a:	89 c7                	mov    %eax,%edi
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 d1                	mov    %edx,%ecx
  800236:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800239:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800245:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80024f:	72 05                	jb     800256 <printnum+0x35>
  800251:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800254:	77 3e                	ja     800294 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	ff 75 18             	pushl  0x18(%ebp)
  80025c:	83 eb 01             	sub    $0x1,%ebx
  80025f:	53                   	push   %ebx
  800260:	50                   	push   %eax
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 e4             	pushl  -0x1c(%ebp)
  800267:	ff 75 e0             	pushl  -0x20(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 db 0a 00 00       	call   800d50 <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 f2                	mov    %esi,%edx
  80027c:	89 f8                	mov    %edi,%eax
  80027e:	e8 9e ff ff ff       	call   800221 <printnum>
  800283:	83 c4 20             	add    $0x20,%esp
  800286:	eb 13                	jmp    80029b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	ff 75 18             	pushl  0x18(%ebp)
  80028f:	ff d7                	call   *%edi
  800291:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800294:	83 eb 01             	sub    $0x1,%ebx
  800297:	85 db                	test   %ebx,%ebx
  800299:	7f ed                	jg     800288 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	56                   	push   %esi
  80029f:	83 ec 04             	sub    $0x4,%esp
  8002a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ae:	e8 cd 0b 00 00       	call   800e80 <__umoddi3>
  8002b3:	83 c4 14             	add    $0x14,%esp
  8002b6:	0f be 80 ec 10 80 00 	movsbl 0x8010ec(%eax),%eax
  8002bd:	50                   	push   %eax
  8002be:	ff d7                	call   *%edi
  8002c0:	83 c4 10             	add    $0x10,%esp
}
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ce:	83 fa 01             	cmp    $0x1,%edx
  8002d1:	7e 0e                	jle    8002e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	8b 52 04             	mov    0x4(%edx),%edx
  8002df:	eb 22                	jmp    800303 <getuint+0x38>
	else if (lflag)
  8002e1:	85 d2                	test   %edx,%edx
  8002e3:	74 10                	je     8002f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 0e                	jmp    800303 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 0a                	jae    800320 <sprintputch+0x1b>
		*b->buf++ = ch;
  800316:	8d 4a 01             	lea    0x1(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	88 02                	mov    %al,(%edx)
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800328:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032b:	50                   	push   %eax
  80032c:	ff 75 10             	pushl  0x10(%ebp)
  80032f:	ff 75 0c             	pushl  0xc(%ebp)
  800332:	ff 75 08             	pushl  0x8(%ebp)
  800335:	e8 05 00 00 00       	call   80033f <vprintfmt>
	va_end(ap);
  80033a:	83 c4 10             	add    $0x10,%esp
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 2c             	sub    $0x2c,%esp
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800351:	eb 12                	jmp    800365 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 84 90 03 00 00    	je     8006eb <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	53                   	push   %ebx
  80035f:	50                   	push   %eax
  800360:	ff d6                	call   *%esi
  800362:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	83 c7 01             	add    $0x1,%edi
  800368:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036c:	83 f8 25             	cmp    $0x25,%eax
  80036f:	75 e2                	jne    800353 <vprintfmt+0x14>
  800371:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800375:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800383:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
  80038f:	eb 07                	jmp    800398 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800394:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8d 47 01             	lea    0x1(%edi),%eax
  80039b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039e:	0f b6 07             	movzbl (%edi),%eax
  8003a1:	0f b6 c8             	movzbl %al,%ecx
  8003a4:	83 e8 23             	sub    $0x23,%eax
  8003a7:	3c 55                	cmp    $0x55,%al
  8003a9:	0f 87 21 03 00 00    	ja     8006d0 <vprintfmt+0x391>
  8003af:	0f b6 c0             	movzbl %al,%eax
  8003b2:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003da:	83 fa 09             	cmp    $0x9,%edx
  8003dd:	77 39                	ja     800418 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003df:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e2:	eb e9                	jmp    8003cd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f5:	eb 27                	jmp    80041e <vprintfmt+0xdf>
  8003f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800401:	0f 49 c8             	cmovns %eax,%ecx
  800404:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040a:	eb 8c                	jmp    800398 <vprintfmt+0x59>
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800416:	eb 80                	jmp    800398 <vprintfmt+0x59>
  800418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 89 70 ff ff ff    	jns    800398 <vprintfmt+0x59>
				width = precision, precision = -1;
  800428:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800435:	e9 5e ff ff ff       	jmp    800398 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800440:	e9 53 ff ff ff       	jmp    800398 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	ff 30                	pushl  (%eax)
  800454:	ff d6                	call   *%esi
			break;
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045c:	e9 04 ff ff ff       	jmp    800365 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	99                   	cltd   
  80046d:	31 d0                	xor    %edx,%eax
  80046f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 09             	cmp    $0x9,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x142>
  800476:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  80047d:	85 d2                	test   %edx,%edx
  80047f:	75 18                	jne    800499 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800481:	50                   	push   %eax
  800482:	68 04 11 80 00       	push   $0x801104
  800487:	53                   	push   %ebx
  800488:	56                   	push   %esi
  800489:	e8 94 fe ff ff       	call   800322 <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800494:	e9 cc fe ff ff       	jmp    800365 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800499:	52                   	push   %edx
  80049a:	68 0d 11 80 00       	push   $0x80110d
  80049f:	53                   	push   %ebx
  8004a0:	56                   	push   %esi
  8004a1:	e8 7c fe ff ff       	call   800322 <printfmt>
  8004a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ac:	e9 b4 fe ff ff       	jmp    800365 <vprintfmt+0x26>
  8004b1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c5:	85 ff                	test   %edi,%edi
  8004c7:	ba fd 10 80 00       	mov    $0x8010fd,%edx
  8004cc:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d3:	0f 84 92 00 00 00    	je     80056b <vprintfmt+0x22c>
  8004d9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004dd:	0f 8e 96 00 00 00    	jle    800579 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	51                   	push   %ecx
  8004e7:	57                   	push   %edi
  8004e8:	e8 86 02 00 00       	call   800773 <strnlen>
  8004ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f0:	29 c1                	sub    %eax,%ecx
  8004f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800502:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	eb 0f                	jmp    800515 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	53                   	push   %ebx
  80050a:	ff 75 e0             	pushl  -0x20(%ebp)
  80050d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	83 ef 01             	sub    $0x1,%edi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 ff                	test   %edi,%edi
  800517:	7f ed                	jg     800506 <vprintfmt+0x1c7>
  800519:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051f:	85 c9                	test   %ecx,%ecx
  800521:	b8 00 00 00 00       	mov    $0x0,%eax
  800526:	0f 49 c1             	cmovns %ecx,%eax
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 75 08             	mov    %esi,0x8(%ebp)
  80052e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800531:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800534:	89 cb                	mov    %ecx,%ebx
  800536:	eb 4d                	jmp    800585 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800538:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053c:	74 1b                	je     800559 <vprintfmt+0x21a>
  80053e:	0f be c0             	movsbl %al,%eax
  800541:	83 e8 20             	sub    $0x20,%eax
  800544:	83 f8 5e             	cmp    $0x5e,%eax
  800547:	76 10                	jbe    800559 <vprintfmt+0x21a>
					putch('?', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 0c             	pushl  0xc(%ebp)
  80054f:	6a 3f                	push   $0x3f
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb 0d                	jmp    800566 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	ff 75 0c             	pushl  0xc(%ebp)
  80055f:	52                   	push   %edx
  800560:	ff 55 08             	call   *0x8(%ebp)
  800563:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	83 eb 01             	sub    $0x1,%ebx
  800569:	eb 1a                	jmp    800585 <vprintfmt+0x246>
  80056b:	89 75 08             	mov    %esi,0x8(%ebp)
  80056e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800571:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800574:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800577:	eb 0c                	jmp    800585 <vprintfmt+0x246>
  800579:	89 75 08             	mov    %esi,0x8(%ebp)
  80057c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800582:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800585:	83 c7 01             	add    $0x1,%edi
  800588:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058c:	0f be d0             	movsbl %al,%edx
  80058f:	85 d2                	test   %edx,%edx
  800591:	74 23                	je     8005b6 <vprintfmt+0x277>
  800593:	85 f6                	test   %esi,%esi
  800595:	78 a1                	js     800538 <vprintfmt+0x1f9>
  800597:	83 ee 01             	sub    $0x1,%esi
  80059a:	79 9c                	jns    800538 <vprintfmt+0x1f9>
  80059c:	89 df                	mov    %ebx,%edi
  80059e:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a4:	eb 18                	jmp    8005be <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 20                	push   $0x20
  8005ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ae:	83 ef 01             	sub    $0x1,%edi
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 08                	jmp    8005be <vprintfmt+0x27f>
  8005b6:	89 df                	mov    %ebx,%edi
  8005b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	7f e4                	jg     8005a6 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c5:	e9 9b fd ff ff       	jmp    800365 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ca:	83 fa 01             	cmp    $0x1,%edx
  8005cd:	7e 16                	jle    8005e5 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 08             	lea    0x8(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 50 04             	mov    0x4(%eax),%edx
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e3:	eb 32                	jmp    800617 <vprintfmt+0x2d8>
	else if (lflag)
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	74 18                	je     800601 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 c1                	mov    %eax,%ecx
  8005f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ff:	eb 16                	jmp    800617 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 c1                	mov    %eax,%ecx
  800611:	c1 f9 1f             	sar    $0x1f,%ecx
  800614:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800617:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800622:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800626:	79 74                	jns    80069c <vprintfmt+0x35d>
				putch('-', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 2d                	push   $0x2d
  80062e:	ff d6                	call   *%esi
				num = -(long long) num;
  800630:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800633:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800636:	f7 d8                	neg    %eax
  800638:	83 d2 00             	adc    $0x0,%edx
  80063b:	f7 da                	neg    %edx
  80063d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800645:	eb 55                	jmp    80069c <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 7c fc ff ff       	call   8002cb <getuint>
			base = 10;
  80064f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800654:	eb 46                	jmp    80069c <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 6d fc ff ff       	call   8002cb <getuint>
                        base = 8;
  80065e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800663:	eb 37                	jmp    80069c <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 30                	push   $0x30
  80066b:	ff d6                	call   *%esi
			putch('x', putdat);
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	6a 78                	push   $0x78
  800673:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800685:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800688:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068d:	eb 0d                	jmp    80069c <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 34 fc ff ff       	call   8002cb <getuint>
			base = 16;
  800697:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a3:	57                   	push   %edi
  8006a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a7:	51                   	push   %ecx
  8006a8:	52                   	push   %edx
  8006a9:	50                   	push   %eax
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	89 f0                	mov    %esi,%eax
  8006ae:	e8 6e fb ff ff       	call   800221 <printnum>
			break;
  8006b3:	83 c4 20             	add    $0x20,%esp
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	e9 a7 fc ff ff       	jmp    800365 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	51                   	push   %ecx
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cb:	e9 95 fc ff ff       	jmp    800365 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 03                	jmp    8006e0 <vprintfmt+0x3a1>
  8006dd:	83 ef 01             	sub    $0x1,%edi
  8006e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e4:	75 f7                	jne    8006dd <vprintfmt+0x39e>
  8006e6:	e9 7a fc ff ff       	jmp    800365 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5e                   	pop    %esi
  8006f0:	5f                   	pop    %edi
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 18             	sub    $0x18,%esp
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800702:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800706:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800709:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 26                	je     80073a <vsnprintf+0x47>
  800714:	85 d2                	test   %edx,%edx
  800716:	7e 22                	jle    80073a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800718:	ff 75 14             	pushl  0x14(%ebp)
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	68 05 03 80 00       	push   $0x800305
  800727:	e8 13 fc ff ff       	call   80033f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 05                	jmp    80073f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074a:	50                   	push   %eax
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	ff 75 08             	pushl  0x8(%ebp)
  800754:	e8 9a ff ff ff       	call   8006f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strlen+0x10>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076f:	75 f7                	jne    800768 <strlen+0xd>
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	eb 03                	jmp    800786 <strnlen+0x13>
		n++;
  800783:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800786:	39 c2                	cmp    %eax,%edx
  800788:	74 08                	je     800792 <strnlen+0x1f>
  80078a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078e:	75 f3                	jne    800783 <strnlen+0x10>
  800790:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c2 01             	add    $0x1,%edx
  8007a3:	83 c1 01             	add    $0x1,%ecx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9a ff ff ff       	call   80075b <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	8b 55 10             	mov    0x10(%ebp),%edx
  800811:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800813:	85 d2                	test   %edx,%edx
  800815:	74 21                	je     800838 <strlcpy+0x35>
  800817:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 09                	jmp    800828 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 09                	je     800835 <strlcpy+0x32>
  80082c:	0f b6 19             	movzbl (%ecx),%ebx
  80082f:	84 db                	test   %bl,%bl
  800831:	75 ec                	jne    80081f <strlcpy+0x1c>
  800833:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800835:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800838:	29 f0                	sub    %esi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800847:	eb 06                	jmp    80084f <strcmp+0x11>
		p++, q++;
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084f:	0f b6 01             	movzbl (%ecx),%eax
  800852:	84 c0                	test   %al,%al
  800854:	74 04                	je     80085a <strcmp+0x1c>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	74 ef                	je     800849 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	89 c3                	mov    %eax,%ebx
  800870:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800873:	eb 06                	jmp    80087b <strncmp+0x17>
		n--, p++, q++;
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087b:	39 d8                	cmp    %ebx,%eax
  80087d:	74 15                	je     800894 <strncmp+0x30>
  80087f:	0f b6 08             	movzbl (%eax),%ecx
  800882:	84 c9                	test   %cl,%cl
  800884:	74 04                	je     80088a <strncmp+0x26>
  800886:	3a 0a                	cmp    (%edx),%cl
  800888:	74 eb                	je     800875 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 00             	movzbl (%eax),%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
  800892:	eb 05                	jmp    800899 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800899:	5b                   	pop    %ebx
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 07                	jmp    8008af <strchr+0x13>
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 0f                	je     8008bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 03                	jmp    8008cc <strfind+0xf>
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	74 04                	je     8008d7 <strfind+0x1a>
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	75 f2                	jne    8008c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 36                	je     80091f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 28                	jne    800919 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 23                	jne    800919 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fa:	89 d3                	mov    %edx,%ebx
  8008fc:	c1 e3 08             	shl    $0x8,%ebx
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	c1 e6 18             	shl    $0x18,%esi
  800904:	89 d0                	mov    %edx,%eax
  800906:	c1 e0 10             	shl    $0x10,%eax
  800909:	09 f0                	or     %esi,%eax
  80090b:	09 c2                	or     %eax,%edx
  80090d:	89 d0                	mov    %edx,%eax
  80090f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800911:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800914:	fc                   	cld    
  800915:	f3 ab                	rep stos %eax,%es:(%edi)
  800917:	eb 06                	jmp    80091f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	fc                   	cld    
  80091d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091f:	89 f8                	mov    %edi,%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 35                	jae    80096d <memmove+0x47>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	73 2e                	jae    80096d <memmove+0x47>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800942:	89 d6                	mov    %edx,%esi
  800944:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	75 13                	jne    800961 <memmove+0x3b>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0e                	jne    800961 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 09                	jmp    80096a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 1d                	jmp    80098a <memmove+0x64>
  80096d:	89 f2                	mov    %esi,%edx
  80096f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	f6 c2 03             	test   $0x3,%dl
  800974:	75 0f                	jne    800985 <memmove+0x5f>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0a                	jne    800985 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800991:	ff 75 10             	pushl  0x10(%ebp)
  800994:	ff 75 0c             	pushl  0xc(%ebp)
  800997:	ff 75 08             	pushl  0x8(%ebp)
  80099a:	e8 87 ff ff ff       	call   800926 <memmove>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c6                	mov    %eax,%esi
  8009ae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	eb 1a                	jmp    8009cd <memcmp+0x2c>
		if (*s1 != *s2)
  8009b3:	0f b6 08             	movzbl (%eax),%ecx
  8009b6:	0f b6 1a             	movzbl (%edx),%ebx
  8009b9:	38 d9                	cmp    %bl,%cl
  8009bb:	74 0a                	je     8009c7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bd:	0f b6 c1             	movzbl %cl,%eax
  8009c0:	0f b6 db             	movzbl %bl,%ebx
  8009c3:	29 d8                	sub    %ebx,%eax
  8009c5:	eb 0f                	jmp    8009d6 <memcmp+0x35>
		s1++, s2++;
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	39 f0                	cmp    %esi,%eax
  8009cf:	75 e2                	jne    8009b3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e3:	89 c2                	mov    %eax,%edx
  8009e5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e8:	eb 07                	jmp    8009f1 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	38 08                	cmp    %cl,(%eax)
  8009ec:	74 07                	je     8009f5 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	39 d0                	cmp    %edx,%eax
  8009f3:	72 f5                	jb     8009ea <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a03:	eb 03                	jmp    800a08 <strtol+0x11>
		s++;
  800a05:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a08:	0f b6 01             	movzbl (%ecx),%eax
  800a0b:	3c 09                	cmp    $0x9,%al
  800a0d:	74 f6                	je     800a05 <strtol+0xe>
  800a0f:	3c 20                	cmp    $0x20,%al
  800a11:	74 f2                	je     800a05 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a13:	3c 2b                	cmp    $0x2b,%al
  800a15:	75 0a                	jne    800a21 <strtol+0x2a>
		s++;
  800a17:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1f:	eb 10                	jmp    800a31 <strtol+0x3a>
  800a21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a26:	3c 2d                	cmp    $0x2d,%al
  800a28:	75 07                	jne    800a31 <strtol+0x3a>
		s++, neg = 1;
  800a2a:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a31:	85 db                	test   %ebx,%ebx
  800a33:	0f 94 c0             	sete   %al
  800a36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3c:	75 19                	jne    800a57 <strtol+0x60>
  800a3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a41:	75 14                	jne    800a57 <strtol+0x60>
  800a43:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a47:	0f 85 82 00 00 00    	jne    800acf <strtol+0xd8>
		s += 2, base = 16;
  800a4d:	83 c1 02             	add    $0x2,%ecx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 16                	jmp    800a6d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a57:	84 c0                	test   %al,%al
  800a59:	74 12                	je     800a6d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	80 39 30             	cmpb   $0x30,(%ecx)
  800a63:	75 08                	jne    800a6d <strtol+0x76>
		s++, base = 8;
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a75:	0f b6 11             	movzbl (%ecx),%edx
  800a78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x93>
			dig = *s - '0';
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 30             	sub    $0x30,%edx
  800a88:	eb 22                	jmp    800aac <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 08                	ja     800a9c <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 57             	sub    $0x57,%edx
  800a9a:	eb 10                	jmp    800aac <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 16                	ja     800abc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaf:	7d 0f                	jge    800ac0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aba:	eb b9                	jmp    800a75 <strtol+0x7e>
  800abc:	89 c2                	mov    %eax,%edx
  800abe:	eb 02                	jmp    800ac2 <strtol+0xcb>
  800ac0:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac6:	74 0d                	je     800ad5 <strtol+0xde>
		*endptr = (char *) s;
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acb:	89 0e                	mov    %ecx,(%esi)
  800acd:	eb 06                	jmp    800ad5 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acf:	84 c0                	test   %al,%al
  800ad1:	75 92                	jne    800a65 <strtol+0x6e>
  800ad3:	eb 98                	jmp    800a6d <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad5:	f7 da                	neg    %edx
  800ad7:	85 ff                	test   %edi,%edi
  800ad9:	0f 45 c2             	cmovne %edx,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cgetc>:

int
sys_cgetc(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	89 cb                	mov    %ecx,%ebx
  800b36:	89 cf                	mov    %ecx,%edi
  800b38:	89 ce                	mov    %ecx,%esi
  800b3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 03                	push   $0x3
  800b46:	68 48 13 80 00       	push   $0x801348
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 65 13 80 00       	push   $0x801365
  800b52:	e8 dd f5 ff ff       	call   800134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_yield>:

void
sys_yield(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	be 00 00 00 00       	mov    $0x0,%esi
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	89 f7                	mov    %esi,%edi
  800bbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 04                	push   $0x4
  800bc7:	68 48 13 80 00       	push   $0x801348
  800bcc:	6a 23                	push   $0x23
  800bce:	68 65 13 80 00       	push   $0x801365
  800bd3:	e8 5c f5 ff ff       	call   800134 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 05                	push   $0x5
  800c09:	68 48 13 80 00       	push   $0x801348
  800c0e:	6a 23                	push   $0x23
  800c10:	68 65 13 80 00       	push   $0x801365
  800c15:	e8 1a f5 ff ff       	call   800134 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	b8 06 00 00 00       	mov    $0x6,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 06                	push   $0x6
  800c4b:	68 48 13 80 00       	push   $0x801348
  800c50:	6a 23                	push   $0x23
  800c52:	68 65 13 80 00       	push   $0x801365
  800c57:	e8 d8 f4 ff ff       	call   800134 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 08 00 00 00       	mov    $0x8,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 08                	push   $0x8
  800c8d:	68 48 13 80 00       	push   $0x801348
  800c92:	6a 23                	push   $0x23
  800c94:	68 65 13 80 00       	push   $0x801365
  800c99:	e8 96 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 09                	push   $0x9
  800ccf:	68 48 13 80 00       	push   $0x801348
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 65 13 80 00       	push   $0x801365
  800cdb:	e8 54 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	be 00 00 00 00       	mov    $0x0,%esi
  800cf3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d04:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 0c                	push   $0xc
  800d33:	68 48 13 80 00       	push   $0x801348
  800d38:	6a 23                	push   $0x23
  800d3a:	68 65 13 80 00       	push   $0x801365
  800d3f:	e8 f0 f3 ff ff       	call   800134 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__udivdi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	83 ec 10             	sub    $0x10,%esp
  800d56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800d5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800d5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d66:	85 d2                	test   %edx,%edx
  800d68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d6c:	89 34 24             	mov    %esi,(%esp)
  800d6f:	89 c8                	mov    %ecx,%eax
  800d71:	75 35                	jne    800da8 <__udivdi3+0x58>
  800d73:	39 f1                	cmp    %esi,%ecx
  800d75:	0f 87 bd 00 00 00    	ja     800e38 <__udivdi3+0xe8>
  800d7b:	85 c9                	test   %ecx,%ecx
  800d7d:	89 cd                	mov    %ecx,%ebp
  800d7f:	75 0b                	jne    800d8c <__udivdi3+0x3c>
  800d81:	b8 01 00 00 00       	mov    $0x1,%eax
  800d86:	31 d2                	xor    %edx,%edx
  800d88:	f7 f1                	div    %ecx
  800d8a:	89 c5                	mov    %eax,%ebp
  800d8c:	89 f0                	mov    %esi,%eax
  800d8e:	31 d2                	xor    %edx,%edx
  800d90:	f7 f5                	div    %ebp
  800d92:	89 c6                	mov    %eax,%esi
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	f7 f5                	div    %ebp
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    
  800da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da8:	3b 14 24             	cmp    (%esp),%edx
  800dab:	77 7b                	ja     800e28 <__udivdi3+0xd8>
  800dad:	0f bd f2             	bsr    %edx,%esi
  800db0:	83 f6 1f             	xor    $0x1f,%esi
  800db3:	0f 84 97 00 00 00    	je     800e50 <__udivdi3+0x100>
  800db9:	bd 20 00 00 00       	mov    $0x20,%ebp
  800dbe:	89 d7                	mov    %edx,%edi
  800dc0:	89 f1                	mov    %esi,%ecx
  800dc2:	29 f5                	sub    %esi,%ebp
  800dc4:	d3 e7                	shl    %cl,%edi
  800dc6:	89 c2                	mov    %eax,%edx
  800dc8:	89 e9                	mov    %ebp,%ecx
  800dca:	d3 ea                	shr    %cl,%edx
  800dcc:	89 f1                	mov    %esi,%ecx
  800dce:	09 fa                	or     %edi,%edx
  800dd0:	8b 3c 24             	mov    (%esp),%edi
  800dd3:	d3 e0                	shl    %cl,%eax
  800dd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dd9:	89 e9                	mov    %ebp,%ecx
  800ddb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ddf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	d3 ea                	shr    %cl,%edx
  800de7:	89 f1                	mov    %esi,%ecx
  800de9:	d3 e7                	shl    %cl,%edi
  800deb:	89 e9                	mov    %ebp,%ecx
  800ded:	d3 e8                	shr    %cl,%eax
  800def:	09 c7                	or     %eax,%edi
  800df1:	89 f8                	mov    %edi,%eax
  800df3:	f7 74 24 08          	divl   0x8(%esp)
  800df7:	89 d5                	mov    %edx,%ebp
  800df9:	89 c7                	mov    %eax,%edi
  800dfb:	f7 64 24 0c          	mull   0xc(%esp)
  800dff:	39 d5                	cmp    %edx,%ebp
  800e01:	89 14 24             	mov    %edx,(%esp)
  800e04:	72 11                	jb     800e17 <__udivdi3+0xc7>
  800e06:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e0a:	89 f1                	mov    %esi,%ecx
  800e0c:	d3 e2                	shl    %cl,%edx
  800e0e:	39 c2                	cmp    %eax,%edx
  800e10:	73 5e                	jae    800e70 <__udivdi3+0x120>
  800e12:	3b 2c 24             	cmp    (%esp),%ebp
  800e15:	75 59                	jne    800e70 <__udivdi3+0x120>
  800e17:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e1a:	31 f6                	xor    %esi,%esi
  800e1c:	89 f2                	mov    %esi,%edx
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	31 f6                	xor    %esi,%esi
  800e2a:	31 c0                	xor    %eax,%eax
  800e2c:	89 f2                	mov    %esi,%edx
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	89 f2                	mov    %esi,%edx
  800e3a:	31 f6                	xor    %esi,%esi
  800e3c:	89 f8                	mov    %edi,%eax
  800e3e:	f7 f1                	div    %ecx
  800e40:	89 f2                	mov    %esi,%edx
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e54:	76 0b                	jbe    800e61 <__udivdi3+0x111>
  800e56:	31 c0                	xor    %eax,%eax
  800e58:	3b 14 24             	cmp    (%esp),%edx
  800e5b:	0f 83 37 ff ff ff    	jae    800d98 <__udivdi3+0x48>
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	e9 2d ff ff ff       	jmp    800d98 <__udivdi3+0x48>
  800e6b:	90                   	nop
  800e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f8                	mov    %edi,%eax
  800e72:	31 f6                	xor    %esi,%esi
  800e74:	e9 1f ff ff ff       	jmp    800d98 <__udivdi3+0x48>
  800e79:	66 90                	xchg   %ax,%ax
  800e7b:	66 90                	xchg   %ax,%ax
  800e7d:	66 90                	xchg   %ax,%ax
  800e7f:	90                   	nop

00800e80 <__umoddi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	83 ec 20             	sub    $0x20,%esp
  800e86:	8b 44 24 34          	mov    0x34(%esp),%eax
  800e8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e92:	89 c6                	mov    %eax,%esi
  800e94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800ea0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ea4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800ea8:	89 74 24 18          	mov    %esi,0x18(%esp)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	75 1e                	jne    800ed0 <__umoddi3+0x50>
  800eb2:	39 f7                	cmp    %esi,%edi
  800eb4:	76 52                	jbe    800f08 <__umoddi3+0x88>
  800eb6:	89 c8                	mov    %ecx,%eax
  800eb8:	89 f2                	mov    %esi,%edx
  800eba:	f7 f7                	div    %edi
  800ebc:	89 d0                	mov    %edx,%eax
  800ebe:	31 d2                	xor    %edx,%edx
  800ec0:	83 c4 20             	add    $0x20,%esp
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    
  800ec7:	89 f6                	mov    %esi,%esi
  800ec9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ed0:	39 f0                	cmp    %esi,%eax
  800ed2:	77 5c                	ja     800f30 <__umoddi3+0xb0>
  800ed4:	0f bd e8             	bsr    %eax,%ebp
  800ed7:	83 f5 1f             	xor    $0x1f,%ebp
  800eda:	75 64                	jne    800f40 <__umoddi3+0xc0>
  800edc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800ee0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800ee4:	0f 86 f6 00 00 00    	jbe    800fe0 <__umoddi3+0x160>
  800eea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800eee:	0f 82 ec 00 00 00    	jb     800fe0 <__umoddi3+0x160>
  800ef4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ef8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	85 ff                	test   %edi,%edi
  800f0a:	89 fd                	mov    %edi,%ebp
  800f0c:	75 0b                	jne    800f19 <__umoddi3+0x99>
  800f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f13:	31 d2                	xor    %edx,%edx
  800f15:	f7 f7                	div    %edi
  800f17:	89 c5                	mov    %eax,%ebp
  800f19:	8b 44 24 10          	mov    0x10(%esp),%eax
  800f1d:	31 d2                	xor    %edx,%edx
  800f1f:	f7 f5                	div    %ebp
  800f21:	89 c8                	mov    %ecx,%eax
  800f23:	f7 f5                	div    %ebp
  800f25:	eb 95                	jmp    800ebc <__umoddi3+0x3c>
  800f27:	89 f6                	mov    %esi,%esi
  800f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    
  800f3b:	90                   	nop
  800f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f40:	b8 20 00 00 00       	mov    $0x20,%eax
  800f45:	89 e9                	mov    %ebp,%ecx
  800f47:	29 e8                	sub    %ebp,%eax
  800f49:	d3 e2                	shl    %cl,%edx
  800f4b:	89 c7                	mov    %eax,%edi
  800f4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 c1                	mov    %eax,%ecx
  800f5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f5f:	09 d1                	or     %edx,%ecx
  800f61:	89 fa                	mov    %edi,%edx
  800f63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f67:	89 e9                	mov    %ebp,%ecx
  800f69:	d3 e0                	shl    %cl,%eax
  800f6b:	89 f9                	mov    %edi,%ecx
  800f6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	d3 e8                	shr    %cl,%eax
  800f75:	89 e9                	mov    %ebp,%ecx
  800f77:	89 c7                	mov    %eax,%edi
  800f79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f7d:	d3 e6                	shl    %cl,%esi
  800f7f:	89 d1                	mov    %edx,%ecx
  800f81:	89 fa                	mov    %edi,%edx
  800f83:	d3 e8                	shr    %cl,%eax
  800f85:	89 e9                	mov    %ebp,%ecx
  800f87:	09 f0                	or     %esi,%eax
  800f89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800f8d:	f7 74 24 10          	divl   0x10(%esp)
  800f91:	d3 e6                	shl    %cl,%esi
  800f93:	89 d1                	mov    %edx,%ecx
  800f95:	f7 64 24 0c          	mull   0xc(%esp)
  800f99:	39 d1                	cmp    %edx,%ecx
  800f9b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800f9f:	89 d7                	mov    %edx,%edi
  800fa1:	89 c6                	mov    %eax,%esi
  800fa3:	72 0a                	jb     800faf <__umoddi3+0x12f>
  800fa5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800fa9:	73 10                	jae    800fbb <__umoddi3+0x13b>
  800fab:	39 d1                	cmp    %edx,%ecx
  800fad:	75 0c                	jne    800fbb <__umoddi3+0x13b>
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	89 c6                	mov    %eax,%esi
  800fb3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800fb7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800fbb:	89 ca                	mov    %ecx,%edx
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fc3:	29 f0                	sub    %esi,%eax
  800fc5:	19 fa                	sbb    %edi,%edx
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800fce:	89 d7                	mov    %edx,%edi
  800fd0:	d3 e7                	shl    %cl,%edi
  800fd2:	89 e9                	mov    %ebp,%ecx
  800fd4:	09 f8                	or     %edi,%eax
  800fd6:	d3 ea                	shr    %cl,%edx
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	5e                   	pop    %esi
  800fdc:	5f                   	pop    %edi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    
  800fdf:	90                   	nop
  800fe0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fe4:	29 f9                	sub    %edi,%ecx
  800fe6:	19 c6                	sbb    %eax,%esi
  800fe8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800fec:	89 74 24 18          	mov    %esi,0x18(%esp)
  800ff0:	e9 ff fe ff ff       	jmp    800ef4 <__umoddi3+0x74>
