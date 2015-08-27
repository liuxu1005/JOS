
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 ef 07 00 00       	call   800838 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
  80004e:	83 c4 10             	add    $0x10,%esp
}
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 c8 0b 00 00       	call   800c41 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 0c 29 80 00       	push   $0x80290c
  800086:	6a 13                	push   $0x13
  800088:	68 1f 29 80 00       	push   $0x80291f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 7d 0e 00 00       	call   800f14 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 1b 2e 80 00       	push   $0x802e1b
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 1f 29 80 00       	push   $0x80291f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 72 07 00 00       	call   800838 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 a9 21 00 00       	call   802280 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f8 07 00 00       	call   8008e2 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 06 29 80 00       	mov    $0x802906,%edx
  8000f4:	b8 00 29 80 00       	mov    $0x802900,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 33 29 80 00       	push   $0x802933
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 4e 29 80 00       	push   $0x80294e
  80010e:	68 53 29 80 00       	push   $0x802953
  800113:	68 52 29 80 00       	push   $0x802952
  800118:	e8 97 1d 00 00       	call   801eb4 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 60 29 80 00       	push   $0x802960
  80012a:	6a 21                	push   $0x21
  80012c:	68 1f 29 80 00       	push   $0x80291f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 41 21 00 00       	call   802280 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 90 07 00 00       	call   8008e2 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 06 29 80 00       	mov    $0x802906,%edx
  80015c:	b8 00 29 80 00       	mov    $0x802900,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 6a 29 80 00       	push   $0x80296a
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   
  800170:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800183:	e8 7b 0a 00 00       	call   800c03 <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
  8001b4:	83 c4 10             	add    $0x10,%esp
}
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 3a 11 00 00       	call   801303 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 ef 09 00 00       	call   800bc2 <sys_env_destroy>
  8001d3:	83 c4 10             	add    $0x10,%esp
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 18 0a 00 00       	call   800c03 <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 b0 29 80 00       	push   $0x8029b0
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 59 2e 80 00 	movl   $0x802e59,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 37 09 00 00       	call   800b85 <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 4f 01 00 00       	call   8003e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 dc 08 00 00       	call   800b85 <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 d1                	mov    %edx,%ecx
  8002da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002f0:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002f3:	72 05                	jb     8002fa <printnum+0x35>
  8002f5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002f8:	77 3e                	ja     800338 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	ff 75 18             	pushl  0x18(%ebp)
  800300:	83 eb 01             	sub    $0x1,%ebx
  800303:	53                   	push   %ebx
  800304:	50                   	push   %eax
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 07 23 00 00       	call   802620 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 13                	jmp    80033f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800338:	83 eb 01             	sub    $0x1,%ebx
  80033b:	85 db                	test   %ebx,%ebx
  80033d:	7f ed                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	56                   	push   %esi
  800343:	83 ec 04             	sub    $0x4,%esp
  800346:	ff 75 e4             	pushl  -0x1c(%ebp)
  800349:	ff 75 e0             	pushl  -0x20(%ebp)
  80034c:	ff 75 dc             	pushl  -0x24(%ebp)
  80034f:	ff 75 d8             	pushl  -0x28(%ebp)
  800352:	e8 f9 23 00 00       	call   802750 <__umoddi3>
  800357:	83 c4 14             	add    $0x14,%esp
  80035a:	0f be 80 d3 29 80 00 	movsbl 0x8029d3(%eax),%eax
  800361:	50                   	push   %eax
  800362:	ff d7                	call   *%edi
  800364:	83 c4 10             	add    $0x10,%esp
}
  800367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800372:	83 fa 01             	cmp    $0x1,%edx
  800375:	7e 0e                	jle    800385 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800377:	8b 10                	mov    (%eax),%edx
  800379:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	8b 52 04             	mov    0x4(%edx),%edx
  800383:	eb 22                	jmp    8003a7 <getuint+0x38>
	else if (lflag)
  800385:	85 d2                	test   %edx,%edx
  800387:	74 10                	je     800399 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 0e                	jmp    8003a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 0a                	jae    8003c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	88 02                	mov    %al,(%edx)
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cf:	50                   	push   %eax
  8003d0:	ff 75 10             	pushl  0x10(%ebp)
  8003d3:	ff 75 0c             	pushl  0xc(%ebp)
  8003d6:	ff 75 08             	pushl  0x8(%ebp)
  8003d9:	e8 05 00 00 00       	call   8003e3 <vprintfmt>
	va_end(ap);
  8003de:	83 c4 10             	add    $0x10,%esp
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	57                   	push   %edi
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 2c             	sub    $0x2c,%esp
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f5:	eb 12                	jmp    800409 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	0f 84 90 03 00 00    	je     80078f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	50                   	push   %eax
  800404:	ff d6                	call   *%esi
  800406:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	83 c7 01             	add    $0x1,%edi
  80040c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800410:	83 f8 25             	cmp    $0x25,%eax
  800413:	75 e2                	jne    8003f7 <vprintfmt+0x14>
  800415:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800419:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800420:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800427:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80042e:	ba 00 00 00 00       	mov    $0x0,%edx
  800433:	eb 07                	jmp    80043c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800438:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8d 47 01             	lea    0x1(%edi),%eax
  80043f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800442:	0f b6 07             	movzbl (%edi),%eax
  800445:	0f b6 c8             	movzbl %al,%ecx
  800448:	83 e8 23             	sub    $0x23,%eax
  80044b:	3c 55                	cmp    $0x55,%al
  80044d:	0f 87 21 03 00 00    	ja     800774 <vprintfmt+0x391>
  800453:	0f b6 c0             	movzbl %al,%eax
  800456:	ff 24 85 40 2b 80 00 	jmp    *0x802b40(,%eax,4)
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800460:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800464:	eb d6                	jmp    80043c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800471:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800474:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800478:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80047b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80047e:	83 fa 09             	cmp    $0x9,%edx
  800481:	77 39                	ja     8004bc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800483:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800486:	eb e9                	jmp    800471 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 48 04             	lea    0x4(%eax),%ecx
  80048e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800499:	eb 27                	jmp    8004c2 <vprintfmt+0xdf>
  80049b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a5:	0f 49 c8             	cmovns %eax,%ecx
  8004a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	eb 8c                	jmp    80043c <vprintfmt+0x59>
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ba:	eb 80                	jmp    80043c <vprintfmt+0x59>
  8004bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004bf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c6:	0f 89 70 ff ff ff    	jns    80043c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d9:	e9 5e ff ff ff       	jmp    80043c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004de:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e4:	e9 53 ff ff ff       	jmp    80043c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	ff 30                	pushl  (%eax)
  8004f8:	ff d6                	call   *%esi
			break;
  8004fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800500:	e9 04 ff ff ff       	jmp    800409 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 04             	lea    0x4(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	99                   	cltd   
  800511:	31 d0                	xor    %edx,%eax
  800513:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800515:	83 f8 0f             	cmp    $0xf,%eax
  800518:	7f 0b                	jg     800525 <vprintfmt+0x142>
  80051a:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	75 18                	jne    80053d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800525:	50                   	push   %eax
  800526:	68 eb 29 80 00       	push   $0x8029eb
  80052b:	53                   	push   %ebx
  80052c:	56                   	push   %esi
  80052d:	e8 94 fe ff ff       	call   8003c6 <printfmt>
  800532:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800538:	e9 cc fe ff ff       	jmp    800409 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80053d:	52                   	push   %edx
  80053e:	68 2d 2f 80 00       	push   $0x802f2d
  800543:	53                   	push   %ebx
  800544:	56                   	push   %esi
  800545:	e8 7c fe ff ff       	call   8003c6 <printfmt>
  80054a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800550:	e9 b4 fe ff ff       	jmp    800409 <vprintfmt+0x26>
  800555:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800558:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055b:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800569:	85 ff                	test   %edi,%edi
  80056b:	ba e4 29 80 00       	mov    $0x8029e4,%edx
  800570:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800573:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800577:	0f 84 92 00 00 00    	je     80060f <vprintfmt+0x22c>
  80057d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800581:	0f 8e 96 00 00 00    	jle    80061d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	51                   	push   %ecx
  80058b:	57                   	push   %edi
  80058c:	e8 86 02 00 00       	call   800817 <strnlen>
  800591:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800594:	29 c1                	sub    %eax,%ecx
  800596:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800599:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a8:	eb 0f                	jmp    8005b9 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	7f ed                	jg     8005aa <vprintfmt+0x1c7>
  8005bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c3:	85 c9                	test   %ecx,%ecx
  8005c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ca:	0f 49 c1             	cmovns %ecx,%eax
  8005cd:	29 c1                	sub    %eax,%ecx
  8005cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d8:	89 cb                	mov    %ecx,%ebx
  8005da:	eb 4d                	jmp    800629 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e0:	74 1b                	je     8005fd <vprintfmt+0x21a>
  8005e2:	0f be c0             	movsbl %al,%eax
  8005e5:	83 e8 20             	sub    $0x20,%eax
  8005e8:	83 f8 5e             	cmp    $0x5e,%eax
  8005eb:	76 10                	jbe    8005fd <vprintfmt+0x21a>
					putch('?', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	ff 75 0c             	pushl  0xc(%ebp)
  8005f3:	6a 3f                	push   $0x3f
  8005f5:	ff 55 08             	call   *0x8(%ebp)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	eb 0d                	jmp    80060a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	ff 75 0c             	pushl  0xc(%ebp)
  800603:	52                   	push   %edx
  800604:	ff 55 08             	call   *0x8(%ebp)
  800607:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060a:	83 eb 01             	sub    $0x1,%ebx
  80060d:	eb 1a                	jmp    800629 <vprintfmt+0x246>
  80060f:	89 75 08             	mov    %esi,0x8(%ebp)
  800612:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800615:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800618:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061b:	eb 0c                	jmp    800629 <vprintfmt+0x246>
  80061d:	89 75 08             	mov    %esi,0x8(%ebp)
  800620:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800623:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800626:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800629:	83 c7 01             	add    $0x1,%edi
  80062c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800630:	0f be d0             	movsbl %al,%edx
  800633:	85 d2                	test   %edx,%edx
  800635:	74 23                	je     80065a <vprintfmt+0x277>
  800637:	85 f6                	test   %esi,%esi
  800639:	78 a1                	js     8005dc <vprintfmt+0x1f9>
  80063b:	83 ee 01             	sub    $0x1,%esi
  80063e:	79 9c                	jns    8005dc <vprintfmt+0x1f9>
  800640:	89 df                	mov    %ebx,%edi
  800642:	8b 75 08             	mov    0x8(%ebp),%esi
  800645:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800648:	eb 18                	jmp    800662 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 20                	push   $0x20
  800650:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb 08                	jmp    800662 <vprintfmt+0x27f>
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	8b 75 08             	mov    0x8(%ebp),%esi
  80065f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800662:	85 ff                	test   %edi,%edi
  800664:	7f e4                	jg     80064a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800669:	e9 9b fd ff ff       	jmp    800409 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066e:	83 fa 01             	cmp    $0x1,%edx
  800671:	7e 16                	jle    800689 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 08             	lea    0x8(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)
  80067c:	8b 50 04             	mov    0x4(%eax),%edx
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800687:	eb 32                	jmp    8006bb <vprintfmt+0x2d8>
	else if (lflag)
  800689:	85 d2                	test   %edx,%edx
  80068b:	74 18                	je     8006a5 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 00                	mov    (%eax),%eax
  800698:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069b:	89 c1                	mov    %eax,%ecx
  80069d:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a3:	eb 16                	jmp    8006bb <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 c1                	mov    %eax,%ecx
  8006b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ca:	79 74                	jns    800740 <vprintfmt+0x35d>
				putch('-', putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 2d                	push   $0x2d
  8006d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006da:	f7 d8                	neg    %eax
  8006dc:	83 d2 00             	adc    $0x0,%edx
  8006df:	f7 da                	neg    %edx
  8006e1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e9:	eb 55                	jmp    800740 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 7c fc ff ff       	call   80036f <getuint>
			base = 10;
  8006f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f8:	eb 46                	jmp    800740 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fd:	e8 6d fc ff ff       	call   80036f <getuint>
                        base = 8;
  800702:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800707:	eb 37                	jmp    800740 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 30                	push   $0x30
  80070f:	ff d6                	call   *%esi
			putch('x', putdat);
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 78                	push   $0x78
  800717:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 04             	lea    0x4(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800722:	8b 00                	mov    (%eax),%eax
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800729:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800731:	eb 0d                	jmp    800740 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 34 fc ff ff       	call   80036f <getuint>
			base = 16;
  80073b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800740:	83 ec 0c             	sub    $0xc,%esp
  800743:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800747:	57                   	push   %edi
  800748:	ff 75 e0             	pushl  -0x20(%ebp)
  80074b:	51                   	push   %ecx
  80074c:	52                   	push   %edx
  80074d:	50                   	push   %eax
  80074e:	89 da                	mov    %ebx,%edx
  800750:	89 f0                	mov    %esi,%eax
  800752:	e8 6e fb ff ff       	call   8002c5 <printnum>
			break;
  800757:	83 c4 20             	add    $0x20,%esp
  80075a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075d:	e9 a7 fc ff ff       	jmp    800409 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	51                   	push   %ecx
  800767:	ff d6                	call   *%esi
			break;
  800769:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076f:	e9 95 fc ff ff       	jmp    800409 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 25                	push   $0x25
  80077a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 03                	jmp    800784 <vprintfmt+0x3a1>
  800781:	83 ef 01             	sub    $0x1,%edi
  800784:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800788:	75 f7                	jne    800781 <vprintfmt+0x39e>
  80078a:	e9 7a fc ff ff       	jmp    800409 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5f                   	pop    %edi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 18             	sub    $0x18,%esp
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	74 26                	je     8007de <vsnprintf+0x47>
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	7e 22                	jle    8007de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bc:	ff 75 14             	pushl  0x14(%ebp)
  8007bf:	ff 75 10             	pushl  0x10(%ebp)
  8007c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	68 a9 03 80 00       	push   $0x8003a9
  8007cb:	e8 13 fc ff ff       	call   8003e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d9:	83 c4 10             	add    $0x10,%esp
  8007dc:	eb 05                	jmp    8007e3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 10             	pushl  0x10(%ebp)
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	ff 75 08             	pushl  0x8(%ebp)
  8007f8:	e8 9a ff ff ff       	call   800797 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	eb 03                	jmp    80080f <strlen+0x10>
		n++;
  80080c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800813:	75 f7                	jne    80080c <strlen+0xd>
		n++;
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
  800825:	eb 03                	jmp    80082a <strnlen+0x13>
		n++;
  800827:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 08                	je     800836 <strnlen+0x1f>
  80082e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800832:	75 f3                	jne    800827 <strnlen+0x10>
  800834:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800842:	89 c2                	mov    %eax,%edx
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800851:	84 db                	test   %bl,%bl
  800853:	75 ef                	jne    800844 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800855:	5b                   	pop    %ebx
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085f:	53                   	push   %ebx
  800860:	e8 9a ff ff ff       	call   8007ff <strlen>
  800865:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	01 d8                	add    %ebx,%eax
  80086d:	50                   	push   %eax
  80086e:	e8 c5 ff ff ff       	call   800838 <strcpy>
	return dst;
}
  800873:	89 d8                	mov    %ebx,%eax
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 75 08             	mov    0x8(%ebp),%esi
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800885:	89 f3                	mov    %esi,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088a:	89 f2                	mov    %esi,%edx
  80088c:	eb 0f                	jmp    80089d <strncpy+0x23>
		*dst++ = *src;
  80088e:	83 c2 01             	add    $0x1,%edx
  800891:	0f b6 01             	movzbl (%ecx),%eax
  800894:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800897:	80 39 01             	cmpb   $0x1,(%ecx)
  80089a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089d:	39 da                	cmp    %ebx,%edx
  80089f:	75 ed                	jne    80088e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
  8008ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b7:	85 d2                	test   %edx,%edx
  8008b9:	74 21                	je     8008dc <strlcpy+0x35>
  8008bb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bf:	89 f2                	mov    %esi,%edx
  8008c1:	eb 09                	jmp    8008cc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cc:	39 c2                	cmp    %eax,%edx
  8008ce:	74 09                	je     8008d9 <strlcpy+0x32>
  8008d0:	0f b6 19             	movzbl (%ecx),%ebx
  8008d3:	84 db                	test   %bl,%bl
  8008d5:	75 ec                	jne    8008c3 <strlcpy+0x1c>
  8008d7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008dc:	29 f0                	sub    %esi,%eax
}
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008eb:	eb 06                	jmp    8008f3 <strcmp+0x11>
		p++, q++;
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f3:	0f b6 01             	movzbl (%ecx),%eax
  8008f6:	84 c0                	test   %al,%al
  8008f8:	74 04                	je     8008fe <strcmp+0x1c>
  8008fa:	3a 02                	cmp    (%edx),%al
  8008fc:	74 ef                	je     8008ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 c0             	movzbl %al,%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	53                   	push   %ebx
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800912:	89 c3                	mov    %eax,%ebx
  800914:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800917:	eb 06                	jmp    80091f <strncmp+0x17>
		n--, p++, q++;
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091f:	39 d8                	cmp    %ebx,%eax
  800921:	74 15                	je     800938 <strncmp+0x30>
  800923:	0f b6 08             	movzbl (%eax),%ecx
  800926:	84 c9                	test   %cl,%cl
  800928:	74 04                	je     80092e <strncmp+0x26>
  80092a:	3a 0a                	cmp    (%edx),%cl
  80092c:	74 eb                	je     800919 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092e:	0f b6 00             	movzbl (%eax),%eax
  800931:	0f b6 12             	movzbl (%edx),%edx
  800934:	29 d0                	sub    %edx,%eax
  800936:	eb 05                	jmp    80093d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093d:	5b                   	pop    %ebx
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	eb 07                	jmp    800953 <strchr+0x13>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 0f                	je     80095f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	0f b6 10             	movzbl (%eax),%edx
  800956:	84 d2                	test   %dl,%dl
  800958:	75 f2                	jne    80094c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096b:	eb 03                	jmp    800970 <strfind+0xf>
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800973:	84 d2                	test   %dl,%dl
  800975:	74 04                	je     80097b <strfind+0x1a>
  800977:	38 ca                	cmp    %cl,%dl
  800979:	75 f2                	jne    80096d <strfind+0xc>
			break;
	return (char *) s;
}
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	57                   	push   %edi
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 7d 08             	mov    0x8(%ebp),%edi
  800986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800989:	85 c9                	test   %ecx,%ecx
  80098b:	74 36                	je     8009c3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800993:	75 28                	jne    8009bd <memset+0x40>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 23                	jne    8009bd <memset+0x40>
		c &= 0xFF;
  80099a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099e:	89 d3                	mov    %edx,%ebx
  8009a0:	c1 e3 08             	shl    $0x8,%ebx
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	c1 e6 18             	shl    $0x18,%esi
  8009a8:	89 d0                	mov    %edx,%eax
  8009aa:	c1 e0 10             	shl    $0x10,%eax
  8009ad:	09 f0                	or     %esi,%eax
  8009af:	09 c2                	or     %eax,%edx
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b8:	fc                   	cld    
  8009b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bb:	eb 06                	jmp    8009c3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	fc                   	cld    
  8009c1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c3:	89 f8                	mov    %edi,%eax
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d8:	39 c6                	cmp    %eax,%esi
  8009da:	73 35                	jae    800a11 <memmove+0x47>
  8009dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009df:	39 d0                	cmp    %edx,%eax
  8009e1:	73 2e                	jae    800a11 <memmove+0x47>
		s += n;
		d += n;
  8009e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009e6:	89 d6                	mov    %edx,%esi
  8009e8:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f0:	75 13                	jne    800a05 <memmove+0x3b>
  8009f2:	f6 c1 03             	test   $0x3,%cl
  8009f5:	75 0e                	jne    800a05 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f7:	83 ef 04             	sub    $0x4,%edi
  8009fa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a00:	fd                   	std    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb 09                	jmp    800a0e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a05:	83 ef 01             	sub    $0x1,%edi
  800a08:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0b:	fd                   	std    
  800a0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0e:	fc                   	cld    
  800a0f:	eb 1d                	jmp    800a2e <memmove+0x64>
  800a11:	89 f2                	mov    %esi,%edx
  800a13:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	f6 c2 03             	test   $0x3,%dl
  800a18:	75 0f                	jne    800a29 <memmove+0x5f>
  800a1a:	f6 c1 03             	test   $0x3,%cl
  800a1d:	75 0a                	jne    800a29 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a22:	89 c7                	mov    %eax,%edi
  800a24:	fc                   	cld    
  800a25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a27:	eb 05                	jmp    800a2e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a29:	89 c7                	mov    %eax,%edi
  800a2b:	fc                   	cld    
  800a2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a35:	ff 75 10             	pushl  0x10(%ebp)
  800a38:	ff 75 0c             	pushl  0xc(%ebp)
  800a3b:	ff 75 08             	pushl  0x8(%ebp)
  800a3e:	e8 87 ff ff ff       	call   8009ca <memmove>
}
  800a43:	c9                   	leave  
  800a44:	c3                   	ret    

