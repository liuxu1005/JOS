
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
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8024c0,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 24 80 00       	push   $0x8024c6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 24 80 00       	push   $0x8024e8
  800068:	e8 0e 15 00 00       	call   80157b <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 24 80 00       	push   $0x8024ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 25 80 00       	push   $0x802504
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 25 80 00       	push   $0x802511
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
  8000b7:	e8 12 10 00 00       	call   8010ce <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 25 80 00       	push   $0x802524
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 b6 0e 00 00       	call   800f8e <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 25 80 00       	push   $0x80254c
  8000f0:	68 55 25 80 00       	push   $0x802555
  8000f5:	68 5f 25 80 00       	push   $0x80255f
  8000fa:	68 5e 25 80 00       	push   $0x80255e
  8000ff:	e8 68 1a 00 00       	call   801b6c <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 25 80 00       	push   $0x802564
  800111:	6a 1a                	push   $0x1a
  800113:	68 04 25 80 00       	push   $0x802504
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 25 80 00       	push   $0x80257b
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
  800151:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800180:	e8 36 0e 00 00       	call   800fbb <close_all>
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
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 18 0a 00 00       	call   800bbf <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 98 25 80 00       	push   $0x802598
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
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
  8002d0:	e8 1b 1f 00 00       	call   8021f0 <__udivdi3>
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
  80030e:	e8 0d 20 00 00       	call   802320 <__umoddi3>
  800313:	83 c4 14             	add    $0x14,%esp
  800316:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
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
  800412:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
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
  8004d6:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	75 18                	jne    8004f9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e1:	50                   	push   %eax
  8004e2:	68 d3 25 80 00       	push   $0x8025d3
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
  8004fa:	68 b1 29 80 00       	push   $0x8029b1
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
  800527:	ba cc 25 80 00       	mov    $0x8025cc,%edx
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
  800ba6:	68 df 28 80 00       	push   $0x8028df
  800bab:	6a 23                	push   $0x23
  800bad:	68 fc 28 80 00       	push   $0x8028fc
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
  800c27:	68 df 28 80 00       	push   $0x8028df
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 fc 28 80 00       	push   $0x8028fc
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
  800c69:	68 df 28 80 00       	push   $0x8028df
  800c6e:	6a 23                	push   $0x23
  800c70:	68 fc 28 80 00       	push   $0x8028fc
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
  800cab:	68 df 28 80 00       	push   $0x8028df
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 fc 28 80 00       	push   $0x8028fc
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
  800ced:	68 df 28 80 00       	push   $0x8028df
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 fc 28 80 00       	push   $0x8028fc
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
  800d2f:	68 df 28 80 00       	push   $0x8028df
  800d34:	6a 23                	push   $0x23
  800d36:	68 fc 28 80 00       	push   $0x8028fc
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
  800d71:	68 df 28 80 00       	push   $0x8028df
  800d76:	6a 23                	push   $0x23
  800d78:	68 fc 28 80 00       	push   $0x8028fc
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
  800dd5:	68 df 28 80 00       	push   $0x8028df
  800dda:	6a 23                	push   $0x23
  800ddc:	68 fc 28 80 00       	push   $0x8028fc
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

00800dee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	05 00 00 00 30       	add    $0x30000000,%eax
  800df9:	c1 e8 0c             	shr    $0xc,%eax
}
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e20:	89 c2                	mov    %eax,%edx
  800e22:	c1 ea 16             	shr    $0x16,%edx
  800e25:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2c:	f6 c2 01             	test   $0x1,%dl
  800e2f:	74 11                	je     800e42 <fd_alloc+0x2d>
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	c1 ea 0c             	shr    $0xc,%edx
  800e36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3d:	f6 c2 01             	test   $0x1,%dl
  800e40:	75 09                	jne    800e4b <fd_alloc+0x36>
			*fd_store = fd;
  800e42:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
  800e49:	eb 17                	jmp    800e62 <fd_alloc+0x4d>
  800e4b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e50:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e55:	75 c9                	jne    800e20 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e57:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e5d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6a:	83 f8 1f             	cmp    $0x1f,%eax
  800e6d:	77 36                	ja     800ea5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e6f:	c1 e0 0c             	shl    $0xc,%eax
  800e72:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	c1 ea 16             	shr    $0x16,%edx
  800e7c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e83:	f6 c2 01             	test   $0x1,%dl
  800e86:	74 24                	je     800eac <fd_lookup+0x48>
  800e88:	89 c2                	mov    %eax,%edx
  800e8a:	c1 ea 0c             	shr    $0xc,%edx
  800e8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e94:	f6 c2 01             	test   $0x1,%dl
  800e97:	74 1a                	je     800eb3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9c:	89 02                	mov    %eax,(%edx)
	return 0;
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	eb 13                	jmp    800eb8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eaa:	eb 0c                	jmp    800eb8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb1:	eb 05                	jmp    800eb8 <fd_lookup+0x54>
  800eb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 08             	sub    $0x8,%esp
  800ec0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec3:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec8:	eb 13                	jmp    800edd <dev_lookup+0x23>
  800eca:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ecd:	39 08                	cmp    %ecx,(%eax)
  800ecf:	75 0c                	jne    800edd <dev_lookup+0x23>
			*dev = devtab[i];
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  800edb:	eb 2e                	jmp    800f0b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800edd:	8b 02                	mov    (%edx),%eax
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	75 e7                	jne    800eca <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee3:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee8:	8b 40 48             	mov    0x48(%eax),%eax
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	51                   	push   %ecx
  800eef:	50                   	push   %eax
  800ef0:	68 0c 29 80 00       	push   $0x80290c
  800ef5:	e8 73 f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800efa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 10             	sub    $0x10,%esp
  800f15:	8b 75 08             	mov    0x8(%ebp),%esi
  800f18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f25:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f28:	50                   	push   %eax
  800f29:	e8 36 ff ff ff       	call   800e64 <fd_lookup>
  800f2e:	83 c4 08             	add    $0x8,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	78 05                	js     800f3a <fd_close+0x2d>
	    || fd != fd2)
  800f35:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f38:	74 0c                	je     800f46 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f3a:	84 db                	test   %bl,%bl
  800f3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f41:	0f 44 c2             	cmove  %edx,%eax
  800f44:	eb 41                	jmp    800f87 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f46:	83 ec 08             	sub    $0x8,%esp
  800f49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4c:	50                   	push   %eax
  800f4d:	ff 36                	pushl  (%esi)
  800f4f:	e8 66 ff ff ff       	call   800eba <dev_lookup>
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 1a                	js     800f77 <fd_close+0x6a>
		if (dev->dev_close)
  800f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f60:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	74 0b                	je     800f77 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	56                   	push   %esi
  800f70:	ff d0                	call   *%eax
  800f72:	89 c3                	mov    %eax,%ebx
  800f74:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f77:	83 ec 08             	sub    $0x8,%esp
  800f7a:	56                   	push   %esi
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 00 fd ff ff       	call   800c82 <sys_page_unmap>
	return r;
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	89 d8                	mov    %ebx,%eax
}
  800f87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	ff 75 08             	pushl  0x8(%ebp)
  800f9b:	e8 c4 fe ff ff       	call   800e64 <fd_lookup>
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	83 c4 08             	add    $0x8,%esp
  800fa5:	85 d2                	test   %edx,%edx
  800fa7:	78 10                	js     800fb9 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	6a 01                	push   $0x1
  800fae:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb1:	e8 57 ff ff ff       	call   800f0d <fd_close>
  800fb6:	83 c4 10             	add    $0x10,%esp
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <close_all>:

void
close_all(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	53                   	push   %ebx
  800fcb:	e8 be ff ff ff       	call   800f8e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd0:	83 c3 01             	add    $0x1,%ebx
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	83 fb 20             	cmp    $0x20,%ebx
  800fd9:	75 ec                	jne    800fc7 <close_all+0xc>
		close(i);
}
  800fdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	83 ec 2c             	sub    $0x2c,%esp
  800fe9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fef:	50                   	push   %eax
  800ff0:	ff 75 08             	pushl  0x8(%ebp)
  800ff3:	e8 6c fe ff ff       	call   800e64 <fd_lookup>
  800ff8:	89 c2                	mov    %eax,%edx
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	85 d2                	test   %edx,%edx
  800fff:	0f 88 c1 00 00 00    	js     8010c6 <dup+0xe6>
		return r;
	close(newfdnum);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	56                   	push   %esi
  801009:	e8 80 ff ff ff       	call   800f8e <close>

	newfd = INDEX2FD(newfdnum);
  80100e:	89 f3                	mov    %esi,%ebx
  801010:	c1 e3 0c             	shl    $0xc,%ebx
  801013:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801019:	83 c4 04             	add    $0x4,%esp
  80101c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101f:	e8 da fd ff ff       	call   800dfe <fd2data>
  801024:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801026:	89 1c 24             	mov    %ebx,(%esp)
  801029:	e8 d0 fd ff ff       	call   800dfe <fd2data>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801034:	89 f8                	mov    %edi,%eax
  801036:	c1 e8 16             	shr    $0x16,%eax
  801039:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801040:	a8 01                	test   $0x1,%al
  801042:	74 37                	je     80107b <dup+0x9b>
  801044:	89 f8                	mov    %edi,%eax
  801046:	c1 e8 0c             	shr    $0xc,%eax
  801049:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801050:	f6 c2 01             	test   $0x1,%dl
  801053:	74 26                	je     80107b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801055:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	25 07 0e 00 00       	and    $0xe07,%eax
  801064:	50                   	push   %eax
  801065:	ff 75 d4             	pushl  -0x2c(%ebp)
  801068:	6a 00                	push   $0x0
  80106a:	57                   	push   %edi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 ce fb ff ff       	call   800c40 <sys_page_map>
  801072:	89 c7                	mov    %eax,%edi
  801074:	83 c4 20             	add    $0x20,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 2e                	js     8010a9 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107e:	89 d0                	mov    %edx,%eax
  801080:	c1 e8 0c             	shr    $0xc,%eax
  801083:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	25 07 0e 00 00       	and    $0xe07,%eax
  801092:	50                   	push   %eax
  801093:	53                   	push   %ebx
  801094:	6a 00                	push   $0x0
  801096:	52                   	push   %edx
  801097:	6a 00                	push   $0x0
  801099:	e8 a2 fb ff ff       	call   800c40 <sys_page_map>
  80109e:	89 c7                	mov    %eax,%edi
  8010a0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a5:	85 ff                	test   %edi,%edi
  8010a7:	79 1d                	jns    8010c6 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 ce fb ff ff       	call   800c82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 c1 fb ff ff       	call   800c82 <sys_page_unmap>
	return r;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	89 f8                	mov    %edi,%eax
}
  8010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	53                   	push   %ebx
  8010d2:	83 ec 14             	sub    $0x14,%esp
  8010d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	53                   	push   %ebx
  8010dd:	e8 82 fd ff ff       	call   800e64 <fd_lookup>
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 6d                	js     801158 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f5:	ff 30                	pushl  (%eax)
  8010f7:	e8 be fd ff ff       	call   800eba <dev_lookup>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 4c                	js     80114f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801103:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801106:	8b 42 08             	mov    0x8(%edx),%eax
  801109:	83 e0 03             	and    $0x3,%eax
  80110c:	83 f8 01             	cmp    $0x1,%eax
  80110f:	75 21                	jne    801132 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801111:	a1 04 40 80 00       	mov    0x804004,%eax
  801116:	8b 40 48             	mov    0x48(%eax),%eax
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	53                   	push   %ebx
  80111d:	50                   	push   %eax
  80111e:	68 4d 29 80 00       	push   $0x80294d
  801123:	e8 45 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801130:	eb 26                	jmp    801158 <read+0x8a>
	}
	if (!dev->dev_read)
  801132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801135:	8b 40 08             	mov    0x8(%eax),%eax
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 17                	je     801153 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	ff 75 0c             	pushl  0xc(%ebp)
  801145:	52                   	push   %edx
  801146:	ff d0                	call   *%eax
  801148:	89 c2                	mov    %eax,%edx
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	eb 09                	jmp    801158 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114f:	89 c2                	mov    %eax,%edx
  801151:	eb 05                	jmp    801158 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801153:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801158:	89 d0                	mov    %edx,%eax
  80115a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801173:	eb 21                	jmp    801196 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	89 f0                	mov    %esi,%eax
  80117a:	29 d8                	sub    %ebx,%eax
  80117c:	50                   	push   %eax
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	03 45 0c             	add    0xc(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	57                   	push   %edi
  801184:	e8 45 ff ff ff       	call   8010ce <read>
		if (m < 0)
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 0c                	js     80119c <readn+0x3d>
			return m;
		if (m == 0)
  801190:	85 c0                	test   %eax,%eax
  801192:	74 06                	je     80119a <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801194:	01 c3                	add    %eax,%ebx
  801196:	39 f3                	cmp    %esi,%ebx
  801198:	72 db                	jb     801175 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80119a:	89 d8                	mov    %ebx,%eax
}
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 14             	sub    $0x14,%esp
  8011ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	53                   	push   %ebx
  8011b3:	e8 ac fc ff ff       	call   800e64 <fd_lookup>
  8011b8:	83 c4 08             	add    $0x8,%esp
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 68                	js     801229 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	ff 30                	pushl  (%eax)
  8011cd:	e8 e8 fc ff ff       	call   800eba <dev_lookup>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 47                	js     801220 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e0:	75 21                	jne    801203 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	53                   	push   %ebx
  8011ee:	50                   	push   %eax
  8011ef:	68 69 29 80 00       	push   $0x802969
  8011f4:	e8 74 f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801201:	eb 26                	jmp    801229 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801203:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801206:	8b 52 0c             	mov    0xc(%edx),%edx
  801209:	85 d2                	test   %edx,%edx
  80120b:	74 17                	je     801224 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	ff 75 10             	pushl  0x10(%ebp)
  801213:	ff 75 0c             	pushl  0xc(%ebp)
  801216:	50                   	push   %eax
  801217:	ff d2                	call   *%edx
  801219:	89 c2                	mov    %eax,%edx
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	eb 09                	jmp    801229 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801220:	89 c2                	mov    %eax,%edx
  801222:	eb 05                	jmp    801229 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801224:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801229:	89 d0                	mov    %edx,%eax
  80122b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122e:	c9                   	leave  
  80122f:	c3                   	ret    

00801230 <seek>:

int
seek(int fdnum, off_t offset)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801236:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 22 fc ff ff       	call   800e64 <fd_lookup>
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 0e                	js     801257 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801249:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801252:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	53                   	push   %ebx
  80125d:	83 ec 14             	sub    $0x14,%esp
  801260:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801263:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	53                   	push   %ebx
  801268:	e8 f7 fb ff ff       	call   800e64 <fd_lookup>
  80126d:	83 c4 08             	add    $0x8,%esp
  801270:	89 c2                	mov    %eax,%edx
  801272:	85 c0                	test   %eax,%eax
  801274:	78 65                	js     8012db <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801280:	ff 30                	pushl  (%eax)
  801282:	e8 33 fc ff ff       	call   800eba <dev_lookup>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 44                	js     8012d2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801295:	75 21                	jne    8012b8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801297:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80129c:	8b 40 48             	mov    0x48(%eax),%eax
  80129f:	83 ec 04             	sub    $0x4,%esp
  8012a2:	53                   	push   %ebx
  8012a3:	50                   	push   %eax
  8012a4:	68 2c 29 80 00       	push   $0x80292c
  8012a9:	e8 bf ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b6:	eb 23                	jmp    8012db <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	8b 52 18             	mov    0x18(%edx),%edx
  8012be:	85 d2                	test   %edx,%edx
  8012c0:	74 14                	je     8012d6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	ff 75 0c             	pushl  0xc(%ebp)
  8012c8:	50                   	push   %eax
  8012c9:	ff d2                	call   *%edx
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	eb 09                	jmp    8012db <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	eb 05                	jmp    8012db <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012db:	89 d0                	mov    %edx,%eax
  8012dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 14             	sub    $0x14,%esp
  8012e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 6c fb ff ff       	call   800e64 <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 58                	js     801359 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	ff 30                	pushl  (%eax)
  80130d:	e8 a8 fb ff ff       	call   800eba <dev_lookup>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 37                	js     801350 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801319:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801320:	74 32                	je     801354 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801322:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801325:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80132c:	00 00 00 
	stat->st_isdir = 0;
  80132f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801336:	00 00 00 
	stat->st_dev = dev;
  801339:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	53                   	push   %ebx
  801343:	ff 75 f0             	pushl  -0x10(%ebp)
  801346:	ff 50 14             	call   *0x14(%eax)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	eb 09                	jmp    801359 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801350:	89 c2                	mov    %eax,%edx
  801352:	eb 05                	jmp    801359 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801354:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801359:	89 d0                	mov    %edx,%eax
  80135b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	6a 00                	push   $0x0
  80136a:	ff 75 08             	pushl  0x8(%ebp)
  80136d:	e8 09 02 00 00       	call   80157b <open>
  801372:	89 c3                	mov    %eax,%ebx
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	85 db                	test   %ebx,%ebx
  801379:	78 1b                	js     801396 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	ff 75 0c             	pushl  0xc(%ebp)
  801381:	53                   	push   %ebx
  801382:	e8 5b ff ff ff       	call   8012e2 <fstat>
  801387:	89 c6                	mov    %eax,%esi
	close(fd);
  801389:	89 1c 24             	mov    %ebx,(%esp)
  80138c:	e8 fd fb ff ff       	call   800f8e <close>
	return r;
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 f0                	mov    %esi,%eax
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	89 c6                	mov    %eax,%esi
  8013a4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ad:	75 12                	jne    8013c1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013af:	83 ec 0c             	sub    $0xc,%esp
  8013b2:	6a 01                	push   $0x1
  8013b4:	e8 bf 0d 00 00       	call   802178 <ipc_find_env>
  8013b9:	a3 00 40 80 00       	mov    %eax,0x804000
  8013be:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c1:	6a 07                	push   $0x7
  8013c3:	68 00 50 80 00       	push   $0x805000
  8013c8:	56                   	push   %esi
  8013c9:	ff 35 00 40 80 00    	pushl  0x804000
  8013cf:	e8 50 0d 00 00       	call   802124 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d4:	83 c4 0c             	add    $0xc,%esp
  8013d7:	6a 00                	push   $0x0
  8013d9:	53                   	push   %ebx
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 da 0c 00 00       	call   8020bb <ipc_recv>
}
  8013e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801401:	ba 00 00 00 00       	mov    $0x0,%edx
  801406:	b8 02 00 00 00       	mov    $0x2,%eax
  80140b:	e8 8d ff ff ff       	call   80139d <fsipc>
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	8b 40 0c             	mov    0xc(%eax),%eax
  80141e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801423:	ba 00 00 00 00       	mov    $0x0,%edx
  801428:	b8 06 00 00 00       	mov    $0x6,%eax
  80142d:	e8 6b ff ff ff       	call   80139d <fsipc>
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 40 0c             	mov    0xc(%eax),%eax
  801444:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	b8 05 00 00 00       	mov    $0x5,%eax
  801453:	e8 45 ff ff ff       	call   80139d <fsipc>
  801458:	89 c2                	mov    %eax,%edx
  80145a:	85 d2                	test   %edx,%edx
  80145c:	78 2c                	js     80148a <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	68 00 50 80 00       	push   $0x805000
  801466:	53                   	push   %ebx
  801467:	e8 88 f3 ff ff       	call   8007f4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146c:	a1 80 50 80 00       	mov    0x805080,%eax
  801471:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801477:	a1 84 50 80 00       	mov    0x805084,%eax
  80147c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	57                   	push   %edi
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a1:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014a9:	eb 3d                	jmp    8014e8 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014ab:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014b1:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014b6:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	57                   	push   %edi
  8014bd:	53                   	push   %ebx
  8014be:	68 08 50 80 00       	push   $0x805008
  8014c3:	e8 be f4 ff ff       	call   800986 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8014c8:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d8:	e8 c0 fe ff ff       	call   80139d <fsipc>
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 0d                	js     8014f1 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8014e4:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8014e6:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014e8:	85 f6                	test   %esi,%esi
  8014ea:	75 bf                	jne    8014ab <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8014f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	56                   	push   %esi
  8014fd:	53                   	push   %ebx
  8014fe:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801501:	8b 45 08             	mov    0x8(%ebp),%eax
  801504:	8b 40 0c             	mov    0xc(%eax),%eax
  801507:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80150c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	b8 03 00 00 00       	mov    $0x3,%eax
  80151c:	e8 7c fe ff ff       	call   80139d <fsipc>
  801521:	89 c3                	mov    %eax,%ebx
  801523:	85 c0                	test   %eax,%eax
  801525:	78 4b                	js     801572 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801527:	39 c6                	cmp    %eax,%esi
  801529:	73 16                	jae    801541 <devfile_read+0x48>
  80152b:	68 98 29 80 00       	push   $0x802998
  801530:	68 9f 29 80 00       	push   $0x80299f
  801535:	6a 7c                	push   $0x7c
  801537:	68 b4 29 80 00       	push   $0x8029b4
  80153c:	e8 53 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801541:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801546:	7e 16                	jle    80155e <devfile_read+0x65>
  801548:	68 bf 29 80 00       	push   $0x8029bf
  80154d:	68 9f 29 80 00       	push   $0x80299f
  801552:	6a 7d                	push   $0x7d
  801554:	68 b4 29 80 00       	push   $0x8029b4
  801559:	e8 36 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	50                   	push   %eax
  801562:	68 00 50 80 00       	push   $0x805000
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	e8 17 f4 ff ff       	call   800986 <memmove>
	return r;
  80156f:	83 c4 10             	add    $0x10,%esp
}
  801572:	89 d8                	mov    %ebx,%eax
  801574:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801577:	5b                   	pop    %ebx
  801578:	5e                   	pop    %esi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	53                   	push   %ebx
  80157f:	83 ec 20             	sub    $0x20,%esp
  801582:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801585:	53                   	push   %ebx
  801586:	e8 30 f2 ff ff       	call   8007bb <strlen>
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801593:	7f 67                	jg     8015fc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	e8 74 f8 ff ff       	call   800e15 <fd_alloc>
  8015a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 57                	js     801601 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	68 00 50 80 00       	push   $0x805000
  8015b3:	e8 3c f2 ff ff       	call   8007f4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c8:	e8 d0 fd ff ff       	call   80139d <fsipc>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	79 14                	jns    8015ea <open+0x6f>
		fd_close(fd, 0);
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	6a 00                	push   $0x0
  8015db:	ff 75 f4             	pushl  -0xc(%ebp)
  8015de:	e8 2a f9 ff ff       	call   800f0d <fd_close>
		return r;
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	89 da                	mov    %ebx,%edx
  8015e8:	eb 17                	jmp    801601 <open+0x86>
	}

	return fd2num(fd);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 f9 f7 ff ff       	call   800dee <fd2num>
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	eb 05                	jmp    801601 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015fc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801601:	89 d0                	mov    %edx,%eax
  801603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 08 00 00 00       	mov    $0x8,%eax
  801618:	e8 80 fd ff ff       	call   80139d <fsipc>
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	57                   	push   %edi
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80162b:	6a 00                	push   $0x0
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 46 ff ff ff       	call   80157b <open>
  801635:	89 c7                	mov    %eax,%edi
  801637:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	0f 88 97 04 00 00    	js     801adf <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801648:	83 ec 04             	sub    $0x4,%esp
  80164b:	68 00 02 00 00       	push   $0x200
  801650:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	57                   	push   %edi
  801658:	e8 02 fb ff ff       	call   80115f <readn>
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	3d 00 02 00 00       	cmp    $0x200,%eax
  801665:	75 0c                	jne    801673 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801667:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80166e:	45 4c 46 
  801671:	74 33                	je     8016a6 <spawn+0x87>
		close(fd);
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80167c:	e8 0d f9 ff ff       	call   800f8e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801681:	83 c4 0c             	add    $0xc,%esp
  801684:	68 7f 45 4c 46       	push   $0x464c457f
  801689:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80168f:	68 cb 29 80 00       	push   $0x8029cb
  801694:	e8 d4 eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  8016a1:	e9 be 04 00 00       	jmp    801b64 <spawn+0x545>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016a6:	b8 07 00 00 00       	mov    $0x7,%eax
  8016ab:	cd 30                	int    $0x30
  8016ad:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016b3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	0f 88 26 04 00 00    	js     801ae7 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016c1:	89 c6                	mov    %eax,%esi
  8016c3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016c9:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016cc:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016d2:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016d8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016df:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016e5:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016f0:	be 00 00 00 00       	mov    $0x0,%esi
  8016f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016f8:	eb 13                	jmp    80170d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	50                   	push   %eax
  8016fe:	e8 b8 f0 ff ff       	call   8007bb <strlen>
  801703:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801707:	83 c3 01             	add    $0x1,%ebx
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801714:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801717:	85 c0                	test   %eax,%eax
  801719:	75 df                	jne    8016fa <spawn+0xdb>
  80171b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801721:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801727:	bf 00 10 40 00       	mov    $0x401000,%edi
  80172c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80172e:	89 fa                	mov    %edi,%edx
  801730:	83 e2 fc             	and    $0xfffffffc,%edx
  801733:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80173a:	29 c2                	sub    %eax,%edx
  80173c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801742:	8d 42 f8             	lea    -0x8(%edx),%eax
  801745:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80174a:	0f 86 a7 03 00 00    	jbe    801af7 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	6a 07                	push   $0x7
  801755:	68 00 00 40 00       	push   $0x400000
  80175a:	6a 00                	push   $0x0
  80175c:	e8 9c f4 ff ff       	call   800bfd <sys_page_alloc>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	0f 88 f8 03 00 00    	js     801b64 <spawn+0x545>
  80176c:	be 00 00 00 00       	mov    $0x0,%esi
  801771:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80177a:	eb 30                	jmp    8017ac <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80177c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801782:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801788:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801791:	57                   	push   %edi
  801792:	e8 5d f0 ff ff       	call   8007f4 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801797:	83 c4 04             	add    $0x4,%esp
  80179a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80179d:	e8 19 f0 ff ff       	call   8007bb <strlen>
  8017a2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017a6:	83 c6 01             	add    $0x1,%esi
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017b2:	7f c8                	jg     80177c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017b4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017ba:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017c0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017c7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017cd:	74 19                	je     8017e8 <spawn+0x1c9>
  8017cf:	68 58 2a 80 00       	push   $0x802a58
  8017d4:	68 9f 29 80 00       	push   $0x80299f
  8017d9:	68 f1 00 00 00       	push   $0xf1
  8017de:	68 e5 29 80 00       	push   $0x8029e5
  8017e3:	e8 ac e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017e8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8017ee:	89 f8                	mov    %edi,%eax
  8017f0:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017f5:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017f8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017fe:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801801:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801807:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	6a 07                	push   $0x7
  801812:	68 00 d0 bf ee       	push   $0xeebfd000
  801817:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80181d:	68 00 00 40 00       	push   $0x400000
  801822:	6a 00                	push   $0x0
  801824:	e8 17 f4 ff ff       	call   800c40 <sys_page_map>
  801829:	89 c3                	mov    %eax,%ebx
  80182b:	83 c4 20             	add    $0x20,%esp
  80182e:	85 c0                	test   %eax,%eax
  801830:	0f 88 1a 03 00 00    	js     801b50 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	68 00 00 40 00       	push   $0x400000
  80183e:	6a 00                	push   $0x0
  801840:	e8 3d f4 ff ff       	call   800c82 <sys_page_unmap>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	0f 88 fe 02 00 00    	js     801b50 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801852:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801858:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80185f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801865:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80186c:	00 00 00 
  80186f:	e9 85 01 00 00       	jmp    8019f9 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801874:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80187a:	83 38 01             	cmpl   $0x1,(%eax)
  80187d:	0f 85 68 01 00 00    	jne    8019eb <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801883:	89 c7                	mov    %eax,%edi
  801885:	8b 40 18             	mov    0x18(%eax),%eax
  801888:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80188e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801891:	83 f8 01             	cmp    $0x1,%eax
  801894:	19 c0                	sbb    %eax,%eax
  801896:	83 e0 fe             	and    $0xfffffffe,%eax
  801899:	83 c0 07             	add    $0x7,%eax
  80189c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018a2:	89 f8                	mov    %edi,%eax
  8018a4:	8b 7f 04             	mov    0x4(%edi),%edi
  8018a7:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018ad:	8b 78 10             	mov    0x10(%eax),%edi
  8018b0:	8b 48 14             	mov    0x14(%eax),%ecx
  8018b3:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8018b9:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018bc:	89 f0                	mov    %esi,%eax
  8018be:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018c3:	74 10                	je     8018d5 <spawn+0x2b6>
		va -= i;
  8018c5:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018c7:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  8018cd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018cf:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018da:	e9 fa 00 00 00       	jmp    8019d9 <spawn+0x3ba>
		if (i >= filesz) {
  8018df:	39 fb                	cmp    %edi,%ebx
  8018e1:	72 27                	jb     80190a <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018e3:	83 ec 04             	sub    $0x4,%esp
  8018e6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018ec:	56                   	push   %esi
  8018ed:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018f3:	e8 05 f3 ff ff       	call   800bfd <sys_page_alloc>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	0f 89 ca 00 00 00    	jns    8019cd <spawn+0x3ae>
  801903:	89 c7                	mov    %eax,%edi
  801905:	e9 fe 01 00 00       	jmp    801b08 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80190a:	83 ec 04             	sub    $0x4,%esp
  80190d:	6a 07                	push   $0x7
  80190f:	68 00 00 40 00       	push   $0x400000
  801914:	6a 00                	push   $0x0
  801916:	e8 e2 f2 ff ff       	call   800bfd <sys_page_alloc>
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	85 c0                	test   %eax,%eax
  801920:	0f 88 d8 01 00 00    	js     801afe <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80192f:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801935:	50                   	push   %eax
  801936:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80193c:	e8 ef f8 ff ff       	call   801230 <seek>
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	0f 88 b6 01 00 00    	js     801b02 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	89 fa                	mov    %edi,%edx
  801951:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801957:	89 d0                	mov    %edx,%eax
  801959:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80195f:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801964:	0f 47 c1             	cmova  %ecx,%eax
  801967:	50                   	push   %eax
  801968:	68 00 00 40 00       	push   $0x400000
  80196d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801973:	e8 e7 f7 ff ff       	call   80115f <readn>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	0f 88 83 01 00 00    	js     801b06 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80198c:	56                   	push   %esi
  80198d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801993:	68 00 00 40 00       	push   $0x400000
  801998:	6a 00                	push   $0x0
  80199a:	e8 a1 f2 ff ff       	call   800c40 <sys_page_map>
  80199f:	83 c4 20             	add    $0x20,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	79 15                	jns    8019bb <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  8019a6:	50                   	push   %eax
  8019a7:	68 f1 29 80 00       	push   $0x8029f1
  8019ac:	68 24 01 00 00       	push   $0x124
  8019b1:	68 e5 29 80 00       	push   $0x8029e5
  8019b6:	e8 d9 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	68 00 00 40 00       	push   $0x400000
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 b8 f2 ff ff       	call   800c82 <sys_page_unmap>
  8019ca:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019d3:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019d9:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019df:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8019e5:	0f 82 f4 fe ff ff    	jb     8018df <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019eb:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019f2:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019f9:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a00:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a06:	0f 8c 68 fe ff ff    	jl     801874 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a15:	e8 74 f5 ff ff       	call   800f8e <close>
  801a1a:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801a1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a22:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801a28:	89 d8                	mov    %ebx,%eax
  801a2a:	c1 e8 16             	shr    $0x16,%eax
  801a2d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a34:	a8 01                	test   $0x1,%al
  801a36:	74 53                	je     801a8b <spawn+0x46c>
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	c1 e8 0c             	shr    $0xc,%eax
  801a3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a44:	f6 c2 01             	test   $0x1,%dl
  801a47:	74 42                	je     801a8b <spawn+0x46c>
  801a49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a50:	f6 c6 04             	test   $0x4,%dh
  801a53:	74 36                	je     801a8b <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801a55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	25 07 0e 00 00       	and    $0xe07,%eax
  801a64:	50                   	push   %eax
  801a65:	53                   	push   %ebx
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 d1 f1 ff ff       	call   800c40 <sys_page_map>
                        if (r < 0) return r;
  801a6f:	83 c4 20             	add    $0x20,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	79 15                	jns    801a8b <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801a76:	50                   	push   %eax
  801a77:	68 0e 2a 80 00       	push   $0x802a0e
  801a7c:	68 82 00 00 00       	push   $0x82
  801a81:	68 e5 29 80 00       	push   $0x8029e5
  801a86:	e8 09 e7 ff ff       	call   800194 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801a8b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a91:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a97:	75 8f                	jne    801a28 <spawn+0x409>
  801a99:	e9 8d 00 00 00       	jmp    801b2b <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801a9e:	50                   	push   %eax
  801a9f:	68 24 2a 80 00       	push   $0x802a24
  801aa4:	68 85 00 00 00       	push   $0x85
  801aa9:	68 e5 29 80 00       	push   $0x8029e5
  801aae:	e8 e1 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	6a 02                	push   $0x2
  801ab8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801abe:	e8 01 f2 ff ff       	call   800cc4 <sys_env_set_status>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	79 25                	jns    801aef <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801aca:	50                   	push   %eax
  801acb:	68 3e 2a 80 00       	push   $0x802a3e
  801ad0:	68 88 00 00 00       	push   $0x88
  801ad5:	68 e5 29 80 00       	push   $0x8029e5
  801ada:	e8 b5 e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801adf:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ae5:	eb 7d                	jmp    801b64 <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801ae7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801aed:	eb 75                	jmp    801b64 <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801aef:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801af5:	eb 6d                	jmp    801b64 <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801af7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801afc:	eb 66                	jmp    801b64 <spawn+0x545>
  801afe:	89 c7                	mov    %eax,%edi
  801b00:	eb 06                	jmp    801b08 <spawn+0x4e9>
  801b02:	89 c7                	mov    %eax,%edi
  801b04:	eb 02                	jmp    801b08 <spawn+0x4e9>
  801b06:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b11:	e8 68 f0 ff ff       	call   800b7e <sys_env_destroy>
	close(fd);
  801b16:	83 c4 04             	add    $0x4,%esp
  801b19:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b1f:	e8 6a f4 ff ff       	call   800f8e <close>
	return r;
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	89 f8                	mov    %edi,%eax
  801b29:	eb 39                	jmp    801b64 <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b34:	50                   	push   %eax
  801b35:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b3b:	e8 c6 f1 ff ff       	call   800d06 <sys_env_set_trapframe>
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	85 c0                	test   %eax,%eax
  801b45:	0f 89 68 ff ff ff    	jns    801ab3 <spawn+0x494>
  801b4b:	e9 4e ff ff ff       	jmp    801a9e <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b50:	83 ec 08             	sub    $0x8,%esp
  801b53:	68 00 00 40 00       	push   $0x400000
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 23 f1 ff ff       	call   800c82 <sys_page_unmap>
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b67:	5b                   	pop    %ebx
  801b68:	5e                   	pop    %esi
  801b69:	5f                   	pop    %edi
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b71:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b79:	eb 03                	jmp    801b7e <spawnl+0x12>
		argc++;
  801b7b:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b7e:	83 c2 04             	add    $0x4,%edx
  801b81:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b85:	75 f4                	jne    801b7b <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b87:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b8e:	83 e2 f0             	and    $0xfffffff0,%edx
  801b91:	29 d4                	sub    %edx,%esp
  801b93:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b97:	c1 ea 02             	shr    $0x2,%edx
  801b9a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ba1:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba6:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bad:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bb4:	00 
  801bb5:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbc:	eb 0a                	jmp    801bc8 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bbe:	83 c0 01             	add    $0x1,%eax
  801bc1:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bc5:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bc8:	39 d0                	cmp    %edx,%eax
  801bca:	75 f2                	jne    801bbe <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	56                   	push   %esi
  801bd0:	ff 75 08             	pushl  0x8(%ebp)
  801bd3:	e8 47 fa ff ff       	call   80161f <spawn>
}
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801be7:	83 ec 0c             	sub    $0xc,%esp
  801bea:	ff 75 08             	pushl  0x8(%ebp)
  801bed:	e8 0c f2 ff ff       	call   800dfe <fd2data>
  801bf2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bf4:	83 c4 08             	add    $0x8,%esp
  801bf7:	68 80 2a 80 00       	push   $0x802a80
  801bfc:	53                   	push   %ebx
  801bfd:	e8 f2 eb ff ff       	call   8007f4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c02:	8b 56 04             	mov    0x4(%esi),%edx
  801c05:	89 d0                	mov    %edx,%eax
  801c07:	2b 06                	sub    (%esi),%eax
  801c09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c0f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c16:	00 00 00 
	stat->st_dev = &devpipe;
  801c19:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c20:	30 80 00 
	return 0;
}
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	53                   	push   %ebx
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c39:	53                   	push   %ebx
  801c3a:	6a 00                	push   $0x0
  801c3c:	e8 41 f0 ff ff       	call   800c82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c41:	89 1c 24             	mov    %ebx,(%esp)
  801c44:	e8 b5 f1 ff ff       	call   800dfe <fd2data>
  801c49:	83 c4 08             	add    $0x8,%esp
  801c4c:	50                   	push   %eax
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 2e f0 ff ff       	call   800c82 <sys_page_unmap>
}
  801c54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	57                   	push   %edi
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 1c             	sub    $0x1c,%esp
  801c62:	89 c6                	mov    %eax,%esi
  801c64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c67:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	56                   	push   %esi
  801c73:	e8 38 05 00 00       	call   8021b0 <pageref>
  801c78:	89 c7                	mov    %eax,%edi
  801c7a:	83 c4 04             	add    $0x4,%esp
  801c7d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c80:	e8 2b 05 00 00       	call   8021b0 <pageref>
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	39 c7                	cmp    %eax,%edi
  801c8a:	0f 94 c2             	sete   %dl
  801c8d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c90:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801c96:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c99:	39 fb                	cmp    %edi,%ebx
  801c9b:	74 19                	je     801cb6 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801c9d:	84 d2                	test   %dl,%dl
  801c9f:	74 c6                	je     801c67 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca1:	8b 51 58             	mov    0x58(%ecx),%edx
  801ca4:	50                   	push   %eax
  801ca5:	52                   	push   %edx
  801ca6:	53                   	push   %ebx
  801ca7:	68 87 2a 80 00       	push   $0x802a87
  801cac:	e8 bc e5 ff ff       	call   80026d <cprintf>
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	eb b1                	jmp    801c67 <_pipeisclosed+0xe>
	}
}
  801cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 28             	sub    $0x28,%esp
  801cc7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cca:	56                   	push   %esi
  801ccb:	e8 2e f1 ff ff       	call   800dfe <fd2data>
  801cd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	bf 00 00 00 00       	mov    $0x0,%edi
  801cda:	eb 4b                	jmp    801d27 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cdc:	89 da                	mov    %ebx,%edx
  801cde:	89 f0                	mov    %esi,%eax
  801ce0:	e8 74 ff ff ff       	call   801c59 <_pipeisclosed>
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	75 48                	jne    801d31 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ce9:	e8 f0 ee ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cee:	8b 43 04             	mov    0x4(%ebx),%eax
  801cf1:	8b 0b                	mov    (%ebx),%ecx
  801cf3:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf6:	39 d0                	cmp    %edx,%eax
  801cf8:	73 e2                	jae    801cdc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d01:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d04:	89 c2                	mov    %eax,%edx
  801d06:	c1 fa 1f             	sar    $0x1f,%edx
  801d09:	89 d1                	mov    %edx,%ecx
  801d0b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d0e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d11:	83 e2 1f             	and    $0x1f,%edx
  801d14:	29 ca                	sub    %ecx,%edx
  801d16:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d1a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d1e:	83 c0 01             	add    $0x1,%eax
  801d21:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d24:	83 c7 01             	add    $0x1,%edi
  801d27:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d2a:	75 c2                	jne    801cee <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2f:	eb 05                	jmp    801d36 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d39:	5b                   	pop    %ebx
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 18             	sub    $0x18,%esp
  801d47:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d4a:	57                   	push   %edi
  801d4b:	e8 ae f0 ff ff       	call   800dfe <fd2data>
  801d50:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d5a:	eb 3d                	jmp    801d99 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d5c:	85 db                	test   %ebx,%ebx
  801d5e:	74 04                	je     801d64 <devpipe_read+0x26>
				return i;
  801d60:	89 d8                	mov    %ebx,%eax
  801d62:	eb 44                	jmp    801da8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d64:	89 f2                	mov    %esi,%edx
  801d66:	89 f8                	mov    %edi,%eax
  801d68:	e8 ec fe ff ff       	call   801c59 <_pipeisclosed>
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	75 32                	jne    801da3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d71:	e8 68 ee ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d76:	8b 06                	mov    (%esi),%eax
  801d78:	3b 46 04             	cmp    0x4(%esi),%eax
  801d7b:	74 df                	je     801d5c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d7d:	99                   	cltd   
  801d7e:	c1 ea 1b             	shr    $0x1b,%edx
  801d81:	01 d0                	add    %edx,%eax
  801d83:	83 e0 1f             	and    $0x1f,%eax
  801d86:	29 d0                	sub    %edx,%eax
  801d88:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d90:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d93:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d96:	83 c3 01             	add    $0x1,%ebx
  801d99:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d9c:	75 d8                	jne    801d76 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801da1:	eb 05                	jmp    801da8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	5f                   	pop    %edi
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	e8 54 f0 ff ff       	call   800e15 <fd_alloc>
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	89 c2                	mov    %eax,%edx
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	0f 88 2c 01 00 00    	js     801efa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	68 07 04 00 00       	push   $0x407
  801dd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 1d ee ff ff       	call   800bfd <sys_page_alloc>
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	89 c2                	mov    %eax,%edx
  801de5:	85 c0                	test   %eax,%eax
  801de7:	0f 88 0d 01 00 00    	js     801efa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ded:	83 ec 0c             	sub    $0xc,%esp
  801df0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801df3:	50                   	push   %eax
  801df4:	e8 1c f0 ff ff       	call   800e15 <fd_alloc>
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	0f 88 e2 00 00 00    	js     801ee8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	68 07 04 00 00       	push   $0x407
  801e0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e11:	6a 00                	push   $0x0
  801e13:	e8 e5 ed ff ff       	call   800bfd <sys_page_alloc>
  801e18:	89 c3                	mov    %eax,%ebx
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	0f 88 c3 00 00 00    	js     801ee8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2b:	e8 ce ef ff ff       	call   800dfe <fd2data>
  801e30:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e32:	83 c4 0c             	add    $0xc,%esp
  801e35:	68 07 04 00 00       	push   $0x407
  801e3a:	50                   	push   %eax
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 bb ed ff ff       	call   800bfd <sys_page_alloc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	0f 88 89 00 00 00    	js     801ed8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4f:	83 ec 0c             	sub    $0xc,%esp
  801e52:	ff 75 f0             	pushl  -0x10(%ebp)
  801e55:	e8 a4 ef ff ff       	call   800dfe <fd2data>
  801e5a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e61:	50                   	push   %eax
  801e62:	6a 00                	push   $0x0
  801e64:	56                   	push   %esi
  801e65:	6a 00                	push   $0x0
  801e67:	e8 d4 ed ff ff       	call   800c40 <sys_page_map>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	83 c4 20             	add    $0x20,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 55                	js     801eca <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e75:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e83:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e93:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e98:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea5:	e8 44 ef ff ff       	call   800dee <fd2num>
  801eaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ead:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eaf:	83 c4 04             	add    $0x4,%esp
  801eb2:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb5:	e8 34 ef ff ff       	call   800dee <fd2num>
  801eba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ebd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec8:	eb 30                	jmp    801efa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	56                   	push   %esi
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 ad ed ff ff       	call   800c82 <sys_page_unmap>
  801ed5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ed8:	83 ec 08             	sub    $0x8,%esp
  801edb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 9d ed ff ff       	call   800c82 <sys_page_unmap>
  801ee5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ee8:	83 ec 08             	sub    $0x8,%esp
  801eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801eee:	6a 00                	push   $0x0
  801ef0:	e8 8d ed ff ff       	call   800c82 <sys_page_unmap>
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801efa:	89 d0                	mov    %edx,%eax
  801efc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0c:	50                   	push   %eax
  801f0d:	ff 75 08             	pushl  0x8(%ebp)
  801f10:	e8 4f ef ff ff       	call   800e64 <fd_lookup>
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 d2                	test   %edx,%edx
  801f1c:	78 18                	js     801f36 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f1e:	83 ec 0c             	sub    $0xc,%esp
  801f21:	ff 75 f4             	pushl  -0xc(%ebp)
  801f24:	e8 d5 ee ff ff       	call   800dfe <fd2data>
	return _pipeisclosed(fd, p);
  801f29:	89 c2                	mov    %eax,%edx
  801f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2e:	e8 26 fd ff ff       	call   801c59 <_pipeisclosed>
  801f33:	83 c4 10             	add    $0x10,%esp
}
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f48:	68 9f 2a 80 00       	push   $0x802a9f
  801f4d:	ff 75 0c             	pushl  0xc(%ebp)
  801f50:	e8 9f e8 ff ff       	call   8007f4 <strcpy>
	return 0;
}
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    

