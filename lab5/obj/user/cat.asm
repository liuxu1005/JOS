
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
  800048:	e8 56 11 00 00       	call   8011a3 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 d8                	cmp    %ebx,%eax
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 00 20 80 00       	push   $0x802000
  800060:	6a 0d                	push   $0xd
  800062:	68 1b 20 80 00       	push   $0x80201b
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
  80007a:	e8 4e 10 00 00       	call   8010cd <read>
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
  800093:	68 26 20 80 00       	push   $0x802026
  800098:	6a 0f                	push   $0xf
  80009a:	68 1b 20 80 00       	push   $0x80201b
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
  8000b7:	c7 05 00 30 80 00 3b 	movl   $0x80203b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 3f 20 80 00       	push   $0x80203f
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
  8000e8:	e8 8d 14 00 00       	call   80157a <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 47 20 80 00       	push   $0x802047
  800102:	e8 11 16 00 00       	call   801718 <printf>
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
  80011b:	e8 6d 0e 00 00       	call   800f8d <close>
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
  80017f:	e8 36 0e 00 00       	call   800fba <close_all>
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
  8001b1:	68 64 20 80 00       	push   $0x802064
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
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
  8002cf:	e8 6c 1a 00 00       	call   801d40 <__udivdi3>
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
  80030d:	e8 5e 1b 00 00       	call   801e70 <__umoddi3>
  800312:	83 c4 14             	add    $0x14,%esp
  800315:	0f be 80 87 20 80 00 	movsbl 0x802087(%eax),%eax
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
  800411:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
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
  8004d5:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	75 18                	jne    8004f8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	50                   	push   %eax
  8004e1:	68 9f 20 80 00       	push   $0x80209f
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
  8004f9:	68 75 24 80 00       	push   $0x802475
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
  800526:	ba 98 20 80 00       	mov    $0x802098,%edx
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
  800ba5:	68 9f 23 80 00       	push   $0x80239f
  800baa:	6a 23                	push   $0x23
  800bac:	68 bc 23 80 00       	push   $0x8023bc
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
  800c26:	68 9f 23 80 00       	push   $0x80239f
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 bc 23 80 00       	push   $0x8023bc
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
  800c68:	68 9f 23 80 00       	push   $0x80239f
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 bc 23 80 00       	push   $0x8023bc
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
  800caa:	68 9f 23 80 00       	push   $0x80239f
  800caf:	6a 23                	push   $0x23
  800cb1:	68 bc 23 80 00       	push   $0x8023bc
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
  800cec:	68 9f 23 80 00       	push   $0x80239f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 bc 23 80 00       	push   $0x8023bc
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
  800d2e:	68 9f 23 80 00       	push   $0x80239f
  800d33:	6a 23                	push   $0x23
  800d35:	68 bc 23 80 00       	push   $0x8023bc
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
  800d70:	68 9f 23 80 00       	push   $0x80239f
  800d75:	6a 23                	push   $0x23
  800d77:	68 bc 23 80 00       	push   $0x8023bc
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
  800dd4:	68 9f 23 80 00       	push   $0x80239f
  800dd9:	6a 23                	push   $0x23
  800ddb:	68 bc 23 80 00       	push   $0x8023bc
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

00800ded <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	05 00 00 00 30       	add    $0x30000000,%eax
  800df8:	c1 e8 0c             	shr    $0xc,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	c1 ea 16             	shr    $0x16,%edx
  800e24:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2b:	f6 c2 01             	test   $0x1,%dl
  800e2e:	74 11                	je     800e41 <fd_alloc+0x2d>
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	c1 ea 0c             	shr    $0xc,%edx
  800e35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3c:	f6 c2 01             	test   $0x1,%dl
  800e3f:	75 09                	jne    800e4a <fd_alloc+0x36>
			*fd_store = fd;
  800e41:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
  800e48:	eb 17                	jmp    800e61 <fd_alloc+0x4d>
  800e4a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e4f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e54:	75 c9                	jne    800e1f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e56:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e5c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e69:	83 f8 1f             	cmp    $0x1f,%eax
  800e6c:	77 36                	ja     800ea4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e6e:	c1 e0 0c             	shl    $0xc,%eax
  800e71:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 16             	shr    $0x16,%edx
  800e7b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e82:	f6 c2 01             	test   $0x1,%dl
  800e85:	74 24                	je     800eab <fd_lookup+0x48>
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	c1 ea 0c             	shr    $0xc,%edx
  800e8c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e93:	f6 c2 01             	test   $0x1,%dl
  800e96:	74 1a                	je     800eb2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	eb 13                	jmp    800eb7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea9:	eb 0c                	jmp    800eb7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb0:	eb 05                	jmp    800eb7 <fd_lookup+0x54>
  800eb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec2:	ba 4c 24 80 00       	mov    $0x80244c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec7:	eb 13                	jmp    800edc <dev_lookup+0x23>
  800ec9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ecc:	39 08                	cmp    %ecx,(%eax)
  800ece:	75 0c                	jne    800edc <dev_lookup+0x23>
			*dev = devtab[i];
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	eb 2e                	jmp    800f0a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800edc:	8b 02                	mov    (%edx),%eax
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	75 e7                	jne    800ec9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee2:	a1 40 60 80 00       	mov    0x806040,%eax
  800ee7:	8b 40 48             	mov    0x48(%eax),%eax
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	51                   	push   %ecx
  800eee:	50                   	push   %eax
  800eef:	68 cc 23 80 00       	push   $0x8023cc
  800ef4:	e8 73 f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 10             	sub    $0x10,%esp
  800f14:	8b 75 08             	mov    0x8(%ebp),%esi
  800f17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f24:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f27:	50                   	push   %eax
  800f28:	e8 36 ff ff ff       	call   800e63 <fd_lookup>
  800f2d:	83 c4 08             	add    $0x8,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 05                	js     800f39 <fd_close+0x2d>
	    || fd != fd2)
  800f34:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f37:	74 0c                	je     800f45 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f39:	84 db                	test   %bl,%bl
  800f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f40:	0f 44 c2             	cmove  %edx,%eax
  800f43:	eb 41                	jmp    800f86 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 36                	pushl  (%esi)
  800f4e:	e8 66 ff ff ff       	call   800eb9 <dev_lookup>
  800f53:	89 c3                	mov    %eax,%ebx
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 1a                	js     800f76 <fd_close+0x6a>
		if (dev->dev_close)
  800f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	74 0b                	je     800f76 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	56                   	push   %esi
  800f6f:	ff d0                	call   *%eax
  800f71:	89 c3                	mov    %eax,%ebx
  800f73:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	56                   	push   %esi
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 00 fd ff ff       	call   800c81 <sys_page_unmap>
	return r;
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	89 d8                	mov    %ebx,%eax
}
  800f86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	ff 75 08             	pushl  0x8(%ebp)
  800f9a:	e8 c4 fe ff ff       	call   800e63 <fd_lookup>
  800f9f:	89 c2                	mov    %eax,%edx
  800fa1:	83 c4 08             	add    $0x8,%esp
  800fa4:	85 d2                	test   %edx,%edx
  800fa6:	78 10                	js     800fb8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	6a 01                	push   $0x1
  800fad:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb0:	e8 57 ff ff ff       	call   800f0c <fd_close>
  800fb5:	83 c4 10             	add    $0x10,%esp
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <close_all>:

void
close_all(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	53                   	push   %ebx
  800fbe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	53                   	push   %ebx
  800fca:	e8 be ff ff ff       	call   800f8d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcf:	83 c3 01             	add    $0x1,%ebx
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	83 fb 20             	cmp    $0x20,%ebx
  800fd8:	75 ec                	jne    800fc6 <close_all+0xc>
		close(i);
}
  800fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 2c             	sub    $0x2c,%esp
  800fe8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800feb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	ff 75 08             	pushl  0x8(%ebp)
  800ff2:	e8 6c fe ff ff       	call   800e63 <fd_lookup>
  800ff7:	89 c2                	mov    %eax,%edx
  800ff9:	83 c4 08             	add    $0x8,%esp
  800ffc:	85 d2                	test   %edx,%edx
  800ffe:	0f 88 c1 00 00 00    	js     8010c5 <dup+0xe6>
		return r;
	close(newfdnum);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	56                   	push   %esi
  801008:	e8 80 ff ff ff       	call   800f8d <close>

	newfd = INDEX2FD(newfdnum);
  80100d:	89 f3                	mov    %esi,%ebx
  80100f:	c1 e3 0c             	shl    $0xc,%ebx
  801012:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801018:	83 c4 04             	add    $0x4,%esp
  80101b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101e:	e8 da fd ff ff       	call   800dfd <fd2data>
  801023:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801025:	89 1c 24             	mov    %ebx,(%esp)
  801028:	e8 d0 fd ff ff       	call   800dfd <fd2data>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801033:	89 f8                	mov    %edi,%eax
  801035:	c1 e8 16             	shr    $0x16,%eax
  801038:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103f:	a8 01                	test   $0x1,%al
  801041:	74 37                	je     80107a <dup+0x9b>
  801043:	89 f8                	mov    %edi,%eax
  801045:	c1 e8 0c             	shr    $0xc,%eax
  801048:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 26                	je     80107a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801054:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	25 07 0e 00 00       	and    $0xe07,%eax
  801063:	50                   	push   %eax
  801064:	ff 75 d4             	pushl  -0x2c(%ebp)
  801067:	6a 00                	push   $0x0
  801069:	57                   	push   %edi
  80106a:	6a 00                	push   $0x0
  80106c:	e8 ce fb ff ff       	call   800c3f <sys_page_map>
  801071:	89 c7                	mov    %eax,%edi
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 2e                	js     8010a8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107d:	89 d0                	mov    %edx,%eax
  80107f:	c1 e8 0c             	shr    $0xc,%eax
  801082:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	25 07 0e 00 00       	and    $0xe07,%eax
  801091:	50                   	push   %eax
  801092:	53                   	push   %ebx
  801093:	6a 00                	push   $0x0
  801095:	52                   	push   %edx
  801096:	6a 00                	push   $0x0
  801098:	e8 a2 fb ff ff       	call   800c3f <sys_page_map>
  80109d:	89 c7                	mov    %eax,%edi
  80109f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a4:	85 ff                	test   %edi,%edi
  8010a6:	79 1d                	jns    8010c5 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	53                   	push   %ebx
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 ce fb ff ff       	call   800c81 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 c1 fb ff ff       	call   800c81 <sys_page_unmap>
	return r;
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	89 f8                	mov    %edi,%eax
}
  8010c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 14             	sub    $0x14,%esp
  8010d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010da:	50                   	push   %eax
  8010db:	53                   	push   %ebx
  8010dc:	e8 82 fd ff ff       	call   800e63 <fd_lookup>
  8010e1:	83 c4 08             	add    $0x8,%esp
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 6d                	js     801157 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f0:	50                   	push   %eax
  8010f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f4:	ff 30                	pushl  (%eax)
  8010f6:	e8 be fd ff ff       	call   800eb9 <dev_lookup>
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 4c                	js     80114e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801102:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801105:	8b 42 08             	mov    0x8(%edx),%eax
  801108:	83 e0 03             	and    $0x3,%eax
  80110b:	83 f8 01             	cmp    $0x1,%eax
  80110e:	75 21                	jne    801131 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801110:	a1 40 60 80 00       	mov    0x806040,%eax
  801115:	8b 40 48             	mov    0x48(%eax),%eax
  801118:	83 ec 04             	sub    $0x4,%esp
  80111b:	53                   	push   %ebx
  80111c:	50                   	push   %eax
  80111d:	68 10 24 80 00       	push   $0x802410
  801122:	e8 45 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80112f:	eb 26                	jmp    801157 <read+0x8a>
	}
	if (!dev->dev_read)
  801131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801134:	8b 40 08             	mov    0x8(%eax),%eax
  801137:	85 c0                	test   %eax,%eax
  801139:	74 17                	je     801152 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113b:	83 ec 04             	sub    $0x4,%esp
  80113e:	ff 75 10             	pushl  0x10(%ebp)
  801141:	ff 75 0c             	pushl  0xc(%ebp)
  801144:	52                   	push   %edx
  801145:	ff d0                	call   *%eax
  801147:	89 c2                	mov    %eax,%edx
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	eb 09                	jmp    801157 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114e:	89 c2                	mov    %eax,%edx
  801150:	eb 05                	jmp    801157 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801152:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801157:	89 d0                	mov    %edx,%eax
  801159:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801172:	eb 21                	jmp    801195 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	89 f0                	mov    %esi,%eax
  801179:	29 d8                	sub    %ebx,%eax
  80117b:	50                   	push   %eax
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	03 45 0c             	add    0xc(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	57                   	push   %edi
  801183:	e8 45 ff ff ff       	call   8010cd <read>
		if (m < 0)
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 0c                	js     80119b <readn+0x3d>
			return m;
		if (m == 0)
  80118f:	85 c0                	test   %eax,%eax
  801191:	74 06                	je     801199 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801193:	01 c3                	add    %eax,%ebx
  801195:	39 f3                	cmp    %esi,%ebx
  801197:	72 db                	jb     801174 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801199:	89 d8                	mov    %ebx,%eax
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	53                   	push   %ebx
  8011a7:	83 ec 14             	sub    $0x14,%esp
  8011aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b0:	50                   	push   %eax
  8011b1:	53                   	push   %ebx
  8011b2:	e8 ac fc ff ff       	call   800e63 <fd_lookup>
  8011b7:	83 c4 08             	add    $0x8,%esp
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 68                	js     801228 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c6:	50                   	push   %eax
  8011c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ca:	ff 30                	pushl  (%eax)
  8011cc:	e8 e8 fc ff ff       	call   800eb9 <dev_lookup>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 47                	js     80121f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011df:	75 21                	jne    801202 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e1:	a1 40 60 80 00       	mov    0x806040,%eax
  8011e6:	8b 40 48             	mov    0x48(%eax),%eax
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	53                   	push   %ebx
  8011ed:	50                   	push   %eax
  8011ee:	68 2c 24 80 00       	push   $0x80242c
  8011f3:	e8 74 f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801200:	eb 26                	jmp    801228 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801202:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801205:	8b 52 0c             	mov    0xc(%edx),%edx
  801208:	85 d2                	test   %edx,%edx
  80120a:	74 17                	je     801223 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	ff 75 10             	pushl  0x10(%ebp)
  801212:	ff 75 0c             	pushl  0xc(%ebp)
  801215:	50                   	push   %eax
  801216:	ff d2                	call   *%edx
  801218:	89 c2                	mov    %eax,%edx
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	eb 09                	jmp    801228 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121f:	89 c2                	mov    %eax,%edx
  801221:	eb 05                	jmp    801228 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801223:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801228:	89 d0                	mov    %edx,%eax
  80122a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <seek>:

int
seek(int fdnum, off_t offset)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801235:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	ff 75 08             	pushl  0x8(%ebp)
  80123c:	e8 22 fc ff ff       	call   800e63 <fd_lookup>
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 0e                	js     801256 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801248:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 14             	sub    $0x14,%esp
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801262:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	53                   	push   %ebx
  801267:	e8 f7 fb ff ff       	call   800e63 <fd_lookup>
  80126c:	83 c4 08             	add    $0x8,%esp
  80126f:	89 c2                	mov    %eax,%edx
  801271:	85 c0                	test   %eax,%eax
  801273:	78 65                	js     8012da <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127f:	ff 30                	pushl  (%eax)
  801281:	e8 33 fc ff ff       	call   800eb9 <dev_lookup>
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 44                	js     8012d1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801290:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801294:	75 21                	jne    8012b7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801296:	a1 40 60 80 00       	mov    0x806040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80129b:	8b 40 48             	mov    0x48(%eax),%eax
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	53                   	push   %ebx
  8012a2:	50                   	push   %eax
  8012a3:	68 ec 23 80 00       	push   $0x8023ec
  8012a8:	e8 bf ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b5:	eb 23                	jmp    8012da <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ba:	8b 52 18             	mov    0x18(%edx),%edx
  8012bd:	85 d2                	test   %edx,%edx
  8012bf:	74 14                	je     8012d5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c1:	83 ec 08             	sub    $0x8,%esp
  8012c4:	ff 75 0c             	pushl  0xc(%ebp)
  8012c7:	50                   	push   %eax
  8012c8:	ff d2                	call   *%edx
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	eb 09                	jmp    8012da <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	eb 05                	jmp    8012da <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 14             	sub    $0x14,%esp
  8012e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	ff 75 08             	pushl  0x8(%ebp)
  8012f2:	e8 6c fb ff ff       	call   800e63 <fd_lookup>
  8012f7:	83 c4 08             	add    $0x8,%esp
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 58                	js     801358 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	ff 30                	pushl  (%eax)
  80130c:	e8 a8 fb ff ff       	call   800eb9 <dev_lookup>
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 37                	js     80134f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80131f:	74 32                	je     801353 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801321:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801324:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80132b:	00 00 00 
	stat->st_isdir = 0;
  80132e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801335:	00 00 00 
	stat->st_dev = dev;
  801338:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	53                   	push   %ebx
  801342:	ff 75 f0             	pushl  -0x10(%ebp)
  801345:	ff 50 14             	call   *0x14(%eax)
  801348:	89 c2                	mov    %eax,%edx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	eb 09                	jmp    801358 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134f:	89 c2                	mov    %eax,%edx
  801351:	eb 05                	jmp    801358 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801353:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801358:	89 d0                	mov    %edx,%eax
  80135a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	6a 00                	push   $0x0
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 09 02 00 00       	call   80157a <open>
  801371:	89 c3                	mov    %eax,%ebx
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 db                	test   %ebx,%ebx
  801378:	78 1b                	js     801395 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	ff 75 0c             	pushl  0xc(%ebp)
  801380:	53                   	push   %ebx
  801381:	e8 5b ff ff ff       	call   8012e1 <fstat>
  801386:	89 c6                	mov    %eax,%esi
	close(fd);
  801388:	89 1c 24             	mov    %ebx,(%esp)
  80138b:	e8 fd fb ff ff       	call   800f8d <close>
	return r;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	89 f0                	mov    %esi,%eax
}
  801395:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	89 c6                	mov    %eax,%esi
  8013a3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ac:	75 12                	jne    8013c0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	6a 01                	push   $0x1
  8013b3:	e8 0f 09 00 00       	call   801cc7 <ipc_find_env>
  8013b8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013bd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c0:	6a 07                	push   $0x7
  8013c2:	68 00 70 80 00       	push   $0x807000
  8013c7:	56                   	push   %esi
  8013c8:	ff 35 00 40 80 00    	pushl  0x804000
  8013ce:	e8 a0 08 00 00       	call   801c73 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d3:	83 c4 0c             	add    $0xc,%esp
  8013d6:	6a 00                	push   $0x0
  8013d8:	53                   	push   %ebx
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 2a 08 00 00       	call   801c0a <ipc_recv>
}
  8013e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f3:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8013f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fb:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801400:	ba 00 00 00 00       	mov    $0x0,%edx
  801405:	b8 02 00 00 00       	mov    $0x2,%eax
  80140a:	e8 8d ff ff ff       	call   80139c <fsipc>
}
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	8b 40 0c             	mov    0xc(%eax),%eax
  80141d:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801422:	ba 00 00 00 00       	mov    $0x0,%edx
  801427:	b8 06 00 00 00       	mov    $0x6,%eax
  80142c:	e8 6b ff ff ff       	call   80139c <fsipc>
}
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	53                   	push   %ebx
  801437:	83 ec 04             	sub    $0x4,%esp
  80143a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
  801440:	8b 40 0c             	mov    0xc(%eax),%eax
  801443:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801448:	ba 00 00 00 00       	mov    $0x0,%edx
  80144d:	b8 05 00 00 00       	mov    $0x5,%eax
  801452:	e8 45 ff ff ff       	call   80139c <fsipc>
  801457:	89 c2                	mov    %eax,%edx
  801459:	85 d2                	test   %edx,%edx
  80145b:	78 2c                	js     801489 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	68 00 70 80 00       	push   $0x807000
  801465:	53                   	push   %ebx
  801466:	e8 88 f3 ff ff       	call   8007f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146b:	a1 80 70 80 00       	mov    0x807080,%eax
  801470:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801476:	a1 84 70 80 00       	mov    0x807084,%eax
  80147b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 70 80 00       	mov    %eax,0x807000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014a8:	eb 3d                	jmp    8014e7 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014aa:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014b0:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014b5:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	57                   	push   %edi
  8014bc:	53                   	push   %ebx
  8014bd:	68 08 70 80 00       	push   $0x807008
  8014c2:	e8 be f4 ff ff       	call   800985 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8014c7:	89 3d 04 70 80 00    	mov    %edi,0x807004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d7:	e8 c0 fe ff ff       	call   80139c <fsipc>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 0d                	js     8014f0 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8014e3:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8014e5:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014e7:	85 f6                	test   %esi,%esi
  8014e9:	75 bf                	jne    8014aa <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8014eb:	89 d8                	mov    %ebx,%eax
  8014ed:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8014f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5e                   	pop    %esi
  8014f5:	5f                   	pop    %edi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	56                   	push   %esi
  8014fc:	53                   	push   %ebx
  8014fd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	8b 40 0c             	mov    0xc(%eax),%eax
  801506:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80150b:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 03 00 00 00       	mov    $0x3,%eax
  80151b:	e8 7c fe ff ff       	call   80139c <fsipc>
  801520:	89 c3                	mov    %eax,%ebx
  801522:	85 c0                	test   %eax,%eax
  801524:	78 4b                	js     801571 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801526:	39 c6                	cmp    %eax,%esi
  801528:	73 16                	jae    801540 <devfile_read+0x48>
  80152a:	68 5c 24 80 00       	push   $0x80245c
  80152f:	68 63 24 80 00       	push   $0x802463
  801534:	6a 7c                	push   $0x7c
  801536:	68 78 24 80 00       	push   $0x802478
  80153b:	e8 53 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  801540:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801545:	7e 16                	jle    80155d <devfile_read+0x65>
  801547:	68 83 24 80 00       	push   $0x802483
  80154c:	68 63 24 80 00       	push   $0x802463
  801551:	6a 7d                	push   $0x7d
  801553:	68 78 24 80 00       	push   $0x802478
  801558:	e8 36 ec ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	50                   	push   %eax
  801561:	68 00 70 80 00       	push   $0x807000
  801566:	ff 75 0c             	pushl  0xc(%ebp)
  801569:	e8 17 f4 ff ff       	call   800985 <memmove>
	return r;
  80156e:	83 c4 10             	add    $0x10,%esp
}
  801571:	89 d8                	mov    %ebx,%eax
  801573:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    