00800a45 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a50:	89 c6                	mov    %eax,%esi
  800a52:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a55:	eb 1a                	jmp    800a71 <memcmp+0x2c>
		if (*s1 != *s2)
  800a57:	0f b6 08             	movzbl (%eax),%ecx
  800a5a:	0f b6 1a             	movzbl (%edx),%ebx
  800a5d:	38 d9                	cmp    %bl,%cl
  800a5f:	74 0a                	je     800a6b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a61:	0f b6 c1             	movzbl %cl,%eax
  800a64:	0f b6 db             	movzbl %bl,%ebx
  800a67:	29 d8                	sub    %ebx,%eax
  800a69:	eb 0f                	jmp    800a7a <memcmp+0x35>
		s1++, s2++;
  800a6b:	83 c0 01             	add    $0x1,%eax
  800a6e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a71:	39 f0                	cmp    %esi,%eax
  800a73:	75 e2                	jne    800a57 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8c:	eb 07                	jmp    800a95 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	38 08                	cmp    %cl,(%eax)
  800a90:	74 07                	je     800a99 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	39 d0                	cmp    %edx,%eax
  800a97:	72 f5                	jb     800a8e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa7:	eb 03                	jmp    800aac <strtol+0x11>
		s++;
  800aa9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aac:	0f b6 01             	movzbl (%ecx),%eax
  800aaf:	3c 09                	cmp    $0x9,%al
  800ab1:	74 f6                	je     800aa9 <strtol+0xe>
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f2                	je     800aa9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab7:	3c 2b                	cmp    $0x2b,%al
  800ab9:	75 0a                	jne    800ac5 <strtol+0x2a>
		s++;
  800abb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac3:	eb 10                	jmp    800ad5 <strtol+0x3a>
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aca:	3c 2d                	cmp    $0x2d,%al
  800acc:	75 07                	jne    800ad5 <strtol+0x3a>
		s++, neg = 1;
  800ace:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ad1:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad5:	85 db                	test   %ebx,%ebx
  800ad7:	0f 94 c0             	sete   %al
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 19                	jne    800afb <strtol+0x60>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	75 14                	jne    800afb <strtol+0x60>
  800ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aeb:	0f 85 82 00 00 00    	jne    800b73 <strtol+0xd8>
		s += 2, base = 16;
  800af1:	83 c1 02             	add    $0x2,%ecx
  800af4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af9:	eb 16                	jmp    800b11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800afb:	84 c0                	test   %al,%al
  800afd:	74 12                	je     800b11 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b04:	80 39 30             	cmpb   $0x30,(%ecx)
  800b07:	75 08                	jne    800b11 <strtol+0x76>
		s++, base = 8;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b19:	0f b6 11             	movzbl (%ecx),%edx
  800b1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1f:	89 f3                	mov    %esi,%ebx
  800b21:	80 fb 09             	cmp    $0x9,%bl
  800b24:	77 08                	ja     800b2e <strtol+0x93>
			dig = *s - '0';
  800b26:	0f be d2             	movsbl %dl,%edx
  800b29:	83 ea 30             	sub    $0x30,%edx
  800b2c:	eb 22                	jmp    800b50 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b31:	89 f3                	mov    %esi,%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 08                	ja     800b40 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b38:	0f be d2             	movsbl %dl,%edx
  800b3b:	83 ea 57             	sub    $0x57,%edx
  800b3e:	eb 10                	jmp    800b50 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b43:	89 f3                	mov    %esi,%ebx
  800b45:	80 fb 19             	cmp    $0x19,%bl
  800b48:	77 16                	ja     800b60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b4a:	0f be d2             	movsbl %dl,%edx
  800b4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b53:	7d 0f                	jge    800b64 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b55:	83 c1 01             	add    $0x1,%ecx
  800b58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5e:	eb b9                	jmp    800b19 <strtol+0x7e>
  800b60:	89 c2                	mov    %eax,%edx
  800b62:	eb 02                	jmp    800b66 <strtol+0xcb>
  800b64:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 0d                	je     800b79 <strtol+0xde>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
  800b71:	eb 06                	jmp    800b79 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b73:	84 c0                	test   %al,%al
  800b75:	75 92                	jne    800b09 <strtol+0x6e>
  800b77:	eb 98                	jmp    800b11 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b79:	f7 da                	neg    %edx
  800b7b:	85 ff                	test   %edi,%edi
  800b7d:	0f 45 c2             	cmovne %edx,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	89 c3                	mov    %eax,%ebx
  800b98:	89 c7                	mov    %eax,%edi
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	89 cb                	mov    %ecx,%ebx
  800bda:	89 cf                	mov    %ecx,%edi
  800bdc:	89 ce                	mov    %ecx,%esi
  800bde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 03                	push   $0x3
  800bea:	68 1f 2d 80 00       	push   $0x802d1f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 3c 2d 80 00       	push   $0x802d3c
  800bf6:	e8 dd f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	89 d7                	mov    %edx,%edi
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_yield>:

void
sys_yield(void)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c4a:	be 00 00 00 00       	mov    $0x0,%esi
  800c4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5d:	89 f7                	mov    %esi,%edi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 04                	push   $0x4
  800c6b:	68 1f 2d 80 00       	push   $0x802d1f
  800c70:	6a 23                	push   $0x23
  800c72:	68 3c 2d 80 00       	push   $0x802d3c
  800c77:	e8 5c f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9e:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 05                	push   $0x5
  800cad:	68 1f 2d 80 00       	push   $0x802d1f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 3c 2d 80 00       	push   $0x802d3c
  800cb9:	e8 1a f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 06                	push   $0x6
  800cef:	68 1f 2d 80 00       	push   $0x802d1f
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 3c 2d 80 00       	push   $0x802d3c
  800cfb:	e8 d8 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 08                	push   $0x8
  800d31:	68 1f 2d 80 00       	push   $0x802d1f
  800d36:	6a 23                	push   $0x23
  800d38:	68 3c 2d 80 00       	push   $0x802d3c
  800d3d:	e8 96 f4 ff ff       	call   8001d8 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 09                	push   $0x9
  800d73:	68 1f 2d 80 00       	push   $0x802d1f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 3c 2d 80 00       	push   $0x802d3c
  800d7f:	e8 54 f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 17                	jle    800dc6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 0a                	push   $0xa
  800db5:	68 1f 2d 80 00       	push   $0x802d1f
  800dba:	6a 23                	push   $0x23
  800dbc:	68 3c 2d 80 00       	push   $0x802d3c
  800dc1:	e8 12 f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	be 00 00 00 00       	mov    $0x0,%esi
  800dd9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	89 cb                	mov    %ecx,%ebx
  800e09:	89 cf                	mov    %ecx,%edi
  800e0b:	89 ce                	mov    %ecx,%esi
  800e0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 0d                	push   $0xd
  800e19:	68 1f 2d 80 00       	push   $0x802d1f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 3c 2d 80 00       	push   $0x802d3c
  800e25:	e8 ae f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	53                   	push   %ebx
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e3c:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e3e:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e42:	74 2e                	je     800e72 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e44:	89 c2                	mov    %eax,%edx
  800e46:	c1 ea 16             	shr    $0x16,%edx
  800e49:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e50:	f6 c2 01             	test   $0x1,%dl
  800e53:	74 1d                	je     800e72 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e55:	89 c2                	mov    %eax,%edx
  800e57:	c1 ea 0c             	shr    $0xc,%edx
  800e5a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e61:	f6 c1 01             	test   $0x1,%cl
  800e64:	74 0c                	je     800e72 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e6d:	f6 c6 08             	test   $0x8,%dh
  800e70:	75 14                	jne    800e86 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	68 4c 2d 80 00       	push   $0x802d4c
  800e7a:	6a 21                	push   $0x21
  800e7c:	68 df 2d 80 00       	push   $0x802ddf
  800e81:	e8 52 f3 ff ff       	call   8001d8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e8b:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	6a 07                	push   $0x7
  800e92:	68 00 f0 7f 00       	push   $0x7ff000
  800e97:	6a 00                	push   $0x0
  800e99:	e8 a3 fd ff ff       	call   800c41 <sys_page_alloc>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	79 14                	jns    800eb9 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 ea 2d 80 00       	push   $0x802dea
  800ead:	6a 2b                	push   $0x2b
  800eaf:	68 df 2d 80 00       	push   $0x802ddf
  800eb4:	e8 1f f3 ff ff       	call   8001d8 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800eb9:	83 ec 04             	sub    $0x4,%esp
  800ebc:	68 00 10 00 00       	push   $0x1000
  800ec1:	53                   	push   %ebx
  800ec2:	68 00 f0 7f 00       	push   $0x7ff000
  800ec7:	e8 fe fa ff ff       	call   8009ca <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800ecc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed3:	53                   	push   %ebx
  800ed4:	6a 00                	push   $0x0
  800ed6:	68 00 f0 7f 00       	push   $0x7ff000
  800edb:	6a 00                	push   $0x0
  800edd:	e8 a2 fd ff ff       	call   800c84 <sys_page_map>
  800ee2:	83 c4 20             	add    $0x20,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	79 14                	jns    800efd <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	68 00 2e 80 00       	push   $0x802e00
  800ef1:	6a 2e                	push   $0x2e
  800ef3:	68 df 2d 80 00       	push   $0x802ddf
  800ef8:	e8 db f2 ff ff       	call   8001d8 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800efd:	83 ec 08             	sub    $0x8,%esp
  800f00:	68 00 f0 7f 00       	push   $0x7ff000
  800f05:	6a 00                	push   $0x0
  800f07:	e8 ba fd ff ff       	call   800cc6 <sys_page_unmap>
  800f0c:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f1d:	68 32 0e 80 00       	push   $0x800e32
  800f22:	e8 2b 15 00 00       	call   802452 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f27:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2c:	cd 30                	int    $0x30
  800f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 12                	jns    800f4a <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f38:	50                   	push   %eax
  800f39:	68 14 2e 80 00       	push   $0x802e14
  800f3e:	6a 6d                	push   $0x6d
  800f40:	68 df 2d 80 00       	push   $0x802ddf
  800f45:	e8 8e f2 ff ff       	call   8001d8 <_panic>
  800f4a:	89 c7                	mov    %eax,%edi
  800f4c:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f51:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f55:	75 21                	jne    800f78 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f57:	e8 a7 fc ff ff       	call   800c03 <sys_getenvid>
  800f5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f69:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  800f6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f73:	e9 9c 01 00 00       	jmp    801114 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	c1 e8 16             	shr    $0x16,%eax
  800f7d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f84:	a8 01                	test   $0x1,%al
  800f86:	0f 84 f3 00 00 00    	je     80107f <fork+0x16b>
  800f8c:	89 d8                	mov    %ebx,%eax
  800f8e:	c1 e8 0c             	shr    $0xc,%eax
  800f91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f98:	f6 c2 01             	test   $0x1,%dl
  800f9b:	0f 84 de 00 00 00    	je     80107f <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800fa1:	89 c6                	mov    %eax,%esi
  800fa3:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800fa6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fad:	f6 c6 04             	test   $0x4,%dh
  800fb0:	74 37                	je     800fe9 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800fb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb9:	83 ec 0c             	sub    $0xc,%esp
  800fbc:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc1:	50                   	push   %eax
  800fc2:	56                   	push   %esi
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 b8 fc ff ff       	call   800c84 <sys_page_map>
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	0f 89 a8 00 00 00    	jns    80107f <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800fd7:	50                   	push   %eax
  800fd8:	68 70 2d 80 00       	push   $0x802d70
  800fdd:	6a 49                	push   $0x49
  800fdf:	68 df 2d 80 00       	push   $0x802ddf
  800fe4:	e8 ef f1 ff ff       	call   8001d8 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800fe9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff0:	f6 c6 08             	test   $0x8,%dh
  800ff3:	75 0b                	jne    801000 <fork+0xec>
  800ff5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ffc:	a8 02                	test   $0x2,%al
  800ffe:	74 57                	je     801057 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	68 05 08 00 00       	push   $0x805
  801008:	56                   	push   %esi
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	e8 72 fc ff ff       	call   800c84 <sys_page_map>
  801012:	83 c4 20             	add    $0x20,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 12                	jns    80102b <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  801019:	50                   	push   %eax
  80101a:	68 70 2d 80 00       	push   $0x802d70
  80101f:	6a 4c                	push   $0x4c
  801021:	68 df 2d 80 00       	push   $0x802ddf
  801026:	e8 ad f1 ff ff       	call   8001d8 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	68 05 08 00 00       	push   $0x805
  801033:	56                   	push   %esi
  801034:	6a 00                	push   $0x0
  801036:	56                   	push   %esi
  801037:	6a 00                	push   $0x0
  801039:	e8 46 fc ff ff       	call   800c84 <sys_page_map>
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	79 3a                	jns    80107f <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  801045:	50                   	push   %eax
  801046:	68 94 2d 80 00       	push   $0x802d94
  80104b:	6a 4e                	push   $0x4e
  80104d:	68 df 2d 80 00       	push   $0x802ddf
  801052:	e8 81 f1 ff ff       	call   8001d8 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	6a 05                	push   $0x5
  80105c:	56                   	push   %esi
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	6a 00                	push   $0x0
  801061:	e8 1e fc ff ff       	call   800c84 <sys_page_map>
  801066:	83 c4 20             	add    $0x20,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 12                	jns    80107f <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  80106d:	50                   	push   %eax
  80106e:	68 bc 2d 80 00       	push   $0x802dbc
  801073:	6a 50                	push   $0x50
  801075:	68 df 2d 80 00       	push   $0x802ddf
  80107a:	e8 59 f1 ff ff       	call   8001d8 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80107f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801085:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80108b:	0f 85 e7 fe ff ff    	jne    800f78 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	6a 07                	push   $0x7
  801096:	68 00 f0 bf ee       	push   $0xeebff000
  80109b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109e:	e8 9e fb ff ff       	call   800c41 <sys_page_alloc>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 14                	jns    8010be <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	68 24 2e 80 00       	push   $0x802e24
  8010b2:	6a 76                	push   $0x76
  8010b4:	68 df 2d 80 00       	push   $0x802ddf
  8010b9:	e8 1a f1 ff ff       	call   8001d8 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	68 c1 24 80 00       	push   $0x8024c1
  8010c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c9:	e8 be fc ff ff       	call   800d8c <sys_env_set_pgfault_upcall>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 14                	jns    8010e9 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8010d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d8:	68 3e 2e 80 00       	push   $0x802e3e
  8010dd:	6a 79                	push   $0x79
  8010df:	68 df 2d 80 00       	push   $0x802ddf
  8010e4:	e8 ef f0 ff ff       	call   8001d8 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	6a 02                	push   $0x2
  8010ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f1:	e8 12 fc ff ff       	call   800d08 <sys_env_set_status>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	79 14                	jns    801111 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8010fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801100:	68 5b 2e 80 00       	push   $0x802e5b
  801105:	6a 7b                	push   $0x7b
  801107:	68 df 2d 80 00       	push   $0x802ddf
  80110c:	e8 c7 f0 ff ff       	call   8001d8 <_panic>
        return forkid;
  801111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sfork>:

// Challenge!
int
sfork(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801122:	68 72 2e 80 00       	push   $0x802e72
  801127:	68 83 00 00 00       	push   $0x83
  80112c:	68 df 2d 80 00       	push   $0x802ddf
  801131:	e8 a2 f0 ff ff       	call   8001d8 <_panic>

00801136 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	05 00 00 00 30       	add    $0x30000000,%eax
  801141:	c1 e8 0c             	shr    $0xc,%eax
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801151:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801156:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801163:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801168:	89 c2                	mov    %eax,%edx
  80116a:	c1 ea 16             	shr    $0x16,%edx
  80116d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801174:	f6 c2 01             	test   $0x1,%dl
  801177:	74 11                	je     80118a <fd_alloc+0x2d>
  801179:	89 c2                	mov    %eax,%edx
  80117b:	c1 ea 0c             	shr    $0xc,%edx
  80117e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801185:	f6 c2 01             	test   $0x1,%dl
  801188:	75 09                	jne    801193 <fd_alloc+0x36>
			*fd_store = fd;
  80118a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 17                	jmp    8011aa <fd_alloc+0x4d>
  801193:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801198:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119d:	75 c9                	jne    801168 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b2:	83 f8 1f             	cmp    $0x1f,%eax
  8011b5:	77 36                	ja     8011ed <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b7:	c1 e0 0c             	shl    $0xc,%eax
  8011ba:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	c1 ea 16             	shr    $0x16,%edx
  8011c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	74 24                	je     8011f4 <fd_lookup+0x48>
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	c1 ea 0c             	shr    $0xc,%edx
  8011d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	74 1a                	je     8011fb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e4:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 13                	jmp    801200 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 0c                	jmp    801200 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f9:	eb 05                	jmp    801200 <fd_lookup+0x54>
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120b:	ba 04 2f 80 00       	mov    $0x802f04,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801210:	eb 13                	jmp    801225 <dev_lookup+0x23>
  801212:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801215:	39 08                	cmp    %ecx,(%eax)
  801217:	75 0c                	jne    801225 <dev_lookup+0x23>
			*dev = devtab[i];
  801219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	eb 2e                	jmp    801253 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	85 c0                	test   %eax,%eax
  801229:	75 e7                	jne    801212 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122b:	a1 04 50 80 00       	mov    0x805004,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	51                   	push   %ecx
  801237:	50                   	push   %eax
  801238:	68 88 2e 80 00       	push   $0x802e88
  80123d:	e8 6f f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801242:	8b 45 0c             	mov    0xc(%ebp),%eax
  801245:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 10             	sub    $0x10,%esp
  80125d:	8b 75 08             	mov    0x8(%ebp),%esi
  801260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801267:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801270:	50                   	push   %eax
  801271:	e8 36 ff ff ff       	call   8011ac <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 05                	js     801282 <fd_close+0x2d>
	    || fd != fd2)
  80127d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801280:	74 0c                	je     80128e <fd_close+0x39>
		return (must_exist ? r : 0);
  801282:	84 db                	test   %bl,%bl
  801284:	ba 00 00 00 00       	mov    $0x0,%edx
  801289:	0f 44 c2             	cmove  %edx,%eax
  80128c:	eb 41                	jmp    8012cf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801294:	50                   	push   %eax
  801295:	ff 36                	pushl  (%esi)
  801297:	e8 66 ff ff ff       	call   801202 <dev_lookup>
  80129c:	89 c3                	mov    %eax,%ebx
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 1a                	js     8012bf <fd_close+0x6a>
		if (dev->dev_close)
  8012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ab:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	74 0b                	je     8012bf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b4:	83 ec 0c             	sub    $0xc,%esp
  8012b7:	56                   	push   %esi
  8012b8:	ff d0                	call   *%eax
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	56                   	push   %esi
  8012c3:	6a 00                	push   $0x0
  8012c5:	e8 fc f9 ff ff       	call   800cc6 <sys_page_unmap>
	return r;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	89 d8                	mov    %ebx,%eax
}
  8012cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d2:	5b                   	pop    %ebx
  8012d3:	5e                   	pop    %esi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 c4 fe ff ff       	call   8011ac <fd_lookup>
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	85 d2                	test   %edx,%edx
  8012ef:	78 10                	js     801301 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	6a 01                	push   $0x1
  8012f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f9:	e8 57 ff ff ff       	call   801255 <fd_close>
  8012fe:	83 c4 10             	add    $0x10,%esp
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <close_all>:

void
close_all(void)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	53                   	push   %ebx
  801313:	e8 be ff ff ff       	call   8012d6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801318:	83 c3 01             	add    $0x1,%ebx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	83 fb 20             	cmp    $0x20,%ebx
  801321:	75 ec                	jne    80130f <close_all+0xc>
		close(i);
}
  801323:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	57                   	push   %edi
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
  80132e:	83 ec 2c             	sub    $0x2c,%esp
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801334:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 75 08             	pushl  0x8(%ebp)
  80133b:	e8 6c fe ff ff       	call   8011ac <fd_lookup>
  801340:	89 c2                	mov    %eax,%edx
  801342:	83 c4 08             	add    $0x8,%esp
  801345:	85 d2                	test   %edx,%edx
  801347:	0f 88 c1 00 00 00    	js     80140e <dup+0xe6>
		return r;
	close(newfdnum);
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	56                   	push   %esi
  801351:	e8 80 ff ff ff       	call   8012d6 <close>

	newfd = INDEX2FD(newfdnum);
  801356:	89 f3                	mov    %esi,%ebx
  801358:	c1 e3 0c             	shl    $0xc,%ebx
  80135b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801361:	83 c4 04             	add    $0x4,%esp
  801364:	ff 75 e4             	pushl  -0x1c(%ebp)
  801367:	e8 da fd ff ff       	call   801146 <fd2data>
  80136c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136e:	89 1c 24             	mov    %ebx,(%esp)
  801371:	e8 d0 fd ff ff       	call   801146 <fd2data>
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137c:	89 f8                	mov    %edi,%eax
  80137e:	c1 e8 16             	shr    $0x16,%eax
  801381:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801388:	a8 01                	test   $0x1,%al
  80138a:	74 37                	je     8013c3 <dup+0x9b>
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	c1 e8 0c             	shr    $0xc,%eax
  801391:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801398:	f6 c2 01             	test   $0x1,%dl
  80139b:	74 26                	je     8013c3 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	57                   	push   %edi
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 ca f8 ff ff       	call   800c84 <sys_page_map>
  8013ba:	89 c7                	mov    %eax,%edi
  8013bc:	83 c4 20             	add    $0x20,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 2e                	js     8013f1 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c6:	89 d0                	mov    %edx,%eax
  8013c8:	c1 e8 0c             	shr    $0xc,%eax
  8013cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013da:	50                   	push   %eax
  8013db:	53                   	push   %ebx
  8013dc:	6a 00                	push   $0x0
  8013de:	52                   	push   %edx
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 9e f8 ff ff       	call   800c84 <sys_page_map>
  8013e6:	89 c7                	mov    %eax,%edi
  8013e8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013eb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ed:	85 ff                	test   %edi,%edi
  8013ef:	79 1d                	jns    80140e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 ca f8 ff ff       	call   800cc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801402:	6a 00                	push   $0x0
  801404:	e8 bd f8 ff ff       	call   800cc6 <sys_page_unmap>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 f8                	mov    %edi,%eax
}
  80140e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5f                   	pop    %edi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 14             	sub    $0x14,%esp
  80141d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801420:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	53                   	push   %ebx
  801425:	e8 82 fd ff ff       	call   8011ac <fd_lookup>
  80142a:	83 c4 08             	add    $0x8,%esp
  80142d:	89 c2                	mov    %eax,%edx
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 6d                	js     8014a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	ff 30                	pushl  (%eax)
  80143f:	e8 be fd ff ff       	call   801202 <dev_lookup>
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	78 4c                	js     801497 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144e:	8b 42 08             	mov    0x8(%edx),%eax
  801451:	83 e0 03             	and    $0x3,%eax
  801454:	83 f8 01             	cmp    $0x1,%eax
  801457:	75 21                	jne    80147a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801459:	a1 04 50 80 00       	mov    0x805004,%eax
  80145e:	8b 40 48             	mov    0x48(%eax),%eax
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	53                   	push   %ebx
  801465:	50                   	push   %eax
  801466:	68 c9 2e 80 00       	push   $0x802ec9
  80146b:	e8 41 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801478:	eb 26                	jmp    8014a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147d:	8b 40 08             	mov    0x8(%eax),%eax
  801480:	85 c0                	test   %eax,%eax
  801482:	74 17                	je     80149b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	ff 75 10             	pushl  0x10(%ebp)
  80148a:	ff 75 0c             	pushl  0xc(%ebp)
  80148d:	52                   	push   %edx
  80148e:	ff d0                	call   *%eax
  801490:	89 c2                	mov    %eax,%edx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb 09                	jmp    8014a0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	89 c2                	mov    %eax,%edx
  801499:	eb 05                	jmp    8014a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014a0:	89 d0                	mov    %edx,%eax
  8014a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	57                   	push   %edi
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bb:	eb 21                	jmp    8014de <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bd:	83 ec 04             	sub    $0x4,%esp
  8014c0:	89 f0                	mov    %esi,%eax
  8014c2:	29 d8                	sub    %ebx,%eax
  8014c4:	50                   	push   %eax
  8014c5:	89 d8                	mov    %ebx,%eax
  8014c7:	03 45 0c             	add    0xc(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	57                   	push   %edi
  8014cc:	e8 45 ff ff ff       	call   801416 <read>
		if (m < 0)
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 0c                	js     8014e4 <readn+0x3d>
			return m;
		if (m == 0)
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	74 06                	je     8014e2 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dc:	01 c3                	add    %eax,%ebx
  8014de:	39 f3                	cmp    %esi,%ebx
  8014e0:	72 db                	jb     8014bd <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014e2:	89 d8                	mov    %ebx,%eax
}
  8014e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e7:	5b                   	pop    %ebx
  8014e8:	5e                   	pop    %esi
  8014e9:	5f                   	pop    %edi
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    

008014ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 14             	sub    $0x14,%esp
  8014f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	53                   	push   %ebx
  8014fb:	e8 ac fc ff ff       	call   8011ac <fd_lookup>
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	89 c2                	mov    %eax,%edx
  801505:	85 c0                	test   %eax,%eax
  801507:	78 68                	js     801571 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801513:	ff 30                	pushl  (%eax)
  801515:	e8 e8 fc ff ff       	call   801202 <dev_lookup>
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 47                	js     801568 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801528:	75 21                	jne    80154b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152a:	a1 04 50 80 00       	mov    0x805004,%eax
  80152f:	8b 40 48             	mov    0x48(%eax),%eax
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	53                   	push   %ebx
  801536:	50                   	push   %eax
  801537:	68 e5 2e 80 00       	push   $0x802ee5
  80153c:	e8 70 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801549:	eb 26                	jmp    801571 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154e:	8b 52 0c             	mov    0xc(%edx),%edx
  801551:	85 d2                	test   %edx,%edx
  801553:	74 17                	je     80156c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	ff 75 10             	pushl  0x10(%ebp)
  80155b:	ff 75 0c             	pushl  0xc(%ebp)
  80155e:	50                   	push   %eax
  80155f:	ff d2                	call   *%edx
  801561:	89 c2                	mov    %eax,%edx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	eb 09                	jmp    801571 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	89 c2                	mov    %eax,%edx
  80156a:	eb 05                	jmp    801571 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801571:	89 d0                	mov    %edx,%eax
  801573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <seek>:

int
seek(int fdnum, off_t offset)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	ff 75 08             	pushl  0x8(%ebp)
  801585:	e8 22 fc ff ff       	call   8011ac <fd_lookup>
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 0e                	js     80159f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801591:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
  801597:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 14             	sub    $0x14,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	53                   	push   %ebx
  8015b0:	e8 f7 fb ff ff       	call   8011ac <fd_lookup>
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 65                	js     801623 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	ff 30                	pushl  (%eax)
  8015ca:	e8 33 fc ff ff       	call   801202 <dev_lookup>
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 44                	js     80161a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015dd:	75 21                	jne    801600 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015df:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e4:	8b 40 48             	mov    0x48(%eax),%eax
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	53                   	push   %ebx
  8015eb:	50                   	push   %eax
  8015ec:	68 a8 2e 80 00       	push   $0x802ea8
  8015f1:	e8 bb ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fe:	eb 23                	jmp    801623 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801600:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801603:	8b 52 18             	mov    0x18(%edx),%edx
  801606:	85 d2                	test   %edx,%edx
  801608:	74 14                	je     80161e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	50                   	push   %eax
  801611:	ff d2                	call   *%edx
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	53                   	push   %ebx
  80162e:	83 ec 14             	sub    $0x14,%esp
  801631:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801634:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	ff 75 08             	pushl  0x8(%ebp)
  80163b:	e8 6c fb ff ff       	call   8011ac <fd_lookup>
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	89 c2                	mov    %eax,%edx
  801645:	85 c0                	test   %eax,%eax
  801647:	78 58                	js     8016a1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801653:	ff 30                	pushl  (%eax)
  801655:	e8 a8 fb ff ff       	call   801202 <dev_lookup>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 37                	js     801698 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801668:	74 32                	je     80169c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801674:	00 00 00 
	stat->st_isdir = 0;
  801677:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167e:	00 00 00 
	stat->st_dev = dev;
  801681:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	53                   	push   %ebx
  80168b:	ff 75 f0             	pushl  -0x10(%ebp)
  80168e:	ff 50 14             	call   *0x14(%eax)
  801691:	89 c2                	mov    %eax,%edx
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	eb 09                	jmp    8016a1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801698:	89 c2                	mov    %eax,%edx
  80169a:	eb 05                	jmp    8016a1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a1:	89 d0                	mov    %edx,%eax
  8016a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	6a 00                	push   $0x0
  8016b2:	ff 75 08             	pushl  0x8(%ebp)
  8016b5:	e8 09 02 00 00       	call   8018c3 <open>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 db                	test   %ebx,%ebx
  8016c1:	78 1b                	js     8016de <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	ff 75 0c             	pushl  0xc(%ebp)
  8016c9:	53                   	push   %ebx
  8016ca:	e8 5b ff ff ff       	call   80162a <fstat>
  8016cf:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d1:	89 1c 24             	mov    %ebx,(%esp)
  8016d4:	e8 fd fb ff ff       	call   8012d6 <close>
	return r;
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	89 f0                	mov    %esi,%eax
}
  8016de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	56                   	push   %esi
  8016e9:	53                   	push   %ebx
  8016ea:	89 c6                	mov    %eax,%esi
  8016ec:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ee:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8016f5:	75 12                	jne    801709 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	6a 01                	push   $0x1
  8016fc:	e8 a1 0e 00 00       	call   8025a2 <ipc_find_env>
  801701:	a3 00 50 80 00       	mov    %eax,0x805000
  801706:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801709:	6a 07                	push   $0x7
  80170b:	68 00 60 80 00       	push   $0x806000
  801710:	56                   	push   %esi
  801711:	ff 35 00 50 80 00    	pushl  0x805000
  801717:	e8 32 0e 00 00       	call   80254e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171c:	83 c4 0c             	add    $0xc,%esp
  80171f:	6a 00                	push   $0x0
  801721:	53                   	push   %ebx
  801722:	6a 00                	push   $0x0
  801724:	e8 bc 0d 00 00       	call   8024e5 <ipc_recv>
}
  801729:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	8b 40 0c             	mov    0xc(%eax),%eax
  80173c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801741:	8b 45 0c             	mov    0xc(%ebp),%eax
  801744:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 02 00 00 00       	mov    $0x2,%eax
  801753:	e8 8d ff ff ff       	call   8016e5 <fsipc>
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80176b:	ba 00 00 00 00       	mov    $0x0,%edx
  801770:	b8 06 00 00 00       	mov    $0x6,%eax
  801775:	e8 6b ff ff ff       	call   8016e5 <fsipc>
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	b8 05 00 00 00       	mov    $0x5,%eax
  80179b:	e8 45 ff ff ff       	call   8016e5 <fsipc>
  8017a0:	89 c2                	mov    %eax,%edx
  8017a2:	85 d2                	test   %edx,%edx
  8017a4:	78 2c                	js     8017d2 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	68 00 60 80 00       	push   $0x806000
  8017ae:	53                   	push   %ebx
  8017af:	e8 84 f0 ff ff       	call   800838 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b4:	a1 80 60 80 00       	mov    0x806080,%eax
  8017b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017bf:	a1 84 60 80 00       	mov    0x806084,%eax
  8017c4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	57                   	push   %edi
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e9:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8017ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017f1:	eb 3d                	jmp    801830 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8017f3:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8017f9:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8017fe:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801801:	83 ec 04             	sub    $0x4,%esp
  801804:	57                   	push   %edi
  801805:	53                   	push   %ebx
  801806:	68 08 60 80 00       	push   $0x806008
  80180b:	e8 ba f1 ff ff       	call   8009ca <memmove>
                fsipcbuf.write.req_n = tmp; 
  801810:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 04 00 00 00       	mov    $0x4,%eax
  801820:	e8 c0 fe ff ff       	call   8016e5 <fsipc>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 0d                	js     801839 <devfile_write+0x62>
		        return r;
                n -= tmp;
  80182c:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80182e:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801830:	85 f6                	test   %esi,%esi
  801832:	75 bf                	jne    8017f3 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801834:	89 d8                	mov    %ebx,%eax
  801836:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801839:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80183c:	5b                   	pop    %ebx
  80183d:	5e                   	pop    %esi
  80183e:	5f                   	pop    %edi
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	56                   	push   %esi
  801845:	53                   	push   %ebx
  801846:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	8b 40 0c             	mov    0xc(%eax),%eax
  80184f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801854:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185a:	ba 00 00 00 00       	mov    $0x0,%edx
  80185f:	b8 03 00 00 00       	mov    $0x3,%eax
  801864:	e8 7c fe ff ff       	call   8016e5 <fsipc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 4b                	js     8018ba <devfile_read+0x79>
		return r;
	assert(r <= n);
  80186f:	39 c6                	cmp    %eax,%esi
  801871:	73 16                	jae    801889 <devfile_read+0x48>
  801873:	68 14 2f 80 00       	push   $0x802f14
  801878:	68 1b 2f 80 00       	push   $0x802f1b
  80187d:	6a 7c                	push   $0x7c
  80187f:	68 30 2f 80 00       	push   $0x802f30
  801884:	e8 4f e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801889:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80188e:	7e 16                	jle    8018a6 <devfile_read+0x65>
  801890:	68 3b 2f 80 00       	push   $0x802f3b
  801895:	68 1b 2f 80 00       	push   $0x802f1b
  80189a:	6a 7d                	push   $0x7d
  80189c:	68 30 2f 80 00       	push   $0x802f30
  8018a1:	e8 32 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a6:	83 ec 04             	sub    $0x4,%esp
  8018a9:	50                   	push   %eax
  8018aa:	68 00 60 80 00       	push   $0x806000
  8018af:	ff 75 0c             	pushl  0xc(%ebp)
  8018b2:	e8 13 f1 ff ff       	call   8009ca <memmove>
	return r;
  8018b7:	83 c4 10             	add    $0x10,%esp
}
  8018ba:	89 d8                	mov    %ebx,%eax
  8018bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bf:	5b                   	pop    %ebx
  8018c0:	5e                   	pop    %esi
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    