00801f5c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	57                   	push   %edi
  801f60:	56                   	push   %esi
  801f61:	53                   	push   %ebx
  801f62:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f68:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f6d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f73:	eb 2d                	jmp    801fa2 <devcons_write+0x46>
		m = n - tot;
  801f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f78:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f7a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f7d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f82:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f85:	83 ec 04             	sub    $0x4,%esp
  801f88:	53                   	push   %ebx
  801f89:	03 45 0c             	add    0xc(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	57                   	push   %edi
  801f8e:	e8 f3 e9 ff ff       	call   800986 <memmove>
		sys_cputs(buf, m);
  801f93:	83 c4 08             	add    $0x8,%esp
  801f96:	53                   	push   %ebx
  801f97:	57                   	push   %edi
  801f98:	e8 a4 eb ff ff       	call   800b41 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f9d:	01 de                	add    %ebx,%esi
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	89 f0                	mov    %esi,%eax
  801fa4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fa7:	72 cc                	jb     801f75 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5e                   	pop    %esi
  801fae:	5f                   	pop    %edi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801fbc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc0:	75 07                	jne    801fc9 <devcons_read+0x18>
  801fc2:	eb 28                	jmp    801fec <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fc4:	e8 15 ec ff ff       	call   800bde <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fc9:	e8 91 eb ff ff       	call   800b5f <sys_cgetc>
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	74 f2                	je     801fc4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 16                	js     801fec <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fd6:	83 f8 04             	cmp    $0x4,%eax
  801fd9:	74 0c                	je     801fe7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fde:	88 02                	mov    %al,(%edx)
	return 1;
  801fe0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe5:	eb 05                	jmp    801fec <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fe7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ffa:	6a 01                	push   $0x1
  801ffc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	e8 3c eb ff ff       	call   800b41 <sys_cputs>
  802005:	83 c4 10             	add    $0x10,%esp
}
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <getchar>:

int
getchar(void)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802010:	6a 01                	push   $0x1
  802012:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802015:	50                   	push   %eax
  802016:	6a 00                	push   $0x0
  802018:	e8 b1 f0 ff ff       	call   8010ce <read>
	if (r < 0)
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	85 c0                	test   %eax,%eax
  802022:	78 0f                	js     802033 <getchar+0x29>
		return r;
	if (r < 1)
  802024:	85 c0                	test   %eax,%eax
  802026:	7e 06                	jle    80202e <getchar+0x24>
		return -E_EOF;
	return c;
  802028:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80202c:	eb 05                	jmp    802033 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80202e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203e:	50                   	push   %eax
  80203f:	ff 75 08             	pushl  0x8(%ebp)
  802042:	e8 1d ee ff ff       	call   800e64 <fd_lookup>
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	78 11                	js     80205f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80204e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802051:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802057:	39 10                	cmp    %edx,(%eax)
  802059:	0f 94 c0             	sete   %al
  80205c:	0f b6 c0             	movzbl %al,%eax
}
  80205f:	c9                   	leave  
  802060:	c3                   	ret    

00802061 <opencons>:

int
opencons(void)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	e8 a5 ed ff ff       	call   800e15 <fd_alloc>
  802070:	83 c4 10             	add    $0x10,%esp
		return r;
  802073:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802075:	85 c0                	test   %eax,%eax
  802077:	78 3e                	js     8020b7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802079:	83 ec 04             	sub    $0x4,%esp
  80207c:	68 07 04 00 00       	push   $0x407
  802081:	ff 75 f4             	pushl  -0xc(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 72 eb ff ff       	call   800bfd <sys_page_alloc>
  80208b:	83 c4 10             	add    $0x10,%esp
		return r;
  80208e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802090:	85 c0                	test   %eax,%eax
  802092:	78 23                	js     8020b7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802094:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	50                   	push   %eax
  8020ad:	e8 3c ed ff ff       	call   800dee <fd2num>
  8020b2:	89 c2                	mov    %eax,%edx
  8020b4:	83 c4 10             	add    $0x10,%esp
}
  8020b7:	89 d0                	mov    %edx,%eax
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	56                   	push   %esi
  8020bf:	53                   	push   %ebx
  8020c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020d0:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	50                   	push   %eax
  8020d7:	e8 d1 ec ff ff       	call   800dad <sys_ipc_recv>
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	79 16                	jns    8020f9 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8020e3:	85 f6                	test   %esi,%esi
  8020e5:	74 06                	je     8020ed <ipc_recv+0x32>
  8020e7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8020ed:	85 db                	test   %ebx,%ebx
  8020ef:	74 2c                	je     80211d <ipc_recv+0x62>
  8020f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020f7:	eb 24                	jmp    80211d <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8020f9:	85 f6                	test   %esi,%esi
  8020fb:	74 0a                	je     802107 <ipc_recv+0x4c>
  8020fd:	a1 04 40 80 00       	mov    0x804004,%eax
  802102:	8b 40 74             	mov    0x74(%eax),%eax
  802105:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802107:	85 db                	test   %ebx,%ebx
  802109:	74 0a                	je     802115 <ipc_recv+0x5a>
  80210b:	a1 04 40 80 00       	mov    0x804004,%eax
  802110:	8b 40 78             	mov    0x78(%eax),%eax
  802113:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802115:	a1 04 40 80 00       	mov    0x804004,%eax
  80211a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80211d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	57                   	push   %edi
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
  80212a:	83 ec 0c             	sub    $0xc,%esp
  80212d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802130:	8b 75 0c             	mov    0xc(%ebp),%esi
  802133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802136:	85 db                	test   %ebx,%ebx
  802138:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80213d:	0f 44 d8             	cmove  %eax,%ebx
  802140:	eb 1c                	jmp    80215e <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802142:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802145:	74 12                	je     802159 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802147:	50                   	push   %eax
  802148:	68 ab 2a 80 00       	push   $0x802aab
  80214d:	6a 39                	push   $0x39
  80214f:	68 c6 2a 80 00       	push   $0x802ac6
  802154:	e8 3b e0 ff ff       	call   800194 <_panic>
                 sys_yield();
  802159:	e8 80 ea ff ff       	call   800bde <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80215e:	ff 75 14             	pushl  0x14(%ebp)
  802161:	53                   	push   %ebx
  802162:	56                   	push   %esi
  802163:	57                   	push   %edi
  802164:	e8 21 ec ff ff       	call   800d8a <sys_ipc_try_send>
  802169:	83 c4 10             	add    $0x10,%esp
  80216c:	85 c0                	test   %eax,%eax
  80216e:	78 d2                	js     802142 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80217e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802183:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802186:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80218c:	8b 52 50             	mov    0x50(%edx),%edx
  80218f:	39 ca                	cmp    %ecx,%edx
  802191:	75 0d                	jne    8021a0 <ipc_find_env+0x28>
			return envs[i].env_id;
  802193:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802196:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80219b:	8b 40 08             	mov    0x8(%eax),%eax
  80219e:	eb 0e                	jmp    8021ae <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021a0:	83 c0 01             	add    $0x1,%eax
  8021a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a8:	75 d9                	jne    802183 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021aa:	66 b8 00 00          	mov    $0x0,%ax
}
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    

