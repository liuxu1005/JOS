
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
  80005d:	68 40 20 80 00       	push   $0x802040
  800062:	e8 03 17 00 00       	call   80176a <printf>
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
  80007c:	e8 74 11 00 00       	call   8011f5 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 45 20 80 00       	push   $0x802045
  800095:	6a 13                	push   $0x13
  800097:	68 60 20 80 00       	push   $0x802060
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
  8000b8:	e8 62 10 00 00       	call   80111f <read>
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
  8000d3:	68 6b 20 80 00       	push   $0x80206b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 60 20 80 00       	push   $0x802060
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
  8000f4:	c7 05 04 30 80 00 80 	movl   $0x802080,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 84 20 80 00       	push   $0x802084
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
  80012f:	e8 98 14 00 00       	call   8015cc <open>
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
  800146:	68 8c 20 80 00       	push   $0x80208c
  80014b:	6a 27                	push   $0x27
  80014d:	68 60 20 80 00       	push   $0x802060
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 75 0e 00 00       	call   800fdf <close>

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
  8001a2:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001d1:	e8 36 0e 00 00       	call   80100c <close_all>
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
  800203:	68 a8 20 80 00       	push   $0x8020a8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
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
  800321:	e8 6a 1a 00 00       	call   801d90 <__udivdi3>
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
  80035f:	e8 5c 1b 00 00       	call   801ec0 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 80 cb 20 80 00 	movsbl 0x8020cb(%eax),%eax
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
  800463:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
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
  800527:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	75 18                	jne    80054a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800532:	50                   	push   %eax
  800533:	68 e3 20 80 00       	push   $0x8020e3
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
  80054b:	68 b5 24 80 00       	push   $0x8024b5
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
  800578:	ba dc 20 80 00       	mov    $0x8020dc,%edx
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
  800bf7:	68 df 23 80 00       	push   $0x8023df
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 fc 23 80 00       	push   $0x8023fc
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
  800c78:	68 df 23 80 00       	push   $0x8023df
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 fc 23 80 00       	push   $0x8023fc
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
  800cba:	68 df 23 80 00       	push   $0x8023df
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 fc 23 80 00       	push   $0x8023fc
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
  800cfc:	68 df 23 80 00       	push   $0x8023df
  800d01:	6a 23                	push   $0x23
  800d03:	68 fc 23 80 00       	push   $0x8023fc
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
  800d3e:	68 df 23 80 00       	push   $0x8023df
  800d43:	6a 23                	push   $0x23
  800d45:	68 fc 23 80 00       	push   $0x8023fc
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
  800d80:	68 df 23 80 00       	push   $0x8023df
  800d85:	6a 23                	push   $0x23
  800d87:	68 fc 23 80 00       	push   $0x8023fc
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
  800dc2:	68 df 23 80 00       	push   $0x8023df
  800dc7:	6a 23                	push   $0x23
  800dc9:	68 fc 23 80 00       	push   $0x8023fc
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
  800e26:	68 df 23 80 00       	push   $0x8023df
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 fc 23 80 00       	push   $0x8023fc
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

00800e3f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	c1 ea 16             	shr    $0x16,%edx
  800e76:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7d:	f6 c2 01             	test   $0x1,%dl
  800e80:	74 11                	je     800e93 <fd_alloc+0x2d>
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 ea 0c             	shr    $0xc,%edx
  800e87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	75 09                	jne    800e9c <fd_alloc+0x36>
			*fd_store = fd;
  800e93:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	eb 17                	jmp    800eb3 <fd_alloc+0x4d>
  800e9c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ea1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea6:	75 c9                	jne    800e71 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ebb:	83 f8 1f             	cmp    $0x1f,%eax
  800ebe:	77 36                	ja     800ef6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec0:	c1 e0 0c             	shl    $0xc,%eax
  800ec3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	c1 ea 16             	shr    $0x16,%edx
  800ecd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed4:	f6 c2 01             	test   $0x1,%dl
  800ed7:	74 24                	je     800efd <fd_lookup+0x48>
  800ed9:	89 c2                	mov    %eax,%edx
  800edb:	c1 ea 0c             	shr    $0xc,%edx
  800ede:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee5:	f6 c2 01             	test   $0x1,%dl
  800ee8:	74 1a                	je     800f04 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eed:	89 02                	mov    %eax,(%edx)
	return 0;
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	eb 13                	jmp    800f09 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efb:	eb 0c                	jmp    800f09 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f02:	eb 05                	jmp    800f09 <fd_lookup+0x54>
  800f04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
  800f11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f14:	ba 8c 24 80 00       	mov    $0x80248c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f19:	eb 13                	jmp    800f2e <dev_lookup+0x23>
  800f1b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f1e:	39 08                	cmp    %ecx,(%eax)
  800f20:	75 0c                	jne    800f2e <dev_lookup+0x23>
			*dev = devtab[i];
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f27:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2c:	eb 2e                	jmp    800f5c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f2e:	8b 02                	mov    (%edx),%eax
  800f30:	85 c0                	test   %eax,%eax
  800f32:	75 e7                	jne    800f1b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f34:	a1 08 40 80 00       	mov    0x804008,%eax
  800f39:	8b 40 48             	mov    0x48(%eax),%eax
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	51                   	push   %ecx
  800f40:	50                   	push   %eax
  800f41:	68 0c 24 80 00       	push   $0x80240c
  800f46:	e8 73 f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    

00800f5e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 10             	sub    $0x10,%esp
  800f66:	8b 75 08             	mov    0x8(%ebp),%esi
  800f69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f70:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f76:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f79:	50                   	push   %eax
  800f7a:	e8 36 ff ff ff       	call   800eb5 <fd_lookup>
  800f7f:	83 c4 08             	add    $0x8,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	78 05                	js     800f8b <fd_close+0x2d>
	    || fd != fd2)
  800f86:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f89:	74 0c                	je     800f97 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f8b:	84 db                	test   %bl,%bl
  800f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f92:	0f 44 c2             	cmove  %edx,%eax
  800f95:	eb 41                	jmp    800fd8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f97:	83 ec 08             	sub    $0x8,%esp
  800f9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	ff 36                	pushl  (%esi)
  800fa0:	e8 66 ff ff ff       	call   800f0b <dev_lookup>
  800fa5:	89 c3                	mov    %eax,%ebx
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 1a                	js     800fc8 <fd_close+0x6a>
		if (dev->dev_close)
  800fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	74 0b                	je     800fc8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	56                   	push   %esi
  800fc1:	ff d0                	call   *%eax
  800fc3:	89 c3                	mov    %eax,%ebx
  800fc5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 00 fd ff ff       	call   800cd3 <sys_page_unmap>
	return r;
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	89 d8                	mov    %ebx,%eax
}
  800fd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	ff 75 08             	pushl  0x8(%ebp)
  800fec:	e8 c4 fe ff ff       	call   800eb5 <fd_lookup>
  800ff1:	89 c2                	mov    %eax,%edx
  800ff3:	83 c4 08             	add    $0x8,%esp
  800ff6:	85 d2                	test   %edx,%edx
  800ff8:	78 10                	js     80100a <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800ffa:	83 ec 08             	sub    $0x8,%esp
  800ffd:	6a 01                	push   $0x1
  800fff:	ff 75 f4             	pushl  -0xc(%ebp)
  801002:	e8 57 ff ff ff       	call   800f5e <fd_close>
  801007:	83 c4 10             	add    $0x10,%esp
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <close_all>:

void
close_all(void)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	53                   	push   %ebx
  801010:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801013:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	53                   	push   %ebx
  80101c:	e8 be ff ff ff       	call   800fdf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801021:	83 c3 01             	add    $0x1,%ebx
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	83 fb 20             	cmp    $0x20,%ebx
  80102a:	75 ec                	jne    801018 <close_all+0xc>
		close(i);
}
  80102c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	83 ec 2c             	sub    $0x2c,%esp
  80103a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80103d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801040:	50                   	push   %eax
  801041:	ff 75 08             	pushl  0x8(%ebp)
  801044:	e8 6c fe ff ff       	call   800eb5 <fd_lookup>
  801049:	89 c2                	mov    %eax,%edx
  80104b:	83 c4 08             	add    $0x8,%esp
  80104e:	85 d2                	test   %edx,%edx
  801050:	0f 88 c1 00 00 00    	js     801117 <dup+0xe6>
		return r;
	close(newfdnum);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	56                   	push   %esi
  80105a:	e8 80 ff ff ff       	call   800fdf <close>

	newfd = INDEX2FD(newfdnum);
  80105f:	89 f3                	mov    %esi,%ebx
  801061:	c1 e3 0c             	shl    $0xc,%ebx
  801064:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80106a:	83 c4 04             	add    $0x4,%esp
  80106d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801070:	e8 da fd ff ff       	call   800e4f <fd2data>
  801075:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801077:	89 1c 24             	mov    %ebx,(%esp)
  80107a:	e8 d0 fd ff ff       	call   800e4f <fd2data>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801085:	89 f8                	mov    %edi,%eax
  801087:	c1 e8 16             	shr    $0x16,%eax
  80108a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801091:	a8 01                	test   $0x1,%al
  801093:	74 37                	je     8010cc <dup+0x9b>
  801095:	89 f8                	mov    %edi,%eax
  801097:	c1 e8 0c             	shr    $0xc,%eax
  80109a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a1:	f6 c2 01             	test   $0x1,%dl
  8010a4:	74 26                	je     8010cc <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b9:	6a 00                	push   $0x0
  8010bb:	57                   	push   %edi
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 ce fb ff ff       	call   800c91 <sys_page_map>
  8010c3:	89 c7                	mov    %eax,%edi
  8010c5:	83 c4 20             	add    $0x20,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 2e                	js     8010fa <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010cf:	89 d0                	mov    %edx,%eax
  8010d1:	c1 e8 0c             	shr    $0xc,%eax
  8010d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e3:	50                   	push   %eax
  8010e4:	53                   	push   %ebx
  8010e5:	6a 00                	push   $0x0
  8010e7:	52                   	push   %edx
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 a2 fb ff ff       	call   800c91 <sys_page_map>
  8010ef:	89 c7                	mov    %eax,%edi
  8010f1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010f4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f6:	85 ff                	test   %edi,%edi
  8010f8:	79 1d                	jns    801117 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	53                   	push   %ebx
  8010fe:	6a 00                	push   $0x0
  801100:	e8 ce fb ff ff       	call   800cd3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801105:	83 c4 08             	add    $0x8,%esp
  801108:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110b:	6a 00                	push   $0x0
  80110d:	e8 c1 fb ff ff       	call   800cd3 <sys_page_unmap>
	return r;
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	89 f8                	mov    %edi,%eax
}
  801117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	53                   	push   %ebx
  801123:	83 ec 14             	sub    $0x14,%esp
  801126:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801129:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112c:	50                   	push   %eax
  80112d:	53                   	push   %ebx
  80112e:	e8 82 fd ff ff       	call   800eb5 <fd_lookup>
  801133:	83 c4 08             	add    $0x8,%esp
  801136:	89 c2                	mov    %eax,%edx
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 6d                	js     8011a9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801146:	ff 30                	pushl  (%eax)
  801148:	e8 be fd ff ff       	call   800f0b <dev_lookup>
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 4c                	js     8011a0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801154:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801157:	8b 42 08             	mov    0x8(%edx),%eax
  80115a:	83 e0 03             	and    $0x3,%eax
  80115d:	83 f8 01             	cmp    $0x1,%eax
  801160:	75 21                	jne    801183 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801162:	a1 08 40 80 00       	mov    0x804008,%eax
  801167:	8b 40 48             	mov    0x48(%eax),%eax
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	53                   	push   %ebx
  80116e:	50                   	push   %eax
  80116f:	68 50 24 80 00       	push   $0x802450
  801174:	e8 45 f1 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801181:	eb 26                	jmp    8011a9 <read+0x8a>
	}
	if (!dev->dev_read)
  801183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801186:	8b 40 08             	mov    0x8(%eax),%eax
  801189:	85 c0                	test   %eax,%eax
  80118b:	74 17                	je     8011a4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	ff 75 10             	pushl  0x10(%ebp)
  801193:	ff 75 0c             	pushl  0xc(%ebp)
  801196:	52                   	push   %edx
  801197:	ff d0                	call   *%eax
  801199:	89 c2                	mov    %eax,%edx
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	eb 09                	jmp    8011a9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	eb 05                	jmp    8011a9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ae:	c9                   	leave  
  8011af:	c3                   	ret    