0080157a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 20             	sub    $0x20,%esp
  801581:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801584:	53                   	push   %ebx
  801585:	e8 30 f2 ff ff       	call   8007ba <strlen>
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801592:	7f 67                	jg     8015fb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	e8 74 f8 ff ff       	call   800e14 <fd_alloc>
  8015a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 57                	js     801600 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	68 00 70 80 00       	push   $0x807000
  8015b2:	e8 3c f2 ff ff       	call   8007f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ba:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c7:	e8 d0 fd ff ff       	call   80139c <fsipc>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	79 14                	jns    8015e9 <open+0x6f>
		fd_close(fd, 0);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	6a 00                	push   $0x0
  8015da:	ff 75 f4             	pushl  -0xc(%ebp)
  8015dd:	e8 2a f9 ff ff       	call   800f0c <fd_close>
		return r;
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	89 da                	mov    %ebx,%edx
  8015e7:	eb 17                	jmp    801600 <open+0x86>
	}

	return fd2num(fd);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ef:	e8 f9 f7 ff ff       	call   800ded <fd2num>
  8015f4:	89 c2                	mov    %eax,%edx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	eb 05                	jmp    801600 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015fb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801600:	89 d0                	mov    %edx,%eax
  801602:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80160d:	ba 00 00 00 00       	mov    $0x0,%edx
  801612:	b8 08 00 00 00       	mov    $0x8,%eax
  801617:	e8 80 fd ff ff       	call   80139c <fsipc>
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80161e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801622:	7e 37                	jle    80165b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80162d:	ff 70 04             	pushl  0x4(%eax)
  801630:	8d 40 10             	lea    0x10(%eax),%eax
  801633:	50                   	push   %eax
  801634:	ff 33                	pushl  (%ebx)
  801636:	e8 68 fb ff ff       	call   8011a3 <write>
		if (result > 0)
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	7e 03                	jle    801645 <writebuf+0x27>
			b->result += result;
  801642:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801645:	39 43 04             	cmp    %eax,0x4(%ebx)
  801648:	74 0d                	je     801657 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80164a:	85 c0                	test   %eax,%eax
  80164c:	ba 00 00 00 00       	mov    $0x0,%edx
  801651:	0f 4f c2             	cmovg  %edx,%eax
  801654:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	f3 c3                	repz ret 