008021b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	c1 e8 16             	shr    $0x16,%eax
  8021bb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c7:	f6 c1 01             	test   $0x1,%cl
  8021ca:	74 1d                	je     8021e9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021cc:	c1 ea 0c             	shr    $0xc,%edx
  8021cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d6:	f6 c2 01             	test   $0x1,%dl
  8021d9:	74 0e                	je     8021e9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021db:	c1 ea 0c             	shr    $0xc,%edx
  8021de:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e5:	ef 
  8021e6:	0f b7 c0             	movzwl %ax,%eax
}
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    
  8021eb:	66 90                	xchg   %ax,%ax
  8021ed:	66 90                	xchg   %ax,%ax
  8021ef:	90                   	nop

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	83 ec 10             	sub    $0x10,%esp
  8021f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8021fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8021fe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802202:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802206:	85 d2                	test   %edx,%edx
  802208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80220c:	89 34 24             	mov    %esi,(%esp)
  80220f:	89 c8                	mov    %ecx,%eax
  802211:	75 35                	jne    802248 <__udivdi3+0x58>
  802213:	39 f1                	cmp    %esi,%ecx
  802215:	0f 87 bd 00 00 00    	ja     8022d8 <__udivdi3+0xe8>
  80221b:	85 c9                	test   %ecx,%ecx
  80221d:	89 cd                	mov    %ecx,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f1                	div    %ecx
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 f0                	mov    %esi,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c6                	mov    %eax,%esi
  802234:	89 f8                	mov    %edi,%eax
  802236:	f7 f5                	div    %ebp
  802238:	89 f2                	mov    %esi,%edx
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
  802241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802248:	3b 14 24             	cmp    (%esp),%edx
  80224b:	77 7b                	ja     8022c8 <__udivdi3+0xd8>
  80224d:	0f bd f2             	bsr    %edx,%esi
  802250:	83 f6 1f             	xor    $0x1f,%esi
  802253:	0f 84 97 00 00 00    	je     8022f0 <__udivdi3+0x100>
  802259:	bd 20 00 00 00       	mov    $0x20,%ebp
  80225e:	89 d7                	mov    %edx,%edi
  802260:	89 f1                	mov    %esi,%ecx
  802262:	29 f5                	sub    %esi,%ebp
  802264:	d3 e7                	shl    %cl,%edi
  802266:	89 c2                	mov    %eax,%edx
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	d3 ea                	shr    %cl,%edx
  80226c:	89 f1                	mov    %esi,%ecx
  80226e:	09 fa                	or     %edi,%edx
  802270:	8b 3c 24             	mov    (%esp),%edi
  802273:	d3 e0                	shl    %cl,%eax
  802275:	89 54 24 08          	mov    %edx,0x8(%esp)
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802283:	89 fa                	mov    %edi,%edx
  802285:	d3 ea                	shr    %cl,%edx
  802287:	89 f1                	mov    %esi,%ecx
  802289:	d3 e7                	shl    %cl,%edi
  80228b:	89 e9                	mov    %ebp,%ecx
  80228d:	d3 e8                	shr    %cl,%eax
  80228f:	09 c7                	or     %eax,%edi
  802291:	89 f8                	mov    %edi,%eax
  802293:	f7 74 24 08          	divl   0x8(%esp)
  802297:	89 d5                	mov    %edx,%ebp
  802299:	89 c7                	mov    %eax,%edi
  80229b:	f7 64 24 0c          	mull   0xc(%esp)
  80229f:	39 d5                	cmp    %edx,%ebp
  8022a1:	89 14 24             	mov    %edx,(%esp)
  8022a4:	72 11                	jb     8022b7 <__udivdi3+0xc7>
  8022a6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022aa:	89 f1                	mov    %esi,%ecx
  8022ac:	d3 e2                	shl    %cl,%edx
  8022ae:	39 c2                	cmp    %eax,%edx
  8022b0:	73 5e                	jae    802310 <__udivdi3+0x120>
  8022b2:	3b 2c 24             	cmp    (%esp),%ebp
  8022b5:	75 59                	jne    802310 <__udivdi3+0x120>
  8022b7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8022ba:	31 f6                	xor    %esi,%esi
  8022bc:	89 f2                	mov    %esi,%edx
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	31 f6                	xor    %esi,%esi
  8022ca:	31 c0                	xor    %eax,%eax
  8022cc:	89 f2                	mov    %esi,%edx
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	31 f6                	xor    %esi,%esi
  8022dc:	89 f8                	mov    %edi,%eax
  8022de:	f7 f1                	div    %ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	83 c4 10             	add    $0x10,%esp
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022f4:	76 0b                	jbe    802301 <__udivdi3+0x111>
  8022f6:	31 c0                	xor    %eax,%eax
  8022f8:	3b 14 24             	cmp    (%esp),%edx
  8022fb:	0f 83 37 ff ff ff    	jae    802238 <__udivdi3+0x48>
  802301:	b8 01 00 00 00       	mov    $0x1,%eax
  802306:	e9 2d ff ff ff       	jmp    802238 <__udivdi3+0x48>
  80230b:	90                   	nop
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 f8                	mov    %edi,%eax
  802312:	31 f6                	xor    %esi,%esi
  802314:	e9 1f ff ff ff       	jmp    802238 <__udivdi3+0x48>
  802319:	66 90                	xchg   %ax,%ax
  80231b:	66 90                	xchg   %ax,%ax
  80231d:	66 90                	xchg   %ax,%ax
  80231f:	90                   	nop

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	83 ec 20             	sub    $0x20,%esp
  802326:	8b 44 24 34          	mov    0x34(%esp),%eax
  80232a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802332:	89 c6                	mov    %eax,%esi
  802334:	89 44 24 10          	mov    %eax,0x10(%esp)
  802338:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80233c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802340:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802344:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802348:	89 74 24 18          	mov    %esi,0x18(%esp)
  80234c:	85 c0                	test   %eax,%eax
  80234e:	89 c2                	mov    %eax,%edx
  802350:	75 1e                	jne    802370 <__umoddi3+0x50>
  802352:	39 f7                	cmp    %esi,%edi
  802354:	76 52                	jbe    8023a8 <__umoddi3+0x88>
  802356:	89 c8                	mov    %ecx,%eax
  802358:	89 f2                	mov    %esi,%edx
  80235a:	f7 f7                	div    %edi
  80235c:	89 d0                	mov    %edx,%eax
  80235e:	31 d2                	xor    %edx,%edx
  802360:	83 c4 20             	add    $0x20,%esp
  802363:	5e                   	pop    %esi
  802364:	5f                   	pop    %edi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    
  802367:	89 f6                	mov    %esi,%esi
  802369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802370:	39 f0                	cmp    %esi,%eax
  802372:	77 5c                	ja     8023d0 <__umoddi3+0xb0>
  802374:	0f bd e8             	bsr    %eax,%ebp
  802377:	83 f5 1f             	xor    $0x1f,%ebp
  80237a:	75 64                	jne    8023e0 <__umoddi3+0xc0>
  80237c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802380:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802384:	0f 86 f6 00 00 00    	jbe    802480 <__umoddi3+0x160>
  80238a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80238e:	0f 82 ec 00 00 00    	jb     802480 <__umoddi3+0x160>
  802394:	8b 44 24 14          	mov    0x14(%esp),%eax
  802398:	8b 54 24 18          	mov    0x18(%esp),%edx
  80239c:	83 c4 20             	add    $0x20,%esp
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	85 ff                	test   %edi,%edi
  8023aa:	89 fd                	mov    %edi,%ebp
  8023ac:	75 0b                	jne    8023b9 <__umoddi3+0x99>
  8023ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f7                	div    %edi
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	f7 f5                	div    %ebp
  8023c1:	89 c8                	mov    %ecx,%eax
  8023c3:	f7 f5                	div    %ebp
  8023c5:	eb 95                	jmp    80235c <__umoddi3+0x3c>
  8023c7:	89 f6                	mov    %esi,%esi
  8023c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 20             	add    $0x20,%esp
  8023d7:	5e                   	pop    %esi
  8023d8:	5f                   	pop    %edi
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    
  8023db:	90                   	nop
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8023e5:	89 e9                	mov    %ebp,%ecx
  8023e7:	29 e8                	sub    %ebp,%eax
  8023e9:	d3 e2                	shl    %cl,%edx
  8023eb:	89 c7                	mov    %eax,%edi
  8023ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 c1                	mov    %eax,%ecx
  8023fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ff:	09 d1                	or     %edx,%ecx
  802401:	89 fa                	mov    %edi,%edx
  802403:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802407:	89 e9                	mov    %ebp,%ecx
  802409:	d3 e0                	shl    %cl,%eax
  80240b:	89 f9                	mov    %edi,%ecx
  80240d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802411:	89 f0                	mov    %esi,%eax
  802413:	d3 e8                	shr    %cl,%eax
  802415:	89 e9                	mov    %ebp,%ecx
  802417:	89 c7                	mov    %eax,%edi
  802419:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80241d:	d3 e6                	shl    %cl,%esi
  80241f:	89 d1                	mov    %edx,%ecx
  802421:	89 fa                	mov    %edi,%edx
  802423:	d3 e8                	shr    %cl,%eax
  802425:	89 e9                	mov    %ebp,%ecx
  802427:	09 f0                	or     %esi,%eax
  802429:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80242d:	f7 74 24 10          	divl   0x10(%esp)
  802431:	d3 e6                	shl    %cl,%esi
  802433:	89 d1                	mov    %edx,%ecx
  802435:	f7 64 24 0c          	mull   0xc(%esp)
  802439:	39 d1                	cmp    %edx,%ecx
  80243b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80243f:	89 d7                	mov    %edx,%edi
  802441:	89 c6                	mov    %eax,%esi
  802443:	72 0a                	jb     80244f <__umoddi3+0x12f>
  802445:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802449:	73 10                	jae    80245b <__umoddi3+0x13b>
  80244b:	39 d1                	cmp    %edx,%ecx
  80244d:	75 0c                	jne    80245b <__umoddi3+0x13b>
  80244f:	89 d7                	mov    %edx,%edi
  802451:	89 c6                	mov    %eax,%esi
  802453:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802457:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80245b:	89 ca                	mov    %ecx,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802463:	29 f0                	sub    %esi,%eax
  802465:	19 fa                	sbb    %edi,%edx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80246e:	89 d7                	mov    %edx,%edi
  802470:	d3 e7                	shl    %cl,%edi
  802472:	89 e9                	mov    %ebp,%ecx
  802474:	09 f8                	or     %edi,%eax
  802476:	d3 ea                	shr    %cl,%edx
  802478:	83 c4 20             	add    $0x20,%esp
  80247b:	5e                   	pop    %esi
  80247c:	5f                   	pop    %edi
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    
  80247f:	90                   	nop
  802480:	8b 74 24 10          	mov    0x10(%esp),%esi
  802484:	29 f9                	sub    %edi,%ecx
  802486:	19 c6                	sbb    %eax,%esi
  802488:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80248c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802490:	e9 ff fe ff ff       	jmp    802394 <__umoddi3+0x74>