008011b0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 0c             	sub    $0xc,%esp
  8011b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c4:	eb 21                	jmp    8011e7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	89 f0                	mov    %esi,%eax
  8011cb:	29 d8                	sub    %ebx,%eax
  8011cd:	50                   	push   %eax
  8011ce:	89 d8                	mov    %ebx,%eax
  8011d0:	03 45 0c             	add    0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	57                   	push   %edi
  8011d5:	e8 45 ff ff ff       	call   80111f <read>
		if (m < 0)
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 0c                	js     8011ed <readn+0x3d>
			return m;
		if (m == 0)
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	74 06                	je     8011eb <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e5:	01 c3                	add    %eax,%ebx
  8011e7:	39 f3                	cmp    %esi,%ebx
  8011e9:	72 db                	jb     8011c6 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011eb:	89 d8                	mov    %ebx,%eax
}
  8011ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 14             	sub    $0x14,%esp
  8011fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	53                   	push   %ebx
  801204:	e8 ac fc ff ff       	call   800eb5 <fd_lookup>
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 68                	js     80127a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121c:	ff 30                	pushl  (%eax)
  80121e:	e8 e8 fc ff ff       	call   800f0b <dev_lookup>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	78 47                	js     801271 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801231:	75 21                	jne    801254 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801233:	a1 08 40 80 00       	mov    0x804008,%eax
  801238:	8b 40 48             	mov    0x48(%eax),%eax
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	53                   	push   %ebx
  80123f:	50                   	push   %eax
  801240:	68 6c 24 80 00       	push   $0x80246c
  801245:	e8 74 f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801252:	eb 26                	jmp    80127a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801254:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801257:	8b 52 0c             	mov    0xc(%edx),%edx
  80125a:	85 d2                	test   %edx,%edx
  80125c:	74 17                	je     801275 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	ff 75 10             	pushl  0x10(%ebp)
  801264:	ff 75 0c             	pushl  0xc(%ebp)
  801267:	50                   	push   %eax
  801268:	ff d2                	call   *%edx
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	eb 09                	jmp    80127a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801271:	89 c2                	mov    %eax,%edx
  801273:	eb 05                	jmp    80127a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801275:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80127a:	89 d0                	mov    %edx,%eax
  80127c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <seek>:

int
seek(int fdnum, off_t offset)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801287:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80128a:	50                   	push   %eax
  80128b:	ff 75 08             	pushl  0x8(%ebp)
  80128e:	e8 22 fc ff ff       	call   800eb5 <fd_lookup>
  801293:	83 c4 08             	add    $0x8,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 0e                	js     8012a8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80129a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80129d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    

008012aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 14             	sub    $0x14,%esp
  8012b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	53                   	push   %ebx
  8012b9:	e8 f7 fb ff ff       	call   800eb5 <fd_lookup>
  8012be:	83 c4 08             	add    $0x8,%esp
  8012c1:	89 c2                	mov    %eax,%edx
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 65                	js     80132c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d1:	ff 30                	pushl  (%eax)
  8012d3:	e8 33 fc ff ff       	call   800f0b <dev_lookup>
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 44                	js     801323 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e6:	75 21                	jne    801309 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ed:	8b 40 48             	mov    0x48(%eax),%eax
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	53                   	push   %ebx
  8012f4:	50                   	push   %eax
  8012f5:	68 2c 24 80 00       	push   $0x80242c
  8012fa:	e8 bf ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801307:	eb 23                	jmp    80132c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801309:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80130c:	8b 52 18             	mov    0x18(%edx),%edx
  80130f:	85 d2                	test   %edx,%edx
  801311:	74 14                	je     801327 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 0c             	pushl  0xc(%ebp)
  801319:	50                   	push   %eax
  80131a:	ff d2                	call   *%edx
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	eb 09                	jmp    80132c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801323:	89 c2                	mov    %eax,%edx
  801325:	eb 05                	jmp    80132c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801327:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	53                   	push   %ebx
  801337:	83 ec 14             	sub    $0x14,%esp
  80133a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 6c fb ff ff       	call   800eb5 <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 58                	js     8013aa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	ff 30                	pushl  (%eax)
  80135e:	e8 a8 fb ff ff       	call   800f0b <dev_lookup>
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 37                	js     8013a1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801371:	74 32                	je     8013a5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801373:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801376:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137d:	00 00 00 
	stat->st_isdir = 0;
  801380:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801387:	00 00 00 
	stat->st_dev = dev;
  80138a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	53                   	push   %ebx
  801394:	ff 75 f0             	pushl  -0x10(%ebp)
  801397:	ff 50 14             	call   *0x14(%eax)
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	eb 09                	jmp    8013aa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	eb 05                	jmp    8013aa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013aa:	89 d0                	mov    %edx,%eax
  8013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	6a 00                	push   $0x0
  8013bb:	ff 75 08             	pushl  0x8(%ebp)
  8013be:	e8 09 02 00 00       	call   8015cc <open>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 db                	test   %ebx,%ebx
  8013ca:	78 1b                	js     8013e7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	ff 75 0c             	pushl  0xc(%ebp)
  8013d2:	53                   	push   %ebx
  8013d3:	e8 5b ff ff ff       	call   801333 <fstat>
  8013d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8013da:	89 1c 24             	mov    %ebx,(%esp)
  8013dd:	e8 fd fb ff ff       	call   800fdf <close>
	return r;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	89 f0                	mov    %esi,%eax
}
  8013e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	89 c6                	mov    %eax,%esi
  8013f5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013f7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013fe:	75 12                	jne    801412 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	6a 01                	push   $0x1
  801405:	e8 0f 09 00 00       	call   801d19 <ipc_find_env>
  80140a:	a3 04 40 80 00       	mov    %eax,0x804004
  80140f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801412:	6a 07                	push   $0x7
  801414:	68 00 50 80 00       	push   $0x805000
  801419:	56                   	push   %esi
  80141a:	ff 35 04 40 80 00    	pushl  0x804004
  801420:	e8 a0 08 00 00       	call   801cc5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801425:	83 c4 0c             	add    $0xc,%esp
  801428:	6a 00                	push   $0x0
  80142a:	53                   	push   %ebx
  80142b:	6a 00                	push   $0x0
  80142d:	e8 2a 08 00 00       	call   801c5c <ipc_recv>
}
  801432:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	8b 40 0c             	mov    0xc(%eax),%eax
  801445:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80144a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801452:	ba 00 00 00 00       	mov    $0x0,%edx
  801457:	b8 02 00 00 00       	mov    $0x2,%eax
  80145c:	e8 8d ff ff ff       	call   8013ee <fsipc>
}
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	8b 40 0c             	mov    0xc(%eax),%eax
  80146f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801474:	ba 00 00 00 00       	mov    $0x0,%edx
  801479:	b8 06 00 00 00       	mov    $0x6,%eax
  80147e:	e8 6b ff ff ff       	call   8013ee <fsipc>
}
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	53                   	push   %ebx
  801489:	83 ec 04             	sub    $0x4,%esp
  80148c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	8b 40 0c             	mov    0xc(%eax),%eax
  801495:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a4:	e8 45 ff ff ff       	call   8013ee <fsipc>
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	78 2c                	js     8014db <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	68 00 50 80 00       	push   $0x805000
  8014b7:	53                   	push   %ebx
  8014b8:	e8 88 f3 ff ff       	call   800845 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8014c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	57                   	push   %edi
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 0c             	sub    $0xc,%esp
  8014e9:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8014ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f2:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014fa:	eb 3d                	jmp    801539 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014fc:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801502:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801507:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	57                   	push   %edi
  80150e:	53                   	push   %ebx
  80150f:	68 08 50 80 00       	push   $0x805008
  801514:	e8 be f4 ff ff       	call   8009d7 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801519:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 04 00 00 00       	mov    $0x4,%eax
  801529:	e8 c0 fe ff ff       	call   8013ee <fsipc>
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 0d                	js     801542 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801535:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801537:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801539:	85 f6                	test   %esi,%esi
  80153b:	75 bf                	jne    8014fc <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80153d:	89 d8                	mov    %ebx,%eax
  80153f:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 03 00 00 00       	mov    $0x3,%eax
  80156d:	e8 7c fe ff ff       	call   8013ee <fsipc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	85 c0                	test   %eax,%eax
  801576:	78 4b                	js     8015c3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801578:	39 c6                	cmp    %eax,%esi
  80157a:	73 16                	jae    801592 <devfile_read+0x48>
  80157c:	68 9c 24 80 00       	push   $0x80249c
  801581:	68 a3 24 80 00       	push   $0x8024a3
  801586:	6a 7c                	push   $0x7c
  801588:	68 b8 24 80 00       	push   $0x8024b8
  80158d:	e8 53 ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  801592:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801597:	7e 16                	jle    8015af <devfile_read+0x65>
  801599:	68 c3 24 80 00       	push   $0x8024c3
  80159e:	68 a3 24 80 00       	push   $0x8024a3
  8015a3:	6a 7d                	push   $0x7d
  8015a5:	68 b8 24 80 00       	push   $0x8024b8
  8015aa:	e8 36 ec ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	50                   	push   %eax
  8015b3:	68 00 50 80 00       	push   $0x805000
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	e8 17 f4 ff ff       	call   8009d7 <memmove>
	return r;
  8015c0:	83 c4 10             	add    $0x10,%esp
}
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 20             	sub    $0x20,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d6:	53                   	push   %ebx
  8015d7:	e8 30 f2 ff ff       	call   80080c <strlen>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e4:	7f 67                	jg     80164d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	e8 74 f8 ff ff       	call   800e66 <fd_alloc>
  8015f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 57                	js     801652 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	68 00 50 80 00       	push   $0x805000
  801604:	e8 3c f2 ff ff       	call   800845 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801609:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	b8 01 00 00 00       	mov    $0x1,%eax
  801619:	e8 d0 fd ff ff       	call   8013ee <fsipc>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	79 14                	jns    80163b <open+0x6f>
		fd_close(fd, 0);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	6a 00                	push   $0x0
  80162c:	ff 75 f4             	pushl  -0xc(%ebp)
  80162f:	e8 2a f9 ff ff       	call   800f5e <fd_close>
		return r;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 da                	mov    %ebx,%edx
  801639:	eb 17                	jmp    801652 <open+0x86>
	}

	return fd2num(fd);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 75 f4             	pushl  -0xc(%ebp)
  801641:	e8 f9 f7 ff ff       	call   800e3f <fd2num>
  801646:	89 c2                	mov    %eax,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 05                	jmp    801652 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801652:	89 d0                	mov    %edx,%eax
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165f:	ba 00 00 00 00       	mov    $0x0,%edx
  801664:	b8 08 00 00 00       	mov    $0x8,%eax
  801669:	e8 80 fd ff ff       	call   8013ee <fsipc>
}
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801670:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801674:	7e 37                	jle    8016ad <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80167f:	ff 70 04             	pushl  0x4(%eax)
  801682:	8d 40 10             	lea    0x10(%eax),%eax
  801685:	50                   	push   %eax
  801686:	ff 33                	pushl  (%ebx)
  801688:	e8 68 fb ff ff       	call   8011f5 <write>
		if (result > 0)
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	7e 03                	jle    801697 <writebuf+0x27>
			b->result += result;
  801694:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801697:	39 43 04             	cmp    %eax,0x4(%ebx)
  80169a:	74 0d                	je     8016a9 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80169c:	85 c0                	test   %eax,%eax
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	0f 4f c2             	cmovg  %edx,%eax
  8016a6:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	f3 c3                	repz ret 

