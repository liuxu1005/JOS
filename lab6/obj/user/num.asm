
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 80 25 80 00       	push   $0x802580
  800062:	e8 a9 17 00 00       	call   801810 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 1a 12 00 00       	call   80129b <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 85 25 80 00       	push   $0x802585
  800095:	6a 13                	push   $0x13
  800097:	68 a0 25 80 00       	push   $0x8025a0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 08 11 00 00       	call   8011c5 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 ab 25 80 00       	push   $0x8025ab
  8000d8:	6a 18                	push   $0x18
  8000da:	68 a0 25 80 00       	push   $0x8025a0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 c0 	movl   $0x8025c0,0x803004
  8000fb:	25 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 c4 25 80 00       	push   $0x8025c4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 3e 15 00 00       	call   801672 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 cc 25 80 00       	push   $0x8025cc
  80014b:	6a 27                	push   $0x27
  80014d:	68 a0 25 80 00       	push   $0x8025a0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 1b 0f 00 00       	call   801085 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800190:	e8 7b 0a 00 00       	call   800c10 <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
  8001c1:	83 c4 10             	add    $0x10,%esp
}
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 dc 0e 00 00       	call   8010b2 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 ef 09 00 00       	call   800bcf <sys_env_destroy>
  8001e0:	83 c4 10             	add    $0x10,%esp
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 18 0a 00 00       	call   800c10 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 e8 25 80 00       	push   $0x8025e8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 37 09 00 00       	call   800b92 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 4f 01 00 00       	call   8003f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 dc 08 00 00       	call   800b92 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 d1                	mov    %edx,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002fd:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800300:	72 05                	jb     800307 <printnum+0x35>
  800302:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800305:	77 3e                	ja     800345 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800307:	83 ec 0c             	sub    $0xc,%esp
  80030a:	ff 75 18             	pushl  0x18(%ebp)
  80030d:	83 eb 01             	sub    $0x1,%ebx
  800310:	53                   	push   %ebx
  800311:	50                   	push   %eax
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 8a 1f 00 00       	call   8022b0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 13                	jmp    80034c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800345:	83 eb 01             	sub    $0x1,%ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f ed                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	ff 75 e4             	pushl  -0x1c(%ebp)
  800356:	ff 75 e0             	pushl  -0x20(%ebp)
  800359:	ff 75 dc             	pushl  -0x24(%ebp)
  80035c:	ff 75 d8             	pushl  -0x28(%ebp)
  80035f:	e8 7c 20 00 00       	call   8023e0 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 80 0b 26 80 00 	movsbl 0x80260b(%eax),%eax
  80036e:	50                   	push   %eax
  80036f:	ff d7                	call   *%edi
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037f:	83 fa 01             	cmp    $0x1,%edx
  800382:	7e 0e                	jle    800392 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800384:	8b 10                	mov    (%eax),%edx
  800386:	8d 4a 08             	lea    0x8(%edx),%ecx
  800389:	89 08                	mov    %ecx,(%eax)
  80038b:	8b 02                	mov    (%edx),%eax
  80038d:	8b 52 04             	mov    0x4(%edx),%edx
  800390:	eb 22                	jmp    8003b4 <getuint+0x38>
	else if (lflag)
  800392:	85 d2                	test   %edx,%edx
  800394:	74 10                	je     8003a6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a4:	eb 0e                	jmp    8003b4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c5:	73 0a                	jae    8003d1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ca:	89 08                	mov    %ecx,(%eax)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	88 02                	mov    %al,(%edx)
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003dc:	50                   	push   %eax
  8003dd:	ff 75 10             	pushl  0x10(%ebp)
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	e8 05 00 00 00       	call   8003f0 <vprintfmt>
	va_end(ap);
  8003eb:	83 c4 10             	add    $0x10,%esp
}
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 2c             	sub    $0x2c,%esp
  8003f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ff:	8b 7d 10             	mov    0x10(%ebp),%edi
  800402:	eb 12                	jmp    800416 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800404:	85 c0                	test   %eax,%eax
  800406:	0f 84 90 03 00 00    	je     80079c <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	53                   	push   %ebx
  800410:	50                   	push   %eax
  800411:	ff d6                	call   *%esi
  800413:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800416:	83 c7 01             	add    $0x1,%edi
  800419:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041d:	83 f8 25             	cmp    $0x25,%eax
  800420:	75 e2                	jne    800404 <vprintfmt+0x14>
  800422:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800426:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800434:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	eb 07                	jmp    800449 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800445:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8d 47 01             	lea    0x1(%edi),%eax
  80044c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044f:	0f b6 07             	movzbl (%edi),%eax
  800452:	0f b6 c8             	movzbl %al,%ecx
  800455:	83 e8 23             	sub    $0x23,%eax
  800458:	3c 55                	cmp    $0x55,%al
  80045a:	0f 87 21 03 00 00    	ja     800781 <vprintfmt+0x391>
  800460:	0f b6 c0             	movzbl %al,%eax
  800463:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800471:	eb d6                	jmp    800449 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800481:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800485:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800488:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80048b:	83 fa 09             	cmp    $0x9,%edx
  80048e:	77 39                	ja     8004c9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800490:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800493:	eb e9                	jmp    80047e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 48 04             	lea    0x4(%eax),%ecx
  80049b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a6:	eb 27                	jmp    8004cf <vprintfmt+0xdf>
  8004a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b2:	0f 49 c8             	cmovns %eax,%ecx
  8004b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bb:	eb 8c                	jmp    800449 <vprintfmt+0x59>
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c7:	eb 80                	jmp    800449 <vprintfmt+0x59>
  8004c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d3:	0f 89 70 ff ff ff    	jns    800449 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e6:	e9 5e ff ff ff       	jmp    800449 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004eb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f1:	e9 53 ff ff ff       	jmp    800449 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	ff 30                	pushl  (%eax)
  800505:	ff d6                	call   *%esi
			break;
  800507:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050d:	e9 04 ff ff ff       	jmp    800416 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	99                   	cltd   
  80051e:	31 d0                	xor    %edx,%eax
  800520:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800522:	83 f8 0f             	cmp    $0xf,%eax
  800525:	7f 0b                	jg     800532 <vprintfmt+0x142>
  800527:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	75 18                	jne    80054a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800532:	50                   	push   %eax
  800533:	68 23 26 80 00       	push   $0x802623
  800538:	53                   	push   %ebx
  800539:	56                   	push   %esi
  80053a:	e8 94 fe ff ff       	call   8003d3 <printfmt>
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800545:	e9 cc fe ff ff       	jmp    800416 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054a:	52                   	push   %edx
  80054b:	68 f9 29 80 00       	push   $0x8029f9
  800550:	53                   	push   %ebx
  800551:	56                   	push   %esi
  800552:	e8 7c fe ff ff       	call   8003d3 <printfmt>
  800557:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055d:	e9 b4 fe ff ff       	jmp    800416 <vprintfmt+0x26>
  800562:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800565:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800568:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800576:	85 ff                	test   %edi,%edi
  800578:	ba 1c 26 80 00       	mov    $0x80261c,%edx
  80057d:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800580:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800584:	0f 84 92 00 00 00    	je     80061c <vprintfmt+0x22c>
  80058a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80058e:	0f 8e 96 00 00 00    	jle    80062a <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	51                   	push   %ecx
  800598:	57                   	push   %edi
  800599:	e8 86 02 00 00       	call   800824 <strnlen>
  80059e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a1:	29 c1                	sub    %eax,%ecx
  8005a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	eb 0f                	jmp    8005c6 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8005be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c0:	83 ef 01             	sub    $0x1,%edi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f ed                	jg     8005b7 <vprintfmt+0x1c7>
  8005ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d7:	0f 49 c1             	cmovns %ecx,%eax
  8005da:	29 c1                	sub    %eax,%ecx
  8005dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e5:	89 cb                	mov    %ecx,%ebx
  8005e7:	eb 4d                	jmp    800636 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ed:	74 1b                	je     80060a <vprintfmt+0x21a>
  8005ef:	0f be c0             	movsbl %al,%eax
  8005f2:	83 e8 20             	sub    $0x20,%eax
  8005f5:	83 f8 5e             	cmp    $0x5e,%eax
  8005f8:	76 10                	jbe    80060a <vprintfmt+0x21a>
					putch('?', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	ff 75 0c             	pushl  0xc(%ebp)
  800600:	6a 3f                	push   $0x3f
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	eb 0d                	jmp    800617 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	52                   	push   %edx
  800611:	ff 55 08             	call   *0x8(%ebp)
  800614:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800617:	83 eb 01             	sub    $0x1,%ebx
  80061a:	eb 1a                	jmp    800636 <vprintfmt+0x246>
  80061c:	89 75 08             	mov    %esi,0x8(%ebp)
  80061f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800622:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800625:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800628:	eb 0c                	jmp    800636 <vprintfmt+0x246>
  80062a:	89 75 08             	mov    %esi,0x8(%ebp)
  80062d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800630:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800633:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800636:	83 c7 01             	add    $0x1,%edi
  800639:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063d:	0f be d0             	movsbl %al,%edx
  800640:	85 d2                	test   %edx,%edx
  800642:	74 23                	je     800667 <vprintfmt+0x277>
  800644:	85 f6                	test   %esi,%esi
  800646:	78 a1                	js     8005e9 <vprintfmt+0x1f9>
  800648:	83 ee 01             	sub    $0x1,%esi
  80064b:	79 9c                	jns    8005e9 <vprintfmt+0x1f9>
  80064d:	89 df                	mov    %ebx,%edi
  80064f:	8b 75 08             	mov    0x8(%ebp),%esi
  800652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800655:	eb 18                	jmp    80066f <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 20                	push   $0x20
  80065d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	83 ef 01             	sub    $0x1,%edi
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 08                	jmp    80066f <vprintfmt+0x27f>
  800667:	89 df                	mov    %ebx,%edi
  800669:	8b 75 08             	mov    0x8(%ebp),%esi
  80066c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066f:	85 ff                	test   %edi,%edi
  800671:	7f e4                	jg     800657 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800676:	e9 9b fd ff ff       	jmp    800416 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067b:	83 fa 01             	cmp    $0x1,%edx
  80067e:	7e 16                	jle    800696 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 08             	lea    0x8(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 50 04             	mov    0x4(%eax),%edx
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	eb 32                	jmp    8006c8 <vprintfmt+0x2d8>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 18                	je     8006b2 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a8:	89 c1                	mov    %eax,%ecx
  8006aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b0:	eb 16                	jmp    8006c8 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 c1                	mov    %eax,%ecx
  8006c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d7:	79 74                	jns    80074d <vprintfmt+0x35d>
				putch('-', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	6a 2d                	push   $0x2d
  8006df:	ff d6                	call   *%esi
				num = -(long long) num;
  8006e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e7:	f7 d8                	neg    %eax
  8006e9:	83 d2 00             	adc    $0x0,%edx
  8006ec:	f7 da                	neg    %edx
  8006ee:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f6:	eb 55                	jmp    80074d <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 7c fc ff ff       	call   80037c <getuint>
			base = 10;
  800700:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800705:	eb 46                	jmp    80074d <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 6d fc ff ff       	call   80037c <getuint>
                        base = 8;
  80070f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800714:	eb 37                	jmp    80074d <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 30                	push   $0x30
  80071c:	ff d6                	call   *%esi
			putch('x', putdat);
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 78                	push   $0x78
  800724:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800736:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800739:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073e:	eb 0d                	jmp    80074d <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
  800743:	e8 34 fc ff ff       	call   80037c <getuint>
			base = 16;
  800748:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074d:	83 ec 0c             	sub    $0xc,%esp
  800750:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800754:	57                   	push   %edi
  800755:	ff 75 e0             	pushl  -0x20(%ebp)
  800758:	51                   	push   %ecx
  800759:	52                   	push   %edx
  80075a:	50                   	push   %eax
  80075b:	89 da                	mov    %ebx,%edx
  80075d:	89 f0                	mov    %esi,%eax
  80075f:	e8 6e fb ff ff       	call   8002d2 <printnum>
			break;
  800764:	83 c4 20             	add    $0x20,%esp
  800767:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076a:	e9 a7 fc ff ff       	jmp    800416 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	51                   	push   %ecx
  800774:	ff d6                	call   *%esi
			break;
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077c:	e9 95 fc ff ff       	jmp    800416 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 25                	push   $0x25
  800787:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	eb 03                	jmp    800791 <vprintfmt+0x3a1>
  80078e:	83 ef 01             	sub    $0x1,%edi
  800791:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800795:	75 f7                	jne    80078e <vprintfmt+0x39e>
  800797:	e9 7a fc ff ff       	jmp    800416 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80079c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5f                   	pop    %edi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	83 ec 18             	sub    $0x18,%esp
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	74 26                	je     8007eb <vsnprintf+0x47>
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	7e 22                	jle    8007eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c9:	ff 75 14             	pushl  0x14(%ebp)
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	68 b6 03 80 00       	push   $0x8003b6
  8007d8:	e8 13 fc ff ff       	call   8003f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 05                	jmp    8007f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fb:	50                   	push   %eax
  8007fc:	ff 75 10             	pushl  0x10(%ebp)
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	ff 75 08             	pushl  0x8(%ebp)
  800805:	e8 9a ff ff ff       	call   8007a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	eb 03                	jmp    80081c <strlen+0x10>
		n++;
  800819:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80081c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800820:	75 f7                	jne    800819 <strlen+0xd>
		n++;
	return n;
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
  800832:	eb 03                	jmp    800837 <strnlen+0x13>
		n++;
  800834:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800837:	39 c2                	cmp    %eax,%edx
  800839:	74 08                	je     800843 <strnlen+0x1f>
  80083b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083f:	75 f3                	jne    800834 <strnlen+0x10>
  800841:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80085b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085e:	84 db                	test   %bl,%bl
  800860:	75 ef                	jne    800851 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086c:	53                   	push   %ebx
  80086d:	e8 9a ff ff ff       	call   80080c <strlen>
  800872:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	01 d8                	add    %ebx,%eax
  80087a:	50                   	push   %eax
  80087b:	e8 c5 ff ff ff       	call   800845 <strcpy>
	return dst;
}
  800880:	89 d8                	mov    %ebx,%eax
  800882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 75 08             	mov    0x8(%ebp),%esi
  80088f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800892:	89 f3                	mov    %esi,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800897:	89 f2                	mov    %esi,%edx
  800899:	eb 0f                	jmp    8008aa <strncpy+0x23>
		*dst++ = *src;
  80089b:	83 c2 01             	add    $0x1,%edx
  80089e:	0f b6 01             	movzbl (%ecx),%eax
  8008a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a4:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008aa:	39 da                	cmp    %ebx,%edx
  8008ac:	75 ed                	jne    80089b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ae:	89 f0                	mov    %esi,%eax
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c4:	85 d2                	test   %edx,%edx
  8008c6:	74 21                	je     8008e9 <strlcpy+0x35>
  8008c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008cc:	89 f2                	mov    %esi,%edx
  8008ce:	eb 09                	jmp    8008d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d0:	83 c2 01             	add    $0x1,%edx
  8008d3:	83 c1 01             	add    $0x1,%ecx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d9:	39 c2                	cmp    %eax,%edx
  8008db:	74 09                	je     8008e6 <strlcpy+0x32>
  8008dd:	0f b6 19             	movzbl (%ecx),%ebx
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	75 ec                	jne    8008d0 <strlcpy+0x1c>
  8008e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e9:	29 f0                	sub    %esi,%eax
}
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f8:	eb 06                	jmp    800900 <strcmp+0x11>
		p++, q++;
  8008fa:	83 c1 01             	add    $0x1,%ecx
  8008fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800900:	0f b6 01             	movzbl (%ecx),%eax
  800903:	84 c0                	test   %al,%al
  800905:	74 04                	je     80090b <strcmp+0x1c>
  800907:	3a 02                	cmp    (%edx),%al
  800909:	74 ef                	je     8008fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 c0             	movzbl %al,%eax
  80090e:	0f b6 12             	movzbl (%edx),%edx
  800911:	29 d0                	sub    %edx,%eax
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	89 c3                	mov    %eax,%ebx
  800921:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800924:	eb 06                	jmp    80092c <strncmp+0x17>
		n--, p++, q++;
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092c:	39 d8                	cmp    %ebx,%eax
  80092e:	74 15                	je     800945 <strncmp+0x30>
  800930:	0f b6 08             	movzbl (%eax),%ecx
  800933:	84 c9                	test   %cl,%cl
  800935:	74 04                	je     80093b <strncmp+0x26>
  800937:	3a 0a                	cmp    (%edx),%cl
  800939:	74 eb                	je     800926 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093b:	0f b6 00             	movzbl (%eax),%eax
  80093e:	0f b6 12             	movzbl (%edx),%edx
  800941:	29 d0                	sub    %edx,%eax
  800943:	eb 05                	jmp    80094a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094a:	5b                   	pop    %ebx
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800957:	eb 07                	jmp    800960 <strchr+0x13>
		if (*s == c)
  800959:	38 ca                	cmp    %cl,%dl
  80095b:	74 0f                	je     80096c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095d:	83 c0 01             	add    $0x1,%eax
  800960:	0f b6 10             	movzbl (%eax),%edx
  800963:	84 d2                	test   %dl,%dl
  800965:	75 f2                	jne    800959 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800978:	eb 03                	jmp    80097d <strfind+0xf>
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800980:	84 d2                	test   %dl,%dl
  800982:	74 04                	je     800988 <strfind+0x1a>
  800984:	38 ca                	cmp    %cl,%dl
  800986:	75 f2                	jne    80097a <strfind+0xc>
			break;
	return (char *) s;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 7d 08             	mov    0x8(%ebp),%edi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800996:	85 c9                	test   %ecx,%ecx
  800998:	74 36                	je     8009d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a0:	75 28                	jne    8009ca <memset+0x40>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 23                	jne    8009ca <memset+0x40>
		c &= 0xFF;
  8009a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ab:	89 d3                	mov    %edx,%ebx
  8009ad:	c1 e3 08             	shl    $0x8,%ebx
  8009b0:	89 d6                	mov    %edx,%esi
  8009b2:	c1 e6 18             	shl    $0x18,%esi
  8009b5:	89 d0                	mov    %edx,%eax
  8009b7:	c1 e0 10             	shl    $0x10,%eax
  8009ba:	09 f0                	or     %esi,%eax
  8009bc:	09 c2                	or     %eax,%edx
  8009be:	89 d0                	mov    %edx,%eax
  8009c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c5:	fc                   	cld    
  8009c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c8:	eb 06                	jmp    8009d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cd:	fc                   	cld    
  8009ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d0:	89 f8                	mov    %edi,%eax
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e5:	39 c6                	cmp    %eax,%esi
  8009e7:	73 35                	jae    800a1e <memmove+0x47>
  8009e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ec:	39 d0                	cmp    %edx,%eax
  8009ee:	73 2e                	jae    800a1e <memmove+0x47>
		s += n;
		d += n;
  8009f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009f3:	89 d6                	mov    %edx,%esi
  8009f5:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fd:	75 13                	jne    800a12 <memmove+0x3b>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 0e                	jne    800a12 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a04:	83 ef 04             	sub    $0x4,%edi
  800a07:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0d:	fd                   	std    
  800a0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a10:	eb 09                	jmp    800a1b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a12:	83 ef 01             	sub    $0x1,%edi
  800a15:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a18:	fd                   	std    
  800a19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1b:	fc                   	cld    
  800a1c:	eb 1d                	jmp    800a3b <memmove+0x64>
  800a1e:	89 f2                	mov    %esi,%edx
  800a20:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a22:	f6 c2 03             	test   $0x3,%dl
  800a25:	75 0f                	jne    800a36 <memmove+0x5f>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	75 0a                	jne    800a36 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2f:	89 c7                	mov    %eax,%edi
  800a31:	fc                   	cld    
  800a32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a34:	eb 05                	jmp    800a3b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a36:	89 c7                	mov    %eax,%edi
  800a38:	fc                   	cld    
  800a39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a42:	ff 75 10             	pushl  0x10(%ebp)
  800a45:	ff 75 0c             	pushl  0xc(%ebp)
  800a48:	ff 75 08             	pushl  0x8(%ebp)
  800a4b:	e8 87 ff ff ff       	call   8009d7 <memmove>
}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	89 c6                	mov    %eax,%esi
  800a5f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a62:	eb 1a                	jmp    800a7e <memcmp+0x2c>
		if (*s1 != *s2)
  800a64:	0f b6 08             	movzbl (%eax),%ecx
  800a67:	0f b6 1a             	movzbl (%edx),%ebx
  800a6a:	38 d9                	cmp    %bl,%cl
  800a6c:	74 0a                	je     800a78 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a6e:	0f b6 c1             	movzbl %cl,%eax
  800a71:	0f b6 db             	movzbl %bl,%ebx
  800a74:	29 d8                	sub    %ebx,%eax
  800a76:	eb 0f                	jmp    800a87 <memcmp+0x35>
		s1++, s2++;
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7e:	39 f0                	cmp    %esi,%eax
  800a80:	75 e2                	jne    800a64 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a94:	89 c2                	mov    %eax,%edx
  800a96:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a99:	eb 07                	jmp    800aa2 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9b:	38 08                	cmp    %cl,(%eax)
  800a9d:	74 07                	je     800aa6 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9f:	83 c0 01             	add    $0x1,%eax
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	72 f5                	jb     800a9b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab4:	eb 03                	jmp    800ab9 <strtol+0x11>
		s++;
  800ab6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab9:	0f b6 01             	movzbl (%ecx),%eax
  800abc:	3c 09                	cmp    $0x9,%al
  800abe:	74 f6                	je     800ab6 <strtol+0xe>
  800ac0:	3c 20                	cmp    $0x20,%al
  800ac2:	74 f2                	je     800ab6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac4:	3c 2b                	cmp    $0x2b,%al
  800ac6:	75 0a                	jne    800ad2 <strtol+0x2a>
		s++;
  800ac8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad0:	eb 10                	jmp    800ae2 <strtol+0x3a>
  800ad2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad7:	3c 2d                	cmp    $0x2d,%al
  800ad9:	75 07                	jne    800ae2 <strtol+0x3a>
		s++, neg = 1;
  800adb:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ade:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae2:	85 db                	test   %ebx,%ebx
  800ae4:	0f 94 c0             	sete   %al
  800ae7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aed:	75 19                	jne    800b08 <strtol+0x60>
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	75 14                	jne    800b08 <strtol+0x60>
  800af4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af8:	0f 85 82 00 00 00    	jne    800b80 <strtol+0xd8>
		s += 2, base = 16;
  800afe:	83 c1 02             	add    $0x2,%ecx
  800b01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b06:	eb 16                	jmp    800b1e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b08:	84 c0                	test   %al,%al
  800b0a:	74 12                	je     800b1e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b11:	80 39 30             	cmpb   $0x30,(%ecx)
  800b14:	75 08                	jne    800b1e <strtol+0x76>
		s++, base = 8;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b26:	0f b6 11             	movzbl (%ecx),%edx
  800b29:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 09             	cmp    $0x9,%bl
  800b31:	77 08                	ja     800b3b <strtol+0x93>
			dig = *s - '0';
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 30             	sub    $0x30,%edx
  800b39:	eb 22                	jmp    800b5d <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b3b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 19             	cmp    $0x19,%bl
  800b43:	77 08                	ja     800b4d <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 57             	sub    $0x57,%edx
  800b4b:	eb 10                	jmp    800b5d <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b4d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b50:	89 f3                	mov    %esi,%ebx
  800b52:	80 fb 19             	cmp    $0x19,%bl
  800b55:	77 16                	ja     800b6d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b57:	0f be d2             	movsbl %dl,%edx
  800b5a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b5d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b60:	7d 0f                	jge    800b71 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b62:	83 c1 01             	add    $0x1,%ecx
  800b65:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b69:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b6b:	eb b9                	jmp    800b26 <strtol+0x7e>
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	eb 02                	jmp    800b73 <strtol+0xcb>
  800b71:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b73:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b77:	74 0d                	je     800b86 <strtol+0xde>
		*endptr = (char *) s;
  800b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7c:	89 0e                	mov    %ecx,(%esi)
  800b7e:	eb 06                	jmp    800b86 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b80:	84 c0                	test   %al,%al
  800b82:	75 92                	jne    800b16 <strtol+0x6e>
  800b84:	eb 98                	jmp    800b1e <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b86:	f7 da                	neg    %edx
  800b88:	85 ff                	test   %edi,%edi
  800b8a:	0f 45 c2             	cmovne %edx,%eax
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	89 c3                	mov    %eax,%ebx
  800ba5:	89 c7                	mov    %eax,%edi
  800ba7:	89 c6                	mov    %eax,%esi
  800ba9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc0:	89 d1                	mov    %edx,%ecx
  800bc2:	89 d3                	mov    %edx,%ebx
  800bc4:	89 d7                	mov    %edx,%edi
  800bc6:	89 d6                	mov    %edx,%esi
  800bc8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	89 cb                	mov    %ecx,%ebx
  800be7:	89 cf                	mov    %ecx,%edi
  800be9:	89 ce                	mov    %ecx,%esi
  800beb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 03                	push   $0x3
  800bf7:	68 1f 29 80 00       	push   $0x80291f
  800bfc:	6a 22                	push   $0x22
  800bfe:	68 3c 29 80 00       	push   $0x80293c
  800c03:	e8 dd f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c16:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c20:	89 d1                	mov    %edx,%ecx
  800c22:	89 d3                	mov    %edx,%ebx
  800c24:	89 d7                	mov    %edx,%edi
  800c26:	89 d6                	mov    %edx,%esi
  800c28:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_yield>:

void
sys_yield(void)
{      
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c35:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3f:	89 d1                	mov    %edx,%ecx
  800c41:	89 d3                	mov    %edx,%ebx
  800c43:	89 d7                	mov    %edx,%edi
  800c45:	89 d6                	mov    %edx,%esi
  800c47:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c57:	be 00 00 00 00       	mov    $0x0,%esi
  800c5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6a:	89 f7                	mov    %esi,%edi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 04                	push   $0x4
  800c78:	68 1f 29 80 00       	push   $0x80291f
  800c7d:	6a 22                	push   $0x22
  800c7f:	68 3c 29 80 00       	push   $0x80293c
  800c84:	e8 5c f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cab:	8b 75 18             	mov    0x18(%ebp),%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 05                	push   $0x5
  800cba:	68 1f 29 80 00       	push   $0x80291f
  800cbf:	6a 22                	push   $0x22
  800cc1:	68 3c 29 80 00       	push   $0x80293c
  800cc6:	e8 1a f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 df                	mov    %ebx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 17                	jle    800d0d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 06                	push   $0x6
  800cfc:	68 1f 29 80 00       	push   $0x80291f
  800d01:	6a 22                	push   $0x22
  800d03:	68 3c 29 80 00       	push   $0x80293c
  800d08:	e8 d8 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	b8 08 00 00 00       	mov    $0x8,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 17                	jle    800d4f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 08                	push   $0x8
  800d3e:	68 1f 29 80 00       	push   $0x80291f
  800d43:	6a 22                	push   $0x22
  800d45:	68 3c 29 80 00       	push   $0x80293c
  800d4a:	e8 96 f4 ff ff       	call   8001e5 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d65:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	89 df                	mov    %ebx,%edi
  800d72:	89 de                	mov    %ebx,%esi
  800d74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 17                	jle    800d91 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	50                   	push   %eax
  800d7e:	6a 09                	push   $0x9
  800d80:	68 1f 29 80 00       	push   $0x80291f
  800d85:	6a 22                	push   $0x22
  800d87:	68 3c 29 80 00       	push   $0x80293c
  800d8c:	e8 54 f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800da2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	89 df                	mov    %ebx,%edi
  800db4:	89 de                	mov    %ebx,%esi
  800db6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	7e 17                	jle    800dd3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	50                   	push   %eax
  800dc0:	6a 0a                	push   $0xa
  800dc2:	68 1f 29 80 00       	push   $0x80291f
  800dc7:	6a 22                	push   $0x22
  800dc9:	68 3c 29 80 00       	push   $0x80293c
  800dce:	e8 12 f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800de1:	be 00 00 00 00       	mov    $0x0,%esi
  800de6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	89 cb                	mov    %ecx,%ebx
  800e16:	89 cf                	mov    %ecx,%edi
  800e18:	89 ce                	mov    %ecx,%esi
  800e1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 17                	jle    800e37 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 0d                	push   $0xd
  800e26:	68 1f 29 80 00       	push   $0x80291f
  800e2b:	6a 22                	push   $0x22
  800e2d:	68 3c 29 80 00       	push   $0x80293c
  800e32:	e8 ae f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e45:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e4f:	89 d1                	mov    %edx,%ecx
  800e51:	89 d3                	mov    %edx,%ebx
  800e53:	89 d7                	mov    %edx,%edi
  800e55:	89 d6                	mov    %edx,%esi
  800e57:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <sys_transmit>:

int
sys_transmit(void *addr)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	89 cb                	mov    %ecx,%ebx
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	89 ce                	mov    %ecx,%esi
  800e7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 17                	jle    800e97 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	50                   	push   %eax
  800e84:	6a 0f                	push   $0xf
  800e86:	68 1f 29 80 00       	push   $0x80291f
  800e8b:	6a 22                	push   $0x22
  800e8d:	68 3c 29 80 00       	push   $0x80293c
  800e92:	e8 4e f3 ff ff       	call   8001e5 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_recv>:

int
sys_recv(void *addr)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ead:	b8 10 00 00 00       	mov    $0x10,%eax
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 cb                	mov    %ecx,%ebx
  800eb7:	89 cf                	mov    %ecx,%edi
  800eb9:	89 ce                	mov    %ecx,%esi
  800ebb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7e 17                	jle    800ed8 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	50                   	push   %eax
  800ec5:	6a 10                	push   $0x10
  800ec7:	68 1f 29 80 00       	push   $0x80291f
  800ecc:	6a 22                	push   $0x22
  800ece:	68 3c 29 80 00       	push   $0x80293c
  800ed3:	e8 0d f3 ff ff       	call   8001e5 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	05 00 00 00 30       	add    $0x30000000,%eax
  800eeb:	c1 e8 0c             	shr    $0xc,%eax
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800efb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f00:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 16             	shr    $0x16,%edx
  800f17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 11                	je     800f34 <fd_alloc+0x2d>
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 0c             	shr    $0xc,%edx
  800f28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	75 09                	jne    800f3d <fd_alloc+0x36>
			*fd_store = fd;
  800f34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb 17                	jmp    800f54 <fd_alloc+0x4d>
  800f3d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f42:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f47:	75 c9                	jne    800f12 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f49:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f4f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f5c:	83 f8 1f             	cmp    $0x1f,%eax
  800f5f:	77 36                	ja     800f97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f61:	c1 e0 0c             	shl    $0xc,%eax
  800f64:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	c1 ea 16             	shr    $0x16,%edx
  800f6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 24                	je     800f9e <fd_lookup+0x48>
  800f7a:	89 c2                	mov    %eax,%edx
  800f7c:	c1 ea 0c             	shr    $0xc,%edx
  800f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	74 1a                	je     800fa5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	eb 13                	jmp    800faa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9c:	eb 0c                	jmp    800faa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa3:	eb 05                	jmp    800faa <fd_lookup+0x54>
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	eb 13                	jmp    800fcf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800fbc:	39 08                	cmp    %ecx,(%eax)
  800fbe:	75 0c                	jne    800fcc <dev_lookup+0x20>
			*dev = devtab[i];
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	eb 36                	jmp    801002 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fcc:	83 c2 01             	add    $0x1,%edx
  800fcf:	8b 04 95 cc 29 80 00 	mov    0x8029cc(,%edx,4),%eax
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	75 e2                	jne    800fbc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fda:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800fdf:	8b 40 48             	mov    0x48(%eax),%eax
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	51                   	push   %ecx
  800fe6:	50                   	push   %eax
  800fe7:	68 4c 29 80 00       	push   $0x80294c
  800fec:	e8 cd f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	83 ec 10             	sub    $0x10,%esp
  80100c:	8b 75 08             	mov    0x8(%ebp),%esi
  80100f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801012:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801015:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801016:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80101c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80101f:	50                   	push   %eax
  801020:	e8 31 ff ff ff       	call   800f56 <fd_lookup>
  801025:	83 c4 08             	add    $0x8,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 05                	js     801031 <fd_close+0x2d>
	    || fd != fd2)
  80102c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80102f:	74 0c                	je     80103d <fd_close+0x39>
		return (must_exist ? r : 0);
  801031:	84 db                	test   %bl,%bl
  801033:	ba 00 00 00 00       	mov    $0x0,%edx
  801038:	0f 44 c2             	cmove  %edx,%eax
  80103b:	eb 41                	jmp    80107e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801043:	50                   	push   %eax
  801044:	ff 36                	pushl  (%esi)
  801046:	e8 61 ff ff ff       	call   800fac <dev_lookup>
  80104b:	89 c3                	mov    %eax,%ebx
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 1a                	js     80106e <fd_close+0x6a>
		if (dev->dev_close)
  801054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801057:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80105a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80105f:	85 c0                	test   %eax,%eax
  801061:	74 0b                	je     80106e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	56                   	push   %esi
  801067:	ff d0                	call   *%eax
  801069:	89 c3                	mov    %eax,%ebx
  80106b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	56                   	push   %esi
  801072:	6a 00                	push   $0x0
  801074:	e8 5a fc ff ff       	call   800cd3 <sys_page_unmap>
	return r;
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	89 d8                	mov    %ebx,%eax
}
  80107e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108e:	50                   	push   %eax
  80108f:	ff 75 08             	pushl  0x8(%ebp)
  801092:	e8 bf fe ff ff       	call   800f56 <fd_lookup>
  801097:	89 c2                	mov    %eax,%edx
  801099:	83 c4 08             	add    $0x8,%esp
  80109c:	85 d2                	test   %edx,%edx
  80109e:	78 10                	js     8010b0 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	6a 01                	push   $0x1
  8010a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a8:	e8 57 ff ff ff       	call   801004 <fd_close>
  8010ad:	83 c4 10             	add    $0x10,%esp
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <close_all>:

void
close_all(void)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	53                   	push   %ebx
  8010c2:	e8 be ff ff ff       	call   801085 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c7:	83 c3 01             	add    $0x1,%ebx
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	83 fb 20             	cmp    $0x20,%ebx
  8010d0:	75 ec                	jne    8010be <close_all+0xc>
		close(i);
}
  8010d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 2c             	sub    $0x2c,%esp
  8010e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	e8 67 fe ff ff       	call   800f56 <fd_lookup>
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	83 c4 08             	add    $0x8,%esp
  8010f4:	85 d2                	test   %edx,%edx
  8010f6:	0f 88 c1 00 00 00    	js     8011bd <dup+0xe6>
		return r;
	close(newfdnum);
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	56                   	push   %esi
  801100:	e8 80 ff ff ff       	call   801085 <close>

	newfd = INDEX2FD(newfdnum);
  801105:	89 f3                	mov    %esi,%ebx
  801107:	c1 e3 0c             	shl    $0xc,%ebx
  80110a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801110:	83 c4 04             	add    $0x4,%esp
  801113:	ff 75 e4             	pushl  -0x1c(%ebp)
  801116:	e8 d5 fd ff ff       	call   800ef0 <fd2data>
  80111b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80111d:	89 1c 24             	mov    %ebx,(%esp)
  801120:	e8 cb fd ff ff       	call   800ef0 <fd2data>
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112b:	89 f8                	mov    %edi,%eax
  80112d:	c1 e8 16             	shr    $0x16,%eax
  801130:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801137:	a8 01                	test   $0x1,%al
  801139:	74 37                	je     801172 <dup+0x9b>
  80113b:	89 f8                	mov    %edi,%eax
  80113d:	c1 e8 0c             	shr    $0xc,%eax
  801140:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 26                	je     801172 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	25 07 0e 00 00       	and    $0xe07,%eax
  80115b:	50                   	push   %eax
  80115c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115f:	6a 00                	push   $0x0
  801161:	57                   	push   %edi
  801162:	6a 00                	push   $0x0
  801164:	e8 28 fb ff ff       	call   800c91 <sys_page_map>
  801169:	89 c7                	mov    %eax,%edi
  80116b:	83 c4 20             	add    $0x20,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 2e                	js     8011a0 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801172:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801175:	89 d0                	mov    %edx,%eax
  801177:	c1 e8 0c             	shr    $0xc,%eax
  80117a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	25 07 0e 00 00       	and    $0xe07,%eax
  801189:	50                   	push   %eax
  80118a:	53                   	push   %ebx
  80118b:	6a 00                	push   $0x0
  80118d:	52                   	push   %edx
  80118e:	6a 00                	push   $0x0
  801190:	e8 fc fa ff ff       	call   800c91 <sys_page_map>
  801195:	89 c7                	mov    %eax,%edi
  801197:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80119a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119c:	85 ff                	test   %edi,%edi
  80119e:	79 1d                	jns    8011bd <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	53                   	push   %ebx
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 28 fb ff ff       	call   800cd3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ab:	83 c4 08             	add    $0x8,%esp
  8011ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011b1:	6a 00                	push   $0x0
  8011b3:	e8 1b fb ff ff       	call   800cd3 <sys_page_unmap>
	return r;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	89 f8                	mov    %edi,%eax
}
  8011bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5f                   	pop    %edi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 14             	sub    $0x14,%esp
  8011cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	53                   	push   %ebx
  8011d4:	e8 7d fd ff ff       	call   800f56 <fd_lookup>
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 6d                	js     80124f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ec:	ff 30                	pushl  (%eax)
  8011ee:	e8 b9 fd ff ff       	call   800fac <dev_lookup>
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 4c                	js     801246 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011fd:	8b 42 08             	mov    0x8(%edx),%eax
  801200:	83 e0 03             	and    $0x3,%eax
  801203:	83 f8 01             	cmp    $0x1,%eax
  801206:	75 21                	jne    801229 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801208:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80120d:	8b 40 48             	mov    0x48(%eax),%eax
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	53                   	push   %ebx
  801214:	50                   	push   %eax
  801215:	68 90 29 80 00       	push   $0x802990
  80121a:	e8 9f f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801227:	eb 26                	jmp    80124f <read+0x8a>
	}
	if (!dev->dev_read)
  801229:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122c:	8b 40 08             	mov    0x8(%eax),%eax
  80122f:	85 c0                	test   %eax,%eax
  801231:	74 17                	je     80124a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	ff 75 10             	pushl  0x10(%ebp)
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	52                   	push   %edx
  80123d:	ff d0                	call   *%eax
  80123f:	89 c2                	mov    %eax,%edx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	eb 09                	jmp    80124f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801246:	89 c2                	mov    %eax,%edx
  801248:	eb 05                	jmp    80124f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80124a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80124f:	89 d0                	mov    %edx,%eax
  801251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801262:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126a:	eb 21                	jmp    80128d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	89 f0                	mov    %esi,%eax
  801271:	29 d8                	sub    %ebx,%eax
  801273:	50                   	push   %eax
  801274:	89 d8                	mov    %ebx,%eax
  801276:	03 45 0c             	add    0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	57                   	push   %edi
  80127b:	e8 45 ff ff ff       	call   8011c5 <read>
		if (m < 0)
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	78 0c                	js     801293 <readn+0x3d>
			return m;
		if (m == 0)
  801287:	85 c0                	test   %eax,%eax
  801289:	74 06                	je     801291 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128b:	01 c3                	add    %eax,%ebx
  80128d:	39 f3                	cmp    %esi,%ebx
  80128f:	72 db                	jb     80126c <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801291:	89 d8                	mov    %ebx,%eax
}
  801293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801296:	5b                   	pop    %ebx
  801297:	5e                   	pop    %esi
  801298:	5f                   	pop    %edi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 14             	sub    $0x14,%esp
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	53                   	push   %ebx
  8012aa:	e8 a7 fc ff ff       	call   800f56 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 68                	js     801320 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	ff 30                	pushl  (%eax)
  8012c4:	e8 e3 fc ff ff       	call   800fac <dev_lookup>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 47                	js     801317 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d7:	75 21                	jne    8012fa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012de:	8b 40 48             	mov    0x48(%eax),%eax
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	50                   	push   %eax
  8012e6:	68 ac 29 80 00       	push   $0x8029ac
  8012eb:	e8 ce ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f8:	eb 26                	jmp    801320 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801300:	85 d2                	test   %edx,%edx
  801302:	74 17                	je     80131b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	ff 75 10             	pushl  0x10(%ebp)
  80130a:	ff 75 0c             	pushl  0xc(%ebp)
  80130d:	50                   	push   %eax
  80130e:	ff d2                	call   *%edx
  801310:	89 c2                	mov    %eax,%edx
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	eb 09                	jmp    801320 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801317:	89 c2                	mov    %eax,%edx
  801319:	eb 05                	jmp    801320 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80131b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801320:	89 d0                	mov    %edx,%eax
  801322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <seek>:

int
seek(int fdnum, off_t offset)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 75 08             	pushl  0x8(%ebp)
  801334:	e8 1d fc ff ff       	call   800f56 <fd_lookup>
  801339:	83 c4 08             	add    $0x8,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 0e                	js     80134e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801340:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801343:	8b 55 0c             	mov    0xc(%ebp),%edx
  801346:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	53                   	push   %ebx
  801354:	83 ec 14             	sub    $0x14,%esp
  801357:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	53                   	push   %ebx
  80135f:	e8 f2 fb ff ff       	call   800f56 <fd_lookup>
  801364:	83 c4 08             	add    $0x8,%esp
  801367:	89 c2                	mov    %eax,%edx
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 65                	js     8013d2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801377:	ff 30                	pushl  (%eax)
  801379:	e8 2e fc ff ff       	call   800fac <dev_lookup>
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	78 44                	js     8013c9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801385:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801388:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80138c:	75 21                	jne    8013af <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80138e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801393:	8b 40 48             	mov    0x48(%eax),%eax
  801396:	83 ec 04             	sub    $0x4,%esp
  801399:	53                   	push   %ebx
  80139a:	50                   	push   %eax
  80139b:	68 6c 29 80 00       	push   $0x80296c
  8013a0:	e8 19 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ad:	eb 23                	jmp    8013d2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b2:	8b 52 18             	mov    0x18(%edx),%edx
  8013b5:	85 d2                	test   %edx,%edx
  8013b7:	74 14                	je     8013cd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	ff 75 0c             	pushl  0xc(%ebp)
  8013bf:	50                   	push   %eax
  8013c0:	ff d2                	call   *%edx
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	eb 09                	jmp    8013d2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	eb 05                	jmp    8013d2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013d2:	89 d0                	mov    %edx,%eax
  8013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	53                   	push   %ebx
  8013dd:	83 ec 14             	sub    $0x14,%esp
  8013e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	ff 75 08             	pushl  0x8(%ebp)
  8013ea:	e8 67 fb ff ff       	call   800f56 <fd_lookup>
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 58                	js     801450 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	ff 30                	pushl  (%eax)
  801404:	e8 a3 fb ff ff       	call   800fac <dev_lookup>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 37                	js     801447 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801413:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801417:	74 32                	je     80144b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801419:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80141c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801423:	00 00 00 
	stat->st_isdir = 0;
  801426:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80142d:	00 00 00 
	stat->st_dev = dev;
  801430:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	53                   	push   %ebx
  80143a:	ff 75 f0             	pushl  -0x10(%ebp)
  80143d:	ff 50 14             	call   *0x14(%eax)
  801440:	89 c2                	mov    %eax,%edx
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb 09                	jmp    801450 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801447:	89 c2                	mov    %eax,%edx
  801449:	eb 05                	jmp    801450 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80144b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801450:	89 d0                	mov    %edx,%eax
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	6a 00                	push   $0x0
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 09 02 00 00       	call   801672 <open>
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 db                	test   %ebx,%ebx
  801470:	78 1b                	js     80148d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	53                   	push   %ebx
  801479:	e8 5b ff ff ff       	call   8013d9 <fstat>
  80147e:	89 c6                	mov    %eax,%esi
	close(fd);
  801480:	89 1c 24             	mov    %ebx,(%esp)
  801483:	e8 fd fb ff ff       	call   801085 <close>
	return r;
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	89 f0                	mov    %esi,%eax
}
  80148d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    

