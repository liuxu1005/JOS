
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 40 40 80 00       	push   $0x804040
  800046:	6a 01                	push   $0x1
  800048:	e8 fc 11 00 00       	call   801249 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 d8                	cmp    %ebx,%eax
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 40 25 80 00       	push   $0x802540
  800060:	6a 0d                	push   $0xd
  800062:	68 5b 25 80 00       	push   $0x80255b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 40 40 80 00       	push   $0x804040
  800079:	56                   	push   %esi
  80007a:	e8 f4 10 00 00       	call   801173 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 66 25 80 00       	push   $0x802566
  800098:	6a 0f                	push   $0xf
  80009a:	68 5b 25 80 00       	push   $0x80255b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 7b 	movl   $0x80257b,0x803000
  8000be:	25 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 7f 25 80 00       	push   $0x80257f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 33 15 00 00       	call   801620 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 87 25 80 00       	push   $0x802587
  800102:	e8 b7 16 00 00       	call   8017be <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 13 0f 00 00       	call   801033 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80013e:	e8 7b 0a 00 00       	call   800bbe <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 40 60 80 00       	mov    %eax,0x806040

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
  80016f:	83 c4 10             	add    $0x10,%esp
}
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 dc 0e 00 00       	call   801060 <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 ef 09 00 00       	call   800b7d <sys_env_destroy>
  80018e:	83 c4 10             	add    $0x10,%esp
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 18 0a 00 00       	call   800bbe <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 a4 25 80 00       	push   $0x8025a4
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 24 2a 80 00 	movl   $0x802a24,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 37 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 4f 01 00 00       	call   80039e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 dc 08 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 d1                	mov    %edx,%ecx
  800295:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800298:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029b:	8b 45 10             	mov    0x10(%ebp),%eax
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ab:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002ae:	72 05                	jb     8002b5 <printnum+0x35>
  8002b0:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002b3:	77 3e                	ja     8002f3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	ff 75 18             	pushl  0x18(%ebp)
  8002bb:	83 eb 01             	sub    $0x1,%ebx
  8002be:	53                   	push   %ebx
  8002bf:	50                   	push   %eax
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 8c 1f 00 00       	call   802260 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 13                	jmp    8002fa <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f3:	83 eb 01             	sub    $0x1,%ebx
  8002f6:	85 db                	test   %ebx,%ebx
  8002f8:	7f ed                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	56                   	push   %esi
  8002fe:	83 ec 04             	sub    $0x4,%esp
  800301:	ff 75 e4             	pushl  -0x1c(%ebp)
  800304:	ff 75 e0             	pushl  -0x20(%ebp)
  800307:	ff 75 dc             	pushl  -0x24(%ebp)
  80030a:	ff 75 d8             	pushl  -0x28(%ebp)
  80030d:	e8 7e 20 00 00       	call   802390 <__umoddi3>
  800312:	83 c4 14             	add    $0x14,%esp
  800315:	0f be 80 c7 25 80 00 	movsbl 0x8025c7(%eax),%eax
  80031c:	50                   	push   %eax
  80031d:	ff d7                	call   *%edi
  80031f:	83 c4 10             	add    $0x10,%esp
}
  800322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	3b 50 04             	cmp    0x4(%eax),%edx
  800373:	73 0a                	jae    80037f <sprintputch+0x1b>
		*b->buf++ = ch;
  800375:	8d 4a 01             	lea    0x1(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	88 02                	mov    %al,(%edx)
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800387:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038a:	50                   	push   %eax
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	ff 75 0c             	pushl  0xc(%ebp)
  800391:	ff 75 08             	pushl  0x8(%ebp)
  800394:	e8 05 00 00 00       	call   80039e <vprintfmt>
	va_end(ap);
  800399:	83 c4 10             	add    $0x10,%esp
}
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    

