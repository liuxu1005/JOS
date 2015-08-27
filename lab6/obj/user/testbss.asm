
obj/user/testbss.debug:     file format elf32-i386


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
  800039:	68 c0 23 80 00       	push   $0x8023c0
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 40 40 80 00 	cmpl   $0x0,0x804040(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 3b 24 80 00       	push   $0x80243b
  80005b:	6a 11                	push   $0x11
  80005d:	68 58 24 80 00       	push   $0x802458
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
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
  800076:	89 04 85 40 40 80 00 	mov    %eax,0x804040(,%eax,4)

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
  80008c:	3b 04 85 40 40 80 00 	cmp    0x804040(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 e0 23 80 00       	push   $0x8023e0
  80009b:	6a 16                	push   $0x16
  80009d:	68 58 24 80 00       	push   $0x802458
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
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
  8000b4:	68 08 24 80 00       	push   $0x802408
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 40 50 c0 00 00 	movl   $0x0,0xc05040
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 67 24 80 00       	push   $0x802467
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 58 24 80 00       	push   $0x802458
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

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
  8000e7:	e8 7b 0a 00 00       	call   800b67 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 40 40 c0 00       	mov    %eax,0xc04040

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 dc 0e 00 00       	call   801009 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 ef 09 00 00       	call   800b26 <sys_env_destroy>
  800137:	83 c4 10             	add    $0x10,%esp
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 18 0a 00 00       	call   800b67 <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 88 24 80 00       	push   $0x802488
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 56 24 80 00 	movl   $0x802456,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 37 09 00 00       	call   800ae9 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 4f 01 00 00       	call   800347 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 dc 08 00 00       	call   800ae9 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 d1                	mov    %edx,%ecx
  80023e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800241:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800244:	8b 45 10             	mov    0x10(%ebp),%eax
  800247:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800254:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800257:	72 05                	jb     80025e <printnum+0x35>
  800259:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80025c:	77 3e                	ja     80029c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	ff 75 18             	pushl  0x18(%ebp)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	53                   	push   %ebx
  800268:	50                   	push   %eax
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 73 1e 00 00       	call   8020f0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 13                	jmp    8002a3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f ed                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	83 ec 04             	sub    $0x4,%esp
  8002aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b6:	e8 65 1f 00 00       	call   802220 <__umoddi3>
  8002bb:	83 c4 14             	add    $0x14,%esp
  8002be:	0f be 80 ab 24 80 00 	movsbl 0x8024ab(%eax),%eax
  8002c5:	50                   	push   %eax
  8002c6:	ff d7                	call   *%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
}
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d6:	83 fa 01             	cmp    $0x1,%edx
  8002d9:	7e 0e                	jle    8002e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	8b 52 04             	mov    0x4(%edx),%edx
  8002e7:	eb 22                	jmp    80030b <getuint+0x38>
	else if (lflag)
  8002e9:	85 d2                	test   %edx,%edx
  8002eb:	74 10                	je     8002fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fb:	eb 0e                	jmp    80030b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800313:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800317:	8b 10                	mov    (%eax),%edx
  800319:	3b 50 04             	cmp    0x4(%eax),%edx
  80031c:	73 0a                	jae    800328 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	88 02                	mov    %al,(%edx)
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800330:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800333:	50                   	push   %eax
  800334:	ff 75 10             	pushl  0x10(%ebp)
  800337:	ff 75 0c             	pushl  0xc(%ebp)
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	e8 05 00 00 00       	call   800347 <vprintfmt>
	va_end(ap);
  800342:	83 c4 10             	add    $0x10,%esp
}
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
  80034d:	83 ec 2c             	sub    $0x2c,%esp
  800350:	8b 75 08             	mov    0x8(%ebp),%esi
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800356:	8b 7d 10             	mov    0x10(%ebp),%edi
  800359:	eb 12                	jmp    80036d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035b:	85 c0                	test   %eax,%eax
  80035d:	0f 84 90 03 00 00    	je     8006f3 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	53                   	push   %ebx
  800367:	50                   	push   %eax
  800368:	ff d6                	call   *%esi
  80036a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036d:	83 c7 01             	add    $0x1,%edi
  800370:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800374:	83 f8 25             	cmp    $0x25,%eax
  800377:	75 e2                	jne    80035b <vprintfmt+0x14>
  800379:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800384:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 07                	jmp    8003a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8d 47 01             	lea    0x1(%edi),%eax
  8003a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a6:	0f b6 07             	movzbl (%edi),%eax
  8003a9:	0f b6 c8             	movzbl %al,%ecx
  8003ac:	83 e8 23             	sub    $0x23,%eax
  8003af:	3c 55                	cmp    $0x55,%al
  8003b1:	0f 87 21 03 00 00    	ja     8006d8 <vprintfmt+0x391>
  8003b7:	0f b6 c0             	movzbl %al,%eax
  8003ba:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c8:	eb d6                	jmp    8003a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003dc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003df:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e2:	83 fa 09             	cmp    $0x9,%edx
  8003e5:	77 39                	ja     800420 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ea:	eb e9                	jmp    8003d5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fd:	eb 27                	jmp    800426 <vprintfmt+0xdf>
  8003ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800402:	85 c0                	test   %eax,%eax
  800404:	b9 00 00 00 00       	mov    $0x0,%ecx
  800409:	0f 49 c8             	cmovns %eax,%ecx
  80040c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800412:	eb 8c                	jmp    8003a0 <vprintfmt+0x59>
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800417:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041e:	eb 80                	jmp    8003a0 <vprintfmt+0x59>
  800420:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800423:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800426:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042a:	0f 89 70 ff ff ff    	jns    8003a0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800430:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043d:	e9 5e ff ff ff       	jmp    8003a0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800442:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800448:	e9 53 ff ff ff       	jmp    8003a0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	53                   	push   %ebx
  80045a:	ff 30                	pushl  (%eax)
  80045c:	ff d6                	call   *%esi
			break;
  80045e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800464:	e9 04 ff ff ff       	jmp    80036d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 50 04             	lea    0x4(%eax),%edx
  80046f:	89 55 14             	mov    %edx,0x14(%ebp)
  800472:	8b 00                	mov    (%eax),%eax
  800474:	99                   	cltd   
  800475:	31 d0                	xor    %edx,%eax
  800477:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 0f             	cmp    $0xf,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x142>
  80047e:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800485:	85 d2                	test   %edx,%edx
  800487:	75 18                	jne    8004a1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800489:	50                   	push   %eax
  80048a:	68 c3 24 80 00       	push   $0x8024c3
  80048f:	53                   	push   %ebx
  800490:	56                   	push   %esi
  800491:	e8 94 fe ff ff       	call   80032a <printfmt>
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049c:	e9 cc fe ff ff       	jmp    80036d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a1:	52                   	push   %edx
  8004a2:	68 b9 28 80 00       	push   $0x8028b9
  8004a7:	53                   	push   %ebx
  8004a8:	56                   	push   %esi
  8004a9:	e8 7c fe ff ff       	call   80032a <printfmt>
  8004ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b4:	e9 b4 fe ff ff       	jmp    80036d <vprintfmt+0x26>
  8004b9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	ba bc 24 80 00       	mov    $0x8024bc,%edx
  8004d4:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004db:	0f 84 92 00 00 00    	je     800573 <vprintfmt+0x22c>
  8004e1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e5:	0f 8e 96 00 00 00    	jle    800581 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	51                   	push   %ecx
  8004ef:	57                   	push   %edi
  8004f0:	e8 86 02 00 00       	call   80077b <strnlen>
  8004f5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f8:	29 c1                	sub    %eax,%ecx
  8004fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800500:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800504:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800507:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	eb 0f                	jmp    80051d <vprintfmt+0x1d6>
					putch(padc, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	ff 75 e0             	pushl  -0x20(%ebp)
  800515:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	83 ef 01             	sub    $0x1,%edi
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 ff                	test   %edi,%edi
  80051f:	7f ed                	jg     80050e <vprintfmt+0x1c7>
  800521:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800524:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800527:	85 c9                	test   %ecx,%ecx
  800529:	b8 00 00 00 00       	mov    $0x0,%eax
  80052e:	0f 49 c1             	cmovns %ecx,%eax
  800531:	29 c1                	sub    %eax,%ecx
  800533:	89 75 08             	mov    %esi,0x8(%ebp)
  800536:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053c:	89 cb                	mov    %ecx,%ebx
  80053e:	eb 4d                	jmp    80058d <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800540:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800544:	74 1b                	je     800561 <vprintfmt+0x21a>
  800546:	0f be c0             	movsbl %al,%eax
  800549:	83 e8 20             	sub    $0x20,%eax
  80054c:	83 f8 5e             	cmp    $0x5e,%eax
  80054f:	76 10                	jbe    800561 <vprintfmt+0x21a>
					putch('?', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	6a 3f                	push   $0x3f
  800559:	ff 55 08             	call   *0x8(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 0d                	jmp    80056e <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	52                   	push   %edx
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	83 eb 01             	sub    $0x1,%ebx
  800571:	eb 1a                	jmp    80058d <vprintfmt+0x246>
  800573:	89 75 08             	mov    %esi,0x8(%ebp)
  800576:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800579:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057f:	eb 0c                	jmp    80058d <vprintfmt+0x246>
  800581:	89 75 08             	mov    %esi,0x8(%ebp)
  800584:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800587:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058d:	83 c7 01             	add    $0x1,%edi
  800590:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800594:	0f be d0             	movsbl %al,%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	74 23                	je     8005be <vprintfmt+0x277>
  80059b:	85 f6                	test   %esi,%esi
  80059d:	78 a1                	js     800540 <vprintfmt+0x1f9>
  80059f:	83 ee 01             	sub    $0x1,%esi
  8005a2:	79 9c                	jns    800540 <vprintfmt+0x1f9>
  8005a4:	89 df                	mov    %ebx,%edi
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ac:	eb 18                	jmp    8005c6 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 20                	push   $0x20
  8005b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b6:	83 ef 01             	sub    $0x1,%edi
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	eb 08                	jmp    8005c6 <vprintfmt+0x27f>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f e4                	jg     8005ae <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cd:	e9 9b fd ff ff       	jmp    80036d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d2:	83 fa 01             	cmp    $0x1,%edx
  8005d5:	7e 16                	jle    8005ed <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 08             	lea    0x8(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	8b 50 04             	mov    0x4(%eax),%edx
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005eb:	eb 32                	jmp    80061f <vprintfmt+0x2d8>
	else if (lflag)
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 18                	je     800609 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 c1                	mov    %eax,%ecx
  800601:	c1 f9 1f             	sar    $0x1f,%ecx
  800604:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800607:	eb 16                	jmp    80061f <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 50 04             	lea    0x4(%eax),%edx
  80060f:	89 55 14             	mov    %edx,0x14(%ebp)
  800612:	8b 00                	mov    (%eax),%eax
  800614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800617:	89 c1                	mov    %eax,%ecx
  800619:	c1 f9 1f             	sar    $0x1f,%ecx
  80061c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800622:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800625:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062e:	79 74                	jns    8006a4 <vprintfmt+0x35d>
				putch('-', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 2d                	push   $0x2d
  800636:	ff d6                	call   *%esi
				num = -(long long) num;
  800638:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063e:	f7 d8                	neg    %eax
  800640:	83 d2 00             	adc    $0x0,%edx
  800643:	f7 da                	neg    %edx
  800645:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800648:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064d:	eb 55                	jmp    8006a4 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 7c fc ff ff       	call   8002d3 <getuint>
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065c:	eb 46                	jmp    8006a4 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 6d fc ff ff       	call   8002d3 <getuint>
                        base = 8;
  800666:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80066b:	eb 37                	jmp    8006a4 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	6a 30                	push   $0x30
  800673:	ff d6                	call   *%esi
			putch('x', putdat);
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 78                	push   $0x78
  80067b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800686:	8b 00                	mov    (%eax),%eax
  800688:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800690:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800695:	eb 0d                	jmp    8006a4 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 34 fc ff ff       	call   8002d3 <getuint>
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ab:	57                   	push   %edi
  8006ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8006af:	51                   	push   %ecx
  8006b0:	52                   	push   %edx
  8006b1:	50                   	push   %eax
  8006b2:	89 da                	mov    %ebx,%edx
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	e8 6e fb ff ff       	call   800229 <printnum>
			break;
  8006bb:	83 c4 20             	add    $0x20,%esp
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c1:	e9 a7 fc ff ff       	jmp    80036d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	51                   	push   %ecx
  8006cb:	ff d6                	call   *%esi
			break;
  8006cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d3:	e9 95 fc ff ff       	jmp    80036d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	6a 25                	push   $0x25
  8006de:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb 03                	jmp    8006e8 <vprintfmt+0x3a1>
  8006e5:	83 ef 01             	sub    $0x1,%edi
  8006e8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ec:	75 f7                	jne    8006e5 <vprintfmt+0x39e>
  8006ee:	e9 7a fc ff ff       	jmp    80036d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 18             	sub    $0x18,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 26                	je     800742 <vsnprintf+0x47>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 22                	jle    800742 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	ff 75 14             	pushl  0x14(%ebp)
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	68 0d 03 80 00       	push   $0x80030d
  80072f:	e8 13 fc ff ff       	call   800347 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	eb 05                	jmp    800747 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	50                   	push   %eax
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	ff 75 0c             	pushl  0xc(%ebp)
  800759:	ff 75 08             	pushl  0x8(%ebp)
  80075c:	e8 9a ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
  80076e:	eb 03                	jmp    800773 <strlen+0x10>
		n++;
  800770:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800773:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800777:	75 f7                	jne    800770 <strlen+0xd>
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800781:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	ba 00 00 00 00       	mov    $0x0,%edx
  800789:	eb 03                	jmp    80078e <strnlen+0x13>
		n++;
  80078b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	39 c2                	cmp    %eax,%edx
  800790:	74 08                	je     80079a <strnlen+0x1f>
  800792:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800796:	75 f3                	jne    80078b <strnlen+0x10>
  800798:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a6:	89 c2                	mov    %eax,%edx
  8007a8:	83 c2 01             	add    $0x1,%edx
  8007ab:	83 c1 01             	add    $0x1,%ecx
  8007ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b5:	84 db                	test   %bl,%bl
  8007b7:	75 ef                	jne    8007a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c3:	53                   	push   %ebx
  8007c4:	e8 9a ff ff ff       	call   800763 <strlen>
  8007c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	50                   	push   %eax
  8007d2:	e8 c5 ff ff ff       	call   80079c <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	89 f3                	mov    %esi,%ebx
  8007eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ee:	89 f2                	mov    %esi,%edx
  8007f0:	eb 0f                	jmp    800801 <strncpy+0x23>
		*dst++ = *src;
  8007f2:	83 c2 01             	add    $0x1,%edx
  8007f5:	0f b6 01             	movzbl (%ecx),%eax
  8007f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	39 da                	cmp    %ebx,%edx
  800803:	75 ed                	jne    8007f2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800805:	89 f0                	mov    %esi,%eax
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	8b 55 10             	mov    0x10(%ebp),%edx
  800819:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 21                	je     800840 <strlcpy+0x35>
  80081f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800823:	89 f2                	mov    %esi,%edx
  800825:	eb 09                	jmp    800830 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800830:	39 c2                	cmp    %eax,%edx
  800832:	74 09                	je     80083d <strlcpy+0x32>
  800834:	0f b6 19             	movzbl (%ecx),%ebx
  800837:	84 db                	test   %bl,%bl
  800839:	75 ec                	jne    800827 <strlcpy+0x1c>
  80083b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800840:	29 f0                	sub    %esi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084f:	eb 06                	jmp    800857 <strcmp+0x11>
		p++, q++;
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800857:	0f b6 01             	movzbl (%ecx),%eax
  80085a:	84 c0                	test   %al,%al
  80085c:	74 04                	je     800862 <strcmp+0x1c>
  80085e:	3a 02                	cmp    (%edx),%al
  800860:	74 ef                	je     800851 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800862:	0f b6 c0             	movzbl %al,%eax
  800865:	0f b6 12             	movzbl (%edx),%edx
  800868:	29 d0                	sub    %edx,%eax
}
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	53                   	push   %ebx
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 c3                	mov    %eax,%ebx
  800878:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087b:	eb 06                	jmp    800883 <strncmp+0x17>
		n--, p++, q++;
  80087d:	83 c0 01             	add    $0x1,%eax
  800880:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800883:	39 d8                	cmp    %ebx,%eax
  800885:	74 15                	je     80089c <strncmp+0x30>
  800887:	0f b6 08             	movzbl (%eax),%ecx
  80088a:	84 c9                	test   %cl,%cl
  80088c:	74 04                	je     800892 <strncmp+0x26>
  80088e:	3a 0a                	cmp    (%edx),%cl
  800890:	74 eb                	je     80087d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 00             	movzbl (%eax),%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
  80089a:	eb 05                	jmp    8008a1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ae:	eb 07                	jmp    8008b7 <strchr+0x13>
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 0f                	je     8008c3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	0f b6 10             	movzbl (%eax),%edx
  8008ba:	84 d2                	test   %dl,%dl
  8008bc:	75 f2                	jne    8008b0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cf:	eb 03                	jmp    8008d4 <strfind+0xf>
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	74 04                	je     8008df <strfind+0x1a>
  8008db:	38 ca                	cmp    %cl,%dl
  8008dd:	75 f2                	jne    8008d1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	57                   	push   %edi
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 36                	je     800927 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 28                	jne    800921 <memset+0x40>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 23                	jne    800921 <memset+0x40>
		c &= 0xFF;
  8008fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	89 d3                	mov    %edx,%ebx
  800904:	c1 e3 08             	shl    $0x8,%ebx
  800907:	89 d6                	mov    %edx,%esi
  800909:	c1 e6 18             	shl    $0x18,%esi
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	c1 e0 10             	shl    $0x10,%eax
  800911:	09 f0                	or     %esi,%eax
  800913:	09 c2                	or     %eax,%edx
  800915:	89 d0                	mov    %edx,%eax
  800917:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800919:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091c:	fc                   	cld    
  80091d:	f3 ab                	rep stos %eax,%es:(%edi)
  80091f:	eb 06                	jmp    800927 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800921:	8b 45 0c             	mov    0xc(%ebp),%eax
  800924:	fc                   	cld    
  800925:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800927:	89 f8                	mov    %edi,%eax
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5f                   	pop    %edi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 75 0c             	mov    0xc(%ebp),%esi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093c:	39 c6                	cmp    %eax,%esi
  80093e:	73 35                	jae    800975 <memmove+0x47>
  800940:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800943:	39 d0                	cmp    %edx,%eax
  800945:	73 2e                	jae    800975 <memmove+0x47>
		s += n;
		d += n;
  800947:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800954:	75 13                	jne    800969 <memmove+0x3b>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0e                	jne    800969 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095b:	83 ef 04             	sub    $0x4,%edi
  80095e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800961:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800964:	fd                   	std    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb 09                	jmp    800972 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800969:	83 ef 01             	sub    $0x1,%edi
  80096c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096f:	fd                   	std    
  800970:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800972:	fc                   	cld    
  800973:	eb 1d                	jmp    800992 <memmove+0x64>
  800975:	89 f2                	mov    %esi,%edx
  800977:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800979:	f6 c2 03             	test   $0x3,%dl
  80097c:	75 0f                	jne    80098d <memmove+0x5f>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0a                	jne    80098d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800983:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800999:	ff 75 10             	pushl  0x10(%ebp)
  80099c:	ff 75 0c             	pushl  0xc(%ebp)
  80099f:	ff 75 08             	pushl  0x8(%ebp)
  8009a2:	e8 87 ff ff ff       	call   80092e <memmove>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b4:	89 c6                	mov    %eax,%esi
  8009b6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b9:	eb 1a                	jmp    8009d5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009bb:	0f b6 08             	movzbl (%eax),%ecx
  8009be:	0f b6 1a             	movzbl (%edx),%ebx
  8009c1:	38 d9                	cmp    %bl,%cl
  8009c3:	74 0a                	je     8009cf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c5:	0f b6 c1             	movzbl %cl,%eax
  8009c8:	0f b6 db             	movzbl %bl,%ebx
  8009cb:	29 d8                	sub    %ebx,%eax
  8009cd:	eb 0f                	jmp    8009de <memcmp+0x35>
		s1++, s2++;
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	39 f0                	cmp    %esi,%eax
  8009d7:	75 e2                	jne    8009bb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009eb:	89 c2                	mov    %eax,%edx
  8009ed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f0:	eb 07                	jmp    8009f9 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f2:	38 08                	cmp    %cl,(%eax)
  8009f4:	74 07                	je     8009fd <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	72 f5                	jb     8009f2 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	eb 03                	jmp    800a10 <strtol+0x11>
		s++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	0f b6 01             	movzbl (%ecx),%eax
  800a13:	3c 09                	cmp    $0x9,%al
  800a15:	74 f6                	je     800a0d <strtol+0xe>
  800a17:	3c 20                	cmp    $0x20,%al
  800a19:	74 f2                	je     800a0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1b:	3c 2b                	cmp    $0x2b,%al
  800a1d:	75 0a                	jne    800a29 <strtol+0x2a>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb 10                	jmp    800a39 <strtol+0x3a>
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2e:	3c 2d                	cmp    $0x2d,%al
  800a30:	75 07                	jne    800a39 <strtol+0x3a>
		s++, neg = 1;
  800a32:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a35:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	0f 94 c0             	sete   %al
  800a3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a44:	75 19                	jne    800a5f <strtol+0x60>
  800a46:	80 39 30             	cmpb   $0x30,(%ecx)
  800a49:	75 14                	jne    800a5f <strtol+0x60>
  800a4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4f:	0f 85 82 00 00 00    	jne    800ad7 <strtol+0xd8>
		s += 2, base = 16;
  800a55:	83 c1 02             	add    $0x2,%ecx
  800a58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5d:	eb 16                	jmp    800a75 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5f:	84 c0                	test   %al,%al
  800a61:	74 12                	je     800a75 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a63:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a68:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6b:	75 08                	jne    800a75 <strtol+0x76>
		s++, base = 8;
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7d:	0f b6 11             	movzbl (%ecx),%edx
  800a80:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 09             	cmp    $0x9,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x93>
			dig = *s - '0';
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 30             	sub    $0x30,%edx
  800a90:	eb 22                	jmp    800ab4 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 08                	ja     800aa4 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a9c:	0f be d2             	movsbl %dl,%edx
  800a9f:	83 ea 57             	sub    $0x57,%edx
  800aa2:	eb 10                	jmp    800ab4 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aa4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa7:	89 f3                	mov    %esi,%ebx
  800aa9:	80 fb 19             	cmp    $0x19,%bl
  800aac:	77 16                	ja     800ac4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aae:	0f be d2             	movsbl %dl,%edx
  800ab1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab7:	7d 0f                	jge    800ac8 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac2:	eb b9                	jmp    800a7d <strtol+0x7e>
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	eb 02                	jmp    800aca <strtol+0xcb>
  800ac8:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ace:	74 0d                	je     800add <strtol+0xde>
		*endptr = (char *) s;
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad3:	89 0e                	mov    %ecx,(%esi)
  800ad5:	eb 06                	jmp    800add <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	84 c0                	test   %al,%al
  800ad9:	75 92                	jne    800a6d <strtol+0x6e>
  800adb:	eb 98                	jmp    800a75 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800add:	f7 da                	neg    %edx
  800adf:	85 ff                	test   %edi,%edi
  800ae1:	0f 45 c2             	cmovne %edx,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	89 c7                	mov    %eax,%edi
  800afe:	89 c6                	mov    %eax,%esi
  800b00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	b8 01 00 00 00       	mov    $0x1,%eax
  800b17:	89 d1                	mov    %edx,%ecx
  800b19:	89 d3                	mov    %edx,%ebx
  800b1b:	89 d7                	mov    %edx,%edi
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b34:	b8 03 00 00 00       	mov    $0x3,%eax
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	89 cb                	mov    %ecx,%ebx
  800b3e:	89 cf                	mov    %ecx,%edi
  800b40:	89 ce                	mov    %ecx,%esi
  800b42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b44:	85 c0                	test   %eax,%eax
  800b46:	7e 17                	jle    800b5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 03                	push   $0x3
  800b4e:	68 df 27 80 00       	push   $0x8027df
  800b53:	6a 22                	push   $0x22
  800b55:	68 fc 27 80 00       	push   $0x8027fc
  800b5a:	e8 dd f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 02 00 00 00       	mov    $0x2,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_yield>:

void
sys_yield(void)
{      
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b96:	89 d1                	mov    %edx,%ecx
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	89 d7                	mov    %edx,%edi
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bae:	be 00 00 00 00       	mov    $0x0,%esi
  800bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc1:	89 f7                	mov    %esi,%edi
  800bc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 17                	jle    800be0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 04                	push   $0x4
  800bcf:	68 df 27 80 00       	push   $0x8027df
  800bd4:	6a 22                	push   $0x22
  800bd6:	68 fc 27 80 00       	push   $0x8027fc
  800bdb:	e8 5c f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c02:	8b 75 18             	mov    0x18(%ebp),%esi
  800c05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 17                	jle    800c22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 05                	push   $0x5
  800c11:	68 df 27 80 00       	push   $0x8027df
  800c16:	6a 22                	push   $0x22
  800c18:	68 fc 27 80 00       	push   $0x8027fc
  800c1d:	e8 1a f5 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c38:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 df                	mov    %ebx,%edi
  800c45:	89 de                	mov    %ebx,%esi
  800c47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7e 17                	jle    800c64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 06                	push   $0x6
  800c53:	68 df 27 80 00       	push   $0x8027df
  800c58:	6a 22                	push   $0x22
  800c5a:	68 fc 27 80 00       	push   $0x8027fc
  800c5f:	e8 d8 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 df                	mov    %ebx,%edi
  800c87:	89 de                	mov    %ebx,%esi
  800c89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 17                	jle    800ca6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 08                	push   $0x8
  800c95:	68 df 27 80 00       	push   $0x8027df
  800c9a:	6a 22                	push   $0x22
  800c9c:	68 fc 27 80 00       	push   $0x8027fc
  800ca1:	e8 96 f4 ff ff       	call   80013c <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 df                	mov    %ebx,%edi
  800cc9:	89 de                	mov    %ebx,%esi
  800ccb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 09                	push   $0x9
  800cd7:	68 df 27 80 00       	push   $0x8027df
  800cdc:	6a 22                	push   $0x22
  800cde:	68 fc 27 80 00       	push   $0x8027fc
  800ce3:	e8 54 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 0a                	push   $0xa
  800d19:	68 df 27 80 00       	push   $0x8027df
  800d1e:	6a 22                	push   $0x22
  800d20:	68 fc 27 80 00       	push   $0x8027fc
  800d25:	e8 12 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d38:	be 00 00 00 00       	mov    $0x0,%esi
  800d3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 cb                	mov    %ecx,%ebx
  800d6d:	89 cf                	mov    %ecx,%edi
  800d6f:	89 ce                	mov    %ecx,%esi
  800d71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 17                	jle    800d8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	50                   	push   %eax
  800d7b:	6a 0d                	push   $0xd
  800d7d:	68 df 27 80 00       	push   $0x8027df
  800d82:	6a 22                	push   $0x22
  800d84:	68 fc 27 80 00       	push   $0x8027fc
  800d89:	e8 ae f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800da1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da6:	89 d1                	mov    %edx,%ecx
  800da8:	89 d3                	mov    %edx,%ebx
  800daa:	89 d7                	mov    %edx,%edi
  800dac:	89 d6                	mov    %edx,%esi
  800dae:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 cb                	mov    %ecx,%ebx
  800dcd:	89 cf                	mov    %ecx,%edi
  800dcf:	89 ce                	mov    %ecx,%esi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 0f                	push   $0xf
  800ddd:	68 df 27 80 00       	push   $0x8027df
  800de2:	6a 22                	push   $0x22
  800de4:	68 fc 27 80 00       	push   $0x8027fc
  800de9:	e8 4e f3 ff ff       	call   80013c <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_recv>:

int
sys_recv(void *addr)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e04:	b8 10 00 00 00       	mov    $0x10,%eax
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 cb                	mov    %ecx,%ebx
  800e0e:	89 cf                	mov    %ecx,%edi
  800e10:	89 ce                	mov    %ecx,%esi
  800e12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 17                	jle    800e2f <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 10                	push   $0x10
  800e1e:	68 df 27 80 00       	push   $0x8027df
  800e23:	6a 22                	push   $0x22
  800e25:	68 fc 27 80 00       	push   $0x8027fc
  800e2a:	e8 0d f3 ff ff       	call   80013c <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e42:	c1 e8 0c             	shr    $0xc,%eax
}
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e57:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e64:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 16             	shr    $0x16,%edx
  800e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	74 11                	je     800e8b <fd_alloc+0x2d>
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 0c             	shr    $0xc,%edx
  800e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	75 09                	jne    800e94 <fd_alloc+0x36>
			*fd_store = fd;
  800e8b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	eb 17                	jmp    800eab <fd_alloc+0x4d>
  800e94:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e99:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9e:	75 c9                	jne    800e69 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb3:	83 f8 1f             	cmp    $0x1f,%eax
  800eb6:	77 36                	ja     800eee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb8:	c1 e0 0c             	shl    $0xc,%eax
  800ebb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 16             	shr    $0x16,%edx
  800ec5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 24                	je     800ef5 <fd_lookup+0x48>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 0c             	shr    $0xc,%edx
  800ed6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	74 1a                	je     800efc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eec:	eb 13                	jmp    800f01 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb 0c                	jmp    800f01 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efa:	eb 05                	jmp    800f01 <fd_lookup+0x54>
  800efc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 08             	sub    $0x8,%esp
  800f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f11:	eb 13                	jmp    800f26 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f13:	39 08                	cmp    %ecx,(%eax)
  800f15:	75 0c                	jne    800f23 <dev_lookup+0x20>
			*dev = devtab[i];
  800f17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f21:	eb 36                	jmp    800f59 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f23:	83 c2 01             	add    $0x1,%edx
  800f26:	8b 04 95 8c 28 80 00 	mov    0x80288c(,%edx,4),%eax
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	75 e2                	jne    800f13 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f31:	a1 40 40 c0 00       	mov    0xc04040,%eax
  800f36:	8b 40 48             	mov    0x48(%eax),%eax
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	51                   	push   %ecx
  800f3d:	50                   	push   %eax
  800f3e:	68 0c 28 80 00       	push   $0x80280c
  800f43:	e8 cd f2 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 10             	sub    $0x10,%esp
  800f63:	8b 75 08             	mov    0x8(%ebp),%esi
  800f66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f6d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f73:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f76:	50                   	push   %eax
  800f77:	e8 31 ff ff ff       	call   800ead <fd_lookup>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 05                	js     800f88 <fd_close+0x2d>
	    || fd != fd2)
  800f83:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f86:	74 0c                	je     800f94 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f88:	84 db                	test   %bl,%bl
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	0f 44 c2             	cmove  %edx,%eax
  800f92:	eb 41                	jmp    800fd5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 36                	pushl  (%esi)
  800f9d:	e8 61 ff ff ff       	call   800f03 <dev_lookup>
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 1a                	js     800fc5 <fd_close+0x6a>
		if (dev->dev_close)
  800fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fae:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	74 0b                	je     800fc5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	56                   	push   %esi
  800fbe:	ff d0                	call   *%eax
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 5a fc ff ff       	call   800c2a <sys_page_unmap>
	return r;
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	89 d8                	mov    %ebx,%eax
}
  800fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 bf fe ff ff       	call   800ead <fd_lookup>
  800fee:	89 c2                	mov    %eax,%edx
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	85 d2                	test   %edx,%edx
  800ff5:	78 10                	js     801007 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	6a 01                	push   $0x1
  800ffc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fff:	e8 57 ff ff ff       	call   800f5b <fd_close>
  801004:	83 c4 10             	add    $0x10,%esp
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <close_all>:

void
close_all(void)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	53                   	push   %ebx
  80100d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801010:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	53                   	push   %ebx
  801019:	e8 be ff ff ff       	call   800fdc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80101e:	83 c3 01             	add    $0x1,%ebx
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	83 fb 20             	cmp    $0x20,%ebx
  801027:	75 ec                	jne    801015 <close_all+0xc>
		close(i);
}
  801029:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 2c             	sub    $0x2c,%esp
  801037:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80103a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 67 fe ff ff       	call   800ead <fd_lookup>
  801046:	89 c2                	mov    %eax,%edx
  801048:	83 c4 08             	add    $0x8,%esp
  80104b:	85 d2                	test   %edx,%edx
  80104d:	0f 88 c1 00 00 00    	js     801114 <dup+0xe6>
		return r;
	close(newfdnum);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	56                   	push   %esi
  801057:	e8 80 ff ff ff       	call   800fdc <close>

	newfd = INDEX2FD(newfdnum);
  80105c:	89 f3                	mov    %esi,%ebx
  80105e:	c1 e3 0c             	shl    $0xc,%ebx
  801061:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801067:	83 c4 04             	add    $0x4,%esp
  80106a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106d:	e8 d5 fd ff ff       	call   800e47 <fd2data>
  801072:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801074:	89 1c 24             	mov    %ebx,(%esp)
  801077:	e8 cb fd ff ff       	call   800e47 <fd2data>
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801082:	89 f8                	mov    %edi,%eax
  801084:	c1 e8 16             	shr    $0x16,%eax
  801087:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108e:	a8 01                	test   $0x1,%al
  801090:	74 37                	je     8010c9 <dup+0x9b>
  801092:	89 f8                	mov    %edi,%eax
  801094:	c1 e8 0c             	shr    $0xc,%eax
  801097:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	74 26                	je     8010c9 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b2:	50                   	push   %eax
  8010b3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b6:	6a 00                	push   $0x0
  8010b8:	57                   	push   %edi
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 28 fb ff ff       	call   800be8 <sys_page_map>
  8010c0:	89 c7                	mov    %eax,%edi
  8010c2:	83 c4 20             	add    $0x20,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 2e                	js     8010f7 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010cc:	89 d0                	mov    %edx,%eax
  8010ce:	c1 e8 0c             	shr    $0xc,%eax
  8010d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e0:	50                   	push   %eax
  8010e1:	53                   	push   %ebx
  8010e2:	6a 00                	push   $0x0
  8010e4:	52                   	push   %edx
  8010e5:	6a 00                	push   $0x0
  8010e7:	e8 fc fa ff ff       	call   800be8 <sys_page_map>
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010f1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f3:	85 ff                	test   %edi,%edi
  8010f5:	79 1d                	jns    801114 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	53                   	push   %ebx
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 28 fb ff ff       	call   800c2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801102:	83 c4 08             	add    $0x8,%esp
  801105:	ff 75 d4             	pushl  -0x2c(%ebp)
  801108:	6a 00                	push   $0x0
  80110a:	e8 1b fb ff ff       	call   800c2a <sys_page_unmap>
	return r;
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	89 f8                	mov    %edi,%eax
}
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	53                   	push   %ebx
  801120:	83 ec 14             	sub    $0x14,%esp
  801123:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801126:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	53                   	push   %ebx
  80112b:	e8 7d fd ff ff       	call   800ead <fd_lookup>
  801130:	83 c4 08             	add    $0x8,%esp
  801133:	89 c2                	mov    %eax,%edx
  801135:	85 c0                	test   %eax,%eax
  801137:	78 6d                	js     8011a6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113f:	50                   	push   %eax
  801140:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801143:	ff 30                	pushl  (%eax)
  801145:	e8 b9 fd ff ff       	call   800f03 <dev_lookup>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 4c                	js     80119d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801151:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801154:	8b 42 08             	mov    0x8(%edx),%eax
  801157:	83 e0 03             	and    $0x3,%eax
  80115a:	83 f8 01             	cmp    $0x1,%eax
  80115d:	75 21                	jne    801180 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115f:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801164:	8b 40 48             	mov    0x48(%eax),%eax
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	53                   	push   %ebx
  80116b:	50                   	push   %eax
  80116c:	68 50 28 80 00       	push   $0x802850
  801171:	e8 9f f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117e:	eb 26                	jmp    8011a6 <read+0x8a>
	}
	if (!dev->dev_read)
  801180:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801183:	8b 40 08             	mov    0x8(%eax),%eax
  801186:	85 c0                	test   %eax,%eax
  801188:	74 17                	je     8011a1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	ff 75 10             	pushl  0x10(%ebp)
  801190:	ff 75 0c             	pushl  0xc(%ebp)
  801193:	52                   	push   %edx
  801194:	ff d0                	call   *%eax
  801196:	89 c2                	mov    %eax,%edx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	eb 09                	jmp    8011a6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	eb 05                	jmp    8011a6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011a6:	89 d0                	mov    %edx,%eax
  8011a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	57                   	push   %edi
  8011b1:	56                   	push   %esi
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c1:	eb 21                	jmp    8011e4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	89 f0                	mov    %esi,%eax
  8011c8:	29 d8                	sub    %ebx,%eax
  8011ca:	50                   	push   %eax
  8011cb:	89 d8                	mov    %ebx,%eax
  8011cd:	03 45 0c             	add    0xc(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	57                   	push   %edi
  8011d2:	e8 45 ff ff ff       	call   80111c <read>
		if (m < 0)
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 0c                	js     8011ea <readn+0x3d>
			return m;
		if (m == 0)
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 06                	je     8011e8 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e2:	01 c3                	add    %eax,%ebx
  8011e4:	39 f3                	cmp    %esi,%ebx
  8011e6:	72 db                	jb     8011c3 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011e8:	89 d8                	mov    %ebx,%eax
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 14             	sub    $0x14,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	53                   	push   %ebx
  801201:	e8 a7 fc ff ff       	call   800ead <fd_lookup>
  801206:	83 c4 08             	add    $0x8,%esp
  801209:	89 c2                	mov    %eax,%edx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 68                	js     801277 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	ff 30                	pushl  (%eax)
  80121b:	e8 e3 fc ff ff       	call   800f03 <dev_lookup>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 47                	js     80126e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122e:	75 21                	jne    801251 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801230:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801235:	8b 40 48             	mov    0x48(%eax),%eax
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	53                   	push   %ebx
  80123c:	50                   	push   %eax
  80123d:	68 6c 28 80 00       	push   $0x80286c
  801242:	e8 ce ef ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124f:	eb 26                	jmp    801277 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801251:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801254:	8b 52 0c             	mov    0xc(%edx),%edx
  801257:	85 d2                	test   %edx,%edx
  801259:	74 17                	je     801272 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	ff 75 10             	pushl  0x10(%ebp)
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	50                   	push   %eax
  801265:	ff d2                	call   *%edx
  801267:	89 c2                	mov    %eax,%edx
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	eb 09                	jmp    801277 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	89 c2                	mov    %eax,%edx
  801270:	eb 05                	jmp    801277 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801272:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801277:	89 d0                	mov    %edx,%eax
  801279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <seek>:

int
seek(int fdnum, off_t offset)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801284:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 1d fc ff ff       	call   800ead <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 0e                	js     8012a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801297:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80129a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 14             	sub    $0x14,%esp
  8012ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	53                   	push   %ebx
  8012b6:	e8 f2 fb ff ff       	call   800ead <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 65                	js     801329 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	ff 30                	pushl  (%eax)
  8012d0:	e8 2e fc ff ff       	call   800f03 <dev_lookup>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 44                	js     801320 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e3:	75 21                	jne    801306 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e5:	a1 40 40 c0 00       	mov    0xc04040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	53                   	push   %ebx
  8012f1:	50                   	push   %eax
  8012f2:	68 2c 28 80 00       	push   $0x80282c
  8012f7:	e8 19 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801304:	eb 23                	jmp    801329 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801306:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801309:	8b 52 18             	mov    0x18(%edx),%edx
  80130c:	85 d2                	test   %edx,%edx
  80130e:	74 14                	je     801324 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	ff 75 0c             	pushl  0xc(%ebp)
  801316:	50                   	push   %eax
  801317:	ff d2                	call   *%edx
  801319:	89 c2                	mov    %eax,%edx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	eb 09                	jmp    801329 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	89 c2                	mov    %eax,%edx
  801322:	eb 05                	jmp    801329 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801324:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801329:	89 d0                	mov    %edx,%eax
  80132b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132e:	c9                   	leave  
  80132f:	c3                   	ret    

00801330 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 14             	sub    $0x14,%esp
  801337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	ff 75 08             	pushl  0x8(%ebp)
  801341:	e8 67 fb ff ff       	call   800ead <fd_lookup>
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	89 c2                	mov    %eax,%edx
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 58                	js     8013a7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801359:	ff 30                	pushl  (%eax)
  80135b:	e8 a3 fb ff ff       	call   800f03 <dev_lookup>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 37                	js     80139e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801367:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80136e:	74 32                	je     8013a2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801370:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801373:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137a:	00 00 00 
	stat->st_isdir = 0;
  80137d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801384:	00 00 00 
	stat->st_dev = dev;
  801387:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	53                   	push   %ebx
  801391:	ff 75 f0             	pushl  -0x10(%ebp)
  801394:	ff 50 14             	call   *0x14(%eax)
  801397:	89 c2                	mov    %eax,%edx
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	eb 09                	jmp    8013a7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	eb 05                	jmp    8013a7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a7:	89 d0                	mov    %edx,%eax
  8013a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	6a 00                	push   $0x0
  8013b8:	ff 75 08             	pushl  0x8(%ebp)
  8013bb:	e8 09 02 00 00       	call   8015c9 <open>
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 db                	test   %ebx,%ebx
  8013c7:	78 1b                	js     8013e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	ff 75 0c             	pushl  0xc(%ebp)
  8013cf:	53                   	push   %ebx
  8013d0:	e8 5b ff ff ff       	call   801330 <fstat>
  8013d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d7:	89 1c 24             	mov    %ebx,(%esp)
  8013da:	e8 fd fb ff ff       	call   800fdc <close>
	return r;
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	89 f0                	mov    %esi,%eax
}
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	89 c6                	mov    %eax,%esi
  8013f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013fb:	75 12                	jne    80140f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	6a 01                	push   $0x1
  801402:	e8 70 0c 00 00       	call   802077 <ipc_find_env>
  801407:	a3 00 40 80 00       	mov    %eax,0x804000
  80140c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80140f:	6a 07                	push   $0x7
  801411:	68 00 50 c0 00       	push   $0xc05000
  801416:	56                   	push   %esi
  801417:	ff 35 00 40 80 00    	pushl  0x804000
  80141d:	e8 01 0c 00 00       	call   802023 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801422:	83 c4 0c             	add    $0xc,%esp
  801425:	6a 00                	push   $0x0
  801427:	53                   	push   %ebx
  801428:	6a 00                	push   $0x0
  80142a:	e8 8b 0b 00 00       	call   801fba <ipc_recv>
}
  80142f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801432:	5b                   	pop    %ebx
  801433:	5e                   	pop    %esi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	8b 40 0c             	mov    0xc(%eax),%eax
  801442:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801447:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144a:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	b8 02 00 00 00       	mov    $0x2,%eax
  801459:	e8 8d ff ff ff       	call   8013eb <fsipc>
}
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
  801469:	8b 40 0c             	mov    0xc(%eax),%eax
  80146c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801471:	ba 00 00 00 00       	mov    $0x0,%edx
  801476:	b8 06 00 00 00       	mov    $0x6,%eax
  80147b:	e8 6b ff ff ff       	call   8013eb <fsipc>
}
  801480:	c9                   	leave  
  801481:	c3                   	ret    