00801494 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	89 c6                	mov    %eax,%esi
  80149b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80149d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014a4:	75 12                	jne    8014b8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	6a 01                	push   $0x1
  8014ab:	e8 80 0d 00 00       	call   802230 <ipc_find_env>
  8014b0:	a3 04 40 80 00       	mov    %eax,0x804004
  8014b5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014b8:	6a 07                	push   $0x7
  8014ba:	68 00 50 80 00       	push   $0x805000
  8014bf:	56                   	push   %esi
  8014c0:	ff 35 04 40 80 00    	pushl  0x804004
  8014c6:	e8 11 0d 00 00       	call   8021dc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014cb:	83 c4 0c             	add    $0xc,%esp
  8014ce:	6a 00                	push   $0x0
  8014d0:	53                   	push   %ebx
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 9b 0c 00 00       	call   802173 <ipc_recv>
}
  8014d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014eb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 02 00 00 00       	mov    $0x2,%eax
  801502:	e8 8d ff ff ff       	call   801494 <fsipc>
}
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	8b 40 0c             	mov    0xc(%eax),%eax
  801515:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80151a:	ba 00 00 00 00       	mov    $0x0,%edx
  80151f:	b8 06 00 00 00       	mov    $0x6,%eax
  801524:	e8 6b ff ff ff       	call   801494 <fsipc>
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	8b 40 0c             	mov    0xc(%eax),%eax
  80153b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
  801545:	b8 05 00 00 00       	mov    $0x5,%eax
  80154a:	e8 45 ff ff ff       	call   801494 <fsipc>
  80154f:	89 c2                	mov    %eax,%edx
  801551:	85 d2                	test   %edx,%edx
  801553:	78 2c                	js     801581 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	68 00 50 80 00       	push   $0x805000
  80155d:	53                   	push   %ebx
  80155e:	e8 e2 f2 ff ff       	call   800845 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801563:	a1 80 50 80 00       	mov    0x805080,%eax
  801568:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80156e:	a1 84 50 80 00       	mov    0x805084,%eax
  801573:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	57                   	push   %edi
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	8b 40 0c             	mov    0xc(%eax),%eax
  801598:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015a0:	eb 3d                	jmp    8015df <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8015a2:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8015a8:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8015ad:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	57                   	push   %edi
  8015b4:	53                   	push   %ebx
  8015b5:	68 08 50 80 00       	push   $0x805008
  8015ba:	e8 18 f4 ff ff       	call   8009d7 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8015bf:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8015cf:	e8 c0 fe ff ff       	call   801494 <fsipc>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 0d                	js     8015e8 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8015db:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8015dd:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015df:	85 f6                	test   %esi,%esi
  8015e1:	75 bf                	jne    8015a2 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8015e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801603:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801609:	ba 00 00 00 00       	mov    $0x0,%edx
  80160e:	b8 03 00 00 00       	mov    $0x3,%eax
  801613:	e8 7c fe ff ff       	call   801494 <fsipc>
  801618:	89 c3                	mov    %eax,%ebx
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 4b                	js     801669 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80161e:	39 c6                	cmp    %eax,%esi
  801620:	73 16                	jae    801638 <devfile_read+0x48>
  801622:	68 e0 29 80 00       	push   $0x8029e0
  801627:	68 e7 29 80 00       	push   $0x8029e7
  80162c:	6a 7c                	push   $0x7c
  80162e:	68 fc 29 80 00       	push   $0x8029fc
  801633:	e8 ad eb ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  801638:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80163d:	7e 16                	jle    801655 <devfile_read+0x65>
  80163f:	68 07 2a 80 00       	push   $0x802a07
  801644:	68 e7 29 80 00       	push   $0x8029e7
  801649:	6a 7d                	push   $0x7d
  80164b:	68 fc 29 80 00       	push   $0x8029fc
  801650:	e8 90 eb ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	50                   	push   %eax
  801659:	68 00 50 80 00       	push   $0x805000
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	e8 71 f3 ff ff       	call   8009d7 <memmove>
	return r;
  801666:	83 c4 10             	add    $0x10,%esp
}
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	83 ec 20             	sub    $0x20,%esp
  801679:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80167c:	53                   	push   %ebx
  80167d:	e8 8a f1 ff ff       	call   80080c <strlen>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80168a:	7f 67                	jg     8016f3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	e8 6f f8 ff ff       	call   800f07 <fd_alloc>
  801698:	83 c4 10             	add    $0x10,%esp
		return r;
  80169b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 57                	js     8016f8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	68 00 50 80 00       	push   $0x805000
  8016aa:	e8 96 f1 ff ff       	call   800845 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8016bf:	e8 d0 fd ff ff       	call   801494 <fsipc>
  8016c4:	89 c3                	mov    %eax,%ebx
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	79 14                	jns    8016e1 <open+0x6f>
		fd_close(fd, 0);
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	6a 00                	push   $0x0
  8016d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d5:	e8 2a f9 ff ff       	call   801004 <fd_close>
		return r;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	89 da                	mov    %ebx,%edx
  8016df:	eb 17                	jmp    8016f8 <open+0x86>
	}

	return fd2num(fd);
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e7:	e8 f4 f7 ff ff       	call   800ee0 <fd2num>
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	eb 05                	jmp    8016f8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016f3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 08 00 00 00       	mov    $0x8,%eax
  80170f:	e8 80 fd ff ff       	call   801494 <fsipc>
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801716:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80171a:	7e 37                	jle    801753 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801725:	ff 70 04             	pushl  0x4(%eax)
  801728:	8d 40 10             	lea    0x10(%eax),%eax
  80172b:	50                   	push   %eax
  80172c:	ff 33                	pushl  (%ebx)
  80172e:	e8 68 fb ff ff       	call   80129b <write>
		if (result > 0)
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	85 c0                	test   %eax,%eax
  801738:	7e 03                	jle    80173d <writebuf+0x27>
			b->result += result;
  80173a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80173d:	39 43 04             	cmp    %eax,0x4(%ebx)
  801740:	74 0d                	je     80174f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801742:	85 c0                	test   %eax,%eax
  801744:	ba 00 00 00 00       	mov    $0x0,%edx
  801749:	0f 4f c2             	cmovg  %edx,%eax
  80174c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801752:	c9                   	leave  
  801753:	f3 c3                	repz ret 

00801755 <putch>:

static void
putch(int ch, void *thunk)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 04             	sub    $0x4,%esp
  80175c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80175f:	8b 53 04             	mov    0x4(%ebx),%edx
  801762:	8d 42 01             	lea    0x1(%edx),%eax
  801765:	89 43 04             	mov    %eax,0x4(%ebx)
  801768:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80176f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801774:	75 0e                	jne    801784 <putch+0x2f>
		writebuf(b);
  801776:	89 d8                	mov    %ebx,%eax
  801778:	e8 99 ff ff ff       	call   801716 <writebuf>
		b->idx = 0;
  80177d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801784:	83 c4 04             	add    $0x4,%esp
  801787:	5b                   	pop    %ebx
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80179c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017a3:	00 00 00 
	b.result = 0;
  8017a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017ad:	00 00 00 
	b.error = 1;
  8017b0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017b7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017ba:	ff 75 10             	pushl  0x10(%ebp)
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	68 55 17 80 00       	push   $0x801755
  8017cc:	e8 1f ec ff ff       	call   8003f0 <vprintfmt>
	if (b.idx > 0)
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017db:	7e 0b                	jle    8017e8 <vfprintf+0x5e>
		writebuf(&b);
  8017dd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017e3:	e8 2e ff ff ff       	call   801716 <writebuf>

	return (b.result ? b.result : b.error);
  8017e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ff:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801802:	50                   	push   %eax
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	ff 75 08             	pushl  0x8(%ebp)
  801809:	e8 7c ff ff ff       	call   80178a <vfprintf>
	va_end(ap);

	return cnt;
}
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <printf>:

int
printf(const char *fmt, ...)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801816:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801819:	50                   	push   %eax
  80181a:	ff 75 08             	pushl  0x8(%ebp)
  80181d:	6a 01                	push   $0x1
  80181f:	e8 66 ff ff ff       	call   80178a <vfprintf>
	va_end(ap);

	return cnt;
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80182c:	68 13 2a 80 00       	push   $0x802a13
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	e8 0c f0 ff ff       	call   800845 <strcpy>
	return 0;
}
  801839:	b8 00 00 00 00       	mov    $0x0,%eax
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 10             	sub    $0x10,%esp
  801847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80184a:	53                   	push   %ebx
  80184b:	e8 18 0a 00 00       	call   802268 <pageref>
  801850:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801858:	83 f8 01             	cmp    $0x1,%eax
  80185b:	75 10                	jne    80186d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	ff 73 0c             	pushl  0xc(%ebx)
  801863:	e8 ca 02 00 00       	call   801b32 <nsipc_close>
  801868:	89 c2                	mov    %eax,%edx
  80186a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80186d:	89 d0                	mov    %edx,%eax
  80186f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80187a:	6a 00                	push   $0x0
  80187c:	ff 75 10             	pushl  0x10(%ebp)
  80187f:	ff 75 0c             	pushl  0xc(%ebp)
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	ff 70 0c             	pushl  0xc(%eax)
  801888:	e8 82 03 00 00       	call   801c0f <nsipc_send>
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801895:	6a 00                	push   $0x0
  801897:	ff 75 10             	pushl  0x10(%ebp)
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a0:	ff 70 0c             	pushl  0xc(%eax)
  8018a3:	e8 fb 02 00 00       	call   801ba3 <nsipc_recv>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018b0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018b3:	52                   	push   %edx
  8018b4:	50                   	push   %eax
  8018b5:	e8 9c f6 ff ff       	call   800f56 <fd_lookup>
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 17                	js     8018d8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c4:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  8018ca:	39 08                	cmp    %ecx,(%eax)
  8018cc:	75 05                	jne    8018d3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d1:	eb 05                	jmp    8018d8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	83 ec 1c             	sub    $0x1c,%esp
  8018e2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e7:	50                   	push   %eax
  8018e8:	e8 1a f6 ff ff       	call   800f07 <fd_alloc>
  8018ed:	89 c3                	mov    %eax,%ebx
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 1b                	js     801911 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	68 07 04 00 00       	push   $0x407
  8018fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801901:	6a 00                	push   $0x0
  801903:	e8 46 f3 ff ff       	call   800c4e <sys_page_alloc>
  801908:	89 c3                	mov    %eax,%ebx
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	79 10                	jns    801921 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801911:	83 ec 0c             	sub    $0xc,%esp
  801914:	56                   	push   %esi
  801915:	e8 18 02 00 00       	call   801b32 <nsipc_close>
		return r;
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	89 d8                	mov    %ebx,%eax
  80191f:	eb 24                	jmp    801945 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801921:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80192c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192f:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801936:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801939:	83 ec 0c             	sub    $0xc,%esp
  80193c:	52                   	push   %edx
  80193d:	e8 9e f5 ff ff       	call   800ee0 <fd2num>
  801942:	83 c4 10             	add    $0x10,%esp
}
  801945:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	e8 50 ff ff ff       	call   8018aa <fd2sockid>
		return r;
  80195a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 1f                	js     80197f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	ff 75 10             	pushl  0x10(%ebp)
  801966:	ff 75 0c             	pushl  0xc(%ebp)
  801969:	50                   	push   %eax
  80196a:	e8 1c 01 00 00       	call   801a8b <nsipc_accept>
  80196f:	83 c4 10             	add    $0x10,%esp
		return r;
  801972:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801974:	85 c0                	test   %eax,%eax
  801976:	78 07                	js     80197f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801978:	e8 5d ff ff ff       	call   8018da <alloc_sockfd>
  80197d:	89 c1                	mov    %eax,%ecx
}
  80197f:	89 c8                	mov    %ecx,%eax
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801989:	8b 45 08             	mov    0x8(%ebp),%eax
  80198c:	e8 19 ff ff ff       	call   8018aa <fd2sockid>
  801991:	89 c2                	mov    %eax,%edx
  801993:	85 d2                	test   %edx,%edx
  801995:	78 12                	js     8019a9 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801997:	83 ec 04             	sub    $0x4,%esp
  80199a:	ff 75 10             	pushl  0x10(%ebp)
  80199d:	ff 75 0c             	pushl  0xc(%ebp)
  8019a0:	52                   	push   %edx
  8019a1:	e8 35 01 00 00       	call   801adb <nsipc_bind>
  8019a6:	83 c4 10             	add    $0x10,%esp
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <shutdown>:

int
shutdown(int s, int how)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	e8 f1 fe ff ff       	call   8018aa <fd2sockid>
  8019b9:	89 c2                	mov    %eax,%edx
  8019bb:	85 d2                	test   %edx,%edx
  8019bd:	78 0f                	js     8019ce <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	ff 75 0c             	pushl  0xc(%ebp)
  8019c5:	52                   	push   %edx
  8019c6:	e8 45 01 00 00       	call   801b10 <nsipc_shutdown>
  8019cb:	83 c4 10             	add    $0x10,%esp
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	e8 cc fe ff ff       	call   8018aa <fd2sockid>
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	85 d2                	test   %edx,%edx
  8019e2:	78 12                	js     8019f6 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  8019e4:	83 ec 04             	sub    $0x4,%esp
  8019e7:	ff 75 10             	pushl  0x10(%ebp)
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	52                   	push   %edx
  8019ee:	e8 59 01 00 00       	call   801b4c <nsipc_connect>
  8019f3:	83 c4 10             	add    $0x10,%esp
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <listen>:

int
listen(int s, int backlog)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	e8 a4 fe ff ff       	call   8018aa <fd2sockid>
  801a06:	89 c2                	mov    %eax,%edx
  801a08:	85 d2                	test   %edx,%edx
  801a0a:	78 0f                	js     801a1b <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	ff 75 0c             	pushl  0xc(%ebp)
  801a12:	52                   	push   %edx
  801a13:	e8 69 01 00 00       	call   801b81 <nsipc_listen>
  801a18:	83 c4 10             	add    $0x10,%esp
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a23:	ff 75 10             	pushl  0x10(%ebp)
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	e8 3c 02 00 00       	call   801c6d <nsipc_socket>
  801a31:	89 c2                	mov    %eax,%edx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 d2                	test   %edx,%edx
  801a38:	78 05                	js     801a3f <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801a3a:	e8 9b fe ff ff       	call   8018da <alloc_sockfd>
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 04             	sub    $0x4,%esp
  801a48:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a4a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801a51:	75 12                	jne    801a65 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	6a 02                	push   $0x2
  801a58:	e8 d3 07 00 00       	call   802230 <ipc_find_env>
  801a5d:	a3 08 40 80 00       	mov    %eax,0x804008
  801a62:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a65:	6a 07                	push   $0x7
  801a67:	68 00 60 80 00       	push   $0x806000
  801a6c:	53                   	push   %ebx
  801a6d:	ff 35 08 40 80 00    	pushl  0x804008
  801a73:	e8 64 07 00 00       	call   8021dc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a78:	83 c4 0c             	add    $0xc,%esp
  801a7b:	6a 00                	push   $0x0
  801a7d:	6a 00                	push   $0x0
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 ed 06 00 00       	call   802173 <ipc_recv>
}
  801a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a9b:	8b 06                	mov    (%esi),%eax
  801a9d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa7:	e8 95 ff ff ff       	call   801a41 <nsipc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 20                	js     801ad2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	ff 35 10 60 80 00    	pushl  0x806010
  801abb:	68 00 60 80 00       	push   $0x806000
  801ac0:	ff 75 0c             	pushl  0xc(%ebp)
  801ac3:	e8 0f ef ff ff       	call   8009d7 <memmove>
		*addrlen = ret->ret_addrlen;
  801ac8:	a1 10 60 80 00       	mov    0x806010,%eax
  801acd:	89 06                	mov    %eax,(%esi)
  801acf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ad2:	89 d8                	mov    %ebx,%eax
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801aed:	53                   	push   %ebx
  801aee:	ff 75 0c             	pushl  0xc(%ebp)
  801af1:	68 04 60 80 00       	push   $0x806004
  801af6:	e8 dc ee ff ff       	call   8009d7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801afb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b01:	b8 02 00 00 00       	mov    $0x2,%eax
  801b06:	e8 36 ff ff ff       	call   801a41 <nsipc>
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b21:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b26:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2b:	e8 11 ff ff ff       	call   801a41 <nsipc>
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <nsipc_close>:

int
nsipc_close(int s)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b40:	b8 04 00 00 00       	mov    $0x4,%eax
  801b45:	e8 f7 fe ff ff       	call   801a41 <nsipc>
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 08             	sub    $0x8,%esp
  801b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b5e:	53                   	push   %ebx
  801b5f:	ff 75 0c             	pushl  0xc(%ebp)
  801b62:	68 04 60 80 00       	push   $0x806004
  801b67:	e8 6b ee ff ff       	call   8009d7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b6c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b72:	b8 05 00 00 00       	mov    $0x5,%eax
  801b77:	e8 c5 fe ff ff       	call   801a41 <nsipc>
}
  801b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b97:	b8 06 00 00 00       	mov    $0x6,%eax
  801b9c:	e8 a0 fe ff ff       	call   801a41 <nsipc>
}
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bb3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bc1:	b8 07 00 00 00       	mov    $0x7,%eax
  801bc6:	e8 76 fe ff ff       	call   801a41 <nsipc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 35                	js     801c06 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bd1:	39 f0                	cmp    %esi,%eax
  801bd3:	7f 07                	jg     801bdc <nsipc_recv+0x39>
  801bd5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bda:	7e 16                	jle    801bf2 <nsipc_recv+0x4f>
  801bdc:	68 1f 2a 80 00       	push   $0x802a1f
  801be1:	68 e7 29 80 00       	push   $0x8029e7
  801be6:	6a 62                	push   $0x62
  801be8:	68 34 2a 80 00       	push   $0x802a34
  801bed:	e8 f3 e5 ff ff       	call   8001e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bf2:	83 ec 04             	sub    $0x4,%esp
  801bf5:	50                   	push   %eax
  801bf6:	68 00 60 80 00       	push   $0x806000
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	e8 d4 ed ff ff       	call   8009d7 <memmove>
  801c03:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	53                   	push   %ebx
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c21:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c27:	7e 16                	jle    801c3f <nsipc_send+0x30>
  801c29:	68 40 2a 80 00       	push   $0x802a40
  801c2e:	68 e7 29 80 00       	push   $0x8029e7
  801c33:	6a 6d                	push   $0x6d
  801c35:	68 34 2a 80 00       	push   $0x802a34
  801c3a:	e8 a6 e5 ff ff       	call   8001e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	53                   	push   %ebx
  801c43:	ff 75 0c             	pushl  0xc(%ebp)
  801c46:	68 0c 60 80 00       	push   $0x80600c
  801c4b:	e8 87 ed ff ff       	call   8009d7 <memmove>
	nsipcbuf.send.req_size = size;
  801c50:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c56:	8b 45 14             	mov    0x14(%ebp),%eax
  801c59:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c63:	e8 d9 fd ff ff       	call   801a41 <nsipc>
}
  801c68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c83:	8b 45 10             	mov    0x10(%ebp),%eax
  801c86:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c8b:	b8 09 00 00 00       	mov    $0x9,%eax
  801c90:	e8 ac fd ff ff       	call   801a41 <nsipc>
}
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	ff 75 08             	pushl  0x8(%ebp)
  801ca5:	e8 46 f2 ff ff       	call   800ef0 <fd2data>
  801caa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cac:	83 c4 08             	add    $0x8,%esp
  801caf:	68 4c 2a 80 00       	push   $0x802a4c
  801cb4:	53                   	push   %ebx
  801cb5:	e8 8b eb ff ff       	call   800845 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cba:	8b 56 04             	mov    0x4(%esi),%edx
  801cbd:	89 d0                	mov    %edx,%eax
  801cbf:	2b 06                	sub    (%esi),%eax
  801cc1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cc7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cce:	00 00 00 
	stat->st_dev = &devpipe;
  801cd1:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801cd8:	30 80 00 
	return 0;
}
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	53                   	push   %ebx
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf1:	53                   	push   %ebx
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 da ef ff ff       	call   800cd3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf9:	89 1c 24             	mov    %ebx,(%esp)
  801cfc:	e8 ef f1 ff ff       	call   800ef0 <fd2data>
  801d01:	83 c4 08             	add    $0x8,%esp
  801d04:	50                   	push   %eax
  801d05:	6a 00                	push   $0x0
  801d07:	e8 c7 ef ff ff       	call   800cd3 <sys_page_unmap>
}
  801d0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    

00801d11 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	83 ec 1c             	sub    $0x1c,%esp
  801d1a:	89 c6                	mov    %eax,%esi
  801d1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d1f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801d24:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	56                   	push   %esi
  801d2b:	e8 38 05 00 00       	call   802268 <pageref>
  801d30:	89 c7                	mov    %eax,%edi
  801d32:	83 c4 04             	add    $0x4,%esp
  801d35:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d38:	e8 2b 05 00 00       	call   802268 <pageref>
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	39 c7                	cmp    %eax,%edi
  801d42:	0f 94 c2             	sete   %dl
  801d45:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d48:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801d4e:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d51:	39 fb                	cmp    %edi,%ebx
  801d53:	74 19                	je     801d6e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801d55:	84 d2                	test   %dl,%dl
  801d57:	74 c6                	je     801d1f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d59:	8b 51 58             	mov    0x58(%ecx),%edx
  801d5c:	50                   	push   %eax
  801d5d:	52                   	push   %edx
  801d5e:	53                   	push   %ebx
  801d5f:	68 53 2a 80 00       	push   $0x802a53
  801d64:	e8 55 e5 ff ff       	call   8002be <cprintf>
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	eb b1                	jmp    801d1f <_pipeisclosed+0xe>
	}
}
  801d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d71:	5b                   	pop    %ebx
  801d72:	5e                   	pop    %esi
  801d73:	5f                   	pop    %edi
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	57                   	push   %edi
  801d7a:	56                   	push   %esi
  801d7b:	53                   	push   %ebx
  801d7c:	83 ec 28             	sub    $0x28,%esp
  801d7f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d82:	56                   	push   %esi
  801d83:	e8 68 f1 ff ff       	call   800ef0 <fd2data>
  801d88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d92:	eb 4b                	jmp    801ddf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d94:	89 da                	mov    %ebx,%edx
  801d96:	89 f0                	mov    %esi,%eax
  801d98:	e8 74 ff ff ff       	call   801d11 <_pipeisclosed>
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	75 48                	jne    801de9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801da1:	e8 89 ee ff ff       	call   800c2f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801da6:	8b 43 04             	mov    0x4(%ebx),%eax
  801da9:	8b 0b                	mov    (%ebx),%ecx
  801dab:	8d 51 20             	lea    0x20(%ecx),%edx
  801dae:	39 d0                	cmp    %edx,%eax
  801db0:	73 e2                	jae    801d94 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801db9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dbc:	89 c2                	mov    %eax,%edx
  801dbe:	c1 fa 1f             	sar    $0x1f,%edx
  801dc1:	89 d1                	mov    %edx,%ecx
  801dc3:	c1 e9 1b             	shr    $0x1b,%ecx
  801dc6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dc9:	83 e2 1f             	and    $0x1f,%edx
  801dcc:	29 ca                	sub    %ecx,%edx
  801dce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dd2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dd6:	83 c0 01             	add    $0x1,%eax
  801dd9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddc:	83 c7 01             	add    $0x1,%edi
  801ddf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de2:	75 c2                	jne    801da6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801de4:	8b 45 10             	mov    0x10(%ebp),%eax
  801de7:	eb 05                	jmp    801dee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df1:	5b                   	pop    %ebx
  801df2:	5e                   	pop    %esi
  801df3:	5f                   	pop    %edi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	57                   	push   %edi
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	83 ec 18             	sub    $0x18,%esp
  801dff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e02:	57                   	push   %edi
  801e03:	e8 e8 f0 ff ff       	call   800ef0 <fd2data>
  801e08:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e12:	eb 3d                	jmp    801e51 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e14:	85 db                	test   %ebx,%ebx
  801e16:	74 04                	je     801e1c <devpipe_read+0x26>
				return i;
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	eb 44                	jmp    801e60 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e1c:	89 f2                	mov    %esi,%edx
  801e1e:	89 f8                	mov    %edi,%eax
  801e20:	e8 ec fe ff ff       	call   801d11 <_pipeisclosed>
  801e25:	85 c0                	test   %eax,%eax
  801e27:	75 32                	jne    801e5b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e29:	e8 01 ee ff ff       	call   800c2f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e2e:	8b 06                	mov    (%esi),%eax
  801e30:	3b 46 04             	cmp    0x4(%esi),%eax
  801e33:	74 df                	je     801e14 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e35:	99                   	cltd   
  801e36:	c1 ea 1b             	shr    $0x1b,%edx
  801e39:	01 d0                	add    %edx,%eax
  801e3b:	83 e0 1f             	and    $0x1f,%eax
  801e3e:	29 d0                	sub    %edx,%eax
  801e40:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e48:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e4b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4e:	83 c3 01             	add    $0x1,%ebx
  801e51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e54:	75 d8                	jne    801e2e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e56:	8b 45 10             	mov    0x10(%ebp),%eax
  801e59:	eb 05                	jmp    801e60 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e73:	50                   	push   %eax
  801e74:	e8 8e f0 ff ff       	call   800f07 <fd_alloc>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	0f 88 2c 01 00 00    	js     801fb2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e86:	83 ec 04             	sub    $0x4,%esp
  801e89:	68 07 04 00 00       	push   $0x407
  801e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e91:	6a 00                	push   $0x0
  801e93:	e8 b6 ed ff ff       	call   800c4e <sys_page_alloc>
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	89 c2                	mov    %eax,%edx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 0d 01 00 00    	js     801fb2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	e8 56 f0 ff ff       	call   800f07 <fd_alloc>
  801eb1:	89 c3                	mov    %eax,%ebx
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	0f 88 e2 00 00 00    	js     801fa0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebe:	83 ec 04             	sub    $0x4,%esp
  801ec1:	68 07 04 00 00       	push   $0x407
  801ec6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 7e ed ff ff       	call   800c4e <sys_page_alloc>
  801ed0:	89 c3                	mov    %eax,%ebx
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	0f 88 c3 00 00 00    	js     801fa0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee3:	e8 08 f0 ff ff       	call   800ef0 <fd2data>
  801ee8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eea:	83 c4 0c             	add    $0xc,%esp
  801eed:	68 07 04 00 00       	push   $0x407
  801ef2:	50                   	push   %eax
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 54 ed ff ff       	call   800c4e <sys_page_alloc>
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	0f 88 89 00 00 00    	js     801f90 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0d:	e8 de ef ff ff       	call   800ef0 <fd2data>
  801f12:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f19:	50                   	push   %eax
  801f1a:	6a 00                	push   $0x0
  801f1c:	56                   	push   %esi
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 6d ed ff ff       	call   800c91 <sys_page_map>
  801f24:	89 c3                	mov    %eax,%ebx
  801f26:	83 c4 20             	add    $0x20,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 55                	js     801f82 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f2d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f36:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f42:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f50:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f57:	83 ec 0c             	sub    $0xc,%esp
  801f5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5d:	e8 7e ef ff ff       	call   800ee0 <fd2num>
  801f62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f65:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f67:	83 c4 04             	add    $0x4,%esp
  801f6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6d:	e8 6e ef ff ff       	call   800ee0 <fd2num>
  801f72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f75:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f80:	eb 30                	jmp    801fb2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f82:	83 ec 08             	sub    $0x8,%esp
  801f85:	56                   	push   %esi
  801f86:	6a 00                	push   $0x0
  801f88:	e8 46 ed ff ff       	call   800cd3 <sys_page_unmap>
  801f8d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f90:	83 ec 08             	sub    $0x8,%esp
  801f93:	ff 75 f0             	pushl  -0x10(%ebp)
  801f96:	6a 00                	push   $0x0
  801f98:	e8 36 ed ff ff       	call   800cd3 <sys_page_unmap>
  801f9d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fa0:	83 ec 08             	sub    $0x8,%esp
  801fa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 26 ed ff ff       	call   800cd3 <sys_page_unmap>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc4:	50                   	push   %eax
  801fc5:	ff 75 08             	pushl  0x8(%ebp)
  801fc8:	e8 89 ef ff ff       	call   800f56 <fd_lookup>
  801fcd:	89 c2                	mov    %eax,%edx
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	85 d2                	test   %edx,%edx
  801fd4:	78 18                	js     801fee <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdc:	e8 0f ef ff ff       	call   800ef0 <fd2data>
	return _pipeisclosed(fd, p);
  801fe1:	89 c2                	mov    %eax,%edx
  801fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe6:	e8 26 fd ff ff       	call   801d11 <_pipeisclosed>
  801feb:	83 c4 10             	add    $0x10,%esp
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802000:	68 6b 2a 80 00       	push   $0x802a6b
  802005:	ff 75 0c             	pushl  0xc(%ebp)
  802008:	e8 38 e8 ff ff       	call   800845 <strcpy>
	return 0;
}
  80200d:	b8 00 00 00 00       	mov    $0x0,%eax
  802012:	c9                   	leave  
  802013:	c3                   	ret    

