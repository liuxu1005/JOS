
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
  800081:	68 0c 2e 80 00       	push   $0x802e0c
  800086:	6a 13                	push   $0x13
  800088:	68 1f 2e 80 00       	push   $0x802e1f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 1e 0f 00 00       	call   800fb5 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 1b 33 80 00       	push   $0x80331b
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 1f 2e 80 00       	push   $0x802e1f
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
  8000d2:	e8 c0 26 00 00       	call   802797 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f8 07 00 00       	call   8008e2 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 06 2e 80 00       	mov    $0x802e06,%edx
  8000f4:	b8 00 2e 80 00       	mov    $0x802e00,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 33 2e 80 00       	push   $0x802e33
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 4e 2e 80 00       	push   $0x802e4e
  80010e:	68 53 2e 80 00       	push   $0x802e53
  800113:	68 52 2e 80 00       	push   $0x802e52
  800118:	e8 3d 1e 00 00       	call   801f5a <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 60 2e 80 00       	push   $0x802e60
  80012a:	6a 21                	push   $0x21
  80012c:	68 1f 2e 80 00       	push   $0x802e1f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 58 26 00 00       	call   802797 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 90 07 00 00       	call   8008e2 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 06 2e 80 00       	mov    $0x802e06,%edx
  80015c:	b8 00 2e 80 00       	mov    $0x802e00,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 6a 2e 80 00       	push   $0x802e6a
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
  800195:	a3 08 50 80 00       	mov    %eax,0x805008

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
  8001c4:	e8 e0 11 00 00       	call   8013a9 <close_all>
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
  8001f6:	68 b0 2e 80 00       	push   $0x802eb0
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 59 33 80 00 	movl   $0x803359,(%esp)
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
  800314:	e8 17 28 00 00       	call   802b30 <__udivdi3>
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
  800352:	e8 09 29 00 00       	call   802c60 <__umoddi3>
  800357:	83 c4 14             	add    $0x14,%esp
  80035a:	0f be 80 d3 2e 80 00 	movsbl 0x802ed3(%eax),%eax
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
  800456:	ff 24 85 40 30 80 00 	jmp    *0x803040(,%eax,4)
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
  80051a:	8b 14 85 c0 31 80 00 	mov    0x8031c0(,%eax,4),%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	75 18                	jne    80053d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800525:	50                   	push   %eax
  800526:	68 eb 2e 80 00       	push   $0x802eeb
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
  80053e:	68 31 34 80 00       	push   $0x803431
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
  80056b:	ba e4 2e 80 00       	mov    $0x802ee4,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800bea:	68 1f 32 80 00       	push   $0x80321f
  800bef:	6a 22                	push   $0x22
  800bf1:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
	// return value.
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
	// return value.
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
  800c6b:	68 1f 32 80 00       	push   $0x80321f
  800c70:	6a 22                	push   $0x22
  800c72:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
  800cad:	68 1f 32 80 00       	push   $0x80321f
  800cb2:	6a 22                	push   $0x22
  800cb4:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
  800cef:	68 1f 32 80 00       	push   $0x80321f
  800cf4:	6a 22                	push   $0x22
  800cf6:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
  800d31:	68 1f 32 80 00       	push   $0x80321f
  800d36:	6a 22                	push   $0x22
  800d38:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
  800d73:	68 1f 32 80 00       	push   $0x80321f
  800d78:	6a 22                	push   $0x22
  800d7a:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
  800db5:	68 1f 32 80 00       	push   $0x80321f
  800dba:	6a 22                	push   $0x22
  800dbc:	68 3c 32 80 00       	push   $0x80323c
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
	// return value.
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
	// return value.
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
  800e19:	68 1f 32 80 00       	push   $0x80321f
  800e1e:	6a 22                	push   $0x22
  800e20:	68 3c 32 80 00       	push   $0x80323c
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

00800e32 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e42:	89 d1                	mov    %edx,%ecx
  800e44:	89 d3                	mov    %edx,%ebx
  800e46:	89 d7                	mov    %edx,%edi
  800e48:	89 d6                	mov    %edx,%esi
  800e4a:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 cb                	mov    %ecx,%ebx
  800e69:	89 cf                	mov    %ecx,%edi
  800e6b:	89 ce                	mov    %ecx,%esi
  800e6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 17                	jle    800e8a <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	50                   	push   %eax
  800e77:	6a 0f                	push   $0xf
  800e79:	68 1f 32 80 00       	push   $0x80321f
  800e7e:	6a 22                	push   $0x22
  800e80:	68 3c 32 80 00       	push   $0x80323c
  800e85:	e8 4e f3 ff ff       	call   8001d8 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_recv>:

int
sys_recv(void *addr)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea0:	b8 10 00 00 00       	mov    $0x10,%eax
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	89 cb                	mov    %ecx,%ebx
  800eaa:	89 cf                	mov    %ecx,%edi
  800eac:	89 ce                	mov    %ecx,%esi
  800eae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7e 17                	jle    800ecb <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	50                   	push   %eax
  800eb8:	6a 10                	push   $0x10
  800eba:	68 1f 32 80 00       	push   $0x80321f
  800ebf:	6a 22                	push   $0x22
  800ec1:	68 3c 32 80 00       	push   $0x80323c
  800ec6:	e8 0d f3 ff ff       	call   8001d8 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	53                   	push   %ebx
  800ed7:	83 ec 04             	sub    $0x4,%esp
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800edd:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800edf:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ee3:	74 2e                	je     800f13 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	c1 ea 16             	shr    $0x16,%edx
  800eea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef1:	f6 c2 01             	test   $0x1,%dl
  800ef4:	74 1d                	je     800f13 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ef6:	89 c2                	mov    %eax,%edx
  800ef8:	c1 ea 0c             	shr    $0xc,%edx
  800efb:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f02:	f6 c1 01             	test   $0x1,%cl
  800f05:	74 0c                	je     800f13 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f0e:	f6 c6 08             	test   $0x8,%dh
  800f11:	75 14                	jne    800f27 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	68 4c 32 80 00       	push   $0x80324c
  800f1b:	6a 21                	push   $0x21
  800f1d:	68 df 32 80 00       	push   $0x8032df
  800f22:	e8 b1 f2 ff ff       	call   8001d8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800f27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2c:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	6a 07                	push   $0x7
  800f33:	68 00 f0 7f 00       	push   $0x7ff000
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 02 fd ff ff       	call   800c41 <sys_page_alloc>
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	79 14                	jns    800f5a <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 ea 32 80 00       	push   $0x8032ea
  800f4e:	6a 2b                	push   $0x2b
  800f50:	68 df 32 80 00       	push   $0x8032df
  800f55:	e8 7e f2 ff ff       	call   8001d8 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 00 10 00 00       	push   $0x1000
  800f62:	53                   	push   %ebx
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	e8 5d fa ff ff       	call   8009ca <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800f6d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f74:	53                   	push   %ebx
  800f75:	6a 00                	push   $0x0
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 01 fd ff ff       	call   800c84 <sys_page_map>
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 14                	jns    800f9e <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 00 33 80 00       	push   $0x803300
  800f92:	6a 2e                	push   $0x2e
  800f94:	68 df 32 80 00       	push   $0x8032df
  800f99:	e8 3a f2 ff ff       	call   8001d8 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 19 fd ff ff       	call   800cc6 <sys_page_unmap>
  800fad:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800fbe:	68 d3 0e 80 00       	push   $0x800ed3
  800fc3:	e8 a1 19 00 00       	call   802969 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcd:	cd 30                	int    $0x30
  800fcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 12                	jns    800feb <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800fd9:	50                   	push   %eax
  800fda:	68 14 33 80 00       	push   $0x803314
  800fdf:	6a 6d                	push   $0x6d
  800fe1:	68 df 32 80 00       	push   $0x8032df
  800fe6:	e8 ed f1 ff ff       	call   8001d8 <_panic>
  800feb:	89 c7                	mov    %eax,%edi
  800fed:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800ff2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ff6:	75 21                	jne    801019 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800ff8:	e8 06 fc ff ff       	call   800c03 <sys_getenvid>
  800ffd:	25 ff 03 00 00       	and    $0x3ff,%eax
  801002:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801005:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80100a:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80100f:	b8 00 00 00 00       	mov    $0x0,%eax
  801014:	e9 9c 01 00 00       	jmp    8011b5 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	c1 e8 16             	shr    $0x16,%eax
  80101e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801025:	a8 01                	test   $0x1,%al
  801027:	0f 84 f3 00 00 00    	je     801120 <fork+0x16b>
  80102d:	89 d8                	mov    %ebx,%eax
  80102f:	c1 e8 0c             	shr    $0xc,%eax
  801032:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801039:	f6 c2 01             	test   $0x1,%dl
  80103c:	0f 84 de 00 00 00    	je     801120 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  801042:	89 c6                	mov    %eax,%esi
  801044:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801047:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104e:	f6 c6 04             	test   $0x4,%dh
  801051:	74 37                	je     80108a <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801053:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	25 07 0e 00 00       	and    $0xe07,%eax
  801062:	50                   	push   %eax
  801063:	56                   	push   %esi
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	6a 00                	push   $0x0
  801068:	e8 17 fc ff ff       	call   800c84 <sys_page_map>
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	0f 89 a8 00 00 00    	jns    801120 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  801078:	50                   	push   %eax
  801079:	68 70 32 80 00       	push   $0x803270
  80107e:	6a 49                	push   $0x49
  801080:	68 df 32 80 00       	push   $0x8032df
  801085:	e8 4e f1 ff ff       	call   8001d8 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  80108a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801091:	f6 c6 08             	test   $0x8,%dh
  801094:	75 0b                	jne    8010a1 <fork+0xec>
  801096:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109d:	a8 02                	test   $0x2,%al
  80109f:	74 57                	je     8010f8 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	68 05 08 00 00       	push   $0x805
  8010a9:	56                   	push   %esi
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 d1 fb ff ff       	call   800c84 <sys_page_map>
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 12                	jns    8010cc <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  8010ba:	50                   	push   %eax
  8010bb:	68 70 32 80 00       	push   $0x803270
  8010c0:	6a 4c                	push   $0x4c
  8010c2:	68 df 32 80 00       	push   $0x8032df
  8010c7:	e8 0c f1 ff ff       	call   8001d8 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	68 05 08 00 00       	push   $0x805
  8010d4:	56                   	push   %esi
  8010d5:	6a 00                	push   $0x0
  8010d7:	56                   	push   %esi
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 a5 fb ff ff       	call   800c84 <sys_page_map>
  8010df:	83 c4 20             	add    $0x20,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	79 3a                	jns    801120 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 94 32 80 00       	push   $0x803294
  8010ec:	6a 4e                	push   $0x4e
  8010ee:	68 df 32 80 00       	push   $0x8032df
  8010f3:	e8 e0 f0 ff ff       	call   8001d8 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	6a 05                	push   $0x5
  8010fd:	56                   	push   %esi
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	6a 00                	push   $0x0
  801102:	e8 7d fb ff ff       	call   800c84 <sys_page_map>
  801107:	83 c4 20             	add    $0x20,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	79 12                	jns    801120 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80110e:	50                   	push   %eax
  80110f:	68 bc 32 80 00       	push   $0x8032bc
  801114:	6a 50                	push   $0x50
  801116:	68 df 32 80 00       	push   $0x8032df
  80111b:	e8 b8 f0 ff ff       	call   8001d8 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801120:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801126:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80112c:	0f 85 e7 fe ff ff    	jne    801019 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	6a 07                	push   $0x7
  801137:	68 00 f0 bf ee       	push   $0xeebff000
  80113c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113f:	e8 fd fa ff ff       	call   800c41 <sys_page_alloc>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	79 14                	jns    80115f <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	68 24 33 80 00       	push   $0x803324
  801153:	6a 76                	push   $0x76
  801155:	68 df 32 80 00       	push   $0x8032df
  80115a:	e8 79 f0 ff ff       	call   8001d8 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	68 d8 29 80 00       	push   $0x8029d8
  801167:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116a:	e8 1d fc ff ff       	call   800d8c <sys_env_set_pgfault_upcall>
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	79 14                	jns    80118a <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801176:	ff 75 e4             	pushl  -0x1c(%ebp)
  801179:	68 3e 33 80 00       	push   $0x80333e
  80117e:	6a 79                	push   $0x79
  801180:	68 df 32 80 00       	push   $0x8032df
  801185:	e8 4e f0 ff ff       	call   8001d8 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	6a 02                	push   $0x2
  80118f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801192:	e8 71 fb ff ff       	call   800d08 <sys_env_set_status>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	79 14                	jns    8011b2 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80119e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a1:	68 5b 33 80 00       	push   $0x80335b
  8011a6:	6a 7b                	push   $0x7b
  8011a8:	68 df 32 80 00       	push   $0x8032df
  8011ad:	e8 26 f0 ff ff       	call   8001d8 <_panic>
        return forkid;
  8011b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sfork>:

// Challenge!
int
sfork(void)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c3:	68 72 33 80 00       	push   $0x803372
  8011c8:	68 83 00 00 00       	push   $0x83
  8011cd:	68 df 32 80 00       	push   $0x8032df
  8011d2:	e8 01 f0 ff ff       	call   8001d8 <_panic>