0080165d <putch>:

static void
putch(int ch, void *thunk)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	53                   	push   %ebx
  801661:	83 ec 04             	sub    $0x4,%esp
  801664:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801667:	8b 53 04             	mov    0x4(%ebx),%edx
  80166a:	8d 42 01             	lea    0x1(%edx),%eax
  80166d:	89 43 04             	mov    %eax,0x4(%ebx)
  801670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801673:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801677:	3d 00 01 00 00       	cmp    $0x100,%eax
  80167c:	75 0e                	jne    80168c <putch+0x2f>
		writebuf(b);
  80167e:	89 d8                	mov    %ebx,%eax
  801680:	e8 99 ff ff ff       	call   80161e <writebuf>
		b->idx = 0;
  801685:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80168c:	83 c4 04             	add    $0x4,%esp
  80168f:	5b                   	pop    %ebx
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016a4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016ab:	00 00 00 
	b.result = 0;
  8016ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016b5:	00 00 00 
	b.error = 1;
  8016b8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016bf:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016c2:	ff 75 10             	pushl  0x10(%ebp)
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	68 5d 16 80 00       	push   $0x80165d
  8016d4:	e8 c5 ec ff ff       	call   80039e <vprintfmt>
	if (b.idx > 0)
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016e3:	7e 0b                	jle    8016f0 <vfprintf+0x5e>
		writebuf(&b);
  8016e5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016eb:	e8 2e ff ff ff       	call   80161e <writebuf>

	return (b.result ? b.result : b.error);
  8016f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801707:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80170a:	50                   	push   %eax
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 7c ff ff ff       	call   801692 <vfprintf>
	va_end(ap);

	return cnt;
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <printf>:

int
printf(const char *fmt, ...)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80171e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801721:	50                   	push   %eax
  801722:	ff 75 08             	pushl  0x8(%ebp)
  801725:	6a 01                	push   $0x1
  801727:	e8 66 ff ff ff       	call   801692 <vfprintf>
	va_end(ap);

	return cnt;
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801736:	83 ec 0c             	sub    $0xc,%esp
  801739:	ff 75 08             	pushl  0x8(%ebp)
  80173c:	e8 bc f6 ff ff       	call   800dfd <fd2data>
  801741:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801743:	83 c4 08             	add    $0x8,%esp
  801746:	68 8f 24 80 00       	push   $0x80248f
  80174b:	53                   	push   %ebx
  80174c:	e8 a2 f0 ff ff       	call   8007f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801751:	8b 56 04             	mov    0x4(%esi),%edx
  801754:	89 d0                	mov    %edx,%eax
  801756:	2b 06                	sub    (%esi),%eax
  801758:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80175e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801765:	00 00 00 
	stat->st_dev = &devpipe;
  801768:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80176f:	30 80 00 
	return 0;
}
  801772:	b8 00 00 00 00       	mov    $0x0,%eax
  801777:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177a:	5b                   	pop    %ebx
  80177b:	5e                   	pop    %esi
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801788:	53                   	push   %ebx
  801789:	6a 00                	push   $0x0
  80178b:	e8 f1 f4 ff ff       	call   800c81 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801790:	89 1c 24             	mov    %ebx,(%esp)
  801793:	e8 65 f6 ff ff       	call   800dfd <fd2data>
  801798:	83 c4 08             	add    $0x8,%esp
  80179b:	50                   	push   %eax
  80179c:	6a 00                	push   $0x0
  80179e:	e8 de f4 ff ff       	call   800c81 <sys_page_unmap>
}
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	57                   	push   %edi
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 1c             	sub    $0x1c,%esp
  8017b1:	89 c6                	mov    %eax,%esi
  8017b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017b6:	a1 40 60 80 00       	mov    0x806040,%eax
  8017bb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	56                   	push   %esi
  8017c2:	e8 38 05 00 00       	call   801cff <pageref>
  8017c7:	89 c7                	mov    %eax,%edi
  8017c9:	83 c4 04             	add    $0x4,%esp
  8017cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017cf:	e8 2b 05 00 00       	call   801cff <pageref>
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	39 c7                	cmp    %eax,%edi
  8017d9:	0f 94 c2             	sete   %dl
  8017dc:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8017df:	8b 0d 40 60 80 00    	mov    0x806040,%ecx
  8017e5:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8017e8:	39 fb                	cmp    %edi,%ebx
  8017ea:	74 19                	je     801805 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8017ec:	84 d2                	test   %dl,%dl
  8017ee:	74 c6                	je     8017b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017f0:	8b 51 58             	mov    0x58(%ecx),%edx
  8017f3:	50                   	push   %eax
  8017f4:	52                   	push   %edx
  8017f5:	53                   	push   %ebx
  8017f6:	68 96 24 80 00       	push   $0x802496
  8017fb:	e8 6c ea ff ff       	call   80026c <cprintf>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	eb b1                	jmp    8017b6 <_pipeisclosed+0xe>
	}
}
  801805:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5f                   	pop    %edi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	83 ec 28             	sub    $0x28,%esp
  801816:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801819:	56                   	push   %esi
  80181a:	e8 de f5 ff ff       	call   800dfd <fd2data>
  80181f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	bf 00 00 00 00       	mov    $0x0,%edi
  801829:	eb 4b                	jmp    801876 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80182b:	89 da                	mov    %ebx,%edx
  80182d:	89 f0                	mov    %esi,%eax
  80182f:	e8 74 ff ff ff       	call   8017a8 <_pipeisclosed>
  801834:	85 c0                	test   %eax,%eax
  801836:	75 48                	jne    801880 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801838:	e8 a0 f3 ff ff       	call   800bdd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80183d:	8b 43 04             	mov    0x4(%ebx),%eax
  801840:	8b 0b                	mov    (%ebx),%ecx
  801842:	8d 51 20             	lea    0x20(%ecx),%edx
  801845:	39 d0                	cmp    %edx,%eax
  801847:	73 e2                	jae    80182b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801850:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801853:	89 c2                	mov    %eax,%edx
  801855:	c1 fa 1f             	sar    $0x1f,%edx
  801858:	89 d1                	mov    %edx,%ecx
  80185a:	c1 e9 1b             	shr    $0x1b,%ecx
  80185d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801860:	83 e2 1f             	and    $0x1f,%edx
  801863:	29 ca                	sub    %ecx,%edx
  801865:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801869:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80186d:	83 c0 01             	add    $0x1,%eax
  801870:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801873:	83 c7 01             	add    $0x1,%edi
  801876:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801879:	75 c2                	jne    80183d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80187b:	8b 45 10             	mov    0x10(%ebp),%eax
  80187e:	eb 05                	jmp    801885 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801880:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801885:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5f                   	pop    %edi
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	57                   	push   %edi
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	83 ec 18             	sub    $0x18,%esp
  801896:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801899:	57                   	push   %edi
  80189a:	e8 5e f5 ff ff       	call   800dfd <fd2data>
  80189f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a9:	eb 3d                	jmp    8018e8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018ab:	85 db                	test   %ebx,%ebx
  8018ad:	74 04                	je     8018b3 <devpipe_read+0x26>
				return i;
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	eb 44                	jmp    8018f7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018b3:	89 f2                	mov    %esi,%edx
  8018b5:	89 f8                	mov    %edi,%eax
  8018b7:	e8 ec fe ff ff       	call   8017a8 <_pipeisclosed>
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	75 32                	jne    8018f2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018c0:	e8 18 f3 ff ff       	call   800bdd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018c5:	8b 06                	mov    (%esi),%eax
  8018c7:	3b 46 04             	cmp    0x4(%esi),%eax
  8018ca:	74 df                	je     8018ab <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018cc:	99                   	cltd   
  8018cd:	c1 ea 1b             	shr    $0x1b,%edx
  8018d0:	01 d0                	add    %edx,%eax
  8018d2:	83 e0 1f             	and    $0x1f,%eax
  8018d5:	29 d0                	sub    %edx,%eax
  8018d7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018df:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018e2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e5:	83 c3 01             	add    $0x1,%ebx
  8018e8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018eb:	75 d8                	jne    8018c5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f0:	eb 05                	jmp    8018f7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5f                   	pop    %edi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	e8 04 f5 ff ff       	call   800e14 <fd_alloc>
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	89 c2                	mov    %eax,%edx
  801915:	85 c0                	test   %eax,%eax
  801917:	0f 88 2c 01 00 00    	js     801a49 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	68 07 04 00 00       	push   $0x407
  801925:	ff 75 f4             	pushl  -0xc(%ebp)
  801928:	6a 00                	push   $0x0
  80192a:	e8 cd f2 ff ff       	call   800bfc <sys_page_alloc>
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	89 c2                	mov    %eax,%edx
  801934:	85 c0                	test   %eax,%eax
  801936:	0f 88 0d 01 00 00    	js     801a49 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80193c:	83 ec 0c             	sub    $0xc,%esp
  80193f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801942:	50                   	push   %eax
  801943:	e8 cc f4 ff ff       	call   800e14 <fd_alloc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	0f 88 e2 00 00 00    	js     801a37 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	68 07 04 00 00       	push   $0x407
  80195d:	ff 75 f0             	pushl  -0x10(%ebp)
  801960:	6a 00                	push   $0x0
  801962:	e8 95 f2 ff ff       	call   800bfc <sys_page_alloc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	0f 88 c3 00 00 00    	js     801a37 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 f4             	pushl  -0xc(%ebp)
  80197a:	e8 7e f4 ff ff       	call   800dfd <fd2data>
  80197f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801981:	83 c4 0c             	add    $0xc,%esp
  801984:	68 07 04 00 00       	push   $0x407
  801989:	50                   	push   %eax
  80198a:	6a 00                	push   $0x0
  80198c:	e8 6b f2 ff ff       	call   800bfc <sys_page_alloc>
  801991:	89 c3                	mov    %eax,%ebx
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	85 c0                	test   %eax,%eax
  801998:	0f 88 89 00 00 00    	js     801a27 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a4:	e8 54 f4 ff ff       	call   800dfd <fd2data>
  8019a9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019b0:	50                   	push   %eax
  8019b1:	6a 00                	push   $0x0
  8019b3:	56                   	push   %esi
  8019b4:	6a 00                	push   $0x0
  8019b6:	e8 84 f2 ff ff       	call   800c3f <sys_page_map>
  8019bb:	89 c3                	mov    %eax,%ebx
  8019bd:	83 c4 20             	add    $0x20,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 55                	js     801a19 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019c4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019d9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	e8 f4 f3 ff ff       	call   800ded <fd2num>
  8019f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019fe:	83 c4 04             	add    $0x4,%esp
  801a01:	ff 75 f0             	pushl  -0x10(%ebp)
  801a04:	e8 e4 f3 ff ff       	call   800ded <fd2num>
  801a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a0c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	ba 00 00 00 00       	mov    $0x0,%edx
  801a17:	eb 30                	jmp    801a49 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a19:	83 ec 08             	sub    $0x8,%esp
  801a1c:	56                   	push   %esi
  801a1d:	6a 00                	push   $0x0
  801a1f:	e8 5d f2 ff ff       	call   800c81 <sys_page_unmap>
  801a24:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 4d f2 ff ff       	call   800c81 <sys_page_unmap>
  801a34:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3d:	6a 00                	push   $0x0
  801a3f:	e8 3d f2 ff ff       	call   800c81 <sys_page_unmap>
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a49:	89 d0                	mov    %edx,%eax
  801a4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5b:	50                   	push   %eax
  801a5c:	ff 75 08             	pushl  0x8(%ebp)
  801a5f:	e8 ff f3 ff ff       	call   800e63 <fd_lookup>
  801a64:	89 c2                	mov    %eax,%edx
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	85 d2                	test   %edx,%edx
  801a6b:	78 18                	js     801a85 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	ff 75 f4             	pushl  -0xc(%ebp)
  801a73:	e8 85 f3 ff ff       	call   800dfd <fd2data>
	return _pipeisclosed(fd, p);
  801a78:	89 c2                	mov    %eax,%edx
  801a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7d:	e8 26 fd ff ff       	call   8017a8 <_pipeisclosed>
  801a82:	83 c4 10             	add    $0x10,%esp
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a97:	68 ae 24 80 00       	push   $0x8024ae
  801a9c:	ff 75 0c             	pushl  0xc(%ebp)
  801a9f:	e8 4f ed ff ff       	call   8007f3 <strcpy>
	return 0;
}
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801abc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ac2:	eb 2d                	jmp    801af1 <devcons_write+0x46>
		m = n - tot;
  801ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ac7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ac9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801acc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ad1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ad4:	83 ec 04             	sub    $0x4,%esp
  801ad7:	53                   	push   %ebx
  801ad8:	03 45 0c             	add    0xc(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	57                   	push   %edi
  801add:	e8 a3 ee ff ff       	call   800985 <memmove>
		sys_cputs(buf, m);
  801ae2:	83 c4 08             	add    $0x8,%esp
  801ae5:	53                   	push   %ebx
  801ae6:	57                   	push   %edi
  801ae7:	e8 54 f0 ff ff       	call   800b40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aec:	01 de                	add    %ebx,%esi
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	89 f0                	mov    %esi,%eax
  801af3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801af6:	72 cc                	jb     801ac4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5f                   	pop    %edi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801b0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b0f:	75 07                	jne    801b18 <devcons_read+0x18>
  801b11:	eb 28                	jmp    801b3b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b13:	e8 c5 f0 ff ff       	call   800bdd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b18:	e8 41 f0 ff ff       	call   800b5e <sys_cgetc>
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	74 f2                	je     801b13 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 16                	js     801b3b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b25:	83 f8 04             	cmp    $0x4,%eax
  801b28:	74 0c                	je     801b36 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2d:	88 02                	mov    %al,(%edx)
	return 1;
  801b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b34:	eb 05                	jmp    801b3b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b49:	6a 01                	push   $0x1
  801b4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b4e:	50                   	push   %eax
  801b4f:	e8 ec ef ff ff       	call   800b40 <sys_cputs>
  801b54:	83 c4 10             	add    $0x10,%esp
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <getchar>:

int
getchar(void)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b5f:	6a 01                	push   $0x1
  801b61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b64:	50                   	push   %eax
  801b65:	6a 00                	push   $0x0
  801b67:	e8 61 f5 ff ff       	call   8010cd <read>
	if (r < 0)
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 0f                	js     801b82 <getchar+0x29>
		return r;
	if (r < 1)
  801b73:	85 c0                	test   %eax,%eax
  801b75:	7e 06                	jle    801b7d <getchar+0x24>
		return -E_EOF;
	return c;
  801b77:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b7b:	eb 05                	jmp    801b82 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b7d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	ff 75 08             	pushl  0x8(%ebp)
  801b91:	e8 cd f2 ff ff       	call   800e63 <fd_lookup>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 11                	js     801bae <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba6:	39 10                	cmp    %edx,(%eax)
  801ba8:	0f 94 c0             	sete   %al
  801bab:	0f b6 c0             	movzbl %al,%eax
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <opencons>:

int
opencons(void)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb9:	50                   	push   %eax
  801bba:	e8 55 f2 ff ff       	call   800e14 <fd_alloc>
  801bbf:	83 c4 10             	add    $0x10,%esp
		return r;
  801bc2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 3e                	js     801c06 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bc8:	83 ec 04             	sub    $0x4,%esp
  801bcb:	68 07 04 00 00       	push   $0x407
  801bd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd3:	6a 00                	push   $0x0
  801bd5:	e8 22 f0 ff ff       	call   800bfc <sys_page_alloc>
  801bda:	83 c4 10             	add    $0x10,%esp
		return r;
  801bdd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	78 23                	js     801c06 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801be3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	50                   	push   %eax
  801bfc:	e8 ec f1 ff ff       	call   800ded <fd2num>
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	83 c4 10             	add    $0x10,%esp
}
  801c06:	89 d0                	mov    %edx,%eax
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c1f:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	50                   	push   %eax
  801c26:	e8 81 f1 ff ff       	call   800dac <sys_ipc_recv>
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	79 16                	jns    801c48 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801c32:	85 f6                	test   %esi,%esi
  801c34:	74 06                	je     801c3c <ipc_recv+0x32>
  801c36:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801c3c:	85 db                	test   %ebx,%ebx
  801c3e:	74 2c                	je     801c6c <ipc_recv+0x62>
  801c40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c46:	eb 24                	jmp    801c6c <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801c48:	85 f6                	test   %esi,%esi
  801c4a:	74 0a                	je     801c56 <ipc_recv+0x4c>
  801c4c:	a1 40 60 80 00       	mov    0x806040,%eax
  801c51:	8b 40 74             	mov    0x74(%eax),%eax
  801c54:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801c56:	85 db                	test   %ebx,%ebx
  801c58:	74 0a                	je     801c64 <ipc_recv+0x5a>
  801c5a:	a1 40 60 80 00       	mov    0x806040,%eax
  801c5f:	8b 40 78             	mov    0x78(%eax),%eax
  801c62:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801c64:	a1 40 60 80 00       	mov    0x806040,%eax
  801c69:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	57                   	push   %edi
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801c85:	85 db                	test   %ebx,%ebx
  801c87:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c8c:	0f 44 d8             	cmove  %eax,%ebx
  801c8f:	eb 1c                	jmp    801cad <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801c91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c94:	74 12                	je     801ca8 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801c96:	50                   	push   %eax
  801c97:	68 ba 24 80 00       	push   $0x8024ba
  801c9c:	6a 39                	push   $0x39
  801c9e:	68 d5 24 80 00       	push   $0x8024d5
  801ca3:	e8 eb e4 ff ff       	call   800193 <_panic>
                 sys_yield();
  801ca8:	e8 30 ef ff ff       	call   800bdd <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801cad:	ff 75 14             	pushl  0x14(%ebp)
  801cb0:	53                   	push   %ebx
  801cb1:	56                   	push   %esi
  801cb2:	57                   	push   %edi
  801cb3:	e8 d1 f0 ff ff       	call   800d89 <sys_ipc_try_send>
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 d2                	js     801c91 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cd2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cd5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cdb:	8b 52 50             	mov    0x50(%edx),%edx
  801cde:	39 ca                	cmp    %ecx,%edx
  801ce0:	75 0d                	jne    801cef <ipc_find_env+0x28>
			return envs[i].env_id;
  801ce2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ce5:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801cea:	8b 40 08             	mov    0x8(%eax),%eax
  801ced:	eb 0e                	jmp    801cfd <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cef:	83 c0 01             	add    $0x1,%eax
  801cf2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cf7:	75 d9                	jne    801cd2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cf9:	66 b8 00 00          	mov    $0x0,%ax
}
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	c1 e8 16             	shr    $0x16,%eax
  801d0a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d16:	f6 c1 01             	test   $0x1,%cl
  801d19:	74 1d                	je     801d38 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d1b:	c1 ea 0c             	shr    $0xc,%edx
  801d1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d25:	f6 c2 01             	test   $0x1,%dl
  801d28:	74 0e                	je     801d38 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d2a:	c1 ea 0c             	shr    $0xc,%edx
  801d2d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d34:	ef 
  801d35:	0f b7 c0             	movzwl %ax,%eax
}
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__udivdi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	83 ec 10             	sub    $0x10,%esp
  801d46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801d4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d4e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801d52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d56:	85 d2                	test   %edx,%edx
  801d58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d5c:	89 34 24             	mov    %esi,(%esp)
  801d5f:	89 c8                	mov    %ecx,%eax
  801d61:	75 35                	jne    801d98 <__udivdi3+0x58>
  801d63:	39 f1                	cmp    %esi,%ecx
  801d65:	0f 87 bd 00 00 00    	ja     801e28 <__udivdi3+0xe8>
  801d6b:	85 c9                	test   %ecx,%ecx
  801d6d:	89 cd                	mov    %ecx,%ebp
  801d6f:	75 0b                	jne    801d7c <__udivdi3+0x3c>
  801d71:	b8 01 00 00 00       	mov    $0x1,%eax
  801d76:	31 d2                	xor    %edx,%edx
  801d78:	f7 f1                	div    %ecx
  801d7a:	89 c5                	mov    %eax,%ebp
  801d7c:	89 f0                	mov    %esi,%eax
  801d7e:	31 d2                	xor    %edx,%edx
  801d80:	f7 f5                	div    %ebp
  801d82:	89 c6                	mov    %eax,%esi
  801d84:	89 f8                	mov    %edi,%eax
  801d86:	f7 f5                	div    %ebp
  801d88:	89 f2                	mov    %esi,%edx
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	5e                   	pop    %esi
  801d8e:	5f                   	pop    %edi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    
  801d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d98:	3b 14 24             	cmp    (%esp),%edx
  801d9b:	77 7b                	ja     801e18 <__udivdi3+0xd8>
  801d9d:	0f bd f2             	bsr    %edx,%esi
  801da0:	83 f6 1f             	xor    $0x1f,%esi
  801da3:	0f 84 97 00 00 00    	je     801e40 <__udivdi3+0x100>
  801da9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801dae:	89 d7                	mov    %edx,%edi
  801db0:	89 f1                	mov    %esi,%ecx
  801db2:	29 f5                	sub    %esi,%ebp
  801db4:	d3 e7                	shl    %cl,%edi
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	d3 ea                	shr    %cl,%edx
  801dbc:	89 f1                	mov    %esi,%ecx
  801dbe:	09 fa                	or     %edi,%edx
  801dc0:	8b 3c 24             	mov    (%esp),%edi
  801dc3:	d3 e0                	shl    %cl,%eax
  801dc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dcf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801dd3:	89 fa                	mov    %edi,%edx
  801dd5:	d3 ea                	shr    %cl,%edx
  801dd7:	89 f1                	mov    %esi,%ecx
  801dd9:	d3 e7                	shl    %cl,%edi
  801ddb:	89 e9                	mov    %ebp,%ecx
  801ddd:	d3 e8                	shr    %cl,%eax
  801ddf:	09 c7                	or     %eax,%edi
  801de1:	89 f8                	mov    %edi,%eax
  801de3:	f7 74 24 08          	divl   0x8(%esp)
  801de7:	89 d5                	mov    %edx,%ebp
  801de9:	89 c7                	mov    %eax,%edi
  801deb:	f7 64 24 0c          	mull   0xc(%esp)
  801def:	39 d5                	cmp    %edx,%ebp
  801df1:	89 14 24             	mov    %edx,(%esp)
  801df4:	72 11                	jb     801e07 <__udivdi3+0xc7>
  801df6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dfa:	89 f1                	mov    %esi,%ecx
  801dfc:	d3 e2                	shl    %cl,%edx
  801dfe:	39 c2                	cmp    %eax,%edx
  801e00:	73 5e                	jae    801e60 <__udivdi3+0x120>
  801e02:	3b 2c 24             	cmp    (%esp),%ebp
  801e05:	75 59                	jne    801e60 <__udivdi3+0x120>
  801e07:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e0a:	31 f6                	xor    %esi,%esi
  801e0c:	89 f2                	mov    %esi,%edx
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	5e                   	pop    %esi
  801e12:	5f                   	pop    %edi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    
  801e15:	8d 76 00             	lea    0x0(%esi),%esi
  801e18:	31 f6                	xor    %esi,%esi
  801e1a:	31 c0                	xor    %eax,%eax
  801e1c:	89 f2                	mov    %esi,%edx
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi
  801e28:	89 f2                	mov    %esi,%edx
  801e2a:	31 f6                	xor    %esi,%esi
  801e2c:	89 f8                	mov    %edi,%eax
  801e2e:	f7 f1                	div    %ecx
  801e30:	89 f2                	mov    %esi,%edx
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e44:	76 0b                	jbe    801e51 <__udivdi3+0x111>
  801e46:	31 c0                	xor    %eax,%eax
  801e48:	3b 14 24             	cmp    (%esp),%edx
  801e4b:	0f 83 37 ff ff ff    	jae    801d88 <__udivdi3+0x48>
  801e51:	b8 01 00 00 00       	mov    $0x1,%eax
  801e56:	e9 2d ff ff ff       	jmp    801d88 <__udivdi3+0x48>
  801e5b:	90                   	nop
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	89 f8                	mov    %edi,%eax
  801e62:	31 f6                	xor    %esi,%esi
  801e64:	e9 1f ff ff ff       	jmp    801d88 <__udivdi3+0x48>
  801e69:	66 90                	xchg   %ax,%ax
  801e6b:	66 90                	xchg   %ax,%ax
  801e6d:	66 90                	xchg   %ax,%ax
  801e6f:	90                   	nop

