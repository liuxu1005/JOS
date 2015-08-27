
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
  800039:	68 c0 1e 80 00       	push   $0x801ec0
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
  800056:	68 3b 1f 80 00       	push   $0x801f3b
  80005b:	6a 11                	push   $0x11
  80005d:	68 58 1f 80 00       	push   $0x801f58
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
  800096:	68 e0 1e 80 00       	push   $0x801ee0
  80009b:	6a 16                	push   $0x16
  80009d:	68 58 1f 80 00       	push   $0x801f58
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
  8000b4:	68 08 1f 80 00       	push   $0x801f08
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 40 50 c0 00 00 	movl   $0x0,0xc05040
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 67 1f 80 00       	push   $0x801f67
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 58 1f 80 00       	push   $0x801f58
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
  800128:	e8 36 0e 00 00       	call   800f63 <close_all>
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
  80015a:	68 88 1f 80 00       	push   $0x801f88
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 56 1f 80 00 	movl   $0x801f56,(%esp)
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
  800278:	e8 63 19 00 00       	call   801be0 <__udivdi3>
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
  8002b6:	e8 55 1a 00 00       	call   801d10 <__umoddi3>
  8002bb:	83 c4 14             	add    $0x14,%esp
  8002be:	0f be 80 ab 1f 80 00 	movsbl 0x801fab(%eax),%eax
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
  8003ba:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
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
  80047e:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  800485:	85 d2                	test   %edx,%edx
  800487:	75 18                	jne    8004a1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800489:	50                   	push   %eax
  80048a:	68 c3 1f 80 00       	push   $0x801fc3
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
  8004a2:	68 b5 23 80 00       	push   $0x8023b5
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
  8004cf:	ba bc 1f 80 00       	mov    $0x801fbc,%edx
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
  800b4e:	68 df 22 80 00       	push   $0x8022df
  800b53:	6a 23                	push   $0x23
  800b55:	68 fc 22 80 00       	push   $0x8022fc
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
  800bcf:	68 df 22 80 00       	push   $0x8022df
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 fc 22 80 00       	push   $0x8022fc
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
  800c11:	68 df 22 80 00       	push   $0x8022df
  800c16:	6a 23                	push   $0x23
  800c18:	68 fc 22 80 00       	push   $0x8022fc
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
  800c53:	68 df 22 80 00       	push   $0x8022df
  800c58:	6a 23                	push   $0x23
  800c5a:	68 fc 22 80 00       	push   $0x8022fc
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
  800c95:	68 df 22 80 00       	push   $0x8022df
  800c9a:	6a 23                	push   $0x23
  800c9c:	68 fc 22 80 00       	push   $0x8022fc
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
  800cd7:	68 df 22 80 00       	push   $0x8022df
  800cdc:	6a 23                	push   $0x23
  800cde:	68 fc 22 80 00       	push   $0x8022fc
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
  800d19:	68 df 22 80 00       	push   $0x8022df
  800d1e:	6a 23                	push   $0x23
  800d20:	68 fc 22 80 00       	push   $0x8022fc
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
  800d7d:	68 df 22 80 00       	push   $0x8022df
  800d82:	6a 23                	push   $0x23
  800d84:	68 fc 22 80 00       	push   $0x8022fc
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

00800d96 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	05 00 00 00 30       	add    $0x30000000,%eax
  800da1:	c1 e8 0c             	shr    $0xc,%eax
}
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800db6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dc8:	89 c2                	mov    %eax,%edx
  800dca:	c1 ea 16             	shr    $0x16,%edx
  800dcd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd4:	f6 c2 01             	test   $0x1,%dl
  800dd7:	74 11                	je     800dea <fd_alloc+0x2d>
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	c1 ea 0c             	shr    $0xc,%edx
  800dde:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de5:	f6 c2 01             	test   $0x1,%dl
  800de8:	75 09                	jne    800df3 <fd_alloc+0x36>
			*fd_store = fd;
  800dea:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	eb 17                	jmp    800e0a <fd_alloc+0x4d>
  800df3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800df8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dfd:	75 c9                	jne    800dc8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dff:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e05:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e12:	83 f8 1f             	cmp    $0x1f,%eax
  800e15:	77 36                	ja     800e4d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e17:	c1 e0 0c             	shl    $0xc,%eax
  800e1a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	c1 ea 16             	shr    $0x16,%edx
  800e24:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2b:	f6 c2 01             	test   $0x1,%dl
  800e2e:	74 24                	je     800e54 <fd_lookup+0x48>
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	c1 ea 0c             	shr    $0xc,%edx
  800e35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3c:	f6 c2 01             	test   $0x1,%dl
  800e3f:	74 1a                	je     800e5b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e44:	89 02                	mov    %eax,(%edx)
	return 0;
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	eb 13                	jmp    800e60 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e52:	eb 0c                	jmp    800e60 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e59:	eb 05                	jmp    800e60 <fd_lookup+0x54>
  800e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	ba 8c 23 80 00       	mov    $0x80238c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e70:	eb 13                	jmp    800e85 <dev_lookup+0x23>
  800e72:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e75:	39 08                	cmp    %ecx,(%eax)
  800e77:	75 0c                	jne    800e85 <dev_lookup+0x23>
			*dev = devtab[i];
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	eb 2e                	jmp    800eb3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e85:	8b 02                	mov    (%edx),%eax
  800e87:	85 c0                	test   %eax,%eax
  800e89:	75 e7                	jne    800e72 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e8b:	a1 40 40 c0 00       	mov    0xc04040,%eax
  800e90:	8b 40 48             	mov    0x48(%eax),%eax
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	51                   	push   %ecx
  800e97:	50                   	push   %eax
  800e98:	68 0c 23 80 00       	push   $0x80230c
  800e9d:	e8 73 f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 10             	sub    $0x10,%esp
  800ebd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec6:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ecd:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed0:	50                   	push   %eax
  800ed1:	e8 36 ff ff ff       	call   800e0c <fd_lookup>
  800ed6:	83 c4 08             	add    $0x8,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	78 05                	js     800ee2 <fd_close+0x2d>
	    || fd != fd2)
  800edd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ee0:	74 0c                	je     800eee <fd_close+0x39>
		return (must_exist ? r : 0);
  800ee2:	84 db                	test   %bl,%bl
  800ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee9:	0f 44 c2             	cmove  %edx,%eax
  800eec:	eb 41                	jmp    800f2f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eee:	83 ec 08             	sub    $0x8,%esp
  800ef1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	ff 36                	pushl  (%esi)
  800ef7:	e8 66 ff ff ff       	call   800e62 <dev_lookup>
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 1a                	js     800f1f <fd_close+0x6a>
		if (dev->dev_close)
  800f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f08:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f0b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	74 0b                	je     800f1f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	56                   	push   %esi
  800f18:	ff d0                	call   *%eax
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	56                   	push   %esi
  800f23:	6a 00                	push   $0x0
  800f25:	e8 00 fd ff ff       	call   800c2a <sys_page_unmap>
	return r;
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	89 d8                	mov    %ebx,%eax
}
  800f2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3f:	50                   	push   %eax
  800f40:	ff 75 08             	pushl  0x8(%ebp)
  800f43:	e8 c4 fe ff ff       	call   800e0c <fd_lookup>
  800f48:	89 c2                	mov    %eax,%edx
  800f4a:	83 c4 08             	add    $0x8,%esp
  800f4d:	85 d2                	test   %edx,%edx
  800f4f:	78 10                	js     800f61 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	6a 01                	push   $0x1
  800f56:	ff 75 f4             	pushl  -0xc(%ebp)
  800f59:	e8 57 ff ff ff       	call   800eb5 <fd_close>
  800f5e:	83 c4 10             	add    $0x10,%esp
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <close_all>:

void
close_all(void)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	53                   	push   %ebx
  800f67:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	53                   	push   %ebx
  800f73:	e8 be ff ff ff       	call   800f36 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f78:	83 c3 01             	add    $0x1,%ebx
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	83 fb 20             	cmp    $0x20,%ebx
  800f81:	75 ec                	jne    800f6f <close_all+0xc>
		close(i);
}
  800f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 2c             	sub    $0x2c,%esp
  800f91:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f94:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	ff 75 08             	pushl  0x8(%ebp)
  800f9b:	e8 6c fe ff ff       	call   800e0c <fd_lookup>
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	83 c4 08             	add    $0x8,%esp
  800fa5:	85 d2                	test   %edx,%edx
  800fa7:	0f 88 c1 00 00 00    	js     80106e <dup+0xe6>
		return r;
	close(newfdnum);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	56                   	push   %esi
  800fb1:	e8 80 ff ff ff       	call   800f36 <close>

	newfd = INDEX2FD(newfdnum);
  800fb6:	89 f3                	mov    %esi,%ebx
  800fb8:	c1 e3 0c             	shl    $0xc,%ebx
  800fbb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fc1:	83 c4 04             	add    $0x4,%esp
  800fc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc7:	e8 da fd ff ff       	call   800da6 <fd2data>
  800fcc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fce:	89 1c 24             	mov    %ebx,(%esp)
  800fd1:	e8 d0 fd ff ff       	call   800da6 <fd2data>
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fdc:	89 f8                	mov    %edi,%eax
  800fde:	c1 e8 16             	shr    $0x16,%eax
  800fe1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe8:	a8 01                	test   $0x1,%al
  800fea:	74 37                	je     801023 <dup+0x9b>
  800fec:	89 f8                	mov    %edi,%eax
  800fee:	c1 e8 0c             	shr    $0xc,%eax
  800ff1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff8:	f6 c2 01             	test   $0x1,%dl
  800ffb:	74 26                	je     801023 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ffd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	25 07 0e 00 00       	and    $0xe07,%eax
  80100c:	50                   	push   %eax
  80100d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801010:	6a 00                	push   $0x0
  801012:	57                   	push   %edi
  801013:	6a 00                	push   $0x0
  801015:	e8 ce fb ff ff       	call   800be8 <sys_page_map>
  80101a:	89 c7                	mov    %eax,%edi
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 2e                	js     801051 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801023:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801026:	89 d0                	mov    %edx,%eax
  801028:	c1 e8 0c             	shr    $0xc,%eax
  80102b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	25 07 0e 00 00       	and    $0xe07,%eax
  80103a:	50                   	push   %eax
  80103b:	53                   	push   %ebx
  80103c:	6a 00                	push   $0x0
  80103e:	52                   	push   %edx
  80103f:	6a 00                	push   $0x0
  801041:	e8 a2 fb ff ff       	call   800be8 <sys_page_map>
  801046:	89 c7                	mov    %eax,%edi
  801048:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80104b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104d:	85 ff                	test   %edi,%edi
  80104f:	79 1d                	jns    80106e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	e8 ce fb ff ff       	call   800c2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801062:	6a 00                	push   $0x0
  801064:	e8 c1 fb ff ff       	call   800c2a <sys_page_unmap>
	return r;
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 f8                	mov    %edi,%eax
}
  80106e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 14             	sub    $0x14,%esp
  80107d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801080:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801083:	50                   	push   %eax
  801084:	53                   	push   %ebx
  801085:	e8 82 fd ff ff       	call   800e0c <fd_lookup>
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	85 c0                	test   %eax,%eax
  801091:	78 6d                	js     801100 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801093:	83 ec 08             	sub    $0x8,%esp
  801096:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801099:	50                   	push   %eax
  80109a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109d:	ff 30                	pushl  (%eax)
  80109f:	e8 be fd ff ff       	call   800e62 <dev_lookup>
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 4c                	js     8010f7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ae:	8b 42 08             	mov    0x8(%edx),%eax
  8010b1:	83 e0 03             	and    $0x3,%eax
  8010b4:	83 f8 01             	cmp    $0x1,%eax
  8010b7:	75 21                	jne    8010da <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b9:	a1 40 40 c0 00       	mov    0xc04040,%eax
  8010be:	8b 40 48             	mov    0x48(%eax),%eax
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	53                   	push   %ebx
  8010c5:	50                   	push   %eax
  8010c6:	68 50 23 80 00       	push   $0x802350
  8010cb:	e8 45 f1 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010d8:	eb 26                	jmp    801100 <read+0x8a>
	}
	if (!dev->dev_read)
  8010da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010dd:	8b 40 08             	mov    0x8(%eax),%eax
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	74 17                	je     8010fb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	ff 75 10             	pushl  0x10(%ebp)
  8010ea:	ff 75 0c             	pushl  0xc(%ebp)
  8010ed:	52                   	push   %edx
  8010ee:	ff d0                	call   *%eax
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	eb 09                	jmp    801100 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	eb 05                	jmp    801100 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801100:	89 d0                	mov    %edx,%eax
  801102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	8b 7d 08             	mov    0x8(%ebp),%edi
  801113:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111b:	eb 21                	jmp    80113e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	89 f0                	mov    %esi,%eax
  801122:	29 d8                	sub    %ebx,%eax
  801124:	50                   	push   %eax
  801125:	89 d8                	mov    %ebx,%eax
  801127:	03 45 0c             	add    0xc(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	57                   	push   %edi
  80112c:	e8 45 ff ff ff       	call   801076 <read>
		if (m < 0)
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	85 c0                	test   %eax,%eax
  801136:	78 0c                	js     801144 <readn+0x3d>
			return m;
		if (m == 0)
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 06                	je     801142 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113c:	01 c3                	add    %eax,%ebx
  80113e:	39 f3                	cmp    %esi,%ebx
  801140:	72 db                	jb     80111d <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801142:	89 d8                	mov    %ebx,%eax
}
  801144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	53                   	push   %ebx
  801150:	83 ec 14             	sub    $0x14,%esp
  801153:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801156:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	53                   	push   %ebx
  80115b:	e8 ac fc ff ff       	call   800e0c <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	89 c2                	mov    %eax,%edx
  801165:	85 c0                	test   %eax,%eax
  801167:	78 68                	js     8011d1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801173:	ff 30                	pushl  (%eax)
  801175:	e8 e8 fc ff ff       	call   800e62 <dev_lookup>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 47                	js     8011c8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801188:	75 21                	jne    8011ab <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80118a:	a1 40 40 c0 00       	mov    0xc04040,%eax
  80118f:	8b 40 48             	mov    0x48(%eax),%eax
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	53                   	push   %ebx
  801196:	50                   	push   %eax
  801197:	68 6c 23 80 00       	push   $0x80236c
  80119c:	e8 74 f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a9:	eb 26                	jmp    8011d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8011b1:	85 d2                	test   %edx,%edx
  8011b3:	74 17                	je     8011cc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	ff 75 10             	pushl  0x10(%ebp)
  8011bb:	ff 75 0c             	pushl  0xc(%ebp)
  8011be:	50                   	push   %eax
  8011bf:	ff d2                	call   *%edx
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	eb 09                	jmp    8011d1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	eb 05                	jmp    8011d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011d1:	89 d0                	mov    %edx,%eax
  8011d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011de:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	ff 75 08             	pushl  0x8(%ebp)
  8011e5:	e8 22 fc ff ff       	call   800e0c <fd_lookup>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 0e                	js     8011ff <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	53                   	push   %ebx
  801205:	83 ec 14             	sub    $0x14,%esp
  801208:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	53                   	push   %ebx
  801210:	e8 f7 fb ff ff       	call   800e0c <fd_lookup>
  801215:	83 c4 08             	add    $0x8,%esp
  801218:	89 c2                	mov    %eax,%edx
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 65                	js     801283 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801228:	ff 30                	pushl  (%eax)
  80122a:	e8 33 fc ff ff       	call   800e62 <dev_lookup>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 44                	js     80127a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801239:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80123d:	75 21                	jne    801260 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80123f:	a1 40 40 c0 00       	mov    0xc04040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801244:	8b 40 48             	mov    0x48(%eax),%eax
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	53                   	push   %ebx
  80124b:	50                   	push   %eax
  80124c:	68 2c 23 80 00       	push   $0x80232c
  801251:	e8 bf ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125e:	eb 23                	jmp    801283 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801260:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801263:	8b 52 18             	mov    0x18(%edx),%edx
  801266:	85 d2                	test   %edx,%edx
  801268:	74 14                	je     80127e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	ff 75 0c             	pushl  0xc(%ebp)
  801270:	50                   	push   %eax
  801271:	ff d2                	call   *%edx
  801273:	89 c2                	mov    %eax,%edx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	eb 09                	jmp    801283 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	eb 05                	jmp    801283 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80127e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801283:	89 d0                	mov    %edx,%eax
  801285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	53                   	push   %ebx
  80128e:	83 ec 14             	sub    $0x14,%esp
  801291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801294:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 75 08             	pushl  0x8(%ebp)
  80129b:	e8 6c fb ff ff       	call   800e0c <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 58                	js     801301 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b3:	ff 30                	pushl  (%eax)
  8012b5:	e8 a8 fb ff ff       	call   800e62 <dev_lookup>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 37                	js     8012f8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012c8:	74 32                	je     8012fc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012d4:	00 00 00 
	stat->st_isdir = 0;
  8012d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012de:	00 00 00 
	stat->st_dev = dev;
  8012e1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ee:	ff 50 14             	call   *0x14(%eax)
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	eb 09                	jmp    801301 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	eb 05                	jmp    801301 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801301:	89 d0                	mov    %edx,%eax
  801303:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	6a 00                	push   $0x0
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 09 02 00 00       	call   801523 <open>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 db                	test   %ebx,%ebx
  801321:	78 1b                	js     80133e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	ff 75 0c             	pushl  0xc(%ebp)
  801329:	53                   	push   %ebx
  80132a:	e8 5b ff ff ff       	call   80128a <fstat>
  80132f:	89 c6                	mov    %eax,%esi
	close(fd);
  801331:	89 1c 24             	mov    %ebx,(%esp)
  801334:	e8 fd fb ff ff       	call   800f36 <close>
	return r;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	89 f0                	mov    %esi,%eax
}
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	89 c6                	mov    %eax,%esi
  80134c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80134e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801355:	75 12                	jne    801369 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	6a 01                	push   $0x1
  80135c:	e8 ff 07 00 00       	call   801b60 <ipc_find_env>
  801361:	a3 00 40 80 00       	mov    %eax,0x804000
  801366:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801369:	6a 07                	push   $0x7
  80136b:	68 00 50 c0 00       	push   $0xc05000
  801370:	56                   	push   %esi
  801371:	ff 35 00 40 80 00    	pushl  0x804000
  801377:	e8 90 07 00 00       	call   801b0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80137c:	83 c4 0c             	add    $0xc,%esp
  80137f:	6a 00                	push   $0x0
  801381:	53                   	push   %ebx
  801382:	6a 00                	push   $0x0
  801384:	e8 1a 07 00 00       	call   801aa3 <ipc_recv>
}
  801389:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 40 0c             	mov    0xc(%eax),%eax
  80139c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b3:	e8 8d ff ff ff       	call   801345 <fsipc>
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c6:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d5:	e8 6b ff ff ff       	call   801345 <fsipc>
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ec:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fb:	e8 45 ff ff ff       	call   801345 <fsipc>
  801400:	89 c2                	mov    %eax,%edx
  801402:	85 d2                	test   %edx,%edx
  801404:	78 2c                	js     801432 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	68 00 50 c0 00       	push   $0xc05000
  80140e:	53                   	push   %ebx
  80140f:	e8 88 f3 ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801414:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801419:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80141f:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801424:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	57                   	push   %edi
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	83 ec 0c             	sub    $0xc,%esp
  801440:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801443:	8b 45 08             	mov    0x8(%ebp),%eax
  801446:	8b 40 0c             	mov    0xc(%eax),%eax
  801449:	a3 00 50 c0 00       	mov    %eax,0xc05000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80144e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801451:	eb 3d                	jmp    801490 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801453:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801459:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80145e:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	57                   	push   %edi
  801465:	53                   	push   %ebx
  801466:	68 08 50 c0 00       	push   $0xc05008
  80146b:	e8 be f4 ff ff       	call   80092e <memmove>
                fsipcbuf.write.req_n = tmp; 
  801470:	89 3d 04 50 c0 00    	mov    %edi,0xc05004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801476:	ba 00 00 00 00       	mov    $0x0,%edx
  80147b:	b8 04 00 00 00       	mov    $0x4,%eax
  801480:	e8 c0 fe ff ff       	call   801345 <fsipc>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 0d                	js     801499 <devfile_write+0x62>
		        return r;
                n -= tmp;
  80148c:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80148e:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801490:	85 f6                	test   %esi,%esi
  801492:	75 bf                	jne    801453 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801494:	89 d8                	mov    %ebx,%eax
  801496:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149c:	5b                   	pop    %ebx
  80149d:	5e                   	pop    %esi
  80149e:	5f                   	pop    %edi
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    