00801482 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	53                   	push   %ebx
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	8b 40 0c             	mov    0xc(%eax),%eax
  801492:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a1:	e8 45 ff ff ff       	call   8013eb <fsipc>
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	85 d2                	test   %edx,%edx
  8014aa:	78 2c                	js     8014d8 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	68 00 50 c0 00       	push   $0xc05000
  8014b4:	53                   	push   %ebx
  8014b5:	e8 e2 f2 ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ba:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c5:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014ca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ef:	a3 00 50 c0 00       	mov    %eax,0xc05000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014f7:	eb 3d                	jmp    801536 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014f9:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014ff:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801504:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	57                   	push   %edi
  80150b:	53                   	push   %ebx
  80150c:	68 08 50 c0 00       	push   $0xc05008
  801511:	e8 18 f4 ff ff       	call   80092e <memmove>
                fsipcbuf.write.req_n = tmp; 
  801516:	89 3d 04 50 c0 00    	mov    %edi,0xc05004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	b8 04 00 00 00       	mov    $0x4,%eax
  801526:	e8 c0 fe ff ff       	call   8013eb <fsipc>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 0d                	js     80153f <devfile_write+0x62>
		        return r;
                n -= tmp;
  801532:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801534:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801536:	85 f6                	test   %esi,%esi
  801538:	75 bf                	jne    8014f9 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80153a:	89 d8                	mov    %ebx,%eax
  80153c:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80153f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801542:	5b                   	pop    %ebx
  801543:	5e                   	pop    %esi
  801544:	5f                   	pop    %edi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
  80154c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154f:	8b 45 08             	mov    0x8(%ebp),%eax
  801552:	8b 40 0c             	mov    0xc(%eax),%eax
  801555:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80155a:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	b8 03 00 00 00       	mov    $0x3,%eax
  80156a:	e8 7c fe ff ff       	call   8013eb <fsipc>
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	85 c0                	test   %eax,%eax
  801573:	78 4b                	js     8015c0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801575:	39 c6                	cmp    %eax,%esi
  801577:	73 16                	jae    80158f <devfile_read+0x48>
  801579:	68 a0 28 80 00       	push   $0x8028a0
  80157e:	68 a7 28 80 00       	push   $0x8028a7
  801583:	6a 7c                	push   $0x7c
  801585:	68 bc 28 80 00       	push   $0x8028bc
  80158a:	e8 ad eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  80158f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801594:	7e 16                	jle    8015ac <devfile_read+0x65>
  801596:	68 c7 28 80 00       	push   $0x8028c7
  80159b:	68 a7 28 80 00       	push   $0x8028a7
  8015a0:	6a 7d                	push   $0x7d
  8015a2:	68 bc 28 80 00       	push   $0x8028bc
  8015a7:	e8 90 eb ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	50                   	push   %eax
  8015b0:	68 00 50 c0 00       	push   $0xc05000
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	e8 71 f3 ff ff       	call   80092e <memmove>
	return r;
  8015bd:	83 c4 10             	add    $0x10,%esp
}
  8015c0:	89 d8                	mov    %ebx,%eax
  8015c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 20             	sub    $0x20,%esp
  8015d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d3:	53                   	push   %ebx
  8015d4:	e8 8a f1 ff ff       	call   800763 <strlen>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e1:	7f 67                	jg     80164a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	e8 6f f8 ff ff       	call   800e5e <fd_alloc>
  8015ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 57                	js     80164f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	68 00 50 c0 00       	push   $0xc05000
  801601:	e8 96 f1 ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801606:	8b 45 0c             	mov    0xc(%ebp),%eax
  801609:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801611:	b8 01 00 00 00       	mov    $0x1,%eax
  801616:	e8 d0 fd ff ff       	call   8013eb <fsipc>
  80161b:	89 c3                	mov    %eax,%ebx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	79 14                	jns    801638 <open+0x6f>
		fd_close(fd, 0);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	6a 00                	push   $0x0
  801629:	ff 75 f4             	pushl  -0xc(%ebp)
  80162c:	e8 2a f9 ff ff       	call   800f5b <fd_close>
		return r;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	89 da                	mov    %ebx,%edx
  801636:	eb 17                	jmp    80164f <open+0x86>
	}

	return fd2num(fd);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	ff 75 f4             	pushl  -0xc(%ebp)
  80163e:	e8 f4 f7 ff ff       	call   800e37 <fd2num>
  801643:	89 c2                	mov    %eax,%edx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 05                	jmp    80164f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164f:	89 d0                	mov    %edx,%eax
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165c:	ba 00 00 00 00       	mov    $0x0,%edx
  801661:	b8 08 00 00 00       	mov    $0x8,%eax
  801666:	e8 80 fd ff ff       	call   8013eb <fsipc>
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801673:	68 d3 28 80 00       	push   $0x8028d3
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	e8 1c f1 ff ff       	call   80079c <strcpy>
	return 0;
}
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 10             	sub    $0x10,%esp
  80168e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801691:	53                   	push   %ebx
  801692:	e8 18 0a 00 00       	call   8020af <pageref>
  801697:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80169a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80169f:	83 f8 01             	cmp    $0x1,%eax
  8016a2:	75 10                	jne    8016b4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016a4:	83 ec 0c             	sub    $0xc,%esp
  8016a7:	ff 73 0c             	pushl  0xc(%ebx)
  8016aa:	e8 ca 02 00 00       	call   801979 <nsipc_close>
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016b4:	89 d0                	mov    %edx,%eax
  8016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016c1:	6a 00                	push   $0x0
  8016c3:	ff 75 10             	pushl  0x10(%ebp)
  8016c6:	ff 75 0c             	pushl  0xc(%ebp)
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	ff 70 0c             	pushl  0xc(%eax)
  8016cf:	e8 82 03 00 00       	call   801a56 <nsipc_send>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016dc:	6a 00                	push   $0x0
  8016de:	ff 75 10             	pushl  0x10(%ebp)
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	ff 70 0c             	pushl  0xc(%eax)
  8016ea:	e8 fb 02 00 00       	call   8019ea <nsipc_recv>
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016f7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016fa:	52                   	push   %edx
  8016fb:	50                   	push   %eax
  8016fc:	e8 ac f7 ff ff       	call   800ead <fd_lookup>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	78 17                	js     80171f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801711:	39 08                	cmp    %ecx,(%eax)
  801713:	75 05                	jne    80171a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	eb 05                	jmp    80171f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80171a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	83 ec 1c             	sub    $0x1c,%esp
  801729:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	e8 2a f7 ff ff       	call   800e5e <fd_alloc>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 1b                	js     801758 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	68 07 04 00 00       	push   $0x407
  801745:	ff 75 f4             	pushl  -0xc(%ebp)
  801748:	6a 00                	push   $0x0
  80174a:	e8 56 f4 ff ff       	call   800ba5 <sys_page_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	79 10                	jns    801768 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	56                   	push   %esi
  80175c:	e8 18 02 00 00       	call   801979 <nsipc_close>
		return r;
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	89 d8                	mov    %ebx,%eax
  801766:	eb 24                	jmp    80178c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801768:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801771:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801773:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801776:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  80177d:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801780:	83 ec 0c             	sub    $0xc,%esp
  801783:	52                   	push   %edx
  801784:	e8 ae f6 ff ff       	call   800e37 <fd2num>
  801789:	83 c4 10             	add    $0x10,%esp
}
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	e8 50 ff ff ff       	call   8016f1 <fd2sockid>
		return r;
  8017a1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 1f                	js     8017c6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	ff 75 10             	pushl  0x10(%ebp)
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	50                   	push   %eax
  8017b1:	e8 1c 01 00 00       	call   8018d2 <nsipc_accept>
  8017b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 07                	js     8017c6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017bf:	e8 5d ff ff ff       	call   801721 <alloc_sockfd>
  8017c4:	89 c1                	mov    %eax,%ecx
}
  8017c6:	89 c8                	mov    %ecx,%eax
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	e8 19 ff ff ff       	call   8016f1 <fd2sockid>
  8017d8:	89 c2                	mov    %eax,%edx
  8017da:	85 d2                	test   %edx,%edx
  8017dc:	78 12                	js     8017f0 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	ff 75 10             	pushl  0x10(%ebp)
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	52                   	push   %edx
  8017e8:	e8 35 01 00 00       	call   801922 <nsipc_bind>
  8017ed:	83 c4 10             	add    $0x10,%esp
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <shutdown>:

int
shutdown(int s, int how)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	e8 f1 fe ff ff       	call   8016f1 <fd2sockid>
  801800:	89 c2                	mov    %eax,%edx
  801802:	85 d2                	test   %edx,%edx
  801804:	78 0f                	js     801815 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	ff 75 0c             	pushl  0xc(%ebp)
  80180c:	52                   	push   %edx
  80180d:	e8 45 01 00 00       	call   801957 <nsipc_shutdown>
  801812:	83 c4 10             	add    $0x10,%esp
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	e8 cc fe ff ff       	call   8016f1 <fd2sockid>
  801825:	89 c2                	mov    %eax,%edx
  801827:	85 d2                	test   %edx,%edx
  801829:	78 12                	js     80183d <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	ff 75 10             	pushl  0x10(%ebp)
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	52                   	push   %edx
  801835:	e8 59 01 00 00       	call   801993 <nsipc_connect>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <listen>:

int
listen(int s, int backlog)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	e8 a4 fe ff ff       	call   8016f1 <fd2sockid>
  80184d:	89 c2                	mov    %eax,%edx
  80184f:	85 d2                	test   %edx,%edx
  801851:	78 0f                	js     801862 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	ff 75 0c             	pushl  0xc(%ebp)
  801859:	52                   	push   %edx
  80185a:	e8 69 01 00 00       	call   8019c8 <nsipc_listen>
  80185f:	83 c4 10             	add    $0x10,%esp
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80186a:	ff 75 10             	pushl  0x10(%ebp)
  80186d:	ff 75 0c             	pushl  0xc(%ebp)
  801870:	ff 75 08             	pushl  0x8(%ebp)
  801873:	e8 3c 02 00 00       	call   801ab4 <nsipc_socket>
  801878:	89 c2                	mov    %eax,%edx
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	85 d2                	test   %edx,%edx
  80187f:	78 05                	js     801886 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801881:	e8 9b fe ff ff       	call   801721 <alloc_sockfd>
}
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	53                   	push   %ebx
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801891:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801898:	75 12                	jne    8018ac <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	6a 02                	push   $0x2
  80189f:	e8 d3 07 00 00       	call   802077 <ipc_find_env>
  8018a4:	a3 04 40 80 00       	mov    %eax,0x804004
  8018a9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018ac:	6a 07                	push   $0x7
  8018ae:	68 00 60 c0 00       	push   $0xc06000
  8018b3:	53                   	push   %ebx
  8018b4:	ff 35 04 40 80 00    	pushl  0x804004
  8018ba:	e8 64 07 00 00       	call   802023 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018bf:	83 c4 0c             	add    $0xc,%esp
  8018c2:	6a 00                	push   $0x0
  8018c4:	6a 00                	push   $0x0
  8018c6:	6a 00                	push   $0x0
  8018c8:	e8 ed 06 00 00       	call   801fba <ipc_recv>
}
  8018cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018e2:	8b 06                	mov    (%esi),%eax
  8018e4:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ee:	e8 95 ff ff ff       	call   801888 <nsipc>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 20                	js     801919 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018f9:	83 ec 04             	sub    $0x4,%esp
  8018fc:	ff 35 10 60 c0 00    	pushl  0xc06010
  801902:	68 00 60 c0 00       	push   $0xc06000
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	e8 1f f0 ff ff       	call   80092e <memmove>
		*addrlen = ret->ret_addrlen;
  80190f:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801914:	89 06                	mov    %eax,(%esi)
  801916:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801919:	89 d8                	mov    %ebx,%eax
  80191b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	53                   	push   %ebx
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801934:	53                   	push   %ebx
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	68 04 60 c0 00       	push   $0xc06004
  80193d:	e8 ec ef ff ff       	call   80092e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801942:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801948:	b8 02 00 00 00       	mov    $0x2,%eax
  80194d:	e8 36 ff ff ff       	call   801888 <nsipc>
}
  801952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  801965:	8b 45 0c             	mov    0xc(%ebp),%eax
  801968:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  80196d:	b8 03 00 00 00       	mov    $0x3,%eax
  801972:	e8 11 ff ff ff       	call   801888 <nsipc>
}
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <nsipc_close>:

int
nsipc_close(int s)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  801987:	b8 04 00 00 00       	mov    $0x4,%eax
  80198c:	e8 f7 fe ff ff       	call   801888 <nsipc>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019a5:	53                   	push   %ebx
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	68 04 60 c0 00       	push   $0xc06004
  8019ae:	e8 7b ef ff ff       	call   80092e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019b3:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  8019b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019be:	e8 c5 fe ff ff       	call   801888 <nsipc>
}
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  8019d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d9:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  8019de:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e3:	e8 a0 fe ff ff       	call   801888 <nsipc>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f5:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  8019fa:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801a00:	8b 45 14             	mov    0x14(%ebp),%eax
  801a03:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a08:	b8 07 00 00 00       	mov    $0x7,%eax
  801a0d:	e8 76 fe ff ff       	call   801888 <nsipc>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 35                	js     801a4d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a18:	39 f0                	cmp    %esi,%eax
  801a1a:	7f 07                	jg     801a23 <nsipc_recv+0x39>
  801a1c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a21:	7e 16                	jle    801a39 <nsipc_recv+0x4f>
  801a23:	68 df 28 80 00       	push   $0x8028df
  801a28:	68 a7 28 80 00       	push   $0x8028a7
  801a2d:	6a 62                	push   $0x62
  801a2f:	68 f4 28 80 00       	push   $0x8028f4
  801a34:	e8 03 e7 ff ff       	call   80013c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a39:	83 ec 04             	sub    $0x4,%esp
  801a3c:	50                   	push   %eax
  801a3d:	68 00 60 c0 00       	push   $0xc06000
  801a42:	ff 75 0c             	pushl  0xc(%ebp)
  801a45:	e8 e4 ee ff ff       	call   80092e <memmove>
  801a4a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a4d:	89 d8                	mov    %ebx,%eax
  801a4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a52:	5b                   	pop    %ebx
  801a53:	5e                   	pop    %esi
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 04             	sub    $0x4,%esp
  801a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801a68:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a6e:	7e 16                	jle    801a86 <nsipc_send+0x30>
  801a70:	68 00 29 80 00       	push   $0x802900
  801a75:	68 a7 28 80 00       	push   $0x8028a7
  801a7a:	6a 6d                	push   $0x6d
  801a7c:	68 f4 28 80 00       	push   $0x8028f4
  801a81:	e8 b6 e6 ff ff       	call   80013c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a86:	83 ec 04             	sub    $0x4,%esp
  801a89:	53                   	push   %ebx
  801a8a:	ff 75 0c             	pushl  0xc(%ebp)
  801a8d:	68 0c 60 c0 00       	push   $0xc0600c
  801a92:	e8 97 ee ff ff       	call   80092e <memmove>
	nsipcbuf.send.req_size = size;
  801a97:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa0:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801aa5:	b8 08 00 00 00       	mov    $0x8,%eax
  801aaa:	e8 d9 fd ff ff       	call   801888 <nsipc>
}
  801aaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac5:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801aca:	8b 45 10             	mov    0x10(%ebp),%eax
  801acd:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801ad2:	b8 09 00 00 00       	mov    $0x9,%eax
  801ad7:	e8 ac fd ff ff       	call   801888 <nsipc>
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	ff 75 08             	pushl  0x8(%ebp)
  801aec:	e8 56 f3 ff ff       	call   800e47 <fd2data>
  801af1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801af3:	83 c4 08             	add    $0x8,%esp
  801af6:	68 0c 29 80 00       	push   $0x80290c
  801afb:	53                   	push   %ebx
  801afc:	e8 9b ec ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b01:	8b 56 04             	mov    0x4(%esi),%edx
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	2b 06                	sub    (%esi),%eax
  801b08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b0e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b15:	00 00 00 
	stat->st_dev = &devpipe;
  801b18:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b1f:	30 80 00 
	return 0;
}
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
  801b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	53                   	push   %ebx
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b38:	53                   	push   %ebx
  801b39:	6a 00                	push   $0x0
  801b3b:	e8 ea f0 ff ff       	call   800c2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b40:	89 1c 24             	mov    %ebx,(%esp)
  801b43:	e8 ff f2 ff ff       	call   800e47 <fd2data>
  801b48:	83 c4 08             	add    $0x8,%esp
  801b4b:	50                   	push   %eax
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 d7 f0 ff ff       	call   800c2a <sys_page_unmap>
}
  801b53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	57                   	push   %edi
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
  801b5e:	83 ec 1c             	sub    $0x1c,%esp
  801b61:	89 c6                	mov    %eax,%esi
  801b63:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b66:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801b6b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	56                   	push   %esi
  801b72:	e8 38 05 00 00       	call   8020af <pageref>
  801b77:	89 c7                	mov    %eax,%edi
  801b79:	83 c4 04             	add    $0x4,%esp
  801b7c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b7f:	e8 2b 05 00 00       	call   8020af <pageref>
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	39 c7                	cmp    %eax,%edi
  801b89:	0f 94 c2             	sete   %dl
  801b8c:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801b8f:	8b 0d 40 40 c0 00    	mov    0xc04040,%ecx
  801b95:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801b98:	39 fb                	cmp    %edi,%ebx
  801b9a:	74 19                	je     801bb5 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801b9c:	84 d2                	test   %dl,%dl
  801b9e:	74 c6                	je     801b66 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba0:	8b 51 58             	mov    0x58(%ecx),%edx
  801ba3:	50                   	push   %eax
  801ba4:	52                   	push   %edx
  801ba5:	53                   	push   %ebx
  801ba6:	68 13 29 80 00       	push   $0x802913
  801bab:	e8 65 e6 ff ff       	call   800215 <cprintf>
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	eb b1                	jmp    801b66 <_pipeisclosed+0xe>
	}
}
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 28             	sub    $0x28,%esp
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc9:	56                   	push   %esi
  801bca:	e8 78 f2 ff ff       	call   800e47 <fd2data>
  801bcf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd9:	eb 4b                	jmp    801c26 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdb:	89 da                	mov    %ebx,%edx
  801bdd:	89 f0                	mov    %esi,%eax
  801bdf:	e8 74 ff ff ff       	call   801b58 <_pipeisclosed>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	75 48                	jne    801c30 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be8:	e8 99 ef ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bed:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf0:	8b 0b                	mov    (%ebx),%ecx
  801bf2:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf5:	39 d0                	cmp    %edx,%eax
  801bf7:	73 e2                	jae    801bdb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	c1 fa 1f             	sar    $0x1f,%edx
  801c08:	89 d1                	mov    %edx,%ecx
  801c0a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c10:	83 e2 1f             	and    $0x1f,%edx
  801c13:	29 ca                	sub    %ecx,%edx
  801c15:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1d:	83 c0 01             	add    $0x1,%eax
  801c20:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c23:	83 c7 01             	add    $0x1,%edi
  801c26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c29:	75 c2                	jne    801bed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2e:	eb 05                	jmp    801c35 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5f                   	pop    %edi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	57                   	push   %edi
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	83 ec 18             	sub    $0x18,%esp
  801c46:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c49:	57                   	push   %edi
  801c4a:	e8 f8 f1 ff ff       	call   800e47 <fd2data>
  801c4f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c59:	eb 3d                	jmp    801c98 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5b:	85 db                	test   %ebx,%ebx
  801c5d:	74 04                	je     801c63 <devpipe_read+0x26>
				return i;
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	eb 44                	jmp    801ca7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c63:	89 f2                	mov    %esi,%edx
  801c65:	89 f8                	mov    %edi,%eax
  801c67:	e8 ec fe ff ff       	call   801b58 <_pipeisclosed>
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	75 32                	jne    801ca2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c70:	e8 11 ef ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c75:	8b 06                	mov    (%esi),%eax
  801c77:	3b 46 04             	cmp    0x4(%esi),%eax
  801c7a:	74 df                	je     801c5b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7c:	99                   	cltd   
  801c7d:	c1 ea 1b             	shr    $0x1b,%edx
  801c80:	01 d0                	add    %edx,%eax
  801c82:	83 e0 1f             	and    $0x1f,%eax
  801c85:	29 d0                	sub    %edx,%eax
  801c87:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c92:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c95:	83 c3 01             	add    $0x1,%ebx
  801c98:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c9b:	75 d8                	jne    801c75 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca0:	eb 05                	jmp    801ca7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cba:	50                   	push   %eax
  801cbb:	e8 9e f1 ff ff       	call   800e5e <fd_alloc>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	0f 88 2c 01 00 00    	js     801df9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 c6 ee ff ff       	call   800ba5 <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 0d 01 00 00    	js     801df9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf2:	50                   	push   %eax
  801cf3:	e8 66 f1 ff ff       	call   800e5e <fd_alloc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	0f 88 e2 00 00 00    	js     801de7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 8e ee ff ff       	call   800ba5 <sys_page_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	0f 88 c3 00 00 00    	js     801de7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	e8 18 f1 ff ff       	call   800e47 <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d31:	83 c4 0c             	add    $0xc,%esp
  801d34:	68 07 04 00 00       	push   $0x407
  801d39:	50                   	push   %eax
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 64 ee ff ff       	call   800ba5 <sys_page_alloc>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	85 c0                	test   %eax,%eax
  801d48:	0f 88 89 00 00 00    	js     801dd7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	83 ec 0c             	sub    $0xc,%esp
  801d51:	ff 75 f0             	pushl  -0x10(%ebp)
  801d54:	e8 ee f0 ff ff       	call   800e47 <fd2data>
  801d59:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d60:	50                   	push   %eax
  801d61:	6a 00                	push   $0x0
  801d63:	56                   	push   %esi
  801d64:	6a 00                	push   $0x0
  801d66:	e8 7d ee ff ff       	call   800be8 <sys_page_map>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 20             	add    $0x20,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 55                	js     801dc9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d74:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d97:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 8e f0 ff ff       	call   800e37 <fd2num>
  801da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dae:	83 c4 04             	add    $0x4,%esp
  801db1:	ff 75 f0             	pushl  -0x10(%ebp)
  801db4:	e8 7e f0 ff ff       	call   800e37 <fd2num>
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	eb 30                	jmp    801df9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	56                   	push   %esi
  801dcd:	6a 00                	push   $0x0
  801dcf:	e8 56 ee ff ff       	call   800c2a <sys_page_unmap>
  801dd4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 46 ee ff ff       	call   800c2a <sys_page_unmap>
  801de4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ded:	6a 00                	push   $0x0
  801def:	e8 36 ee ff ff       	call   800c2a <sys_page_unmap>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801df9:	89 d0                	mov    %edx,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	ff 75 08             	pushl  0x8(%ebp)
  801e0f:	e8 99 f0 ff ff       	call   800ead <fd_lookup>
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 d2                	test   %edx,%edx
  801e1b:	78 18                	js     801e35 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e1d:	83 ec 0c             	sub    $0xc,%esp
  801e20:	ff 75 f4             	pushl  -0xc(%ebp)
  801e23:	e8 1f f0 ff ff       	call   800e47 <fd2data>
	return _pipeisclosed(fd, p);
  801e28:	89 c2                	mov    %eax,%edx
  801e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2d:	e8 26 fd ff ff       	call   801b58 <_pipeisclosed>
  801e32:	83 c4 10             	add    $0x10,%esp
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e47:	68 2b 29 80 00       	push   $0x80292b
  801e4c:	ff 75 0c             	pushl  0xc(%ebp)
  801e4f:	e8 48 e9 ff ff       	call   80079c <strcpy>
	return 0;
}
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	57                   	push   %edi
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e67:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e72:	eb 2d                	jmp    801ea1 <devcons_write+0x46>
		m = n - tot;
  801e74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e77:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e79:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e81:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	53                   	push   %ebx
  801e88:	03 45 0c             	add    0xc(%ebp),%eax
  801e8b:	50                   	push   %eax
  801e8c:	57                   	push   %edi
  801e8d:	e8 9c ea ff ff       	call   80092e <memmove>
		sys_cputs(buf, m);
  801e92:	83 c4 08             	add    $0x8,%esp
  801e95:	53                   	push   %ebx
  801e96:	57                   	push   %edi
  801e97:	e8 4d ec ff ff       	call   800ae9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9c:	01 de                	add    %ebx,%esi
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea6:	72 cc                	jb     801e74 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eab:	5b                   	pop    %ebx
  801eac:	5e                   	pop    %esi
  801ead:	5f                   	pop    %edi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ebb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebf:	75 07                	jne    801ec8 <devcons_read+0x18>
  801ec1:	eb 28                	jmp    801eeb <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec3:	e8 be ec ff ff       	call   800b86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec8:	e8 3a ec ff ff       	call   800b07 <sys_cgetc>
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	74 f2                	je     801ec3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 16                	js     801eeb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed5:	83 f8 04             	cmp    $0x4,%eax
  801ed8:	74 0c                	je     801ee6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edd:	88 02                	mov    %al,(%edx)
	return 1;
  801edf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee4:	eb 05                	jmp    801eeb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ef9:	6a 01                	push   $0x1
  801efb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	e8 e5 eb ff ff       	call   800ae9 <sys_cputs>
  801f04:	83 c4 10             	add    $0x10,%esp
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <getchar>:

int
getchar(void)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f0f:	6a 01                	push   $0x1
  801f11:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f14:	50                   	push   %eax
  801f15:	6a 00                	push   $0x0
  801f17:	e8 00 f2 ff ff       	call   80111c <read>
	if (r < 0)
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 0f                	js     801f32 <getchar+0x29>
		return r;
	if (r < 1)
  801f23:	85 c0                	test   %eax,%eax
  801f25:	7e 06                	jle    801f2d <getchar+0x24>
		return -E_EOF;
	return c;
  801f27:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f2b:	eb 05                	jmp    801f32 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3d:	50                   	push   %eax
  801f3e:	ff 75 08             	pushl  0x8(%ebp)
  801f41:	e8 67 ef ff ff       	call   800ead <fd_lookup>
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 11                	js     801f5e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f50:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f56:	39 10                	cmp    %edx,(%eax)
  801f58:	0f 94 c0             	sete   %al
  801f5b:	0f b6 c0             	movzbl %al,%eax
}
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <opencons>:

int
opencons(void)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f69:	50                   	push   %eax
  801f6a:	e8 ef ee ff ff       	call   800e5e <fd_alloc>
  801f6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f72:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	78 3e                	js     801fb6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f78:	83 ec 04             	sub    $0x4,%esp
  801f7b:	68 07 04 00 00       	push   $0x407
  801f80:	ff 75 f4             	pushl  -0xc(%ebp)
  801f83:	6a 00                	push   $0x0
  801f85:	e8 1b ec ff ff       	call   800ba5 <sys_page_alloc>
  801f8a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 23                	js     801fb6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f93:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa8:	83 ec 0c             	sub    $0xc,%esp
  801fab:	50                   	push   %eax
  801fac:	e8 86 ee ff ff       	call   800e37 <fd2num>
  801fb1:	89 c2                	mov    %eax,%edx
  801fb3:	83 c4 10             	add    $0x10,%esp
}
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	56                   	push   %esi
  801fbe:	53                   	push   %ebx
  801fbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fcf:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	50                   	push   %eax
  801fd6:	e8 7a ed ff ff       	call   800d55 <sys_ipc_recv>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	79 16                	jns    801ff8 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801fe2:	85 f6                	test   %esi,%esi
  801fe4:	74 06                	je     801fec <ipc_recv+0x32>
  801fe6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801fec:	85 db                	test   %ebx,%ebx
  801fee:	74 2c                	je     80201c <ipc_recv+0x62>
  801ff0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ff6:	eb 24                	jmp    80201c <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ff8:	85 f6                	test   %esi,%esi
  801ffa:	74 0a                	je     802006 <ipc_recv+0x4c>
  801ffc:	a1 40 40 c0 00       	mov    0xc04040,%eax
  802001:	8b 40 74             	mov    0x74(%eax),%eax
  802004:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802006:	85 db                	test   %ebx,%ebx
  802008:	74 0a                	je     802014 <ipc_recv+0x5a>
  80200a:	a1 40 40 c0 00       	mov    0xc04040,%eax
  80200f:	8b 40 78             	mov    0x78(%eax),%eax
  802012:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802014:	a1 40 40 c0 00       	mov    0xc04040,%eax
  802019:	8b 40 70             	mov    0x70(%eax),%eax
}
  80201c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    