0080039e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 2c             	sub    $0x2c,%esp
  8003a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ad:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b0:	eb 12                	jmp    8003c4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	0f 84 90 03 00 00    	je     80074a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	53                   	push   %ebx
  8003be:	50                   	push   %eax
  8003bf:	ff d6                	call   *%esi
  8003c1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c4:	83 c7 01             	add    $0x1,%edi
  8003c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003cb:	83 f8 25             	cmp    $0x25,%eax
  8003ce:	75 e2                	jne    8003b2 <vprintfmt+0x14>
  8003d0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 07                	jmp    8003f7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8d 47 01             	lea    0x1(%edi),%eax
  8003fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fd:	0f b6 07             	movzbl (%edi),%eax
  800400:	0f b6 c8             	movzbl %al,%ecx
  800403:	83 e8 23             	sub    $0x23,%eax
  800406:	3c 55                	cmp    $0x55,%al
  800408:	0f 87 21 03 00 00    	ja     80072f <vprintfmt+0x391>
  80040e:	0f b6 c0             	movzbl %al,%eax
  800411:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041f:	eb d6                	jmp    8003f7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	b8 00 00 00 00       	mov    $0x0,%eax
  800429:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800433:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800436:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800439:	83 fa 09             	cmp    $0x9,%edx
  80043c:	77 39                	ja     800477 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800441:	eb e9                	jmp    80042c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 48 04             	lea    0x4(%eax),%ecx
  800449:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800454:	eb 27                	jmp    80047d <vprintfmt+0xdf>
  800456:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800459:	85 c0                	test   %eax,%eax
  80045b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800460:	0f 49 c8             	cmovns %eax,%ecx
  800463:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800469:	eb 8c                	jmp    8003f7 <vprintfmt+0x59>
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800475:	eb 80                	jmp    8003f7 <vprintfmt+0x59>
  800477:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800481:	0f 89 70 ff ff ff    	jns    8003f7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800487:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800494:	e9 5e ff ff ff       	jmp    8003f7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800499:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049f:	e9 53 ff ff ff       	jmp    8003f7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	ff 30                	pushl  (%eax)
  8004b3:	ff d6                	call   *%esi
			break;
  8004b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bb:	e9 04 ff ff ff       	jmp    8003c4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	99                   	cltd   
  8004cc:	31 d0                	xor    %edx,%eax
  8004ce:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 f8 0f             	cmp    $0xf,%eax
  8004d3:	7f 0b                	jg     8004e0 <vprintfmt+0x142>
  8004d5:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	75 18                	jne    8004f8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	50                   	push   %eax
  8004e1:	68 df 25 80 00       	push   $0x8025df
  8004e6:	53                   	push   %ebx
  8004e7:	56                   	push   %esi
  8004e8:	e8 94 fe ff ff       	call   800381 <printfmt>
  8004ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 cc fe ff ff       	jmp    8003c4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	52                   	push   %edx
  8004f9:	68 b9 29 80 00       	push   $0x8029b9
  8004fe:	53                   	push   %ebx
  8004ff:	56                   	push   %esi
  800500:	e8 7c fe ff ff       	call   800381 <printfmt>
  800505:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050b:	e9 b4 fe ff ff       	jmp    8003c4 <vprintfmt+0x26>
  800510:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800513:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800516:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800524:	85 ff                	test   %edi,%edi
  800526:	ba d8 25 80 00       	mov    $0x8025d8,%edx
  80052b:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80052e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800532:	0f 84 92 00 00 00    	je     8005ca <vprintfmt+0x22c>
  800538:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80053c:	0f 8e 96 00 00 00    	jle    8005d8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	51                   	push   %ecx
  800546:	57                   	push   %edi
  800547:	e8 86 02 00 00       	call   8007d2 <strnlen>
  80054c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054f:	29 c1                	sub    %eax,%ecx
  800551:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800557:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800561:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	eb 0f                	jmp    800574 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	53                   	push   %ebx
  800569:	ff 75 e0             	pushl  -0x20(%ebp)
  80056c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056e:	83 ef 01             	sub    $0x1,%edi
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	85 ff                	test   %edi,%edi
  800576:	7f ed                	jg     800565 <vprintfmt+0x1c7>
  800578:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	0f 49 c1             	cmovns %ecx,%eax
  800588:	29 c1                	sub    %eax,%ecx
  80058a:	89 75 08             	mov    %esi,0x8(%ebp)
  80058d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800590:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800593:	89 cb                	mov    %ecx,%ebx
  800595:	eb 4d                	jmp    8005e4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800597:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059b:	74 1b                	je     8005b8 <vprintfmt+0x21a>
  80059d:	0f be c0             	movsbl %al,%eax
  8005a0:	83 e8 20             	sub    $0x20,%eax
  8005a3:	83 f8 5e             	cmp    $0x5e,%eax
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x21a>
					putch('?', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	6a 3f                	push   $0x3f
  8005b0:	ff 55 08             	call   *0x8(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	eb 0d                	jmp    8005c5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 0c             	pushl  0xc(%ebp)
  8005be:	52                   	push   %edx
  8005bf:	ff 55 08             	call   *0x8(%ebp)
  8005c2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c5:	83 eb 01             	sub    $0x1,%ebx
  8005c8:	eb 1a                	jmp    8005e4 <vprintfmt+0x246>
  8005ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d6:	eb 0c                	jmp    8005e4 <vprintfmt+0x246>
  8005d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e4:	83 c7 01             	add    $0x1,%edi
  8005e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005eb:	0f be d0             	movsbl %al,%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	74 23                	je     800615 <vprintfmt+0x277>
  8005f2:	85 f6                	test   %esi,%esi
  8005f4:	78 a1                	js     800597 <vprintfmt+0x1f9>
  8005f6:	83 ee 01             	sub    $0x1,%esi
  8005f9:	79 9c                	jns    800597 <vprintfmt+0x1f9>
  8005fb:	89 df                	mov    %ebx,%edi
  8005fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800600:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800603:	eb 18                	jmp    80061d <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 20                	push   $0x20
  80060b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060d:	83 ef 01             	sub    $0x1,%edi
  800610:	83 c4 10             	add    $0x10,%esp
  800613:	eb 08                	jmp    80061d <vprintfmt+0x27f>
  800615:	89 df                	mov    %ebx,%edi
  800617:	8b 75 08             	mov    0x8(%ebp),%esi
  80061a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061d:	85 ff                	test   %edi,%edi
  80061f:	7f e4                	jg     800605 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800624:	e9 9b fd ff ff       	jmp    8003c4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800629:	83 fa 01             	cmp    $0x1,%edx
  80062c:	7e 16                	jle    800644 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 08             	lea    0x8(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 50 04             	mov    0x4(%eax),%edx
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	eb 32                	jmp    800676 <vprintfmt+0x2d8>
	else if (lflag)
  800644:	85 d2                	test   %edx,%edx
  800646:	74 18                	je     800660 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	8b 00                	mov    (%eax),%eax
  800653:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800656:	89 c1                	mov    %eax,%ecx
  800658:	c1 f9 1f             	sar    $0x1f,%ecx
  80065b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065e:	eb 16                	jmp    800676 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800676:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800679:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800681:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800685:	79 74                	jns    8006fb <vprintfmt+0x35d>
				putch('-', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 2d                	push   $0x2d
  80068d:	ff d6                	call   *%esi
				num = -(long long) num;
  80068f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800692:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800695:	f7 d8                	neg    %eax
  800697:	83 d2 00             	adc    $0x0,%edx
  80069a:	f7 da                	neg    %edx
  80069c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a4:	eb 55                	jmp    8006fb <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 7c fc ff ff       	call   80032a <getuint>
			base = 10;
  8006ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b3:	eb 46                	jmp    8006fb <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 6d fc ff ff       	call   80032a <getuint>
                        base = 8;
  8006bd:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006c2:	eb 37                	jmp    8006fb <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 30                	push   $0x30
  8006ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cc:	83 c4 08             	add    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 78                	push   $0x78
  8006d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ec:	eb 0d                	jmp    8006fb <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f1:	e8 34 fc ff ff       	call   80032a <getuint>
			base = 16;
  8006f6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fb:	83 ec 0c             	sub    $0xc,%esp
  8006fe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800702:	57                   	push   %edi
  800703:	ff 75 e0             	pushl  -0x20(%ebp)
  800706:	51                   	push   %ecx
  800707:	52                   	push   %edx
  800708:	50                   	push   %eax
  800709:	89 da                	mov    %ebx,%edx
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	e8 6e fb ff ff       	call   800280 <printnum>
			break;
  800712:	83 c4 20             	add    $0x20,%esp
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800718:	e9 a7 fc ff ff       	jmp    8003c4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	51                   	push   %ecx
  800722:	ff d6                	call   *%esi
			break;
  800724:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072a:	e9 95 fc ff ff       	jmp    8003c4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 25                	push   $0x25
  800735:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 03                	jmp    80073f <vprintfmt+0x3a1>
  80073c:	83 ef 01             	sub    $0x1,%edi
  80073f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800743:	75 f7                	jne    80073c <vprintfmt+0x39e>
  800745:	e9 7a fc ff ff       	jmp    8003c4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 18             	sub    $0x18,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 26                	je     800799 <vsnprintf+0x47>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 22                	jle    800799 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	ff 75 14             	pushl  0x14(%ebp)
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	68 64 03 80 00       	push   $0x800364
  800786:	e8 13 fc ff ff       	call   80039e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	eb 05                	jmp    80079e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a9:	50                   	push   %eax
  8007aa:	ff 75 10             	pushl  0x10(%ebp)
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	ff 75 08             	pushl  0x8(%ebp)
  8007b3:	e8 9a ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	eb 03                	jmp    8007ca <strlen+0x10>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f7                	jne    8007c7 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e0:	eb 03                	jmp    8007e5 <strnlen+0x13>
		n++;
  8007e2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	39 c2                	cmp    %eax,%edx
  8007e7:	74 08                	je     8007f1 <strnlen+0x1f>
  8007e9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ed:	75 f3                	jne    8007e2 <strnlen+0x10>
  8007ef:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fd:	89 c2                	mov    %eax,%edx
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800809:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080c:	84 db                	test   %bl,%bl
  80080e:	75 ef                	jne    8007ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800810:	5b                   	pop    %ebx
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081a:	53                   	push   %ebx
  80081b:	e8 9a ff ff ff       	call   8007ba <strlen>
  800820:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	01 d8                	add    %ebx,%eax
  800828:	50                   	push   %eax
  800829:	e8 c5 ff ff ff       	call   8007f3 <strcpy>
	return dst;
}
  80082e:	89 d8                	mov    %ebx,%eax
  800830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	56                   	push   %esi
  800839:	53                   	push   %ebx
  80083a:	8b 75 08             	mov    0x8(%ebp),%esi
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800840:	89 f3                	mov    %esi,%ebx
  800842:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	89 f2                	mov    %esi,%edx
  800847:	eb 0f                	jmp    800858 <strncpy+0x23>
		*dst++ = *src;
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800852:	80 39 01             	cmpb   $0x1,(%ecx)
  800855:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	39 da                	cmp    %ebx,%edx
  80085a:	75 ed                	jne    800849 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	8b 55 10             	mov    0x10(%ebp),%edx
  800870:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 d2                	test   %edx,%edx
  800874:	74 21                	je     800897 <strlcpy+0x35>
  800876:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087a:	89 f2                	mov    %esi,%edx
  80087c:	eb 09                	jmp    800887 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800887:	39 c2                	cmp    %eax,%edx
  800889:	74 09                	je     800894 <strlcpy+0x32>
  80088b:	0f b6 19             	movzbl (%ecx),%ebx
  80088e:	84 db                	test   %bl,%bl
  800890:	75 ec                	jne    80087e <strlcpy+0x1c>
  800892:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800897:	29 f0                	sub    %esi,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strcmp+0x11>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x1c>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 ef                	je     8008a8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d2:	eb 06                	jmp    8008da <strncmp+0x17>
		n--, p++, q++;
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008da:	39 d8                	cmp    %ebx,%eax
  8008dc:	74 15                	je     8008f3 <strncmp+0x30>
  8008de:	0f b6 08             	movzbl (%eax),%ecx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	74 04                	je     8008e9 <strncmp+0x26>
  8008e5:	3a 0a                	cmp    (%edx),%cl
  8008e7:	74 eb                	je     8008d4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 00             	movzbl (%eax),%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
  8008f1:	eb 05                	jmp    8008f8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	eb 07                	jmp    80090e <strchr+0x13>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0f                	je     80091a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f2                	jne    800907 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 03                	jmp    80092b <strfind+0xf>
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092e:	84 d2                	test   %dl,%dl
  800930:	74 04                	je     800936 <strfind+0x1a>
  800932:	38 ca                	cmp    %cl,%dl
  800934:	75 f2                	jne    800928 <strfind+0xc>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 36                	je     80097e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 28                	jne    800978 <memset+0x40>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 23                	jne    800978 <memset+0x40>
		c &= 0xFF;
  800955:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800959:	89 d3                	mov    %edx,%ebx
  80095b:	c1 e3 08             	shl    $0x8,%ebx
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 18             	shl    $0x18,%esi
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 10             	shl    $0x10,%eax
  800968:	09 f0                	or     %esi,%eax
  80096a:	09 c2                	or     %eax,%edx
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800970:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800973:	fc                   	cld    
  800974:	f3 ab                	rep stos %eax,%es:(%edi)
  800976:	eb 06                	jmp    80097e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	fc                   	cld    
  80097c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097e:	89 f8                	mov    %edi,%eax
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 35                	jae    8009cc <memmove+0x47>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	73 2e                	jae    8009cc <memmove+0x47>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	75 13                	jne    8009c0 <memmove+0x3b>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 09                	jmp    8009c9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c0:	83 ef 01             	sub    $0x1,%edi
  8009c3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c6:	fd                   	std    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c9:	fc                   	cld    
  8009ca:	eb 1d                	jmp    8009e9 <memmove+0x64>
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	75 0f                	jne    8009e4 <memmove+0x5f>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0a                	jne    8009e4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009da:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 05                	jmp    8009e9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 87 ff ff ff       	call   800985 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	89 c6                	mov    %eax,%esi
  800a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	eb 1a                	jmp    800a2c <memcmp+0x2c>
		if (*s1 != *s2)
  800a12:	0f b6 08             	movzbl (%eax),%ecx
  800a15:	0f b6 1a             	movzbl (%edx),%ebx
  800a18:	38 d9                	cmp    %bl,%cl
  800a1a:	74 0a                	je     800a26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1c:	0f b6 c1             	movzbl %cl,%eax
  800a1f:	0f b6 db             	movzbl %bl,%ebx
  800a22:	29 d8                	sub    %ebx,%eax
  800a24:	eb 0f                	jmp    800a35 <memcmp+0x35>
		s1++, s2++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	39 f0                	cmp    %esi,%eax
  800a2e:	75 e2                	jne    800a12 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	eb 07                	jmp    800a50 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	74 07                	je     800a54 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	72 f5                	jb     800a49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	eb 03                	jmp    800a67 <strtol+0x11>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	3c 09                	cmp    $0x9,%al
  800a6c:	74 f6                	je     800a64 <strtol+0xe>
  800a6e:	3c 20                	cmp    $0x20,%al
  800a70:	74 f2                	je     800a64 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a72:	3c 2b                	cmp    $0x2b,%al
  800a74:	75 0a                	jne    800a80 <strtol+0x2a>
		s++;
  800a76:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	eb 10                	jmp    800a90 <strtol+0x3a>
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a85:	3c 2d                	cmp    $0x2d,%al
  800a87:	75 07                	jne    800a90 <strtol+0x3a>
		s++, neg = 1;
  800a89:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a8c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	0f 94 c0             	sete   %al
  800a95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9b:	75 19                	jne    800ab6 <strtol+0x60>
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 14                	jne    800ab6 <strtol+0x60>
  800aa2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa6:	0f 85 82 00 00 00    	jne    800b2e <strtol+0xd8>
		s += 2, base = 16;
  800aac:	83 c1 02             	add    $0x2,%ecx
  800aaf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab4:	eb 16                	jmp    800acc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab6:	84 c0                	test   %al,%al
  800ab8:	74 12                	je     800acc <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac2:	75 08                	jne    800acc <strtol+0x76>
		s++, base = 8;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	0f b6 11             	movzbl (%ecx),%edx
  800ad7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 09             	cmp    $0x9,%bl
  800adf:	77 08                	ja     800ae9 <strtol+0x93>
			dig = *s - '0';
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 30             	sub    $0x30,%edx
  800ae7:	eb 22                	jmp    800b0b <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 19             	cmp    $0x19,%bl
  800af1:	77 08                	ja     800afb <strtol+0xa5>
			dig = *s - 'a' + 10;
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 57             	sub    $0x57,%edx
  800af9:	eb 10                	jmp    800b0b <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800afb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 16                	ja     800b1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0e:	7d 0f                	jge    800b1f <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b19:	eb b9                	jmp    800ad4 <strtol+0x7e>
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	eb 02                	jmp    800b21 <strtol+0xcb>
  800b1f:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b25:	74 0d                	je     800b34 <strtol+0xde>
		*endptr = (char *) s;
  800b27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2a:	89 0e                	mov    %ecx,(%esi)
  800b2c:	eb 06                	jmp    800b34 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2e:	84 c0                	test   %al,%al
  800b30:	75 92                	jne    800ac4 <strtol+0x6e>
  800b32:	eb 98                	jmp    800acc <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b34:	f7 da                	neg    %edx
  800b36:	85 ff                	test   %edi,%edi
  800b38:	0f 45 c2             	cmovne %edx,%eax
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 03                	push   $0x3
  800ba5:	68 df 28 80 00       	push   $0x8028df
  800baa:	6a 22                	push   $0x22
  800bac:	68 fc 28 80 00       	push   $0x8028fc
  800bb1:	e8 dd f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_yield>:

void
sys_yield(void)
{      
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
  800be8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bed:	89 d1                	mov    %edx,%ecx
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 d7                	mov    %edx,%edi
  800bf3:	89 d6                	mov    %edx,%esi
  800bf5:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c05:	be 00 00 00 00       	mov    $0x0,%esi
  800c0a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	89 f7                	mov    %esi,%edi
  800c1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 17                	jle    800c37 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 04                	push   $0x4
  800c26:	68 df 28 80 00       	push   $0x8028df
  800c2b:	6a 22                	push   $0x22
  800c2d:	68 fc 28 80 00       	push   $0x8028fc
  800c32:	e8 5c f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c48:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c59:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 17                	jle    800c79 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 05                	push   $0x5
  800c68:	68 df 28 80 00       	push   $0x8028df
  800c6d:	6a 22                	push   $0x22
  800c6f:	68 fc 28 80 00       	push   $0x8028fc
  800c74:	e8 1a f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 06                	push   $0x6
  800caa:	68 df 28 80 00       	push   $0x8028df
  800caf:	6a 22                	push   $0x22
  800cb1:	68 fc 28 80 00       	push   $0x8028fc
  800cb6:	e8 d8 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 08                	push   $0x8
  800cec:	68 df 28 80 00       	push   $0x8028df
  800cf1:	6a 22                	push   $0x22
  800cf3:	68 fc 28 80 00       	push   $0x8028fc
  800cf8:	e8 96 f4 ff ff       	call   800193 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d13:	b8 09 00 00 00       	mov    $0x9,%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 df                	mov    %ebx,%edi
  800d20:	89 de                	mov    %ebx,%esi
  800d22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 09                	push   $0x9
  800d2e:	68 df 28 80 00       	push   $0x8028df
  800d33:	6a 22                	push   $0x22
  800d35:	68 fc 28 80 00       	push   $0x8028fc
  800d3a:	e8 54 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 17                	jle    800d81 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 0a                	push   $0xa
  800d70:	68 df 28 80 00       	push   $0x8028df
  800d75:	6a 22                	push   $0x22
  800d77:	68 fc 28 80 00       	push   $0x8028fc
  800d7c:	e8 12 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d8f:	be 00 00 00 00       	mov    $0x0,%esi
  800d94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800db5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dba:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 cb                	mov    %ecx,%ebx
  800dc4:	89 cf                	mov    %ecx,%edi
  800dc6:	89 ce                	mov    %ecx,%esi
  800dc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	7e 17                	jle    800de5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	6a 0d                	push   $0xd
  800dd4:	68 df 28 80 00       	push   $0x8028df
  800dd9:	6a 22                	push   $0x22
  800ddb:	68 fc 28 80 00       	push   $0x8028fc
  800de0:	e8 ae f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800df3:	ba 00 00 00 00       	mov    $0x0,%edx
  800df8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfd:	89 d1                	mov    %edx,%ecx
  800dff:	89 d3                	mov    %edx,%ebx
  800e01:	89 d7                	mov    %edx,%edi
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_transmit>:

int
sys_transmit(void *addr)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 cb                	mov    %ecx,%ebx
  800e24:	89 cf                	mov    %ecx,%edi
  800e26:	89 ce                	mov    %ecx,%esi
  800e28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	7e 17                	jle    800e45 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	50                   	push   %eax
  800e32:	6a 0f                	push   $0xf
  800e34:	68 df 28 80 00       	push   $0x8028df
  800e39:	6a 22                	push   $0x22
  800e3b:	68 fc 28 80 00       	push   $0x8028fc
  800e40:	e8 4e f3 ff ff       	call   800193 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_recv>:

int
sys_recv(void *addr)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5b:	b8 10 00 00 00       	mov    $0x10,%eax
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 cb                	mov    %ecx,%ebx
  800e65:	89 cf                	mov    %ecx,%edi
  800e67:	89 ce                	mov    %ecx,%esi
  800e69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 10                	push   $0x10
  800e75:	68 df 28 80 00       	push   $0x8028df
  800e7a:	6a 22                	push   $0x22
  800e7c:	68 fc 28 80 00       	push   $0x8028fc
  800e81:	e8 0d f3 ff ff       	call   800193 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	05 00 00 00 30       	add    $0x30000000,%eax
  800e99:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ea9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 16             	shr    $0x16,%edx
  800ec5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 11                	je     800ee2 <fd_alloc+0x2d>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 0c             	shr    $0xc,%edx
  800ed6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	75 09                	jne    800eeb <fd_alloc+0x36>
			*fd_store = fd;
  800ee2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	eb 17                	jmp    800f02 <fd_alloc+0x4d>
  800eeb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef5:	75 c9                	jne    800ec0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f0a:	83 f8 1f             	cmp    $0x1f,%eax
  800f0d:	77 36                	ja     800f45 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0f:	c1 e0 0c             	shl    $0xc,%eax
  800f12:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f17:	89 c2                	mov    %eax,%edx
  800f19:	c1 ea 16             	shr    $0x16,%edx
  800f1c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f23:	f6 c2 01             	test   $0x1,%dl
  800f26:	74 24                	je     800f4c <fd_lookup+0x48>
  800f28:	89 c2                	mov    %eax,%edx
  800f2a:	c1 ea 0c             	shr    $0xc,%edx
  800f2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f34:	f6 c2 01             	test   $0x1,%dl
  800f37:	74 1a                	je     800f53 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3c:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f43:	eb 13                	jmp    800f58 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4a:	eb 0c                	jmp    800f58 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f51:	eb 05                	jmp    800f58 <fd_lookup+0x54>
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	83 ec 08             	sub    $0x8,%esp
  800f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f63:	ba 00 00 00 00       	mov    $0x0,%edx
  800f68:	eb 13                	jmp    800f7d <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f6a:	39 08                	cmp    %ecx,(%eax)
  800f6c:	75 0c                	jne    800f7a <dev_lookup+0x20>
			*dev = devtab[i];
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
  800f78:	eb 36                	jmp    800fb0 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7a:	83 c2 01             	add    $0x1,%edx
  800f7d:	8b 04 95 8c 29 80 00 	mov    0x80298c(,%edx,4),%eax
  800f84:	85 c0                	test   %eax,%eax
  800f86:	75 e2                	jne    800f6a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f88:	a1 40 60 80 00       	mov    0x806040,%eax
  800f8d:	8b 40 48             	mov    0x48(%eax),%eax
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	51                   	push   %ecx
  800f94:	50                   	push   %eax
  800f95:	68 0c 29 80 00       	push   $0x80290c
  800f9a:	e8 cd f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 10             	sub    $0x10,%esp
  800fba:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc3:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fca:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcd:	50                   	push   %eax
  800fce:	e8 31 ff ff ff       	call   800f04 <fd_lookup>
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 05                	js     800fdf <fd_close+0x2d>
	    || fd != fd2)
  800fda:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fdd:	74 0c                	je     800feb <fd_close+0x39>
		return (must_exist ? r : 0);
  800fdf:	84 db                	test   %bl,%bl
  800fe1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe6:	0f 44 c2             	cmove  %edx,%eax
  800fe9:	eb 41                	jmp    80102c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	ff 36                	pushl  (%esi)
  800ff4:	e8 61 ff ff ff       	call   800f5a <dev_lookup>
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	83 c4 10             	add    $0x10,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 1a                	js     80101c <fd_close+0x6a>
		if (dev->dev_close)
  801002:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801005:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801008:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	74 0b                	je     80101c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	56                   	push   %esi
  801015:	ff d0                	call   *%eax
  801017:	89 c3                	mov    %eax,%ebx
  801019:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	56                   	push   %esi
  801020:	6a 00                	push   $0x0
  801022:	e8 5a fc ff ff       	call   800c81 <sys_page_unmap>
	return r;
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	89 d8                	mov    %ebx,%eax
}
  80102c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	ff 75 08             	pushl  0x8(%ebp)
  801040:	e8 bf fe ff ff       	call   800f04 <fd_lookup>
  801045:	89 c2                	mov    %eax,%edx
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	85 d2                	test   %edx,%edx
  80104c:	78 10                	js     80105e <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	6a 01                	push   $0x1
  801053:	ff 75 f4             	pushl  -0xc(%ebp)
  801056:	e8 57 ff ff ff       	call   800fb2 <fd_close>
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <close_all>:

void
close_all(void)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	53                   	push   %ebx
  801064:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801067:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	53                   	push   %ebx
  801070:	e8 be ff ff ff       	call   801033 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801075:	83 c3 01             	add    $0x1,%ebx
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	83 fb 20             	cmp    $0x20,%ebx
  80107e:	75 ec                	jne    80106c <close_all+0xc>
		close(i);
}
  801080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 2c             	sub    $0x2c,%esp
  80108e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	ff 75 08             	pushl  0x8(%ebp)
  801098:	e8 67 fe ff ff       	call   800f04 <fd_lookup>
  80109d:	89 c2                	mov    %eax,%edx
  80109f:	83 c4 08             	add    $0x8,%esp
  8010a2:	85 d2                	test   %edx,%edx
  8010a4:	0f 88 c1 00 00 00    	js     80116b <dup+0xe6>
		return r;
	close(newfdnum);
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	56                   	push   %esi
  8010ae:	e8 80 ff ff ff       	call   801033 <close>

	newfd = INDEX2FD(newfdnum);
  8010b3:	89 f3                	mov    %esi,%ebx
  8010b5:	c1 e3 0c             	shl    $0xc,%ebx
  8010b8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010be:	83 c4 04             	add    $0x4,%esp
  8010c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c4:	e8 d5 fd ff ff       	call   800e9e <fd2data>
  8010c9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010cb:	89 1c 24             	mov    %ebx,(%esp)
  8010ce:	e8 cb fd ff ff       	call   800e9e <fd2data>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d9:	89 f8                	mov    %edi,%eax
  8010db:	c1 e8 16             	shr    $0x16,%eax
  8010de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e5:	a8 01                	test   $0x1,%al
  8010e7:	74 37                	je     801120 <dup+0x9b>
  8010e9:	89 f8                	mov    %edi,%eax
  8010eb:	c1 e8 0c             	shr    $0xc,%eax
  8010ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f5:	f6 c2 01             	test   $0x1,%dl
  8010f8:	74 26                	je     801120 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	25 07 0e 00 00       	and    $0xe07,%eax
  801109:	50                   	push   %eax
  80110a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110d:	6a 00                	push   $0x0
  80110f:	57                   	push   %edi
  801110:	6a 00                	push   $0x0
  801112:	e8 28 fb ff ff       	call   800c3f <sys_page_map>
  801117:	89 c7                	mov    %eax,%edi
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 2e                	js     80114e <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801120:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801123:	89 d0                	mov    %edx,%eax
  801125:	c1 e8 0c             	shr    $0xc,%eax
  801128:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	25 07 0e 00 00       	and    $0xe07,%eax
  801137:	50                   	push   %eax
  801138:	53                   	push   %ebx
  801139:	6a 00                	push   $0x0
  80113b:	52                   	push   %edx
  80113c:	6a 00                	push   $0x0
  80113e:	e8 fc fa ff ff       	call   800c3f <sys_page_map>
  801143:	89 c7                	mov    %eax,%edi
  801145:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801148:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114a:	85 ff                	test   %edi,%edi
  80114c:	79 1d                	jns    80116b <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	53                   	push   %ebx
  801152:	6a 00                	push   $0x0
  801154:	e8 28 fb ff ff       	call   800c81 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801159:	83 c4 08             	add    $0x8,%esp
  80115c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115f:	6a 00                	push   $0x0
  801161:	e8 1b fb ff ff       	call   800c81 <sys_page_unmap>
	return r;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	89 f8                	mov    %edi,%eax
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	53                   	push   %ebx
  801177:	83 ec 14             	sub    $0x14,%esp
  80117a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	53                   	push   %ebx
  801182:	e8 7d fd ff ff       	call   800f04 <fd_lookup>
  801187:	83 c4 08             	add    $0x8,%esp
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 6d                	js     8011fd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801196:	50                   	push   %eax
  801197:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119a:	ff 30                	pushl  (%eax)
  80119c:	e8 b9 fd ff ff       	call   800f5a <dev_lookup>
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 4c                	js     8011f4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ab:	8b 42 08             	mov    0x8(%edx),%eax
  8011ae:	83 e0 03             	and    $0x3,%eax
  8011b1:	83 f8 01             	cmp    $0x1,%eax
  8011b4:	75 21                	jne    8011d7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b6:	a1 40 60 80 00       	mov    0x806040,%eax
  8011bb:	8b 40 48             	mov    0x48(%eax),%eax
  8011be:	83 ec 04             	sub    $0x4,%esp
  8011c1:	53                   	push   %ebx
  8011c2:	50                   	push   %eax
  8011c3:	68 50 29 80 00       	push   $0x802950
  8011c8:	e8 9f f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d5:	eb 26                	jmp    8011fd <read+0x8a>
	}
	if (!dev->dev_read)
  8011d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011da:	8b 40 08             	mov    0x8(%eax),%eax
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	74 17                	je     8011f8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	ff 75 10             	pushl  0x10(%ebp)
  8011e7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ea:	52                   	push   %edx
  8011eb:	ff d0                	call   *%eax
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	eb 09                	jmp    8011fd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	eb 05                	jmp    8011fd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011fd:	89 d0                	mov    %edx,%eax
  8011ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801210:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801213:	bb 00 00 00 00       	mov    $0x0,%ebx
  801218:	eb 21                	jmp    80123b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	29 d8                	sub    %ebx,%eax
  801221:	50                   	push   %eax
  801222:	89 d8                	mov    %ebx,%eax
  801224:	03 45 0c             	add    0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	57                   	push   %edi
  801229:	e8 45 ff ff ff       	call   801173 <read>
		if (m < 0)
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 0c                	js     801241 <readn+0x3d>
			return m;
		if (m == 0)
  801235:	85 c0                	test   %eax,%eax
  801237:	74 06                	je     80123f <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801239:	01 c3                	add    %eax,%ebx
  80123b:	39 f3                	cmp    %esi,%ebx
  80123d:	72 db                	jb     80121a <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80123f:	89 d8                	mov    %ebx,%eax
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	53                   	push   %ebx
  80124d:	83 ec 14             	sub    $0x14,%esp
  801250:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	53                   	push   %ebx
  801258:	e8 a7 fc ff ff       	call   800f04 <fd_lookup>
  80125d:	83 c4 08             	add    $0x8,%esp
  801260:	89 c2                	mov    %eax,%edx
  801262:	85 c0                	test   %eax,%eax
  801264:	78 68                	js     8012ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	ff 30                	pushl  (%eax)
  801272:	e8 e3 fc ff ff       	call   800f5a <dev_lookup>
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 47                	js     8012c5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801285:	75 21                	jne    8012a8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801287:	a1 40 60 80 00       	mov    0x806040,%eax
  80128c:	8b 40 48             	mov    0x48(%eax),%eax
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	53                   	push   %ebx
  801293:	50                   	push   %eax
  801294:	68 6c 29 80 00       	push   $0x80296c
  801299:	e8 ce ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a6:	eb 26                	jmp    8012ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8012ae:	85 d2                	test   %edx,%edx
  8012b0:	74 17                	je     8012c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	ff 75 10             	pushl  0x10(%ebp)
  8012b8:	ff 75 0c             	pushl  0xc(%ebp)
  8012bb:	50                   	push   %eax
  8012bc:	ff d2                	call   *%edx
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	eb 09                	jmp    8012ce <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	eb 05                	jmp    8012ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012ce:	89 d0                	mov    %edx,%eax
  8012d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 1d fc ff ff       	call   800f04 <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 0e                	js     8012fc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	53                   	push   %ebx
  80130d:	e8 f2 fb ff ff       	call   800f04 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	89 c2                	mov    %eax,%edx
  801317:	85 c0                	test   %eax,%eax
  801319:	78 65                	js     801380 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	ff 30                	pushl  (%eax)
  801327:	e8 2e fc ff ff       	call   800f5a <dev_lookup>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 44                	js     801377 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133a:	75 21                	jne    80135d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80133c:	a1 40 60 80 00       	mov    0x806040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801341:	8b 40 48             	mov    0x48(%eax),%eax
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	53                   	push   %ebx
  801348:	50                   	push   %eax
  801349:	68 2c 29 80 00       	push   $0x80292c
  80134e:	e8 19 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135b:	eb 23                	jmp    801380 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80135d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801360:	8b 52 18             	mov    0x18(%edx),%edx
  801363:	85 d2                	test   %edx,%edx
  801365:	74 14                	je     80137b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	ff 75 0c             	pushl  0xc(%ebp)
  80136d:	50                   	push   %eax
  80136e:	ff d2                	call   *%edx
  801370:	89 c2                	mov    %eax,%edx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	eb 09                	jmp    801380 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801377:	89 c2                	mov    %eax,%edx
  801379:	eb 05                	jmp    801380 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80137b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801380:	89 d0                	mov    %edx,%eax
  801382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 14             	sub    $0x14,%esp
  80138e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801391:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	ff 75 08             	pushl  0x8(%ebp)
  801398:	e8 67 fb ff ff       	call   800f04 <fd_lookup>
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	89 c2                	mov    %eax,%edx
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 58                	js     8013fe <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b0:	ff 30                	pushl  (%eax)
  8013b2:	e8 a3 fb ff ff       	call   800f5a <dev_lookup>
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 37                	js     8013f5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c5:	74 32                	je     8013f9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d1:	00 00 00 
	stat->st_isdir = 0;
  8013d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013db:	00 00 00 
	stat->st_dev = dev;
  8013de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013eb:	ff 50 14             	call   *0x14(%eax)
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	eb 09                	jmp    8013fe <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	eb 05                	jmp    8013fe <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013fe:	89 d0                	mov    %edx,%eax
  801400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	6a 00                	push   $0x0
  80140f:	ff 75 08             	pushl  0x8(%ebp)
  801412:	e8 09 02 00 00       	call   801620 <open>
  801417:	89 c3                	mov    %eax,%ebx
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	85 db                	test   %ebx,%ebx
  80141e:	78 1b                	js     80143b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 0c             	pushl  0xc(%ebp)
  801426:	53                   	push   %ebx
  801427:	e8 5b ff ff ff       	call   801387 <fstat>
  80142c:	89 c6                	mov    %eax,%esi
	close(fd);
  80142e:	89 1c 24             	mov    %ebx,(%esp)
  801431:	e8 fd fb ff ff       	call   801033 <close>
	return r;
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	89 f0                	mov    %esi,%eax
}
  80143b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
  801447:	89 c6                	mov    %eax,%esi
  801449:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80144b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801452:	75 12                	jne    801466 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	6a 01                	push   $0x1
  801459:	e8 80 0d 00 00       	call   8021de <ipc_find_env>
  80145e:	a3 00 40 80 00       	mov    %eax,0x804000
  801463:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801466:	6a 07                	push   $0x7
  801468:	68 00 70 80 00       	push   $0x807000
  80146d:	56                   	push   %esi
  80146e:	ff 35 00 40 80 00    	pushl  0x804000
  801474:	e8 11 0d 00 00       	call   80218a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801479:	83 c4 0c             	add    $0xc,%esp
  80147c:	6a 00                	push   $0x0
  80147e:	53                   	push   %ebx
  80147f:	6a 00                	push   $0x0
  801481:	e8 9b 0c 00 00       	call   802121 <ipc_recv>
}
  801486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	8b 40 0c             	mov    0xc(%eax),%eax
  801499:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80149e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a1:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b0:	e8 8d ff ff ff       	call   801442 <fsipc>
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c3:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d2:	e8 6b ff ff ff       	call   801442 <fsipc>
}
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e9:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f8:	e8 45 ff ff ff       	call   801442 <fsipc>
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	85 d2                	test   %edx,%edx
  801501:	78 2c                	js     80152f <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	68 00 70 80 00       	push   $0x807000
  80150b:	53                   	push   %ebx
  80150c:	e8 e2 f2 ff ff       	call   8007f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801511:	a1 80 70 80 00       	mov    0x807080,%eax
  801516:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151c:	a1 84 70 80 00       	mov    0x807084,%eax
  801521:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	57                   	push   %edi
  801538:	56                   	push   %esi
  801539:	53                   	push   %ebx
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	8b 40 0c             	mov    0xc(%eax),%eax
  801546:	a3 00 70 80 00       	mov    %eax,0x807000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80154b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80154e:	eb 3d                	jmp    80158d <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801550:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801556:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80155b:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	57                   	push   %edi
  801562:	53                   	push   %ebx
  801563:	68 08 70 80 00       	push   $0x807008
  801568:	e8 18 f4 ff ff       	call   800985 <memmove>
                fsipcbuf.write.req_n = tmp; 
  80156d:	89 3d 04 70 80 00    	mov    %edi,0x807004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801573:	ba 00 00 00 00       	mov    $0x0,%edx
  801578:	b8 04 00 00 00       	mov    $0x4,%eax
  80157d:	e8 c0 fe ff ff       	call   801442 <fsipc>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 0d                	js     801596 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801589:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80158b:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80158d:	85 f6                	test   %esi,%esi
  80158f:	75 bf                	jne    801550 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801591:	89 d8                	mov    %ebx,%eax
  801593:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801596:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801599:	5b                   	pop    %ebx
  80159a:	5e                   	pop    %esi
  80159b:	5f                   	pop    %edi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ac:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8015b1:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c1:	e8 7c fe ff ff       	call   801442 <fsipc>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 4b                	js     801617 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015cc:	39 c6                	cmp    %eax,%esi
  8015ce:	73 16                	jae    8015e6 <devfile_read+0x48>
  8015d0:	68 a0 29 80 00       	push   $0x8029a0
  8015d5:	68 a7 29 80 00       	push   $0x8029a7
  8015da:	6a 7c                	push   $0x7c
  8015dc:	68 bc 29 80 00       	push   $0x8029bc
  8015e1:	e8 ad eb ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  8015e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015eb:	7e 16                	jle    801603 <devfile_read+0x65>
  8015ed:	68 c7 29 80 00       	push   $0x8029c7
  8015f2:	68 a7 29 80 00       	push   $0x8029a7
  8015f7:	6a 7d                	push   $0x7d
  8015f9:	68 bc 29 80 00       	push   $0x8029bc
  8015fe:	e8 90 eb ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	50                   	push   %eax
  801607:	68 00 70 80 00       	push   $0x807000
  80160c:	ff 75 0c             	pushl  0xc(%ebp)
  80160f:	e8 71 f3 ff ff       	call   800985 <memmove>
	return r;
  801614:	83 c4 10             	add    $0x10,%esp
}
  801617:	89 d8                	mov    %ebx,%eax
  801619:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161c:	5b                   	pop    %ebx
  80161d:	5e                   	pop    %esi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 20             	sub    $0x20,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80162a:	53                   	push   %ebx
  80162b:	e8 8a f1 ff ff       	call   8007ba <strlen>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801638:	7f 67                	jg     8016a1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163a:	83 ec 0c             	sub    $0xc,%esp
  80163d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	e8 6f f8 ff ff       	call   800eb5 <fd_alloc>
  801646:	83 c4 10             	add    $0x10,%esp
		return r;
  801649:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 57                	js     8016a6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	53                   	push   %ebx
  801653:	68 00 70 80 00       	push   $0x807000
  801658:	e8 96 f1 ff ff       	call   8007f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80165d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801660:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801665:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801668:	b8 01 00 00 00       	mov    $0x1,%eax
  80166d:	e8 d0 fd ff ff       	call   801442 <fsipc>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	79 14                	jns    80168f <open+0x6f>
		fd_close(fd, 0);
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	6a 00                	push   $0x0
  801680:	ff 75 f4             	pushl  -0xc(%ebp)
  801683:	e8 2a f9 ff ff       	call   800fb2 <fd_close>
		return r;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	89 da                	mov    %ebx,%edx
  80168d:	eb 17                	jmp    8016a6 <open+0x86>
	}

	return fd2num(fd);
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	ff 75 f4             	pushl  -0xc(%ebp)
  801695:	e8 f4 f7 ff ff       	call   800e8e <fd2num>
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	eb 05                	jmp    8016a6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a6:	89 d0                	mov    %edx,%eax
  8016a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016bd:	e8 80 fd ff ff       	call   801442 <fsipc>
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016c4:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016c8:	7e 37                	jle    801701 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016d3:	ff 70 04             	pushl  0x4(%eax)
  8016d6:	8d 40 10             	lea    0x10(%eax),%eax
  8016d9:	50                   	push   %eax
  8016da:	ff 33                	pushl  (%ebx)
  8016dc:	e8 68 fb ff ff       	call   801249 <write>
		if (result > 0)
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	7e 03                	jle    8016eb <writebuf+0x27>
			b->result += result;
  8016e8:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016eb:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016ee:	74 0d                	je     8016fd <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f7:	0f 4f c2             	cmovg  %edx,%eax
  8016fa:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801700:	c9                   	leave  
  801701:	f3 c3                	repz ret 