008011d7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801204:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 16             	shr    $0x16,%edx
  80120e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 11                	je     80122b <fd_alloc+0x2d>
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	c1 ea 0c             	shr    $0xc,%edx
  80121f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801226:	f6 c2 01             	test   $0x1,%dl
  801229:	75 09                	jne    801234 <fd_alloc+0x36>
			*fd_store = fd;
  80122b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 17                	jmp    80124b <fd_alloc+0x4d>
  801234:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801239:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123e:	75 c9                	jne    801209 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801240:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801246:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801253:	83 f8 1f             	cmp    $0x1f,%eax
  801256:	77 36                	ja     80128e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801258:	c1 e0 0c             	shl    $0xc,%eax
  80125b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 16             	shr    $0x16,%edx
  801265:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	74 24                	je     801295 <fd_lookup+0x48>
  801271:	89 c2                	mov    %eax,%edx
  801273:	c1 ea 0c             	shr    $0xc,%edx
  801276:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127d:	f6 c2 01             	test   $0x1,%dl
  801280:	74 1a                	je     80129c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801282:	8b 55 0c             	mov    0xc(%ebp),%edx
  801285:	89 02                	mov    %eax,(%edx)
	return 0;
  801287:	b8 00 00 00 00       	mov    $0x0,%eax
  80128c:	eb 13                	jmp    8012a1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801293:	eb 0c                	jmp    8012a1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129a:	eb 05                	jmp    8012a1 <fd_lookup+0x54>
  80129c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b1:	eb 13                	jmp    8012c6 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8012b3:	39 08                	cmp    %ecx,(%eax)
  8012b5:	75 0c                	jne    8012c3 <dev_lookup+0x20>
			*dev = devtab[i];
  8012b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	eb 36                	jmp    8012f9 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c3:	83 c2 01             	add    $0x1,%edx
  8012c6:	8b 04 95 04 34 80 00 	mov    0x803404(,%edx,4),%eax
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	75 e2                	jne    8012b3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d1:	a1 08 50 80 00       	mov    0x805008,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	51                   	push   %ecx
  8012dd:	50                   	push   %eax
  8012de:	68 88 33 80 00       	push   $0x803388
  8012e3:	e8 c9 ef ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 10             	sub    $0x10,%esp
  801303:	8b 75 08             	mov    0x8(%ebp),%esi
  801306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80130d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801313:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801316:	50                   	push   %eax
  801317:	e8 31 ff ff ff       	call   80124d <fd_lookup>
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 05                	js     801328 <fd_close+0x2d>
	    || fd != fd2)
  801323:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801326:	74 0c                	je     801334 <fd_close+0x39>
		return (must_exist ? r : 0);
  801328:	84 db                	test   %bl,%bl
  80132a:	ba 00 00 00 00       	mov    $0x0,%edx
  80132f:	0f 44 c2             	cmove  %edx,%eax
  801332:	eb 41                	jmp    801375 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 36                	pushl  (%esi)
  80133d:	e8 61 ff ff ff       	call   8012a3 <dev_lookup>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 1a                	js     801365 <fd_close+0x6a>
		if (dev->dev_close)
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801351:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801356:	85 c0                	test   %eax,%eax
  801358:	74 0b                	je     801365 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	56                   	push   %esi
  80135e:	ff d0                	call   *%eax
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	56                   	push   %esi
  801369:	6a 00                	push   $0x0
  80136b:	e8 56 f9 ff ff       	call   800cc6 <sys_page_unmap>
	return r;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 d8                	mov    %ebx,%eax
}
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 bf fe ff ff       	call   80124d <fd_lookup>
  80138e:	89 c2                	mov    %eax,%edx
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	85 d2                	test   %edx,%edx
  801395:	78 10                	js     8013a7 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	6a 01                	push   $0x1
  80139c:	ff 75 f4             	pushl  -0xc(%ebp)
  80139f:	e8 57 ff ff ff       	call   8012fb <fd_close>
  8013a4:	83 c4 10             	add    $0x10,%esp
}
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <close_all>:

void
close_all(void)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	e8 be ff ff ff       	call   80137c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013be:	83 c3 01             	add    $0x1,%ebx
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	83 fb 20             	cmp    $0x20,%ebx
  8013c7:	75 ec                	jne    8013b5 <close_all+0xc>
		close(i);
}
  8013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 2c             	sub    $0x2c,%esp
  8013d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	ff 75 08             	pushl  0x8(%ebp)
  8013e1:	e8 67 fe ff ff       	call   80124d <fd_lookup>
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	0f 88 c1 00 00 00    	js     8014b4 <dup+0xe6>
		return r;
	close(newfdnum);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	56                   	push   %esi
  8013f7:	e8 80 ff ff ff       	call   80137c <close>

	newfd = INDEX2FD(newfdnum);
  8013fc:	89 f3                	mov    %esi,%ebx
  8013fe:	c1 e3 0c             	shl    $0xc,%ebx
  801401:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801407:	83 c4 04             	add    $0x4,%esp
  80140a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140d:	e8 d5 fd ff ff       	call   8011e7 <fd2data>
  801412:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801414:	89 1c 24             	mov    %ebx,(%esp)
  801417:	e8 cb fd ff ff       	call   8011e7 <fd2data>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801422:	89 f8                	mov    %edi,%eax
  801424:	c1 e8 16             	shr    $0x16,%eax
  801427:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142e:	a8 01                	test   $0x1,%al
  801430:	74 37                	je     801469 <dup+0x9b>
  801432:	89 f8                	mov    %edi,%eax
  801434:	c1 e8 0c             	shr    $0xc,%eax
  801437:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143e:	f6 c2 01             	test   $0x1,%dl
  801441:	74 26                	je     801469 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801443:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	25 07 0e 00 00       	and    $0xe07,%eax
  801452:	50                   	push   %eax
  801453:	ff 75 d4             	pushl  -0x2c(%ebp)
  801456:	6a 00                	push   $0x0
  801458:	57                   	push   %edi
  801459:	6a 00                	push   $0x0
  80145b:	e8 24 f8 ff ff       	call   800c84 <sys_page_map>
  801460:	89 c7                	mov    %eax,%edi
  801462:	83 c4 20             	add    $0x20,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 2e                	js     801497 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801469:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80146c:	89 d0                	mov    %edx,%eax
  80146e:	c1 e8 0c             	shr    $0xc,%eax
  801471:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	25 07 0e 00 00       	and    $0xe07,%eax
  801480:	50                   	push   %eax
  801481:	53                   	push   %ebx
  801482:	6a 00                	push   $0x0
  801484:	52                   	push   %edx
  801485:	6a 00                	push   $0x0
  801487:	e8 f8 f7 ff ff       	call   800c84 <sys_page_map>
  80148c:	89 c7                	mov    %eax,%edi
  80148e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801491:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801493:	85 ff                	test   %edi,%edi
  801495:	79 1d                	jns    8014b4 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	53                   	push   %ebx
  80149b:	6a 00                	push   $0x0
  80149d:	e8 24 f8 ff ff       	call   800cc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 17 f8 ff ff       	call   800cc6 <sys_page_unmap>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f8                	mov    %edi,%eax
}
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 14             	sub    $0x14,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	e8 7d fd ff ff       	call   80124d <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 6d                	js     801546 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	ff 30                	pushl  (%eax)
  8014e5:	e8 b9 fd ff ff       	call   8012a3 <dev_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 4c                	js     80153d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f4:	8b 42 08             	mov    0x8(%edx),%eax
  8014f7:	83 e0 03             	and    $0x3,%eax
  8014fa:	83 f8 01             	cmp    $0x1,%eax
  8014fd:	75 21                	jne    801520 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ff:	a1 08 50 80 00       	mov    0x805008,%eax
  801504:	8b 40 48             	mov    0x48(%eax),%eax
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	53                   	push   %ebx
  80150b:	50                   	push   %eax
  80150c:	68 c9 33 80 00       	push   $0x8033c9
  801511:	e8 9b ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151e:	eb 26                	jmp    801546 <read+0x8a>
	}
	if (!dev->dev_read)
  801520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801523:	8b 40 08             	mov    0x8(%eax),%eax
  801526:	85 c0                	test   %eax,%eax
  801528:	74 17                	je     801541 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	ff 75 10             	pushl  0x10(%ebp)
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	52                   	push   %edx
  801534:	ff d0                	call   *%eax
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	8b 7d 08             	mov    0x8(%ebp),%edi
  801559:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801561:	eb 21                	jmp    801584 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	89 f0                	mov    %esi,%eax
  801568:	29 d8                	sub    %ebx,%eax
  80156a:	50                   	push   %eax
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	03 45 0c             	add    0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	57                   	push   %edi
  801572:	e8 45 ff ff ff       	call   8014bc <read>
		if (m < 0)
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 0c                	js     80158a <readn+0x3d>
			return m;
		if (m == 0)
  80157e:	85 c0                	test   %eax,%eax
  801580:	74 06                	je     801588 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801582:	01 c3                	add    %eax,%ebx
  801584:	39 f3                	cmp    %esi,%ebx
  801586:	72 db                	jb     801563 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801588:	89 d8                	mov    %ebx,%eax
}
  80158a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5f                   	pop    %edi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 14             	sub    $0x14,%esp
  801599:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	53                   	push   %ebx
  8015a1:	e8 a7 fc ff ff       	call   80124d <fd_lookup>
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 68                	js     801617 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	ff 30                	pushl  (%eax)
  8015bb:	e8 e3 fc ff ff       	call   8012a3 <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 47                	js     80160e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ce:	75 21                	jne    8015f1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d0:	a1 08 50 80 00       	mov    0x805008,%eax
  8015d5:	8b 40 48             	mov    0x48(%eax),%eax
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	53                   	push   %ebx
  8015dc:	50                   	push   %eax
  8015dd:	68 e5 33 80 00       	push   $0x8033e5
  8015e2:	e8 ca ec ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ef:	eb 26                	jmp    801617 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f7:	85 d2                	test   %edx,%edx
  8015f9:	74 17                	je     801612 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	ff 75 10             	pushl  0x10(%ebp)
  801601:	ff 75 0c             	pushl  0xc(%ebp)
  801604:	50                   	push   %eax
  801605:	ff d2                	call   *%edx
  801607:	89 c2                	mov    %eax,%edx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 09                	jmp    801617 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	89 c2                	mov    %eax,%edx
  801610:	eb 05                	jmp    801617 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801612:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801617:	89 d0                	mov    %edx,%eax
  801619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <seek>:

int
seek(int fdnum, off_t offset)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801624:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 1d fc ff ff       	call   80124d <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 0e                	js     801645 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801637:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	e8 f2 fb ff ff       	call   80124d <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	89 c2                	mov    %eax,%edx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 65                	js     8016c9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	ff 30                	pushl  (%eax)
  801670:	e8 2e fc ff ff       	call   8012a3 <dev_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 44                	js     8016c0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801683:	75 21                	jne    8016a6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801685:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168a:	8b 40 48             	mov    0x48(%eax),%eax
  80168d:	83 ec 04             	sub    $0x4,%esp
  801690:	53                   	push   %ebx
  801691:	50                   	push   %eax
  801692:	68 a8 33 80 00       	push   $0x8033a8
  801697:	e8 15 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a4:	eb 23                	jmp    8016c9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a9:	8b 52 18             	mov    0x18(%edx),%edx
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	74 14                	je     8016c4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	ff 75 0c             	pushl  0xc(%ebp)
  8016b6:	50                   	push   %eax
  8016b7:	ff d2                	call   *%edx
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	eb 09                	jmp    8016c9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	eb 05                	jmp    8016c9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c9:	89 d0                	mov    %edx,%eax
  8016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 14             	sub    $0x14,%esp
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 67 fb ff ff       	call   80124d <fd_lookup>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 58                	js     801747 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	ff 30                	pushl  (%eax)
  8016fb:	e8 a3 fb ff ff       	call   8012a3 <dev_lookup>
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 37                	js     80173e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170e:	74 32                	je     801742 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801710:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801713:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171a:	00 00 00 
	stat->st_isdir = 0;
  80171d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801724:	00 00 00 
	stat->st_dev = dev;
  801727:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	53                   	push   %ebx
  801731:	ff 75 f0             	pushl  -0x10(%ebp)
  801734:	ff 50 14             	call   *0x14(%eax)
  801737:	89 c2                	mov    %eax,%edx
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	eb 09                	jmp    801747 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	89 c2                	mov    %eax,%edx
  801740:	eb 05                	jmp    801747 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801742:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801747:	89 d0                	mov    %edx,%eax
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	6a 00                	push   $0x0
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	e8 09 02 00 00       	call   801969 <open>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 db                	test   %ebx,%ebx
  801767:	78 1b                	js     801784 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	53                   	push   %ebx
  801770:	e8 5b ff ff ff       	call   8016d0 <fstat>
  801775:	89 c6                	mov    %eax,%esi
	close(fd);
  801777:	89 1c 24             	mov    %ebx,(%esp)
  80177a:	e8 fd fb ff ff       	call   80137c <close>
	return r;
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	89 f0                	mov    %esi,%eax
}
  801784:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	89 c6                	mov    %eax,%esi
  801792:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801794:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80179b:	75 12                	jne    8017af <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	6a 01                	push   $0x1
  8017a2:	e8 12 13 00 00       	call   802ab9 <ipc_find_env>
  8017a7:	a3 00 50 80 00       	mov    %eax,0x805000
  8017ac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017af:	6a 07                	push   $0x7
  8017b1:	68 00 60 80 00       	push   $0x806000
  8017b6:	56                   	push   %esi
  8017b7:	ff 35 00 50 80 00    	pushl  0x805000
  8017bd:	e8 a3 12 00 00       	call   802a65 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c2:	83 c4 0c             	add    $0xc,%esp
  8017c5:	6a 00                	push   $0x0
  8017c7:	53                   	push   %ebx
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 2d 12 00 00       	call   8029fc <ipc_recv>
}
  8017cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8017e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ea:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f9:	e8 8d ff ff ff       	call   80178b <fsipc>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 06 00 00 00       	mov    $0x6,%eax
  80181b:	e8 6b ff ff ff       	call   80178b <fsipc>
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801837:	ba 00 00 00 00       	mov    $0x0,%edx
  80183c:	b8 05 00 00 00       	mov    $0x5,%eax
  801841:	e8 45 ff ff ff       	call   80178b <fsipc>
  801846:	89 c2                	mov    %eax,%edx
  801848:	85 d2                	test   %edx,%edx
  80184a:	78 2c                	js     801878 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	68 00 60 80 00       	push   $0x806000
  801854:	53                   	push   %ebx
  801855:	e8 de ef ff ff       	call   800838 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185a:	a1 80 60 80 00       	mov    0x806080,%eax
  80185f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801865:	a1 84 60 80 00       	mov    0x806084,%eax
  80186a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	57                   	push   %edi
  801881:	56                   	push   %esi
  801882:	53                   	push   %ebx
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801894:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801897:	eb 3d                	jmp    8018d6 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801899:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80189f:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8018a4:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	57                   	push   %edi
  8018ab:	53                   	push   %ebx
  8018ac:	68 08 60 80 00       	push   $0x806008
  8018b1:	e8 14 f1 ff ff       	call   8009ca <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018b6:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c6:	e8 c0 fe ff ff       	call   80178b <fsipc>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 0d                	js     8018df <devfile_write+0x62>
		        return r;
                n -= tmp;
  8018d2:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8018d4:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018d6:	85 f6                	test   %esi,%esi
  8018d8:	75 bf                	jne    801899 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8018df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5f                   	pop    %edi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8018fa:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801900:	ba 00 00 00 00       	mov    $0x0,%edx
  801905:	b8 03 00 00 00       	mov    $0x3,%eax
  80190a:	e8 7c fe ff ff       	call   80178b <fsipc>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	85 c0                	test   %eax,%eax
  801913:	78 4b                	js     801960 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801915:	39 c6                	cmp    %eax,%esi
  801917:	73 16                	jae    80192f <devfile_read+0x48>
  801919:	68 18 34 80 00       	push   $0x803418
  80191e:	68 1f 34 80 00       	push   $0x80341f
  801923:	6a 7c                	push   $0x7c
  801925:	68 34 34 80 00       	push   $0x803434
  80192a:	e8 a9 e8 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  80192f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801934:	7e 16                	jle    80194c <devfile_read+0x65>
  801936:	68 3f 34 80 00       	push   $0x80343f
  80193b:	68 1f 34 80 00       	push   $0x80341f
  801940:	6a 7d                	push   $0x7d
  801942:	68 34 34 80 00       	push   $0x803434
  801947:	e8 8c e8 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	50                   	push   %eax
  801950:	68 00 60 80 00       	push   $0x806000
  801955:	ff 75 0c             	pushl  0xc(%ebp)
  801958:	e8 6d f0 ff ff       	call   8009ca <memmove>
	return r;
  80195d:	83 c4 10             	add    $0x10,%esp
}
  801960:	89 d8                	mov    %ebx,%eax
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	53                   	push   %ebx
  80196d:	83 ec 20             	sub    $0x20,%esp
  801970:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801973:	53                   	push   %ebx
  801974:	e8 86 ee ff ff       	call   8007ff <strlen>
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801981:	7f 67                	jg     8019ea <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	e8 6f f8 ff ff       	call   8011fe <fd_alloc>
  80198f:	83 c4 10             	add    $0x10,%esp
		return r;
  801992:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801994:	85 c0                	test   %eax,%eax
  801996:	78 57                	js     8019ef <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	53                   	push   %ebx
  80199c:	68 00 60 80 00       	push   $0x806000
  8019a1:	e8 92 ee ff ff       	call   800838 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a9:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b6:	e8 d0 fd ff ff       	call   80178b <fsipc>
  8019bb:	89 c3                	mov    %eax,%ebx
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	79 14                	jns    8019d8 <open+0x6f>
		fd_close(fd, 0);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	6a 00                	push   $0x0
  8019c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cc:	e8 2a f9 ff ff       	call   8012fb <fd_close>
		return r;
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	89 da                	mov    %ebx,%edx
  8019d6:	eb 17                	jmp    8019ef <open+0x86>
	}

	return fd2num(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 f4 f7 ff ff       	call   8011d7 <fd2num>
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb 05                	jmp    8019ef <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ef:	89 d0                	mov    %edx,%eax
  8019f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801a01:	b8 08 00 00 00       	mov    $0x8,%eax
  801a06:	e8 80 fd ff ff       	call   80178b <fsipc>
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	57                   	push   %edi
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a19:	6a 00                	push   $0x0
  801a1b:	ff 75 08             	pushl  0x8(%ebp)
  801a1e:	e8 46 ff ff ff       	call   801969 <open>
  801a23:	89 c7                	mov    %eax,%edi
  801a25:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	0f 88 97 04 00 00    	js     801ecd <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	68 00 02 00 00       	push   $0x200
  801a3e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	57                   	push   %edi
  801a46:	e8 02 fb ff ff       	call   80154d <readn>
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a53:	75 0c                	jne    801a61 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801a55:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a5c:	45 4c 46 
  801a5f:	74 33                	je     801a94 <spawn+0x87>
		close(fd);
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a6a:	e8 0d f9 ff ff       	call   80137c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a6f:	83 c4 0c             	add    $0xc,%esp
  801a72:	68 7f 45 4c 46       	push   $0x464c457f
  801a77:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a7d:	68 4b 34 80 00       	push   $0x80344b
  801a82:	e8 2a e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801a8f:	e9 be 04 00 00       	jmp    801f52 <spawn+0x545>
  801a94:	b8 07 00 00 00       	mov    $0x7,%eax
  801a99:	cd 30                	int    $0x30
  801a9b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801aa1:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 88 26 04 00 00    	js     801ed5 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801aaf:	89 c6                	mov    %eax,%esi
  801ab1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ab7:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801aba:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801ac0:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ac6:	b9 11 00 00 00       	mov    $0x11,%ecx
  801acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801acd:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ad3:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ad9:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ade:	be 00 00 00 00       	mov    $0x0,%esi
  801ae3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ae6:	eb 13                	jmp    801afb <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	50                   	push   %eax
  801aec:	e8 0e ed ff ff       	call   8007ff <strlen>
  801af1:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801af5:	83 c3 01             	add    $0x1,%ebx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801b02:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801b05:	85 c0                	test   %eax,%eax
  801b07:	75 df                	jne    801ae8 <spawn+0xdb>
  801b09:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801b0f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b15:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b1a:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b1c:	89 fa                	mov    %edi,%edx
  801b1e:	83 e2 fc             	and    $0xfffffffc,%edx
  801b21:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801b28:	29 c2                	sub    %eax,%edx
  801b2a:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b30:	8d 42 f8             	lea    -0x8(%edx),%eax
  801b33:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b38:	0f 86 a7 03 00 00    	jbe    801ee5 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b3e:	83 ec 04             	sub    $0x4,%esp
  801b41:	6a 07                	push   $0x7
  801b43:	68 00 00 40 00       	push   $0x400000
  801b48:	6a 00                	push   $0x0
  801b4a:	e8 f2 f0 ff ff       	call   800c41 <sys_page_alloc>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 88 f8 03 00 00    	js     801f52 <spawn+0x545>
  801b5a:	be 00 00 00 00       	mov    $0x0,%esi
  801b5f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b68:	eb 30                	jmp    801b9a <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b6a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b70:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b76:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b79:	83 ec 08             	sub    $0x8,%esp
  801b7c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b7f:	57                   	push   %edi
  801b80:	e8 b3 ec ff ff       	call   800838 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b85:	83 c4 04             	add    $0x4,%esp
  801b88:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b8b:	e8 6f ec ff ff       	call   8007ff <strlen>
  801b90:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b94:	83 c6 01             	add    $0x1,%esi
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ba0:	7f c8                	jg     801b6a <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ba2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ba8:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801bae:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801bb5:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801bbb:	74 19                	je     801bd6 <spawn+0x1c9>
  801bbd:	68 d8 34 80 00       	push   $0x8034d8
  801bc2:	68 1f 34 80 00       	push   $0x80341f
  801bc7:	68 f1 00 00 00       	push   $0xf1
  801bcc:	68 65 34 80 00       	push   $0x803465
  801bd1:	e8 02 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bd6:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801bdc:	89 f8                	mov    %edi,%eax
  801bde:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801be3:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801be6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bec:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bef:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801bf5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	6a 07                	push   $0x7
  801c00:	68 00 d0 bf ee       	push   $0xeebfd000
  801c05:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c0b:	68 00 00 40 00       	push   $0x400000
  801c10:	6a 00                	push   $0x0
  801c12:	e8 6d f0 ff ff       	call   800c84 <sys_page_map>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	83 c4 20             	add    $0x20,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	0f 88 1a 03 00 00    	js     801f3e <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	68 00 00 40 00       	push   $0x400000
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 93 f0 ff ff       	call   800cc6 <sys_page_unmap>
  801c33:	89 c3                	mov    %eax,%ebx
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 fe 02 00 00    	js     801f3e <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c40:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c46:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801c4d:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c53:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801c5a:	00 00 00 
  801c5d:	e9 85 01 00 00       	jmp    801de7 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801c62:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c68:	83 38 01             	cmpl   $0x1,(%eax)
  801c6b:	0f 85 68 01 00 00    	jne    801dd9 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c71:	89 c7                	mov    %eax,%edi
  801c73:	8b 40 18             	mov    0x18(%eax),%eax
  801c76:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c7c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c7f:	83 f8 01             	cmp    $0x1,%eax
  801c82:	19 c0                	sbb    %eax,%eax
  801c84:	83 e0 fe             	and    $0xfffffffe,%eax
  801c87:	83 c0 07             	add    $0x7,%eax
  801c8a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c90:	89 f8                	mov    %edi,%eax
  801c92:	8b 7f 04             	mov    0x4(%edi),%edi
  801c95:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c9b:	8b 78 10             	mov    0x10(%eax),%edi
  801c9e:	8b 48 14             	mov    0x14(%eax),%ecx
  801ca1:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801ca7:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801caa:	89 f0                	mov    %esi,%eax
  801cac:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cb1:	74 10                	je     801cc3 <spawn+0x2b6>
		va -= i;
  801cb3:	29 c6                	sub    %eax,%esi
		memsz += i;
  801cb5:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801cbb:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801cbd:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc8:	e9 fa 00 00 00       	jmp    801dc7 <spawn+0x3ba>
		if (i >= filesz) {
  801ccd:	39 fb                	cmp    %edi,%ebx
  801ccf:	72 27                	jb     801cf8 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cd1:	83 ec 04             	sub    $0x4,%esp
  801cd4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cda:	56                   	push   %esi
  801cdb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ce1:	e8 5b ef ff ff       	call   800c41 <sys_page_alloc>
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	0f 89 ca 00 00 00    	jns    801dbb <spawn+0x3ae>
  801cf1:	89 c7                	mov    %eax,%edi
  801cf3:	e9 fe 01 00 00       	jmp    801ef6 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	6a 07                	push   $0x7
  801cfd:	68 00 00 40 00       	push   $0x400000
  801d02:	6a 00                	push   $0x0
  801d04:	e8 38 ef ff ff       	call   800c41 <sys_page_alloc>
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	0f 88 d8 01 00 00    	js     801eec <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d14:	83 ec 08             	sub    $0x8,%esp
  801d17:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d1d:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d2a:	e8 ef f8 ff ff       	call   80161e <seek>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	0f 88 b6 01 00 00    	js     801ef0 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d3a:	83 ec 04             	sub    $0x4,%esp
  801d3d:	89 fa                	mov    %edi,%edx
  801d3f:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801d4d:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801d52:	0f 47 c1             	cmova  %ecx,%eax
  801d55:	50                   	push   %eax
  801d56:	68 00 00 40 00       	push   $0x400000
  801d5b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d61:	e8 e7 f7 ff ff       	call   80154d <readn>
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	0f 88 83 01 00 00    	js     801ef4 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d71:	83 ec 0c             	sub    $0xc,%esp
  801d74:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d7a:	56                   	push   %esi
  801d7b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d81:	68 00 00 40 00       	push   $0x400000
  801d86:	6a 00                	push   $0x0
  801d88:	e8 f7 ee ff ff       	call   800c84 <sys_page_map>
  801d8d:	83 c4 20             	add    $0x20,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	79 15                	jns    801da9 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801d94:	50                   	push   %eax
  801d95:	68 71 34 80 00       	push   $0x803471
  801d9a:	68 24 01 00 00       	push   $0x124
  801d9f:	68 65 34 80 00       	push   $0x803465
  801da4:	e8 2f e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801da9:	83 ec 08             	sub    $0x8,%esp
  801dac:	68 00 00 40 00       	push   $0x400000
  801db1:	6a 00                	push   $0x0
  801db3:	e8 0e ef ff ff       	call   800cc6 <sys_page_unmap>
  801db8:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801dbb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dc1:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801dc7:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801dcd:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801dd3:	0f 82 f4 fe ff ff    	jb     801ccd <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801dd9:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801de0:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801de7:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801dee:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801df4:	0f 8c 68 fe ff ff    	jl     801c62 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801dfa:	83 ec 0c             	sub    $0xc,%esp
  801dfd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e03:	e8 74 f5 ff ff       	call   80137c <close>
  801e08:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e10:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801e16:	89 d8                	mov    %ebx,%eax
  801e18:	c1 e8 16             	shr    $0x16,%eax
  801e1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e22:	a8 01                	test   $0x1,%al
  801e24:	74 53                	je     801e79 <spawn+0x46c>
  801e26:	89 d8                	mov    %ebx,%eax
  801e28:	c1 e8 0c             	shr    $0xc,%eax
  801e2b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e32:	f6 c2 01             	test   $0x1,%dl
  801e35:	74 42                	je     801e79 <spawn+0x46c>
  801e37:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e3e:	f6 c6 04             	test   $0x4,%dh
  801e41:	74 36                	je     801e79 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801e43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	25 07 0e 00 00       	and    $0xe07,%eax
  801e52:	50                   	push   %eax
  801e53:	53                   	push   %ebx
  801e54:	56                   	push   %esi
  801e55:	53                   	push   %ebx
  801e56:	6a 00                	push   $0x0
  801e58:	e8 27 ee ff ff       	call   800c84 <sys_page_map>
                        if (r < 0) return r;
  801e5d:	83 c4 20             	add    $0x20,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	79 15                	jns    801e79 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e64:	50                   	push   %eax
  801e65:	68 8e 34 80 00       	push   $0x80348e
  801e6a:	68 82 00 00 00       	push   $0x82
  801e6f:	68 65 34 80 00       	push   $0x803465
  801e74:	e8 5f e3 ff ff       	call   8001d8 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801e79:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e7f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801e85:	75 8f                	jne    801e16 <spawn+0x409>
  801e87:	e9 8d 00 00 00       	jmp    801f19 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801e8c:	50                   	push   %eax
  801e8d:	68 a4 34 80 00       	push   $0x8034a4
  801e92:	68 85 00 00 00       	push   $0x85
  801e97:	68 65 34 80 00       	push   $0x803465
  801e9c:	e8 37 e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ea1:	83 ec 08             	sub    $0x8,%esp
  801ea4:	6a 02                	push   $0x2
  801ea6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eac:	e8 57 ee ff ff       	call   800d08 <sys_env_set_status>
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	79 25                	jns    801edd <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801eb8:	50                   	push   %eax
  801eb9:	68 be 34 80 00       	push   $0x8034be
  801ebe:	68 88 00 00 00       	push   $0x88
  801ec3:	68 65 34 80 00       	push   $0x803465
  801ec8:	e8 0b e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ecd:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ed3:	eb 7d                	jmp    801f52 <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801ed5:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801edb:	eb 75                	jmp    801f52 <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801edd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ee3:	eb 6d                	jmp    801f52 <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ee5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801eea:	eb 66                	jmp    801f52 <spawn+0x545>
  801eec:	89 c7                	mov    %eax,%edi
  801eee:	eb 06                	jmp    801ef6 <spawn+0x4e9>
  801ef0:	89 c7                	mov    %eax,%edi
  801ef2:	eb 02                	jmp    801ef6 <spawn+0x4e9>
  801ef4:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801ef6:	83 ec 0c             	sub    $0xc,%esp
  801ef9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eff:	e8 be ec ff ff       	call   800bc2 <sys_env_destroy>
	close(fd);
  801f04:	83 c4 04             	add    $0x4,%esp
  801f07:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f0d:	e8 6a f4 ff ff       	call   80137c <close>
	return r;
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	89 f8                	mov    %edi,%eax
  801f17:	eb 39                	jmp    801f52 <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801f19:	83 ec 08             	sub    $0x8,%esp
  801f1c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f22:	50                   	push   %eax
  801f23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f29:	e8 1c ee ff ff       	call   800d4a <sys_env_set_trapframe>
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	0f 89 68 ff ff ff    	jns    801ea1 <spawn+0x494>
  801f39:	e9 4e ff ff ff       	jmp    801e8c <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	68 00 00 40 00       	push   $0x400000
  801f46:	6a 00                	push   $0x0
  801f48:	e8 79 ed ff ff       	call   800cc6 <sys_page_unmap>
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f5f:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f67:	eb 03                	jmp    801f6c <spawnl+0x12>
		argc++;
  801f69:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f6c:	83 c2 04             	add    $0x4,%edx
  801f6f:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f73:	75 f4                	jne    801f69 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f75:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f7c:	83 e2 f0             	and    $0xfffffff0,%edx
  801f7f:	29 d4                	sub    %edx,%esp
  801f81:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f85:	c1 ea 02             	shr    $0x2,%edx
  801f88:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f8f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f94:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f9b:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801fa2:	00 
  801fa3:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  801faa:	eb 0a                	jmp    801fb6 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801fac:	83 c0 01             	add    $0x1,%eax
  801faf:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801fb3:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801fb6:	39 d0                	cmp    %edx,%eax
  801fb8:	75 f2                	jne    801fac <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801fba:	83 ec 08             	sub    $0x8,%esp
  801fbd:	56                   	push   %esi
  801fbe:	ff 75 08             	pushl  0x8(%ebp)
  801fc1:	e8 47 fa ff ff       	call   801a0d <spawn>
}
  801fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc9:	5b                   	pop    %ebx
  801fca:	5e                   	pop    %esi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801fd3:	68 fe 34 80 00       	push   $0x8034fe
  801fd8:	ff 75 0c             	pushl  0xc(%ebp)
  801fdb:	e8 58 e8 ff ff       	call   800838 <strcpy>
	return 0;
}
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	53                   	push   %ebx
  801feb:	83 ec 10             	sub    $0x10,%esp
  801fee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ff1:	53                   	push   %ebx
  801ff2:	e8 fa 0a 00 00       	call   802af1 <pageref>
  801ff7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ffa:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801fff:	83 f8 01             	cmp    $0x1,%eax
  802002:	75 10                	jne    802014 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802004:	83 ec 0c             	sub    $0xc,%esp
  802007:	ff 73 0c             	pushl  0xc(%ebx)
  80200a:	e8 ca 02 00 00       	call   8022d9 <nsipc_close>
  80200f:	89 c2                	mov    %eax,%edx
  802011:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802014:	89 d0                	mov    %edx,%eax
  802016:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802019:	c9                   	leave  
  80201a:	c3                   	ret    