00802014 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	57                   	push   %edi
  802018:	56                   	push   %esi
  802019:	53                   	push   %ebx
  80201a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802020:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802025:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202b:	eb 2d                	jmp    80205a <devcons_write+0x46>
		m = n - tot;
  80202d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802030:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802032:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802035:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80203a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80203d:	83 ec 04             	sub    $0x4,%esp
  802040:	53                   	push   %ebx
  802041:	03 45 0c             	add    0xc(%ebp),%eax
  802044:	50                   	push   %eax
  802045:	57                   	push   %edi
  802046:	e8 8c e9 ff ff       	call   8009d7 <memmove>
		sys_cputs(buf, m);
  80204b:	83 c4 08             	add    $0x8,%esp
  80204e:	53                   	push   %ebx
  80204f:	57                   	push   %edi
  802050:	e8 3d eb ff ff       	call   800b92 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802055:	01 de                	add    %ebx,%esi
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	89 f0                	mov    %esi,%eax
  80205c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80205f:	72 cc                	jb     80202d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802074:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802078:	75 07                	jne    802081 <devcons_read+0x18>
  80207a:	eb 28                	jmp    8020a4 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80207c:	e8 ae eb ff ff       	call   800c2f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802081:	e8 2a eb ff ff       	call   800bb0 <sys_cgetc>
  802086:	85 c0                	test   %eax,%eax
  802088:	74 f2                	je     80207c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 16                	js     8020a4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80208e:	83 f8 04             	cmp    $0x4,%eax
  802091:	74 0c                	je     80209f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802093:	8b 55 0c             	mov    0xc(%ebp),%edx
  802096:	88 02                	mov    %al,(%edx)
	return 1;
  802098:	b8 01 00 00 00       	mov    $0x1,%eax
  80209d:	eb 05                	jmp    8020a4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80209f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8020af:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020b2:	6a 01                	push   $0x1
  8020b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b7:	50                   	push   %eax
  8020b8:	e8 d5 ea ff ff       	call   800b92 <sys_cputs>
  8020bd:	83 c4 10             	add    $0x10,%esp
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <getchar>:

int
getchar(void)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020c8:	6a 01                	push   $0x1
  8020ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020cd:	50                   	push   %eax
  8020ce:	6a 00                	push   $0x0
  8020d0:	e8 f0 f0 ff ff       	call   8011c5 <read>
	if (r < 0)
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 0f                	js     8020eb <getchar+0x29>
		return r;
	if (r < 1)
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	7e 06                	jle    8020e6 <getchar+0x24>
		return -E_EOF;
	return c;
  8020e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e4:	eb 05                	jmp    8020eb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    

008020ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	50                   	push   %eax
  8020f7:	ff 75 08             	pushl  0x8(%ebp)
  8020fa:	e8 57 ee ff ff       	call   800f56 <fd_lookup>
  8020ff:	83 c4 10             	add    $0x10,%esp
  802102:	85 c0                	test   %eax,%eax
  802104:	78 11                	js     802117 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802106:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802109:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80210f:	39 10                	cmp    %edx,(%eax)
  802111:	0f 94 c0             	sete   %al
  802114:	0f b6 c0             	movzbl %al,%eax
}
  802117:	c9                   	leave  
  802118:	c3                   	ret    

00802119 <opencons>:

int
opencons(void)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80211f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802122:	50                   	push   %eax
  802123:	e8 df ed ff ff       	call   800f07 <fd_alloc>
  802128:	83 c4 10             	add    $0x10,%esp
		return r;
  80212b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 3e                	js     80216f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802131:	83 ec 04             	sub    $0x4,%esp
  802134:	68 07 04 00 00       	push   $0x407
  802139:	ff 75 f4             	pushl  -0xc(%ebp)
  80213c:	6a 00                	push   $0x0
  80213e:	e8 0b eb ff ff       	call   800c4e <sys_page_alloc>
  802143:	83 c4 10             	add    $0x10,%esp
		return r;
  802146:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 23                	js     80216f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80214c:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802155:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802161:	83 ec 0c             	sub    $0xc,%esp
  802164:	50                   	push   %eax
  802165:	e8 76 ed ff ff       	call   800ee0 <fd2num>
  80216a:	89 c2                	mov    %eax,%edx
  80216c:	83 c4 10             	add    $0x10,%esp
}
  80216f:	89 d0                	mov    %edx,%eax
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
  802178:	8b 75 08             	mov    0x8(%ebp),%esi
  80217b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802181:	85 c0                	test   %eax,%eax
  802183:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802188:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80218b:	83 ec 0c             	sub    $0xc,%esp
  80218e:	50                   	push   %eax
  80218f:	e8 6a ec ff ff       	call   800dfe <sys_ipc_recv>
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	79 16                	jns    8021b1 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80219b:	85 f6                	test   %esi,%esi
  80219d:	74 06                	je     8021a5 <ipc_recv+0x32>
  80219f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8021a5:	85 db                	test   %ebx,%ebx
  8021a7:	74 2c                	je     8021d5 <ipc_recv+0x62>
  8021a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021af:	eb 24                	jmp    8021d5 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8021b1:	85 f6                	test   %esi,%esi
  8021b3:	74 0a                	je     8021bf <ipc_recv+0x4c>
  8021b5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021ba:	8b 40 74             	mov    0x74(%eax),%eax
  8021bd:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8021bf:	85 db                	test   %ebx,%ebx
  8021c1:	74 0a                	je     8021cd <ipc_recv+0x5a>
  8021c3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021c8:	8b 40 78             	mov    0x78(%eax),%eax
  8021cb:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8021cd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021d2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    

008021dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	57                   	push   %edi
  8021e0:	56                   	push   %esi
  8021e1:	53                   	push   %ebx
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8021ee:	85 db                	test   %ebx,%ebx
  8021f0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021f5:	0f 44 d8             	cmove  %eax,%ebx
  8021f8:	eb 1c                	jmp    802216 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8021fa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021fd:	74 12                	je     802211 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8021ff:	50                   	push   %eax
  802200:	68 77 2a 80 00       	push   $0x802a77
  802205:	6a 39                	push   $0x39
  802207:	68 92 2a 80 00       	push   $0x802a92
  80220c:	e8 d4 df ff ff       	call   8001e5 <_panic>
                 sys_yield();
  802211:	e8 19 ea ff ff       	call   800c2f <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802216:	ff 75 14             	pushl  0x14(%ebp)
  802219:	53                   	push   %ebx
  80221a:	56                   	push   %esi
  80221b:	57                   	push   %edi
  80221c:	e8 ba eb ff ff       	call   800ddb <sys_ipc_try_send>
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	85 c0                	test   %eax,%eax
  802226:	78 d2                	js     8021fa <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80222b:	5b                   	pop    %ebx
  80222c:	5e                   	pop    %esi
  80222d:	5f                   	pop    %edi
  80222e:	5d                   	pop    %ebp
  80222f:	c3                   	ret    

00802230 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802236:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80223b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80223e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802244:	8b 52 50             	mov    0x50(%edx),%edx
  802247:	39 ca                	cmp    %ecx,%edx
  802249:	75 0d                	jne    802258 <ipc_find_env+0x28>
			return envs[i].env_id;
  80224b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80224e:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802253:	8b 40 08             	mov    0x8(%eax),%eax
  802256:	eb 0e                	jmp    802266 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802258:	83 c0 01             	add    $0x1,%eax
  80225b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802260:	75 d9                	jne    80223b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802262:	66 b8 00 00          	mov    $0x0,%ax
}
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    

00802268 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80226e:	89 d0                	mov    %edx,%eax
  802270:	c1 e8 16             	shr    $0x16,%eax
  802273:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80227a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80227f:	f6 c1 01             	test   $0x1,%cl
  802282:	74 1d                	je     8022a1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802284:	c1 ea 0c             	shr    $0xc,%edx
  802287:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80228e:	f6 c2 01             	test   $0x1,%dl
  802291:	74 0e                	je     8022a1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802293:	c1 ea 0c             	shr    $0xc,%edx
  802296:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80229d:	ef 
  80229e:	0f b7 c0             	movzwl %ax,%eax
}
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
  8022a3:	66 90                	xchg   %ax,%ax
  8022a5:	66 90                	xchg   %ax,%ax
  8022a7:	66 90                	xchg   %ax,%ax
  8022a9:	66 90                	xchg   %ax,%ax
  8022ab:	66 90                	xchg   %ax,%ax
  8022ad:	66 90                	xchg   %ax,%ax
  8022af:	90                   	nop