008018c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 20             	sub    $0x20,%esp
  8018ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018cd:	53                   	push   %ebx
  8018ce:	e8 2c ef ff ff       	call   8007ff <strlen>
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018db:	7f 67                	jg     801944 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e3:	50                   	push   %eax
  8018e4:	e8 74 f8 ff ff       	call   80115d <fd_alloc>
  8018e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 57                	js     801949 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	53                   	push   %ebx
  8018f6:	68 00 60 80 00       	push   $0x806000
  8018fb:	e8 38 ef ff ff       	call   800838 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801900:	8b 45 0c             	mov    0xc(%ebp),%eax
  801903:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801908:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190b:	b8 01 00 00 00       	mov    $0x1,%eax
  801910:	e8 d0 fd ff ff       	call   8016e5 <fsipc>
  801915:	89 c3                	mov    %eax,%ebx
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	79 14                	jns    801932 <open+0x6f>
		fd_close(fd, 0);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	6a 00                	push   $0x0
  801923:	ff 75 f4             	pushl  -0xc(%ebp)
  801926:	e8 2a f9 ff ff       	call   801255 <fd_close>
		return r;
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	89 da                	mov    %ebx,%edx
  801930:	eb 17                	jmp    801949 <open+0x86>
	}

	return fd2num(fd);
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	ff 75 f4             	pushl  -0xc(%ebp)
  801938:	e8 f9 f7 ff ff       	call   801136 <fd2num>
  80193d:	89 c2                	mov    %eax,%edx
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	eb 05                	jmp    801949 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801944:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801949:	89 d0                	mov    %edx,%eax
  80194b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801956:	ba 00 00 00 00       	mov    $0x0,%edx
  80195b:	b8 08 00 00 00       	mov    $0x8,%eax
  801960:	e8 80 fd ff ff       	call   8016e5 <fsipc>
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	57                   	push   %edi
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801973:	6a 00                	push   $0x0
  801975:	ff 75 08             	pushl  0x8(%ebp)
  801978:	e8 46 ff ff ff       	call   8018c3 <open>
  80197d:	89 c7                	mov    %eax,%edi
  80197f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	0f 88 97 04 00 00    	js     801e27 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801990:	83 ec 04             	sub    $0x4,%esp
  801993:	68 00 02 00 00       	push   $0x200
  801998:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80199e:	50                   	push   %eax
  80199f:	57                   	push   %edi
  8019a0:	e8 02 fb ff ff       	call   8014a7 <readn>
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019ad:	75 0c                	jne    8019bb <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019af:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019b6:	45 4c 46 
  8019b9:	74 33                	je     8019ee <spawn+0x87>
		close(fd);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c4:	e8 0d f9 ff ff       	call   8012d6 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019c9:	83 c4 0c             	add    $0xc,%esp
  8019cc:	68 7f 45 4c 46       	push   $0x464c457f
  8019d1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019d7:	68 47 2f 80 00       	push   $0x802f47
  8019dc:	e8 d0 e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  8019e9:	e9 be 04 00 00       	jmp    801eac <spawn+0x545>
  8019ee:	b8 07 00 00 00       	mov    $0x7,%eax
  8019f3:	cd 30                	int    $0x30
  8019f5:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019fb:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	0f 88 26 04 00 00    	js     801e2f <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a09:	89 c6                	mov    %eax,%esi
  801a0b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a11:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a14:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a1a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a20:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a27:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a2d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a33:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a38:	be 00 00 00 00       	mov    $0x0,%esi
  801a3d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a40:	eb 13                	jmp    801a55 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	50                   	push   %eax
  801a46:	e8 b4 ed ff ff       	call   8007ff <strlen>
  801a4b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a4f:	83 c3 01             	add    $0x1,%ebx
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a5c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	75 df                	jne    801a42 <spawn+0xdb>
  801a63:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a69:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a6f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a74:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a76:	89 fa                	mov    %edi,%edx
  801a78:	83 e2 fc             	and    $0xfffffffc,%edx
  801a7b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a82:	29 c2                	sub    %eax,%edx
  801a84:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a8a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a8d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a92:	0f 86 a7 03 00 00    	jbe    801e3f <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	6a 07                	push   $0x7
  801a9d:	68 00 00 40 00       	push   $0x400000
  801aa2:	6a 00                	push   $0x0
  801aa4:	e8 98 f1 ff ff       	call   800c41 <sys_page_alloc>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	0f 88 f8 03 00 00    	js     801eac <spawn+0x545>
  801ab4:	be 00 00 00 00       	mov    $0x0,%esi
  801ab9:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ac2:	eb 30                	jmp    801af4 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ac4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801aca:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ad0:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ad3:	83 ec 08             	sub    $0x8,%esp
  801ad6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ad9:	57                   	push   %edi
  801ada:	e8 59 ed ff ff       	call   800838 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801adf:	83 c4 04             	add    $0x4,%esp
  801ae2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ae5:	e8 15 ed ff ff       	call   8007ff <strlen>
  801aea:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aee:	83 c6 01             	add    $0x1,%esi
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801afa:	7f c8                	jg     801ac4 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801afc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b02:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b08:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b0f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b15:	74 19                	je     801b30 <spawn+0x1c9>
  801b17:	68 d4 2f 80 00       	push   $0x802fd4
  801b1c:	68 1b 2f 80 00       	push   $0x802f1b
  801b21:	68 f1 00 00 00       	push   $0xf1
  801b26:	68 61 2f 80 00       	push   $0x802f61
  801b2b:	e8 a8 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b30:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b36:	89 f8                	mov    %edi,%eax
  801b38:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b3d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b40:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b46:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b49:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b4f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	6a 07                	push   $0x7
  801b5a:	68 00 d0 bf ee       	push   $0xeebfd000
  801b5f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b65:	68 00 00 40 00       	push   $0x400000
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 13 f1 ff ff       	call   800c84 <sys_page_map>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	83 c4 20             	add    $0x20,%esp
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 1a 03 00 00    	js     801e98 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b7e:	83 ec 08             	sub    $0x8,%esp
  801b81:	68 00 00 40 00       	push   $0x400000
  801b86:	6a 00                	push   $0x0
  801b88:	e8 39 f1 ff ff       	call   800cc6 <sys_page_unmap>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	0f 88 fe 02 00 00    	js     801e98 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b9a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ba0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ba7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bad:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bb4:	00 00 00 
  801bb7:	e9 85 01 00 00       	jmp    801d41 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801bbc:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bc2:	83 38 01             	cmpl   $0x1,(%eax)
  801bc5:	0f 85 68 01 00 00    	jne    801d33 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bcb:	89 c7                	mov    %eax,%edi
  801bcd:	8b 40 18             	mov    0x18(%eax),%eax
  801bd0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bd6:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bd9:	83 f8 01             	cmp    $0x1,%eax
  801bdc:	19 c0                	sbb    %eax,%eax
  801bde:	83 e0 fe             	and    $0xfffffffe,%eax
  801be1:	83 c0 07             	add    $0x7,%eax
  801be4:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bea:	89 f8                	mov    %edi,%eax
  801bec:	8b 7f 04             	mov    0x4(%edi),%edi
  801bef:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bf5:	8b 78 10             	mov    0x10(%eax),%edi
  801bf8:	8b 48 14             	mov    0x14(%eax),%ecx
  801bfb:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801c01:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c04:	89 f0                	mov    %esi,%eax
  801c06:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c0b:	74 10                	je     801c1d <spawn+0x2b6>
		va -= i;
  801c0d:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c0f:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801c15:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c17:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c22:	e9 fa 00 00 00       	jmp    801d21 <spawn+0x3ba>
		if (i >= filesz) {
  801c27:	39 fb                	cmp    %edi,%ebx
  801c29:	72 27                	jb     801c52 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c2b:	83 ec 04             	sub    $0x4,%esp
  801c2e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c34:	56                   	push   %esi
  801c35:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c3b:	e8 01 f0 ff ff       	call   800c41 <sys_page_alloc>
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	0f 89 ca 00 00 00    	jns    801d15 <spawn+0x3ae>
  801c4b:	89 c7                	mov    %eax,%edi
  801c4d:	e9 fe 01 00 00       	jmp    801e50 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c52:	83 ec 04             	sub    $0x4,%esp
  801c55:	6a 07                	push   $0x7
  801c57:	68 00 00 40 00       	push   $0x400000
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 de ef ff ff       	call   800c41 <sys_page_alloc>
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	0f 88 d8 01 00 00    	js     801e46 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c77:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c84:	e8 ef f8 ff ff       	call   801578 <seek>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	0f 88 b6 01 00 00    	js     801e4a <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c94:	83 ec 04             	sub    $0x4,%esp
  801c97:	89 fa                	mov    %edi,%edx
  801c99:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801c9f:	89 d0                	mov    %edx,%eax
  801ca1:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801ca7:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801cac:	0f 47 c1             	cmova  %ecx,%eax
  801caf:	50                   	push   %eax
  801cb0:	68 00 00 40 00       	push   $0x400000
  801cb5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cbb:	e8 e7 f7 ff ff       	call   8014a7 <readn>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 83 01 00 00    	js     801e4e <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cd4:	56                   	push   %esi
  801cd5:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cdb:	68 00 00 40 00       	push   $0x400000
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 9d ef ff ff       	call   800c84 <sys_page_map>
  801ce7:	83 c4 20             	add    $0x20,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	79 15                	jns    801d03 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801cee:	50                   	push   %eax
  801cef:	68 6d 2f 80 00       	push   $0x802f6d
  801cf4:	68 24 01 00 00       	push   $0x124
  801cf9:	68 61 2f 80 00       	push   $0x802f61
  801cfe:	e8 d5 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801d03:	83 ec 08             	sub    $0x8,%esp
  801d06:	68 00 00 40 00       	push   $0x400000
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 b4 ef ff ff       	call   800cc6 <sys_page_unmap>
  801d12:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d15:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d1b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d21:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d27:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d2d:	0f 82 f4 fe ff ff    	jb     801c27 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d33:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d3a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d41:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d48:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d4e:	0f 8c 68 fe ff ff    	jl     801bbc <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d5d:	e8 74 f5 ff ff       	call   8012d6 <close>
  801d62:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d6a:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	c1 e8 16             	shr    $0x16,%eax
  801d75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d7c:	a8 01                	test   $0x1,%al
  801d7e:	74 53                	je     801dd3 <spawn+0x46c>
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	c1 e8 0c             	shr    $0xc,%eax
  801d85:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d8c:	f6 c2 01             	test   $0x1,%dl
  801d8f:	74 42                	je     801dd3 <spawn+0x46c>
  801d91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d98:	f6 c6 04             	test   $0x4,%dh
  801d9b:	74 36                	je     801dd3 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801d9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	25 07 0e 00 00       	and    $0xe07,%eax
  801dac:	50                   	push   %eax
  801dad:	53                   	push   %ebx
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
  801db0:	6a 00                	push   $0x0
  801db2:	e8 cd ee ff ff       	call   800c84 <sys_page_map>
                        if (r < 0) return r;
  801db7:	83 c4 20             	add    $0x20,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	79 15                	jns    801dd3 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801dbe:	50                   	push   %eax
  801dbf:	68 8a 2f 80 00       	push   $0x802f8a
  801dc4:	68 82 00 00 00       	push   $0x82
  801dc9:	68 61 2f 80 00       	push   $0x802f61
  801dce:	e8 05 e4 ff ff       	call   8001d8 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801dd3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dd9:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801ddf:	75 8f                	jne    801d70 <spawn+0x409>
  801de1:	e9 8d 00 00 00       	jmp    801e73 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801de6:	50                   	push   %eax
  801de7:	68 a0 2f 80 00       	push   $0x802fa0
  801dec:	68 85 00 00 00       	push   $0x85
  801df1:	68 61 2f 80 00       	push   $0x802f61
  801df6:	e8 dd e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dfb:	83 ec 08             	sub    $0x8,%esp
  801dfe:	6a 02                	push   $0x2
  801e00:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e06:	e8 fd ee ff ff       	call   800d08 <sys_env_set_status>
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	79 25                	jns    801e37 <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801e12:	50                   	push   %eax
  801e13:	68 ba 2f 80 00       	push   $0x802fba
  801e18:	68 88 00 00 00       	push   $0x88
  801e1d:	68 61 2f 80 00       	push   $0x802f61
  801e22:	e8 b1 e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e27:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e2d:	eb 7d                	jmp    801eac <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e2f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e35:	eb 75                	jmp    801eac <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e37:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e3d:	eb 6d                	jmp    801eac <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e3f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801e44:	eb 66                	jmp    801eac <spawn+0x545>
  801e46:	89 c7                	mov    %eax,%edi
  801e48:	eb 06                	jmp    801e50 <spawn+0x4e9>
  801e4a:	89 c7                	mov    %eax,%edi
  801e4c:	eb 02                	jmp    801e50 <spawn+0x4e9>
  801e4e:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e59:	e8 64 ed ff ff       	call   800bc2 <sys_env_destroy>
	close(fd);
  801e5e:	83 c4 04             	add    $0x4,%esp
  801e61:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e67:	e8 6a f4 ff ff       	call   8012d6 <close>
	return r;
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	89 f8                	mov    %edi,%eax
  801e71:	eb 39                	jmp    801eac <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801e73:	83 ec 08             	sub    $0x8,%esp
  801e76:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e83:	e8 c2 ee ff ff       	call   800d4a <sys_env_set_trapframe>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	0f 89 68 ff ff ff    	jns    801dfb <spawn+0x494>
  801e93:	e9 4e ff ff ff       	jmp    801de6 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	68 00 00 40 00       	push   $0x400000
  801ea0:	6a 00                	push   $0x0
  801ea2:	e8 1f ee ff ff       	call   800cc6 <sys_page_unmap>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eb9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec1:	eb 03                	jmp    801ec6 <spawnl+0x12>
		argc++;
  801ec3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec6:	83 c2 04             	add    $0x4,%edx
  801ec9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ecd:	75 f4                	jne    801ec3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ecf:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ed6:	83 e2 f0             	and    $0xfffffff0,%edx
  801ed9:	29 d4                	sub    %edx,%esp
  801edb:	8d 54 24 03          	lea    0x3(%esp),%edx
  801edf:	c1 ea 02             	shr    $0x2,%edx
  801ee2:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ee9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eee:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ef5:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801efc:	00 
  801efd:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
  801f04:	eb 0a                	jmp    801f10 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f06:	83 c0 01             	add    $0x1,%eax
  801f09:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f0d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f10:	39 d0                	cmp    %edx,%eax
  801f12:	75 f2                	jne    801f06 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f14:	83 ec 08             	sub    $0x8,%esp
  801f17:	56                   	push   %esi
  801f18:	ff 75 08             	pushl  0x8(%ebp)
  801f1b:	e8 47 fa ff ff       	call   801967 <spawn>
}
  801f20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	56                   	push   %esi
  801f2b:	53                   	push   %ebx
  801f2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	ff 75 08             	pushl  0x8(%ebp)
  801f35:	e8 0c f2 ff ff       	call   801146 <fd2data>
  801f3a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f3c:	83 c4 08             	add    $0x8,%esp
  801f3f:	68 fa 2f 80 00       	push   $0x802ffa
  801f44:	53                   	push   %ebx
  801f45:	e8 ee e8 ff ff       	call   800838 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f4a:	8b 56 04             	mov    0x4(%esi),%edx
  801f4d:	89 d0                	mov    %edx,%eax
  801f4f:	2b 06                	sub    (%esi),%eax
  801f51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f57:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f5e:	00 00 00 
	stat->st_dev = &devpipe;
  801f61:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  801f68:	40 80 00 
	return 0;
}
  801f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f81:	53                   	push   %ebx
  801f82:	6a 00                	push   $0x0
  801f84:	e8 3d ed ff ff       	call   800cc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f89:	89 1c 24             	mov    %ebx,(%esp)
  801f8c:	e8 b5 f1 ff ff       	call   801146 <fd2data>
  801f91:	83 c4 08             	add    $0x8,%esp
  801f94:	50                   	push   %eax
  801f95:	6a 00                	push   $0x0
  801f97:	e8 2a ed ff ff       	call   800cc6 <sys_page_unmap>
}
  801f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	57                   	push   %edi
  801fa5:	56                   	push   %esi
  801fa6:	53                   	push   %ebx
  801fa7:	83 ec 1c             	sub    $0x1c,%esp
  801faa:	89 c6                	mov    %eax,%esi
  801fac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801faf:	a1 04 50 80 00       	mov    0x805004,%eax
  801fb4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	56                   	push   %esi
  801fbb:	e8 1a 06 00 00       	call   8025da <pageref>
  801fc0:	89 c7                	mov    %eax,%edi
  801fc2:	83 c4 04             	add    $0x4,%esp
  801fc5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fc8:	e8 0d 06 00 00       	call   8025da <pageref>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	39 c7                	cmp    %eax,%edi
  801fd2:	0f 94 c2             	sete   %dl
  801fd5:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801fd8:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  801fde:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801fe1:	39 fb                	cmp    %edi,%ebx
  801fe3:	74 19                	je     801ffe <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801fe5:	84 d2                	test   %dl,%dl
  801fe7:	74 c6                	je     801faf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fe9:	8b 51 58             	mov    0x58(%ecx),%edx
  801fec:	50                   	push   %eax
  801fed:	52                   	push   %edx
  801fee:	53                   	push   %ebx
  801fef:	68 01 30 80 00       	push   $0x803001
  801ff4:	e8 b8 e2 ff ff       	call   8002b1 <cprintf>
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	eb b1                	jmp    801faf <_pipeisclosed+0xe>
	}
}
  801ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5f                   	pop    %edi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    