0080201b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802021:	6a 00                	push   $0x0
  802023:	ff 75 10             	pushl  0x10(%ebp)
  802026:	ff 75 0c             	pushl  0xc(%ebp)
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	ff 70 0c             	pushl  0xc(%eax)
  80202f:	e8 82 03 00 00       	call   8023b6 <nsipc_send>
}
  802034:	c9                   	leave  
  802035:	c3                   	ret    

00802036 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80203c:	6a 00                	push   $0x0
  80203e:	ff 75 10             	pushl  0x10(%ebp)
  802041:	ff 75 0c             	pushl  0xc(%ebp)
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	ff 70 0c             	pushl  0xc(%eax)
  80204a:	e8 fb 02 00 00       	call   80234a <nsipc_recv>
}
  80204f:	c9                   	leave  
  802050:	c3                   	ret    

00802051 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802057:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80205a:	52                   	push   %edx
  80205b:	50                   	push   %eax
  80205c:	e8 ec f1 ff ff       	call   80124d <fd_lookup>
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	85 c0                	test   %eax,%eax
  802066:	78 17                	js     80207f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  802071:	39 08                	cmp    %ecx,(%eax)
  802073:	75 05                	jne    80207a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802075:	8b 40 0c             	mov    0xc(%eax),%eax
  802078:	eb 05                	jmp    80207f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80207a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80207f:	c9                   	leave  
  802080:	c3                   	ret    

00802081 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	56                   	push   %esi
  802085:	53                   	push   %ebx
  802086:	83 ec 1c             	sub    $0x1c,%esp
  802089:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80208b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208e:	50                   	push   %eax
  80208f:	e8 6a f1 ff ff       	call   8011fe <fd_alloc>
  802094:	89 c3                	mov    %eax,%ebx
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 1b                	js     8020b8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80209d:	83 ec 04             	sub    $0x4,%esp
  8020a0:	68 07 04 00 00       	push   $0x407
  8020a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a8:	6a 00                	push   $0x0
  8020aa:	e8 92 eb ff ff       	call   800c41 <sys_page_alloc>
  8020af:	89 c3                	mov    %eax,%ebx
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	79 10                	jns    8020c8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	56                   	push   %esi
  8020bc:	e8 18 02 00 00       	call   8022d9 <nsipc_close>
		return r;
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	eb 24                	jmp    8020ec <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8020c8:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8020ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8020d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d6:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8020dd:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8020e0:	83 ec 0c             	sub    $0xc,%esp
  8020e3:	52                   	push   %edx
  8020e4:	e8 ee f0 ff ff       	call   8011d7 <fd2num>
  8020e9:	83 c4 10             	add    $0x10,%esp
}
  8020ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fc:	e8 50 ff ff ff       	call   802051 <fd2sockid>
		return r;
  802101:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802103:	85 c0                	test   %eax,%eax
  802105:	78 1f                	js     802126 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802107:	83 ec 04             	sub    $0x4,%esp
  80210a:	ff 75 10             	pushl  0x10(%ebp)
  80210d:	ff 75 0c             	pushl  0xc(%ebp)
  802110:	50                   	push   %eax
  802111:	e8 1c 01 00 00       	call   802232 <nsipc_accept>
  802116:	83 c4 10             	add    $0x10,%esp
		return r;
  802119:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80211b:	85 c0                	test   %eax,%eax
  80211d:	78 07                	js     802126 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80211f:	e8 5d ff ff ff       	call   802081 <alloc_sockfd>
  802124:	89 c1                	mov    %eax,%ecx
}
  802126:	89 c8                	mov    %ecx,%eax
  802128:	c9                   	leave  
  802129:	c3                   	ret    

0080212a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802130:	8b 45 08             	mov    0x8(%ebp),%eax
  802133:	e8 19 ff ff ff       	call   802051 <fd2sockid>
  802138:	89 c2                	mov    %eax,%edx
  80213a:	85 d2                	test   %edx,%edx
  80213c:	78 12                	js     802150 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80213e:	83 ec 04             	sub    $0x4,%esp
  802141:	ff 75 10             	pushl  0x10(%ebp)
  802144:	ff 75 0c             	pushl  0xc(%ebp)
  802147:	52                   	push   %edx
  802148:	e8 35 01 00 00       	call   802282 <nsipc_bind>
  80214d:	83 c4 10             	add    $0x10,%esp
}
  802150:	c9                   	leave  
  802151:	c3                   	ret    

00802152 <shutdown>:

int
shutdown(int s, int how)
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
  802155:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802158:	8b 45 08             	mov    0x8(%ebp),%eax
  80215b:	e8 f1 fe ff ff       	call   802051 <fd2sockid>
  802160:	89 c2                	mov    %eax,%edx
  802162:	85 d2                	test   %edx,%edx
  802164:	78 0f                	js     802175 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802166:	83 ec 08             	sub    $0x8,%esp
  802169:	ff 75 0c             	pushl  0xc(%ebp)
  80216c:	52                   	push   %edx
  80216d:	e8 45 01 00 00       	call   8022b7 <nsipc_shutdown>
  802172:	83 c4 10             	add    $0x10,%esp
}
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80217d:	8b 45 08             	mov    0x8(%ebp),%eax
  802180:	e8 cc fe ff ff       	call   802051 <fd2sockid>
  802185:	89 c2                	mov    %eax,%edx
  802187:	85 d2                	test   %edx,%edx
  802189:	78 12                	js     80219d <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  80218b:	83 ec 04             	sub    $0x4,%esp
  80218e:	ff 75 10             	pushl  0x10(%ebp)
  802191:	ff 75 0c             	pushl  0xc(%ebp)
  802194:	52                   	push   %edx
  802195:	e8 59 01 00 00       	call   8022f3 <nsipc_connect>
  80219a:	83 c4 10             	add    $0x10,%esp
}
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    

0080219f <listen>:

int
listen(int s, int backlog)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a8:	e8 a4 fe ff ff       	call   802051 <fd2sockid>
  8021ad:	89 c2                	mov    %eax,%edx
  8021af:	85 d2                	test   %edx,%edx
  8021b1:	78 0f                	js     8021c2 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8021b3:	83 ec 08             	sub    $0x8,%esp
  8021b6:	ff 75 0c             	pushl  0xc(%ebp)
  8021b9:	52                   	push   %edx
  8021ba:	e8 69 01 00 00       	call   802328 <nsipc_listen>
  8021bf:	83 c4 10             	add    $0x10,%esp
}
  8021c2:	c9                   	leave  
  8021c3:	c3                   	ret    

008021c4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8021ca:	ff 75 10             	pushl  0x10(%ebp)
  8021cd:	ff 75 0c             	pushl  0xc(%ebp)
  8021d0:	ff 75 08             	pushl  0x8(%ebp)
  8021d3:	e8 3c 02 00 00       	call   802414 <nsipc_socket>
  8021d8:	89 c2                	mov    %eax,%edx
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	85 d2                	test   %edx,%edx
  8021df:	78 05                	js     8021e6 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8021e1:	e8 9b fe ff ff       	call   802081 <alloc_sockfd>
}
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	53                   	push   %ebx
  8021ec:	83 ec 04             	sub    $0x4,%esp
  8021ef:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021f1:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8021f8:	75 12                	jne    80220c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021fa:	83 ec 0c             	sub    $0xc,%esp
  8021fd:	6a 02                	push   $0x2
  8021ff:	e8 b5 08 00 00       	call   802ab9 <ipc_find_env>
  802204:	a3 04 50 80 00       	mov    %eax,0x805004
  802209:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80220c:	6a 07                	push   $0x7
  80220e:	68 00 70 80 00       	push   $0x807000
  802213:	53                   	push   %ebx
  802214:	ff 35 04 50 80 00    	pushl  0x805004
  80221a:	e8 46 08 00 00       	call   802a65 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80221f:	83 c4 0c             	add    $0xc,%esp
  802222:	6a 00                	push   $0x0
  802224:	6a 00                	push   $0x0
  802226:	6a 00                	push   $0x0
  802228:	e8 cf 07 00 00       	call   8029fc <ipc_recv>
}
  80222d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802230:	c9                   	leave  
  802231:	c3                   	ret    

00802232 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	56                   	push   %esi
  802236:	53                   	push   %ebx
  802237:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80223a:	8b 45 08             	mov    0x8(%ebp),%eax
  80223d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802242:	8b 06                	mov    (%esi),%eax
  802244:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802249:	b8 01 00 00 00       	mov    $0x1,%eax
  80224e:	e8 95 ff ff ff       	call   8021e8 <nsipc>
  802253:	89 c3                	mov    %eax,%ebx
  802255:	85 c0                	test   %eax,%eax
  802257:	78 20                	js     802279 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802259:	83 ec 04             	sub    $0x4,%esp
  80225c:	ff 35 10 70 80 00    	pushl  0x807010
  802262:	68 00 70 80 00       	push   $0x807000
  802267:	ff 75 0c             	pushl  0xc(%ebp)
  80226a:	e8 5b e7 ff ff       	call   8009ca <memmove>
		*addrlen = ret->ret_addrlen;
  80226f:	a1 10 70 80 00       	mov    0x807010,%eax
  802274:	89 06                	mov    %eax,(%esi)
  802276:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802279:	89 d8                	mov    %ebx,%eax
  80227b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    

00802282 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	53                   	push   %ebx
  802286:	83 ec 08             	sub    $0x8,%esp
  802289:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802294:	53                   	push   %ebx
  802295:	ff 75 0c             	pushl  0xc(%ebp)
  802298:	68 04 70 80 00       	push   $0x807004
  80229d:	e8 28 e7 ff ff       	call   8009ca <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022a2:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8022a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8022ad:	e8 36 ff ff ff       	call   8021e8 <nsipc>
}
  8022b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8022c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8022cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8022d2:	e8 11 ff ff ff       	call   8021e8 <nsipc>
}
  8022d7:	c9                   	leave  
  8022d8:	c3                   	ret    

008022d9 <nsipc_close>:

int
nsipc_close(int s)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022df:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8022e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8022ec:	e8 f7 fe ff ff       	call   8021e8 <nsipc>
}
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	53                   	push   %ebx
  8022f7:	83 ec 08             	sub    $0x8,%esp
  8022fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802300:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802305:	53                   	push   %ebx
  802306:	ff 75 0c             	pushl  0xc(%ebp)
  802309:	68 04 70 80 00       	push   $0x807004
  80230e:	e8 b7 e6 ff ff       	call   8009ca <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802313:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802319:	b8 05 00 00 00       	mov    $0x5,%eax
  80231e:	e8 c5 fe ff ff       	call   8021e8 <nsipc>
}
  802323:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802326:	c9                   	leave  
  802327:	c3                   	ret    

00802328 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80232e:	8b 45 08             	mov    0x8(%ebp),%eax
  802331:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802336:	8b 45 0c             	mov    0xc(%ebp),%eax
  802339:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80233e:	b8 06 00 00 00       	mov    $0x6,%eax
  802343:	e8 a0 fe ff ff       	call   8021e8 <nsipc>
}
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	56                   	push   %esi
  80234e:	53                   	push   %ebx
  80234f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802352:	8b 45 08             	mov    0x8(%ebp),%eax
  802355:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80235a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802360:	8b 45 14             	mov    0x14(%ebp),%eax
  802363:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802368:	b8 07 00 00 00       	mov    $0x7,%eax
  80236d:	e8 76 fe ff ff       	call   8021e8 <nsipc>
  802372:	89 c3                	mov    %eax,%ebx
  802374:	85 c0                	test   %eax,%eax
  802376:	78 35                	js     8023ad <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802378:	39 f0                	cmp    %esi,%eax
  80237a:	7f 07                	jg     802383 <nsipc_recv+0x39>
  80237c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802381:	7e 16                	jle    802399 <nsipc_recv+0x4f>
  802383:	68 0a 35 80 00       	push   $0x80350a
  802388:	68 1f 34 80 00       	push   $0x80341f
  80238d:	6a 62                	push   $0x62
  80238f:	68 1f 35 80 00       	push   $0x80351f
  802394:	e8 3f de ff ff       	call   8001d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802399:	83 ec 04             	sub    $0x4,%esp
  80239c:	50                   	push   %eax
  80239d:	68 00 70 80 00       	push   $0x807000
  8023a2:	ff 75 0c             	pushl  0xc(%ebp)
  8023a5:	e8 20 e6 ff ff       	call   8009ca <memmove>
  8023aa:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8023ad:	89 d8                	mov    %ebx,%eax
  8023af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023b2:	5b                   	pop    %ebx
  8023b3:	5e                   	pop    %esi
  8023b4:	5d                   	pop    %ebp
  8023b5:	c3                   	ret    

008023b6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	53                   	push   %ebx
  8023ba:	83 ec 04             	sub    $0x4,%esp
  8023bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8023c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c3:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8023c8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8023ce:	7e 16                	jle    8023e6 <nsipc_send+0x30>
  8023d0:	68 2b 35 80 00       	push   $0x80352b
  8023d5:	68 1f 34 80 00       	push   $0x80341f
  8023da:	6a 6d                	push   $0x6d
  8023dc:	68 1f 35 80 00       	push   $0x80351f
  8023e1:	e8 f2 dd ff ff       	call   8001d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023e6:	83 ec 04             	sub    $0x4,%esp
  8023e9:	53                   	push   %ebx
  8023ea:	ff 75 0c             	pushl  0xc(%ebp)
  8023ed:	68 0c 70 80 00       	push   $0x80700c
  8023f2:	e8 d3 e5 ff ff       	call   8009ca <memmove>
	nsipcbuf.send.req_size = size;
  8023f7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023fd:	8b 45 14             	mov    0x14(%ebp),%eax
  802400:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802405:	b8 08 00 00 00       	mov    $0x8,%eax
  80240a:	e8 d9 fd ff ff       	call   8021e8 <nsipc>
}
  80240f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802412:	c9                   	leave  
  802413:	c3                   	ret    

00802414 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80241a:	8b 45 08             	mov    0x8(%ebp),%eax
  80241d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802422:	8b 45 0c             	mov    0xc(%ebp),%eax
  802425:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80242a:	8b 45 10             	mov    0x10(%ebp),%eax
  80242d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802432:	b8 09 00 00 00       	mov    $0x9,%eax
  802437:	e8 ac fd ff ff       	call   8021e8 <nsipc>
}
  80243c:	c9                   	leave  
  80243d:	c3                   	ret    

0080243e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80243e:	55                   	push   %ebp
  80243f:	89 e5                	mov    %esp,%ebp
  802441:	56                   	push   %esi
  802442:	53                   	push   %ebx
  802443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802446:	83 ec 0c             	sub    $0xc,%esp
  802449:	ff 75 08             	pushl  0x8(%ebp)
  80244c:	e8 96 ed ff ff       	call   8011e7 <fd2data>
  802451:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802453:	83 c4 08             	add    $0x8,%esp
  802456:	68 37 35 80 00       	push   $0x803537
  80245b:	53                   	push   %ebx
  80245c:	e8 d7 e3 ff ff       	call   800838 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802461:	8b 56 04             	mov    0x4(%esi),%edx
  802464:	89 d0                	mov    %edx,%eax
  802466:	2b 06                	sub    (%esi),%eax
  802468:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80246e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802475:	00 00 00 
	stat->st_dev = &devpipe;
  802478:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  80247f:	40 80 00 
	return 0;
}
  802482:	b8 00 00 00 00       	mov    $0x0,%eax
  802487:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80248a:	5b                   	pop    %ebx
  80248b:	5e                   	pop    %esi
  80248c:	5d                   	pop    %ebp
  80248d:	c3                   	ret    

0080248e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80248e:	55                   	push   %ebp
  80248f:	89 e5                	mov    %esp,%ebp
  802491:	53                   	push   %ebx
  802492:	83 ec 0c             	sub    $0xc,%esp
  802495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802498:	53                   	push   %ebx
  802499:	6a 00                	push   $0x0
  80249b:	e8 26 e8 ff ff       	call   800cc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024a0:	89 1c 24             	mov    %ebx,(%esp)
  8024a3:	e8 3f ed ff ff       	call   8011e7 <fd2data>
  8024a8:	83 c4 08             	add    $0x8,%esp
  8024ab:	50                   	push   %eax
  8024ac:	6a 00                	push   $0x0
  8024ae:	e8 13 e8 ff ff       	call   800cc6 <sys_page_unmap>
}
  8024b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024b6:	c9                   	leave  
  8024b7:	c3                   	ret    

008024b8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
  8024bb:	57                   	push   %edi
  8024bc:	56                   	push   %esi
  8024bd:	53                   	push   %ebx
  8024be:	83 ec 1c             	sub    $0x1c,%esp
  8024c1:	89 c6                	mov    %eax,%esi
  8024c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024c6:	a1 08 50 80 00       	mov    0x805008,%eax
  8024cb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8024ce:	83 ec 0c             	sub    $0xc,%esp
  8024d1:	56                   	push   %esi
  8024d2:	e8 1a 06 00 00       	call   802af1 <pageref>
  8024d7:	89 c7                	mov    %eax,%edi
  8024d9:	83 c4 04             	add    $0x4,%esp
  8024dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024df:	e8 0d 06 00 00       	call   802af1 <pageref>
  8024e4:	83 c4 10             	add    $0x10,%esp
  8024e7:	39 c7                	cmp    %eax,%edi
  8024e9:	0f 94 c2             	sete   %dl
  8024ec:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8024ef:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8024f5:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8024f8:	39 fb                	cmp    %edi,%ebx
  8024fa:	74 19                	je     802515 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8024fc:	84 d2                	test   %dl,%dl
  8024fe:	74 c6                	je     8024c6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802500:	8b 51 58             	mov    0x58(%ecx),%edx
  802503:	50                   	push   %eax
  802504:	52                   	push   %edx
  802505:	53                   	push   %ebx
  802506:	68 3e 35 80 00       	push   $0x80353e
  80250b:	e8 a1 dd ff ff       	call   8002b1 <cprintf>
  802510:	83 c4 10             	add    $0x10,%esp
  802513:	eb b1                	jmp    8024c6 <_pipeisclosed+0xe>
	}
}
  802515:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5f                   	pop    %edi
  80251b:	5d                   	pop    %ebp
  80251c:	c3                   	ret    