00802023 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	57                   	push   %edi
  802027:	56                   	push   %esi
  802028:	53                   	push   %ebx
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80202f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802032:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802035:	85 db                	test   %ebx,%ebx
  802037:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80203c:	0f 44 d8             	cmove  %eax,%ebx
  80203f:	eb 1c                	jmp    80205d <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802041:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802044:	74 12                	je     802058 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802046:	50                   	push   %eax
  802047:	68 37 29 80 00       	push   $0x802937
  80204c:	6a 39                	push   $0x39
  80204e:	68 52 29 80 00       	push   $0x802952
  802053:	e8 e4 e0 ff ff       	call   80013c <_panic>
                 sys_yield();
  802058:	e8 29 eb ff ff       	call   800b86 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80205d:	ff 75 14             	pushl  0x14(%ebp)
  802060:	53                   	push   %ebx
  802061:	56                   	push   %esi
  802062:	57                   	push   %edi
  802063:	e8 ca ec ff ff       	call   800d32 <sys_ipc_try_send>
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 d2                	js     802041 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80206f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802072:	5b                   	pop    %ebx
  802073:	5e                   	pop    %esi
  802074:	5f                   	pop    %edi
  802075:	5d                   	pop    %ebp
  802076:	c3                   	ret    

00802077 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802082:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802085:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80208b:	8b 52 50             	mov    0x50(%edx),%edx
  80208e:	39 ca                	cmp    %ecx,%edx
  802090:	75 0d                	jne    80209f <ipc_find_env+0x28>
			return envs[i].env_id;
  802092:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802095:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80209a:	8b 40 08             	mov    0x8(%eax),%eax
  80209d:	eb 0e                	jmp    8020ad <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80209f:	83 c0 01             	add    $0x1,%eax
  8020a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a7:	75 d9                	jne    802082 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020a9:	66 b8 00 00          	mov    $0x0,%ax
}
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    