008014a1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	56                   	push   %esi
  8014a5:	53                   	push   %ebx
  8014a6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8014af:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014b4:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c4:	e8 7c fe ff ff       	call   801345 <fsipc>
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 4b                	js     80151a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014cf:	39 c6                	cmp    %eax,%esi
  8014d1:	73 16                	jae    8014e9 <devfile_read+0x48>
  8014d3:	68 9c 23 80 00       	push   $0x80239c
  8014d8:	68 a3 23 80 00       	push   $0x8023a3
  8014dd:	6a 7c                	push   $0x7c
  8014df:	68 b8 23 80 00       	push   $0x8023b8
  8014e4:	e8 53 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  8014e9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ee:	7e 16                	jle    801506 <devfile_read+0x65>
  8014f0:	68 c3 23 80 00       	push   $0x8023c3
  8014f5:	68 a3 23 80 00       	push   $0x8023a3
  8014fa:	6a 7d                	push   $0x7d
  8014fc:	68 b8 23 80 00       	push   $0x8023b8
  801501:	e8 36 ec ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801506:	83 ec 04             	sub    $0x4,%esp
  801509:	50                   	push   %eax
  80150a:	68 00 50 c0 00       	push   $0xc05000
  80150f:	ff 75 0c             	pushl  0xc(%ebp)
  801512:	e8 17 f4 ff ff       	call   80092e <memmove>
	return r;
  801517:	83 c4 10             	add    $0x10,%esp
}
  80151a:	89 d8                	mov    %ebx,%eax
  80151c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 20             	sub    $0x20,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80152d:	53                   	push   %ebx
  80152e:	e8 30 f2 ff ff       	call   800763 <strlen>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80153b:	7f 67                	jg     8015a4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	e8 74 f8 ff ff       	call   800dbd <fd_alloc>
  801549:	83 c4 10             	add    $0x10,%esp
		return r;
  80154c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 57                	js     8015a9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	53                   	push   %ebx
  801556:	68 00 50 c0 00       	push   $0xc05000
  80155b:	e8 3c f2 ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801560:	8b 45 0c             	mov    0xc(%ebp),%eax
  801563:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801568:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156b:	b8 01 00 00 00       	mov    $0x1,%eax
  801570:	e8 d0 fd ff ff       	call   801345 <fsipc>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	79 14                	jns    801592 <open+0x6f>
		fd_close(fd, 0);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	6a 00                	push   $0x0
  801583:	ff 75 f4             	pushl  -0xc(%ebp)
  801586:	e8 2a f9 ff ff       	call   800eb5 <fd_close>
		return r;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	89 da                	mov    %ebx,%edx
  801590:	eb 17                	jmp    8015a9 <open+0x86>
	}

	return fd2num(fd);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	ff 75 f4             	pushl  -0xc(%ebp)
  801598:	e8 f9 f7 ff ff       	call   800d96 <fd2num>
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	eb 05                	jmp    8015a9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015a4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015a9:	89 d0                	mov    %edx,%eax
  8015ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c0:	e8 80 fd ff ff       	call   801345 <fsipc>
}
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	e8 cc f7 ff ff       	call   800da6 <fd2data>
  8015da:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	68 cf 23 80 00       	push   $0x8023cf
  8015e4:	53                   	push   %ebx
  8015e5:	e8 b2 f1 ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015ea:	8b 56 04             	mov    0x4(%esi),%edx
  8015ed:	89 d0                	mov    %edx,%eax
  8015ef:	2b 06                	sub    (%esi),%eax
  8015f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fe:	00 00 00 
	stat->st_dev = &devpipe;
  801601:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801608:	30 80 00 
	return 0;
}
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
  801610:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801621:	53                   	push   %ebx
  801622:	6a 00                	push   $0x0
  801624:	e8 01 f6 ff ff       	call   800c2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801629:	89 1c 24             	mov    %ebx,(%esp)
  80162c:	e8 75 f7 ff ff       	call   800da6 <fd2data>
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	50                   	push   %eax
  801635:	6a 00                	push   $0x0
  801637:	e8 ee f5 ff ff       	call   800c2a <sys_page_unmap>
}
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	57                   	push   %edi
  801645:	56                   	push   %esi
  801646:	53                   	push   %ebx
  801647:	83 ec 1c             	sub    $0x1c,%esp
  80164a:	89 c6                	mov    %eax,%esi
  80164c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80164f:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801654:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801657:	83 ec 0c             	sub    $0xc,%esp
  80165a:	56                   	push   %esi
  80165b:	e8 38 05 00 00       	call   801b98 <pageref>
  801660:	89 c7                	mov    %eax,%edi
  801662:	83 c4 04             	add    $0x4,%esp
  801665:	ff 75 e4             	pushl  -0x1c(%ebp)
  801668:	e8 2b 05 00 00       	call   801b98 <pageref>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	39 c7                	cmp    %eax,%edi
  801672:	0f 94 c2             	sete   %dl
  801675:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801678:	8b 0d 40 40 c0 00    	mov    0xc04040,%ecx
  80167e:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801681:	39 fb                	cmp    %edi,%ebx
  801683:	74 19                	je     80169e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801685:	84 d2                	test   %dl,%dl
  801687:	74 c6                	je     80164f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801689:	8b 51 58             	mov    0x58(%ecx),%edx
  80168c:	50                   	push   %eax
  80168d:	52                   	push   %edx
  80168e:	53                   	push   %ebx
  80168f:	68 d6 23 80 00       	push   $0x8023d6
  801694:	e8 7c eb ff ff       	call   800215 <cprintf>
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb b1                	jmp    80164f <_pipeisclosed+0xe>
	}
}
  80169e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	5f                   	pop    %edi
  8016a4:	5d                   	pop    %ebp
  8016a5:	c3                   	ret    