0080251d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80251d:	55                   	push   %ebp
  80251e:	89 e5                	mov    %esp,%ebp
  802520:	57                   	push   %edi
  802521:	56                   	push   %esi
  802522:	53                   	push   %ebx
  802523:	83 ec 28             	sub    $0x28,%esp
  802526:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802529:	56                   	push   %esi
  80252a:	e8 b8 ec ff ff       	call   8011e7 <fd2data>
  80252f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802531:	83 c4 10             	add    $0x10,%esp
  802534:	bf 00 00 00 00       	mov    $0x0,%edi
  802539:	eb 4b                	jmp    802586 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80253b:	89 da                	mov    %ebx,%edx
  80253d:	89 f0                	mov    %esi,%eax
  80253f:	e8 74 ff ff ff       	call   8024b8 <_pipeisclosed>
  802544:	85 c0                	test   %eax,%eax
  802546:	75 48                	jne    802590 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802548:	e8 d5 e6 ff ff       	call   800c22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80254d:	8b 43 04             	mov    0x4(%ebx),%eax
  802550:	8b 0b                	mov    (%ebx),%ecx
  802552:	8d 51 20             	lea    0x20(%ecx),%edx
  802555:	39 d0                	cmp    %edx,%eax
  802557:	73 e2                	jae    80253b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802559:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80255c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802560:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802563:	89 c2                	mov    %eax,%edx
  802565:	c1 fa 1f             	sar    $0x1f,%edx
  802568:	89 d1                	mov    %edx,%ecx
  80256a:	c1 e9 1b             	shr    $0x1b,%ecx
  80256d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802570:	83 e2 1f             	and    $0x1f,%edx
  802573:	29 ca                	sub    %ecx,%edx
  802575:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802579:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80257d:	83 c0 01             	add    $0x1,%eax
  802580:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802583:	83 c7 01             	add    $0x1,%edi
  802586:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802589:	75 c2                	jne    80254d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80258b:	8b 45 10             	mov    0x10(%ebp),%eax
  80258e:	eb 05                	jmp    802595 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802590:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802595:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    

0080259d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	57                   	push   %edi
  8025a1:	56                   	push   %esi
  8025a2:	53                   	push   %ebx
  8025a3:	83 ec 18             	sub    $0x18,%esp
  8025a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025a9:	57                   	push   %edi
  8025aa:	e8 38 ec ff ff       	call   8011e7 <fd2data>
  8025af:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025b1:	83 c4 10             	add    $0x10,%esp
  8025b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025b9:	eb 3d                	jmp    8025f8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025bb:	85 db                	test   %ebx,%ebx
  8025bd:	74 04                	je     8025c3 <devpipe_read+0x26>
				return i;
  8025bf:	89 d8                	mov    %ebx,%eax
  8025c1:	eb 44                	jmp    802607 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	89 f8                	mov    %edi,%eax
  8025c7:	e8 ec fe ff ff       	call   8024b8 <_pipeisclosed>
  8025cc:	85 c0                	test   %eax,%eax
  8025ce:	75 32                	jne    802602 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8025d0:	e8 4d e6 ff ff       	call   800c22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025d5:	8b 06                	mov    (%esi),%eax
  8025d7:	3b 46 04             	cmp    0x4(%esi),%eax
  8025da:	74 df                	je     8025bb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025dc:	99                   	cltd   
  8025dd:	c1 ea 1b             	shr    $0x1b,%edx
  8025e0:	01 d0                	add    %edx,%eax
  8025e2:	83 e0 1f             	and    $0x1f,%eax
  8025e5:	29 d0                	sub    %edx,%eax
  8025e7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8025ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ef:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8025f2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025f5:	83 c3 01             	add    $0x1,%ebx
  8025f8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025fb:	75 d8                	jne    8025d5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025fd:	8b 45 10             	mov    0x10(%ebp),%eax
  802600:	eb 05                	jmp    802607 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802602:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802607:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260a:	5b                   	pop    %ebx
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    

0080260f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80260f:	55                   	push   %ebp
  802610:	89 e5                	mov    %esp,%ebp
  802612:	56                   	push   %esi
  802613:	53                   	push   %ebx
  802614:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80261a:	50                   	push   %eax
  80261b:	e8 de eb ff ff       	call   8011fe <fd_alloc>
  802620:	83 c4 10             	add    $0x10,%esp
  802623:	89 c2                	mov    %eax,%edx
  802625:	85 c0                	test   %eax,%eax
  802627:	0f 88 2c 01 00 00    	js     802759 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262d:	83 ec 04             	sub    $0x4,%esp
  802630:	68 07 04 00 00       	push   $0x407
  802635:	ff 75 f4             	pushl  -0xc(%ebp)
  802638:	6a 00                	push   $0x0
  80263a:	e8 02 e6 ff ff       	call   800c41 <sys_page_alloc>
  80263f:	83 c4 10             	add    $0x10,%esp
  802642:	89 c2                	mov    %eax,%edx
  802644:	85 c0                	test   %eax,%eax
  802646:	0f 88 0d 01 00 00    	js     802759 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80264c:	83 ec 0c             	sub    $0xc,%esp
  80264f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802652:	50                   	push   %eax
  802653:	e8 a6 eb ff ff       	call   8011fe <fd_alloc>
  802658:	89 c3                	mov    %eax,%ebx
  80265a:	83 c4 10             	add    $0x10,%esp
  80265d:	85 c0                	test   %eax,%eax
  80265f:	0f 88 e2 00 00 00    	js     802747 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802665:	83 ec 04             	sub    $0x4,%esp
  802668:	68 07 04 00 00       	push   $0x407
  80266d:	ff 75 f0             	pushl  -0x10(%ebp)
  802670:	6a 00                	push   $0x0
  802672:	e8 ca e5 ff ff       	call   800c41 <sys_page_alloc>
  802677:	89 c3                	mov    %eax,%ebx
  802679:	83 c4 10             	add    $0x10,%esp
  80267c:	85 c0                	test   %eax,%eax
  80267e:	0f 88 c3 00 00 00    	js     802747 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802684:	83 ec 0c             	sub    $0xc,%esp
  802687:	ff 75 f4             	pushl  -0xc(%ebp)
  80268a:	e8 58 eb ff ff       	call   8011e7 <fd2data>
  80268f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802691:	83 c4 0c             	add    $0xc,%esp
  802694:	68 07 04 00 00       	push   $0x407
  802699:	50                   	push   %eax
  80269a:	6a 00                	push   $0x0
  80269c:	e8 a0 e5 ff ff       	call   800c41 <sys_page_alloc>
  8026a1:	89 c3                	mov    %eax,%ebx
  8026a3:	83 c4 10             	add    $0x10,%esp
  8026a6:	85 c0                	test   %eax,%eax
  8026a8:	0f 88 89 00 00 00    	js     802737 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ae:	83 ec 0c             	sub    $0xc,%esp
  8026b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8026b4:	e8 2e eb ff ff       	call   8011e7 <fd2data>
  8026b9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026c0:	50                   	push   %eax
  8026c1:	6a 00                	push   $0x0
  8026c3:	56                   	push   %esi
  8026c4:	6a 00                	push   $0x0
  8026c6:	e8 b9 e5 ff ff       	call   800c84 <sys_page_map>
  8026cb:	89 c3                	mov    %eax,%ebx
  8026cd:	83 c4 20             	add    $0x20,%esp
  8026d0:	85 c0                	test   %eax,%eax
  8026d2:	78 55                	js     802729 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026d4:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026e9:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026fe:	83 ec 0c             	sub    $0xc,%esp
  802701:	ff 75 f4             	pushl  -0xc(%ebp)
  802704:	e8 ce ea ff ff       	call   8011d7 <fd2num>
  802709:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80270c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80270e:	83 c4 04             	add    $0x4,%esp
  802711:	ff 75 f0             	pushl  -0x10(%ebp)
  802714:	e8 be ea ff ff       	call   8011d7 <fd2num>
  802719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80271c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80271f:	83 c4 10             	add    $0x10,%esp
  802722:	ba 00 00 00 00       	mov    $0x0,%edx
  802727:	eb 30                	jmp    802759 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802729:	83 ec 08             	sub    $0x8,%esp
  80272c:	56                   	push   %esi
  80272d:	6a 00                	push   $0x0
  80272f:	e8 92 e5 ff ff       	call   800cc6 <sys_page_unmap>
  802734:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802737:	83 ec 08             	sub    $0x8,%esp
  80273a:	ff 75 f0             	pushl  -0x10(%ebp)
  80273d:	6a 00                	push   $0x0
  80273f:	e8 82 e5 ff ff       	call   800cc6 <sys_page_unmap>
  802744:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802747:	83 ec 08             	sub    $0x8,%esp
  80274a:	ff 75 f4             	pushl  -0xc(%ebp)
  80274d:	6a 00                	push   $0x0
  80274f:	e8 72 e5 ff ff       	call   800cc6 <sys_page_unmap>
  802754:	83 c4 10             	add    $0x10,%esp
  802757:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802759:	89 d0                	mov    %edx,%eax
  80275b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80275e:	5b                   	pop    %ebx
  80275f:	5e                   	pop    %esi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    

00802762 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802762:	55                   	push   %ebp
  802763:	89 e5                	mov    %esp,%ebp
  802765:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80276b:	50                   	push   %eax
  80276c:	ff 75 08             	pushl  0x8(%ebp)
  80276f:	e8 d9 ea ff ff       	call   80124d <fd_lookup>
  802774:	89 c2                	mov    %eax,%edx
  802776:	83 c4 10             	add    $0x10,%esp
  802779:	85 d2                	test   %edx,%edx
  80277b:	78 18                	js     802795 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80277d:	83 ec 0c             	sub    $0xc,%esp
  802780:	ff 75 f4             	pushl  -0xc(%ebp)
  802783:	e8 5f ea ff ff       	call   8011e7 <fd2data>
	return _pipeisclosed(fd, p);
  802788:	89 c2                	mov    %eax,%edx
  80278a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80278d:	e8 26 fd ff ff       	call   8024b8 <_pipeisclosed>
  802792:	83 c4 10             	add    $0x10,%esp
}
  802795:	c9                   	leave  
  802796:	c3                   	ret    

00802797 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802797:	55                   	push   %ebp
  802798:	89 e5                	mov    %esp,%ebp
  80279a:	56                   	push   %esi
  80279b:	53                   	push   %ebx
  80279c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80279f:	85 f6                	test   %esi,%esi
  8027a1:	75 16                	jne    8027b9 <wait+0x22>
  8027a3:	68 56 35 80 00       	push   $0x803556
  8027a8:	68 1f 34 80 00       	push   $0x80341f
  8027ad:	6a 09                	push   $0x9
  8027af:	68 61 35 80 00       	push   $0x803561
  8027b4:	e8 1f da ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8027b9:	89 f3                	mov    %esi,%ebx
  8027bb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027c1:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8027c4:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8027ca:	eb 05                	jmp    8027d1 <wait+0x3a>
		sys_yield();
  8027cc:	e8 51 e4 ff ff       	call   800c22 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027d1:	8b 43 48             	mov    0x48(%ebx),%eax
  8027d4:	39 f0                	cmp    %esi,%eax
  8027d6:	75 07                	jne    8027df <wait+0x48>
  8027d8:	8b 43 54             	mov    0x54(%ebx),%eax
  8027db:	85 c0                	test   %eax,%eax
  8027dd:	75 ed                	jne    8027cc <wait+0x35>
		sys_yield();
}
  8027df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027e2:	5b                   	pop    %ebx
  8027e3:	5e                   	pop    %esi
  8027e4:	5d                   	pop    %ebp
  8027e5:	c3                   	ret    

008027e6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8027e6:	55                   	push   %ebp
  8027e7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8027e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8027ee:	5d                   	pop    %ebp
  8027ef:	c3                   	ret    

008027f0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8027f0:	55                   	push   %ebp
  8027f1:	89 e5                	mov    %esp,%ebp
  8027f3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8027f6:	68 6c 35 80 00       	push   $0x80356c
  8027fb:	ff 75 0c             	pushl  0xc(%ebp)
  8027fe:	e8 35 e0 ff ff       	call   800838 <strcpy>
	return 0;
}
  802803:	b8 00 00 00 00       	mov    $0x0,%eax
  802808:	c9                   	leave  
  802809:	c3                   	ret    

0080280a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80280a:	55                   	push   %ebp
  80280b:	89 e5                	mov    %esp,%ebp
  80280d:	57                   	push   %edi
  80280e:	56                   	push   %esi
  80280f:	53                   	push   %ebx
  802810:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802816:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80281b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802821:	eb 2d                	jmp    802850 <devcons_write+0x46>
		m = n - tot;
  802823:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802826:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802828:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80282b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802830:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802833:	83 ec 04             	sub    $0x4,%esp
  802836:	53                   	push   %ebx
  802837:	03 45 0c             	add    0xc(%ebp),%eax
  80283a:	50                   	push   %eax
  80283b:	57                   	push   %edi
  80283c:	e8 89 e1 ff ff       	call   8009ca <memmove>
		sys_cputs(buf, m);
  802841:	83 c4 08             	add    $0x8,%esp
  802844:	53                   	push   %ebx
  802845:	57                   	push   %edi
  802846:	e8 3a e3 ff ff       	call   800b85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80284b:	01 de                	add    %ebx,%esi
  80284d:	83 c4 10             	add    $0x10,%esp
  802850:	89 f0                	mov    %esi,%eax
  802852:	3b 75 10             	cmp    0x10(%ebp),%esi
  802855:	72 cc                	jb     802823 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802857:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80285a:	5b                   	pop    %ebx
  80285b:	5e                   	pop    %esi
  80285c:	5f                   	pop    %edi
  80285d:	5d                   	pop    %ebp
  80285e:	c3                   	ret    

