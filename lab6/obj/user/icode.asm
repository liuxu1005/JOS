
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 40 80 00 c0 	movl   $0x8029c0,0x804000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 29 80 00       	push   $0x8029c6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 29 80 00 	movl   $0x8029d5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 29 80 00       	push   $0x8029e8
  800068:	e8 b4 15 00 00       	call   801621 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 29 80 00       	push   $0x8029ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 2a 80 00       	push   $0x802a04
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 2a 80 00       	push   $0x802a11
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 97 0a 00 00       	call   800b41 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 b8 10 00 00       	call   801174 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 2a 80 00       	push   $0x802a24
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 5c 0f 00 00       	call   801034 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 2a 80 00       	push   $0x802a4c
  8000f0:	68 55 2a 80 00       	push   $0x802a55
  8000f5:	68 5f 2a 80 00       	push   $0x802a5f
  8000fa:	68 5e 2a 80 00       	push   $0x802a5e
  8000ff:	e8 0e 1b 00 00       	call   801c12 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 2a 80 00       	push   $0x802a64
  800111:	6a 1a                	push   $0x1a
  800113:	68 04 2a 80 00       	push   $0x802a04
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 2a 80 00       	push   $0x802a7b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
  80012a:	83 c4 10             	add    $0x10,%esp
}
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80013f:	e8 7b 0a 00 00       	call   800bbf <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
  800170:	83 c4 10             	add    $0x10,%esp
}
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 dc 0e 00 00       	call   801061 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 ef 09 00 00       	call   800b7e <sys_env_destroy>
  80018f:	83 c4 10             	add    $0x10,%esp
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8001a2:	e8 18 0a 00 00       	call   800bbf <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 98 2a 80 00       	push   $0x802a98
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 d5 2f 80 00 	movl   $0x802fd5,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 37 09 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 4f 01 00 00       	call   80039f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 dc 08 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 d1                	mov    %edx,%ecx
  800296:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800299:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ac:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002af:	72 05                	jb     8002b6 <printnum+0x35>
  8002b1:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002b4:	77 3e                	ja     8002f4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	ff 75 18             	pushl  0x18(%ebp)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	53                   	push   %ebx
  8002c0:	50                   	push   %eax
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 3b 24 00 00       	call   802710 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 13                	jmp    8002fb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f4:	83 eb 01             	sub    $0x1,%ebx
  8002f7:	85 db                	test   %ebx,%ebx
  8002f9:	7f ed                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	83 ec 04             	sub    $0x4,%esp
  800302:	ff 75 e4             	pushl  -0x1c(%ebp)
  800305:	ff 75 e0             	pushl  -0x20(%ebp)
  800308:	ff 75 dc             	pushl  -0x24(%ebp)
  80030b:	ff 75 d8             	pushl  -0x28(%ebp)
  80030e:	e8 2d 25 00 00       	call   802840 <__umoddi3>
  800313:	83 c4 14             	add    $0x14,%esp
  800316:	0f be 80 bb 2a 80 00 	movsbl 0x802abb(%eax),%eax
  80031d:	50                   	push   %eax
  80031e:	ff d7                	call   *%edi
  800320:	83 c4 10             	add    $0x10,%esp
}
  800323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800326:	5b                   	pop    %ebx
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032e:	83 fa 01             	cmp    $0x1,%edx
  800331:	7e 0e                	jle    800341 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800333:	8b 10                	mov    (%eax),%edx
  800335:	8d 4a 08             	lea    0x8(%edx),%ecx
  800338:	89 08                	mov    %ecx,(%eax)
  80033a:	8b 02                	mov    (%edx),%eax
  80033c:	8b 52 04             	mov    0x4(%edx),%edx
  80033f:	eb 22                	jmp    800363 <getuint+0x38>
	else if (lflag)
  800341:	85 d2                	test   %edx,%edx
  800343:	74 10                	je     800355 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800345:	8b 10                	mov    (%eax),%edx
  800347:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034a:	89 08                	mov    %ecx,(%eax)
  80034c:	8b 02                	mov    (%edx),%eax
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	eb 0e                	jmp    800363 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	3b 50 04             	cmp    0x4(%eax),%edx
  800374:	73 0a                	jae    800380 <sprintputch+0x1b>
		*b->buf++ = ch;
  800376:	8d 4a 01             	lea    0x1(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	88 02                	mov    %al,(%edx)
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800388:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038b:	50                   	push   %eax
  80038c:	ff 75 10             	pushl  0x10(%ebp)
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	ff 75 08             	pushl  0x8(%ebp)
  800395:	e8 05 00 00 00       	call   80039f <vprintfmt>
	va_end(ap);
  80039a:	83 c4 10             	add    $0x10,%esp
}
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 2c             	sub    $0x2c,%esp
  8003a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b1:	eb 12                	jmp    8003c5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b3:	85 c0                	test   %eax,%eax
  8003b5:	0f 84 90 03 00 00    	je     80074b <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	53                   	push   %ebx
  8003bf:	50                   	push   %eax
  8003c0:	ff d6                	call   *%esi
  8003c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c5:	83 c7 01             	add    $0x1,%edi
  8003c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003cc:	83 f8 25             	cmp    $0x25,%eax
  8003cf:	75 e2                	jne    8003b3 <vprintfmt+0x14>
  8003d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ef:	eb 07                	jmp    8003f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8d 47 01             	lea    0x1(%edi),%eax
  8003fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fe:	0f b6 07             	movzbl (%edi),%eax
  800401:	0f b6 c8             	movzbl %al,%ecx
  800404:	83 e8 23             	sub    $0x23,%eax
  800407:	3c 55                	cmp    $0x55,%al
  800409:	0f 87 21 03 00 00    	ja     800730 <vprintfmt+0x391>
  80040f:	0f b6 c0             	movzbl %al,%eax
  800412:	ff 24 85 00 2c 80 00 	jmp    *0x802c00(,%eax,4)
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800420:	eb d6                	jmp    8003f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800430:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800434:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800437:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043a:	83 fa 09             	cmp    $0x9,%edx
  80043d:	77 39                	ja     800478 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800442:	eb e9                	jmp    80042d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 48 04             	lea    0x4(%eax),%ecx
  80044a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800455:	eb 27                	jmp    80047e <vprintfmt+0xdf>
  800457:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045a:	85 c0                	test   %eax,%eax
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800461:	0f 49 c8             	cmovns %eax,%ecx
  800464:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046a:	eb 8c                	jmp    8003f8 <vprintfmt+0x59>
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800476:	eb 80                	jmp    8003f8 <vprintfmt+0x59>
  800478:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 89 70 ff ff ff    	jns    8003f8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800488:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800495:	e9 5e ff ff ff       	jmp    8003f8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a0:	e9 53 ff ff ff       	jmp    8003f8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 30                	pushl  (%eax)
  8004b4:	ff d6                	call   *%esi
			break;
  8004b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bc:	e9 04 ff ff ff       	jmp    8003c5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	99                   	cltd   
  8004cd:	31 d0                	xor    %edx,%eax
  8004cf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d1:	83 f8 0f             	cmp    $0xf,%eax
  8004d4:	7f 0b                	jg     8004e1 <vprintfmt+0x142>
  8004d6:	8b 14 85 80 2d 80 00 	mov    0x802d80(,%eax,4),%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	75 18                	jne    8004f9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e1:	50                   	push   %eax
  8004e2:	68 d3 2a 80 00       	push   $0x802ad3
  8004e7:	53                   	push   %ebx
  8004e8:	56                   	push   %esi
  8004e9:	e8 94 fe ff ff       	call   800382 <printfmt>
  8004ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f4:	e9 cc fe ff ff       	jmp    8003c5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	52                   	push   %edx
  8004fa:	68 b5 2e 80 00       	push   $0x802eb5
  8004ff:	53                   	push   %ebx
  800500:	56                   	push   %esi
  800501:	e8 7c fe ff ff       	call   800382 <printfmt>
  800506:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	e9 b4 fe ff ff       	jmp    8003c5 <vprintfmt+0x26>
  800511:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800514:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800517:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800525:	85 ff                	test   %edi,%edi
  800527:	ba cc 2a 80 00       	mov    $0x802acc,%edx
  80052c:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80052f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800533:	0f 84 92 00 00 00    	je     8005cb <vprintfmt+0x22c>
  800539:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80053d:	0f 8e 96 00 00 00    	jle    8005d9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	51                   	push   %ecx
  800547:	57                   	push   %edi
  800548:	e8 86 02 00 00       	call   8007d3 <strnlen>
  80054d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800550:	29 c1                	sub    %eax,%ecx
  800552:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800555:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800558:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800562:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	eb 0f                	jmp    800575 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	ff 75 e0             	pushl  -0x20(%ebp)
  80056d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	83 ef 01             	sub    $0x1,%edi
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 ff                	test   %edi,%edi
  800577:	7f ed                	jg     800566 <vprintfmt+0x1c7>
  800579:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057f:	85 c9                	test   %ecx,%ecx
  800581:	b8 00 00 00 00       	mov    $0x0,%eax
  800586:	0f 49 c1             	cmovns %ecx,%eax
  800589:	29 c1                	sub    %eax,%ecx
  80058b:	89 75 08             	mov    %esi,0x8(%ebp)
  80058e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800591:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800594:	89 cb                	mov    %ecx,%ebx
  800596:	eb 4d                	jmp    8005e5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800598:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059c:	74 1b                	je     8005b9 <vprintfmt+0x21a>
  80059e:	0f be c0             	movsbl %al,%eax
  8005a1:	83 e8 20             	sub    $0x20,%eax
  8005a4:	83 f8 5e             	cmp    $0x5e,%eax
  8005a7:	76 10                	jbe    8005b9 <vprintfmt+0x21a>
					putch('?', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	ff 75 0c             	pushl  0xc(%ebp)
  8005af:	6a 3f                	push   $0x3f
  8005b1:	ff 55 08             	call   *0x8(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb 0d                	jmp    8005c6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	ff 75 0c             	pushl  0xc(%ebp)
  8005bf:	52                   	push   %edx
  8005c0:	ff 55 08             	call   *0x8(%ebp)
  8005c3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	83 eb 01             	sub    $0x1,%ebx
  8005c9:	eb 1a                	jmp    8005e5 <vprintfmt+0x246>
  8005cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d7:	eb 0c                	jmp    8005e5 <vprintfmt+0x246>
  8005d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e5:	83 c7 01             	add    $0x1,%edi
  8005e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ec:	0f be d0             	movsbl %al,%edx
  8005ef:	85 d2                	test   %edx,%edx
  8005f1:	74 23                	je     800616 <vprintfmt+0x277>
  8005f3:	85 f6                	test   %esi,%esi
  8005f5:	78 a1                	js     800598 <vprintfmt+0x1f9>
  8005f7:	83 ee 01             	sub    $0x1,%esi
  8005fa:	79 9c                	jns    800598 <vprintfmt+0x1f9>
  8005fc:	89 df                	mov    %ebx,%edi
  8005fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800604:	eb 18                	jmp    80061e <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 20                	push   $0x20
  80060c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 ef 01             	sub    $0x1,%edi
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	eb 08                	jmp    80061e <vprintfmt+0x27f>
  800616:	89 df                	mov    %ebx,%edi
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	85 ff                	test   %edi,%edi
  800620:	7f e4                	jg     800606 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800625:	e9 9b fd ff ff       	jmp    8003c5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062a:	83 fa 01             	cmp    $0x1,%edx
  80062d:	7e 16                	jle    800645 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 08             	lea    0x8(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800643:	eb 32                	jmp    800677 <vprintfmt+0x2d8>
	else if (lflag)
  800645:	85 d2                	test   %edx,%edx
  800647:	74 18                	je     800661 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	89 c1                	mov    %eax,%ecx
  800659:	c1 f9 1f             	sar    $0x1f,%ecx
  80065c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065f:	eb 16                	jmp    800677 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)
  80066a:	8b 00                	mov    (%eax),%eax
  80066c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066f:	89 c1                	mov    %eax,%ecx
  800671:	c1 f9 1f             	sar    $0x1f,%ecx
  800674:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800677:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80067a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800682:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800686:	79 74                	jns    8006fc <vprintfmt+0x35d>
				putch('-', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 2d                	push   $0x2d
  80068e:	ff d6                	call   *%esi
				num = -(long long) num;
  800690:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800693:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800696:	f7 d8                	neg    %eax
  800698:	83 d2 00             	adc    $0x0,%edx
  80069b:	f7 da                	neg    %edx
  80069d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a5:	eb 55                	jmp    8006fc <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 7c fc ff ff       	call   80032b <getuint>
			base = 10;
  8006af:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b4:	eb 46                	jmp    8006fc <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	e8 6d fc ff ff       	call   80032b <getuint>
                        base = 8;
  8006be:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006c3:	eb 37                	jmp    8006fc <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	6a 30                	push   $0x30
  8006cb:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cd:	83 c4 08             	add    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 78                	push   $0x78
  8006d3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	e8 34 fc ff ff       	call   80032b <getuint>
			base = 16;
  8006f7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	83 ec 0c             	sub    $0xc,%esp
  8006ff:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800703:	57                   	push   %edi
  800704:	ff 75 e0             	pushl  -0x20(%ebp)
  800707:	51                   	push   %ecx
  800708:	52                   	push   %edx
  800709:	50                   	push   %eax
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	89 f0                	mov    %esi,%eax
  80070e:	e8 6e fb ff ff       	call   800281 <printnum>
			break;
  800713:	83 c4 20             	add    $0x20,%esp
  800716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800719:	e9 a7 fc ff ff       	jmp    8003c5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	51                   	push   %ecx
  800723:	ff d6                	call   *%esi
			break;
  800725:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072b:	e9 95 fc ff ff       	jmp    8003c5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 03                	jmp    800740 <vprintfmt+0x3a1>
  80073d:	83 ef 01             	sub    $0x1,%edi
  800740:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800744:	75 f7                	jne    80073d <vprintfmt+0x39e>
  800746:	e9 7a fc ff ff       	jmp    8003c5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 18             	sub    $0x18,%esp
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800762:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800766:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800769:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800770:	85 c0                	test   %eax,%eax
  800772:	74 26                	je     80079a <vsnprintf+0x47>
  800774:	85 d2                	test   %edx,%edx
  800776:	7e 22                	jle    80079a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800778:	ff 75 14             	pushl  0x14(%ebp)
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	68 65 03 80 00       	push   $0x800365
  800787:	e8 13 fc ff ff       	call   80039f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb 05                	jmp    80079f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007aa:	50                   	push   %eax
  8007ab:	ff 75 10             	pushl  0x10(%ebp)
  8007ae:	ff 75 0c             	pushl  0xc(%ebp)
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 9a ff ff ff       	call   800753 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 03                	jmp    8007cb <strlen+0x10>
		n++;
  8007c8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cf:	75 f7                	jne    8007c8 <strlen+0xd>
		n++;
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e1:	eb 03                	jmp    8007e6 <strnlen+0x13>
		n++;
  8007e3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e6:	39 c2                	cmp    %eax,%edx
  8007e8:	74 08                	je     8007f2 <strnlen+0x1f>
  8007ea:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ee:	75 f3                	jne    8007e3 <strnlen+0x10>
  8007f0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fe:	89 c2                	mov    %eax,%edx
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080d:	84 db                	test   %bl,%bl
  80080f:	75 ef                	jne    800800 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800811:	5b                   	pop    %ebx
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081b:	53                   	push   %ebx
  80081c:	e8 9a ff ff ff       	call   8007bb <strlen>
  800821:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800824:	ff 75 0c             	pushl  0xc(%ebp)
  800827:	01 d8                	add    %ebx,%eax
  800829:	50                   	push   %eax
  80082a:	e8 c5 ff ff ff       	call   8007f4 <strcpy>
	return dst;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 75 08             	mov    0x8(%ebp),%esi
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800841:	89 f3                	mov    %esi,%ebx
  800843:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800846:	89 f2                	mov    %esi,%edx
  800848:	eb 0f                	jmp    800859 <strncpy+0x23>
		*dst++ = *src;
  80084a:	83 c2 01             	add    $0x1,%edx
  80084d:	0f b6 01             	movzbl (%ecx),%eax
  800850:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800853:	80 39 01             	cmpb   $0x1,(%ecx)
  800856:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	39 da                	cmp    %ebx,%edx
  80085b:	75 ed                	jne    80084a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085d:	89 f0                	mov    %esi,%eax
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 75 08             	mov    0x8(%ebp),%esi
  80086b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086e:	8b 55 10             	mov    0x10(%ebp),%edx
  800871:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 d2                	test   %edx,%edx
  800875:	74 21                	je     800898 <strlcpy+0x35>
  800877:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087b:	89 f2                	mov    %esi,%edx
  80087d:	eb 09                	jmp    800888 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087f:	83 c2 01             	add    $0x1,%edx
  800882:	83 c1 01             	add    $0x1,%ecx
  800885:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800888:	39 c2                	cmp    %eax,%edx
  80088a:	74 09                	je     800895 <strlcpy+0x32>
  80088c:	0f b6 19             	movzbl (%ecx),%ebx
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ec                	jne    80087f <strlcpy+0x1c>
  800893:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800895:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800898:	29 f0                	sub    %esi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a7:	eb 06                	jmp    8008af <strcmp+0x11>
		p++, q++;
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	0f b6 01             	movzbl (%ecx),%eax
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 04                	je     8008ba <strcmp+0x1c>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	74 ef                	je     8008a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ba:	0f b6 c0             	movzbl %al,%eax
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	29 d0                	sub    %edx,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 c3                	mov    %eax,%ebx
  8008d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d3:	eb 06                	jmp    8008db <strncmp+0x17>
		n--, p++, q++;
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008db:	39 d8                	cmp    %ebx,%eax
  8008dd:	74 15                	je     8008f4 <strncmp+0x30>
  8008df:	0f b6 08             	movzbl (%eax),%ecx
  8008e2:	84 c9                	test   %cl,%cl
  8008e4:	74 04                	je     8008ea <strncmp+0x26>
  8008e6:	3a 0a                	cmp    (%edx),%cl
  8008e8:	74 eb                	je     8008d5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ea:	0f b6 00             	movzbl (%eax),%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
  8008f2:	eb 05                	jmp    8008f9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	eb 07                	jmp    80090f <strchr+0x13>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0f                	je     80091b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	0f b6 10             	movzbl (%eax),%edx
  800912:	84 d2                	test   %dl,%dl
  800914:	75 f2                	jne    800908 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 03                	jmp    80092c <strfind+0xf>
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 04                	je     800937 <strfind+0x1a>
  800933:	38 ca                	cmp    %cl,%dl
  800935:	75 f2                	jne    800929 <strfind+0xc>
			break;
	return (char *) s;
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 36                	je     80097f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 28                	jne    800979 <memset+0x40>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 23                	jne    800979 <memset+0x40>
		c &= 0xFF;
  800956:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095a:	89 d3                	mov    %edx,%ebx
  80095c:	c1 e3 08             	shl    $0x8,%ebx
  80095f:	89 d6                	mov    %edx,%esi
  800961:	c1 e6 18             	shl    $0x18,%esi
  800964:	89 d0                	mov    %edx,%eax
  800966:	c1 e0 10             	shl    $0x10,%eax
  800969:	09 f0                	or     %esi,%eax
  80096b:	09 c2                	or     %eax,%edx
  80096d:	89 d0                	mov    %edx,%eax
  80096f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800971:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800974:	fc                   	cld    
  800975:	f3 ab                	rep stos %eax,%es:(%edi)
  800977:	eb 06                	jmp    80097f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	fc                   	cld    
  80097d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097f:	89 f8                	mov    %edi,%eax
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800994:	39 c6                	cmp    %eax,%esi
  800996:	73 35                	jae    8009cd <memmove+0x47>
  800998:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	73 2e                	jae    8009cd <memmove+0x47>
		s += n;
		d += n;
  80099f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a2:	89 d6                	mov    %edx,%esi
  8009a4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ac:	75 13                	jne    8009c1 <memmove+0x3b>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 0e                	jne    8009c1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b3:	83 ef 04             	sub    $0x4,%edi
  8009b6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 09                	jmp    8009ca <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c1:	83 ef 01             	sub    $0x1,%edi
  8009c4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ca:	fc                   	cld    
  8009cb:	eb 1d                	jmp    8009ea <memmove+0x64>
  8009cd:	89 f2                	mov    %esi,%edx
  8009cf:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f6 c2 03             	test   $0x3,%dl
  8009d4:	75 0f                	jne    8009e5 <memmove+0x5f>
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 0a                	jne    8009e5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009db:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb 05                	jmp    8009ea <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f1:	ff 75 10             	pushl  0x10(%ebp)
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	ff 75 08             	pushl  0x8(%ebp)
  8009fa:	e8 87 ff ff ff       	call   800986 <memmove>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 c6                	mov    %eax,%esi
  800a0e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	eb 1a                	jmp    800a2d <memcmp+0x2c>
		if (*s1 != *s2)
  800a13:	0f b6 08             	movzbl (%eax),%ecx
  800a16:	0f b6 1a             	movzbl (%edx),%ebx
  800a19:	38 d9                	cmp    %bl,%cl
  800a1b:	74 0a                	je     800a27 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c1             	movzbl %cl,%eax
  800a20:	0f b6 db             	movzbl %bl,%ebx
  800a23:	29 d8                	sub    %ebx,%eax
  800a25:	eb 0f                	jmp    800a36 <memcmp+0x35>
		s1++, s2++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2d:	39 f0                	cmp    %esi,%eax
  800a2f:	75 e2                	jne    800a13 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a48:	eb 07                	jmp    800a51 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	38 08                	cmp    %cl,(%eax)
  800a4c:	74 07                	je     800a55 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4e:	83 c0 01             	add    $0x1,%eax
  800a51:	39 d0                	cmp    %edx,%eax
  800a53:	72 f5                	jb     800a4a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	eb 03                	jmp    800a68 <strtol+0x11>
		s++;
  800a65:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	0f b6 01             	movzbl (%ecx),%eax
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f6                	je     800a65 <strtol+0xe>
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f2                	je     800a65 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a73:	3c 2b                	cmp    $0x2b,%al
  800a75:	75 0a                	jne    800a81 <strtol+0x2a>
		s++;
  800a77:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7f:	eb 10                	jmp    800a91 <strtol+0x3a>
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a86:	3c 2d                	cmp    $0x2d,%al
  800a88:	75 07                	jne    800a91 <strtol+0x3a>
		s++, neg = 1;
  800a8a:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a91:	85 db                	test   %ebx,%ebx
  800a93:	0f 94 c0             	sete   %al
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 19                	jne    800ab7 <strtol+0x60>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 14                	jne    800ab7 <strtol+0x60>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	0f 85 82 00 00 00    	jne    800b2f <strtol+0xd8>
		s += 2, base = 16;
  800aad:	83 c1 02             	add    $0x2,%ecx
  800ab0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab5:	eb 16                	jmp    800acd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab7:	84 c0                	test   %al,%al
  800ab9:	74 12                	je     800acd <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac3:	75 08                	jne    800acd <strtol+0x76>
		s++, base = 8;
  800ac5:	83 c1 01             	add    $0x1,%ecx
  800ac8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 11             	movzbl (%ecx),%edx
  800ad8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x93>
			dig = *s - '0';
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 30             	sub    $0x30,%edx
  800ae8:	eb 22                	jmp    800b0c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0xa5>
			dig = *s - 'a' + 10;
  800af4:	0f be d2             	movsbl %dl,%edx
  800af7:	83 ea 57             	sub    $0x57,%edx
  800afa:	eb 10                	jmp    800b0c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 16                	ja     800b1c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b06:	0f be d2             	movsbl %dl,%edx
  800b09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0f:	7d 0f                	jge    800b20 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b11:	83 c1 01             	add    $0x1,%ecx
  800b14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1a:	eb b9                	jmp    800ad5 <strtol+0x7e>
  800b1c:	89 c2                	mov    %eax,%edx
  800b1e:	eb 02                	jmp    800b22 <strtol+0xcb>
  800b20:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b26:	74 0d                	je     800b35 <strtol+0xde>
		*endptr = (char *) s;
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	89 0e                	mov    %ecx,(%esi)
  800b2d:	eb 06                	jmp    800b35 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2f:	84 c0                	test   %al,%al
  800b31:	75 92                	jne    800ac5 <strtol+0x6e>
  800b33:	eb 98                	jmp    800acd <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b35:	f7 da                	neg    %edx
  800b37:	85 ff                	test   %edi,%edi
  800b39:	0f 45 c2             	cmovne %edx,%eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	89 ce                	mov    %ecx,%esi
  800b9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 03                	push   $0x3
  800ba6:	68 df 2d 80 00       	push   $0x802ddf
  800bab:	6a 22                	push   $0x22
  800bad:	68 fc 2d 80 00       	push   $0x802dfc
  800bb2:	e8 dd f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{      
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 04                	push   $0x4
  800c27:	68 df 2d 80 00       	push   $0x802ddf
  800c2c:	6a 22                	push   $0x22
  800c2e:	68 fc 2d 80 00       	push   $0x802dfc
  800c33:	e8 5c f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c49:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 05                	push   $0x5
  800c69:	68 df 2d 80 00       	push   $0x802ddf
  800c6e:	6a 22                	push   $0x22
  800c70:	68 fc 2d 80 00       	push   $0x802dfc
  800c75:	e8 1a f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 06 00 00 00       	mov    $0x6,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 06                	push   $0x6
  800cab:	68 df 2d 80 00       	push   $0x802ddf
  800cb0:	6a 22                	push   $0x22
  800cb2:	68 fc 2d 80 00       	push   $0x802dfc
  800cb7:	e8 d8 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 08                	push   $0x8
  800ced:	68 df 2d 80 00       	push   $0x802ddf
  800cf2:	6a 22                	push   $0x22
  800cf4:	68 fc 2d 80 00       	push   $0x802dfc
  800cf9:	e8 96 f4 ff ff       	call   800194 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 09 00 00 00       	mov    $0x9,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 09                	push   $0x9
  800d2f:	68 df 2d 80 00       	push   $0x802ddf
  800d34:	6a 22                	push   $0x22
  800d36:	68 fc 2d 80 00       	push   $0x802dfc
  800d3b:	e8 54 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0a                	push   $0xa
  800d71:	68 df 2d 80 00       	push   $0x802ddf
  800d76:	6a 22                	push   $0x22
  800d78:	68 fc 2d 80 00       	push   $0x802dfc
  800d7d:	e8 12 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d90:	be 00 00 00 00       	mov    $0x0,%esi
  800d95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	89 ce                	mov    %ecx,%esi
  800dc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 17                	jle    800de6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 0d                	push   $0xd
  800dd5:	68 df 2d 80 00       	push   $0x802ddf
  800dda:	6a 22                	push   $0x22
  800ddc:	68 fc 2d 80 00       	push   $0x802dfc
  800de1:	e8 ae f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800df4:	ba 00 00 00 00       	mov    $0x0,%edx
  800df9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfe:	89 d1                	mov    %edx,%ecx
  800e00:	89 d3                	mov    %edx,%ebx
  800e02:	89 d7                	mov    %edx,%edi
  800e04:	89 d6                	mov    %edx,%esi
  800e06:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_transmit>:

int
sys_transmit(void *addr)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 cb                	mov    %ecx,%ebx
  800e25:	89 cf                	mov    %ecx,%edi
  800e27:	89 ce                	mov    %ecx,%esi
  800e29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 0f                	push   $0xf
  800e35:	68 df 2d 80 00       	push   $0x802ddf
  800e3a:	6a 22                	push   $0x22
  800e3c:	68 fc 2d 80 00       	push   $0x802dfc
  800e41:	e8 4e f3 ff ff       	call   800194 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_recv>:

int
sys_recv(void *addr)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 cb                	mov    %ecx,%ebx
  800e66:	89 cf                	mov    %ecx,%edi
  800e68:	89 ce                	mov    %ecx,%esi
  800e6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 17                	jle    800e87 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	50                   	push   %eax
  800e74:	6a 10                	push   $0x10
  800e76:	68 df 2d 80 00       	push   $0x802ddf
  800e7b:	6a 22                	push   $0x22
  800e7d:	68 fc 2d 80 00       	push   $0x802dfc
  800e82:	e8 0d f3 ff ff       	call   800194 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800eaa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eaf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	c1 ea 16             	shr    $0x16,%edx
  800ec6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecd:	f6 c2 01             	test   $0x1,%dl
  800ed0:	74 11                	je     800ee3 <fd_alloc+0x2d>
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	c1 ea 0c             	shr    $0xc,%edx
  800ed7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ede:	f6 c2 01             	test   $0x1,%dl
  800ee1:	75 09                	jne    800eec <fd_alloc+0x36>
			*fd_store = fd;
  800ee3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eea:	eb 17                	jmp    800f03 <fd_alloc+0x4d>
  800eec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef6:	75 c9                	jne    800ec1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f0b:	83 f8 1f             	cmp    $0x1f,%eax
  800f0e:	77 36                	ja     800f46 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f10:	c1 e0 0c             	shl    $0xc,%eax
  800f13:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	c1 ea 16             	shr    $0x16,%edx
  800f1d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	74 24                	je     800f4d <fd_lookup+0x48>
  800f29:	89 c2                	mov    %eax,%edx
  800f2b:	c1 ea 0c             	shr    $0xc,%edx
  800f2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f35:	f6 c2 01             	test   $0x1,%dl
  800f38:	74 1a                	je     800f54 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f44:	eb 13                	jmp    800f59 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4b:	eb 0c                	jmp    800f59 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f52:	eb 05                	jmp    800f59 <fd_lookup+0x54>
  800f54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 08             	sub    $0x8,%esp
  800f61:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f64:	ba 00 00 00 00       	mov    $0x0,%edx
  800f69:	eb 13                	jmp    800f7e <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f6b:	39 08                	cmp    %ecx,(%eax)
  800f6d:	75 0c                	jne    800f7b <dev_lookup+0x20>
			*dev = devtab[i];
  800f6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f72:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	eb 36                	jmp    800fb1 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7b:	83 c2 01             	add    $0x1,%edx
  800f7e:	8b 04 95 88 2e 80 00 	mov    0x802e88(,%edx,4),%eax
  800f85:	85 c0                	test   %eax,%eax
  800f87:	75 e2                	jne    800f6b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f89:	a1 08 50 80 00       	mov    0x805008,%eax
  800f8e:	8b 40 48             	mov    0x48(%eax),%eax
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	51                   	push   %ecx
  800f95:	50                   	push   %eax
  800f96:	68 0c 2e 80 00       	push   $0x802e0c
  800f9b:	e8 cd f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 10             	sub    $0x10,%esp
  800fbb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fcb:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fce:	50                   	push   %eax
  800fcf:	e8 31 ff ff ff       	call   800f05 <fd_lookup>
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 05                	js     800fe0 <fd_close+0x2d>
	    || fd != fd2)
  800fdb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fde:	74 0c                	je     800fec <fd_close+0x39>
		return (must_exist ? r : 0);
  800fe0:	84 db                	test   %bl,%bl
  800fe2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe7:	0f 44 c2             	cmove  %edx,%eax
  800fea:	eb 41                	jmp    80102d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff2:	50                   	push   %eax
  800ff3:	ff 36                	pushl  (%esi)
  800ff5:	e8 61 ff ff ff       	call   800f5b <dev_lookup>
  800ffa:	89 c3                	mov    %eax,%ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 1a                	js     80101d <fd_close+0x6a>
		if (dev->dev_close)
  801003:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801006:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80100e:	85 c0                	test   %eax,%eax
  801010:	74 0b                	je     80101d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	56                   	push   %esi
  801016:	ff d0                	call   *%eax
  801018:	89 c3                	mov    %eax,%ebx
  80101a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	56                   	push   %esi
  801021:	6a 00                	push   $0x0
  801023:	e8 5a fc ff ff       	call   800c82 <sys_page_unmap>
	return r;
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	89 d8                	mov    %ebx,%eax
}
  80102d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 bf fe ff ff       	call   800f05 <fd_lookup>
  801046:	89 c2                	mov    %eax,%edx
  801048:	83 c4 08             	add    $0x8,%esp
  80104b:	85 d2                	test   %edx,%edx
  80104d:	78 10                	js     80105f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	6a 01                	push   $0x1
  801054:	ff 75 f4             	pushl  -0xc(%ebp)
  801057:	e8 57 ff ff ff       	call   800fb3 <fd_close>
  80105c:	83 c4 10             	add    $0x10,%esp
}
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <close_all>:

void
close_all(void)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	53                   	push   %ebx
  801065:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801068:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	53                   	push   %ebx
  801071:	e8 be ff ff ff       	call   801034 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801076:	83 c3 01             	add    $0x1,%ebx
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	83 fb 20             	cmp    $0x20,%ebx
  80107f:	75 ec                	jne    80106d <close_all+0xc>
		close(i);
}
  801081:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	57                   	push   %edi
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	83 ec 2c             	sub    $0x2c,%esp
  80108f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	ff 75 08             	pushl  0x8(%ebp)
  801099:	e8 67 fe ff ff       	call   800f05 <fd_lookup>
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	85 d2                	test   %edx,%edx
  8010a5:	0f 88 c1 00 00 00    	js     80116c <dup+0xe6>
		return r;
	close(newfdnum);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	56                   	push   %esi
  8010af:	e8 80 ff ff ff       	call   801034 <close>

	newfd = INDEX2FD(newfdnum);
  8010b4:	89 f3                	mov    %esi,%ebx
  8010b6:	c1 e3 0c             	shl    $0xc,%ebx
  8010b9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010bf:	83 c4 04             	add    $0x4,%esp
  8010c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c5:	e8 d5 fd ff ff       	call   800e9f <fd2data>
  8010ca:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010cc:	89 1c 24             	mov    %ebx,(%esp)
  8010cf:	e8 cb fd ff ff       	call   800e9f <fd2data>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010da:	89 f8                	mov    %edi,%eax
  8010dc:	c1 e8 16             	shr    $0x16,%eax
  8010df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e6:	a8 01                	test   $0x1,%al
  8010e8:	74 37                	je     801121 <dup+0x9b>
  8010ea:	89 f8                	mov    %edi,%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
  8010ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 26                	je     801121 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	25 07 0e 00 00       	and    $0xe07,%eax
  80110a:	50                   	push   %eax
  80110b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110e:	6a 00                	push   $0x0
  801110:	57                   	push   %edi
  801111:	6a 00                	push   $0x0
  801113:	e8 28 fb ff ff       	call   800c40 <sys_page_map>
  801118:	89 c7                	mov    %eax,%edi
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 2e                	js     80114f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801121:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801124:	89 d0                	mov    %edx,%eax
  801126:	c1 e8 0c             	shr    $0xc,%eax
  801129:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	25 07 0e 00 00       	and    $0xe07,%eax
  801138:	50                   	push   %eax
  801139:	53                   	push   %ebx
  80113a:	6a 00                	push   $0x0
  80113c:	52                   	push   %edx
  80113d:	6a 00                	push   $0x0
  80113f:	e8 fc fa ff ff       	call   800c40 <sys_page_map>
  801144:	89 c7                	mov    %eax,%edi
  801146:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801149:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114b:	85 ff                	test   %edi,%edi
  80114d:	79 1d                	jns    80116c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	53                   	push   %ebx
  801153:	6a 00                	push   $0x0
  801155:	e8 28 fb ff ff       	call   800c82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115a:	83 c4 08             	add    $0x8,%esp
  80115d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801160:	6a 00                	push   $0x0
  801162:	e8 1b fb ff ff       	call   800c82 <sys_page_unmap>
	return r;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	89 f8                	mov    %edi,%eax
}
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	53                   	push   %ebx
  801178:	83 ec 14             	sub    $0x14,%esp
  80117b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	53                   	push   %ebx
  801183:	e8 7d fd ff ff       	call   800f05 <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 6d                	js     8011fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119b:	ff 30                	pushl  (%eax)
  80119d:	e8 b9 fd ff ff       	call   800f5b <dev_lookup>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 4c                	js     8011f5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ac:	8b 42 08             	mov    0x8(%edx),%eax
  8011af:	83 e0 03             	and    $0x3,%eax
  8011b2:	83 f8 01             	cmp    $0x1,%eax
  8011b5:	75 21                	jne    8011d8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b7:	a1 08 50 80 00       	mov    0x805008,%eax
  8011bc:	8b 40 48             	mov    0x48(%eax),%eax
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	53                   	push   %ebx
  8011c3:	50                   	push   %eax
  8011c4:	68 4d 2e 80 00       	push   $0x802e4d
  8011c9:	e8 9f f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d6:	eb 26                	jmp    8011fe <read+0x8a>
	}
	if (!dev->dev_read)
  8011d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011db:	8b 40 08             	mov    0x8(%eax),%eax
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 17                	je     8011f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	ff 75 10             	pushl  0x10(%ebp)
  8011e8:	ff 75 0c             	pushl  0xc(%ebp)
  8011eb:	52                   	push   %edx
  8011ec:	ff d0                	call   *%eax
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	eb 09                	jmp    8011fe <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	eb 05                	jmp    8011fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011fe:	89 d0                	mov    %edx,%eax
  801200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	57                   	push   %edi
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	83 ec 0c             	sub    $0xc,%esp
  80120e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801211:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801214:	bb 00 00 00 00       	mov    $0x0,%ebx
  801219:	eb 21                	jmp    80123c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	89 f0                	mov    %esi,%eax
  801220:	29 d8                	sub    %ebx,%eax
  801222:	50                   	push   %eax
  801223:	89 d8                	mov    %ebx,%eax
  801225:	03 45 0c             	add    0xc(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	57                   	push   %edi
  80122a:	e8 45 ff ff ff       	call   801174 <read>
		if (m < 0)
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 0c                	js     801242 <readn+0x3d>
			return m;
		if (m == 0)
  801236:	85 c0                	test   %eax,%eax
  801238:	74 06                	je     801240 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123a:	01 c3                	add    %eax,%ebx
  80123c:	39 f3                	cmp    %esi,%ebx
  80123e:	72 db                	jb     80121b <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801240:	89 d8                	mov    %ebx,%eax
}
  801242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	53                   	push   %ebx
  80124e:	83 ec 14             	sub    $0x14,%esp
  801251:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801254:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	53                   	push   %ebx
  801259:	e8 a7 fc ff ff       	call   800f05 <fd_lookup>
  80125e:	83 c4 08             	add    $0x8,%esp
  801261:	89 c2                	mov    %eax,%edx
  801263:	85 c0                	test   %eax,%eax
  801265:	78 68                	js     8012cf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801271:	ff 30                	pushl  (%eax)
  801273:	e8 e3 fc ff ff       	call   800f5b <dev_lookup>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 47                	js     8012c6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801282:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801286:	75 21                	jne    8012a9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801288:	a1 08 50 80 00       	mov    0x805008,%eax
  80128d:	8b 40 48             	mov    0x48(%eax),%eax
  801290:	83 ec 04             	sub    $0x4,%esp
  801293:	53                   	push   %ebx
  801294:	50                   	push   %eax
  801295:	68 69 2e 80 00       	push   $0x802e69
  80129a:	e8 ce ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a7:	eb 26                	jmp    8012cf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ac:	8b 52 0c             	mov    0xc(%edx),%edx
  8012af:	85 d2                	test   %edx,%edx
  8012b1:	74 17                	je     8012ca <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	ff 75 10             	pushl  0x10(%ebp)
  8012b9:	ff 75 0c             	pushl  0xc(%ebp)
  8012bc:	50                   	push   %eax
  8012bd:	ff d2                	call   *%edx
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	eb 09                	jmp    8012cf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	eb 05                	jmp    8012cf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012cf:	89 d0                	mov    %edx,%eax
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 1d fc ff ff       	call   800f05 <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 0e                	js     8012fd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	53                   	push   %ebx
  80130e:	e8 f2 fb ff ff       	call   800f05 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	89 c2                	mov    %eax,%edx
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 65                	js     801381 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801326:	ff 30                	pushl  (%eax)
  801328:	e8 2e fc ff ff       	call   800f5b <dev_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 44                	js     801378 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801334:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801337:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133b:	75 21                	jne    80135e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80133d:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801342:	8b 40 48             	mov    0x48(%eax),%eax
  801345:	83 ec 04             	sub    $0x4,%esp
  801348:	53                   	push   %ebx
  801349:	50                   	push   %eax
  80134a:	68 2c 2e 80 00       	push   $0x802e2c
  80134f:	e8 19 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135c:	eb 23                	jmp    801381 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80135e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801361:	8b 52 18             	mov    0x18(%edx),%edx
  801364:	85 d2                	test   %edx,%edx
  801366:	74 14                	je     80137c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	ff 75 0c             	pushl  0xc(%ebp)
  80136e:	50                   	push   %eax
  80136f:	ff d2                	call   *%edx
  801371:	89 c2                	mov    %eax,%edx
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	eb 09                	jmp    801381 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801378:	89 c2                	mov    %eax,%edx
  80137a:	eb 05                	jmp    801381 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80137c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801381:	89 d0                	mov    %edx,%eax
  801383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	83 ec 14             	sub    $0x14,%esp
  80138f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 67 fb ff ff       	call   800f05 <fd_lookup>
  80139e:	83 c4 08             	add    $0x8,%esp
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 58                	js     8013ff <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	ff 30                	pushl  (%eax)
  8013b3:	e8 a3 fb ff ff       	call   800f5b <dev_lookup>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 37                	js     8013f6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c6:	74 32                	je     8013fa <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013cb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d2:	00 00 00 
	stat->st_isdir = 0;
  8013d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013dc:	00 00 00 
	stat->st_dev = dev;
  8013df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	53                   	push   %ebx
  8013e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ec:	ff 50 14             	call   *0x14(%eax)
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	eb 09                	jmp    8013ff <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	eb 05                	jmp    8013ff <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ff:	89 d0                	mov    %edx,%eax
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	6a 00                	push   $0x0
  801410:	ff 75 08             	pushl  0x8(%ebp)
  801413:	e8 09 02 00 00       	call   801621 <open>
  801418:	89 c3                	mov    %eax,%ebx
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 db                	test   %ebx,%ebx
  80141f:	78 1b                	js     80143c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	ff 75 0c             	pushl  0xc(%ebp)
  801427:	53                   	push   %ebx
  801428:	e8 5b ff ff ff       	call   801388 <fstat>
  80142d:	89 c6                	mov    %eax,%esi
	close(fd);
  80142f:	89 1c 24             	mov    %ebx,(%esp)
  801432:	e8 fd fb ff ff       	call   801034 <close>
	return r;
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	89 f0                	mov    %esi,%eax
}
  80143c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	89 c6                	mov    %eax,%esi
  80144a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80144c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801453:	75 12                	jne    801467 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	6a 01                	push   $0x1
  80145a:	e8 30 12 00 00       	call   80268f <ipc_find_env>
  80145f:	a3 00 50 80 00       	mov    %eax,0x805000
  801464:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801467:	6a 07                	push   $0x7
  801469:	68 00 60 80 00       	push   $0x806000
  80146e:	56                   	push   %esi
  80146f:	ff 35 00 50 80 00    	pushl  0x805000
  801475:	e8 c1 11 00 00       	call   80263b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80147a:	83 c4 0c             	add    $0xc,%esp
  80147d:	6a 00                	push   $0x0
  80147f:	53                   	push   %ebx
  801480:	6a 00                	push   $0x0
  801482:	e8 4b 11 00 00       	call   8025d2 <ipc_recv>
}
  801487:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5e                   	pop    %esi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	8b 40 0c             	mov    0xc(%eax),%eax
  80149a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80149f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b1:	e8 8d ff ff ff       	call   801443 <fsipc>
}
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014be:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d3:	e8 6b ff ff ff       	call   801443 <fsipc>
}
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 04             	sub    $0x4,%esp
  8014e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ea:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f9:	e8 45 ff ff ff       	call   801443 <fsipc>
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	85 d2                	test   %edx,%edx
  801502:	78 2c                	js     801530 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	68 00 60 80 00       	push   $0x806000
  80150c:	53                   	push   %ebx
  80150d:	e8 e2 f2 ff ff       	call   8007f4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801512:	a1 80 60 80 00       	mov    0x806080,%eax
  801517:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151d:	a1 84 60 80 00       	mov    0x806084,%eax
  801522:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801530:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	57                   	push   %edi
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801541:	8b 45 08             	mov    0x8(%ebp),%eax
  801544:	8b 40 0c             	mov    0xc(%eax),%eax
  801547:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80154c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80154f:	eb 3d                	jmp    80158e <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801551:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801557:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80155c:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	57                   	push   %edi
  801563:	53                   	push   %ebx
  801564:	68 08 60 80 00       	push   $0x806008
  801569:	e8 18 f4 ff ff       	call   800986 <memmove>
                fsipcbuf.write.req_n = tmp; 
  80156e:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 04 00 00 00       	mov    $0x4,%eax
  80157e:	e8 c0 fe ff ff       	call   801443 <fsipc>
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 0d                	js     801597 <devfile_write+0x62>
		        return r;
                n -= tmp;
  80158a:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80158c:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80158e:	85 f6                	test   %esi,%esi
  801590:	75 bf                	jne    801551 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801592:	89 d8                	mov    %ebx,%eax
  801594:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801597:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5f                   	pop    %edi
  80159d:	5d                   	pop    %ebp
  80159e:	c3                   	ret    