008016a6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	57                   	push   %edi
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 28             	sub    $0x28,%esp
  8016af:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016b2:	56                   	push   %esi
  8016b3:	e8 ee f6 ff ff       	call   800da6 <fd2data>
  8016b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	bf 00 00 00 00       	mov    $0x0,%edi
  8016c2:	eb 4b                	jmp    80170f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016c4:	89 da                	mov    %ebx,%edx
  8016c6:	89 f0                	mov    %esi,%eax
  8016c8:	e8 74 ff ff ff       	call   801641 <_pipeisclosed>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	75 48                	jne    801719 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016d1:	e8 b0 f4 ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016d6:	8b 43 04             	mov    0x4(%ebx),%eax
  8016d9:	8b 0b                	mov    (%ebx),%ecx
  8016db:	8d 51 20             	lea    0x20(%ecx),%edx
  8016de:	39 d0                	cmp    %edx,%eax
  8016e0:	73 e2                	jae    8016c4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016e9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	c1 fa 1f             	sar    $0x1f,%edx
  8016f1:	89 d1                	mov    %edx,%ecx
  8016f3:	c1 e9 1b             	shr    $0x1b,%ecx
  8016f6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016f9:	83 e2 1f             	and    $0x1f,%edx
  8016fc:	29 ca                	sub    %ecx,%edx
  8016fe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801702:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801706:	83 c0 01             	add    $0x1,%eax
  801709:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170c:	83 c7 01             	add    $0x1,%edi
  80170f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801712:	75 c2                	jne    8016d6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801714:	8b 45 10             	mov    0x10(%ebp),%eax
  801717:	eb 05                	jmp    80171e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80171e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5f                   	pop    %edi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    

