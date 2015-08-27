
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
  800039:	68 40 0e 80 00       	push   $0x800e40
  80003e:	e8 cd 01 00 00       	call   800210 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 40 20 80 00 	cmpl   $0x0,0x802040(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 bb 0e 80 00       	push   $0x800ebb
  80005b:	6a 11                	push   $0x11
  80005d:	68 d8 0e 80 00       	push   $0x800ed8
  800062:	e8 d0 00 00 00       	call   800137 <_panic>
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
  800096:	68 60 0e 80 00       	push   $0x800e60
  80009b:	6a 16                	push   $0x16
  80009d:	68 d8 0e 80 00       	push   $0x800ed8
  8000a2:	e8 90 00 00 00       	call   800137 <_panic>
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
  8000b4:	68 88 0e 80 00       	push   $0x800e88
  8000b9:	e8 52 01 00 00       	call   800210 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 40 30 c0 00 00 	movl   $0x0,0xc03040
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 e7 0e 80 00       	push   $0x800ee7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 d8 0e 80 00       	push   $0x800ed8
  8000d7:	e8 5b 00 00 00       	call   800137 <_panic>

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
  8000e7:	e8 76 0a 00 00       	call   800b62 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000f4:	c1 e0 05             	shl    $0x5,%eax
  8000f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fc:	a3 40 20 c0 00       	mov    %eax,0xc02040

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800101:	85 db                	test   %ebx,%ebx
  800103:	7e 07                	jle    80010c <libmain+0x30>
		binaryname = argv[0];
  800105:	8b 06                	mov    (%esi),%eax
  800107:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	e8 1d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800116:	e8 0a 00 00 00       	call   800125 <exit>
  80011b:	83 c4 10             	add    $0x10,%esp
}
  80011e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012b:	6a 00                	push   $0x0
  80012d:	e8 ef 09 00 00       	call   800b21 <sys_env_destroy>
  800132:	83 c4 10             	add    $0x10,%esp
}
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800145:	e8 18 0a 00 00       	call   800b62 <sys_getenvid>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	ff 75 0c             	pushl  0xc(%ebp)
  800150:	ff 75 08             	pushl  0x8(%ebp)
  800153:	56                   	push   %esi
  800154:	50                   	push   %eax
  800155:	68 08 0f 80 00       	push   $0x800f08
  80015a:	e8 b1 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015f:	83 c4 18             	add    $0x18,%esp
  800162:	53                   	push   %ebx
  800163:	ff 75 10             	pushl  0x10(%ebp)
  800166:	e8 54 00 00 00       	call   8001bf <vcprintf>
	cprintf("\n");
  80016b:	c7 04 24 d6 0e 80 00 	movl   $0x800ed6,(%esp)
  800172:	e8 99 00 00 00       	call   800210 <cprintf>
  800177:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017a:	cc                   	int3   
  80017b:	eb fd                	jmp    80017a <_panic+0x43>