0080159f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	56                   	push   %esi
  8015a3:	53                   	push   %ebx
  8015a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ad:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8015b2:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c2:	e8 7c fe ff ff       	call   801443 <fsipc>
  8015c7:	89 c3                	mov    %eax,%ebx
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 4b                	js     801618 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015cd:	39 c6                	cmp    %eax,%esi
  8015cf:	73 16                	jae    8015e7 <devfile_read+0x48>
  8015d1:	68 9c 2e 80 00       	push   $0x802e9c
  8015d6:	68 a3 2e 80 00       	push   $0x802ea3
  8015db:	6a 7c                	push   $0x7c
  8015dd:	68 b8 2e 80 00       	push   $0x802eb8
  8015e2:	e8 ad eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  8015e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ec:	7e 16                	jle    801604 <devfile_read+0x65>
  8015ee:	68 c3 2e 80 00       	push   $0x802ec3
  8015f3:	68 a3 2e 80 00       	push   $0x802ea3
  8015f8:	6a 7d                	push   $0x7d
  8015fa:	68 b8 2e 80 00       	push   $0x802eb8
  8015ff:	e8 90 eb ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801604:	83 ec 04             	sub    $0x4,%esp
  801607:	50                   	push   %eax
  801608:	68 00 60 80 00       	push   $0x806000
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	e8 71 f3 ff ff       	call   800986 <memmove>
	return r;
  801615:	83 c4 10             	add    $0x10,%esp
}
  801618:	89 d8                	mov    %ebx,%eax
  80161a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161d:	5b                   	pop    %ebx
  80161e:	5e                   	pop    %esi
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	53                   	push   %ebx
  801625:	83 ec 20             	sub    $0x20,%esp
  801628:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80162b:	53                   	push   %ebx
  80162c:	e8 8a f1 ff ff       	call   8007bb <strlen>
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801639:	7f 67                	jg     8016a2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	e8 6f f8 ff ff       	call   800eb6 <fd_alloc>
  801647:	83 c4 10             	add    $0x10,%esp
		return r;
  80164a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 57                	js     8016a7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	68 00 60 80 00       	push   $0x806000
  801659:	e8 96 f1 ff ff       	call   8007f4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80165e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801661:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801666:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801669:	b8 01 00 00 00       	mov    $0x1,%eax
  80166e:	e8 d0 fd ff ff       	call   801443 <fsipc>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	79 14                	jns    801690 <open+0x6f>
		fd_close(fd, 0);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	6a 00                	push   $0x0
  801681:	ff 75 f4             	pushl  -0xc(%ebp)
  801684:	e8 2a f9 ff ff       	call   800fb3 <fd_close>
		return r;
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	89 da                	mov    %ebx,%edx
  80168e:	eb 17                	jmp    8016a7 <open+0x86>
	}

	return fd2num(fd);
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	ff 75 f4             	pushl  -0xc(%ebp)
  801696:	e8 f4 f7 ff ff       	call   800e8f <fd2num>
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	eb 05                	jmp    8016a7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8016be:	e8 80 fd ff ff       	call   801443 <fsipc>
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8016d1:	6a 00                	push   $0x0
  8016d3:	ff 75 08             	pushl  0x8(%ebp)
  8016d6:	e8 46 ff ff ff       	call   801621 <open>
  8016db:	89 c7                	mov    %eax,%edi
  8016dd:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	0f 88 97 04 00 00    	js     801b85 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	68 00 02 00 00       	push   $0x200
  8016f6:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	57                   	push   %edi
  8016fe:	e8 02 fb ff ff       	call   801205 <readn>
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	3d 00 02 00 00       	cmp    $0x200,%eax
  80170b:	75 0c                	jne    801719 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80170d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801714:	45 4c 46 
  801717:	74 33                	je     80174c <spawn+0x87>
		close(fd);
  801719:	83 ec 0c             	sub    $0xc,%esp
  80171c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801722:	e8 0d f9 ff ff       	call   801034 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801727:	83 c4 0c             	add    $0xc,%esp
  80172a:	68 7f 45 4c 46       	push   $0x464c457f
  80172f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801735:	68 cf 2e 80 00       	push   $0x802ecf
  80173a:	e8 2e eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801747:	e9 be 04 00 00       	jmp    801c0a <spawn+0x545>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80174c:	b8 07 00 00 00       	mov    $0x7,%eax
  801751:	cd 30                	int    $0x30
  801753:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801759:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80175f:	85 c0                	test   %eax,%eax
  801761:	0f 88 26 04 00 00    	js     801b8d <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801767:	89 c6                	mov    %eax,%esi
  801769:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80176f:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801772:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801778:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80177e:	b9 11 00 00 00       	mov    $0x11,%ecx
  801783:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801785:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80178b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801791:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801796:	be 00 00 00 00       	mov    $0x0,%esi
  80179b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80179e:	eb 13                	jmp    8017b3 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	50                   	push   %eax
  8017a4:	e8 12 f0 ff ff       	call   8007bb <strlen>
  8017a9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017ad:	83 c3 01             	add    $0x1,%ebx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8017ba:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	75 df                	jne    8017a0 <spawn+0xdb>
  8017c1:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8017c7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017cd:	bf 00 10 40 00       	mov    $0x401000,%edi
  8017d2:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8017d4:	89 fa                	mov    %edi,%edx
  8017d6:	83 e2 fc             	and    $0xfffffffc,%edx
  8017d9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8017e0:	29 c2                	sub    %eax,%edx
  8017e2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017e8:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017eb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017f0:	0f 86 a7 03 00 00    	jbe    801b9d <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	6a 07                	push   $0x7
  8017fb:	68 00 00 40 00       	push   $0x400000
  801800:	6a 00                	push   $0x0
  801802:	e8 f6 f3 ff ff       	call   800bfd <sys_page_alloc>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	0f 88 f8 03 00 00    	js     801c0a <spawn+0x545>
  801812:	be 00 00 00 00       	mov    $0x0,%esi
  801817:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80181d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801820:	eb 30                	jmp    801852 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801822:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801828:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80182e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801837:	57                   	push   %edi
  801838:	e8 b7 ef ff ff       	call   8007f4 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80183d:	83 c4 04             	add    $0x4,%esp
  801840:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801843:	e8 73 ef ff ff       	call   8007bb <strlen>
  801848:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80184c:	83 c6 01             	add    $0x1,%esi
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801858:	7f c8                	jg     801822 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80185a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801860:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801866:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80186d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801873:	74 19                	je     80188e <spawn+0x1c9>
  801875:	68 5c 2f 80 00       	push   $0x802f5c
  80187a:	68 a3 2e 80 00       	push   $0x802ea3
  80187f:	68 f1 00 00 00       	push   $0xf1
  801884:	68 e9 2e 80 00       	push   $0x802ee9
  801889:	e8 06 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80188e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801894:	89 f8                	mov    %edi,%eax
  801896:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80189b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80189e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8018a4:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8018a7:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8018ad:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	6a 07                	push   $0x7
  8018b8:	68 00 d0 bf ee       	push   $0xeebfd000
  8018bd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018c3:	68 00 00 40 00       	push   $0x400000
  8018c8:	6a 00                	push   $0x0
  8018ca:	e8 71 f3 ff ff       	call   800c40 <sys_page_map>
  8018cf:	89 c3                	mov    %eax,%ebx
  8018d1:	83 c4 20             	add    $0x20,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	0f 88 1a 03 00 00    	js     801bf6 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	68 00 00 40 00       	push   $0x400000
  8018e4:	6a 00                	push   $0x0
  8018e6:	e8 97 f3 ff ff       	call   800c82 <sys_page_unmap>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	0f 88 fe 02 00 00    	js     801bf6 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018f8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018fe:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801905:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80190b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801912:	00 00 00 
  801915:	e9 85 01 00 00       	jmp    801a9f <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  80191a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801920:	83 38 01             	cmpl   $0x1,(%eax)
  801923:	0f 85 68 01 00 00    	jne    801a91 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801929:	89 c7                	mov    %eax,%edi
  80192b:	8b 40 18             	mov    0x18(%eax),%eax
  80192e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801934:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801937:	83 f8 01             	cmp    $0x1,%eax
  80193a:	19 c0                	sbb    %eax,%eax
  80193c:	83 e0 fe             	and    $0xfffffffe,%eax
  80193f:	83 c0 07             	add    $0x7,%eax
  801942:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801948:	89 f8                	mov    %edi,%eax
  80194a:	8b 7f 04             	mov    0x4(%edi),%edi
  80194d:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801953:	8b 78 10             	mov    0x10(%eax),%edi
  801956:	8b 48 14             	mov    0x14(%eax),%ecx
  801959:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  80195f:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801962:	89 f0                	mov    %esi,%eax
  801964:	25 ff 0f 00 00       	and    $0xfff,%eax
  801969:	74 10                	je     80197b <spawn+0x2b6>
		va -= i;
  80196b:	29 c6                	sub    %eax,%esi
		memsz += i;
  80196d:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801973:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801975:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80197b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801980:	e9 fa 00 00 00       	jmp    801a7f <spawn+0x3ba>
		if (i >= filesz) {
  801985:	39 fb                	cmp    %edi,%ebx
  801987:	72 27                	jb     8019b0 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801989:	83 ec 04             	sub    $0x4,%esp
  80198c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801992:	56                   	push   %esi
  801993:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801999:	e8 5f f2 ff ff       	call   800bfd <sys_page_alloc>
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	0f 89 ca 00 00 00    	jns    801a73 <spawn+0x3ae>
  8019a9:	89 c7                	mov    %eax,%edi
  8019ab:	e9 fe 01 00 00       	jmp    801bae <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019b0:	83 ec 04             	sub    $0x4,%esp
  8019b3:	6a 07                	push   $0x7
  8019b5:	68 00 00 40 00       	push   $0x400000
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 3c f2 ff ff       	call   800bfd <sys_page_alloc>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	0f 88 d8 01 00 00    	js     801ba4 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019d5:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  8019db:	50                   	push   %eax
  8019dc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019e2:	e8 ef f8 ff ff       	call   8012d6 <seek>
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	0f 88 b6 01 00 00    	js     801ba8 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	89 fa                	mov    %edi,%edx
  8019f7:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  8019fd:	89 d0                	mov    %edx,%eax
  8019ff:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801a05:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801a0a:	0f 47 c1             	cmova  %ecx,%eax
  801a0d:	50                   	push   %eax
  801a0e:	68 00 00 40 00       	push   $0x400000
  801a13:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a19:	e8 e7 f7 ff ff       	call   801205 <readn>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	0f 88 83 01 00 00    	js     801bac <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a32:	56                   	push   %esi
  801a33:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a39:	68 00 00 40 00       	push   $0x400000
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 fb f1 ff ff       	call   800c40 <sys_page_map>
  801a45:	83 c4 20             	add    $0x20,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	79 15                	jns    801a61 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801a4c:	50                   	push   %eax
  801a4d:	68 f5 2e 80 00       	push   $0x802ef5
  801a52:	68 24 01 00 00       	push   $0x124
  801a57:	68 e9 2e 80 00       	push   $0x802ee9
  801a5c:	e8 33 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801a61:	83 ec 08             	sub    $0x8,%esp
  801a64:	68 00 00 40 00       	push   $0x400000
  801a69:	6a 00                	push   $0x0
  801a6b:	e8 12 f2 ff ff       	call   800c82 <sys_page_unmap>
  801a70:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a73:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a79:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a7f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a85:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801a8b:	0f 82 f4 fe ff ff    	jb     801985 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a91:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a98:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a9f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801aa6:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801aac:	0f 8c 68 fe ff ff    	jl     80191a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801abb:	e8 74 f5 ff ff       	call   801034 <close>
  801ac0:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801ac3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801ace:	89 d8                	mov    %ebx,%eax
  801ad0:	c1 e8 16             	shr    $0x16,%eax
  801ad3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ada:	a8 01                	test   $0x1,%al
  801adc:	74 53                	je     801b31 <spawn+0x46c>
  801ade:	89 d8                	mov    %ebx,%eax
  801ae0:	c1 e8 0c             	shr    $0xc,%eax
  801ae3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801aea:	f6 c2 01             	test   $0x1,%dl
  801aed:	74 42                	je     801b31 <spawn+0x46c>
  801aef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801af6:	f6 c6 04             	test   $0x4,%dh
  801af9:	74 36                	je     801b31 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801afb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	25 07 0e 00 00       	and    $0xe07,%eax
  801b0a:	50                   	push   %eax
  801b0b:	53                   	push   %ebx
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	6a 00                	push   $0x0
  801b10:	e8 2b f1 ff ff       	call   800c40 <sys_page_map>
                        if (r < 0) return r;
  801b15:	83 c4 20             	add    $0x20,%esp
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	79 15                	jns    801b31 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b1c:	50                   	push   %eax
  801b1d:	68 12 2f 80 00       	push   $0x802f12
  801b22:	68 82 00 00 00       	push   $0x82
  801b27:	68 e9 2e 80 00       	push   $0x802ee9
  801b2c:	e8 63 e6 ff ff       	call   800194 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801b31:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b37:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801b3d:	75 8f                	jne    801ace <spawn+0x409>
  801b3f:	e9 8d 00 00 00       	jmp    801bd1 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801b44:	50                   	push   %eax
  801b45:	68 28 2f 80 00       	push   $0x802f28
  801b4a:	68 85 00 00 00       	push   $0x85
  801b4f:	68 e9 2e 80 00       	push   $0x802ee9
  801b54:	e8 3b e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	6a 02                	push   $0x2
  801b5e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b64:	e8 5b f1 ff ff       	call   800cc4 <sys_env_set_status>
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	79 25                	jns    801b95 <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801b70:	50                   	push   %eax
  801b71:	68 42 2f 80 00       	push   $0x802f42
  801b76:	68 88 00 00 00       	push   $0x88
  801b7b:	68 e9 2e 80 00       	push   $0x802ee9
  801b80:	e8 0f e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b85:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b8b:	eb 7d                	jmp    801c0a <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b8d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b93:	eb 75                	jmp    801c0a <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b95:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b9b:	eb 6d                	jmp    801c0a <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b9d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801ba2:	eb 66                	jmp    801c0a <spawn+0x545>
  801ba4:	89 c7                	mov    %eax,%edi
  801ba6:	eb 06                	jmp    801bae <spawn+0x4e9>
  801ba8:	89 c7                	mov    %eax,%edi
  801baa:	eb 02                	jmp    801bae <spawn+0x4e9>
  801bac:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb7:	e8 c2 ef ff ff       	call   800b7e <sys_env_destroy>
	close(fd);
  801bbc:	83 c4 04             	add    $0x4,%esp
  801bbf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc5:	e8 6a f4 ff ff       	call   801034 <close>
	return r;
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	89 f8                	mov    %edi,%eax
  801bcf:	eb 39                	jmp    801c0a <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801bd1:	83 ec 08             	sub    $0x8,%esp
  801bd4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801be1:	e8 20 f1 ff ff       	call   800d06 <sys_env_set_trapframe>
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	0f 89 68 ff ff ff    	jns    801b59 <spawn+0x494>
  801bf1:	e9 4e ff ff ff       	jmp    801b44 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801bf6:	83 ec 08             	sub    $0x8,%esp
  801bf9:	68 00 00 40 00       	push   $0x400000
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 7d f0 ff ff       	call   800c82 <sys_page_unmap>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c17:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c1f:	eb 03                	jmp    801c24 <spawnl+0x12>
		argc++;
  801c21:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c24:	83 c2 04             	add    $0x4,%edx
  801c27:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801c2b:	75 f4                	jne    801c21 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801c2d:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c34:	83 e2 f0             	and    $0xfffffff0,%edx
  801c37:	29 d4                	sub    %edx,%esp
  801c39:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c3d:	c1 ea 02             	shr    $0x2,%edx
  801c40:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c47:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4c:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c53:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c5a:	00 
  801c5b:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	eb 0a                	jmp    801c6e <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c64:	83 c0 01             	add    $0x1,%eax
  801c67:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c6b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c6e:	39 d0                	cmp    %edx,%eax
  801c70:	75 f2                	jne    801c64 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c72:	83 ec 08             	sub    $0x8,%esp
  801c75:	56                   	push   %esi
  801c76:	ff 75 08             	pushl  0x8(%ebp)
  801c79:	e8 47 fa ff ff       	call   8016c5 <spawn>
}
  801c7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c8b:	68 84 2f 80 00       	push   $0x802f84
  801c90:	ff 75 0c             	pushl  0xc(%ebp)
  801c93:	e8 5c eb ff ff       	call   8007f4 <strcpy>
	return 0;
}
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	53                   	push   %ebx
  801ca3:	83 ec 10             	sub    $0x10,%esp
  801ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ca9:	53                   	push   %ebx
  801caa:	e8 18 0a 00 00       	call   8026c7 <pageref>
  801caf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cb2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cb7:	83 f8 01             	cmp    $0x1,%eax
  801cba:	75 10                	jne    801ccc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 73 0c             	pushl  0xc(%ebx)
  801cc2:	e8 ca 02 00 00       	call   801f91 <nsipc_close>
  801cc7:	89 c2                	mov    %eax,%edx
  801cc9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ccc:	89 d0                	mov    %edx,%eax
  801cce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cd9:	6a 00                	push   $0x0
  801cdb:	ff 75 10             	pushl  0x10(%ebp)
  801cde:	ff 75 0c             	pushl  0xc(%ebp)
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	ff 70 0c             	pushl  0xc(%eax)
  801ce7:	e8 82 03 00 00       	call   80206e <nsipc_send>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cf4:	6a 00                	push   $0x0
  801cf6:	ff 75 10             	pushl  0x10(%ebp)
  801cf9:	ff 75 0c             	pushl  0xc(%ebp)
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	ff 70 0c             	pushl  0xc(%eax)
  801d02:	e8 fb 02 00 00       	call   802002 <nsipc_recv>
}
  801d07:	c9                   	leave  
  801d08:	c3                   	ret    