008016af <putch>:

static void
putch(int ch, void *thunk)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 04             	sub    $0x4,%esp
  8016b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016b9:	8b 53 04             	mov    0x4(%ebx),%edx
  8016bc:	8d 42 01             	lea    0x1(%edx),%eax
  8016bf:	89 43 04             	mov    %eax,0x4(%ebx)
  8016c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c5:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016c9:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016ce:	75 0e                	jne    8016de <putch+0x2f>
		writebuf(b);
  8016d0:	89 d8                	mov    %ebx,%eax
  8016d2:	e8 99 ff ff ff       	call   801670 <writebuf>
		b->idx = 0;
  8016d7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016de:	83 c4 04             	add    $0x4,%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016f6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016fd:	00 00 00 
	b.result = 0;
  801700:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801707:	00 00 00 
	b.error = 1;
  80170a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801711:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801714:	ff 75 10             	pushl  0x10(%ebp)
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	68 af 16 80 00       	push   $0x8016af
  801726:	e8 c5 ec ff ff       	call   8003f0 <vprintfmt>
	if (b.idx > 0)
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801735:	7e 0b                	jle    801742 <vfprintf+0x5e>
		writebuf(&b);
  801737:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80173d:	e8 2e ff ff ff       	call   801670 <writebuf>

	return (b.result ? b.result : b.error);
  801742:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801759:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80175c:	50                   	push   %eax
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	e8 7c ff ff ff       	call   8016e4 <vfprintf>
	va_end(ap);

	return cnt;
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <printf>:

int
printf(const char *fmt, ...)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801770:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801773:	50                   	push   %eax
  801774:	ff 75 08             	pushl  0x8(%ebp)
  801777:	6a 01                	push   $0x1
  801779:	e8 66 ff ff ff       	call   8016e4 <vfprintf>
	va_end(ap);

	return cnt;
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801788:	83 ec 0c             	sub    $0xc,%esp
  80178b:	ff 75 08             	pushl  0x8(%ebp)
  80178e:	e8 bc f6 ff ff       	call   800e4f <fd2data>
  801793:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801795:	83 c4 08             	add    $0x8,%esp
  801798:	68 cf 24 80 00       	push   $0x8024cf
  80179d:	53                   	push   %ebx
  80179e:	e8 a2 f0 ff ff       	call   800845 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017a3:	8b 56 04             	mov    0x4(%esi),%edx
  8017a6:	89 d0                	mov    %edx,%eax
  8017a8:	2b 06                	sub    (%esi),%eax
  8017aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b7:	00 00 00 
	stat->st_dev = &devpipe;
  8017ba:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017c1:	30 80 00 
	return 0;
}
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017da:	53                   	push   %ebx
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 f1 f4 ff ff       	call   800cd3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017e2:	89 1c 24             	mov    %ebx,(%esp)
  8017e5:	e8 65 f6 ff ff       	call   800e4f <fd2data>
  8017ea:	83 c4 08             	add    $0x8,%esp
  8017ed:	50                   	push   %eax
  8017ee:	6a 00                	push   $0x0
  8017f0:	e8 de f4 ff ff       	call   800cd3 <sys_page_unmap>
}
  8017f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	57                   	push   %edi
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	83 ec 1c             	sub    $0x1c,%esp
  801803:	89 c6                	mov    %eax,%esi
  801805:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801808:	a1 08 40 80 00       	mov    0x804008,%eax
  80180d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	56                   	push   %esi
  801814:	e8 38 05 00 00       	call   801d51 <pageref>
  801819:	89 c7                	mov    %eax,%edi
  80181b:	83 c4 04             	add    $0x4,%esp
  80181e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801821:	e8 2b 05 00 00       	call   801d51 <pageref>
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	39 c7                	cmp    %eax,%edi
  80182b:	0f 94 c2             	sete   %dl
  80182e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801831:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801837:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80183a:	39 fb                	cmp    %edi,%ebx
  80183c:	74 19                	je     801857 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80183e:	84 d2                	test   %dl,%dl
  801840:	74 c6                	je     801808 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801842:	8b 51 58             	mov    0x58(%ecx),%edx
  801845:	50                   	push   %eax
  801846:	52                   	push   %edx
  801847:	53                   	push   %ebx
  801848:	68 d6 24 80 00       	push   $0x8024d6
  80184d:	e8 6c ea ff ff       	call   8002be <cprintf>
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	eb b1                	jmp    801808 <_pipeisclosed+0xe>
	}
}
  801857:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5f                   	pop    %edi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	57                   	push   %edi
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	83 ec 28             	sub    $0x28,%esp
  801868:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80186b:	56                   	push   %esi
  80186c:	e8 de f5 ff ff       	call   800e4f <fd2data>
  801871:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	bf 00 00 00 00       	mov    $0x0,%edi
  80187b:	eb 4b                	jmp    8018c8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80187d:	89 da                	mov    %ebx,%edx
  80187f:	89 f0                	mov    %esi,%eax
  801881:	e8 74 ff ff ff       	call   8017fa <_pipeisclosed>
  801886:	85 c0                	test   %eax,%eax
  801888:	75 48                	jne    8018d2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80188a:	e8 a0 f3 ff ff       	call   800c2f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80188f:	8b 43 04             	mov    0x4(%ebx),%eax
  801892:	8b 0b                	mov    (%ebx),%ecx
  801894:	8d 51 20             	lea    0x20(%ecx),%edx
  801897:	39 d0                	cmp    %edx,%eax
  801899:	73 e2                	jae    80187d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80189b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018a2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018a5:	89 c2                	mov    %eax,%edx
  8018a7:	c1 fa 1f             	sar    $0x1f,%edx
  8018aa:	89 d1                	mov    %edx,%ecx
  8018ac:	c1 e9 1b             	shr    $0x1b,%ecx
  8018af:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018b2:	83 e2 1f             	and    $0x1f,%edx
  8018b5:	29 ca                	sub    %ecx,%edx
  8018b7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018bf:	83 c0 01             	add    $0x1,%eax
  8018c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c5:	83 c7 01             	add    $0x1,%edi
  8018c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018cb:	75 c2                	jne    80188f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d0:	eb 05                	jmp    8018d7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5f                   	pop    %edi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	57                   	push   %edi
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 18             	sub    $0x18,%esp
  8018e8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018eb:	57                   	push   %edi
  8018ec:	e8 5e f5 ff ff       	call   800e4f <fd2data>
  8018f1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018fb:	eb 3d                	jmp    80193a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018fd:	85 db                	test   %ebx,%ebx
  8018ff:	74 04                	je     801905 <devpipe_read+0x26>
				return i;
  801901:	89 d8                	mov    %ebx,%eax
  801903:	eb 44                	jmp    801949 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801905:	89 f2                	mov    %esi,%edx
  801907:	89 f8                	mov    %edi,%eax
  801909:	e8 ec fe ff ff       	call   8017fa <_pipeisclosed>
  80190e:	85 c0                	test   %eax,%eax
  801910:	75 32                	jne    801944 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801912:	e8 18 f3 ff ff       	call   800c2f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801917:	8b 06                	mov    (%esi),%eax
  801919:	3b 46 04             	cmp    0x4(%esi),%eax
  80191c:	74 df                	je     8018fd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80191e:	99                   	cltd   
  80191f:	c1 ea 1b             	shr    $0x1b,%edx
  801922:	01 d0                	add    %edx,%eax
  801924:	83 e0 1f             	and    $0x1f,%eax
  801927:	29 d0                	sub    %edx,%eax
  801929:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80192e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801931:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801934:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801937:	83 c3 01             	add    $0x1,%ebx
  80193a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80193d:	75 d8                	jne    801917 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80193f:	8b 45 10             	mov    0x10(%ebp),%eax
  801942:	eb 05                	jmp    801949 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5f                   	pop    %edi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	e8 04 f5 ff ff       	call   800e66 <fd_alloc>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	89 c2                	mov    %eax,%edx
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 88 2c 01 00 00    	js     801a9b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	68 07 04 00 00       	push   $0x407
  801977:	ff 75 f4             	pushl  -0xc(%ebp)
  80197a:	6a 00                	push   $0x0
  80197c:	e8 cd f2 ff ff       	call   800c4e <sys_page_alloc>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	89 c2                	mov    %eax,%edx
  801986:	85 c0                	test   %eax,%eax
  801988:	0f 88 0d 01 00 00    	js     801a9b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	e8 cc f4 ff ff       	call   800e66 <fd_alloc>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	0f 88 e2 00 00 00    	js     801a89 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a7:	83 ec 04             	sub    $0x4,%esp
  8019aa:	68 07 04 00 00       	push   $0x407
  8019af:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b2:	6a 00                	push   $0x0
  8019b4:	e8 95 f2 ff ff       	call   800c4e <sys_page_alloc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 c3 00 00 00    	js     801a89 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cc:	e8 7e f4 ff ff       	call   800e4f <fd2data>
  8019d1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d3:	83 c4 0c             	add    $0xc,%esp
  8019d6:	68 07 04 00 00       	push   $0x407
  8019db:	50                   	push   %eax
  8019dc:	6a 00                	push   $0x0
  8019de:	e8 6b f2 ff ff       	call   800c4e <sys_page_alloc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	0f 88 89 00 00 00    	js     801a79 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f6:	e8 54 f4 ff ff       	call   800e4f <fd2data>
  8019fb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a02:	50                   	push   %eax
  801a03:	6a 00                	push   $0x0
  801a05:	56                   	push   %esi
  801a06:	6a 00                	push   $0x0
  801a08:	e8 84 f2 ff ff       	call   800c91 <sys_page_map>
  801a0d:	89 c3                	mov    %eax,%ebx
  801a0f:	83 c4 20             	add    $0x20,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 55                	js     801a6b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a16:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a24:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a2b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a34:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a39:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	ff 75 f4             	pushl  -0xc(%ebp)
  801a46:	e8 f4 f3 ff ff       	call   800e3f <fd2num>
  801a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a50:	83 c4 04             	add    $0x4,%esp
  801a53:	ff 75 f0             	pushl  -0x10(%ebp)
  801a56:	e8 e4 f3 ff ff       	call   800e3f <fd2num>
  801a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a5e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
  801a69:	eb 30                	jmp    801a9b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	56                   	push   %esi
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 5d f2 ff ff       	call   800cd3 <sys_page_unmap>
  801a76:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a79:	83 ec 08             	sub    $0x8,%esp
  801a7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 4d f2 ff ff       	call   800cd3 <sys_page_unmap>
  801a86:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 3d f2 ff ff       	call   800cd3 <sys_page_unmap>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a9b:	89 d0                	mov    %edx,%eax
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aad:	50                   	push   %eax
  801aae:	ff 75 08             	pushl  0x8(%ebp)
  801ab1:	e8 ff f3 ff ff       	call   800eb5 <fd_lookup>
  801ab6:	89 c2                	mov    %eax,%edx
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 d2                	test   %edx,%edx
  801abd:	78 18                	js     801ad7 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac5:	e8 85 f3 ff ff       	call   800e4f <fd2data>
	return _pipeisclosed(fd, p);
  801aca:	89 c2                	mov    %eax,%edx
  801acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acf:	e8 26 fd ff ff       	call   8017fa <_pipeisclosed>
  801ad4:	83 c4 10             	add    $0x10,%esp
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ae9:	68 ee 24 80 00       	push   $0x8024ee
  801aee:	ff 75 0c             	pushl  0xc(%ebp)
  801af1:	e8 4f ed ff ff       	call   800845 <strcpy>
	return 0;
}
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	57                   	push   %edi
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b09:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b0e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b14:	eb 2d                	jmp    801b43 <devcons_write+0x46>
		m = n - tot;
  801b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b19:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b1b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b1e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b23:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b26:	83 ec 04             	sub    $0x4,%esp
  801b29:	53                   	push   %ebx
  801b2a:	03 45 0c             	add    0xc(%ebp),%eax
  801b2d:	50                   	push   %eax
  801b2e:	57                   	push   %edi
  801b2f:	e8 a3 ee ff ff       	call   8009d7 <memmove>
		sys_cputs(buf, m);
  801b34:	83 c4 08             	add    $0x8,%esp
  801b37:	53                   	push   %ebx
  801b38:	57                   	push   %edi
  801b39:	e8 54 f0 ff ff       	call   800b92 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b3e:	01 de                	add    %ebx,%esi
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	89 f0                	mov    %esi,%eax
  801b45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b48:	72 cc                	jb     801b16 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5f                   	pop    %edi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801b5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b61:	75 07                	jne    801b6a <devcons_read+0x18>
  801b63:	eb 28                	jmp    801b8d <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b65:	e8 c5 f0 ff ff       	call   800c2f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b6a:	e8 41 f0 ff ff       	call   800bb0 <sys_cgetc>
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	74 f2                	je     801b65 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 16                	js     801b8d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b77:	83 f8 04             	cmp    $0x4,%eax
  801b7a:	74 0c                	je     801b88 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7f:	88 02                	mov    %al,(%edx)
	return 1;
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	eb 05                	jmp    801b8d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b95:	8b 45 08             	mov    0x8(%ebp),%eax
  801b98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b9b:	6a 01                	push   $0x1
  801b9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	e8 ec ef ff ff       	call   800b92 <sys_cputs>
  801ba6:	83 c4 10             	add    $0x10,%esp
}
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <getchar>:

int
getchar(void)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb1:	6a 01                	push   $0x1
  801bb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb6:	50                   	push   %eax
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 61 f5 ff ff       	call   80111f <read>
	if (r < 0)
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 0f                	js     801bd4 <getchar+0x29>
		return r;
	if (r < 1)
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	7e 06                	jle    801bcf <getchar+0x24>
		return -E_EOF;
	return c;
  801bc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bcd:	eb 05                	jmp    801bd4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bcf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	ff 75 08             	pushl  0x8(%ebp)
  801be3:	e8 cd f2 ff ff       	call   800eb5 <fd_lookup>
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	85 c0                	test   %eax,%eax
  801bed:	78 11                	js     801c00 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801bf8:	39 10                	cmp    %edx,(%eax)
  801bfa:	0f 94 c0             	sete   %al
  801bfd:	0f b6 c0             	movzbl %al,%eax
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <opencons>:

int
opencons(void)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	e8 55 f2 ff ff       	call   800e66 <fd_alloc>
  801c11:	83 c4 10             	add    $0x10,%esp
		return r;
  801c14:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 3e                	js     801c58 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c1a:	83 ec 04             	sub    $0x4,%esp
  801c1d:	68 07 04 00 00       	push   $0x407
  801c22:	ff 75 f4             	pushl  -0xc(%ebp)
  801c25:	6a 00                	push   $0x0
  801c27:	e8 22 f0 ff ff       	call   800c4e <sys_page_alloc>
  801c2c:	83 c4 10             	add    $0x10,%esp
		return r;
  801c2f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 23                	js     801c58 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c35:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c43:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	50                   	push   %eax
  801c4e:	e8 ec f1 ff ff       	call   800e3f <fd2num>
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	83 c4 10             	add    $0x10,%esp
}
  801c58:	89 d0                	mov    %edx,%eax
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	8b 75 08             	mov    0x8(%ebp),%esi
  801c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c71:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	50                   	push   %eax
  801c78:	e8 81 f1 ff ff       	call   800dfe <sys_ipc_recv>
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	79 16                	jns    801c9a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801c84:	85 f6                	test   %esi,%esi
  801c86:	74 06                	je     801c8e <ipc_recv+0x32>
  801c88:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801c8e:	85 db                	test   %ebx,%ebx
  801c90:	74 2c                	je     801cbe <ipc_recv+0x62>
  801c92:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c98:	eb 24                	jmp    801cbe <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801c9a:	85 f6                	test   %esi,%esi
  801c9c:	74 0a                	je     801ca8 <ipc_recv+0x4c>
  801c9e:	a1 08 40 80 00       	mov    0x804008,%eax
  801ca3:	8b 40 74             	mov    0x74(%eax),%eax
  801ca6:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801ca8:	85 db                	test   %ebx,%ebx
  801caa:	74 0a                	je     801cb6 <ipc_recv+0x5a>
  801cac:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb1:	8b 40 78             	mov    0x78(%eax),%eax
  801cb4:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801cb6:	a1 08 40 80 00       	mov    0x804008,%eax
  801cbb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	57                   	push   %edi
  801cc9:	56                   	push   %esi
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801cd7:	85 db                	test   %ebx,%ebx
  801cd9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cde:	0f 44 d8             	cmove  %eax,%ebx
  801ce1:	eb 1c                	jmp    801cff <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801ce3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ce6:	74 12                	je     801cfa <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ce8:	50                   	push   %eax
  801ce9:	68 fa 24 80 00       	push   $0x8024fa
  801cee:	6a 39                	push   $0x39
  801cf0:	68 15 25 80 00       	push   $0x802515
  801cf5:	e8 eb e4 ff ff       	call   8001e5 <_panic>
                 sys_yield();
  801cfa:	e8 30 ef ff ff       	call   800c2f <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801cff:	ff 75 14             	pushl  0x14(%ebp)
  801d02:	53                   	push   %ebx
  801d03:	56                   	push   %esi
  801d04:	57                   	push   %edi
  801d05:	e8 d1 f0 ff ff       	call   800ddb <sys_ipc_try_send>
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	78 d2                	js     801ce3 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    