00801726 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	57                   	push   %edi
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	83 ec 18             	sub    $0x18,%esp
  80172f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801732:	57                   	push   %edi
  801733:	e8 6e f6 ff ff       	call   800da6 <fd2data>
  801738:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801742:	eb 3d                	jmp    801781 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801744:	85 db                	test   %ebx,%ebx
  801746:	74 04                	je     80174c <devpipe_read+0x26>
				return i;
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	eb 44                	jmp    801790 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80174c:	89 f2                	mov    %esi,%edx
  80174e:	89 f8                	mov    %edi,%eax
  801750:	e8 ec fe ff ff       	call   801641 <_pipeisclosed>
  801755:	85 c0                	test   %eax,%eax
  801757:	75 32                	jne    80178b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801759:	e8 28 f4 ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80175e:	8b 06                	mov    (%esi),%eax
  801760:	3b 46 04             	cmp    0x4(%esi),%eax
  801763:	74 df                	je     801744 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801765:	99                   	cltd   
  801766:	c1 ea 1b             	shr    $0x1b,%edx
  801769:	01 d0                	add    %edx,%eax
  80176b:	83 e0 1f             	and    $0x1f,%eax
  80176e:	29 d0                	sub    %edx,%eax
  801770:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801775:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801778:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80177b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177e:	83 c3 01             	add    $0x1,%ebx
  801781:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801784:	75 d8                	jne    80175e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801786:	8b 45 10             	mov    0x10(%ebp),%eax
  801789:	eb 05                	jmp    801790 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80178b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5f                   	pop    %edi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	e8 14 f6 ff ff       	call   800dbd <fd_alloc>
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	0f 88 2c 01 00 00    	js     8018e2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b6:	83 ec 04             	sub    $0x4,%esp
  8017b9:	68 07 04 00 00       	push   $0x407
  8017be:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 dd f3 ff ff       	call   800ba5 <sys_page_alloc>
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	0f 88 0d 01 00 00    	js     8018e2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017db:	50                   	push   %eax
  8017dc:	e8 dc f5 ff ff       	call   800dbd <fd_alloc>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	0f 88 e2 00 00 00    	js     8018d0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	68 07 04 00 00       	push   $0x407
  8017f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 a5 f3 ff ff       	call   800ba5 <sys_page_alloc>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 c3 00 00 00    	js     8018d0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	ff 75 f4             	pushl  -0xc(%ebp)
  801813:	e8 8e f5 ff ff       	call   800da6 <fd2data>
  801818:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181a:	83 c4 0c             	add    $0xc,%esp
  80181d:	68 07 04 00 00       	push   $0x407
  801822:	50                   	push   %eax
  801823:	6a 00                	push   $0x0
  801825:	e8 7b f3 ff ff       	call   800ba5 <sys_page_alloc>
  80182a:	89 c3                	mov    %eax,%ebx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	0f 88 89 00 00 00    	js     8018c0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801837:	83 ec 0c             	sub    $0xc,%esp
  80183a:	ff 75 f0             	pushl  -0x10(%ebp)
  80183d:	e8 64 f5 ff ff       	call   800da6 <fd2data>
  801842:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801849:	50                   	push   %eax
  80184a:	6a 00                	push   $0x0
  80184c:	56                   	push   %esi
  80184d:	6a 00                	push   $0x0
  80184f:	e8 94 f3 ff ff       	call   800be8 <sys_page_map>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	83 c4 20             	add    $0x20,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 55                	js     8018b2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80185d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801866:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801872:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801878:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80187d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801880:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	ff 75 f4             	pushl  -0xc(%ebp)
  80188d:	e8 04 f5 ff ff       	call   800d96 <fd2num>
  801892:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801895:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801897:	83 c4 04             	add    $0x4,%esp
  80189a:	ff 75 f0             	pushl  -0x10(%ebp)
  80189d:	e8 f4 f4 ff ff       	call   800d96 <fd2num>
  8018a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	eb 30                	jmp    8018e2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	56                   	push   %esi
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 6d f3 ff ff       	call   800c2a <sys_page_unmap>
  8018bd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c6:	6a 00                	push   $0x0
  8018c8:	e8 5d f3 ff ff       	call   800c2a <sys_page_unmap>
  8018cd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 4d f3 ff ff       	call   800c2a <sys_page_unmap>
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018e2:	89 d0                	mov    %edx,%eax
  8018e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e7:	5b                   	pop    %ebx
  8018e8:	5e                   	pop    %esi
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	ff 75 08             	pushl  0x8(%ebp)
  8018f8:	e8 0f f5 ff ff       	call   800e0c <fd_lookup>
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	85 d2                	test   %edx,%edx
  801904:	78 18                	js     80191e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801906:	83 ec 0c             	sub    $0xc,%esp
  801909:	ff 75 f4             	pushl  -0xc(%ebp)
  80190c:	e8 95 f4 ff ff       	call   800da6 <fd2data>
	return _pipeisclosed(fd, p);
  801911:	89 c2                	mov    %eax,%edx
  801913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801916:	e8 26 fd ff ff       	call   801641 <_pipeisclosed>
  80191b:	83 c4 10             	add    $0x10,%esp
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801923:	b8 00 00 00 00       	mov    $0x0,%eax
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801930:	68 ee 23 80 00       	push   $0x8023ee
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	e8 5f ee ff ff       	call   80079c <strcpy>
	return 0;
}
  80193d:	b8 00 00 00 00       	mov    $0x0,%eax
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	57                   	push   %edi
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801950:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801955:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80195b:	eb 2d                	jmp    80198a <devcons_write+0x46>
		m = n - tot;
  80195d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801960:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801962:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801965:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80196a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80196d:	83 ec 04             	sub    $0x4,%esp
  801970:	53                   	push   %ebx
  801971:	03 45 0c             	add    0xc(%ebp),%eax
  801974:	50                   	push   %eax
  801975:	57                   	push   %edi
  801976:	e8 b3 ef ff ff       	call   80092e <memmove>
		sys_cputs(buf, m);
  80197b:	83 c4 08             	add    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	57                   	push   %edi
  801980:	e8 64 f1 ff ff       	call   800ae9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801985:	01 de                	add    %ebx,%esi
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	89 f0                	mov    %esi,%eax
  80198c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80198f:	72 cc                	jb     80195d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801991:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801994:	5b                   	pop    %ebx
  801995:	5e                   	pop    %esi
  801996:	5f                   	pop    %edi
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8019a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a8:	75 07                	jne    8019b1 <devcons_read+0x18>
  8019aa:	eb 28                	jmp    8019d4 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ac:	e8 d5 f1 ff ff       	call   800b86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019b1:	e8 51 f1 ff ff       	call   800b07 <sys_cgetc>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	74 f2                	je     8019ac <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 16                	js     8019d4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019be:	83 f8 04             	cmp    $0x4,%eax
  8019c1:	74 0c                	je     8019cf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c6:	88 02                	mov    %al,(%edx)
	return 1;
  8019c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cd:	eb 05                	jmp    8019d4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019cf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019df:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019e2:	6a 01                	push   $0x1
  8019e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 fc f0 ff ff       	call   800ae9 <sys_cputs>
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <getchar>:

int
getchar(void)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019f8:	6a 01                	push   $0x1
  8019fa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 71 f6 ff ff       	call   801076 <read>
	if (r < 0)
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 0f                	js     801a1b <getchar+0x29>
		return r;
	if (r < 1)
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	7e 06                	jle    801a16 <getchar+0x24>
		return -E_EOF;
	return c;
  801a10:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a14:	eb 05                	jmp    801a1b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a16:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a26:	50                   	push   %eax
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	e8 dd f3 ff ff       	call   800e0c <fd_lookup>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 11                	js     801a47 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a39:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a3f:	39 10                	cmp    %edx,(%eax)
  801a41:	0f 94 c0             	sete   %al
  801a44:	0f b6 c0             	movzbl %al,%eax
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <opencons>:

int
opencons(void)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a52:	50                   	push   %eax
  801a53:	e8 65 f3 ff ff       	call   800dbd <fd_alloc>
  801a58:	83 c4 10             	add    $0x10,%esp
		return r;
  801a5b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 3e                	js     801a9f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	68 07 04 00 00       	push   $0x407
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 32 f1 ff ff       	call   800ba5 <sys_page_alloc>
  801a73:	83 c4 10             	add    $0x10,%esp
		return r;
  801a76:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 23                	js     801a9f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a7c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a85:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	50                   	push   %eax
  801a95:	e8 fc f2 ff ff       	call   800d96 <fd2num>
  801a9a:	89 c2                	mov    %eax,%edx
  801a9c:	83 c4 10             	add    $0x10,%esp
}
  801a9f:	89 d0                	mov    %edx,%eax
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	8b 75 08             	mov    0x8(%ebp),%esi
  801aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ab8:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	50                   	push   %eax
  801abf:	e8 91 f2 ff ff       	call   800d55 <sys_ipc_recv>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	79 16                	jns    801ae1 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801acb:	85 f6                	test   %esi,%esi
  801acd:	74 06                	je     801ad5 <ipc_recv+0x32>
  801acf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801ad5:	85 db                	test   %ebx,%ebx
  801ad7:	74 2c                	je     801b05 <ipc_recv+0x62>
  801ad9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801adf:	eb 24                	jmp    801b05 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ae1:	85 f6                	test   %esi,%esi
  801ae3:	74 0a                	je     801aef <ipc_recv+0x4c>
  801ae5:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801aea:	8b 40 74             	mov    0x74(%eax),%eax
  801aed:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801aef:	85 db                	test   %ebx,%ebx
  801af1:	74 0a                	je     801afd <ipc_recv+0x5a>
  801af3:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801af8:	8b 40 78             	mov    0x78(%eax),%eax
  801afb:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801afd:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801b02:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801b1e:	85 db                	test   %ebx,%ebx
  801b20:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b25:	0f 44 d8             	cmove  %eax,%ebx
  801b28:	eb 1c                	jmp    801b46 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801b2a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2d:	74 12                	je     801b41 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801b2f:	50                   	push   %eax
  801b30:	68 fa 23 80 00       	push   $0x8023fa
  801b35:	6a 39                	push   $0x39
  801b37:	68 15 24 80 00       	push   $0x802415
  801b3c:	e8 fb e5 ff ff       	call   80013c <_panic>
                 sys_yield();
  801b41:	e8 40 f0 ff ff       	call   800b86 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b46:	ff 75 14             	pushl  0x14(%ebp)
  801b49:	53                   	push   %ebx
  801b4a:	56                   	push   %esi
  801b4b:	57                   	push   %edi
  801b4c:	e8 e1 f1 ff ff       	call   800d32 <sys_ipc_try_send>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 d2                	js     801b2a <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b74:	8b 52 50             	mov    0x50(%edx),%edx
  801b77:	39 ca                	cmp    %ecx,%edx
  801b79:	75 0d                	jne    801b88 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7e:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b83:	8b 40 08             	mov    0x8(%eax),%eax
  801b86:	eb 0e                	jmp    801b96 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b88:	83 c0 01             	add    $0x1,%eax
  801b8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b90:	75 d9                	jne    801b6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b92:	66 b8 00 00          	mov    $0x0,%ax
}
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9e:	89 d0                	mov    %edx,%eax
  801ba0:	c1 e8 16             	shr    $0x16,%eax
  801ba3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baf:	f6 c1 01             	test   $0x1,%cl
  801bb2:	74 1d                	je     801bd1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb4:	c1 ea 0c             	shr    $0xc,%edx
  801bb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbe:	f6 c2 01             	test   $0x1,%dl
  801bc1:	74 0e                	je     801bd1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc3:	c1 ea 0c             	shr    $0xc,%edx
  801bc6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bcd:	ef 
  801bce:	0f b7 c0             	movzwl %ax,%eax
}
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
  801bd3:	66 90                	xchg   %ax,%ax
  801bd5:	66 90                	xchg   %ax,%ax
  801bd7:	66 90                	xchg   %ax,%ax
  801bd9:	66 90                	xchg   %ax,%ax
  801bdb:	66 90                	xchg   %ax,%ax
  801bdd:	66 90                	xchg   %ax,%ax
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	83 ec 10             	sub    $0x10,%esp
  801be6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801bea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bee:	8b 74 24 24          	mov    0x24(%esp),%esi
  801bf2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bf6:	85 d2                	test   %edx,%edx
  801bf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	89 c8                	mov    %ecx,%eax
  801c01:	75 35                	jne    801c38 <__udivdi3+0x58>
  801c03:	39 f1                	cmp    %esi,%ecx
  801c05:	0f 87 bd 00 00 00    	ja     801cc8 <__udivdi3+0xe8>
  801c0b:	85 c9                	test   %ecx,%ecx
  801c0d:	89 cd                	mov    %ecx,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f1                	div    %ecx
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c6                	mov    %eax,%esi
  801c24:	89 f8                	mov    %edi,%eax
  801c26:	f7 f5                	div    %ebp
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
  801c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c38:	3b 14 24             	cmp    (%esp),%edx
  801c3b:	77 7b                	ja     801cb8 <__udivdi3+0xd8>
  801c3d:	0f bd f2             	bsr    %edx,%esi
  801c40:	83 f6 1f             	xor    $0x1f,%esi
  801c43:	0f 84 97 00 00 00    	je     801ce0 <__udivdi3+0x100>
  801c49:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c4e:	89 d7                	mov    %edx,%edi
  801c50:	89 f1                	mov    %esi,%ecx
  801c52:	29 f5                	sub    %esi,%ebp
  801c54:	d3 e7                	shl    %cl,%edi
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	89 e9                	mov    %ebp,%ecx
  801c5a:	d3 ea                	shr    %cl,%edx
  801c5c:	89 f1                	mov    %esi,%ecx
  801c5e:	09 fa                	or     %edi,%edx
  801c60:	8b 3c 24             	mov    (%esp),%edi
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c69:	89 e9                	mov    %ebp,%ecx
  801c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c73:	89 fa                	mov    %edi,%edx
  801c75:	d3 ea                	shr    %cl,%edx
  801c77:	89 f1                	mov    %esi,%ecx
  801c79:	d3 e7                	shl    %cl,%edi
  801c7b:	89 e9                	mov    %ebp,%ecx
  801c7d:	d3 e8                	shr    %cl,%eax
  801c7f:	09 c7                	or     %eax,%edi
  801c81:	89 f8                	mov    %edi,%eax
  801c83:	f7 74 24 08          	divl   0x8(%esp)
  801c87:	89 d5                	mov    %edx,%ebp
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	f7 64 24 0c          	mull   0xc(%esp)
  801c8f:	39 d5                	cmp    %edx,%ebp
  801c91:	89 14 24             	mov    %edx,(%esp)
  801c94:	72 11                	jb     801ca7 <__udivdi3+0xc7>
  801c96:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c9a:	89 f1                	mov    %esi,%ecx
  801c9c:	d3 e2                	shl    %cl,%edx
  801c9e:	39 c2                	cmp    %eax,%edx
  801ca0:	73 5e                	jae    801d00 <__udivdi3+0x120>
  801ca2:	3b 2c 24             	cmp    (%esp),%ebp
  801ca5:	75 59                	jne    801d00 <__udivdi3+0x120>
  801ca7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801caa:	31 f6                	xor    %esi,%esi
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	31 f6                	xor    %esi,%esi
  801cba:	31 c0                	xor    %eax,%eax
  801cbc:	89 f2                	mov    %esi,%edx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	31 f6                	xor    %esi,%esi
  801ccc:	89 f8                	mov    %edi,%eax
  801cce:	f7 f1                	div    %ecx
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ce4:	76 0b                	jbe    801cf1 <__udivdi3+0x111>
  801ce6:	31 c0                	xor    %eax,%eax
  801ce8:	3b 14 24             	cmp    (%esp),%edx
  801ceb:	0f 83 37 ff ff ff    	jae    801c28 <__udivdi3+0x48>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	e9 2d ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801cfb:	90                   	nop
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	31 f6                	xor    %esi,%esi
  801d04:	e9 1f ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801d09:	66 90                	xchg   %ax,%ax
  801d0b:	66 90                	xchg   %ax,%ax
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	83 ec 20             	sub    $0x20,%esp
  801d16:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d22:	89 c6                	mov    %eax,%esi
  801d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d38:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	75 1e                	jne    801d60 <__umoddi3+0x50>
  801d42:	39 f7                	cmp    %esi,%edi
  801d44:	76 52                	jbe    801d98 <__umoddi3+0x88>
  801d46:	89 c8                	mov    %ecx,%eax
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	f7 f7                	div    %edi
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	31 d2                	xor    %edx,%edx
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
  801d57:	89 f6                	mov    %esi,%esi
  801d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d60:	39 f0                	cmp    %esi,%eax
  801d62:	77 5c                	ja     801dc0 <__umoddi3+0xb0>
  801d64:	0f bd e8             	bsr    %eax,%ebp
  801d67:	83 f5 1f             	xor    $0x1f,%ebp
  801d6a:	75 64                	jne    801dd0 <__umoddi3+0xc0>
  801d6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d74:	0f 86 f6 00 00 00    	jbe    801e70 <__umoddi3+0x160>
  801d7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d7e:	0f 82 ec 00 00 00    	jb     801e70 <__umoddi3+0x160>
  801d84:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d88:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	89 fd                	mov    %edi,%ebp
  801d9c:	75 0b                	jne    801da9 <__umoddi3+0x99>
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f7                	div    %edi
  801da7:	89 c5                	mov    %eax,%ebp
  801da9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dad:	31 d2                	xor    %edx,%edx
  801daf:	f7 f5                	div    %ebp
  801db1:	89 c8                	mov    %ecx,%eax
  801db3:	f7 f5                	div    %ebp
  801db5:	eb 95                	jmp    801d4c <__umoddi3+0x3c>
  801db7:	89 f6                	mov    %esi,%esi
  801db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 20             	add    $0x20,%esp
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
  801dcb:	90                   	nop
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd5:	89 e9                	mov    %ebp,%ecx
  801dd7:	29 e8                	sub    %ebp,%eax
  801dd9:	d3 e2                	shl    %cl,%edx
  801ddb:	89 c7                	mov    %eax,%edi
  801ddd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801de1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 c1                	mov    %eax,%ecx
  801deb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801def:	09 d1                	or     %edx,%ecx
  801df1:	89 fa                	mov    %edi,%edx
  801df3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801df7:	89 e9                	mov    %ebp,%ecx
  801df9:	d3 e0                	shl    %cl,%eax
  801dfb:	89 f9                	mov    %edi,%ecx
  801dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	89 c7                	mov    %eax,%edi
  801e09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e0d:	d3 e6                	shl    %cl,%esi
  801e0f:	89 d1                	mov    %edx,%ecx
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	d3 e8                	shr    %cl,%eax
  801e15:	89 e9                	mov    %ebp,%ecx
  801e17:	09 f0                	or     %esi,%eax
  801e19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e1d:	f7 74 24 10          	divl   0x10(%esp)
  801e21:	d3 e6                	shl    %cl,%esi
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	f7 64 24 0c          	mull   0xc(%esp)
  801e29:	39 d1                	cmp    %edx,%ecx
  801e2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	89 c6                	mov    %eax,%esi
  801e33:	72 0a                	jb     801e3f <__umoddi3+0x12f>
  801e35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e39:	73 10                	jae    801e4b <__umoddi3+0x13b>
  801e3b:	39 d1                	cmp    %edx,%ecx
  801e3d:	75 0c                	jne    801e4b <__umoddi3+0x13b>
  801e3f:	89 d7                	mov    %edx,%edi
  801e41:	89 c6                	mov    %eax,%esi
  801e43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e4b:	89 ca                	mov    %ecx,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e53:	29 f0                	sub    %esi,%eax
  801e55:	19 fa                	sbb    %edi,%edx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e5e:	89 d7                	mov    %edx,%edi
  801e60:	d3 e7                	shl    %cl,%edi
  801e62:	89 e9                	mov    %ebp,%ecx
  801e64:	09 f8                	or     %edi,%eax
  801e66:	d3 ea                	shr    %cl,%edx
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
  801e70:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e74:	29 f9                	sub    %edi,%ecx
  801e76:	19 c6                	sbb    %eax,%esi
  801e78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e80:	e9 ff fe ff ff       	jmp    801d84 <__umoddi3+0x74>