0080285f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80285f:	55                   	push   %ebp
  802860:	89 e5                	mov    %esp,%ebp
  802862:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802865:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80286a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80286e:	75 07                	jne    802877 <devcons_read+0x18>
  802870:	eb 28                	jmp    80289a <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802872:	e8 ab e3 ff ff       	call   800c22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802877:	e8 27 e3 ff ff       	call   800ba3 <sys_cgetc>
  80287c:	85 c0                	test   %eax,%eax
  80287e:	74 f2                	je     802872 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802880:	85 c0                	test   %eax,%eax
  802882:	78 16                	js     80289a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802884:	83 f8 04             	cmp    $0x4,%eax
  802887:	74 0c                	je     802895 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80288c:	88 02                	mov    %al,(%edx)
	return 1;
  80288e:	b8 01 00 00 00       	mov    $0x1,%eax
  802893:	eb 05                	jmp    80289a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802895:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80289a:	c9                   	leave  
  80289b:	c3                   	ret    

0080289c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80289c:	55                   	push   %ebp
  80289d:	89 e5                	mov    %esp,%ebp
  80289f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8028a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8028a8:	6a 01                	push   $0x1
  8028aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028ad:	50                   	push   %eax
  8028ae:	e8 d2 e2 ff ff       	call   800b85 <sys_cputs>
  8028b3:	83 c4 10             	add    $0x10,%esp
}
  8028b6:	c9                   	leave  
  8028b7:	c3                   	ret    

008028b8 <getchar>:

int
getchar(void)
{
  8028b8:	55                   	push   %ebp
  8028b9:	89 e5                	mov    %esp,%ebp
  8028bb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8028be:	6a 01                	push   $0x1
  8028c0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028c3:	50                   	push   %eax
  8028c4:	6a 00                	push   $0x0
  8028c6:	e8 f1 eb ff ff       	call   8014bc <read>
	if (r < 0)
  8028cb:	83 c4 10             	add    $0x10,%esp
  8028ce:	85 c0                	test   %eax,%eax
  8028d0:	78 0f                	js     8028e1 <getchar+0x29>
		return r;
	if (r < 1)
  8028d2:	85 c0                	test   %eax,%eax
  8028d4:	7e 06                	jle    8028dc <getchar+0x24>
		return -E_EOF;
	return c;
  8028d6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028da:	eb 05                	jmp    8028e1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028dc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028e1:	c9                   	leave  
  8028e2:	c3                   	ret    

008028e3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8028e3:	55                   	push   %ebp
  8028e4:	89 e5                	mov    %esp,%ebp
  8028e6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028ec:	50                   	push   %eax
  8028ed:	ff 75 08             	pushl  0x8(%ebp)
  8028f0:	e8 58 e9 ff ff       	call   80124d <fd_lookup>
  8028f5:	83 c4 10             	add    $0x10,%esp
  8028f8:	85 c0                	test   %eax,%eax
  8028fa:	78 11                	js     80290d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ff:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802905:	39 10                	cmp    %edx,(%eax)
  802907:	0f 94 c0             	sete   %al
  80290a:	0f b6 c0             	movzbl %al,%eax
}
  80290d:	c9                   	leave  
  80290e:	c3                   	ret    

0080290f <opencons>:

int
opencons(void)
{
  80290f:	55                   	push   %ebp
  802910:	89 e5                	mov    %esp,%ebp
  802912:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802918:	50                   	push   %eax
  802919:	e8 e0 e8 ff ff       	call   8011fe <fd_alloc>
  80291e:	83 c4 10             	add    $0x10,%esp
		return r;
  802921:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802923:	85 c0                	test   %eax,%eax
  802925:	78 3e                	js     802965 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802927:	83 ec 04             	sub    $0x4,%esp
  80292a:	68 07 04 00 00       	push   $0x407
  80292f:	ff 75 f4             	pushl  -0xc(%ebp)
  802932:	6a 00                	push   $0x0
  802934:	e8 08 e3 ff ff       	call   800c41 <sys_page_alloc>
  802939:	83 c4 10             	add    $0x10,%esp
		return r;
  80293c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80293e:	85 c0                	test   %eax,%eax
  802940:	78 23                	js     802965 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802942:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80294b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80294d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802950:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802957:	83 ec 0c             	sub    $0xc,%esp
  80295a:	50                   	push   %eax
  80295b:	e8 77 e8 ff ff       	call   8011d7 <fd2num>
  802960:	89 c2                	mov    %eax,%edx
  802962:	83 c4 10             	add    $0x10,%esp
}
  802965:	89 d0                	mov    %edx,%eax
  802967:	c9                   	leave  
  802968:	c3                   	ret    

00802969 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802969:	55                   	push   %ebp
  80296a:	89 e5                	mov    %esp,%ebp
  80296c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80296f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802976:	75 2c                	jne    8029a4 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802978:	83 ec 04             	sub    $0x4,%esp
  80297b:	6a 07                	push   $0x7
  80297d:	68 00 f0 bf ee       	push   $0xeebff000
  802982:	6a 00                	push   $0x0
  802984:	e8 b8 e2 ff ff       	call   800c41 <sys_page_alloc>
  802989:	83 c4 10             	add    $0x10,%esp
  80298c:	85 c0                	test   %eax,%eax
  80298e:	74 14                	je     8029a4 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802990:	83 ec 04             	sub    $0x4,%esp
  802993:	68 78 35 80 00       	push   $0x803578
  802998:	6a 21                	push   $0x21
  80299a:	68 dc 35 80 00       	push   $0x8035dc
  80299f:	e8 34 d8 ff ff       	call   8001d8 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8029a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a7:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8029ac:	83 ec 08             	sub    $0x8,%esp
  8029af:	68 d8 29 80 00       	push   $0x8029d8
  8029b4:	6a 00                	push   $0x0
  8029b6:	e8 d1 e3 ff ff       	call   800d8c <sys_env_set_pgfault_upcall>
  8029bb:	83 c4 10             	add    $0x10,%esp
  8029be:	85 c0                	test   %eax,%eax
  8029c0:	79 14                	jns    8029d6 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8029c2:	83 ec 04             	sub    $0x4,%esp
  8029c5:	68 a4 35 80 00       	push   $0x8035a4
  8029ca:	6a 29                	push   $0x29
  8029cc:	68 dc 35 80 00       	push   $0x8035dc
  8029d1:	e8 02 d8 ff ff       	call   8001d8 <_panic>
}
  8029d6:	c9                   	leave  
  8029d7:	c3                   	ret    

008029d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8029d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8029d9:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8029de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8029e0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8029e3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8029e8:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8029ec:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8029f0:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8029f2:	83 c4 08             	add    $0x8,%esp
        popal
  8029f5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8029f6:	83 c4 04             	add    $0x4,%esp
        popfl
  8029f9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8029fa:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8029fb:	c3                   	ret    

008029fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029fc:	55                   	push   %ebp
  8029fd:	89 e5                	mov    %esp,%ebp
  8029ff:	56                   	push   %esi
  802a00:	53                   	push   %ebx
  802a01:	8b 75 08             	mov    0x8(%ebp),%esi
  802a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802a0a:	85 c0                	test   %eax,%eax
  802a0c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802a11:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802a14:	83 ec 0c             	sub    $0xc,%esp
  802a17:	50                   	push   %eax
  802a18:	e8 d4 e3 ff ff       	call   800df1 <sys_ipc_recv>
  802a1d:	83 c4 10             	add    $0x10,%esp
  802a20:	85 c0                	test   %eax,%eax
  802a22:	79 16                	jns    802a3a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802a24:	85 f6                	test   %esi,%esi
  802a26:	74 06                	je     802a2e <ipc_recv+0x32>
  802a28:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802a2e:	85 db                	test   %ebx,%ebx
  802a30:	74 2c                	je     802a5e <ipc_recv+0x62>
  802a32:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802a38:	eb 24                	jmp    802a5e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802a3a:	85 f6                	test   %esi,%esi
  802a3c:	74 0a                	je     802a48 <ipc_recv+0x4c>
  802a3e:	a1 08 50 80 00       	mov    0x805008,%eax
  802a43:	8b 40 74             	mov    0x74(%eax),%eax
  802a46:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802a48:	85 db                	test   %ebx,%ebx
  802a4a:	74 0a                	je     802a56 <ipc_recv+0x5a>
  802a4c:	a1 08 50 80 00       	mov    0x805008,%eax
  802a51:	8b 40 78             	mov    0x78(%eax),%eax
  802a54:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802a56:	a1 08 50 80 00       	mov    0x805008,%eax
  802a5b:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a61:	5b                   	pop    %ebx
  802a62:	5e                   	pop    %esi
  802a63:	5d                   	pop    %ebp
  802a64:	c3                   	ret    

00802a65 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a65:	55                   	push   %ebp
  802a66:	89 e5                	mov    %esp,%ebp
  802a68:	57                   	push   %edi
  802a69:	56                   	push   %esi
  802a6a:	53                   	push   %ebx
  802a6b:	83 ec 0c             	sub    $0xc,%esp
  802a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802a77:	85 db                	test   %ebx,%ebx
  802a79:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a7e:	0f 44 d8             	cmove  %eax,%ebx
  802a81:	eb 1c                	jmp    802a9f <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802a83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a86:	74 12                	je     802a9a <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802a88:	50                   	push   %eax
  802a89:	68 ea 35 80 00       	push   $0x8035ea
  802a8e:	6a 39                	push   $0x39
  802a90:	68 05 36 80 00       	push   $0x803605
  802a95:	e8 3e d7 ff ff       	call   8001d8 <_panic>
                 sys_yield();
  802a9a:	e8 83 e1 ff ff       	call   800c22 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802a9f:	ff 75 14             	pushl  0x14(%ebp)
  802aa2:	53                   	push   %ebx
  802aa3:	56                   	push   %esi
  802aa4:	57                   	push   %edi
  802aa5:	e8 24 e3 ff ff       	call   800dce <sys_ipc_try_send>
  802aaa:	83 c4 10             	add    $0x10,%esp
  802aad:	85 c0                	test   %eax,%eax
  802aaf:	78 d2                	js     802a83 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ab4:	5b                   	pop    %ebx
  802ab5:	5e                   	pop    %esi
  802ab6:	5f                   	pop    %edi
  802ab7:	5d                   	pop    %ebp
  802ab8:	c3                   	ret    

00802ab9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802ab9:	55                   	push   %ebp
  802aba:	89 e5                	mov    %esp,%ebp
  802abc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802abf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802ac4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802ac7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802acd:	8b 52 50             	mov    0x50(%edx),%edx
  802ad0:	39 ca                	cmp    %ecx,%edx
  802ad2:	75 0d                	jne    802ae1 <ipc_find_env+0x28>
			return envs[i].env_id;
  802ad4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ad7:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802adc:	8b 40 08             	mov    0x8(%eax),%eax
  802adf:	eb 0e                	jmp    802aef <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ae1:	83 c0 01             	add    $0x1,%eax
  802ae4:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ae9:	75 d9                	jne    802ac4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802aeb:	66 b8 00 00          	mov    $0x0,%ax
}
  802aef:	5d                   	pop    %ebp
  802af0:	c3                   	ret    

00802af1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802af1:	55                   	push   %ebp
  802af2:	89 e5                	mov    %esp,%ebp
  802af4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802af7:	89 d0                	mov    %edx,%eax
  802af9:	c1 e8 16             	shr    $0x16,%eax
  802afc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802b03:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b08:	f6 c1 01             	test   $0x1,%cl
  802b0b:	74 1d                	je     802b2a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802b0d:	c1 ea 0c             	shr    $0xc,%edx
  802b10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802b17:	f6 c2 01             	test   $0x1,%dl
  802b1a:	74 0e                	je     802b2a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b1c:	c1 ea 0c             	shr    $0xc,%edx
  802b1f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802b26:	ef 
  802b27:	0f b7 c0             	movzwl %ax,%eax
}
  802b2a:	5d                   	pop    %ebp
  802b2b:	c3                   	ret    
  802b2c:	66 90                	xchg   %ax,%ax
  802b2e:	66 90                	xchg   %ax,%ax