00801703 <putch>:

static void
putch(int ch, void *thunk)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80170d:	8b 53 04             	mov    0x4(%ebx),%edx
  801710:	8d 42 01             	lea    0x1(%edx),%eax
  801713:	89 43 04             	mov    %eax,0x4(%ebx)
  801716:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801719:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80171d:	3d 00 01 00 00       	cmp    $0x100,%eax
  801722:	75 0e                	jne    801732 <putch+0x2f>
		writebuf(b);
  801724:	89 d8                	mov    %ebx,%eax
  801726:	e8 99 ff ff ff       	call   8016c4 <writebuf>
		b->idx = 0;
  80172b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801732:	83 c4 04             	add    $0x4,%esp
  801735:	5b                   	pop    %ebx
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80174a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801751:	00 00 00 
	b.result = 0;
  801754:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80175b:	00 00 00 
	b.error = 1;
  80175e:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801765:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801768:	ff 75 10             	pushl  0x10(%ebp)
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801774:	50                   	push   %eax
  801775:	68 03 17 80 00       	push   $0x801703
  80177a:	e8 1f ec ff ff       	call   80039e <vprintfmt>
	if (b.idx > 0)
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801789:	7e 0b                	jle    801796 <vfprintf+0x5e>
		writebuf(&b);
  80178b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801791:	e8 2e ff ff ff       	call   8016c4 <writebuf>

	return (b.result ? b.result : b.error);
  801796:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ad:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017b0:	50                   	push   %eax
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	ff 75 08             	pushl  0x8(%ebp)
  8017b7:	e8 7c ff ff ff       	call   801738 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <printf>:

int
printf(const char *fmt, ...)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017c7:	50                   	push   %eax
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	6a 01                	push   $0x1
  8017cd:	e8 66 ff ff ff       	call   801738 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8017da:	68 d3 29 80 00       	push   $0x8029d3
  8017df:	ff 75 0c             	pushl  0xc(%ebp)
  8017e2:	e8 0c f0 ff ff       	call   8007f3 <strcpy>
	return 0;
}
  8017e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 10             	sub    $0x10,%esp
  8017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017f8:	53                   	push   %ebx
  8017f9:	e8 18 0a 00 00       	call   802216 <pageref>
  8017fe:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801801:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801806:	83 f8 01             	cmp    $0x1,%eax
  801809:	75 10                	jne    80181b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80180b:	83 ec 0c             	sub    $0xc,%esp
  80180e:	ff 73 0c             	pushl  0xc(%ebx)
  801811:	e8 ca 02 00 00       	call   801ae0 <nsipc_close>
  801816:	89 c2                	mov    %eax,%edx
  801818:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80181b:	89 d0                	mov    %edx,%eax
  80181d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801828:	6a 00                	push   $0x0
  80182a:	ff 75 10             	pushl  0x10(%ebp)
  80182d:	ff 75 0c             	pushl  0xc(%ebp)
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	ff 70 0c             	pushl  0xc(%eax)
  801836:	e8 82 03 00 00       	call   801bbd <nsipc_send>
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801843:	6a 00                	push   $0x0
  801845:	ff 75 10             	pushl  0x10(%ebp)
  801848:	ff 75 0c             	pushl  0xc(%ebp)
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	ff 70 0c             	pushl  0xc(%eax)
  801851:	e8 fb 02 00 00       	call   801b51 <nsipc_recv>
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80185e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801861:	52                   	push   %edx
  801862:	50                   	push   %eax
  801863:	e8 9c f6 ff ff       	call   800f04 <fd_lookup>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 17                	js     801886 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801872:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801878:	39 08                	cmp    %ecx,(%eax)
  80187a:	75 05                	jne    801881 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80187c:	8b 40 0c             	mov    0xc(%eax),%eax
  80187f:	eb 05                	jmp    801886 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801881:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	56                   	push   %esi
  80188c:	53                   	push   %ebx
  80188d:	83 ec 1c             	sub    $0x1c,%esp
  801890:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	e8 1a f6 ff ff       	call   800eb5 <fd_alloc>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 1b                	js     8018bf <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018a4:	83 ec 04             	sub    $0x4,%esp
  8018a7:	68 07 04 00 00       	push   $0x407
  8018ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 46 f3 ff ff       	call   800bfc <sys_page_alloc>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	79 10                	jns    8018cf <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	56                   	push   %esi
  8018c3:	e8 18 02 00 00       	call   801ae0 <nsipc_close>
		return r;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	89 d8                	mov    %ebx,%eax
  8018cd:	eb 24                	jmp    8018f3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018cf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018dd:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8018e4:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	52                   	push   %edx
  8018eb:	e8 9e f5 ff ff       	call   800e8e <fd2num>
  8018f0:	83 c4 10             	add    $0x10,%esp
}
  8018f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	e8 50 ff ff ff       	call   801858 <fd2sockid>
		return r;
  801908:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 1f                	js     80192d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80190e:	83 ec 04             	sub    $0x4,%esp
  801911:	ff 75 10             	pushl  0x10(%ebp)
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	50                   	push   %eax
  801918:	e8 1c 01 00 00       	call   801a39 <nsipc_accept>
  80191d:	83 c4 10             	add    $0x10,%esp
		return r;
  801920:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801922:	85 c0                	test   %eax,%eax
  801924:	78 07                	js     80192d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801926:	e8 5d ff ff ff       	call   801888 <alloc_sockfd>
  80192b:	89 c1                	mov    %eax,%ecx
}
  80192d:	89 c8                	mov    %ecx,%eax
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801937:	8b 45 08             	mov    0x8(%ebp),%eax
  80193a:	e8 19 ff ff ff       	call   801858 <fd2sockid>
  80193f:	89 c2                	mov    %eax,%edx
  801941:	85 d2                	test   %edx,%edx
  801943:	78 12                	js     801957 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801945:	83 ec 04             	sub    $0x4,%esp
  801948:	ff 75 10             	pushl  0x10(%ebp)
  80194b:	ff 75 0c             	pushl  0xc(%ebp)
  80194e:	52                   	push   %edx
  80194f:	e8 35 01 00 00       	call   801a89 <nsipc_bind>
  801954:	83 c4 10             	add    $0x10,%esp
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <shutdown>:

int
shutdown(int s, int how)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
  801962:	e8 f1 fe ff ff       	call   801858 <fd2sockid>
  801967:	89 c2                	mov    %eax,%edx
  801969:	85 d2                	test   %edx,%edx
  80196b:	78 0f                	js     80197c <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	ff 75 0c             	pushl  0xc(%ebp)
  801973:	52                   	push   %edx
  801974:	e8 45 01 00 00       	call   801abe <nsipc_shutdown>
  801979:	83 c4 10             	add    $0x10,%esp
}
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801984:	8b 45 08             	mov    0x8(%ebp),%eax
  801987:	e8 cc fe ff ff       	call   801858 <fd2sockid>
  80198c:	89 c2                	mov    %eax,%edx
  80198e:	85 d2                	test   %edx,%edx
  801990:	78 12                	js     8019a4 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	ff 75 10             	pushl  0x10(%ebp)
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	52                   	push   %edx
  80199c:	e8 59 01 00 00       	call   801afa <nsipc_connect>
  8019a1:	83 c4 10             	add    $0x10,%esp
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <listen>:

int
listen(int s, int backlog)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	e8 a4 fe ff ff       	call   801858 <fd2sockid>
  8019b4:	89 c2                	mov    %eax,%edx
  8019b6:	85 d2                	test   %edx,%edx
  8019b8:	78 0f                	js     8019c9 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	ff 75 0c             	pushl  0xc(%ebp)
  8019c0:	52                   	push   %edx
  8019c1:	e8 69 01 00 00       	call   801b2f <nsipc_listen>
  8019c6:	83 c4 10             	add    $0x10,%esp
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019d1:	ff 75 10             	pushl  0x10(%ebp)
  8019d4:	ff 75 0c             	pushl  0xc(%ebp)
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	e8 3c 02 00 00       	call   801c1b <nsipc_socket>
  8019df:	89 c2                	mov    %eax,%edx
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 d2                	test   %edx,%edx
  8019e6:	78 05                	js     8019ed <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8019e8:	e8 9b fe ff ff       	call   801888 <alloc_sockfd>
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	53                   	push   %ebx
  8019f3:	83 ec 04             	sub    $0x4,%esp
  8019f6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019f8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019ff:	75 12                	jne    801a13 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	6a 02                	push   $0x2
  801a06:	e8 d3 07 00 00       	call   8021de <ipc_find_env>
  801a0b:	a3 04 40 80 00       	mov    %eax,0x804004
  801a10:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a13:	6a 07                	push   $0x7
  801a15:	68 00 80 80 00       	push   $0x808000
  801a1a:	53                   	push   %ebx
  801a1b:	ff 35 04 40 80 00    	pushl  0x804004
  801a21:	e8 64 07 00 00       	call   80218a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a26:	83 c4 0c             	add    $0xc,%esp
  801a29:	6a 00                	push   $0x0
  801a2b:	6a 00                	push   $0x0
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 ed 06 00 00       	call   802121 <ipc_recv>
}
  801a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a49:	8b 06                	mov    (%esi),%eax
  801a4b:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a50:	b8 01 00 00 00       	mov    $0x1,%eax
  801a55:	e8 95 ff ff ff       	call   8019ef <nsipc>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 20                	js     801a80 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a60:	83 ec 04             	sub    $0x4,%esp
  801a63:	ff 35 10 80 80 00    	pushl  0x808010
  801a69:	68 00 80 80 00       	push   $0x808000
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	e8 0f ef ff ff       	call   800985 <memmove>
		*addrlen = ret->ret_addrlen;
  801a76:	a1 10 80 80 00       	mov    0x808010,%eax
  801a7b:	89 06                	mov    %eax,(%esi)
  801a7d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801a80:	89 d8                	mov    %ebx,%eax
  801a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 08             	sub    $0x8,%esp
  801a90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a9b:	53                   	push   %ebx
  801a9c:	ff 75 0c             	pushl  0xc(%ebp)
  801a9f:	68 04 80 80 00       	push   $0x808004
  801aa4:	e8 dc ee ff ff       	call   800985 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801aa9:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801aaf:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab4:	e8 36 ff ff ff       	call   8019ef <nsipc>
}
  801ab9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801ad4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ad9:	e8 11 ff ff ff       	call   8019ef <nsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <nsipc_close>:

int
nsipc_close(int s)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801aee:	b8 04 00 00 00       	mov    $0x4,%eax
  801af3:	e8 f7 fe ff ff       	call   8019ef <nsipc>
}
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b0c:	53                   	push   %ebx
  801b0d:	ff 75 0c             	pushl  0xc(%ebp)
  801b10:	68 04 80 80 00       	push   $0x808004
  801b15:	e8 6b ee ff ff       	call   800985 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b1a:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801b20:	b8 05 00 00 00       	mov    $0x5,%eax
  801b25:	e8 c5 fe ff ff       	call   8019ef <nsipc>
}
  801b2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b40:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801b45:	b8 06 00 00 00       	mov    $0x6,%eax
  801b4a:	e8 a0 fe ff ff       	call   8019ef <nsipc>
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801b61:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801b67:	8b 45 14             	mov    0x14(%ebp),%eax
  801b6a:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b6f:	b8 07 00 00 00       	mov    $0x7,%eax
  801b74:	e8 76 fe ff ff       	call   8019ef <nsipc>
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 35                	js     801bb4 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801b7f:	39 f0                	cmp    %esi,%eax
  801b81:	7f 07                	jg     801b8a <nsipc_recv+0x39>
  801b83:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b88:	7e 16                	jle    801ba0 <nsipc_recv+0x4f>
  801b8a:	68 df 29 80 00       	push   $0x8029df
  801b8f:	68 a7 29 80 00       	push   $0x8029a7
  801b94:	6a 62                	push   $0x62
  801b96:	68 f4 29 80 00       	push   $0x8029f4
  801b9b:	e8 f3 e5 ff ff       	call   800193 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	50                   	push   %eax
  801ba4:	68 00 80 80 00       	push   $0x808000
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	e8 d4 ed ff ff       	call   800985 <memmove>
  801bb1:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bca:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801bcf:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bd5:	7e 16                	jle    801bed <nsipc_send+0x30>
  801bd7:	68 00 2a 80 00       	push   $0x802a00
  801bdc:	68 a7 29 80 00       	push   $0x8029a7
  801be1:	6a 6d                	push   $0x6d
  801be3:	68 f4 29 80 00       	push   $0x8029f4
  801be8:	e8 a6 e5 ff ff       	call   800193 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	53                   	push   %ebx
  801bf1:	ff 75 0c             	pushl  0xc(%ebp)
  801bf4:	68 0c 80 80 00       	push   $0x80800c
  801bf9:	e8 87 ed ff ff       	call   800985 <memmove>
	nsipcbuf.send.req_size = size;
  801bfe:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801c04:	8b 45 14             	mov    0x14(%ebp),%eax
  801c07:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801c0c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c11:	e8 d9 fd ff ff       	call   8019ef <nsipc>
}
  801c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    

00801c1b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c21:	8b 45 08             	mov    0x8(%ebp),%eax
  801c24:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801c29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2c:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801c31:	8b 45 10             	mov    0x10(%ebp),%eax
  801c34:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801c39:	b8 09 00 00 00       	mov    $0x9,%eax
  801c3e:	e8 ac fd ff ff       	call   8019ef <nsipc>
}
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 08             	pushl  0x8(%ebp)
  801c53:	e8 46 f2 ff ff       	call   800e9e <fd2data>
  801c58:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c5a:	83 c4 08             	add    $0x8,%esp
  801c5d:	68 0c 2a 80 00       	push   $0x802a0c
  801c62:	53                   	push   %ebx
  801c63:	e8 8b eb ff ff       	call   8007f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c68:	8b 56 04             	mov    0x4(%esi),%edx
  801c6b:	89 d0                	mov    %edx,%eax
  801c6d:	2b 06                	sub    (%esi),%eax
  801c6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c75:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c7c:	00 00 00 
	stat->st_dev = &devpipe;
  801c7f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801c86:	30 80 00 
	return 0;
}
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	53                   	push   %ebx
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c9f:	53                   	push   %ebx
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 da ef ff ff       	call   800c81 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ca7:	89 1c 24             	mov    %ebx,(%esp)
  801caa:	e8 ef f1 ff ff       	call   800e9e <fd2data>
  801caf:	83 c4 08             	add    $0x8,%esp
  801cb2:	50                   	push   %eax
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 c7 ef ff ff       	call   800c81 <sys_page_unmap>
}
  801cba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	57                   	push   %edi
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 1c             	sub    $0x1c,%esp
  801cc8:	89 c6                	mov    %eax,%esi
  801cca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ccd:	a1 40 60 80 00       	mov    0x806040,%eax
  801cd2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	56                   	push   %esi
  801cd9:	e8 38 05 00 00       	call   802216 <pageref>
  801cde:	89 c7                	mov    %eax,%edi
  801ce0:	83 c4 04             	add    $0x4,%esp
  801ce3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce6:	e8 2b 05 00 00       	call   802216 <pageref>
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	39 c7                	cmp    %eax,%edi
  801cf0:	0f 94 c2             	sete   %dl
  801cf3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cf6:	8b 0d 40 60 80 00    	mov    0x806040,%ecx
  801cfc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801cff:	39 fb                	cmp    %edi,%ebx
  801d01:	74 19                	je     801d1c <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801d03:	84 d2                	test   %dl,%dl
  801d05:	74 c6                	je     801ccd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d07:	8b 51 58             	mov    0x58(%ecx),%edx
  801d0a:	50                   	push   %eax
  801d0b:	52                   	push   %edx
  801d0c:	53                   	push   %ebx
  801d0d:	68 13 2a 80 00       	push   $0x802a13
  801d12:	e8 55 e5 ff ff       	call   80026c <cprintf>
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	eb b1                	jmp    801ccd <_pipeisclosed+0xe>
	}
}
  801d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	57                   	push   %edi
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	83 ec 28             	sub    $0x28,%esp
  801d2d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d30:	56                   	push   %esi
  801d31:	e8 68 f1 ff ff       	call   800e9e <fd2data>
  801d36:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d40:	eb 4b                	jmp    801d8d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d42:	89 da                	mov    %ebx,%edx
  801d44:	89 f0                	mov    %esi,%eax
  801d46:	e8 74 ff ff ff       	call   801cbf <_pipeisclosed>
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	75 48                	jne    801d97 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d4f:	e8 89 ee ff ff       	call   800bdd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d54:	8b 43 04             	mov    0x4(%ebx),%eax
  801d57:	8b 0b                	mov    (%ebx),%ecx
  801d59:	8d 51 20             	lea    0x20(%ecx),%edx
  801d5c:	39 d0                	cmp    %edx,%eax
  801d5e:	73 e2                	jae    801d42 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d63:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d67:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	c1 fa 1f             	sar    $0x1f,%edx
  801d6f:	89 d1                	mov    %edx,%ecx
  801d71:	c1 e9 1b             	shr    $0x1b,%ecx
  801d74:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d77:	83 e2 1f             	and    $0x1f,%edx
  801d7a:	29 ca                	sub    %ecx,%edx
  801d7c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d80:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d84:	83 c0 01             	add    $0x1,%eax
  801d87:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8a:	83 c7 01             	add    $0x1,%edi
  801d8d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d90:	75 c2                	jne    801d54 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d92:	8b 45 10             	mov    0x10(%ebp),%eax
  801d95:	eb 05                	jmp    801d9c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	57                   	push   %edi
  801da8:	56                   	push   %esi
  801da9:	53                   	push   %ebx
  801daa:	83 ec 18             	sub    $0x18,%esp
  801dad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801db0:	57                   	push   %edi
  801db1:	e8 e8 f0 ff ff       	call   800e9e <fd2data>
  801db6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dc0:	eb 3d                	jmp    801dff <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dc2:	85 db                	test   %ebx,%ebx
  801dc4:	74 04                	je     801dca <devpipe_read+0x26>
				return i;
  801dc6:	89 d8                	mov    %ebx,%eax
  801dc8:	eb 44                	jmp    801e0e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dca:	89 f2                	mov    %esi,%edx
  801dcc:	89 f8                	mov    %edi,%eax
  801dce:	e8 ec fe ff ff       	call   801cbf <_pipeisclosed>
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	75 32                	jne    801e09 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dd7:	e8 01 ee ff ff       	call   800bdd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ddc:	8b 06                	mov    (%esi),%eax
  801dde:	3b 46 04             	cmp    0x4(%esi),%eax
  801de1:	74 df                	je     801dc2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801de3:	99                   	cltd   
  801de4:	c1 ea 1b             	shr    $0x1b,%edx
  801de7:	01 d0                	add    %edx,%eax
  801de9:	83 e0 1f             	and    $0x1f,%eax
  801dec:	29 d0                	sub    %edx,%eax
  801dee:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801df9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfc:	83 c3 01             	add    $0x1,%ebx
  801dff:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e02:	75 d8                	jne    801ddc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e04:	8b 45 10             	mov    0x10(%ebp),%eax
  801e07:	eb 05                	jmp    801e0e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5f                   	pop    %edi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    

00801e16 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	e8 8e f0 ff ff       	call   800eb5 <fd_alloc>
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	89 c2                	mov    %eax,%edx
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 2c 01 00 00    	js     801f60 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	68 07 04 00 00       	push   $0x407
  801e3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3f:	6a 00                	push   $0x0
  801e41:	e8 b6 ed ff ff       	call   800bfc <sys_page_alloc>
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	89 c2                	mov    %eax,%edx
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	0f 88 0d 01 00 00    	js     801f60 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e59:	50                   	push   %eax
  801e5a:	e8 56 f0 ff ff       	call   800eb5 <fd_alloc>
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	0f 88 e2 00 00 00    	js     801f4e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6c:	83 ec 04             	sub    $0x4,%esp
  801e6f:	68 07 04 00 00       	push   $0x407
  801e74:	ff 75 f0             	pushl  -0x10(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 7e ed ff ff       	call   800bfc <sys_page_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	0f 88 c3 00 00 00    	js     801f4e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e91:	e8 08 f0 ff ff       	call   800e9e <fd2data>
  801e96:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e98:	83 c4 0c             	add    $0xc,%esp
  801e9b:	68 07 04 00 00       	push   $0x407
  801ea0:	50                   	push   %eax
  801ea1:	6a 00                	push   $0x0
  801ea3:	e8 54 ed ff ff       	call   800bfc <sys_page_alloc>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	0f 88 89 00 00 00    	js     801f3e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebb:	e8 de ef ff ff       	call   800e9e <fd2data>
  801ec0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ec7:	50                   	push   %eax
  801ec8:	6a 00                	push   $0x0
  801eca:	56                   	push   %esi
  801ecb:	6a 00                	push   $0x0
  801ecd:	e8 6d ed ff ff       	call   800c3f <sys_page_map>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	83 c4 20             	add    $0x20,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 55                	js     801f30 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801edb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ef0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801efe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f05:	83 ec 0c             	sub    $0xc,%esp
  801f08:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0b:	e8 7e ef ff ff       	call   800e8e <fd2num>
  801f10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f13:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f15:	83 c4 04             	add    $0x4,%esp
  801f18:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1b:	e8 6e ef ff ff       	call   800e8e <fd2num>
  801f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f23:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2e:	eb 30                	jmp    801f60 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f30:	83 ec 08             	sub    $0x8,%esp
  801f33:	56                   	push   %esi
  801f34:	6a 00                	push   $0x0
  801f36:	e8 46 ed ff ff       	call   800c81 <sys_page_unmap>
  801f3b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	ff 75 f0             	pushl  -0x10(%ebp)
  801f44:	6a 00                	push   $0x0
  801f46:	e8 36 ed ff ff       	call   800c81 <sys_page_unmap>
  801f4b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f4e:	83 ec 08             	sub    $0x8,%esp
  801f51:	ff 75 f4             	pushl  -0xc(%ebp)
  801f54:	6a 00                	push   $0x0
  801f56:	e8 26 ed ff ff       	call   800c81 <sys_page_unmap>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f60:	89 d0                	mov    %edx,%eax
  801f62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    

00801f69 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f72:	50                   	push   %eax
  801f73:	ff 75 08             	pushl  0x8(%ebp)
  801f76:	e8 89 ef ff ff       	call   800f04 <fd_lookup>
  801f7b:	89 c2                	mov    %eax,%edx
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	85 d2                	test   %edx,%edx
  801f82:	78 18                	js     801f9c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8a:	e8 0f ef ff ff       	call   800e9e <fd2data>
	return _pipeisclosed(fd, p);
  801f8f:	89 c2                	mov    %eax,%edx
  801f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f94:	e8 26 fd ff ff       	call   801cbf <_pipeisclosed>
  801f99:	83 c4 10             	add    $0x10,%esp
}
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    