008020af <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b5:	89 d0                	mov    %edx,%eax
  8020b7:	c1 e8 16             	shr    $0x16,%eax
  8020ba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020c1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c6:	f6 c1 01             	test   $0x1,%cl
  8020c9:	74 1d                	je     8020e8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020cb:	c1 ea 0c             	shr    $0xc,%edx
  8020ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d5:	f6 c2 01             	test   $0x1,%dl
  8020d8:	74 0e                	je     8020e8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020da:	c1 ea 0c             	shr    $0xc,%edx
  8020dd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e4:	ef 
  8020e5:	0f b7 c0             	movzwl %ax,%eax
}
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	83 ec 10             	sub    $0x10,%esp
  8020f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020fe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802102:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802106:	85 d2                	test   %edx,%edx
  802108:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80210c:	89 34 24             	mov    %esi,(%esp)
  80210f:	89 c8                	mov    %ecx,%eax
  802111:	75 35                	jne    802148 <__udivdi3+0x58>
  802113:	39 f1                	cmp    %esi,%ecx
  802115:	0f 87 bd 00 00 00    	ja     8021d8 <__udivdi3+0xe8>
  80211b:	85 c9                	test   %ecx,%ecx
  80211d:	89 cd                	mov    %ecx,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f1                	div    %ecx
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 f0                	mov    %esi,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c6                	mov    %eax,%esi
  802134:	89 f8                	mov    %edi,%eax
  802136:	f7 f5                	div    %ebp
  802138:	89 f2                	mov    %esi,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	5e                   	pop    %esi
  80213e:	5f                   	pop    %edi
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    
  802141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802148:	3b 14 24             	cmp    (%esp),%edx
  80214b:	77 7b                	ja     8021c8 <__udivdi3+0xd8>
  80214d:	0f bd f2             	bsr    %edx,%esi
  802150:	83 f6 1f             	xor    $0x1f,%esi
  802153:	0f 84 97 00 00 00    	je     8021f0 <__udivdi3+0x100>
  802159:	bd 20 00 00 00       	mov    $0x20,%ebp
  80215e:	89 d7                	mov    %edx,%edi
  802160:	89 f1                	mov    %esi,%ecx
  802162:	29 f5                	sub    %esi,%ebp
  802164:	d3 e7                	shl    %cl,%edi
  802166:	89 c2                	mov    %eax,%edx
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	d3 ea                	shr    %cl,%edx
  80216c:	89 f1                	mov    %esi,%ecx
  80216e:	09 fa                	or     %edi,%edx
  802170:	8b 3c 24             	mov    (%esp),%edi
  802173:	d3 e0                	shl    %cl,%eax
  802175:	89 54 24 08          	mov    %edx,0x8(%esp)
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802183:	89 fa                	mov    %edi,%edx
  802185:	d3 ea                	shr    %cl,%edx
  802187:	89 f1                	mov    %esi,%ecx
  802189:	d3 e7                	shl    %cl,%edi
  80218b:	89 e9                	mov    %ebp,%ecx
  80218d:	d3 e8                	shr    %cl,%eax
  80218f:	09 c7                	or     %eax,%edi
  802191:	89 f8                	mov    %edi,%eax
  802193:	f7 74 24 08          	divl   0x8(%esp)
  802197:	89 d5                	mov    %edx,%ebp
  802199:	89 c7                	mov    %eax,%edi
  80219b:	f7 64 24 0c          	mull   0xc(%esp)
  80219f:	39 d5                	cmp    %edx,%ebp
  8021a1:	89 14 24             	mov    %edx,(%esp)
  8021a4:	72 11                	jb     8021b7 <__udivdi3+0xc7>
  8021a6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021aa:	89 f1                	mov    %esi,%ecx
  8021ac:	d3 e2                	shl    %cl,%edx
  8021ae:	39 c2                	cmp    %eax,%edx
  8021b0:	73 5e                	jae    802210 <__udivdi3+0x120>
  8021b2:	3b 2c 24             	cmp    (%esp),%ebp
  8021b5:	75 59                	jne    802210 <__udivdi3+0x120>
  8021b7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021ba:	31 f6                	xor    %esi,%esi
  8021bc:	89 f2                	mov    %esi,%edx
  8021be:	83 c4 10             	add    $0x10,%esp
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	31 f6                	xor    %esi,%esi
  8021ca:	31 c0                	xor    %eax,%eax
  8021cc:	89 f2                	mov    %esi,%edx
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	89 f2                	mov    %esi,%edx
  8021da:	31 f6                	xor    %esi,%esi
  8021dc:	89 f8                	mov    %edi,%eax
  8021de:	f7 f1                	div    %ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021f4:	76 0b                	jbe    802201 <__udivdi3+0x111>
  8021f6:	31 c0                	xor    %eax,%eax
  8021f8:	3b 14 24             	cmp    (%esp),%edx
  8021fb:	0f 83 37 ff ff ff    	jae    802138 <__udivdi3+0x48>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	e9 2d ff ff ff       	jmp    802138 <__udivdi3+0x48>
  80220b:	90                   	nop
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 f8                	mov    %edi,%eax
  802212:	31 f6                	xor    %esi,%esi
  802214:	e9 1f ff ff ff       	jmp    802138 <__udivdi3+0x48>
  802219:	66 90                	xchg   %ax,%ax
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	83 ec 20             	sub    $0x20,%esp
  802226:	8b 44 24 34          	mov    0x34(%esp),%eax
  80222a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802232:	89 c6                	mov    %eax,%esi
  802234:	89 44 24 10          	mov    %eax,0x10(%esp)
  802238:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80223c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802240:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802244:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802248:	89 74 24 18          	mov    %esi,0x18(%esp)
  80224c:	85 c0                	test   %eax,%eax
  80224e:	89 c2                	mov    %eax,%edx
  802250:	75 1e                	jne    802270 <__umoddi3+0x50>
  802252:	39 f7                	cmp    %esi,%edi
  802254:	76 52                	jbe    8022a8 <__umoddi3+0x88>
  802256:	89 c8                	mov    %ecx,%eax
  802258:	89 f2                	mov    %esi,%edx
  80225a:	f7 f7                	div    %edi
  80225c:	89 d0                	mov    %edx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	83 c4 20             	add    $0x20,%esp
  802263:	5e                   	pop    %esi
  802264:	5f                   	pop    %edi
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    
  802267:	89 f6                	mov    %esi,%esi
  802269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802270:	39 f0                	cmp    %esi,%eax
  802272:	77 5c                	ja     8022d0 <__umoddi3+0xb0>
  802274:	0f bd e8             	bsr    %eax,%ebp
  802277:	83 f5 1f             	xor    $0x1f,%ebp
  80227a:	75 64                	jne    8022e0 <__umoddi3+0xc0>
  80227c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802280:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802284:	0f 86 f6 00 00 00    	jbe    802380 <__umoddi3+0x160>
  80228a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80228e:	0f 82 ec 00 00 00    	jb     802380 <__umoddi3+0x160>
  802294:	8b 44 24 14          	mov    0x14(%esp),%eax
  802298:	8b 54 24 18          	mov    0x18(%esp),%edx
  80229c:	83 c4 20             	add    $0x20,%esp
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
  8022a3:	90                   	nop
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	85 ff                	test   %edi,%edi
  8022aa:	89 fd                	mov    %edi,%ebp
  8022ac:	75 0b                	jne    8022b9 <__umoddi3+0x99>
  8022ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f7                	div    %edi
  8022b7:	89 c5                	mov    %eax,%ebp
  8022b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f5                	div    %ebp
  8022c1:	89 c8                	mov    %ecx,%eax
  8022c3:	f7 f5                	div    %ebp
  8022c5:	eb 95                	jmp    80225c <__umoddi3+0x3c>
  8022c7:	89 f6                	mov    %esi,%esi
  8022c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 20             	add    $0x20,%esp
  8022d7:	5e                   	pop    %esi
  8022d8:	5f                   	pop    %edi
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e5:	89 e9                	mov    %ebp,%ecx
  8022e7:	29 e8                	sub    %ebp,%eax
  8022e9:	d3 e2                	shl    %cl,%edx
  8022eb:	89 c7                	mov    %eax,%edi
  8022ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 c1                	mov    %eax,%ecx
  8022fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022ff:	09 d1                	or     %edx,%ecx
  802301:	89 fa                	mov    %edi,%edx
  802303:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802307:	89 e9                	mov    %ebp,%ecx
  802309:	d3 e0                	shl    %cl,%eax
  80230b:	89 f9                	mov    %edi,%ecx
  80230d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802311:	89 f0                	mov    %esi,%eax
  802313:	d3 e8                	shr    %cl,%eax
  802315:	89 e9                	mov    %ebp,%ecx
  802317:	89 c7                	mov    %eax,%edi
  802319:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80231d:	d3 e6                	shl    %cl,%esi
  80231f:	89 d1                	mov    %edx,%ecx
  802321:	89 fa                	mov    %edi,%edx
  802323:	d3 e8                	shr    %cl,%eax
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	09 f0                	or     %esi,%eax
  802329:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80232d:	f7 74 24 10          	divl   0x10(%esp)
  802331:	d3 e6                	shl    %cl,%esi
  802333:	89 d1                	mov    %edx,%ecx
  802335:	f7 64 24 0c          	mull   0xc(%esp)
  802339:	39 d1                	cmp    %edx,%ecx
  80233b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80233f:	89 d7                	mov    %edx,%edi
  802341:	89 c6                	mov    %eax,%esi
  802343:	72 0a                	jb     80234f <__umoddi3+0x12f>
  802345:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802349:	73 10                	jae    80235b <__umoddi3+0x13b>
  80234b:	39 d1                	cmp    %edx,%ecx
  80234d:	75 0c                	jne    80235b <__umoddi3+0x13b>
  80234f:	89 d7                	mov    %edx,%edi
  802351:	89 c6                	mov    %eax,%esi
  802353:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802357:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80235b:	89 ca                	mov    %ecx,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802363:	29 f0                	sub    %esi,%eax
  802365:	19 fa                	sbb    %edi,%edx
  802367:	d3 e8                	shr    %cl,%eax
  802369:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80236e:	89 d7                	mov    %edx,%edi
  802370:	d3 e7                	shl    %cl,%edi
  802372:	89 e9                	mov    %ebp,%ecx
  802374:	09 f8                	or     %edi,%eax
  802376:	d3 ea                	shr    %cl,%edx
  802378:	83 c4 20             	add    $0x20,%esp
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop
  802380:	8b 74 24 10          	mov    0x10(%esp),%esi
  802384:	29 f9                	sub    %edi,%ecx
  802386:	19 c6                	sbb    %eax,%esi
  802388:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80238c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802390:	e9 ff fe ff ff       	jmp    802294 <__umoddi3+0x74>