00801d09 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d0f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d12:	52                   	push   %edx
  801d13:	50                   	push   %eax
  801d14:	e8 ec f1 ff ff       	call   800f05 <fd_lookup>
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 17                	js     801d37 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801d29:	39 08                	cmp    %ecx,(%eax)
  801d2b:	75 05                	jne    801d32 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d30:	eb 05                	jmp    801d37 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d32:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 1c             	sub    $0x1c,%esp
  801d41:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	e8 6a f1 ff ff       	call   800eb6 <fd_alloc>
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	85 c0                	test   %eax,%eax
  801d53:	78 1b                	js     801d70 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d55:	83 ec 04             	sub    $0x4,%esp
  801d58:	68 07 04 00 00       	push   $0x407
  801d5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d60:	6a 00                	push   $0x0
  801d62:	e8 96 ee ff ff       	call   800bfd <sys_page_alloc>
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	79 10                	jns    801d80 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d70:	83 ec 0c             	sub    $0xc,%esp
  801d73:	56                   	push   %esi
  801d74:	e8 18 02 00 00       	call   801f91 <nsipc_close>
		return r;
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	eb 24                	jmp    801da4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d80:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d89:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d8e:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801d95:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	52                   	push   %edx
  801d9c:	e8 ee f0 ff ff       	call   800e8f <fd2num>
  801da1:	83 c4 10             	add    $0x10,%esp
}
  801da4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db1:	8b 45 08             	mov    0x8(%ebp),%eax
  801db4:	e8 50 ff ff ff       	call   801d09 <fd2sockid>
		return r;
  801db9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	78 1f                	js     801dde <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dbf:	83 ec 04             	sub    $0x4,%esp
  801dc2:	ff 75 10             	pushl  0x10(%ebp)
  801dc5:	ff 75 0c             	pushl  0xc(%ebp)
  801dc8:	50                   	push   %eax
  801dc9:	e8 1c 01 00 00       	call   801eea <nsipc_accept>
  801dce:	83 c4 10             	add    $0x10,%esp
		return r;
  801dd1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	78 07                	js     801dde <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dd7:	e8 5d ff ff ff       	call   801d39 <alloc_sockfd>
  801ddc:	89 c1                	mov    %eax,%ecx
}
  801dde:	89 c8                	mov    %ecx,%eax
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	e8 19 ff ff ff       	call   801d09 <fd2sockid>
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	85 d2                	test   %edx,%edx
  801df4:	78 12                	js     801e08 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801df6:	83 ec 04             	sub    $0x4,%esp
  801df9:	ff 75 10             	pushl  0x10(%ebp)
  801dfc:	ff 75 0c             	pushl  0xc(%ebp)
  801dff:	52                   	push   %edx
  801e00:	e8 35 01 00 00       	call   801f3a <nsipc_bind>
  801e05:	83 c4 10             	add    $0x10,%esp
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <shutdown>:

int
shutdown(int s, int how)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	e8 f1 fe ff ff       	call   801d09 <fd2sockid>
  801e18:	89 c2                	mov    %eax,%edx
  801e1a:	85 d2                	test   %edx,%edx
  801e1c:	78 0f                	js     801e2d <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801e1e:	83 ec 08             	sub    $0x8,%esp
  801e21:	ff 75 0c             	pushl  0xc(%ebp)
  801e24:	52                   	push   %edx
  801e25:	e8 45 01 00 00       	call   801f6f <nsipc_shutdown>
  801e2a:	83 c4 10             	add    $0x10,%esp
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	e8 cc fe ff ff       	call   801d09 <fd2sockid>
  801e3d:	89 c2                	mov    %eax,%edx
  801e3f:	85 d2                	test   %edx,%edx
  801e41:	78 12                	js     801e55 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801e43:	83 ec 04             	sub    $0x4,%esp
  801e46:	ff 75 10             	pushl  0x10(%ebp)
  801e49:	ff 75 0c             	pushl  0xc(%ebp)
  801e4c:	52                   	push   %edx
  801e4d:	e8 59 01 00 00       	call   801fab <nsipc_connect>
  801e52:	83 c4 10             	add    $0x10,%esp
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <listen>:

int
listen(int s, int backlog)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	e8 a4 fe ff ff       	call   801d09 <fd2sockid>
  801e65:	89 c2                	mov    %eax,%edx
  801e67:	85 d2                	test   %edx,%edx
  801e69:	78 0f                	js     801e7a <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e6b:	83 ec 08             	sub    $0x8,%esp
  801e6e:	ff 75 0c             	pushl  0xc(%ebp)
  801e71:	52                   	push   %edx
  801e72:	e8 69 01 00 00       	call   801fe0 <nsipc_listen>
  801e77:	83 c4 10             	add    $0x10,%esp
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e82:	ff 75 10             	pushl  0x10(%ebp)
  801e85:	ff 75 0c             	pushl  0xc(%ebp)
  801e88:	ff 75 08             	pushl  0x8(%ebp)
  801e8b:	e8 3c 02 00 00       	call   8020cc <nsipc_socket>
  801e90:	89 c2                	mov    %eax,%edx
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	85 d2                	test   %edx,%edx
  801e97:	78 05                	js     801e9e <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801e99:	e8 9b fe ff ff       	call   801d39 <alloc_sockfd>
}
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ea9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801eb0:	75 12                	jne    801ec4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	6a 02                	push   $0x2
  801eb7:	e8 d3 07 00 00       	call   80268f <ipc_find_env>
  801ebc:	a3 04 50 80 00       	mov    %eax,0x805004
  801ec1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ec4:	6a 07                	push   $0x7
  801ec6:	68 00 70 80 00       	push   $0x807000
  801ecb:	53                   	push   %ebx
  801ecc:	ff 35 04 50 80 00    	pushl  0x805004
  801ed2:	e8 64 07 00 00       	call   80263b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ed7:	83 c4 0c             	add    $0xc,%esp
  801eda:	6a 00                	push   $0x0
  801edc:	6a 00                	push   $0x0
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 ed 06 00 00       	call   8025d2 <ipc_recv>
}
  801ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801efa:	8b 06                	mov    (%esi),%eax
  801efc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f01:	b8 01 00 00 00       	mov    $0x1,%eax
  801f06:	e8 95 ff ff ff       	call   801ea0 <nsipc>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 20                	js     801f31 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f11:	83 ec 04             	sub    $0x4,%esp
  801f14:	ff 35 10 70 80 00    	pushl  0x807010
  801f1a:	68 00 70 80 00       	push   $0x807000
  801f1f:	ff 75 0c             	pushl  0xc(%ebp)
  801f22:	e8 5f ea ff ff       	call   800986 <memmove>
		*addrlen = ret->ret_addrlen;
  801f27:	a1 10 70 80 00       	mov    0x807010,%eax
  801f2c:	89 06                	mov    %eax,(%esi)
  801f2e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f31:	89 d8                	mov    %ebx,%eax
  801f33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f36:	5b                   	pop    %ebx
  801f37:	5e                   	pop    %esi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f4c:	53                   	push   %ebx
  801f4d:	ff 75 0c             	pushl  0xc(%ebp)
  801f50:	68 04 70 80 00       	push   $0x807004
  801f55:	e8 2c ea ff ff       	call   800986 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f5a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f60:	b8 02 00 00 00       	mov    $0x2,%eax
  801f65:	e8 36 ff ff ff       	call   801ea0 <nsipc>
}
  801f6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f75:	8b 45 08             	mov    0x8(%ebp),%eax
  801f78:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f80:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f85:	b8 03 00 00 00       	mov    $0x3,%eax
  801f8a:	e8 11 ff ff ff       	call   801ea0 <nsipc>
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <nsipc_close>:

int
nsipc_close(int s)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f97:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f9f:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa4:	e8 f7 fe ff ff       	call   801ea0 <nsipc>
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	53                   	push   %ebx
  801faf:	83 ec 08             	sub    $0x8,%esp
  801fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fbd:	53                   	push   %ebx
  801fbe:	ff 75 0c             	pushl  0xc(%ebp)
  801fc1:	68 04 70 80 00       	push   $0x807004
  801fc6:	e8 bb e9 ff ff       	call   800986 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fcb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fd1:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd6:	e8 c5 fe ff ff       	call   801ea0 <nsipc>
}
  801fdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801fee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ff6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ffb:	e8 a0 fe ff ff       	call   801ea0 <nsipc>
}
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	56                   	push   %esi
  802006:	53                   	push   %ebx
  802007:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802012:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802018:	8b 45 14             	mov    0x14(%ebp),%eax
  80201b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802020:	b8 07 00 00 00       	mov    $0x7,%eax
  802025:	e8 76 fe ff ff       	call   801ea0 <nsipc>
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 35                	js     802065 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802030:	39 f0                	cmp    %esi,%eax
  802032:	7f 07                	jg     80203b <nsipc_recv+0x39>
  802034:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802039:	7e 16                	jle    802051 <nsipc_recv+0x4f>
  80203b:	68 90 2f 80 00       	push   $0x802f90
  802040:	68 a3 2e 80 00       	push   $0x802ea3
  802045:	6a 62                	push   $0x62
  802047:	68 a5 2f 80 00       	push   $0x802fa5
  80204c:	e8 43 e1 ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802051:	83 ec 04             	sub    $0x4,%esp
  802054:	50                   	push   %eax
  802055:	68 00 70 80 00       	push   $0x807000
  80205a:	ff 75 0c             	pushl  0xc(%ebp)
  80205d:	e8 24 e9 ff ff       	call   800986 <memmove>
  802062:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802065:	89 d8                	mov    %ebx,%eax
  802067:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    