00802006 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	83 ec 28             	sub    $0x28,%esp
  80200f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802012:	56                   	push   %esi
  802013:	e8 2e f1 ff ff       	call   801146 <fd2data>
  802018:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	bf 00 00 00 00       	mov    $0x0,%edi
  802022:	eb 4b                	jmp    80206f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802024:	89 da                	mov    %ebx,%edx
  802026:	89 f0                	mov    %esi,%eax
  802028:	e8 74 ff ff ff       	call   801fa1 <_pipeisclosed>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	75 48                	jne    802079 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802031:	e8 ec eb ff ff       	call   800c22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802036:	8b 43 04             	mov    0x4(%ebx),%eax
  802039:	8b 0b                	mov    (%ebx),%ecx
  80203b:	8d 51 20             	lea    0x20(%ecx),%edx
  80203e:	39 d0                	cmp    %edx,%eax
  802040:	73 e2                	jae    802024 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802045:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802049:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80204c:	89 c2                	mov    %eax,%edx
  80204e:	c1 fa 1f             	sar    $0x1f,%edx
  802051:	89 d1                	mov    %edx,%ecx
  802053:	c1 e9 1b             	shr    $0x1b,%ecx
  802056:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802059:	83 e2 1f             	and    $0x1f,%edx
  80205c:	29 ca                	sub    %ecx,%edx
  80205e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802062:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802066:	83 c0 01             	add    $0x1,%eax
  802069:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206c:	83 c7 01             	add    $0x1,%edi
  80206f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802072:	75 c2                	jne    802036 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802074:	8b 45 10             	mov    0x10(%ebp),%eax
  802077:	eb 05                	jmp    80207e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802079:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80207e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802081:	5b                   	pop    %ebx
  802082:	5e                   	pop    %esi
  802083:	5f                   	pop    %edi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	57                   	push   %edi
  80208a:	56                   	push   %esi
  80208b:	53                   	push   %ebx
  80208c:	83 ec 18             	sub    $0x18,%esp
  80208f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802092:	57                   	push   %edi
  802093:	e8 ae f0 ff ff       	call   801146 <fd2data>
  802098:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a2:	eb 3d                	jmp    8020e1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020a4:	85 db                	test   %ebx,%ebx
  8020a6:	74 04                	je     8020ac <devpipe_read+0x26>
				return i;
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	eb 44                	jmp    8020f0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020ac:	89 f2                	mov    %esi,%edx
  8020ae:	89 f8                	mov    %edi,%eax
  8020b0:	e8 ec fe ff ff       	call   801fa1 <_pipeisclosed>
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	75 32                	jne    8020eb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020b9:	e8 64 eb ff ff       	call   800c22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020be:	8b 06                	mov    (%esi),%eax
  8020c0:	3b 46 04             	cmp    0x4(%esi),%eax
  8020c3:	74 df                	je     8020a4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020c5:	99                   	cltd   
  8020c6:	c1 ea 1b             	shr    $0x1b,%edx
  8020c9:	01 d0                	add    %edx,%eax
  8020cb:	83 e0 1f             	and    $0x1f,%eax
  8020ce:	29 d0                	sub    %edx,%eax
  8020d0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020db:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020de:	83 c3 01             	add    $0x1,%ebx
  8020e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020e4:	75 d8                	jne    8020be <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e9:	eb 05                	jmp    8020f0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	56                   	push   %esi
  8020fc:	53                   	push   %ebx
  8020fd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802103:	50                   	push   %eax
  802104:	e8 54 f0 ff ff       	call   80115d <fd_alloc>
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	89 c2                	mov    %eax,%edx
  80210e:	85 c0                	test   %eax,%eax
  802110:	0f 88 2c 01 00 00    	js     802242 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802116:	83 ec 04             	sub    $0x4,%esp
  802119:	68 07 04 00 00       	push   $0x407
  80211e:	ff 75 f4             	pushl  -0xc(%ebp)
  802121:	6a 00                	push   $0x0
  802123:	e8 19 eb ff ff       	call   800c41 <sys_page_alloc>
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	89 c2                	mov    %eax,%edx
  80212d:	85 c0                	test   %eax,%eax
  80212f:	0f 88 0d 01 00 00    	js     802242 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802135:	83 ec 0c             	sub    $0xc,%esp
  802138:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80213b:	50                   	push   %eax
  80213c:	e8 1c f0 ff ff       	call   80115d <fd_alloc>
  802141:	89 c3                	mov    %eax,%ebx
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	85 c0                	test   %eax,%eax
  802148:	0f 88 e2 00 00 00    	js     802230 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214e:	83 ec 04             	sub    $0x4,%esp
  802151:	68 07 04 00 00       	push   $0x407
  802156:	ff 75 f0             	pushl  -0x10(%ebp)
  802159:	6a 00                	push   $0x0
  80215b:	e8 e1 ea ff ff       	call   800c41 <sys_page_alloc>
  802160:	89 c3                	mov    %eax,%ebx
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	0f 88 c3 00 00 00    	js     802230 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80216d:	83 ec 0c             	sub    $0xc,%esp
  802170:	ff 75 f4             	pushl  -0xc(%ebp)
  802173:	e8 ce ef ff ff       	call   801146 <fd2data>
  802178:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80217a:	83 c4 0c             	add    $0xc,%esp
  80217d:	68 07 04 00 00       	push   $0x407
  802182:	50                   	push   %eax
  802183:	6a 00                	push   $0x0
  802185:	e8 b7 ea ff ff       	call   800c41 <sys_page_alloc>
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	85 c0                	test   %eax,%eax
  802191:	0f 88 89 00 00 00    	js     802220 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802197:	83 ec 0c             	sub    $0xc,%esp
  80219a:	ff 75 f0             	pushl  -0x10(%ebp)
  80219d:	e8 a4 ef ff ff       	call   801146 <fd2data>
  8021a2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021a9:	50                   	push   %eax
  8021aa:	6a 00                	push   $0x0
  8021ac:	56                   	push   %esi
  8021ad:	6a 00                	push   $0x0
  8021af:	e8 d0 ea ff ff       	call   800c84 <sys_page_map>
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	83 c4 20             	add    $0x20,%esp
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	78 55                	js     802212 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021bd:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8021c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021d2:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8021d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021e7:	83 ec 0c             	sub    $0xc,%esp
  8021ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ed:	e8 44 ef ff ff       	call   801136 <fd2num>
  8021f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021f7:	83 c4 04             	add    $0x4,%esp
  8021fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8021fd:	e8 34 ef ff ff       	call   801136 <fd2num>
  802202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802205:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	ba 00 00 00 00       	mov    $0x0,%edx
  802210:	eb 30                	jmp    802242 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802212:	83 ec 08             	sub    $0x8,%esp
  802215:	56                   	push   %esi
  802216:	6a 00                	push   $0x0
  802218:	e8 a9 ea ff ff       	call   800cc6 <sys_page_unmap>
  80221d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802220:	83 ec 08             	sub    $0x8,%esp
  802223:	ff 75 f0             	pushl  -0x10(%ebp)
  802226:	6a 00                	push   $0x0
  802228:	e8 99 ea ff ff       	call   800cc6 <sys_page_unmap>
  80222d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802230:	83 ec 08             	sub    $0x8,%esp
  802233:	ff 75 f4             	pushl  -0xc(%ebp)
  802236:	6a 00                	push   $0x0
  802238:	e8 89 ea ff ff       	call   800cc6 <sys_page_unmap>
  80223d:	83 c4 10             	add    $0x10,%esp
  802240:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802242:	89 d0                	mov    %edx,%eax
  802244:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802251:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802254:	50                   	push   %eax
  802255:	ff 75 08             	pushl  0x8(%ebp)
  802258:	e8 4f ef ff ff       	call   8011ac <fd_lookup>
  80225d:	89 c2                	mov    %eax,%edx
  80225f:	83 c4 10             	add    $0x10,%esp
  802262:	85 d2                	test   %edx,%edx
  802264:	78 18                	js     80227e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802266:	83 ec 0c             	sub    $0xc,%esp
  802269:	ff 75 f4             	pushl  -0xc(%ebp)
  80226c:	e8 d5 ee ff ff       	call   801146 <fd2data>
	return _pipeisclosed(fd, p);
  802271:	89 c2                	mov    %eax,%edx
  802273:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802276:	e8 26 fd ff ff       	call   801fa1 <_pipeisclosed>
  80227b:	83 c4 10             	add    $0x10,%esp
}
  80227e:	c9                   	leave  
  80227f:	c3                   	ret    