00801e70 <__umoddi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	83 ec 20             	sub    $0x20,%esp
  801e76:	8b 44 24 34          	mov    0x34(%esp),%eax
  801e7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e82:	89 c6                	mov    %eax,%esi
  801e84:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801e90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e98:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	89 c2                	mov    %eax,%edx
  801ea0:	75 1e                	jne    801ec0 <__umoddi3+0x50>
  801ea2:	39 f7                	cmp    %esi,%edi
  801ea4:	76 52                	jbe    801ef8 <__umoddi3+0x88>
  801ea6:	89 c8                	mov    %ecx,%eax
  801ea8:	89 f2                	mov    %esi,%edx
  801eaa:	f7 f7                	div    %edi
  801eac:	89 d0                	mov    %edx,%eax
  801eae:	31 d2                	xor    %edx,%edx
  801eb0:	83 c4 20             	add    $0x20,%esp
  801eb3:	5e                   	pop    %esi
  801eb4:	5f                   	pop    %edi
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    
  801eb7:	89 f6                	mov    %esi,%esi
  801eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ec0:	39 f0                	cmp    %esi,%eax
  801ec2:	77 5c                	ja     801f20 <__umoddi3+0xb0>
  801ec4:	0f bd e8             	bsr    %eax,%ebp
  801ec7:	83 f5 1f             	xor    $0x1f,%ebp
  801eca:	75 64                	jne    801f30 <__umoddi3+0xc0>
  801ecc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ed0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ed4:	0f 86 f6 00 00 00    	jbe    801fd0 <__umoddi3+0x160>
  801eda:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801ede:	0f 82 ec 00 00 00    	jb     801fd0 <__umoddi3+0x160>
  801ee4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ee8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801eec:	83 c4 20             	add    $0x20,%esp
  801eef:	5e                   	pop    %esi
  801ef0:	5f                   	pop    %edi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    
  801ef3:	90                   	nop
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	85 ff                	test   %edi,%edi
  801efa:	89 fd                	mov    %edi,%ebp
  801efc:	75 0b                	jne    801f09 <__umoddi3+0x99>
  801efe:	b8 01 00 00 00       	mov    $0x1,%eax
  801f03:	31 d2                	xor    %edx,%edx
  801f05:	f7 f7                	div    %edi
  801f07:	89 c5                	mov    %eax,%ebp
  801f09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f0d:	31 d2                	xor    %edx,%edx
  801f0f:	f7 f5                	div    %ebp
  801f11:	89 c8                	mov    %ecx,%eax
  801f13:	f7 f5                	div    %ebp
  801f15:	eb 95                	jmp    801eac <__umoddi3+0x3c>
  801f17:	89 f6                	mov    %esi,%esi
  801f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f20:	89 c8                	mov    %ecx,%eax
  801f22:	89 f2                	mov    %esi,%edx
  801f24:	83 c4 20             	add    $0x20,%esp
  801f27:	5e                   	pop    %esi
  801f28:	5f                   	pop    %edi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    
  801f2b:	90                   	nop
  801f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f30:	b8 20 00 00 00       	mov    $0x20,%eax
  801f35:	89 e9                	mov    %ebp,%ecx
  801f37:	29 e8                	sub    %ebp,%eax
  801f39:	d3 e2                	shl    %cl,%edx
  801f3b:	89 c7                	mov    %eax,%edi
  801f3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	d3 e8                	shr    %cl,%eax
  801f49:	89 c1                	mov    %eax,%ecx
  801f4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f4f:	09 d1                	or     %edx,%ecx
  801f51:	89 fa                	mov    %edi,%edx
  801f53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f57:	89 e9                	mov    %ebp,%ecx
  801f59:	d3 e0                	shl    %cl,%eax
  801f5b:	89 f9                	mov    %edi,%ecx
  801f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f61:	89 f0                	mov    %esi,%eax
  801f63:	d3 e8                	shr    %cl,%eax
  801f65:	89 e9                	mov    %ebp,%ecx
  801f67:	89 c7                	mov    %eax,%edi
  801f69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f6d:	d3 e6                	shl    %cl,%esi
  801f6f:	89 d1                	mov    %edx,%ecx
  801f71:	89 fa                	mov    %edi,%edx
  801f73:	d3 e8                	shr    %cl,%eax
  801f75:	89 e9                	mov    %ebp,%ecx
  801f77:	09 f0                	or     %esi,%eax
  801f79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801f7d:	f7 74 24 10          	divl   0x10(%esp)
  801f81:	d3 e6                	shl    %cl,%esi
  801f83:	89 d1                	mov    %edx,%ecx
  801f85:	f7 64 24 0c          	mull   0xc(%esp)
  801f89:	39 d1                	cmp    %edx,%ecx
  801f8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801f8f:	89 d7                	mov    %edx,%edi
  801f91:	89 c6                	mov    %eax,%esi
  801f93:	72 0a                	jb     801f9f <__umoddi3+0x12f>
  801f95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801f99:	73 10                	jae    801fab <__umoddi3+0x13b>
  801f9b:	39 d1                	cmp    %edx,%ecx
  801f9d:	75 0c                	jne    801fab <__umoddi3+0x13b>
  801f9f:	89 d7                	mov    %edx,%edi
  801fa1:	89 c6                	mov    %eax,%esi
  801fa3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801fa7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801fab:	89 ca                	mov    %ecx,%edx
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fb3:	29 f0                	sub    %esi,%eax
  801fb5:	19 fa                	sbb    %edi,%edx
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801fbe:	89 d7                	mov    %edx,%edi
  801fc0:	d3 e7                	shl    %cl,%edi
  801fc2:	89 e9                	mov    %ebp,%ecx
  801fc4:	09 f8                	or     %edi,%eax
  801fc6:	d3 ea                	shr    %cl,%edx
  801fc8:	83 c4 20             	add    $0x20,%esp
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    
  801fcf:	90                   	nop
  801fd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801fd4:	29 f9                	sub    %edi,%ecx
  801fd6:	19 c6                	sbb    %eax,%esi
  801fd8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801fdc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801fe0:	e9 ff fe ff ff       	jmp    801ee4 <__umoddi3+0x74>