0080206e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	53                   	push   %ebx
  802072:	83 ec 04             	sub    $0x4,%esp
  802075:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802078:	8b 45 08             	mov    0x8(%ebp),%eax
  80207b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802080:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802086:	7e 16                	jle    80209e <nsipc_send+0x30>
  802088:	68 b1 2f 80 00       	push   $0x802fb1
  80208d:	68 a3 2e 80 00       	push   $0x802ea3
  802092:	6a 6d                	push   $0x6d
  802094:	68 a5 2f 80 00       	push   $0x802fa5
  802099:	e8 f6 e0 ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80209e:	83 ec 04             	sub    $0x4,%esp
  8020a1:	53                   	push   %ebx
  8020a2:	ff 75 0c             	pushl  0xc(%ebp)
  8020a5:	68 0c 70 80 00       	push   $0x80700c
  8020aa:	e8 d7 e8 ff ff       	call   800986 <memmove>
	nsipcbuf.send.req_size = size;
  8020af:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8020c2:	e8 d9 fd ff ff       	call   801ea0 <nsipc>
}
  8020c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020dd:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020ea:	b8 09 00 00 00       	mov    $0x9,%eax
  8020ef:	e8 ac fd ff ff       	call   801ea0 <nsipc>
}
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	56                   	push   %esi
  8020fa:	53                   	push   %ebx
  8020fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020fe:	83 ec 0c             	sub    $0xc,%esp
  802101:	ff 75 08             	pushl  0x8(%ebp)
  802104:	e8 96 ed ff ff       	call   800e9f <fd2data>
  802109:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80210b:	83 c4 08             	add    $0x8,%esp
  80210e:	68 bd 2f 80 00       	push   $0x802fbd
  802113:	53                   	push   %ebx
  802114:	e8 db e6 ff ff       	call   8007f4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802119:	8b 56 04             	mov    0x4(%esi),%edx
  80211c:	89 d0                	mov    %edx,%eax
  80211e:	2b 06                	sub    (%esi),%eax
  802120:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802126:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80212d:	00 00 00 
	stat->st_dev = &devpipe;
  802130:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802137:	40 80 00 
	return 0;
}
  80213a:	b8 00 00 00 00       	mov    $0x0,%eax
  80213f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802142:	5b                   	pop    %ebx
  802143:	5e                   	pop    %esi
  802144:	5d                   	pop    %ebp
  802145:	c3                   	ret    

00802146 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802146:	55                   	push   %ebp
  802147:	89 e5                	mov    %esp,%ebp
  802149:	53                   	push   %ebx
  80214a:	83 ec 0c             	sub    $0xc,%esp
  80214d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802150:	53                   	push   %ebx
  802151:	6a 00                	push   $0x0
  802153:	e8 2a eb ff ff       	call   800c82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802158:	89 1c 24             	mov    %ebx,(%esp)
  80215b:	e8 3f ed ff ff       	call   800e9f <fd2data>
  802160:	83 c4 08             	add    $0x8,%esp
  802163:	50                   	push   %eax
  802164:	6a 00                	push   $0x0
  802166:	e8 17 eb ff ff       	call   800c82 <sys_page_unmap>
}
  80216b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80216e:	c9                   	leave  
  80216f:	c3                   	ret    

00802170 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	53                   	push   %ebx
  802176:	83 ec 1c             	sub    $0x1c,%esp
  802179:	89 c6                	mov    %eax,%esi
  80217b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80217e:	a1 08 50 80 00       	mov    0x805008,%eax
  802183:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802186:	83 ec 0c             	sub    $0xc,%esp
  802189:	56                   	push   %esi
  80218a:	e8 38 05 00 00       	call   8026c7 <pageref>
  80218f:	89 c7                	mov    %eax,%edi
  802191:	83 c4 04             	add    $0x4,%esp
  802194:	ff 75 e4             	pushl  -0x1c(%ebp)
  802197:	e8 2b 05 00 00       	call   8026c7 <pageref>
  80219c:	83 c4 10             	add    $0x10,%esp
  80219f:	39 c7                	cmp    %eax,%edi
  8021a1:	0f 94 c2             	sete   %dl
  8021a4:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8021a7:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8021ad:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8021b0:	39 fb                	cmp    %edi,%ebx
  8021b2:	74 19                	je     8021cd <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8021b4:	84 d2                	test   %dl,%dl
  8021b6:	74 c6                	je     80217e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021b8:	8b 51 58             	mov    0x58(%ecx),%edx
  8021bb:	50                   	push   %eax
  8021bc:	52                   	push   %edx
  8021bd:	53                   	push   %ebx
  8021be:	68 c4 2f 80 00       	push   $0x802fc4
  8021c3:	e8 a5 e0 ff ff       	call   80026d <cprintf>
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	eb b1                	jmp    80217e <_pipeisclosed+0xe>
	}
}
  8021cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    

008021d5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	57                   	push   %edi
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
  8021db:	83 ec 28             	sub    $0x28,%esp
  8021de:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021e1:	56                   	push   %esi
  8021e2:	e8 b8 ec ff ff       	call   800e9f <fd2data>
  8021e7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8021f1:	eb 4b                	jmp    80223e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021f3:	89 da                	mov    %ebx,%edx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	e8 74 ff ff ff       	call   802170 <_pipeisclosed>
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	75 48                	jne    802248 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802200:	e8 d9 e9 ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802205:	8b 43 04             	mov    0x4(%ebx),%eax
  802208:	8b 0b                	mov    (%ebx),%ecx
  80220a:	8d 51 20             	lea    0x20(%ecx),%edx
  80220d:	39 d0                	cmp    %edx,%eax
  80220f:	73 e2                	jae    8021f3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802214:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802218:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80221b:	89 c2                	mov    %eax,%edx
  80221d:	c1 fa 1f             	sar    $0x1f,%edx
  802220:	89 d1                	mov    %edx,%ecx
  802222:	c1 e9 1b             	shr    $0x1b,%ecx
  802225:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802228:	83 e2 1f             	and    $0x1f,%edx
  80222b:	29 ca                	sub    %ecx,%edx
  80222d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802231:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802235:	83 c0 01             	add    $0x1,%eax
  802238:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80223b:	83 c7 01             	add    $0x1,%edi
  80223e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802241:	75 c2                	jne    802205 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802243:	8b 45 10             	mov    0x10(%ebp),%eax
  802246:	eb 05                	jmp    80224d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80224d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    

00802255 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	57                   	push   %edi
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	83 ec 18             	sub    $0x18,%esp
  80225e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802261:	57                   	push   %edi
  802262:	e8 38 ec ff ff       	call   800e9f <fd2data>
  802267:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802271:	eb 3d                	jmp    8022b0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802273:	85 db                	test   %ebx,%ebx
  802275:	74 04                	je     80227b <devpipe_read+0x26>
				return i;
  802277:	89 d8                	mov    %ebx,%eax
  802279:	eb 44                	jmp    8022bf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80227b:	89 f2                	mov    %esi,%edx
  80227d:	89 f8                	mov    %edi,%eax
  80227f:	e8 ec fe ff ff       	call   802170 <_pipeisclosed>
  802284:	85 c0                	test   %eax,%eax
  802286:	75 32                	jne    8022ba <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802288:	e8 51 e9 ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80228d:	8b 06                	mov    (%esi),%eax
  80228f:	3b 46 04             	cmp    0x4(%esi),%eax
  802292:	74 df                	je     802273 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802294:	99                   	cltd   
  802295:	c1 ea 1b             	shr    $0x1b,%edx
  802298:	01 d0                	add    %edx,%eax
  80229a:	83 e0 1f             	and    $0x1f,%eax
  80229d:	29 d0                	sub    %edx,%eax
  80229f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8022a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022a7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8022aa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ad:	83 c3 01             	add    $0x1,%ebx
  8022b0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022b3:	75 d8                	jne    80228d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b8:	eb 05                	jmp    8022bf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022ba:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c2:	5b                   	pop    %ebx
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    