00802280 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802288:	85 f6                	test   %esi,%esi
  80228a:	75 16                	jne    8022a2 <wait+0x22>
  80228c:	68 19 30 80 00       	push   $0x803019
  802291:	68 1b 2f 80 00       	push   $0x802f1b
  802296:	6a 09                	push   $0x9
  802298:	68 24 30 80 00       	push   $0x803024
  80229d:	e8 36 df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8022a2:	89 f3                	mov    %esi,%ebx
  8022a4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022aa:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022ad:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022b3:	eb 05                	jmp    8022ba <wait+0x3a>
		sys_yield();
  8022b5:	e8 68 e9 ff ff       	call   800c22 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022ba:	8b 43 48             	mov    0x48(%ebx),%eax
  8022bd:	39 f0                	cmp    %esi,%eax
  8022bf:	75 07                	jne    8022c8 <wait+0x48>
  8022c1:	8b 43 54             	mov    0x54(%ebx),%eax
  8022c4:	85 c0                	test   %eax,%eax
  8022c6:	75 ed                	jne    8022b5 <wait+0x35>
		sys_yield();
}
  8022c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022cb:	5b                   	pop    %ebx
  8022cc:	5e                   	pop    %esi
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    

008022cf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022df:	68 2f 30 80 00       	push   $0x80302f
  8022e4:	ff 75 0c             	pushl  0xc(%ebp)
  8022e7:	e8 4c e5 ff ff       	call   800838 <strcpy>
	return 0;
}
  8022ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	57                   	push   %edi
  8022f7:	56                   	push   %esi
  8022f8:	53                   	push   %ebx
  8022f9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802304:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230a:	eb 2d                	jmp    802339 <devcons_write+0x46>
		m = n - tot;
  80230c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80230f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802311:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802314:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802319:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80231c:	83 ec 04             	sub    $0x4,%esp
  80231f:	53                   	push   %ebx
  802320:	03 45 0c             	add    0xc(%ebp),%eax
  802323:	50                   	push   %eax
  802324:	57                   	push   %edi
  802325:	e8 a0 e6 ff ff       	call   8009ca <memmove>
		sys_cputs(buf, m);
  80232a:	83 c4 08             	add    $0x8,%esp
  80232d:	53                   	push   %ebx
  80232e:	57                   	push   %edi
  80232f:	e8 51 e8 ff ff       	call   800b85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802334:	01 de                	add    %ebx,%esi
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	89 f0                	mov    %esi,%eax
  80233b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80233e:	72 cc                	jb     80230c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    

00802348 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80234e:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802353:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802357:	75 07                	jne    802360 <devcons_read+0x18>
  802359:	eb 28                	jmp    802383 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80235b:	e8 c2 e8 ff ff       	call   800c22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802360:	e8 3e e8 ff ff       	call   800ba3 <sys_cgetc>
  802365:	85 c0                	test   %eax,%eax
  802367:	74 f2                	je     80235b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802369:	85 c0                	test   %eax,%eax
  80236b:	78 16                	js     802383 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80236d:	83 f8 04             	cmp    $0x4,%eax
  802370:	74 0c                	je     80237e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802372:	8b 55 0c             	mov    0xc(%ebp),%edx
  802375:	88 02                	mov    %al,(%edx)
	return 1;
  802377:	b8 01 00 00 00       	mov    $0x1,%eax
  80237c:	eb 05                	jmp    802383 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80237e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802383:	c9                   	leave  
  802384:	c3                   	ret    

00802385 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
  80238e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802391:	6a 01                	push   $0x1
  802393:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802396:	50                   	push   %eax
  802397:	e8 e9 e7 ff ff       	call   800b85 <sys_cputs>
  80239c:	83 c4 10             	add    $0x10,%esp
}
  80239f:	c9                   	leave  
  8023a0:	c3                   	ret    

008023a1 <getchar>:

int
getchar(void)
{
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023a7:	6a 01                	push   $0x1
  8023a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ac:	50                   	push   %eax
  8023ad:	6a 00                	push   $0x0
  8023af:	e8 62 f0 ff ff       	call   801416 <read>
	if (r < 0)
  8023b4:	83 c4 10             	add    $0x10,%esp
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 0f                	js     8023ca <getchar+0x29>
		return r;
	if (r < 1)
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	7e 06                	jle    8023c5 <getchar+0x24>
		return -E_EOF;
	return c;
  8023bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023c3:	eb 05                	jmp    8023ca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ca:	c9                   	leave  
  8023cb:	c3                   	ret    

008023cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d5:	50                   	push   %eax
  8023d6:	ff 75 08             	pushl  0x8(%ebp)
  8023d9:	e8 ce ed ff ff       	call   8011ac <fd_lookup>
  8023de:	83 c4 10             	add    $0x10,%esp
  8023e1:	85 c0                	test   %eax,%eax
  8023e3:	78 11                	js     8023f6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e8:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8023ee:	39 10                	cmp    %edx,(%eax)
  8023f0:	0f 94 c0             	sete   %al
  8023f3:	0f b6 c0             	movzbl %al,%eax
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <opencons>:

int
opencons(void)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802401:	50                   	push   %eax
  802402:	e8 56 ed ff ff       	call   80115d <fd_alloc>
  802407:	83 c4 10             	add    $0x10,%esp
		return r;
  80240a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80240c:	85 c0                	test   %eax,%eax
  80240e:	78 3e                	js     80244e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802410:	83 ec 04             	sub    $0x4,%esp
  802413:	68 07 04 00 00       	push   $0x407
  802418:	ff 75 f4             	pushl  -0xc(%ebp)
  80241b:	6a 00                	push   $0x0
  80241d:	e8 1f e8 ff ff       	call   800c41 <sys_page_alloc>
  802422:	83 c4 10             	add    $0x10,%esp
		return r;
  802425:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802427:	85 c0                	test   %eax,%eax
  802429:	78 23                	js     80244e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80242b:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802434:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802439:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802440:	83 ec 0c             	sub    $0xc,%esp
  802443:	50                   	push   %eax
  802444:	e8 ed ec ff ff       	call   801136 <fd2num>
  802449:	89 c2                	mov    %eax,%edx
  80244b:	83 c4 10             	add    $0x10,%esp
}
  80244e:	89 d0                	mov    %edx,%eax
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802458:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80245f:	75 2c                	jne    80248d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802461:	83 ec 04             	sub    $0x4,%esp
  802464:	6a 07                	push   $0x7
  802466:	68 00 f0 bf ee       	push   $0xeebff000
  80246b:	6a 00                	push   $0x0
  80246d:	e8 cf e7 ff ff       	call   800c41 <sys_page_alloc>
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	85 c0                	test   %eax,%eax
  802477:	74 14                	je     80248d <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802479:	83 ec 04             	sub    $0x4,%esp
  80247c:	68 3c 30 80 00       	push   $0x80303c
  802481:	6a 21                	push   $0x21
  802483:	68 a0 30 80 00       	push   $0x8030a0
  802488:	e8 4b dd ff ff       	call   8001d8 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80248d:	8b 45 08             	mov    0x8(%ebp),%eax
  802490:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802495:	83 ec 08             	sub    $0x8,%esp
  802498:	68 c1 24 80 00       	push   $0x8024c1
  80249d:	6a 00                	push   $0x0
  80249f:	e8 e8 e8 ff ff       	call   800d8c <sys_env_set_pgfault_upcall>
  8024a4:	83 c4 10             	add    $0x10,%esp
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	79 14                	jns    8024bf <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8024ab:	83 ec 04             	sub    $0x4,%esp
  8024ae:	68 68 30 80 00       	push   $0x803068
  8024b3:	6a 29                	push   $0x29
  8024b5:	68 a0 30 80 00       	push   $0x8030a0
  8024ba:	e8 19 dd ff ff       	call   8001d8 <_panic>
}
  8024bf:	c9                   	leave  
  8024c0:	c3                   	ret    

008024c1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024c1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024c2:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024c7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024c9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8024cc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8024d1:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8024d5:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8024d9:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8024db:	83 c4 08             	add    $0x8,%esp
        popal
  8024de:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8024df:	83 c4 04             	add    $0x4,%esp
        popfl
  8024e2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8024e3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8024e4:	c3                   	ret    

008024e5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
  8024e8:	56                   	push   %esi
  8024e9:	53                   	push   %ebx
  8024ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024fa:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8024fd:	83 ec 0c             	sub    $0xc,%esp
  802500:	50                   	push   %eax
  802501:	e8 eb e8 ff ff       	call   800df1 <sys_ipc_recv>
  802506:	83 c4 10             	add    $0x10,%esp
  802509:	85 c0                	test   %eax,%eax
  80250b:	79 16                	jns    802523 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80250d:	85 f6                	test   %esi,%esi
  80250f:	74 06                	je     802517 <ipc_recv+0x32>
  802511:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802517:	85 db                	test   %ebx,%ebx
  802519:	74 2c                	je     802547 <ipc_recv+0x62>
  80251b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802521:	eb 24                	jmp    802547 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802523:	85 f6                	test   %esi,%esi
  802525:	74 0a                	je     802531 <ipc_recv+0x4c>
  802527:	a1 04 50 80 00       	mov    0x805004,%eax
  80252c:	8b 40 74             	mov    0x74(%eax),%eax
  80252f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802531:	85 db                	test   %ebx,%ebx
  802533:	74 0a                	je     80253f <ipc_recv+0x5a>
  802535:	a1 04 50 80 00       	mov    0x805004,%eax
  80253a:	8b 40 78             	mov    0x78(%eax),%eax
  80253d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80253f:	a1 04 50 80 00       	mov    0x805004,%eax
  802544:	8b 40 70             	mov    0x70(%eax),%eax
}
  802547:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80254a:	5b                   	pop    %ebx
  80254b:	5e                   	pop    %esi
  80254c:	5d                   	pop    %ebp
  80254d:	c3                   	ret    

0080254e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80254e:	55                   	push   %ebp
  80254f:	89 e5                	mov    %esp,%ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 0c             	sub    $0xc,%esp
  802557:	8b 7d 08             	mov    0x8(%ebp),%edi
  80255a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80255d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802560:	85 db                	test   %ebx,%ebx
  802562:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802567:	0f 44 d8             	cmove  %eax,%ebx
  80256a:	eb 1c                	jmp    802588 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80256c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80256f:	74 12                	je     802583 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802571:	50                   	push   %eax
  802572:	68 ae 30 80 00       	push   $0x8030ae
  802577:	6a 39                	push   $0x39
  802579:	68 c9 30 80 00       	push   $0x8030c9
  80257e:	e8 55 dc ff ff       	call   8001d8 <_panic>
                 sys_yield();
  802583:	e8 9a e6 ff ff       	call   800c22 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802588:	ff 75 14             	pushl  0x14(%ebp)
  80258b:	53                   	push   %ebx
  80258c:	56                   	push   %esi
  80258d:	57                   	push   %edi
  80258e:	e8 3b e8 ff ff       	call   800dce <sys_ipc_try_send>
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	85 c0                	test   %eax,%eax
  802598:	78 d2                	js     80256c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80259a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    

008025a2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025a2:	55                   	push   %ebp
  8025a3:	89 e5                	mov    %esp,%ebp
  8025a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025a8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025ad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025b0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025b6:	8b 52 50             	mov    0x50(%edx),%edx
  8025b9:	39 ca                	cmp    %ecx,%edx
  8025bb:	75 0d                	jne    8025ca <ipc_find_env+0x28>
			return envs[i].env_id;
  8025bd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025c0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8025c5:	8b 40 08             	mov    0x8(%eax),%eax
  8025c8:	eb 0e                	jmp    8025d8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025ca:	83 c0 01             	add    $0x1,%eax
  8025cd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025d2:	75 d9                	jne    8025ad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025d4:	66 b8 00 00          	mov    $0x0,%ax
}
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    

008025da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025da:	55                   	push   %ebp
  8025db:	89 e5                	mov    %esp,%ebp
  8025dd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025e0:	89 d0                	mov    %edx,%eax
  8025e2:	c1 e8 16             	shr    $0x16,%eax
  8025e5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025ec:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f1:	f6 c1 01             	test   $0x1,%cl
  8025f4:	74 1d                	je     802613 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025f6:	c1 ea 0c             	shr    $0xc,%edx
  8025f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802600:	f6 c2 01             	test   $0x1,%dl
  802603:	74 0e                	je     802613 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802605:	c1 ea 0c             	shr    $0xc,%edx
  802608:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80260f:	ef 
  802610:	0f b7 c0             	movzwl %ax,%eax
}
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	66 90                	xchg   %ax,%ax
  802617:	66 90                	xchg   %ax,%ax
  802619:	66 90                	xchg   %ax,%ax
  80261b:	66 90                	xchg   %ax,%ax
  80261d:	66 90                	xchg   %ax,%ax
  80261f:	90                   	nop