00801d19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d1f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d24:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d2d:	8b 52 50             	mov    0x50(%edx),%edx
  801d30:	39 ca                	cmp    %ecx,%edx
  801d32:	75 0d                	jne    801d41 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d34:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d37:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801d3c:	8b 40 08             	mov    0x8(%eax),%eax
  801d3f:	eb 0e                	jmp    801d4f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d41:	83 c0 01             	add    $0x1,%eax
  801d44:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d49:	75 d9                	jne    801d24 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d4b:	66 b8 00 00          	mov    $0x0,%ax
}
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d57:	89 d0                	mov    %edx,%eax
  801d59:	c1 e8 16             	shr    $0x16,%eax
  801d5c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d68:	f6 c1 01             	test   $0x1,%cl
  801d6b:	74 1d                	je     801d8a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d6d:	c1 ea 0c             	shr    $0xc,%edx
  801d70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d77:	f6 c2 01             	test   $0x1,%dl
  801d7a:	74 0e                	je     801d8a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d7c:	c1 ea 0c             	shr    $0xc,%edx
  801d7f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d86:	ef 
  801d87:	0f b7 c0             	movzwl %ax,%eax
}
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__udivdi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	83 ec 10             	sub    $0x10,%esp
  801d96:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801d9a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d9e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801da2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801da6:	85 d2                	test   %edx,%edx
  801da8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dac:	89 34 24             	mov    %esi,(%esp)
  801daf:	89 c8                	mov    %ecx,%eax
  801db1:	75 35                	jne    801de8 <__udivdi3+0x58>
  801db3:	39 f1                	cmp    %esi,%ecx
  801db5:	0f 87 bd 00 00 00    	ja     801e78 <__udivdi3+0xe8>
  801dbb:	85 c9                	test   %ecx,%ecx
  801dbd:	89 cd                	mov    %ecx,%ebp
  801dbf:	75 0b                	jne    801dcc <__udivdi3+0x3c>
  801dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc6:	31 d2                	xor    %edx,%edx
  801dc8:	f7 f1                	div    %ecx
  801dca:	89 c5                	mov    %eax,%ebp
  801dcc:	89 f0                	mov    %esi,%eax
  801dce:	31 d2                	xor    %edx,%edx
  801dd0:	f7 f5                	div    %ebp
  801dd2:	89 c6                	mov    %eax,%esi
  801dd4:	89 f8                	mov    %edi,%eax
  801dd6:	f7 f5                	div    %ebp
  801dd8:	89 f2                	mov    %esi,%edx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    
  801de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de8:	3b 14 24             	cmp    (%esp),%edx
  801deb:	77 7b                	ja     801e68 <__udivdi3+0xd8>
  801ded:	0f bd f2             	bsr    %edx,%esi
  801df0:	83 f6 1f             	xor    $0x1f,%esi
  801df3:	0f 84 97 00 00 00    	je     801e90 <__udivdi3+0x100>
  801df9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801dfe:	89 d7                	mov    %edx,%edi
  801e00:	89 f1                	mov    %esi,%ecx
  801e02:	29 f5                	sub    %esi,%ebp
  801e04:	d3 e7                	shl    %cl,%edi
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	d3 ea                	shr    %cl,%edx
  801e0c:	89 f1                	mov    %esi,%ecx
  801e0e:	09 fa                	or     %edi,%edx
  801e10:	8b 3c 24             	mov    (%esp),%edi
  801e13:	d3 e0                	shl    %cl,%eax
  801e15:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e1f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e23:	89 fa                	mov    %edi,%edx
  801e25:	d3 ea                	shr    %cl,%edx
  801e27:	89 f1                	mov    %esi,%ecx
  801e29:	d3 e7                	shl    %cl,%edi
  801e2b:	89 e9                	mov    %ebp,%ecx
  801e2d:	d3 e8                	shr    %cl,%eax
  801e2f:	09 c7                	or     %eax,%edi
  801e31:	89 f8                	mov    %edi,%eax
  801e33:	f7 74 24 08          	divl   0x8(%esp)
  801e37:	89 d5                	mov    %edx,%ebp
  801e39:	89 c7                	mov    %eax,%edi
  801e3b:	f7 64 24 0c          	mull   0xc(%esp)
  801e3f:	39 d5                	cmp    %edx,%ebp
  801e41:	89 14 24             	mov    %edx,(%esp)
  801e44:	72 11                	jb     801e57 <__udivdi3+0xc7>
  801e46:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e4a:	89 f1                	mov    %esi,%ecx
  801e4c:	d3 e2                	shl    %cl,%edx
  801e4e:	39 c2                	cmp    %eax,%edx
  801e50:	73 5e                	jae    801eb0 <__udivdi3+0x120>
  801e52:	3b 2c 24             	cmp    (%esp),%ebp
  801e55:	75 59                	jne    801eb0 <__udivdi3+0x120>
  801e57:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e5a:	31 f6                	xor    %esi,%esi
  801e5c:	89 f2                	mov    %esi,%edx
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	5e                   	pop    %esi
  801e62:	5f                   	pop    %edi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    
  801e65:	8d 76 00             	lea    0x0(%esi),%esi
  801e68:	31 f6                	xor    %esi,%esi
  801e6a:	31 c0                	xor    %eax,%eax
  801e6c:	89 f2                	mov    %esi,%edx
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	89 f2                	mov    %esi,%edx
  801e7a:	31 f6                	xor    %esi,%esi
  801e7c:	89 f8                	mov    %edi,%eax
  801e7e:	f7 f1                	div    %ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e94:	76 0b                	jbe    801ea1 <__udivdi3+0x111>
  801e96:	31 c0                	xor    %eax,%eax
  801e98:	3b 14 24             	cmp    (%esp),%edx
  801e9b:	0f 83 37 ff ff ff    	jae    801dd8 <__udivdi3+0x48>
  801ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea6:	e9 2d ff ff ff       	jmp    801dd8 <__udivdi3+0x48>
  801eab:	90                   	nop
  801eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	89 f8                	mov    %edi,%eax
  801eb2:	31 f6                	xor    %esi,%esi
  801eb4:	e9 1f ff ff ff       	jmp    801dd8 <__udivdi3+0x48>
  801eb9:	66 90                	xchg   %ax,%ax
  801ebb:	66 90                	xchg   %ax,%ax
  801ebd:	66 90                	xchg   %ax,%ax
  801ebf:	90                   	nop