008022c7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	56                   	push   %esi
  8022cb:	53                   	push   %ebx
  8022cc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d2:	50                   	push   %eax
  8022d3:	e8 de eb ff ff       	call   800eb6 <fd_alloc>
  8022d8:	83 c4 10             	add    $0x10,%esp
  8022db:	89 c2                	mov    %eax,%edx
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	0f 88 2c 01 00 00    	js     802411 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e5:	83 ec 04             	sub    $0x4,%esp
  8022e8:	68 07 04 00 00       	push   $0x407
  8022ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f0:	6a 00                	push   $0x0
  8022f2:	e8 06 e9 ff ff       	call   800bfd <sys_page_alloc>
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	89 c2                	mov    %eax,%edx
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	0f 88 0d 01 00 00    	js     802411 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802304:	83 ec 0c             	sub    $0xc,%esp
  802307:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80230a:	50                   	push   %eax
  80230b:	e8 a6 eb ff ff       	call   800eb6 <fd_alloc>
  802310:	89 c3                	mov    %eax,%ebx
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	85 c0                	test   %eax,%eax
  802317:	0f 88 e2 00 00 00    	js     8023ff <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80231d:	83 ec 04             	sub    $0x4,%esp
  802320:	68 07 04 00 00       	push   $0x407
  802325:	ff 75 f0             	pushl  -0x10(%ebp)
  802328:	6a 00                	push   $0x0
  80232a:	e8 ce e8 ff ff       	call   800bfd <sys_page_alloc>
  80232f:	89 c3                	mov    %eax,%ebx
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	85 c0                	test   %eax,%eax
  802336:	0f 88 c3 00 00 00    	js     8023ff <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80233c:	83 ec 0c             	sub    $0xc,%esp
  80233f:	ff 75 f4             	pushl  -0xc(%ebp)
  802342:	e8 58 eb ff ff       	call   800e9f <fd2data>
  802347:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802349:	83 c4 0c             	add    $0xc,%esp
  80234c:	68 07 04 00 00       	push   $0x407
  802351:	50                   	push   %eax
  802352:	6a 00                	push   $0x0
  802354:	e8 a4 e8 ff ff       	call   800bfd <sys_page_alloc>
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	83 c4 10             	add    $0x10,%esp
  80235e:	85 c0                	test   %eax,%eax
  802360:	0f 88 89 00 00 00    	js     8023ef <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802366:	83 ec 0c             	sub    $0xc,%esp
  802369:	ff 75 f0             	pushl  -0x10(%ebp)
  80236c:	e8 2e eb ff ff       	call   800e9f <fd2data>
  802371:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802378:	50                   	push   %eax
  802379:	6a 00                	push   $0x0
  80237b:	56                   	push   %esi
  80237c:	6a 00                	push   $0x0
  80237e:	e8 bd e8 ff ff       	call   800c40 <sys_page_map>
  802383:	89 c3                	mov    %eax,%ebx
  802385:	83 c4 20             	add    $0x20,%esp
  802388:	85 c0                	test   %eax,%eax
  80238a:	78 55                	js     8023e1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80238c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802392:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802395:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802397:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023a1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023aa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023af:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023b6:	83 ec 0c             	sub    $0xc,%esp
  8023b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023bc:	e8 ce ea ff ff       	call   800e8f <fd2num>
  8023c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023c4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023c6:	83 c4 04             	add    $0x4,%esp
  8023c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8023cc:	e8 be ea ff ff       	call   800e8f <fd2num>
  8023d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023d4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	ba 00 00 00 00       	mov    $0x0,%edx
  8023df:	eb 30                	jmp    802411 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023e1:	83 ec 08             	sub    $0x8,%esp
  8023e4:	56                   	push   %esi
  8023e5:	6a 00                	push   $0x0
  8023e7:	e8 96 e8 ff ff       	call   800c82 <sys_page_unmap>
  8023ec:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023ef:	83 ec 08             	sub    $0x8,%esp
  8023f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8023f5:	6a 00                	push   $0x0
  8023f7:	e8 86 e8 ff ff       	call   800c82 <sys_page_unmap>
  8023fc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023ff:	83 ec 08             	sub    $0x8,%esp
  802402:	ff 75 f4             	pushl  -0xc(%ebp)
  802405:	6a 00                	push   $0x0
  802407:	e8 76 e8 ff ff       	call   800c82 <sys_page_unmap>
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802411:	89 d0                	mov    %edx,%eax
  802413:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802416:	5b                   	pop    %ebx
  802417:	5e                   	pop    %esi
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    

0080241a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80241a:	55                   	push   %ebp
  80241b:	89 e5                	mov    %esp,%ebp
  80241d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802423:	50                   	push   %eax
  802424:	ff 75 08             	pushl  0x8(%ebp)
  802427:	e8 d9 ea ff ff       	call   800f05 <fd_lookup>
  80242c:	89 c2                	mov    %eax,%edx
  80242e:	83 c4 10             	add    $0x10,%esp
  802431:	85 d2                	test   %edx,%edx
  802433:	78 18                	js     80244d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802435:	83 ec 0c             	sub    $0xc,%esp
  802438:	ff 75 f4             	pushl  -0xc(%ebp)
  80243b:	e8 5f ea ff ff       	call   800e9f <fd2data>
	return _pipeisclosed(fd, p);
  802440:	89 c2                	mov    %eax,%edx
  802442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802445:	e8 26 fd ff ff       	call   802170 <_pipeisclosed>
  80244a:	83 c4 10             	add    $0x10,%esp
}
  80244d:	c9                   	leave  
  80244e:	c3                   	ret    

0080244f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802452:	b8 00 00 00 00       	mov    $0x0,%eax
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    

00802459 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80245f:	68 dc 2f 80 00       	push   $0x802fdc
  802464:	ff 75 0c             	pushl  0xc(%ebp)
  802467:	e8 88 e3 ff ff       	call   8007f4 <strcpy>
	return 0;
}
  80246c:	b8 00 00 00 00       	mov    $0x0,%eax
  802471:	c9                   	leave  
  802472:	c3                   	ret    

00802473 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	57                   	push   %edi
  802477:	56                   	push   %esi
  802478:	53                   	push   %ebx
  802479:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80247f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802484:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80248a:	eb 2d                	jmp    8024b9 <devcons_write+0x46>
		m = n - tot;
  80248c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80248f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802491:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802494:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802499:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80249c:	83 ec 04             	sub    $0x4,%esp
  80249f:	53                   	push   %ebx
  8024a0:	03 45 0c             	add    0xc(%ebp),%eax
  8024a3:	50                   	push   %eax
  8024a4:	57                   	push   %edi
  8024a5:	e8 dc e4 ff ff       	call   800986 <memmove>
		sys_cputs(buf, m);
  8024aa:	83 c4 08             	add    $0x8,%esp
  8024ad:	53                   	push   %ebx
  8024ae:	57                   	push   %edi
  8024af:	e8 8d e6 ff ff       	call   800b41 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024b4:	01 de                	add    %ebx,%esi
  8024b6:	83 c4 10             	add    $0x10,%esp
  8024b9:	89 f0                	mov    %esi,%eax
  8024bb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024be:	72 cc                	jb     80248c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    

008024c8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8024ce:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8024d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024d7:	75 07                	jne    8024e0 <devcons_read+0x18>
  8024d9:	eb 28                	jmp    802503 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024db:	e8 fe e6 ff ff       	call   800bde <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024e0:	e8 7a e6 ff ff       	call   800b5f <sys_cgetc>
  8024e5:	85 c0                	test   %eax,%eax
  8024e7:	74 f2                	je     8024db <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	78 16                	js     802503 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024ed:	83 f8 04             	cmp    $0x4,%eax
  8024f0:	74 0c                	je     8024fe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f5:	88 02                	mov    %al,(%edx)
	return 1;
  8024f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fc:	eb 05                	jmp    802503 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802503:	c9                   	leave  
  802504:	c3                   	ret    

00802505 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802505:	55                   	push   %ebp
  802506:	89 e5                	mov    %esp,%ebp
  802508:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80250b:	8b 45 08             	mov    0x8(%ebp),%eax
  80250e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802511:	6a 01                	push   $0x1
  802513:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802516:	50                   	push   %eax
  802517:	e8 25 e6 ff ff       	call   800b41 <sys_cputs>
  80251c:	83 c4 10             	add    $0x10,%esp
}
  80251f:	c9                   	leave  
  802520:	c3                   	ret    

00802521 <getchar>:

int
getchar(void)
{
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802527:	6a 01                	push   $0x1
  802529:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80252c:	50                   	push   %eax
  80252d:	6a 00                	push   $0x0
  80252f:	e8 40 ec ff ff       	call   801174 <read>
	if (r < 0)
  802534:	83 c4 10             	add    $0x10,%esp
  802537:	85 c0                	test   %eax,%eax
  802539:	78 0f                	js     80254a <getchar+0x29>
		return r;
	if (r < 1)
  80253b:	85 c0                	test   %eax,%eax
  80253d:	7e 06                	jle    802545 <getchar+0x24>
		return -E_EOF;
	return c;
  80253f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802543:	eb 05                	jmp    80254a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802545:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80254a:	c9                   	leave  
  80254b:	c3                   	ret    

0080254c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802555:	50                   	push   %eax
  802556:	ff 75 08             	pushl  0x8(%ebp)
  802559:	e8 a7 e9 ff ff       	call   800f05 <fd_lookup>
  80255e:	83 c4 10             	add    $0x10,%esp
  802561:	85 c0                	test   %eax,%eax
  802563:	78 11                	js     802576 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802565:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802568:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80256e:	39 10                	cmp    %edx,(%eax)
  802570:	0f 94 c0             	sete   %al
  802573:	0f b6 c0             	movzbl %al,%eax
}
  802576:	c9                   	leave  
  802577:	c3                   	ret    

00802578 <opencons>:

int
opencons(void)
{
  802578:	55                   	push   %ebp
  802579:	89 e5                	mov    %esp,%ebp
  80257b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80257e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802581:	50                   	push   %eax
  802582:	e8 2f e9 ff ff       	call   800eb6 <fd_alloc>
  802587:	83 c4 10             	add    $0x10,%esp
		return r;
  80258a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80258c:	85 c0                	test   %eax,%eax
  80258e:	78 3e                	js     8025ce <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802590:	83 ec 04             	sub    $0x4,%esp
  802593:	68 07 04 00 00       	push   $0x407
  802598:	ff 75 f4             	pushl  -0xc(%ebp)
  80259b:	6a 00                	push   $0x0
  80259d:	e8 5b e6 ff ff       	call   800bfd <sys_page_alloc>
  8025a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8025a5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025a7:	85 c0                	test   %eax,%eax
  8025a9:	78 23                	js     8025ce <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025ab:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8025b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025c0:	83 ec 0c             	sub    $0xc,%esp
  8025c3:	50                   	push   %eax
  8025c4:	e8 c6 e8 ff ff       	call   800e8f <fd2num>
  8025c9:	89 c2                	mov    %eax,%edx
  8025cb:	83 c4 10             	add    $0x10,%esp
}
  8025ce:	89 d0                	mov    %edx,%eax
  8025d0:	c9                   	leave  
  8025d1:	c3                   	ret    

008025d2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	56                   	push   %esi
  8025d6:	53                   	push   %ebx
  8025d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8025da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025e7:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8025ea:	83 ec 0c             	sub    $0xc,%esp
  8025ed:	50                   	push   %eax
  8025ee:	e8 ba e7 ff ff       	call   800dad <sys_ipc_recv>
  8025f3:	83 c4 10             	add    $0x10,%esp
  8025f6:	85 c0                	test   %eax,%eax
  8025f8:	79 16                	jns    802610 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8025fa:	85 f6                	test   %esi,%esi
  8025fc:	74 06                	je     802604 <ipc_recv+0x32>
  8025fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802604:	85 db                	test   %ebx,%ebx
  802606:	74 2c                	je     802634 <ipc_recv+0x62>
  802608:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80260e:	eb 24                	jmp    802634 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802610:	85 f6                	test   %esi,%esi
  802612:	74 0a                	je     80261e <ipc_recv+0x4c>
  802614:	a1 08 50 80 00       	mov    0x805008,%eax
  802619:	8b 40 74             	mov    0x74(%eax),%eax
  80261c:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80261e:	85 db                	test   %ebx,%ebx
  802620:	74 0a                	je     80262c <ipc_recv+0x5a>
  802622:	a1 08 50 80 00       	mov    0x805008,%eax
  802627:	8b 40 78             	mov    0x78(%eax),%eax
  80262a:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80262c:	a1 08 50 80 00       	mov    0x805008,%eax
  802631:	8b 40 70             	mov    0x70(%eax),%eax
}
  802634:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802637:	5b                   	pop    %ebx
  802638:	5e                   	pop    %esi
  802639:	5d                   	pop    %ebp
  80263a:	c3                   	ret    

0080263b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80263b:	55                   	push   %ebp
  80263c:	89 e5                	mov    %esp,%ebp
  80263e:	57                   	push   %edi
  80263f:	56                   	push   %esi
  802640:	53                   	push   %ebx
  802641:	83 ec 0c             	sub    $0xc,%esp
  802644:	8b 7d 08             	mov    0x8(%ebp),%edi
  802647:	8b 75 0c             	mov    0xc(%ebp),%esi
  80264a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80264d:	85 db                	test   %ebx,%ebx
  80264f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802654:	0f 44 d8             	cmove  %eax,%ebx
  802657:	eb 1c                	jmp    802675 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802659:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80265c:	74 12                	je     802670 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80265e:	50                   	push   %eax
  80265f:	68 e8 2f 80 00       	push   $0x802fe8
  802664:	6a 39                	push   $0x39
  802666:	68 03 30 80 00       	push   $0x803003
  80266b:	e8 24 db ff ff       	call   800194 <_panic>
                 sys_yield();
  802670:	e8 69 e5 ff ff       	call   800bde <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802675:	ff 75 14             	pushl  0x14(%ebp)
  802678:	53                   	push   %ebx
  802679:	56                   	push   %esi
  80267a:	57                   	push   %edi
  80267b:	e8 0a e7 ff ff       	call   800d8a <sys_ipc_try_send>
  802680:	83 c4 10             	add    $0x10,%esp
  802683:	85 c0                	test   %eax,%eax
  802685:	78 d2                	js     802659 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268a:	5b                   	pop    %ebx
  80268b:	5e                   	pop    %esi
  80268c:	5f                   	pop    %edi
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    

0080268f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80268f:	55                   	push   %ebp
  802690:	89 e5                	mov    %esp,%ebp
  802692:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802695:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80269a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80269d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026a3:	8b 52 50             	mov    0x50(%edx),%edx
  8026a6:	39 ca                	cmp    %ecx,%edx
  8026a8:	75 0d                	jne    8026b7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8026aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026ad:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8026b2:	8b 40 08             	mov    0x8(%eax),%eax
  8026b5:	eb 0e                	jmp    8026c5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026b7:	83 c0 01             	add    $0x1,%eax
  8026ba:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026bf:	75 d9                	jne    80269a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026c1:	66 b8 00 00          	mov    $0x0,%ax
}
  8026c5:	5d                   	pop    %ebp
  8026c6:	c3                   	ret    

008026c7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026c7:	55                   	push   %ebp
  8026c8:	89 e5                	mov    %esp,%ebp
  8026ca:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026cd:	89 d0                	mov    %edx,%eax
  8026cf:	c1 e8 16             	shr    $0x16,%eax
  8026d2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026d9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026de:	f6 c1 01             	test   $0x1,%cl
  8026e1:	74 1d                	je     802700 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026e3:	c1 ea 0c             	shr    $0xc,%edx
  8026e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026ed:	f6 c2 01             	test   $0x1,%dl
  8026f0:	74 0e                	je     802700 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026f2:	c1 ea 0c             	shr    $0xc,%edx
  8026f5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026fc:	ef 
  8026fd:	0f b7 c0             	movzwl %ax,%eax
}
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	66 90                	xchg   %ax,%ax
  802704:	66 90                	xchg   %ax,%ax
  802706:	66 90                	xchg   %ax,%ax
  802708:	66 90                	xchg   %ax,%ax
  80270a:	66 90                	xchg   %ax,%ax
  80270c:	66 90                	xchg   %ax,%ax
  80270e:	66 90                	xchg   %ax,%ax