00802620 <__udivdi3>:
  802620:	55                   	push   %ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	83 ec 10             	sub    $0x10,%esp
  802626:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80262a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80262e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802632:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802636:	85 d2                	test   %edx,%edx
  802638:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80263c:	89 34 24             	mov    %esi,(%esp)
  80263f:	89 c8                	mov    %ecx,%eax
  802641:	75 35                	jne    802678 <__udivdi3+0x58>
  802643:	39 f1                	cmp    %esi,%ecx
  802645:	0f 87 bd 00 00 00    	ja     802708 <__udivdi3+0xe8>
  80264b:	85 c9                	test   %ecx,%ecx
  80264d:	89 cd                	mov    %ecx,%ebp
  80264f:	75 0b                	jne    80265c <__udivdi3+0x3c>
  802651:	b8 01 00 00 00       	mov    $0x1,%eax
  802656:	31 d2                	xor    %edx,%edx
  802658:	f7 f1                	div    %ecx
  80265a:	89 c5                	mov    %eax,%ebp
  80265c:	89 f0                	mov    %esi,%eax
  80265e:	31 d2                	xor    %edx,%edx
  802660:	f7 f5                	div    %ebp
  802662:	89 c6                	mov    %eax,%esi
  802664:	89 f8                	mov    %edi,%eax
  802666:	f7 f5                	div    %ebp
  802668:	89 f2                	mov    %esi,%edx
  80266a:	83 c4 10             	add    $0x10,%esp
  80266d:	5e                   	pop    %esi
  80266e:	5f                   	pop    %edi
  80266f:	5d                   	pop    %ebp
  802670:	c3                   	ret    
  802671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802678:	3b 14 24             	cmp    (%esp),%edx
  80267b:	77 7b                	ja     8026f8 <__udivdi3+0xd8>
  80267d:	0f bd f2             	bsr    %edx,%esi
  802680:	83 f6 1f             	xor    $0x1f,%esi
  802683:	0f 84 97 00 00 00    	je     802720 <__udivdi3+0x100>
  802689:	bd 20 00 00 00       	mov    $0x20,%ebp
  80268e:	89 d7                	mov    %edx,%edi
  802690:	89 f1                	mov    %esi,%ecx
  802692:	29 f5                	sub    %esi,%ebp
  802694:	d3 e7                	shl    %cl,%edi
  802696:	89 c2                	mov    %eax,%edx
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	d3 ea                	shr    %cl,%edx
  80269c:	89 f1                	mov    %esi,%ecx
  80269e:	09 fa                	or     %edi,%edx
  8026a0:	8b 3c 24             	mov    (%esp),%edi
  8026a3:	d3 e0                	shl    %cl,%eax
  8026a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026af:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026b3:	89 fa                	mov    %edi,%edx
  8026b5:	d3 ea                	shr    %cl,%edx
  8026b7:	89 f1                	mov    %esi,%ecx
  8026b9:	d3 e7                	shl    %cl,%edi
  8026bb:	89 e9                	mov    %ebp,%ecx
  8026bd:	d3 e8                	shr    %cl,%eax
  8026bf:	09 c7                	or     %eax,%edi
  8026c1:	89 f8                	mov    %edi,%eax
  8026c3:	f7 74 24 08          	divl   0x8(%esp)
  8026c7:	89 d5                	mov    %edx,%ebp
  8026c9:	89 c7                	mov    %eax,%edi
  8026cb:	f7 64 24 0c          	mull   0xc(%esp)
  8026cf:	39 d5                	cmp    %edx,%ebp
  8026d1:	89 14 24             	mov    %edx,(%esp)
  8026d4:	72 11                	jb     8026e7 <__udivdi3+0xc7>
  8026d6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026da:	89 f1                	mov    %esi,%ecx
  8026dc:	d3 e2                	shl    %cl,%edx
  8026de:	39 c2                	cmp    %eax,%edx
  8026e0:	73 5e                	jae    802740 <__udivdi3+0x120>
  8026e2:	3b 2c 24             	cmp    (%esp),%ebp
  8026e5:	75 59                	jne    802740 <__udivdi3+0x120>
  8026e7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8026ea:	31 f6                	xor    %esi,%esi
  8026ec:	89 f2                	mov    %esi,%edx
  8026ee:	83 c4 10             	add    $0x10,%esp
  8026f1:	5e                   	pop    %esi
  8026f2:	5f                   	pop    %edi
  8026f3:	5d                   	pop    %ebp
  8026f4:	c3                   	ret    
  8026f5:	8d 76 00             	lea    0x0(%esi),%esi
  8026f8:	31 f6                	xor    %esi,%esi
  8026fa:	31 c0                	xor    %eax,%eax
  8026fc:	89 f2                	mov    %esi,%edx
  8026fe:	83 c4 10             	add    $0x10,%esp
  802701:	5e                   	pop    %esi
  802702:	5f                   	pop    %edi
  802703:	5d                   	pop    %ebp
  802704:	c3                   	ret    
  802705:	8d 76 00             	lea    0x0(%esi),%esi
  802708:	89 f2                	mov    %esi,%edx
  80270a:	31 f6                	xor    %esi,%esi
  80270c:	89 f8                	mov    %edi,%eax
  80270e:	f7 f1                	div    %ecx
  802710:	89 f2                	mov    %esi,%edx
  802712:	83 c4 10             	add    $0x10,%esp
  802715:	5e                   	pop    %esi
  802716:	5f                   	pop    %edi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802724:	76 0b                	jbe    802731 <__udivdi3+0x111>
  802726:	31 c0                	xor    %eax,%eax
  802728:	3b 14 24             	cmp    (%esp),%edx
  80272b:	0f 83 37 ff ff ff    	jae    802668 <__udivdi3+0x48>
  802731:	b8 01 00 00 00       	mov    $0x1,%eax
  802736:	e9 2d ff ff ff       	jmp    802668 <__udivdi3+0x48>
  80273b:	90                   	nop
  80273c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 f8                	mov    %edi,%eax
  802742:	31 f6                	xor    %esi,%esi
  802744:	e9 1f ff ff ff       	jmp    802668 <__udivdi3+0x48>
  802749:	66 90                	xchg   %ax,%ax
  80274b:	66 90                	xchg   %ax,%ax
  80274d:	66 90                	xchg   %ax,%ax
  80274f:	90                   	nop

00802750 <__umoddi3>:
  802750:	55                   	push   %ebp
  802751:	57                   	push   %edi
  802752:	56                   	push   %esi
  802753:	83 ec 20             	sub    $0x20,%esp
  802756:	8b 44 24 34          	mov    0x34(%esp),%eax
  80275a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80275e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802762:	89 c6                	mov    %eax,%esi
  802764:	89 44 24 10          	mov    %eax,0x10(%esp)
  802768:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80276c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802770:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802774:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802778:	89 74 24 18          	mov    %esi,0x18(%esp)
  80277c:	85 c0                	test   %eax,%eax
  80277e:	89 c2                	mov    %eax,%edx
  802780:	75 1e                	jne    8027a0 <__umoddi3+0x50>
  802782:	39 f7                	cmp    %esi,%edi
  802784:	76 52                	jbe    8027d8 <__umoddi3+0x88>
  802786:	89 c8                	mov    %ecx,%eax
  802788:	89 f2                	mov    %esi,%edx
  80278a:	f7 f7                	div    %edi
  80278c:	89 d0                	mov    %edx,%eax
  80278e:	31 d2                	xor    %edx,%edx
  802790:	83 c4 20             	add    $0x20,%esp
  802793:	5e                   	pop    %esi
  802794:	5f                   	pop    %edi
  802795:	5d                   	pop    %ebp
  802796:	c3                   	ret    
  802797:	89 f6                	mov    %esi,%esi
  802799:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8027a0:	39 f0                	cmp    %esi,%eax
  8027a2:	77 5c                	ja     802800 <__umoddi3+0xb0>
  8027a4:	0f bd e8             	bsr    %eax,%ebp
  8027a7:	83 f5 1f             	xor    $0x1f,%ebp
  8027aa:	75 64                	jne    802810 <__umoddi3+0xc0>
  8027ac:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8027b0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8027b4:	0f 86 f6 00 00 00    	jbe    8028b0 <__umoddi3+0x160>
  8027ba:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8027be:	0f 82 ec 00 00 00    	jb     8028b0 <__umoddi3+0x160>
  8027c4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027c8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8027cc:	83 c4 20             	add    $0x20,%esp
  8027cf:	5e                   	pop    %esi
  8027d0:	5f                   	pop    %edi
  8027d1:	5d                   	pop    %ebp
  8027d2:	c3                   	ret    
  8027d3:	90                   	nop
  8027d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	85 ff                	test   %edi,%edi
  8027da:	89 fd                	mov    %edi,%ebp
  8027dc:	75 0b                	jne    8027e9 <__umoddi3+0x99>
  8027de:	b8 01 00 00 00       	mov    $0x1,%eax
  8027e3:	31 d2                	xor    %edx,%edx
  8027e5:	f7 f7                	div    %edi
  8027e7:	89 c5                	mov    %eax,%ebp
  8027e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8027ed:	31 d2                	xor    %edx,%edx
  8027ef:	f7 f5                	div    %ebp
  8027f1:	89 c8                	mov    %ecx,%eax
  8027f3:	f7 f5                	div    %ebp
  8027f5:	eb 95                	jmp    80278c <__umoddi3+0x3c>
  8027f7:	89 f6                	mov    %esi,%esi
  8027f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802800:	89 c8                	mov    %ecx,%eax
  802802:	89 f2                	mov    %esi,%edx
  802804:	83 c4 20             	add    $0x20,%esp
  802807:	5e                   	pop    %esi
  802808:	5f                   	pop    %edi
  802809:	5d                   	pop    %ebp
  80280a:	c3                   	ret    
  80280b:	90                   	nop
  80280c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802810:	b8 20 00 00 00       	mov    $0x20,%eax
  802815:	89 e9                	mov    %ebp,%ecx
  802817:	29 e8                	sub    %ebp,%eax
  802819:	d3 e2                	shl    %cl,%edx
  80281b:	89 c7                	mov    %eax,%edi
  80281d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802821:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802825:	89 f9                	mov    %edi,%ecx
  802827:	d3 e8                	shr    %cl,%eax
  802829:	89 c1                	mov    %eax,%ecx
  80282b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80282f:	09 d1                	or     %edx,%ecx
  802831:	89 fa                	mov    %edi,%edx
  802833:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802837:	89 e9                	mov    %ebp,%ecx
  802839:	d3 e0                	shl    %cl,%eax
  80283b:	89 f9                	mov    %edi,%ecx
  80283d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802841:	89 f0                	mov    %esi,%eax
  802843:	d3 e8                	shr    %cl,%eax
  802845:	89 e9                	mov    %ebp,%ecx
  802847:	89 c7                	mov    %eax,%edi
  802849:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80284d:	d3 e6                	shl    %cl,%esi
  80284f:	89 d1                	mov    %edx,%ecx
  802851:	89 fa                	mov    %edi,%edx
  802853:	d3 e8                	shr    %cl,%eax
  802855:	89 e9                	mov    %ebp,%ecx
  802857:	09 f0                	or     %esi,%eax
  802859:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80285d:	f7 74 24 10          	divl   0x10(%esp)
  802861:	d3 e6                	shl    %cl,%esi
  802863:	89 d1                	mov    %edx,%ecx
  802865:	f7 64 24 0c          	mull   0xc(%esp)
  802869:	39 d1                	cmp    %edx,%ecx
  80286b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80286f:	89 d7                	mov    %edx,%edi
  802871:	89 c6                	mov    %eax,%esi
  802873:	72 0a                	jb     80287f <__umoddi3+0x12f>
  802875:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802879:	73 10                	jae    80288b <__umoddi3+0x13b>
  80287b:	39 d1                	cmp    %edx,%ecx
  80287d:	75 0c                	jne    80288b <__umoddi3+0x13b>
  80287f:	89 d7                	mov    %edx,%edi
  802881:	89 c6                	mov    %eax,%esi
  802883:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802887:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80288b:	89 ca                	mov    %ecx,%edx
  80288d:	89 e9                	mov    %ebp,%ecx
  80288f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802893:	29 f0                	sub    %esi,%eax
  802895:	19 fa                	sbb    %edi,%edx
  802897:	d3 e8                	shr    %cl,%eax
  802899:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80289e:	89 d7                	mov    %edx,%edi
  8028a0:	d3 e7                	shl    %cl,%edi
  8028a2:	89 e9                	mov    %ebp,%ecx
  8028a4:	09 f8                	or     %edi,%eax
  8028a6:	d3 ea                	shr    %cl,%edx
  8028a8:	83 c4 20             	add    $0x20,%esp
  8028ab:	5e                   	pop    %esi
  8028ac:	5f                   	pop    %edi
  8028ad:	5d                   	pop    %ebp
  8028ae:	c3                   	ret    
  8028af:	90                   	nop
  8028b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028b4:	29 f9                	sub    %edi,%ecx
  8028b6:	19 c6                	sbb    %eax,%esi
  8028b8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8028bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028c0:	e9 ff fe ff ff       	jmp    8027c4 <__umoddi3+0x74>