0080017d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	53                   	push   %ebx
  800181:	83 ec 04             	sub    $0x4,%esp
  800184:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800187:	8b 13                	mov    (%ebx),%edx
  800189:	8d 42 01             	lea    0x1(%edx),%eax
  80018c:	89 03                	mov    %eax,(%ebx)
  80018e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800191:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800195:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019a:	75 1a                	jne    8001b6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019c:	83 ec 08             	sub    $0x8,%esp
  80019f:	68 ff 00 00 00       	push   $0xff
  8001a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 37 09 00 00       	call   800ae4 <sys_cputs>
		b->idx = 0;
  8001ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 7d 01 80 00       	push   $0x80017d
  8001ee:	e8 4f 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 dc 08 00 00       	call   800ae4 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 9d ff ff ff       	call   8001bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 1c             	sub    $0x1c,%esp
  80022d:	89 c7                	mov    %eax,%edi
  80022f:	89 d6                	mov    %edx,%esi
  800231:	8b 45 08             	mov    0x8(%ebp),%eax
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 d1                	mov    %edx,%ecx
  800239:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023f:	8b 45 10             	mov    0x10(%ebp),%eax
  800242:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800245:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800248:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024f:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800252:	72 05                	jb     800259 <printnum+0x35>
  800254:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800257:	77 3e                	ja     800297 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	53                   	push   %ebx
  800263:	50                   	push   %eax
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026a:	ff 75 e0             	pushl  -0x20(%ebp)
  80026d:	ff 75 dc             	pushl  -0x24(%ebp)
  800270:	ff 75 d8             	pushl  -0x28(%ebp)
  800273:	e8 18 09 00 00       	call   800b90 <__udivdi3>
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	52                   	push   %edx
  80027c:	50                   	push   %eax
  80027d:	89 f2                	mov    %esi,%edx
  80027f:	89 f8                	mov    %edi,%eax
  800281:	e8 9e ff ff ff       	call   800224 <printnum>
  800286:	83 c4 20             	add    $0x20,%esp
  800289:	eb 13                	jmp    80029e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	56                   	push   %esi
  80028f:	ff 75 18             	pushl  0x18(%ebp)
  800292:	ff d7                	call   *%edi
  800294:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800297:	83 eb 01             	sub    $0x1,%ebx
  80029a:	85 db                	test   %ebx,%ebx
  80029c:	7f ed                	jg     80028b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	83 ec 04             	sub    $0x4,%esp
  8002a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b1:	e8 0a 0a 00 00       	call   800cc0 <__umoddi3>
  8002b6:	83 c4 14             	add    $0x14,%esp
  8002b9:	0f be 80 2c 0f 80 00 	movsbl 0x800f2c(%eax),%eax
  8002c0:	50                   	push   %eax
  8002c1:	ff d7                	call   *%edi
  8002c3:	83 c4 10             	add    $0x10,%esp
}
  8002c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7e 0e                	jle    8002e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	eb 22                	jmp    800306 <getuint+0x38>
	else if (lflag)
  8002e4:	85 d2                	test   %edx,%edx
  8002e6:	74 10                	je     8002f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f6:	eb 0e                	jmp    800306 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800312:	8b 10                	mov    (%eax),%edx
  800314:	3b 50 04             	cmp    0x4(%eax),%edx
  800317:	73 0a                	jae    800323 <sprintputch+0x1b>
		*b->buf++ = ch;
  800319:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	88 02                	mov    %al,(%edx)
}
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032e:	50                   	push   %eax
  80032f:	ff 75 10             	pushl  0x10(%ebp)
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 05 00 00 00       	call   800342 <vprintfmt>
	va_end(ap);
  80033d:	83 c4 10             	add    $0x10,%esp
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 2c             	sub    $0x2c,%esp
  80034b:	8b 75 08             	mov    0x8(%ebp),%esi
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800351:	8b 7d 10             	mov    0x10(%ebp),%edi
  800354:	eb 12                	jmp    800368 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800356:	85 c0                	test   %eax,%eax
  800358:	0f 84 90 03 00 00    	je     8006ee <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80035e:	83 ec 08             	sub    $0x8,%esp
  800361:	53                   	push   %ebx
  800362:	50                   	push   %eax
  800363:	ff d6                	call   *%esi
  800365:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800368:	83 c7 01             	add    $0x1,%edi
  80036b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e2                	jne    800356 <vprintfmt+0x14>
  800374:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800378:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038d:	ba 00 00 00 00       	mov    $0x0,%edx
  800392:	eb 07                	jmp    80039b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800397:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8d 47 01             	lea    0x1(%edi),%eax
  80039e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a1:	0f b6 07             	movzbl (%edi),%eax
  8003a4:	0f b6 c8             	movzbl %al,%ecx
  8003a7:	83 e8 23             	sub    $0x23,%eax
  8003aa:	3c 55                	cmp    $0x55,%al
  8003ac:	0f 87 21 03 00 00    	ja     8006d3 <vprintfmt+0x391>
  8003b2:	0f b6 c0             	movzbl %al,%eax
  8003b5:	ff 24 85 c0 0f 80 00 	jmp    *0x800fc0(,%eax,4)
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c3:	eb d6                	jmp    80039b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003da:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003dd:	83 fa 09             	cmp    $0x9,%edx
  8003e0:	77 39                	ja     80041b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e5:	eb e9                	jmp    8003d0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f8:	eb 27                	jmp    800421 <vprintfmt+0xdf>
  8003fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800404:	0f 49 c8             	cmovns %eax,%ecx
  800407:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040d:	eb 8c                	jmp    80039b <vprintfmt+0x59>
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800412:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800419:	eb 80                	jmp    80039b <vprintfmt+0x59>
  80041b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800421:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800425:	0f 89 70 ff ff ff    	jns    80039b <vprintfmt+0x59>
				width = precision, precision = -1;
  80042b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800431:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800438:	e9 5e ff ff ff       	jmp    80039b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800443:	e9 53 ff ff ff       	jmp    80039b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 50 04             	lea    0x4(%eax),%edx
  80044e:	89 55 14             	mov    %edx,0x14(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	53                   	push   %ebx
  800455:	ff 30                	pushl  (%eax)
  800457:	ff d6                	call   *%esi
			break;
  800459:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045f:	e9 04 ff ff ff       	jmp    800368 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	99                   	cltd   
  800470:	31 d0                	xor    %edx,%eax
  800472:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800474:	83 f8 07             	cmp    $0x7,%eax
  800477:	7f 0b                	jg     800484 <vprintfmt+0x142>
  800479:	8b 14 85 20 11 80 00 	mov    0x801120(,%eax,4),%edx
  800480:	85 d2                	test   %edx,%edx
  800482:	75 18                	jne    80049c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800484:	50                   	push   %eax
  800485:	68 44 0f 80 00       	push   $0x800f44
  80048a:	53                   	push   %ebx
  80048b:	56                   	push   %esi
  80048c:	e8 94 fe ff ff       	call   800325 <printfmt>
  800491:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800497:	e9 cc fe ff ff       	jmp    800368 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80049c:	52                   	push   %edx
  80049d:	68 4d 0f 80 00       	push   $0x800f4d
  8004a2:	53                   	push   %ebx
  8004a3:	56                   	push   %esi
  8004a4:	e8 7c fe ff ff       	call   800325 <printfmt>
  8004a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004af:	e9 b4 fe ff ff       	jmp    800368 <vprintfmt+0x26>
  8004b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	ba 3d 0f 80 00       	mov    $0x800f3d,%edx
  8004cf:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004d2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d6:	0f 84 92 00 00 00    	je     80056e <vprintfmt+0x22c>
  8004dc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e0:	0f 8e 96 00 00 00    	jle    80057c <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	51                   	push   %ecx
  8004ea:	57                   	push   %edi
  8004eb:	e8 86 02 00 00       	call   800776 <strnlen>
  8004f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f3:	29 c1                	sub    %eax,%ecx
  8004f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800502:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800505:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	eb 0f                	jmp    800518 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	53                   	push   %ebx
  80050d:	ff 75 e0             	pushl  -0x20(%ebp)
  800510:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	85 ff                	test   %edi,%edi
  80051a:	7f ed                	jg     800509 <vprintfmt+0x1c7>
  80051c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800522:	85 c9                	test   %ecx,%ecx
  800524:	b8 00 00 00 00       	mov    $0x0,%eax
  800529:	0f 49 c1             	cmovns %ecx,%eax
  80052c:	29 c1                	sub    %eax,%ecx
  80052e:	89 75 08             	mov    %esi,0x8(%ebp)
  800531:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800534:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800537:	89 cb                	mov    %ecx,%ebx
  800539:	eb 4d                	jmp    800588 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053f:	74 1b                	je     80055c <vprintfmt+0x21a>
  800541:	0f be c0             	movsbl %al,%eax
  800544:	83 e8 20             	sub    $0x20,%eax
  800547:	83 f8 5e             	cmp    $0x5e,%eax
  80054a:	76 10                	jbe    80055c <vprintfmt+0x21a>
					putch('?', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	6a 3f                	push   $0x3f
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	eb 0d                	jmp    800569 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	ff 75 0c             	pushl  0xc(%ebp)
  800562:	52                   	push   %edx
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	83 eb 01             	sub    $0x1,%ebx
  80056c:	eb 1a                	jmp    800588 <vprintfmt+0x246>
  80056e:	89 75 08             	mov    %esi,0x8(%ebp)
  800571:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800574:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800577:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057a:	eb 0c                	jmp    800588 <vprintfmt+0x246>
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800585:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800588:	83 c7 01             	add    $0x1,%edi
  80058b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058f:	0f be d0             	movsbl %al,%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	74 23                	je     8005b9 <vprintfmt+0x277>
  800596:	85 f6                	test   %esi,%esi
  800598:	78 a1                	js     80053b <vprintfmt+0x1f9>
  80059a:	83 ee 01             	sub    $0x1,%esi
  80059d:	79 9c                	jns    80053b <vprintfmt+0x1f9>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	eb 18                	jmp    8005c1 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 20                	push   $0x20
  8005af:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb 08                	jmp    8005c1 <vprintfmt+0x27f>
  8005b9:	89 df                	mov    %ebx,%edi
  8005bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	7f e4                	jg     8005a9 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	e9 9b fd ff ff       	jmp    800368 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cd:	83 fa 01             	cmp    $0x1,%edx
  8005d0:	7e 16                	jle    8005e8 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 50 04             	mov    0x4(%eax),%edx
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e6:	eb 32                	jmp    80061a <vprintfmt+0x2d8>
	else if (lflag)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	74 18                	je     800604 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800602:	eb 16                	jmp    80061a <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 c1                	mov    %eax,%ecx
  800614:	c1 f9 1f             	sar    $0x1f,%ecx
  800617:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	79 74                	jns    80069f <vprintfmt+0x35d>
				putch('-', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 2d                	push   $0x2d
  800631:	ff d6                	call   *%esi
				num = -(long long) num;
  800633:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800636:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800639:	f7 d8                	neg    %eax
  80063b:	83 d2 00             	adc    $0x0,%edx
  80063e:	f7 da                	neg    %edx
  800640:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800643:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800648:	eb 55                	jmp    80069f <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 7c fc ff ff       	call   8002ce <getuint>
			base = 10;
  800652:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800657:	eb 46                	jmp    80069f <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
  80065c:	e8 6d fc ff ff       	call   8002ce <getuint>
                        base = 8;
  800661:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800666:	eb 37                	jmp    80069f <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800688:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800690:	eb 0d                	jmp    80069f <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 34 fc ff ff       	call   8002ce <getuint>
			base = 16;
  80069a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069f:	83 ec 0c             	sub    $0xc,%esp
  8006a2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a6:	57                   	push   %edi
  8006a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006aa:	51                   	push   %ecx
  8006ab:	52                   	push   %edx
  8006ac:	50                   	push   %eax
  8006ad:	89 da                	mov    %ebx,%edx
  8006af:	89 f0                	mov    %esi,%eax
  8006b1:	e8 6e fb ff ff       	call   800224 <printnum>
			break;
  8006b6:	83 c4 20             	add    $0x20,%esp
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bc:	e9 a7 fc ff ff       	jmp    800368 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	51                   	push   %ecx
  8006c6:	ff d6                	call   *%esi
			break;
  8006c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ce:	e9 95 fc ff ff       	jmp    800368 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 25                	push   $0x25
  8006d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 03                	jmp    8006e3 <vprintfmt+0x3a1>
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e7:	75 f7                	jne    8006e0 <vprintfmt+0x39e>
  8006e9:	e9 7a fc ff ff       	jmp    800368 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 26                	je     80073d <vsnprintf+0x47>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 22                	jle    80073d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	ff 75 14             	pushl  0x14(%ebp)
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	68 08 03 80 00       	push   $0x800308
  80072a:	e8 13 fc ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 9a ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 03                	jmp    80076e <strlen+0x10>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f7                	jne    80076b <strlen+0xd>
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	eb 03                	jmp    800789 <strnlen+0x13>
		n++;
  800786:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	39 c2                	cmp    %eax,%edx
  80078b:	74 08                	je     800795 <strnlen+0x1f>
  80078d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800791:	75 f3                	jne    800786 <strnlen+0x10>
  800793:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 9a ff ff ff       	call   80075e <strlen>
  8007c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 c5 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e4:	89 f3                	mov    %esi,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	89 f2                	mov    %esi,%edx
  8007eb:	eb 0f                	jmp    8007fc <strncpy+0x23>
		*dst++ = *src;
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	39 da                	cmp    %ebx,%edx
  8007fe:	75 ed                	jne    8007ed <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x35>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 09                	jmp    80082b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 09                	je     800838 <strlcpy+0x32>
  80082f:	0f b6 19             	movzbl (%ecx),%ebx
  800832:	84 db                	test   %bl,%bl
  800834:	75 ec                	jne    800822 <strlcpy+0x1c>
  800836:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strcmp+0x11>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x1c>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x17>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 15                	je     800897 <strncmp+0x30>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x26>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
  800895:	eb 05                	jmp    80089c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089c:	5b                   	pop    %ebx
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 07                	jmp    8008b2 <strchr+0x13>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 0f                	je     8008be <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 03                	jmp    8008cf <strfind+0xf>
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	74 04                	je     8008da <strfind+0x1a>
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	75 f2                	jne    8008cc <strfind+0xc>
			break;
	return (char *) s;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 36                	je     800922 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 28                	jne    80091c <memset+0x40>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 23                	jne    80091c <memset+0x40>
		c &= 0xFF;
  8008f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 c2                	or     %eax,%edx
  800910:	89 d0                	mov    %edx,%eax
  800912:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800914:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
  80091a:	eb 06                	jmp    800922 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 35                	jae    800970 <memmove+0x47>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	73 2e                	jae    800970 <memmove+0x47>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800945:	89 d6                	mov    %edx,%esi
  800947:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094f:	75 13                	jne    800964 <memmove+0x3b>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 09                	jmp    80096d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 1d                	jmp    80098d <memmove+0x64>
  800970:	89 f2                	mov    %esi,%edx
  800972:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 0f                	jne    800988 <memmove+0x5f>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 87 ff ff ff       	call   800929 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c6                	mov    %eax,%esi
  8009b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	eb 1a                	jmp    8009d0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b6:	0f b6 08             	movzbl (%eax),%ecx
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	38 d9                	cmp    %bl,%cl
  8009be:	74 0a                	je     8009ca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c0:	0f b6 c1             	movzbl %cl,%eax
  8009c3:	0f b6 db             	movzbl %bl,%ebx
  8009c6:	29 d8                	sub    %ebx,%eax
  8009c8:	eb 0f                	jmp    8009d9 <memcmp+0x35>
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	75 e2                	jne    8009b6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009eb:	eb 07                	jmp    8009f4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	74 07                	je     8009f8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	39 d0                	cmp    %edx,%eax
  8009f6:	72 f5                	jb     8009ed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 03                	jmp    800a0b <strtol+0x11>
		s++;
  800a08:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	3c 09                	cmp    $0x9,%al
  800a10:	74 f6                	je     800a08 <strtol+0xe>
  800a12:	3c 20                	cmp    $0x20,%al
  800a14:	74 f2                	je     800a08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a16:	3c 2b                	cmp    $0x2b,%al
  800a18:	75 0a                	jne    800a24 <strtol+0x2a>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a22:	eb 10                	jmp    800a34 <strtol+0x3a>
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	75 07                	jne    800a34 <strtol+0x3a>
		s++, neg = 1;
  800a2d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a30:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	0f 94 c0             	sete   %al
  800a39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3f:	75 19                	jne    800a5a <strtol+0x60>
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 14                	jne    800a5a <strtol+0x60>
  800a46:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4a:	0f 85 82 00 00 00    	jne    800ad2 <strtol+0xd8>
		s += 2, base = 16;
  800a50:	83 c1 02             	add    $0x2,%ecx
  800a53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a58:	eb 16                	jmp    800a70 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5a:	84 c0                	test   %al,%al
  800a5c:	74 12                	je     800a70 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 08                	jne    800a70 <strtol+0x76>
		s++, base = 8;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	0f b6 11             	movzbl (%ecx),%edx
  800a7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 09             	cmp    $0x9,%bl
  800a83:	77 08                	ja     800a8d <strtol+0x93>
			dig = *s - '0';
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 30             	sub    $0x30,%edx
  800a8b:	eb 22                	jmp    800aaf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 19             	cmp    $0x19,%bl
  800a95:	77 08                	ja     800a9f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 57             	sub    $0x57,%edx
  800a9d:	eb 10                	jmp    800aaf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 16                	ja     800abf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab2:	7d 0f                	jge    800ac3 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abd:	eb b9                	jmp    800a78 <strtol+0x7e>
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	eb 02                	jmp    800ac5 <strtol+0xcb>
  800ac3:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac9:	74 0d                	je     800ad8 <strtol+0xde>
		*endptr = (char *) s;
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ace:	89 0e                	mov    %ecx,(%esi)
  800ad0:	eb 06                	jmp    800ad8 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad2:	84 c0                	test   %al,%al
  800ad4:	75 92                	jne    800a68 <strtol+0x6e>
  800ad6:	eb 98                	jmp    800a70 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad8:	f7 da                	neg    %edx
  800ada:	85 ff                	test   %edi,%edi
  800adc:	0f 45 c2             	cmovne %edx,%eax
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	89 c7                	mov    %eax,%edi
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	89 cb                	mov    %ecx,%ebx
  800b39:	89 cf                	mov    %ecx,%edi
  800b3b:	89 ce                	mov    %ecx,%esi
  800b3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 17                	jle    800b5a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	50                   	push   %eax
  800b47:	6a 03                	push   $0x3
  800b49:	68 40 11 80 00       	push   $0x801140
  800b4e:	6a 23                	push   $0x23
  800b50:	68 5d 11 80 00       	push   $0x80115d
  800b55:	e8 dd f5 ff ff       	call   800137 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    
  800b81:	66 90                	xchg   %ax,%ax
  800b83:	66 90                	xchg   %ax,%ax
  800b85:	66 90                	xchg   %ax,%ax
  800b87:	66 90                	xchg   %ax,%ax
  800b89:	66 90                	xchg   %ax,%ax
  800b8b:	66 90                	xchg   %ax,%ax
  800b8d:	66 90                	xchg   %ax,%ax
  800b8f:	90                   	nop

00800b90 <__udivdi3>:
  800b90:	55                   	push   %ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	83 ec 10             	sub    $0x10,%esp
  800b96:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800b9a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800b9e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ba2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ba6:	85 d2                	test   %edx,%edx
  800ba8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bac:	89 34 24             	mov    %esi,(%esp)
  800baf:	89 c8                	mov    %ecx,%eax
  800bb1:	75 35                	jne    800be8 <__udivdi3+0x58>
  800bb3:	39 f1                	cmp    %esi,%ecx
  800bb5:	0f 87 bd 00 00 00    	ja     800c78 <__udivdi3+0xe8>
  800bbb:	85 c9                	test   %ecx,%ecx
  800bbd:	89 cd                	mov    %ecx,%ebp
  800bbf:	75 0b                	jne    800bcc <__udivdi3+0x3c>
  800bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc6:	31 d2                	xor    %edx,%edx
  800bc8:	f7 f1                	div    %ecx
  800bca:	89 c5                	mov    %eax,%ebp
  800bcc:	89 f0                	mov    %esi,%eax
  800bce:	31 d2                	xor    %edx,%edx
  800bd0:	f7 f5                	div    %ebp
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	89 f8                	mov    %edi,%eax
  800bd6:	f7 f5                	div    %ebp
  800bd8:	89 f2                	mov    %esi,%edx
  800bda:	83 c4 10             	add    $0x10,%esp
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    
  800be1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be8:	3b 14 24             	cmp    (%esp),%edx
  800beb:	77 7b                	ja     800c68 <__udivdi3+0xd8>
  800bed:	0f bd f2             	bsr    %edx,%esi
  800bf0:	83 f6 1f             	xor    $0x1f,%esi
  800bf3:	0f 84 97 00 00 00    	je     800c90 <__udivdi3+0x100>
  800bf9:	bd 20 00 00 00       	mov    $0x20,%ebp
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 f1                	mov    %esi,%ecx
  800c02:	29 f5                	sub    %esi,%ebp
  800c04:	d3 e7                	shl    %cl,%edi
  800c06:	89 c2                	mov    %eax,%edx
  800c08:	89 e9                	mov    %ebp,%ecx
  800c0a:	d3 ea                	shr    %cl,%edx
  800c0c:	89 f1                	mov    %esi,%ecx
  800c0e:	09 fa                	or     %edi,%edx
  800c10:	8b 3c 24             	mov    (%esp),%edi
  800c13:	d3 e0                	shl    %cl,%eax
  800c15:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c19:	89 e9                	mov    %ebp,%ecx
  800c1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800c23:	89 fa                	mov    %edi,%edx
  800c25:	d3 ea                	shr    %cl,%edx
  800c27:	89 f1                	mov    %esi,%ecx
  800c29:	d3 e7                	shl    %cl,%edi
  800c2b:	89 e9                	mov    %ebp,%ecx
  800c2d:	d3 e8                	shr    %cl,%eax
  800c2f:	09 c7                	or     %eax,%edi
  800c31:	89 f8                	mov    %edi,%eax
  800c33:	f7 74 24 08          	divl   0x8(%esp)
  800c37:	89 d5                	mov    %edx,%ebp
  800c39:	89 c7                	mov    %eax,%edi
  800c3b:	f7 64 24 0c          	mull   0xc(%esp)
  800c3f:	39 d5                	cmp    %edx,%ebp
  800c41:	89 14 24             	mov    %edx,(%esp)
  800c44:	72 11                	jb     800c57 <__udivdi3+0xc7>
  800c46:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c4a:	89 f1                	mov    %esi,%ecx
  800c4c:	d3 e2                	shl    %cl,%edx
  800c4e:	39 c2                	cmp    %eax,%edx
  800c50:	73 5e                	jae    800cb0 <__udivdi3+0x120>
  800c52:	3b 2c 24             	cmp    (%esp),%ebp
  800c55:	75 59                	jne    800cb0 <__udivdi3+0x120>
  800c57:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c5a:	31 f6                	xor    %esi,%esi
  800c5c:	89 f2                	mov    %esi,%edx
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    
  800c65:	8d 76 00             	lea    0x0(%esi),%esi
  800c68:	31 f6                	xor    %esi,%esi
  800c6a:	31 c0                	xor    %eax,%eax
  800c6c:	89 f2                	mov    %esi,%edx
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
  800c75:	8d 76 00             	lea    0x0(%esi),%esi
  800c78:	89 f2                	mov    %esi,%edx
  800c7a:	31 f6                	xor    %esi,%esi
  800c7c:	89 f8                	mov    %edi,%eax
  800c7e:	f7 f1                	div    %ecx
  800c80:	89 f2                	mov    %esi,%edx
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
  800c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c90:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c94:	76 0b                	jbe    800ca1 <__udivdi3+0x111>
  800c96:	31 c0                	xor    %eax,%eax
  800c98:	3b 14 24             	cmp    (%esp),%edx
  800c9b:	0f 83 37 ff ff ff    	jae    800bd8 <__udivdi3+0x48>
  800ca1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca6:	e9 2d ff ff ff       	jmp    800bd8 <__udivdi3+0x48>
  800cab:	90                   	nop
  800cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 f8                	mov    %edi,%eax
  800cb2:	31 f6                	xor    %esi,%esi
  800cb4:	e9 1f ff ff ff       	jmp    800bd8 <__udivdi3+0x48>
  800cb9:	66 90                	xchg   %ax,%ax
  800cbb:	66 90                	xchg   %ax,%ax
  800cbd:	66 90                	xchg   %ax,%ax
  800cbf:	90                   	nop

00800cc0 <__umoddi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	83 ec 20             	sub    $0x20,%esp
  800cc6:	8b 44 24 34          	mov    0x34(%esp),%eax
  800cca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800cce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cd2:	89 c6                	mov    %eax,%esi
  800cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cdc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800ce0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ce4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800ce8:	89 74 24 18          	mov    %esi,0x18(%esp)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	89 c2                	mov    %eax,%edx
  800cf0:	75 1e                	jne    800d10 <__umoddi3+0x50>
  800cf2:	39 f7                	cmp    %esi,%edi
  800cf4:	76 52                	jbe    800d48 <__umoddi3+0x88>
  800cf6:	89 c8                	mov    %ecx,%eax
  800cf8:	89 f2                	mov    %esi,%edx
  800cfa:	f7 f7                	div    %edi
  800cfc:	89 d0                	mov    %edx,%eax
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	83 c4 20             	add    $0x20,%esp
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
  800d07:	89 f6                	mov    %esi,%esi
  800d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d10:	39 f0                	cmp    %esi,%eax
  800d12:	77 5c                	ja     800d70 <__umoddi3+0xb0>
  800d14:	0f bd e8             	bsr    %eax,%ebp
  800d17:	83 f5 1f             	xor    $0x1f,%ebp
  800d1a:	75 64                	jne    800d80 <__umoddi3+0xc0>
  800d1c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800d20:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800d24:	0f 86 f6 00 00 00    	jbe    800e20 <__umoddi3+0x160>
  800d2a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800d2e:	0f 82 ec 00 00 00    	jb     800e20 <__umoddi3+0x160>
  800d34:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d38:	8b 54 24 18          	mov    0x18(%esp),%edx
  800d3c:	83 c4 20             	add    $0x20,%esp
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
  800d43:	90                   	nop
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	85 ff                	test   %edi,%edi
  800d4a:	89 fd                	mov    %edi,%ebp
  800d4c:	75 0b                	jne    800d59 <__umoddi3+0x99>
  800d4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d53:	31 d2                	xor    %edx,%edx
  800d55:	f7 f7                	div    %edi
  800d57:	89 c5                	mov    %eax,%ebp
  800d59:	8b 44 24 10          	mov    0x10(%esp),%eax
  800d5d:	31 d2                	xor    %edx,%edx
  800d5f:	f7 f5                	div    %ebp
  800d61:	89 c8                	mov    %ecx,%eax
  800d63:	f7 f5                	div    %ebp
  800d65:	eb 95                	jmp    800cfc <__umoddi3+0x3c>
  800d67:	89 f6                	mov    %esi,%esi
  800d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d70:	89 c8                	mov    %ecx,%eax
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	83 c4 20             	add    $0x20,%esp
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    
  800d7b:	90                   	nop
  800d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d80:	b8 20 00 00 00       	mov    $0x20,%eax
  800d85:	89 e9                	mov    %ebp,%ecx
  800d87:	29 e8                	sub    %ebp,%eax
  800d89:	d3 e2                	shl    %cl,%edx
  800d8b:	89 c7                	mov    %eax,%edi
  800d8d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e8                	shr    %cl,%eax
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d9f:	09 d1                	or     %edx,%ecx
  800da1:	89 fa                	mov    %edi,%edx
  800da3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800da7:	89 e9                	mov    %ebp,%ecx
  800da9:	d3 e0                	shl    %cl,%eax
  800dab:	89 f9                	mov    %edi,%ecx
  800dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800db1:	89 f0                	mov    %esi,%eax
  800db3:	d3 e8                	shr    %cl,%eax
  800db5:	89 e9                	mov    %ebp,%ecx
  800db7:	89 c7                	mov    %eax,%edi
  800db9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800dbd:	d3 e6                	shl    %cl,%esi
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 fa                	mov    %edi,%edx
  800dc3:	d3 e8                	shr    %cl,%eax
  800dc5:	89 e9                	mov    %ebp,%ecx
  800dc7:	09 f0                	or     %esi,%eax
  800dc9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800dcd:	f7 74 24 10          	divl   0x10(%esp)
  800dd1:	d3 e6                	shl    %cl,%esi
  800dd3:	89 d1                	mov    %edx,%ecx
  800dd5:	f7 64 24 0c          	mull   0xc(%esp)
  800dd9:	39 d1                	cmp    %edx,%ecx
  800ddb:	89 74 24 14          	mov    %esi,0x14(%esp)
  800ddf:	89 d7                	mov    %edx,%edi
  800de1:	89 c6                	mov    %eax,%esi
  800de3:	72 0a                	jb     800def <__umoddi3+0x12f>
  800de5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800de9:	73 10                	jae    800dfb <__umoddi3+0x13b>
  800deb:	39 d1                	cmp    %edx,%ecx
  800ded:	75 0c                	jne    800dfb <__umoddi3+0x13b>
  800def:	89 d7                	mov    %edx,%edi
  800df1:	89 c6                	mov    %eax,%esi
  800df3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800df7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800dfb:	89 ca                	mov    %ecx,%edx
  800dfd:	89 e9                	mov    %ebp,%ecx
  800dff:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e03:	29 f0                	sub    %esi,%eax
  800e05:	19 fa                	sbb    %edi,%edx
  800e07:	d3 e8                	shr    %cl,%eax
  800e09:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800e0e:	89 d7                	mov    %edx,%edi
  800e10:	d3 e7                	shl    %cl,%edi
  800e12:	89 e9                	mov    %ebp,%ecx
  800e14:	09 f8                	or     %edi,%eax
  800e16:	d3 ea                	shr    %cl,%edx
  800e18:	83 c4 20             	add    $0x20,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
  800e20:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e24:	29 f9                	sub    %edi,%ecx
  800e26:	19 c6                	sbb    %eax,%esi
  800e28:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e2c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e30:	e9 ff fe ff ff       	jmp    800d34 <__umoddi3+0x74>