00802710 <__udivdi3>:
  802710:	55                   	push   %ebp
  802711:	57                   	push   %edi
  802712:	56                   	push   %esi
  802713:	83 ec 10             	sub    $0x10,%esp
  802716:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80271a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80271e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802722:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802726:	85 d2                	test   %edx,%edx
  802728:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80272c:	89 34 24             	mov    %esi,(%esp)
  80272f:	89 c8                	mov    %ecx,%eax
  802731:	75 35                	jne    802768 <__udivdi3+0x58>
  802733:	39 f1                	cmp    %esi,%ecx
  802735:	0f 87 bd 00 00 00    	ja     8027f8 <__udivdi3+0xe8>
  80273b:	85 c9                	test   %ecx,%ecx
  80273d:	89 cd                	mov    %ecx,%ebp
  80273f:	75 0b                	jne    80274c <__udivdi3+0x3c>
  802741:	b8 01 00 00 00       	mov    $0x1,%eax
  802746:	31 d2                	xor    %edx,%edx
  802748:	f7 f1                	div    %ecx
  80274a:	89 c5                	mov    %eax,%ebp
  80274c:	89 f0                	mov    %esi,%eax
  80274e:	31 d2                	xor    %edx,%edx
  802750:	f7 f5                	div    %ebp
  802752:	89 c6                	mov    %eax,%esi
  802754:	89 f8                	mov    %edi,%eax
  802756:	f7 f5                	div    %ebp
  802758:	89 f2                	mov    %esi,%edx
  80275a:	83 c4 10             	add    $0x10,%esp
  80275d:	5e                   	pop    %esi
  80275e:	5f                   	pop    %edi
  80275f:	5d                   	pop    %ebp
  802760:	c3                   	ret    
  802761:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802768:	3b 14 24             	cmp    (%esp),%edx
  80276b:	77 7b                	ja     8027e8 <__udivdi3+0xd8>
  80276d:	0f bd f2             	bsr    %edx,%esi
  802770:	83 f6 1f             	xor    $0x1f,%esi
  802773:	0f 84 97 00 00 00    	je     802810 <__udivdi3+0x100>
  802779:	bd 20 00 00 00       	mov    $0x20,%ebp
  80277e:	89 d7                	mov    %edx,%edi
  802780:	89 f1                	mov    %esi,%ecx
  802782:	29 f5                	sub    %esi,%ebp
  802784:	d3 e7                	shl    %cl,%edi
  802786:	89 c2                	mov    %eax,%edx
  802788:	89 e9                	mov    %ebp,%ecx
  80278a:	d3 ea                	shr    %cl,%edx
  80278c:	89 f1                	mov    %esi,%ecx
  80278e:	09 fa                	or     %edi,%edx
  802790:	8b 3c 24             	mov    (%esp),%edi
  802793:	d3 e0                	shl    %cl,%eax
  802795:	89 54 24 08          	mov    %edx,0x8(%esp)
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80279f:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027a3:	89 fa                	mov    %edi,%edx
  8027a5:	d3 ea                	shr    %cl,%edx
  8027a7:	89 f1                	mov    %esi,%ecx
  8027a9:	d3 e7                	shl    %cl,%edi
  8027ab:	89 e9                	mov    %ebp,%ecx
  8027ad:	d3 e8                	shr    %cl,%eax
  8027af:	09 c7                	or     %eax,%edi
  8027b1:	89 f8                	mov    %edi,%eax
  8027b3:	f7 74 24 08          	divl   0x8(%esp)
  8027b7:	89 d5                	mov    %edx,%ebp
  8027b9:	89 c7                	mov    %eax,%edi
  8027bb:	f7 64 24 0c          	mull   0xc(%esp)
  8027bf:	39 d5                	cmp    %edx,%ebp
  8027c1:	89 14 24             	mov    %edx,(%esp)
  8027c4:	72 11                	jb     8027d7 <__udivdi3+0xc7>
  8027c6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027ca:	89 f1                	mov    %esi,%ecx
  8027cc:	d3 e2                	shl    %cl,%edx
  8027ce:	39 c2                	cmp    %eax,%edx
  8027d0:	73 5e                	jae    802830 <__udivdi3+0x120>
  8027d2:	3b 2c 24             	cmp    (%esp),%ebp
  8027d5:	75 59                	jne    802830 <__udivdi3+0x120>
  8027d7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8027da:	31 f6                	xor    %esi,%esi
  8027dc:	89 f2                	mov    %esi,%edx
  8027de:	83 c4 10             	add    $0x10,%esp
  8027e1:	5e                   	pop    %esi
  8027e2:	5f                   	pop    %edi
  8027e3:	5d                   	pop    %ebp
  8027e4:	c3                   	ret    
  8027e5:	8d 76 00             	lea    0x0(%esi),%esi
  8027e8:	31 f6                	xor    %esi,%esi
  8027ea:	31 c0                	xor    %eax,%eax
  8027ec:	89 f2                	mov    %esi,%edx
  8027ee:	83 c4 10             	add    $0x10,%esp
  8027f1:	5e                   	pop    %esi
  8027f2:	5f                   	pop    %edi
  8027f3:	5d                   	pop    %ebp
  8027f4:	c3                   	ret    
  8027f5:	8d 76 00             	lea    0x0(%esi),%esi
  8027f8:	89 f2                	mov    %esi,%edx
  8027fa:	31 f6                	xor    %esi,%esi
  8027fc:	89 f8                	mov    %edi,%eax
  8027fe:	f7 f1                	div    %ecx
  802800:	89 f2                	mov    %esi,%edx
  802802:	83 c4 10             	add    $0x10,%esp
  802805:	5e                   	pop    %esi
  802806:	5f                   	pop    %edi
  802807:	5d                   	pop    %ebp
  802808:	c3                   	ret    
  802809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802810:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802814:	76 0b                	jbe    802821 <__udivdi3+0x111>
  802816:	31 c0                	xor    %eax,%eax
  802818:	3b 14 24             	cmp    (%esp),%edx
  80281b:	0f 83 37 ff ff ff    	jae    802758 <__udivdi3+0x48>
  802821:	b8 01 00 00 00       	mov    $0x1,%eax
  802826:	e9 2d ff ff ff       	jmp    802758 <__udivdi3+0x48>
  80282b:	90                   	nop
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	89 f8                	mov    %edi,%eax
  802832:	31 f6                	xor    %esi,%esi
  802834:	e9 1f ff ff ff       	jmp    802758 <__udivdi3+0x48>
  802839:	66 90                	xchg   %ax,%ax
  80283b:	66 90                	xchg   %ax,%ax
  80283d:	66 90                	xchg   %ax,%ax
  80283f:	90                   	nop

00802840 <__umoddi3>:
  802840:	55                   	push   %ebp
  802841:	57                   	push   %edi
  802842:	56                   	push   %esi
  802843:	83 ec 20             	sub    $0x20,%esp
  802846:	8b 44 24 34          	mov    0x34(%esp),%eax
  80284a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80284e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802852:	89 c6                	mov    %eax,%esi
  802854:	89 44 24 10          	mov    %eax,0x10(%esp)
  802858:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80285c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802860:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802864:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802868:	89 74 24 18          	mov    %esi,0x18(%esp)
  80286c:	85 c0                	test   %eax,%eax
  80286e:	89 c2                	mov    %eax,%edx
  802870:	75 1e                	jne    802890 <__umoddi3+0x50>
  802872:	39 f7                	cmp    %esi,%edi
  802874:	76 52                	jbe    8028c8 <__umoddi3+0x88>
  802876:	89 c8                	mov    %ecx,%eax
  802878:	89 f2                	mov    %esi,%edx
  80287a:	f7 f7                	div    %edi
  80287c:	89 d0                	mov    %edx,%eax
  80287e:	31 d2                	xor    %edx,%edx
  802880:	83 c4 20             	add    $0x20,%esp
  802883:	5e                   	pop    %esi
  802884:	5f                   	pop    %edi
  802885:	5d                   	pop    %ebp
  802886:	c3                   	ret    
  802887:	89 f6                	mov    %esi,%esi
  802889:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802890:	39 f0                	cmp    %esi,%eax
  802892:	77 5c                	ja     8028f0 <__umoddi3+0xb0>
  802894:	0f bd e8             	bsr    %eax,%ebp
  802897:	83 f5 1f             	xor    $0x1f,%ebp
  80289a:	75 64                	jne    802900 <__umoddi3+0xc0>
  80289c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8028a0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8028a4:	0f 86 f6 00 00 00    	jbe    8029a0 <__umoddi3+0x160>
  8028aa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8028ae:	0f 82 ec 00 00 00    	jb     8029a0 <__umoddi3+0x160>
  8028b4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028b8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8028bc:	83 c4 20             	add    $0x20,%esp
  8028bf:	5e                   	pop    %esi
  8028c0:	5f                   	pop    %edi
  8028c1:	5d                   	pop    %ebp
  8028c2:	c3                   	ret    
  8028c3:	90                   	nop
  8028c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028c8:	85 ff                	test   %edi,%edi
  8028ca:	89 fd                	mov    %edi,%ebp
  8028cc:	75 0b                	jne    8028d9 <__umoddi3+0x99>
  8028ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8028d3:	31 d2                	xor    %edx,%edx
  8028d5:	f7 f7                	div    %edi
  8028d7:	89 c5                	mov    %eax,%ebp
  8028d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8028dd:	31 d2                	xor    %edx,%edx
  8028df:	f7 f5                	div    %ebp
  8028e1:	89 c8                	mov    %ecx,%eax
  8028e3:	f7 f5                	div    %ebp
  8028e5:	eb 95                	jmp    80287c <__umoddi3+0x3c>
  8028e7:	89 f6                	mov    %esi,%esi
  8028e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8028f0:	89 c8                	mov    %ecx,%eax
  8028f2:	89 f2                	mov    %esi,%edx
  8028f4:	83 c4 20             	add    $0x20,%esp
  8028f7:	5e                   	pop    %esi
  8028f8:	5f                   	pop    %edi
  8028f9:	5d                   	pop    %ebp
  8028fa:	c3                   	ret    
  8028fb:	90                   	nop
  8028fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802900:	b8 20 00 00 00       	mov    $0x20,%eax
  802905:	89 e9                	mov    %ebp,%ecx
  802907:	29 e8                	sub    %ebp,%eax
  802909:	d3 e2                	shl    %cl,%edx
  80290b:	89 c7                	mov    %eax,%edi
  80290d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802911:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802915:	89 f9                	mov    %edi,%ecx
  802917:	d3 e8                	shr    %cl,%eax
  802919:	89 c1                	mov    %eax,%ecx
  80291b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80291f:	09 d1                	or     %edx,%ecx
  802921:	89 fa                	mov    %edi,%edx
  802923:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802927:	89 e9                	mov    %ebp,%ecx
  802929:	d3 e0                	shl    %cl,%eax
  80292b:	89 f9                	mov    %edi,%ecx
  80292d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802931:	89 f0                	mov    %esi,%eax
  802933:	d3 e8                	shr    %cl,%eax
  802935:	89 e9                	mov    %ebp,%ecx
  802937:	89 c7                	mov    %eax,%edi
  802939:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80293d:	d3 e6                	shl    %cl,%esi
  80293f:	89 d1                	mov    %edx,%ecx
  802941:	89 fa                	mov    %edi,%edx
  802943:	d3 e8                	shr    %cl,%eax
  802945:	89 e9                	mov    %ebp,%ecx
  802947:	09 f0                	or     %esi,%eax
  802949:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80294d:	f7 74 24 10          	divl   0x10(%esp)
  802951:	d3 e6                	shl    %cl,%esi
  802953:	89 d1                	mov    %edx,%ecx
  802955:	f7 64 24 0c          	mull   0xc(%esp)
  802959:	39 d1                	cmp    %edx,%ecx
  80295b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80295f:	89 d7                	mov    %edx,%edi
  802961:	89 c6                	mov    %eax,%esi
  802963:	72 0a                	jb     80296f <__umoddi3+0x12f>
  802965:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802969:	73 10                	jae    80297b <__umoddi3+0x13b>
  80296b:	39 d1                	cmp    %edx,%ecx
  80296d:	75 0c                	jne    80297b <__umoddi3+0x13b>
  80296f:	89 d7                	mov    %edx,%edi
  802971:	89 c6                	mov    %eax,%esi
  802973:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802977:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80297b:	89 ca                	mov    %ecx,%edx
  80297d:	89 e9                	mov    %ebp,%ecx
  80297f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802983:	29 f0                	sub    %esi,%eax
  802985:	19 fa                	sbb    %edi,%edx
  802987:	d3 e8                	shr    %cl,%eax
  802989:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80298e:	89 d7                	mov    %edx,%edi
  802990:	d3 e7                	shl    %cl,%edi
  802992:	89 e9                	mov    %ebp,%ecx
  802994:	09 f8                	or     %edi,%eax
  802996:	d3 ea                	shr    %cl,%edx
  802998:	83 c4 20             	add    $0x20,%esp
  80299b:	5e                   	pop    %esi
  80299c:	5f                   	pop    %edi
  80299d:	5d                   	pop    %ebp
  80299e:	c3                   	ret    
  80299f:	90                   	nop
  8029a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029a4:	29 f9                	sub    %edi,%ecx
  8029a6:	19 c6                	sbb    %eax,%esi
  8029a8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8029ac:	89 74 24 18          	mov    %esi,0x18(%esp)
  8029b0:	e9 ff fe ff ff       	jmp    8028b4 <__umoddi3+0x74>