008022b0 <__udivdi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	83 ec 10             	sub    $0x10,%esp
  8022b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8022ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8022be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8022c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022c6:	85 d2                	test   %edx,%edx
  8022c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022cc:	89 34 24             	mov    %esi,(%esp)
  8022cf:	89 c8                	mov    %ecx,%eax
  8022d1:	75 35                	jne    802308 <__udivdi3+0x58>
  8022d3:	39 f1                	cmp    %esi,%ecx
  8022d5:	0f 87 bd 00 00 00    	ja     802398 <__udivdi3+0xe8>
  8022db:	85 c9                	test   %ecx,%ecx
  8022dd:	89 cd                	mov    %ecx,%ebp
  8022df:	75 0b                	jne    8022ec <__udivdi3+0x3c>
  8022e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e6:	31 d2                	xor    %edx,%edx
  8022e8:	f7 f1                	div    %ecx
  8022ea:	89 c5                	mov    %eax,%ebp
  8022ec:	89 f0                	mov    %esi,%eax
  8022ee:	31 d2                	xor    %edx,%edx
  8022f0:	f7 f5                	div    %ebp
  8022f2:	89 c6                	mov    %eax,%esi
  8022f4:	89 f8                	mov    %edi,%eax
  8022f6:	f7 f5                	div    %ebp
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	5e                   	pop    %esi
  8022fe:	5f                   	pop    %edi
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	3b 14 24             	cmp    (%esp),%edx
  80230b:	77 7b                	ja     802388 <__udivdi3+0xd8>
  80230d:	0f bd f2             	bsr    %edx,%esi
  802310:	83 f6 1f             	xor    $0x1f,%esi
  802313:	0f 84 97 00 00 00    	je     8023b0 <__udivdi3+0x100>
  802319:	bd 20 00 00 00       	mov    $0x20,%ebp
  80231e:	89 d7                	mov    %edx,%edi
  802320:	89 f1                	mov    %esi,%ecx
  802322:	29 f5                	sub    %esi,%ebp
  802324:	d3 e7                	shl    %cl,%edi
  802326:	89 c2                	mov    %eax,%edx
  802328:	89 e9                	mov    %ebp,%ecx
  80232a:	d3 ea                	shr    %cl,%edx
  80232c:	89 f1                	mov    %esi,%ecx
  80232e:	09 fa                	or     %edi,%edx
  802330:	8b 3c 24             	mov    (%esp),%edi
  802333:	d3 e0                	shl    %cl,%eax
  802335:	89 54 24 08          	mov    %edx,0x8(%esp)
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802343:	89 fa                	mov    %edi,%edx
  802345:	d3 ea                	shr    %cl,%edx
  802347:	89 f1                	mov    %esi,%ecx
  802349:	d3 e7                	shl    %cl,%edi
  80234b:	89 e9                	mov    %ebp,%ecx
  80234d:	d3 e8                	shr    %cl,%eax
  80234f:	09 c7                	or     %eax,%edi
  802351:	89 f8                	mov    %edi,%eax
  802353:	f7 74 24 08          	divl   0x8(%esp)
  802357:	89 d5                	mov    %edx,%ebp
  802359:	89 c7                	mov    %eax,%edi
  80235b:	f7 64 24 0c          	mull   0xc(%esp)
  80235f:	39 d5                	cmp    %edx,%ebp
  802361:	89 14 24             	mov    %edx,(%esp)
  802364:	72 11                	jb     802377 <__udivdi3+0xc7>
  802366:	8b 54 24 04          	mov    0x4(%esp),%edx
  80236a:	89 f1                	mov    %esi,%ecx
  80236c:	d3 e2                	shl    %cl,%edx
  80236e:	39 c2                	cmp    %eax,%edx
  802370:	73 5e                	jae    8023d0 <__udivdi3+0x120>
  802372:	3b 2c 24             	cmp    (%esp),%ebp
  802375:	75 59                	jne    8023d0 <__udivdi3+0x120>
  802377:	8d 47 ff             	lea    -0x1(%edi),%eax
  80237a:	31 f6                	xor    %esi,%esi
  80237c:	89 f2                	mov    %esi,%edx
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    
  802385:	8d 76 00             	lea    0x0(%esi),%esi
  802388:	31 f6                	xor    %esi,%esi
  80238a:	31 c0                	xor    %eax,%eax
  80238c:	89 f2                	mov    %esi,%edx
  80238e:	83 c4 10             	add    $0x10,%esp
  802391:	5e                   	pop    %esi
  802392:	5f                   	pop    %edi
  802393:	5d                   	pop    %ebp
  802394:	c3                   	ret    
  802395:	8d 76 00             	lea    0x0(%esi),%esi
  802398:	89 f2                	mov    %esi,%edx
  80239a:	31 f6                	xor    %esi,%esi
  80239c:	89 f8                	mov    %edi,%eax
  80239e:	f7 f1                	div    %ecx
  8023a0:	89 f2                	mov    %esi,%edx
  8023a2:	83 c4 10             	add    $0x10,%esp
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023b4:	76 0b                	jbe    8023c1 <__udivdi3+0x111>
  8023b6:	31 c0                	xor    %eax,%eax
  8023b8:	3b 14 24             	cmp    (%esp),%edx
  8023bb:	0f 83 37 ff ff ff    	jae    8022f8 <__udivdi3+0x48>
  8023c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c6:	e9 2d ff ff ff       	jmp    8022f8 <__udivdi3+0x48>
  8023cb:	90                   	nop
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	89 f8                	mov    %edi,%eax
  8023d2:	31 f6                	xor    %esi,%esi
  8023d4:	e9 1f ff ff ff       	jmp    8022f8 <__udivdi3+0x48>
  8023d9:	66 90                	xchg   %ax,%ax
  8023db:	66 90                	xchg   %ax,%ax
  8023dd:	66 90                	xchg   %ax,%ax
  8023df:	90                   	nop

008023e0 <__umoddi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	83 ec 20             	sub    $0x20,%esp
  8023e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8023ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f2:	89 c6                	mov    %eax,%esi
  8023f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802400:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802404:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802408:	89 74 24 18          	mov    %esi,0x18(%esp)
  80240c:	85 c0                	test   %eax,%eax
  80240e:	89 c2                	mov    %eax,%edx
  802410:	75 1e                	jne    802430 <__umoddi3+0x50>
  802412:	39 f7                	cmp    %esi,%edi
  802414:	76 52                	jbe    802468 <__umoddi3+0x88>
  802416:	89 c8                	mov    %ecx,%eax
  802418:	89 f2                	mov    %esi,%edx
  80241a:	f7 f7                	div    %edi
  80241c:	89 d0                	mov    %edx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  802420:	83 c4 20             	add    $0x20,%esp
  802423:	5e                   	pop    %esi
  802424:	5f                   	pop    %edi
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    
  802427:	89 f6                	mov    %esi,%esi
  802429:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802430:	39 f0                	cmp    %esi,%eax
  802432:	77 5c                	ja     802490 <__umoddi3+0xb0>
  802434:	0f bd e8             	bsr    %eax,%ebp
  802437:	83 f5 1f             	xor    $0x1f,%ebp
  80243a:	75 64                	jne    8024a0 <__umoddi3+0xc0>
  80243c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802440:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802444:	0f 86 f6 00 00 00    	jbe    802540 <__umoddi3+0x160>
  80244a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80244e:	0f 82 ec 00 00 00    	jb     802540 <__umoddi3+0x160>
  802454:	8b 44 24 14          	mov    0x14(%esp),%eax
  802458:	8b 54 24 18          	mov    0x18(%esp),%edx
  80245c:	83 c4 20             	add    $0x20,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	85 ff                	test   %edi,%edi
  80246a:	89 fd                	mov    %edi,%ebp
  80246c:	75 0b                	jne    802479 <__umoddi3+0x99>
  80246e:	b8 01 00 00 00       	mov    $0x1,%eax
  802473:	31 d2                	xor    %edx,%edx
  802475:	f7 f7                	div    %edi
  802477:	89 c5                	mov    %eax,%ebp
  802479:	8b 44 24 10          	mov    0x10(%esp),%eax
  80247d:	31 d2                	xor    %edx,%edx
  80247f:	f7 f5                	div    %ebp
  802481:	89 c8                	mov    %ecx,%eax
  802483:	f7 f5                	div    %ebp
  802485:	eb 95                	jmp    80241c <__umoddi3+0x3c>
  802487:	89 f6                	mov    %esi,%esi
  802489:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	83 c4 20             	add    $0x20,%esp
  802497:	5e                   	pop    %esi
  802498:	5f                   	pop    %edi
  802499:	5d                   	pop    %ebp
  80249a:	c3                   	ret    
  80249b:	90                   	nop
  80249c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8024a5:	89 e9                	mov    %ebp,%ecx
  8024a7:	29 e8                	sub    %ebp,%eax
  8024a9:	d3 e2                	shl    %cl,%edx
  8024ab:	89 c7                	mov    %eax,%edi
  8024ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8024b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e8                	shr    %cl,%eax
  8024b9:	89 c1                	mov    %eax,%ecx
  8024bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024bf:	09 d1                	or     %edx,%ecx
  8024c1:	89 fa                	mov    %edi,%edx
  8024c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024c7:	89 e9                	mov    %ebp,%ecx
  8024c9:	d3 e0                	shl    %cl,%eax
  8024cb:	89 f9                	mov    %edi,%ecx
  8024cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024d1:	89 f0                	mov    %esi,%eax
  8024d3:	d3 e8                	shr    %cl,%eax
  8024d5:	89 e9                	mov    %ebp,%ecx
  8024d7:	89 c7                	mov    %eax,%edi
  8024d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024dd:	d3 e6                	shl    %cl,%esi
  8024df:	89 d1                	mov    %edx,%ecx
  8024e1:	89 fa                	mov    %edi,%edx
  8024e3:	d3 e8                	shr    %cl,%eax
  8024e5:	89 e9                	mov    %ebp,%ecx
  8024e7:	09 f0                	or     %esi,%eax
  8024e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8024ed:	f7 74 24 10          	divl   0x10(%esp)
  8024f1:	d3 e6                	shl    %cl,%esi
  8024f3:	89 d1                	mov    %edx,%ecx
  8024f5:	f7 64 24 0c          	mull   0xc(%esp)
  8024f9:	39 d1                	cmp    %edx,%ecx
  8024fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8024ff:	89 d7                	mov    %edx,%edi
  802501:	89 c6                	mov    %eax,%esi
  802503:	72 0a                	jb     80250f <__umoddi3+0x12f>
  802505:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802509:	73 10                	jae    80251b <__umoddi3+0x13b>
  80250b:	39 d1                	cmp    %edx,%ecx
  80250d:	75 0c                	jne    80251b <__umoddi3+0x13b>
  80250f:	89 d7                	mov    %edx,%edi
  802511:	89 c6                	mov    %eax,%esi
  802513:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802517:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80251b:	89 ca                	mov    %ecx,%edx
  80251d:	89 e9                	mov    %ebp,%ecx
  80251f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802523:	29 f0                	sub    %esi,%eax
  802525:	19 fa                	sbb    %edi,%edx
  802527:	d3 e8                	shr    %cl,%eax
  802529:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80252e:	89 d7                	mov    %edx,%edi
  802530:	d3 e7                	shl    %cl,%edi
  802532:	89 e9                	mov    %ebp,%ecx
  802534:	09 f8                	or     %edi,%eax
  802536:	d3 ea                	shr    %cl,%edx
  802538:	83 c4 20             	add    $0x20,%esp
  80253b:	5e                   	pop    %esi
  80253c:	5f                   	pop    %edi
  80253d:	5d                   	pop    %ebp
  80253e:	c3                   	ret    
  80253f:	90                   	nop
  802540:	8b 74 24 10          	mov    0x10(%esp),%esi
  802544:	29 f9                	sub    %edi,%ecx
  802546:	19 c6                	sbb    %eax,%esi
  802548:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80254c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802550:	e9 ff fe ff ff       	jmp    802454 <__umoddi3+0x74>