00801f9e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fae:	68 2b 2a 80 00       	push   $0x802a2b
  801fb3:	ff 75 0c             	pushl  0xc(%ebp)
  801fb6:	e8 38 e8 ff ff       	call   8007f3 <strcpy>
	return 0;
}
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc0:	c9                   	leave  
  801fc1:	c3                   	ret    

00801fc2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fce:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd9:	eb 2d                	jmp    802008 <devcons_write+0x46>
		m = n - tot;
  801fdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fde:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fe0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fe3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fe8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801feb:	83 ec 04             	sub    $0x4,%esp
  801fee:	53                   	push   %ebx
  801fef:	03 45 0c             	add    0xc(%ebp),%eax
  801ff2:	50                   	push   %eax
  801ff3:	57                   	push   %edi
  801ff4:	e8 8c e9 ff ff       	call   800985 <memmove>
		sys_cputs(buf, m);
  801ff9:	83 c4 08             	add    $0x8,%esp
  801ffc:	53                   	push   %ebx
  801ffd:	57                   	push   %edi
  801ffe:	e8 3d eb ff ff       	call   800b40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802003:	01 de                	add    %ebx,%esi
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	89 f0                	mov    %esi,%eax
  80200a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80200d:	72 cc                	jb     801fdb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80200f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802012:	5b                   	pop    %ebx
  802013:	5e                   	pop    %esi
  802014:	5f                   	pop    %edi
  802015:	5d                   	pop    %ebp
  802016:	c3                   	ret    

00802017 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802022:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802026:	75 07                	jne    80202f <devcons_read+0x18>
  802028:	eb 28                	jmp    802052 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80202a:	e8 ae eb ff ff       	call   800bdd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80202f:	e8 2a eb ff ff       	call   800b5e <sys_cgetc>
  802034:	85 c0                	test   %eax,%eax
  802036:	74 f2                	je     80202a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802038:	85 c0                	test   %eax,%eax
  80203a:	78 16                	js     802052 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80203c:	83 f8 04             	cmp    $0x4,%eax
  80203f:	74 0c                	je     80204d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802041:	8b 55 0c             	mov    0xc(%ebp),%edx
  802044:	88 02                	mov    %al,(%edx)
	return 1;
  802046:	b8 01 00 00 00       	mov    $0x1,%eax
  80204b:	eb 05                	jmp    802052 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80204d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802052:	c9                   	leave  
  802053:	c3                   	ret    

00802054 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80205a:	8b 45 08             	mov    0x8(%ebp),%eax
  80205d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802060:	6a 01                	push   $0x1
  802062:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802065:	50                   	push   %eax
  802066:	e8 d5 ea ff ff       	call   800b40 <sys_cputs>
  80206b:	83 c4 10             	add    $0x10,%esp
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <getchar>:

int
getchar(void)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802076:	6a 01                	push   $0x1
  802078:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	6a 00                	push   $0x0
  80207e:	e8 f0 f0 ff ff       	call   801173 <read>
	if (r < 0)
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	78 0f                	js     802099 <getchar+0x29>
		return r;
	if (r < 1)
  80208a:	85 c0                	test   %eax,%eax
  80208c:	7e 06                	jle    802094 <getchar+0x24>
		return -E_EOF;
	return c;
  80208e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802092:	eb 05                	jmp    802099 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802094:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802099:	c9                   	leave  
  80209a:	c3                   	ret    

0080209b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a4:	50                   	push   %eax
  8020a5:	ff 75 08             	pushl  0x8(%ebp)
  8020a8:	e8 57 ee ff ff       	call   800f04 <fd_lookup>
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	78 11                	js     8020c5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020bd:	39 10                	cmp    %edx,(%eax)
  8020bf:	0f 94 c0             	sete   %al
  8020c2:	0f b6 c0             	movzbl %al,%eax
}
  8020c5:	c9                   	leave  
  8020c6:	c3                   	ret    

008020c7 <opencons>:

int
opencons(void)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d0:	50                   	push   %eax
  8020d1:	e8 df ed ff ff       	call   800eb5 <fd_alloc>
  8020d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8020d9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 3e                	js     80211d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020df:	83 ec 04             	sub    $0x4,%esp
  8020e2:	68 07 04 00 00       	push   $0x407
  8020e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ea:	6a 00                	push   $0x0
  8020ec:	e8 0b eb ff ff       	call   800bfc <sys_page_alloc>
  8020f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8020f4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	78 23                	js     80211d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020fa:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802100:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802103:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802108:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80210f:	83 ec 0c             	sub    $0xc,%esp
  802112:	50                   	push   %eax
  802113:	e8 76 ed ff ff       	call   800e8e <fd2num>
  802118:	89 c2                	mov    %eax,%edx
  80211a:	83 c4 10             	add    $0x10,%esp
}
  80211d:	89 d0                	mov    %edx,%eax
  80211f:	c9                   	leave  
  802120:	c3                   	ret    

00802121 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	56                   	push   %esi
  802125:	53                   	push   %ebx
  802126:	8b 75 08             	mov    0x8(%ebp),%esi
  802129:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80212f:	85 c0                	test   %eax,%eax
  802131:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802136:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802139:	83 ec 0c             	sub    $0xc,%esp
  80213c:	50                   	push   %eax
  80213d:	e8 6a ec ff ff       	call   800dac <sys_ipc_recv>
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	85 c0                	test   %eax,%eax
  802147:	79 16                	jns    80215f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802149:	85 f6                	test   %esi,%esi
  80214b:	74 06                	je     802153 <ipc_recv+0x32>
  80214d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802153:	85 db                	test   %ebx,%ebx
  802155:	74 2c                	je     802183 <ipc_recv+0x62>
  802157:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80215d:	eb 24                	jmp    802183 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80215f:	85 f6                	test   %esi,%esi
  802161:	74 0a                	je     80216d <ipc_recv+0x4c>
  802163:	a1 40 60 80 00       	mov    0x806040,%eax
  802168:	8b 40 74             	mov    0x74(%eax),%eax
  80216b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80216d:	85 db                	test   %ebx,%ebx
  80216f:	74 0a                	je     80217b <ipc_recv+0x5a>
  802171:	a1 40 60 80 00       	mov    0x806040,%eax
  802176:	8b 40 78             	mov    0x78(%eax),%eax
  802179:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80217b:	a1 40 60 80 00       	mov    0x806040,%eax
  802180:	8b 40 70             	mov    0x70(%eax),%eax
}
  802183:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802186:	5b                   	pop    %ebx
  802187:	5e                   	pop    %esi
  802188:	5d                   	pop    %ebp
  802189:	c3                   	ret    

0080218a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	57                   	push   %edi
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	83 ec 0c             	sub    $0xc,%esp
  802193:	8b 7d 08             	mov    0x8(%ebp),%edi
  802196:	8b 75 0c             	mov    0xc(%ebp),%esi
  802199:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80219c:	85 db                	test   %ebx,%ebx
  80219e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021a3:	0f 44 d8             	cmove  %eax,%ebx
  8021a6:	eb 1c                	jmp    8021c4 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8021a8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ab:	74 12                	je     8021bf <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8021ad:	50                   	push   %eax
  8021ae:	68 37 2a 80 00       	push   $0x802a37
  8021b3:	6a 39                	push   $0x39
  8021b5:	68 52 2a 80 00       	push   $0x802a52
  8021ba:	e8 d4 df ff ff       	call   800193 <_panic>
                 sys_yield();
  8021bf:	e8 19 ea ff ff       	call   800bdd <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8021c4:	ff 75 14             	pushl  0x14(%ebp)
  8021c7:	53                   	push   %ebx
  8021c8:	56                   	push   %esi
  8021c9:	57                   	push   %edi
  8021ca:	e8 ba eb ff ff       	call   800d89 <sys_ipc_try_send>
  8021cf:	83 c4 10             	add    $0x10,%esp
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	78 d2                	js     8021a8 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8021d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d9:	5b                   	pop    %ebx
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    