00802b30 <__udivdi3>:
  802b30:	55                   	push   %ebp
  802b31:	57                   	push   %edi
  802b32:	56                   	push   %esi
  802b33:	83 ec 10             	sub    $0x10,%esp
  802b36:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  802b3a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  802b3e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802b42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802b46:	85 d2                	test   %edx,%edx
  802b48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802b4c:	89 34 24             	mov    %esi,(%esp)
  802b4f:	89 c8                	mov    %ecx,%eax
  802b51:	75 35                	jne    802b88 <__udivdi3+0x58>
  802b53:	39 f1                	cmp    %esi,%ecx
  802b55:	0f 87 bd 00 00 00    	ja     802c18 <__udivdi3+0xe8>
  802b5b:	85 c9                	test   %ecx,%ecx
  802b5d:	89 cd                	mov    %ecx,%ebp
  802b5f:	75 0b                	jne    802b6c <__udivdi3+0x3c>
  802b61:	b8 01 00 00 00       	mov    $0x1,%eax
  802b66:	31 d2                	xor    %edx,%edx
  802b68:	f7 f1                	div    %ecx
  802b6a:	89 c5                	mov    %eax,%ebp
  802b6c:	89 f0                	mov    %esi,%eax
  802b6e:	31 d2                	xor    %edx,%edx
  802b70:	f7 f5                	div    %ebp
  802b72:	89 c6                	mov    %eax,%esi
  802b74:	89 f8                	mov    %edi,%eax
  802b76:	f7 f5                	div    %ebp
  802b78:	89 f2                	mov    %esi,%edx
  802b7a:	83 c4 10             	add    $0x10,%esp
  802b7d:	5e                   	pop    %esi
  802b7e:	5f                   	pop    %edi
  802b7f:	5d                   	pop    %ebp
  802b80:	c3                   	ret    
  802b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b88:	3b 14 24             	cmp    (%esp),%edx
  802b8b:	77 7b                	ja     802c08 <__udivdi3+0xd8>
  802b8d:	0f bd f2             	bsr    %edx,%esi
  802b90:	83 f6 1f             	xor    $0x1f,%esi
  802b93:	0f 84 97 00 00 00    	je     802c30 <__udivdi3+0x100>
  802b99:	bd 20 00 00 00       	mov    $0x20,%ebp
  802b9e:	89 d7                	mov    %edx,%edi
  802ba0:	89 f1                	mov    %esi,%ecx
  802ba2:	29 f5                	sub    %esi,%ebp
  802ba4:	d3 e7                	shl    %cl,%edi
  802ba6:	89 c2                	mov    %eax,%edx
  802ba8:	89 e9                	mov    %ebp,%ecx
  802baa:	d3 ea                	shr    %cl,%edx
  802bac:	89 f1                	mov    %esi,%ecx
  802bae:	09 fa                	or     %edi,%edx
  802bb0:	8b 3c 24             	mov    (%esp),%edi
  802bb3:	d3 e0                	shl    %cl,%eax
  802bb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  802bb9:	89 e9                	mov    %ebp,%ecx
  802bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  802bc3:	89 fa                	mov    %edi,%edx
  802bc5:	d3 ea                	shr    %cl,%edx
  802bc7:	89 f1                	mov    %esi,%ecx
  802bc9:	d3 e7                	shl    %cl,%edi
  802bcb:	89 e9                	mov    %ebp,%ecx
  802bcd:	d3 e8                	shr    %cl,%eax
  802bcf:	09 c7                	or     %eax,%edi
  802bd1:	89 f8                	mov    %edi,%eax
  802bd3:	f7 74 24 08          	divl   0x8(%esp)
  802bd7:	89 d5                	mov    %edx,%ebp
  802bd9:	89 c7                	mov    %eax,%edi
  802bdb:	f7 64 24 0c          	mull   0xc(%esp)
  802bdf:	39 d5                	cmp    %edx,%ebp
  802be1:	89 14 24             	mov    %edx,(%esp)
  802be4:	72 11                	jb     802bf7 <__udivdi3+0xc7>
  802be6:	8b 54 24 04          	mov    0x4(%esp),%edx
  802bea:	89 f1                	mov    %esi,%ecx
  802bec:	d3 e2                	shl    %cl,%edx
  802bee:	39 c2                	cmp    %eax,%edx
  802bf0:	73 5e                	jae    802c50 <__udivdi3+0x120>
  802bf2:	3b 2c 24             	cmp    (%esp),%ebp
  802bf5:	75 59                	jne    802c50 <__udivdi3+0x120>
  802bf7:	8d 47 ff             	lea    -0x1(%edi),%eax
  802bfa:	31 f6                	xor    %esi,%esi
  802bfc:	89 f2                	mov    %esi,%edx
  802bfe:	83 c4 10             	add    $0x10,%esp
  802c01:	5e                   	pop    %esi
  802c02:	5f                   	pop    %edi
  802c03:	5d                   	pop    %ebp
  802c04:	c3                   	ret    
  802c05:	8d 76 00             	lea    0x0(%esi),%esi
  802c08:	31 f6                	xor    %esi,%esi
  802c0a:	31 c0                	xor    %eax,%eax
  802c0c:	89 f2                	mov    %esi,%edx
  802c0e:	83 c4 10             	add    $0x10,%esp
  802c11:	5e                   	pop    %esi
  802c12:	5f                   	pop    %edi
  802c13:	5d                   	pop    %ebp
  802c14:	c3                   	ret    
  802c15:	8d 76 00             	lea    0x0(%esi),%esi
  802c18:	89 f2                	mov    %esi,%edx
  802c1a:	31 f6                	xor    %esi,%esi
  802c1c:	89 f8                	mov    %edi,%eax
  802c1e:	f7 f1                	div    %ecx
  802c20:	89 f2                	mov    %esi,%edx
  802c22:	83 c4 10             	add    $0x10,%esp
  802c25:	5e                   	pop    %esi
  802c26:	5f                   	pop    %edi
  802c27:	5d                   	pop    %ebp
  802c28:	c3                   	ret    
  802c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c30:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802c34:	76 0b                	jbe    802c41 <__udivdi3+0x111>
  802c36:	31 c0                	xor    %eax,%eax
  802c38:	3b 14 24             	cmp    (%esp),%edx
  802c3b:	0f 83 37 ff ff ff    	jae    802b78 <__udivdi3+0x48>
  802c41:	b8 01 00 00 00       	mov    $0x1,%eax
  802c46:	e9 2d ff ff ff       	jmp    802b78 <__udivdi3+0x48>
  802c4b:	90                   	nop
  802c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c50:	89 f8                	mov    %edi,%eax
  802c52:	31 f6                	xor    %esi,%esi
  802c54:	e9 1f ff ff ff       	jmp    802b78 <__udivdi3+0x48>
  802c59:	66 90                	xchg   %ax,%ax
  802c5b:	66 90                	xchg   %ax,%ax
  802c5d:	66 90                	xchg   %ax,%ax
  802c5f:	90                   	nop

00802c60 <__umoddi3>:
  802c60:	55                   	push   %ebp
  802c61:	57                   	push   %edi
  802c62:	56                   	push   %esi
  802c63:	83 ec 20             	sub    $0x20,%esp
  802c66:	8b 44 24 34          	mov    0x34(%esp),%eax
  802c6a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802c6e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c72:	89 c6                	mov    %eax,%esi
  802c74:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c78:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802c7c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802c80:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c84:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802c88:	89 74 24 18          	mov    %esi,0x18(%esp)
  802c8c:	85 c0                	test   %eax,%eax
  802c8e:	89 c2                	mov    %eax,%edx
  802c90:	75 1e                	jne    802cb0 <__umoddi3+0x50>
  802c92:	39 f7                	cmp    %esi,%edi
  802c94:	76 52                	jbe    802ce8 <__umoddi3+0x88>
  802c96:	89 c8                	mov    %ecx,%eax
  802c98:	89 f2                	mov    %esi,%edx
  802c9a:	f7 f7                	div    %edi
  802c9c:	89 d0                	mov    %edx,%eax
  802c9e:	31 d2                	xor    %edx,%edx
  802ca0:	83 c4 20             	add    $0x20,%esp
  802ca3:	5e                   	pop    %esi
  802ca4:	5f                   	pop    %edi
  802ca5:	5d                   	pop    %ebp
  802ca6:	c3                   	ret    
  802ca7:	89 f6                	mov    %esi,%esi
  802ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802cb0:	39 f0                	cmp    %esi,%eax
  802cb2:	77 5c                	ja     802d10 <__umoddi3+0xb0>
  802cb4:	0f bd e8             	bsr    %eax,%ebp
  802cb7:	83 f5 1f             	xor    $0x1f,%ebp
  802cba:	75 64                	jne    802d20 <__umoddi3+0xc0>
  802cbc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802cc0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802cc4:	0f 86 f6 00 00 00    	jbe    802dc0 <__umoddi3+0x160>
  802cca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802cce:	0f 82 ec 00 00 00    	jb     802dc0 <__umoddi3+0x160>
  802cd4:	8b 44 24 14          	mov    0x14(%esp),%eax
  802cd8:	8b 54 24 18          	mov    0x18(%esp),%edx
  802cdc:	83 c4 20             	add    $0x20,%esp
  802cdf:	5e                   	pop    %esi
  802ce0:	5f                   	pop    %edi
  802ce1:	5d                   	pop    %ebp
  802ce2:	c3                   	ret    
  802ce3:	90                   	nop
  802ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ce8:	85 ff                	test   %edi,%edi
  802cea:	89 fd                	mov    %edi,%ebp
  802cec:	75 0b                	jne    802cf9 <__umoddi3+0x99>
  802cee:	b8 01 00 00 00       	mov    $0x1,%eax
  802cf3:	31 d2                	xor    %edx,%edx
  802cf5:	f7 f7                	div    %edi
  802cf7:	89 c5                	mov    %eax,%ebp
  802cf9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802cfd:	31 d2                	xor    %edx,%edx
  802cff:	f7 f5                	div    %ebp
  802d01:	89 c8                	mov    %ecx,%eax
  802d03:	f7 f5                	div    %ebp
  802d05:	eb 95                	jmp    802c9c <__umoddi3+0x3c>
  802d07:	89 f6                	mov    %esi,%esi
  802d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802d10:	89 c8                	mov    %ecx,%eax
  802d12:	89 f2                	mov    %esi,%edx
  802d14:	83 c4 20             	add    $0x20,%esp
  802d17:	5e                   	pop    %esi
  802d18:	5f                   	pop    %edi
  802d19:	5d                   	pop    %ebp
  802d1a:	c3                   	ret    
  802d1b:	90                   	nop
  802d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d20:	b8 20 00 00 00       	mov    $0x20,%eax
  802d25:	89 e9                	mov    %ebp,%ecx
  802d27:	29 e8                	sub    %ebp,%eax
  802d29:	d3 e2                	shl    %cl,%edx
  802d2b:	89 c7                	mov    %eax,%edi
  802d2d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802d31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802d35:	89 f9                	mov    %edi,%ecx
  802d37:	d3 e8                	shr    %cl,%eax
  802d39:	89 c1                	mov    %eax,%ecx
  802d3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802d3f:	09 d1                	or     %edx,%ecx
  802d41:	89 fa                	mov    %edi,%edx
  802d43:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802d47:	89 e9                	mov    %ebp,%ecx
  802d49:	d3 e0                	shl    %cl,%eax
  802d4b:	89 f9                	mov    %edi,%ecx
  802d4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d51:	89 f0                	mov    %esi,%eax
  802d53:	d3 e8                	shr    %cl,%eax
  802d55:	89 e9                	mov    %ebp,%ecx
  802d57:	89 c7                	mov    %eax,%edi
  802d59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802d5d:	d3 e6                	shl    %cl,%esi
  802d5f:	89 d1                	mov    %edx,%ecx
  802d61:	89 fa                	mov    %edi,%edx
  802d63:	d3 e8                	shr    %cl,%eax
  802d65:	89 e9                	mov    %ebp,%ecx
  802d67:	09 f0                	or     %esi,%eax
  802d69:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  802d6d:	f7 74 24 10          	divl   0x10(%esp)
  802d71:	d3 e6                	shl    %cl,%esi
  802d73:	89 d1                	mov    %edx,%ecx
  802d75:	f7 64 24 0c          	mull   0xc(%esp)
  802d79:	39 d1                	cmp    %edx,%ecx
  802d7b:	89 74 24 14          	mov    %esi,0x14(%esp)
  802d7f:	89 d7                	mov    %edx,%edi
  802d81:	89 c6                	mov    %eax,%esi
  802d83:	72 0a                	jb     802d8f <__umoddi3+0x12f>
  802d85:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802d89:	73 10                	jae    802d9b <__umoddi3+0x13b>
  802d8b:	39 d1                	cmp    %edx,%ecx
  802d8d:	75 0c                	jne    802d9b <__umoddi3+0x13b>
  802d8f:	89 d7                	mov    %edx,%edi
  802d91:	89 c6                	mov    %eax,%esi
  802d93:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802d97:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  802d9b:	89 ca                	mov    %ecx,%edx
  802d9d:	89 e9                	mov    %ebp,%ecx
  802d9f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802da3:	29 f0                	sub    %esi,%eax
  802da5:	19 fa                	sbb    %edi,%edx
  802da7:	d3 e8                	shr    %cl,%eax
  802da9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802dae:	89 d7                	mov    %edx,%edi
  802db0:	d3 e7                	shl    %cl,%edi
  802db2:	89 e9                	mov    %ebp,%ecx
  802db4:	09 f8                	or     %edi,%eax
  802db6:	d3 ea                	shr    %cl,%edx
  802db8:	83 c4 20             	add    $0x20,%esp
  802dbb:	5e                   	pop    %esi
  802dbc:	5f                   	pop    %edi
  802dbd:	5d                   	pop    %ebp
  802dbe:	c3                   	ret    
  802dbf:	90                   	nop
  802dc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  802dc4:	29 f9                	sub    %edi,%ecx
  802dc6:	19 c6                	sbb    %eax,%esi
  802dc8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802dcc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802dd0:	e9 ff fe ff ff       	jmp    802cd4 <__umoddi3+0x74>