00801ec0 <__umoddi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	83 ec 20             	sub    $0x20,%esp
  801ec6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801eca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ece:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ed2:	89 c6                	mov    %eax,%esi
  801ed4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ed8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801edc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ee0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ee4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ee8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801eec:	85 c0                	test   %eax,%eax
  801eee:	89 c2                	mov    %eax,%edx
  801ef0:	75 1e                	jne    801f10 <__umoddi3+0x50>
  801ef2:	39 f7                	cmp    %esi,%edi
  801ef4:	76 52                	jbe    801f48 <__umoddi3+0x88>
  801ef6:	89 c8                	mov    %ecx,%eax
  801ef8:	89 f2                	mov    %esi,%edx
  801efa:	f7 f7                	div    %edi
  801efc:	89 d0                	mov    %edx,%eax
  801efe:	31 d2                	xor    %edx,%edx
  801f00:	83 c4 20             	add    $0x20,%esp
  801f03:	5e                   	pop    %esi
  801f04:	5f                   	pop    %edi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    
  801f07:	89 f6                	mov    %esi,%esi
  801f09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f10:	39 f0                	cmp    %esi,%eax
  801f12:	77 5c                	ja     801f70 <__umoddi3+0xb0>
  801f14:	0f bd e8             	bsr    %eax,%ebp
  801f17:	83 f5 1f             	xor    $0x1f,%ebp
  801f1a:	75 64                	jne    801f80 <__umoddi3+0xc0>
  801f1c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801f20:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801f24:	0f 86 f6 00 00 00    	jbe    802020 <__umoddi3+0x160>
  801f2a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801f2e:	0f 82 ec 00 00 00    	jb     802020 <__umoddi3+0x160>
  801f34:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f38:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f3c:	83 c4 20             	add    $0x20,%esp
  801f3f:	5e                   	pop    %esi
  801f40:	5f                   	pop    %edi
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    
  801f43:	90                   	nop
  801f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f48:	85 ff                	test   %edi,%edi
  801f4a:	89 fd                	mov    %edi,%ebp
  801f4c:	75 0b                	jne    801f59 <__umoddi3+0x99>
  801f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f53:	31 d2                	xor    %edx,%edx
  801f55:	f7 f7                	div    %edi
  801f57:	89 c5                	mov    %eax,%ebp
  801f59:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f5d:	31 d2                	xor    %edx,%edx
  801f5f:	f7 f5                	div    %ebp
  801f61:	89 c8                	mov    %ecx,%eax
  801f63:	f7 f5                	div    %ebp
  801f65:	eb 95                	jmp    801efc <__umoddi3+0x3c>
  801f67:	89 f6                	mov    %esi,%esi
  801f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f70:	89 c8                	mov    %ecx,%eax
  801f72:	89 f2                	mov    %esi,%edx
  801f74:	83 c4 20             	add    $0x20,%esp
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
  801f7b:	90                   	nop
  801f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f80:	b8 20 00 00 00       	mov    $0x20,%eax
  801f85:	89 e9                	mov    %ebp,%ecx
  801f87:	29 e8                	sub    %ebp,%eax
  801f89:	d3 e2                	shl    %cl,%edx
  801f8b:	89 c7                	mov    %eax,%edi
  801f8d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e8                	shr    %cl,%eax
  801f99:	89 c1                	mov    %eax,%ecx
  801f9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f9f:	09 d1                	or     %edx,%ecx
  801fa1:	89 fa                	mov    %edi,%edx
  801fa3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fa7:	89 e9                	mov    %ebp,%ecx
  801fa9:	d3 e0                	shl    %cl,%eax
  801fab:	89 f9                	mov    %edi,%ecx
  801fad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb1:	89 f0                	mov    %esi,%eax
  801fb3:	d3 e8                	shr    %cl,%eax
  801fb5:	89 e9                	mov    %ebp,%ecx
  801fb7:	89 c7                	mov    %eax,%edi
  801fb9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fbd:	d3 e6                	shl    %cl,%esi
  801fbf:	89 d1                	mov    %edx,%ecx
  801fc1:	89 fa                	mov    %edi,%edx
  801fc3:	d3 e8                	shr    %cl,%eax
  801fc5:	89 e9                	mov    %ebp,%ecx
  801fc7:	09 f0                	or     %esi,%eax
  801fc9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801fcd:	f7 74 24 10          	divl   0x10(%esp)
  801fd1:	d3 e6                	shl    %cl,%esi
  801fd3:	89 d1                	mov    %edx,%ecx
  801fd5:	f7 64 24 0c          	mull   0xc(%esp)
  801fd9:	39 d1                	cmp    %edx,%ecx
  801fdb:	89 74 24 14          	mov    %esi,0x14(%esp)
  801fdf:	89 d7                	mov    %edx,%edi
  801fe1:	89 c6                	mov    %eax,%esi
  801fe3:	72 0a                	jb     801fef <__umoddi3+0x12f>
  801fe5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801fe9:	73 10                	jae    801ffb <__umoddi3+0x13b>
  801feb:	39 d1                	cmp    %edx,%ecx
  801fed:	75 0c                	jne    801ffb <__umoddi3+0x13b>
  801fef:	89 d7                	mov    %edx,%edi
  801ff1:	89 c6                	mov    %eax,%esi
  801ff3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801ff7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801ffb:	89 ca                	mov    %ecx,%edx
  801ffd:	89 e9                	mov    %ebp,%ecx
  801fff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802003:	29 f0                	sub    %esi,%eax
  802005:	19 fa                	sbb    %edi,%edx
  802007:	d3 e8                	shr    %cl,%eax
  802009:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80200e:	89 d7                	mov    %edx,%edi
  802010:	d3 e7                	shl    %cl,%edi
  802012:	89 e9                	mov    %ebp,%ecx
  802014:	09 f8                	or     %edi,%eax
  802016:	d3 ea                	shr    %cl,%edx
  802018:	83 c4 20             	add    $0x20,%esp
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    
  80201f:	90                   	nop
  802020:	8b 74 24 10          	mov    0x10(%esp),%esi
  802024:	29 f9                	sub    %edi,%ecx
  802026:	19 c6                	sbb    %eax,%esi
  802028:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80202c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802030:	e9 ff fe ff ff       	jmp    801f34 <__umoddi3+0x74>