008021de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021e4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021e9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021ec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021f2:	8b 52 50             	mov    0x50(%edx),%edx
  8021f5:	39 ca                	cmp    %ecx,%edx
  8021f7:	75 0d                	jne    802206 <ipc_find_env+0x28>
			return envs[i].env_id;
  8021f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021fc:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802201:	8b 40 08             	mov    0x8(%eax),%eax
  802204:	eb 0e                	jmp    802214 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802206:	83 c0 01             	add    $0x1,%eax
  802209:	3d 00 04 00 00       	cmp    $0x400,%eax
  80220e:	75 d9                	jne    8021e9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802210:	66 b8 00 00          	mov    $0x0,%ax
}
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	c1 e8 16             	shr    $0x16,%eax
  802221:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80222d:	f6 c1 01             	test   $0x1,%cl
  802230:	74 1d                	je     80224f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802232:	c1 ea 0c             	shr    $0xc,%edx
  802235:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80223c:	f6 c2 01             	test   $0x1,%dl
  80223f:	74 0e                	je     80224f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802241:	c1 ea 0c             	shr    $0xc,%edx
  802244:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80224b:	ef 
  80224c:	0f b7 c0             	movzwl %ax,%eax
}
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    
  802251:	66 90                	xchg   %ax,%ax
  802253:	66 90                	xchg   %ax,%ax
  802255:	66 90                	xchg   %ax,%ax
  802257:	66 90                	xchg   %ax,%ax
  802259:	66 90                	xchg   %ax,%ax
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__udivdi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	83 ec 10             	sub    $0x10,%esp
  802266:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80226a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80226e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802272:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802276:	85 d2                	test   %edx,%edx
  802278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80227c:	89 34 24             	mov    %esi,(%esp)
  80227f:	89 c8                	mov    %ecx,%eax
  802281:	75 35                	jne    8022b8 <__udivdi3+0x58>
  802283:	39 f1                	cmp    %esi,%ecx
  802285:	0f 87 bd 00 00 00    	ja     802348 <__udivdi3+0xe8>
  80228b:	85 c9                	test   %ecx,%ecx
  80228d:	89 cd                	mov    %ecx,%ebp
  80228f:	75 0b                	jne    80229c <__udivdi3+0x3c>
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	f7 f1                	div    %ecx
  80229a:	89 c5                	mov    %eax,%ebp
  80229c:	89 f0                	mov    %esi,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	f7 f5                	div    %ebp
  8022a2:	89 c6                	mov    %eax,%esi
  8022a4:	89 f8                	mov    %edi,%eax
  8022a6:	f7 f5                	div    %ebp
  8022a8:	89 f2                	mov    %esi,%edx
  8022aa:	83 c4 10             	add    $0x10,%esp
  8022ad:	5e                   	pop    %esi
  8022ae:	5f                   	pop    %edi
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    
  8022b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	3b 14 24             	cmp    (%esp),%edx
  8022bb:	77 7b                	ja     802338 <__udivdi3+0xd8>
  8022bd:	0f bd f2             	bsr    %edx,%esi
  8022c0:	83 f6 1f             	xor    $0x1f,%esi
  8022c3:	0f 84 97 00 00 00    	je     802360 <__udivdi3+0x100>
  8022c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8022ce:	89 d7                	mov    %edx,%edi
  8022d0:	89 f1                	mov    %esi,%ecx
  8022d2:	29 f5                	sub    %esi,%ebp
  8022d4:	d3 e7                	shl    %cl,%edi
  8022d6:	89 c2                	mov    %eax,%edx
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	d3 ea                	shr    %cl,%edx
  8022dc:	89 f1                	mov    %esi,%ecx
  8022de:	09 fa                	or     %edi,%edx
  8022e0:	8b 3c 24             	mov    (%esp),%edi
  8022e3:	d3 e0                	shl    %cl,%eax
  8022e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022f3:	89 fa                	mov    %edi,%edx
  8022f5:	d3 ea                	shr    %cl,%edx
  8022f7:	89 f1                	mov    %esi,%ecx
  8022f9:	d3 e7                	shl    %cl,%edi
  8022fb:	89 e9                	mov    %ebp,%ecx
  8022fd:	d3 e8                	shr    %cl,%eax
  8022ff:	09 c7                	or     %eax,%edi
  802301:	89 f8                	mov    %edi,%eax
  802303:	f7 74 24 08          	divl   0x8(%esp)
  802307:	89 d5                	mov    %edx,%ebp
  802309:	89 c7                	mov    %eax,%edi
  80230b:	f7 64 24 0c          	mull   0xc(%esp)
  80230f:	39 d5                	cmp    %edx,%ebp
  802311:	89 14 24             	mov    %edx,(%esp)
  802314:	72 11                	jb     802327 <__udivdi3+0xc7>
  802316:	8b 54 24 04          	mov    0x4(%esp),%edx
  80231a:	89 f1                	mov    %esi,%ecx
  80231c:	d3 e2                	shl    %cl,%edx
  80231e:	39 c2                	cmp    %eax,%edx
  802320:	73 5e                	jae    802380 <__udivdi3+0x120>
  802322:	3b 2c 24             	cmp    (%esp),%ebp
  802325:	75 59                	jne    802380 <__udivdi3+0x120>
  802327:	8d 47 ff             	lea    -0x1(%edi),%eax
  80232a:	31 f6                	xor    %esi,%esi
  80232c:	89 f2                	mov    %esi,%edx
  80232e:	83 c4 10             	add    $0x10,%esp
  802331:	5e                   	pop    %esi
  802332:	5f                   	pop    %edi
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    
  802335:	8d 76 00             	lea    0x0(%esi),%esi
  802338:	31 f6                	xor    %esi,%esi
  80233a:	31 c0                	xor    %eax,%eax
  80233c:	89 f2                	mov    %esi,%edx
  80233e:	83 c4 10             	add    $0x10,%esp
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    
  802345:	8d 76 00             	lea    0x0(%esi),%esi
  802348:	89 f2                	mov    %esi,%edx
  80234a:	31 f6                	xor    %esi,%esi
  80234c:	89 f8                	mov    %edi,%eax
  80234e:	f7 f1                	div    %ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	83 c4 10             	add    $0x10,%esp
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802364:	76 0b                	jbe    802371 <__udivdi3+0x111>
  802366:	31 c0                	xor    %eax,%eax
  802368:	3b 14 24             	cmp    (%esp),%edx
  80236b:	0f 83 37 ff ff ff    	jae    8022a8 <__udivdi3+0x48>
  802371:	b8 01 00 00 00       	mov    $0x1,%eax
  802376:	e9 2d ff ff ff       	jmp    8022a8 <__udivdi3+0x48>
  80237b:	90                   	nop
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	89 f8                	mov    %edi,%eax
  802382:	31 f6                	xor    %esi,%esi
  802384:	e9 1f ff ff ff       	jmp    8022a8 <__udivdi3+0x48>
  802389:	66 90                	xchg   %ax,%ax
  80238b:	66 90                	xchg   %ax,%ax
  80238d:	66 90                	xchg   %ax,%ax
  80238f:	90                   	nop

00802390 <__umoddi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	83 ec 20             	sub    $0x20,%esp
  802396:	8b 44 24 34          	mov    0x34(%esp),%eax
  80239a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80239e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a2:	89 c6                	mov    %eax,%esi
  8023a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8023b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	89 c2                	mov    %eax,%edx
  8023c0:	75 1e                	jne    8023e0 <__umoddi3+0x50>
  8023c2:	39 f7                	cmp    %esi,%edi
  8023c4:	76 52                	jbe    802418 <__umoddi3+0x88>
  8023c6:	89 c8                	mov    %ecx,%eax
  8023c8:	89 f2                	mov    %esi,%edx
  8023ca:	f7 f7                	div    %edi
  8023cc:	89 d0                	mov    %edx,%eax
  8023ce:	31 d2                	xor    %edx,%edx
  8023d0:	83 c4 20             	add    $0x20,%esp
  8023d3:	5e                   	pop    %esi
  8023d4:	5f                   	pop    %edi
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    
  8023d7:	89 f6                	mov    %esi,%esi
  8023d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8023e0:	39 f0                	cmp    %esi,%eax
  8023e2:	77 5c                	ja     802440 <__umoddi3+0xb0>
  8023e4:	0f bd e8             	bsr    %eax,%ebp
  8023e7:	83 f5 1f             	xor    $0x1f,%ebp
  8023ea:	75 64                	jne    802450 <__umoddi3+0xc0>
  8023ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8023f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8023f4:	0f 86 f6 00 00 00    	jbe    8024f0 <__umoddi3+0x160>
  8023fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8023fe:	0f 82 ec 00 00 00    	jb     8024f0 <__umoddi3+0x160>
  802404:	8b 44 24 14          	mov    0x14(%esp),%eax
  802408:	8b 54 24 18          	mov    0x18(%esp),%edx
  80240c:	83 c4 20             	add    $0x20,%esp
  80240f:	5e                   	pop    %esi
  802410:	5f                   	pop    %edi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    
  802413:	90                   	nop
  802414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802418:	85 ff                	test   %edi,%edi
  80241a:	89 fd                	mov    %edi,%ebp
  80241c:	75 0b                	jne    802429 <__umoddi3+0x99>
  80241e:	b8 01 00 00 00       	mov    $0x1,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f7                	div    %edi
  802427:	89 c5                	mov    %eax,%ebp
  802429:	8b 44 24 10          	mov    0x10(%esp),%eax
  80242d:	31 d2                	xor    %edx,%edx
  80242f:	f7 f5                	div    %ebp
  802431:	89 c8                	mov    %ecx,%eax
  802433:	f7 f5                	div    %ebp
  802435:	eb 95                	jmp    8023cc <__umoddi3+0x3c>
  802437:	89 f6                	mov    %esi,%esi
  802439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802440:	89 c8                	mov    %ecx,%eax
  802442:	89 f2                	mov    %esi,%edx
  802444:	83 c4 20             	add    $0x20,%esp
  802447:	5e                   	pop    %esi
  802448:	5f                   	pop    %edi
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    
  80244b:	90                   	nop
  80244c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802450:	b8 20 00 00 00       	mov    $0x20,%eax
  802455:	89 e9                	mov    %ebp,%ecx
  802457:	29 e8                	sub    %ebp,%eax
  802459:	d3 e2                	shl    %cl,%edx
  80245b:	89 c7                	mov    %eax,%edi
  80245d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802461:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 c1                	mov    %eax,%ecx
  80246b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80246f:	09 d1                	or     %edx,%ecx
  802471:	89 fa                	mov    %edi,%edx
  802473:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802477:	89 e9                	mov    %ebp,%ecx
  802479:	d3 e0                	shl    %cl,%eax
  80247b:	89 f9                	mov    %edi,%ecx
  80247d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802481:	89 f0                	mov    %esi,%eax
  802483:	d3 e8                	shr    %cl,%eax
  802485:	89 e9                	mov    %ebp,%ecx
  802487:	89 c7                	mov    %eax,%edi
  802489:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80248d:	d3 e6                	shl    %cl,%esi
  80248f:	89 d1                	mov    %edx,%ecx
  802491:	89 fa                	mov    %edi,%edx
  802493:	d3 e8                	shr    %cl,%eax
  802495:	89 e9                	mov    %ebp,%ecx
  802497:	09 f0                	or     %esi,%eax
  802499:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80249d:	f7 74 24 10          	divl   0x10(%esp)
  8024a1:	d3 e6                	shl    %cl,%esi
  8024a3:	89 d1                	mov    %edx,%ecx
  8024a5:	f7 64 24 0c          	mull   0xc(%esp)
  8024a9:	39 d1                	cmp    %edx,%ecx
  8024ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8024af:	89 d7                	mov    %edx,%edi
  8024b1:	89 c6                	mov    %eax,%esi
  8024b3:	72 0a                	jb     8024bf <__umoddi3+0x12f>
  8024b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8024b9:	73 10                	jae    8024cb <__umoddi3+0x13b>
  8024bb:	39 d1                	cmp    %edx,%ecx
  8024bd:	75 0c                	jne    8024cb <__umoddi3+0x13b>
  8024bf:	89 d7                	mov    %edx,%edi
  8024c1:	89 c6                	mov    %eax,%esi
  8024c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8024c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8024cb:	89 ca                	mov    %ecx,%edx
  8024cd:	89 e9                	mov    %ebp,%ecx
  8024cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024d3:	29 f0                	sub    %esi,%eax
  8024d5:	19 fa                	sbb    %edi,%edx
  8024d7:	d3 e8                	shr    %cl,%eax
  8024d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8024de:	89 d7                	mov    %edx,%edi
  8024e0:	d3 e7                	shl    %cl,%edi
  8024e2:	89 e9                	mov    %ebp,%ecx
  8024e4:	09 f8                	or     %edi,%eax
  8024e6:	d3 ea                	shr    %cl,%edx
  8024e8:	83 c4 20             	add    $0x20,%esp
  8024eb:	5e                   	pop    %esi
  8024ec:	5f                   	pop    %edi
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    
  8024ef:	90                   	nop
  8024f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024f4:	29 f9                	sub    %edi,%ecx
  8024f6:	19 c6                	sbb    %eax,%esi
  8024f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8024fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802500:	e9 ff fe ff ff       	jmp    802404 <__umoddi3+0x74>
