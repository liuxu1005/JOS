
obj/user/testtime.debug:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003a:	e8 74 0d 00 00       	call   800db3 <sys_time_msec>
	unsigned end = now + sec * 1000;
  80003f:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  800046:	01 c3                	add    %eax,%ebx
	if ((int)now < 0 && (int)now > -MAXERROR)
  800048:	83 f8 f1             	cmp    $0xfffffff1,%eax
  80004b:	7c 1b                	jl     800068 <sleep+0x35>
  80004d:	89 c2                	mov    %eax,%edx
  80004f:	c1 ea 1f             	shr    $0x1f,%edx
  800052:	84 d2                	test   %dl,%dl
  800054:	74 12                	je     800068 <sleep+0x35>
		panic("sys_time_msec: %e", (int)now);
  800056:	50                   	push   %eax
  800057:	68 c0 23 80 00       	push   $0x8023c0
  80005c:	6a 0a                	push   $0xa
  80005e:	68 d2 23 80 00       	push   $0x8023d2
  800063:	e8 f1 00 00 00       	call   800159 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 e2 23 80 00       	push   $0x8023e2
  800074:	6a 0c                	push   $0xc
  800076:	68 d2 23 80 00       	push   $0x8023d2
  80007b:	e8 d9 00 00 00       	call   800159 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  800080:	e8 1e 0b 00 00       	call   800ba3 <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  800085:	e8 29 0d 00 00       	call   800db3 <sys_time_msec>
  80008a:	39 c3                	cmp    %eax,%ebx
  80008c:	77 f2                	ja     800080 <sleep+0x4d>
		sys_yield();
}
  80008e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <umain>:

void
umain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	53                   	push   %ebx
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  80009f:	e8 ff 0a 00 00       	call   800ba3 <sys_yield>
void
umain(int argc, char **argv)
{
	int i;
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000a4:	83 eb 01             	sub    $0x1,%ebx
  8000a7:	75 f6                	jne    80009f <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 ee 23 80 00       	push   $0x8023ee
  8000b1:	e8 7c 01 00 00       	call   800232 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 04 24 80 00       	push   $0x802404
  8000c7:	e8 66 01 00 00       	call   800232 <cprintf>
		sleep(1);
  8000cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000d3:	e8 5b ff ff ff       	call   800033 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000d8:	83 eb 01             	sub    $0x1,%ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000e1:	75 db                	jne    8000be <umain+0x2b>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	68 a4 28 80 00       	push   $0x8028a4
  8000eb:	e8 42 01 00 00       	call   800232 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8000f0:	cc                   	int3   
  8000f1:	83 c4 10             	add    $0x10,%esp
	breakpoint();
}
  8000f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800104:	e8 7b 0a 00 00       	call   800b84 <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 63 ff ff ff       	call   800093 <umain>

	// exit gracefully
	exit();
  800130:	e8 0a 00 00 00       	call   80013f <exit>
  800135:	83 c4 10             	add    $0x10,%esp
}
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800145:	e8 dc 0e 00 00       	call   801026 <close_all>
	sys_env_destroy(0);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	6a 00                	push   $0x0
  80014f:	e8 ef 09 00 00       	call   800b43 <sys_env_destroy>
  800154:	83 c4 10             	add    $0x10,%esp
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800161:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800167:	e8 18 0a 00 00       	call   800b84 <sys_getenvid>
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	56                   	push   %esi
  800176:	50                   	push   %eax
  800177:	68 14 24 80 00       	push   $0x802414
  80017c:	e8 b1 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	53                   	push   %ebx
  800185:	ff 75 10             	pushl  0x10(%ebp)
  800188:	e8 54 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018d:	c7 04 24 a4 28 80 00 	movl   $0x8028a4,(%esp)
  800194:	e8 99 00 00 00       	call   800232 <cprintf>
  800199:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019c:	cc                   	int3   
  80019d:	eb fd                	jmp    80019c <_panic+0x43>

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 13                	mov    (%ebx),%edx
  8001ab:	8d 42 01             	lea    0x1(%edx),%eax
  8001ae:	89 03                	mov    %eax,(%ebx)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 1a                	jne    8001d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	68 ff 00 00 00       	push   $0xff
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 37 09 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9f 01 80 00       	push   $0x80019f
  800210:	e8 4f 01 00 00       	call   800364 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 dc 08 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 d1                	mov    %edx,%ecx
  80025b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800261:	8b 45 10             	mov    0x10(%ebp),%eax
  800264:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800267:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800271:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800274:	72 05                	jb     80027b <printnum+0x35>
  800276:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800279:	77 3e                	ja     8002b9 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027b:	83 ec 0c             	sub    $0xc,%esp
  80027e:	ff 75 18             	pushl  0x18(%ebp)
  800281:	83 eb 01             	sub    $0x1,%ebx
  800284:	53                   	push   %ebx
  800285:	50                   	push   %eax
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 76 1e 00 00       	call   802110 <__udivdi3>
  80029a:	83 c4 18             	add    $0x18,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	89 f2                	mov    %esi,%edx
  8002a1:	89 f8                	mov    %edi,%eax
  8002a3:	e8 9e ff ff ff       	call   800246 <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 13                	jmp    8002c0 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	ff 75 18             	pushl  0x18(%ebp)
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b9:	83 eb 01             	sub    $0x1,%ebx
  8002bc:	85 db                	test   %ebx,%ebx
  8002be:	7f ed                	jg     8002ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	56                   	push   %esi
  8002c4:	83 ec 04             	sub    $0x4,%esp
  8002c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d3:	e8 68 1f 00 00       	call   802240 <__umoddi3>
  8002d8:	83 c4 14             	add    $0x14,%esp
  8002db:	0f be 80 37 24 80 00 	movsbl 0x802437(%eax),%eax
  8002e2:	50                   	push   %eax
  8002e3:	ff d7                	call   *%edi
  8002e5:	83 c4 10             	add    $0x10,%esp
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f3:	83 fa 01             	cmp    $0x1,%edx
  8002f6:	7e 0e                	jle    800306 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	8b 52 04             	mov    0x4(%edx),%edx
  800304:	eb 22                	jmp    800328 <getuint+0x38>
	else if (lflag)
  800306:	85 d2                	test   %edx,%edx
  800308:	74 10                	je     80031a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 02                	mov    (%edx),%eax
  800313:	ba 00 00 00 00       	mov    $0x0,%edx
  800318:	eb 0e                	jmp    800328 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800330:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800334:	8b 10                	mov    (%eax),%edx
  800336:	3b 50 04             	cmp    0x4(%eax),%edx
  800339:	73 0a                	jae    800345 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033e:	89 08                	mov    %ecx,(%eax)
  800340:	8b 45 08             	mov    0x8(%ebp),%eax
  800343:	88 02                	mov    %al,(%edx)
}
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800350:	50                   	push   %eax
  800351:	ff 75 10             	pushl  0x10(%ebp)
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	e8 05 00 00 00       	call   800364 <vprintfmt>
	va_end(ap);
  80035f:	83 c4 10             	add    $0x10,%esp
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 2c             	sub    $0x2c,%esp
  80036d:	8b 75 08             	mov    0x8(%ebp),%esi
  800370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800373:	8b 7d 10             	mov    0x10(%ebp),%edi
  800376:	eb 12                	jmp    80038a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800378:	85 c0                	test   %eax,%eax
  80037a:	0f 84 90 03 00 00    	je     800710 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	53                   	push   %ebx
  800384:	50                   	push   %eax
  800385:	ff d6                	call   *%esi
  800387:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038a:	83 c7 01             	add    $0x1,%edi
  80038d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e2                	jne    800378 <vprintfmt+0x14>
  800396:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003af:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b4:	eb 07                	jmp    8003bd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8d 47 01             	lea    0x1(%edi),%eax
  8003c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c3:	0f b6 07             	movzbl (%edi),%eax
  8003c6:	0f b6 c8             	movzbl %al,%ecx
  8003c9:	83 e8 23             	sub    $0x23,%eax
  8003cc:	3c 55                	cmp    $0x55,%al
  8003ce:	0f 87 21 03 00 00    	ja     8006f5 <vprintfmt+0x391>
  8003d4:	0f b6 c0             	movzbl %al,%eax
  8003d7:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e5:	eb d6                	jmp    8003bd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003fc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ff:	83 fa 09             	cmp    $0x9,%edx
  800402:	77 39                	ja     80043d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800404:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800407:	eb e9                	jmp    8003f2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 48 04             	lea    0x4(%eax),%ecx
  80040f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041a:	eb 27                	jmp    800443 <vprintfmt+0xdf>
  80041c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041f:	85 c0                	test   %eax,%eax
  800421:	b9 00 00 00 00       	mov    $0x0,%ecx
  800426:	0f 49 c8             	cmovns %eax,%ecx
  800429:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042f:	eb 8c                	jmp    8003bd <vprintfmt+0x59>
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800434:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043b:	eb 80                	jmp    8003bd <vprintfmt+0x59>
  80043d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800440:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800443:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800447:	0f 89 70 ff ff ff    	jns    8003bd <vprintfmt+0x59>
				width = precision, precision = -1;
  80044d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800453:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045a:	e9 5e ff ff ff       	jmp    8003bd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800465:	e9 53 ff ff ff       	jmp    8003bd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	53                   	push   %ebx
  800477:	ff 30                	pushl  (%eax)
  800479:	ff d6                	call   *%esi
			break;
  80047b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800481:	e9 04 ff ff ff       	jmp    80038a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8d 50 04             	lea    0x4(%eax),%edx
  80048c:	89 55 14             	mov    %edx,0x14(%ebp)
  80048f:	8b 00                	mov    (%eax),%eax
  800491:	99                   	cltd   
  800492:	31 d0                	xor    %edx,%eax
  800494:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800496:	83 f8 0f             	cmp    $0xf,%eax
  800499:	7f 0b                	jg     8004a6 <vprintfmt+0x142>
  80049b:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8004a2:	85 d2                	test   %edx,%edx
  8004a4:	75 18                	jne    8004be <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a6:	50                   	push   %eax
  8004a7:	68 4f 24 80 00       	push   $0x80244f
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 94 fe ff ff       	call   800347 <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b9:	e9 cc fe ff ff       	jmp    80038a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004be:	52                   	push   %edx
  8004bf:	68 39 28 80 00       	push   $0x802839
  8004c4:	53                   	push   %ebx
  8004c5:	56                   	push   %esi
  8004c6:	e8 7c fe ff ff       	call   800347 <printfmt>
  8004cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d1:	e9 b4 fe ff ff       	jmp    80038a <vprintfmt+0x26>
  8004d6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	ba 48 24 80 00       	mov    $0x802448,%edx
  8004f1:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004f4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f8:	0f 84 92 00 00 00    	je     800590 <vprintfmt+0x22c>
  8004fe:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800502:	0f 8e 96 00 00 00    	jle    80059e <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	51                   	push   %ecx
  80050c:	57                   	push   %edi
  80050d:	e8 86 02 00 00       	call   800798 <strnlen>
  800512:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800521:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800524:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800527:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	eb 0f                	jmp    80053a <vprintfmt+0x1d6>
					putch(padc, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	ff 75 e0             	pushl  -0x20(%ebp)
  800532:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ed                	jg     80052b <vprintfmt+0x1c7>
  80053e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800541:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800544:	85 c9                	test   %ecx,%ecx
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	0f 49 c1             	cmovns %ecx,%eax
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	89 cb                	mov    %ecx,%ebx
  80055b:	eb 4d                	jmp    8005aa <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800561:	74 1b                	je     80057e <vprintfmt+0x21a>
  800563:	0f be c0             	movsbl %al,%eax
  800566:	83 e8 20             	sub    $0x20,%eax
  800569:	83 f8 5e             	cmp    $0x5e,%eax
  80056c:	76 10                	jbe    80057e <vprintfmt+0x21a>
					putch('?', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 3f                	push   $0x3f
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 0d                	jmp    80058b <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	52                   	push   %edx
  800585:	ff 55 08             	call   *0x8(%ebp)
  800588:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	eb 1a                	jmp    8005aa <vprintfmt+0x246>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	eb 0c                	jmp    8005aa <vprintfmt+0x246>
  80059e:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005aa:	83 c7 01             	add    $0x1,%edi
  8005ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b1:	0f be d0             	movsbl %al,%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 23                	je     8005db <vprintfmt+0x277>
  8005b8:	85 f6                	test   %esi,%esi
  8005ba:	78 a1                	js     80055d <vprintfmt+0x1f9>
  8005bc:	83 ee 01             	sub    $0x1,%esi
  8005bf:	79 9c                	jns    80055d <vprintfmt+0x1f9>
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c9:	eb 18                	jmp    8005e3 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 20                	push   $0x20
  8005d1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d3:	83 ef 01             	sub    $0x1,%edi
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	eb 08                	jmp    8005e3 <vprintfmt+0x27f>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	85 ff                	test   %edi,%edi
  8005e5:	7f e4                	jg     8005cb <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	e9 9b fd ff ff       	jmp    80038a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 fa 01             	cmp    $0x1,%edx
  8005f2:	7e 16                	jle    80060a <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 08             	lea    0x8(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 50 04             	mov    0x4(%eax),%edx
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800608:	eb 32                	jmp    80063c <vprintfmt+0x2d8>
	else if (lflag)
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 18                	je     800626 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 c1                	mov    %eax,%ecx
  80061e:	c1 f9 1f             	sar    $0x1f,%ecx
  800621:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800624:	eb 16                	jmp    80063c <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 c1                	mov    %eax,%ecx
  800636:	c1 f9 1f             	sar    $0x1f,%ecx
  800639:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800647:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064b:	79 74                	jns    8006c1 <vprintfmt+0x35d>
				putch('-', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 2d                	push   $0x2d
  800653:	ff d6                	call   *%esi
				num = -(long long) num;
  800655:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800658:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065b:	f7 d8                	neg    %eax
  80065d:	83 d2 00             	adc    $0x0,%edx
  800660:	f7 da                	neg    %edx
  800662:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066a:	eb 55                	jmp    8006c1 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 7c fc ff ff       	call   8002f0 <getuint>
			base = 10;
  800674:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800679:	eb 46                	jmp    8006c1 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 6d fc ff ff       	call   8002f0 <getuint>
                        base = 8;
  800683:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800688:	eb 37                	jmp    8006c1 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 30                	push   $0x30
  800690:	ff d6                	call   *%esi
			putch('x', putdat);
  800692:	83 c4 08             	add    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 78                	push   $0x78
  800698:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006aa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ad:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b2:	eb 0d                	jmp    8006c1 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 34 fc ff ff       	call   8002f0 <getuint>
			base = 16;
  8006bc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c8:	57                   	push   %edi
  8006c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cc:	51                   	push   %ecx
  8006cd:	52                   	push   %edx
  8006ce:	50                   	push   %eax
  8006cf:	89 da                	mov    %ebx,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 6e fb ff ff       	call   800246 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006de:	e9 a7 fc ff ff       	jmp    80038a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	51                   	push   %ecx
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f0:	e9 95 fc ff ff       	jmp    80038a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 03                	jmp    800705 <vprintfmt+0x3a1>
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800709:	75 f7                	jne    800702 <vprintfmt+0x39e>
  80070b:	e9 7a fc ff ff       	jmp    80038a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 26                	je     80075f <vsnprintf+0x47>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 22                	jle    80075f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	ff 75 14             	pushl  0x14(%ebp)
  800740:	ff 75 10             	pushl  0x10(%ebp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	68 2a 03 80 00       	push   $0x80032a
  80074c:	e8 13 fc ff ff       	call   800364 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 05                	jmp    800764 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	ff 75 08             	pushl  0x8(%ebp)
  800779:	e8 9a ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 c2                	cmp    %eax,%edx
  8007ad:	74 08                	je     8007b7 <strnlen+0x1f>
  8007af:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
  8007b5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	83 c1 01             	add    $0x1,%ecx
  8007cb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ef                	jne    8007c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e0:	53                   	push   %ebx
  8007e1:	e8 9a ff ff ff       	call   800780 <strlen>
  8007e6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 c5 ff ff ff       	call   8007b9 <strcpy>
	return dst;
}
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800806:	89 f3                	mov    %esi,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	89 f2                	mov    %esi,%edx
  80080d:	eb 0f                	jmp    80081e <strncpy+0x23>
		*dst++ = *src;
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 39 01             	cmpb   $0x1,(%ecx)
  80081b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	39 da                	cmp    %ebx,%edx
  800820:	75 ed                	jne    80080f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800822:	89 f0                	mov    %esi,%eax
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x35>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
  800842:	eb 09                	jmp    80084d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 09                	je     80085a <strlcpy+0x32>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	75 ec                	jne    800844 <strlcpy+0x1c>
  800858:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strcmp+0x11>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 04                	je     80087f <strcmp+0x1c>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	74 ef                	je     80086e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 c3                	mov    %eax,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strncmp+0x17>
		n--, p++, q++;
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 15                	je     8008b9 <strncmp+0x30>
  8008a4:	0f b6 08             	movzbl (%eax),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	74 04                	je     8008af <strncmp+0x26>
  8008ab:	3a 0a                	cmp    (%edx),%cl
  8008ad:	74 eb                	je     80089a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	eb 05                	jmp    8008be <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 07                	jmp    8008d4 <strchr+0x13>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 0f                	je     8008e0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	0f b6 10             	movzbl (%eax),%edx
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	eb 03                	jmp    8008f1 <strfind+0xf>
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	74 04                	je     8008fc <strfind+0x1a>
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	75 f2                	jne    8008ee <strfind+0xc>
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 36                	je     800944 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800914:	75 28                	jne    80093e <memset+0x40>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	75 23                	jne    80093e <memset+0x40>
		c &= 0xFF;
  80091b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 08             	shl    $0x8,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 18             	shl    $0x18,%esi
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 10             	shl    $0x10,%eax
  80092e:	09 f0                	or     %esi,%eax
  800930:	09 c2                	or     %eax,%edx
  800932:	89 d0                	mov    %edx,%eax
  800934:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800936:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 06                	jmp    800944 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	fc                   	cld    
  800942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800944:	89 f8                	mov    %edi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 35                	jae    800992 <memmove+0x47>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 d0                	cmp    %edx,%eax
  800962:	73 2e                	jae    800992 <memmove+0x47>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800967:	89 d6                	mov    %edx,%esi
  800969:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800971:	75 13                	jne    800986 <memmove+0x3b>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0e                	jne    800986 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800978:	83 ef 04             	sub    $0x4,%edi
  80097b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800981:	fd                   	std    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 09                	jmp    80098f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800986:	83 ef 01             	sub    $0x1,%edi
  800989:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098c:	fd                   	std    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098f:	fc                   	cld    
  800990:	eb 1d                	jmp    8009af <memmove+0x64>
  800992:	89 f2                	mov    %esi,%edx
  800994:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	f6 c2 03             	test   $0x3,%dl
  800999:	75 0f                	jne    8009aa <memmove+0x5f>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	75 0a                	jne    8009aa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	fc                   	cld    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb 05                	jmp    8009af <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	ff 75 08             	pushl  0x8(%ebp)
  8009bf:	e8 87 ff ff ff       	call   80094b <memmove>
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d1:	89 c6                	mov    %eax,%esi
  8009d3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	eb 1a                	jmp    8009f2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d8:	0f b6 08             	movzbl (%eax),%ecx
  8009db:	0f b6 1a             	movzbl (%edx),%ebx
  8009de:	38 d9                	cmp    %bl,%cl
  8009e0:	74 0a                	je     8009ec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e2:	0f b6 c1             	movzbl %cl,%eax
  8009e5:	0f b6 db             	movzbl %bl,%ebx
  8009e8:	29 d8                	sub    %ebx,%eax
  8009ea:	eb 0f                	jmp    8009fb <memcmp+0x35>
		s1++, s2++;
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	39 f0                	cmp    %esi,%eax
  8009f4:	75 e2                	jne    8009d8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0d:	eb 07                	jmp    800a16 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0f:	38 08                	cmp    %cl,(%eax)
  800a11:	74 07                	je     800a1a <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	39 d0                	cmp    %edx,%eax
  800a18:	72 f5                	jb     800a0f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a28:	eb 03                	jmp    800a2d <strtol+0x11>
		s++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	3c 09                	cmp    $0x9,%al
  800a32:	74 f6                	je     800a2a <strtol+0xe>
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f2                	je     800a2a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a38:	3c 2b                	cmp    $0x2b,%al
  800a3a:	75 0a                	jne    800a46 <strtol+0x2a>
		s++;
  800a3c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a44:	eb 10                	jmp    800a56 <strtol+0x3a>
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4b:	3c 2d                	cmp    $0x2d,%al
  800a4d:	75 07                	jne    800a56 <strtol+0x3a>
		s++, neg = 1;
  800a4f:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a52:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	0f 94 c0             	sete   %al
  800a5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a61:	75 19                	jne    800a7c <strtol+0x60>
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 14                	jne    800a7c <strtol+0x60>
  800a68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6c:	0f 85 82 00 00 00    	jne    800af4 <strtol+0xd8>
		s += 2, base = 16;
  800a72:	83 c1 02             	add    $0x2,%ecx
  800a75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7a:	eb 16                	jmp    800a92 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a7c:	84 c0                	test   %al,%al
  800a7e:	74 12                	je     800a92 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a80:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a85:	80 39 30             	cmpb   $0x30,(%ecx)
  800a88:	75 08                	jne    800a92 <strtol+0x76>
		s++, base = 8;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9a:	0f b6 11             	movzbl (%ecx),%edx
  800a9d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 09             	cmp    $0x9,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x93>
			dig = *s - '0';
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 30             	sub    $0x30,%edx
  800aad:	eb 22                	jmp    800ad1 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 57             	sub    $0x57,%edx
  800abf:	eb 10                	jmp    800ad1 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 16                	ja     800ae1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad4:	7d 0f                	jge    800ae5 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800add:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adf:	eb b9                	jmp    800a9a <strtol+0x7e>
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	eb 02                	jmp    800ae7 <strtol+0xcb>
  800ae5:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ae7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aeb:	74 0d                	je     800afa <strtol+0xde>
		*endptr = (char *) s;
  800aed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af0:	89 0e                	mov    %ecx,(%esi)
  800af2:	eb 06                	jmp    800afa <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	84 c0                	test   %al,%al
  800af6:	75 92                	jne    800a8a <strtol+0x6e>
  800af8:	eb 98                	jmp    800a92 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800afa:	f7 da                	neg    %edx
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 45 c2             	cmovne %edx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	b8 03 00 00 00       	mov    $0x3,%eax
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 17                	jle    800b7c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 03                	push   $0x3
  800b6b:	68 5f 27 80 00       	push   $0x80275f
  800b70:	6a 22                	push   $0x22
  800b72:	68 7c 27 80 00       	push   $0x80277c
  800b77:	e8 dd f5 ff ff       	call   800159 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_yield>:

void
sys_yield(void)
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
  800bae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bcb:	be 00 00 00 00       	mov    $0x0,%esi
  800bd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	89 f7                	mov    %esi,%edi
  800be0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 04                	push   $0x4
  800bec:	68 5f 27 80 00       	push   $0x80275f
  800bf1:	6a 22                	push   $0x22
  800bf3:	68 7c 27 80 00       	push   $0x80277c
  800bf8:	e8 5c f5 ff ff       	call   800159 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 05                	push   $0x5
  800c2e:	68 5f 27 80 00       	push   $0x80275f
  800c33:	6a 22                	push   $0x22
  800c35:	68 7c 27 80 00       	push   $0x80277c
  800c3a:	e8 1a f5 ff ff       	call   800159 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 06                	push   $0x6
  800c70:	68 5f 27 80 00       	push   $0x80275f
  800c75:	6a 22                	push   $0x22
  800c77:	68 7c 27 80 00       	push   $0x80277c
  800c7c:	e8 d8 f4 ff ff       	call   800159 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 08                	push   $0x8
  800cb2:	68 5f 27 80 00       	push   $0x80275f
  800cb7:	6a 22                	push   $0x22
  800cb9:	68 7c 27 80 00       	push   $0x80277c
  800cbe:	e8 96 f4 ff ff       	call   800159 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 09                	push   $0x9
  800cf4:	68 5f 27 80 00       	push   $0x80275f
  800cf9:	6a 22                	push   $0x22
  800cfb:	68 7c 27 80 00       	push   $0x80277c
  800d00:	e8 54 f4 ff ff       	call   800159 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 0a                	push   $0xa
  800d36:	68 5f 27 80 00       	push   $0x80275f
  800d3b:	6a 22                	push   $0x22
  800d3d:	68 7c 27 80 00       	push   $0x80277c
  800d42:	e8 12 f4 ff ff       	call   800159 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d55:	be 00 00 00 00       	mov    $0x0,%esi
  800d5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d80:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	89 cb                	mov    %ecx,%ebx
  800d8a:	89 cf                	mov    %ecx,%edi
  800d8c:	89 ce                	mov    %ecx,%esi
  800d8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7e 17                	jle    800dab <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	50                   	push   %eax
  800d98:	6a 0d                	push   $0xd
  800d9a:	68 5f 27 80 00       	push   $0x80275f
  800d9f:	6a 22                	push   $0x22
  800da1:	68 7c 27 80 00       	push   $0x80277c
  800da6:	e8 ae f3 ff ff       	call   800159 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800db9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbe:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc3:	89 d1                	mov    %edx,%ecx
  800dc5:	89 d3                	mov    %edx,%ebx
  800dc7:	89 d7                	mov    %edx,%edi
  800dc9:	89 d6                	mov    %edx,%esi
  800dcb:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ddb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	89 cb                	mov    %ecx,%ebx
  800dea:	89 cf                	mov    %ecx,%edi
  800dec:	89 ce                	mov    %ecx,%esi
  800dee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7e 17                	jle    800e0b <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	50                   	push   %eax
  800df8:	6a 0f                	push   $0xf
  800dfa:	68 5f 27 80 00       	push   $0x80275f
  800dff:	6a 22                	push   $0x22
  800e01:	68 7c 27 80 00       	push   $0x80277c
  800e06:	e8 4e f3 ff ff       	call   800159 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_recv>:

int
sys_recv(void *addr)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e21:	b8 10 00 00 00       	mov    $0x10,%eax
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 cb                	mov    %ecx,%ebx
  800e2b:	89 cf                	mov    %ecx,%edi
  800e2d:	89 ce                	mov    %ecx,%esi
  800e2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 17                	jle    800e4c <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 10                	push   $0x10
  800e3b:	68 5f 27 80 00       	push   $0x80275f
  800e40:	6a 22                	push   $0x22
  800e42:	68 7c 27 80 00       	push   $0x80277c
  800e47:	e8 0d f3 ff ff       	call   800159 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e74:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	c1 ea 16             	shr    $0x16,%edx
  800e8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e92:	f6 c2 01             	test   $0x1,%dl
  800e95:	74 11                	je     800ea8 <fd_alloc+0x2d>
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 0c             	shr    $0xc,%edx
  800e9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea3:	f6 c2 01             	test   $0x1,%dl
  800ea6:	75 09                	jne    800eb1 <fd_alloc+0x36>
			*fd_store = fd;
  800ea8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaf:	eb 17                	jmp    800ec8 <fd_alloc+0x4d>
  800eb1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ebb:	75 c9                	jne    800e86 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ebd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed0:	83 f8 1f             	cmp    $0x1f,%eax
  800ed3:	77 36                	ja     800f0b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed5:	c1 e0 0c             	shl    $0xc,%eax
  800ed8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	c1 ea 16             	shr    $0x16,%edx
  800ee2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	74 24                	je     800f12 <fd_lookup+0x48>
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	c1 ea 0c             	shr    $0xc,%edx
  800ef3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efa:	f6 c2 01             	test   $0x1,%dl
  800efd:	74 1a                	je     800f19 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f02:	89 02                	mov    %eax,(%edx)
	return 0;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
  800f09:	eb 13                	jmp    800f1e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f10:	eb 0c                	jmp    800f1e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f17:	eb 05                	jmp    800f1e <fd_lookup+0x54>
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 08             	sub    $0x8,%esp
  800f26:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f29:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2e:	eb 13                	jmp    800f43 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f30:	39 08                	cmp    %ecx,(%eax)
  800f32:	75 0c                	jne    800f40 <dev_lookup+0x20>
			*dev = devtab[i];
  800f34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f37:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 36                	jmp    800f76 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f40:	83 c2 01             	add    $0x1,%edx
  800f43:	8b 04 95 0c 28 80 00 	mov    0x80280c(,%edx,4),%eax
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	75 e2                	jne    800f30 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f4e:	a1 08 40 80 00       	mov    0x804008,%eax
  800f53:	8b 40 48             	mov    0x48(%eax),%eax
  800f56:	83 ec 04             	sub    $0x4,%esp
  800f59:	51                   	push   %ecx
  800f5a:	50                   	push   %eax
  800f5b:	68 8c 27 80 00       	push   $0x80278c
  800f60:	e8 cd f2 ff ff       	call   800232 <cprintf>
	*dev = 0;
  800f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 10             	sub    $0x10,%esp
  800f80:	8b 75 08             	mov    0x8(%ebp),%esi
  800f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f89:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f8a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f90:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f93:	50                   	push   %eax
  800f94:	e8 31 ff ff ff       	call   800eca <fd_lookup>
  800f99:	83 c4 08             	add    $0x8,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 05                	js     800fa5 <fd_close+0x2d>
	    || fd != fd2)
  800fa0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fa3:	74 0c                	je     800fb1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fa5:	84 db                	test   %bl,%bl
  800fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fac:	0f 44 c2             	cmove  %edx,%eax
  800faf:	eb 41                	jmp    800ff2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 36                	pushl  (%esi)
  800fba:	e8 61 ff ff ff       	call   800f20 <dev_lookup>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 1a                	js     800fe2 <fd_close+0x6a>
		if (dev->dev_close)
  800fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	74 0b                	je     800fe2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	56                   	push   %esi
  800fdb:	ff d0                	call   *%eax
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 5a fc ff ff       	call   800c47 <sys_page_unmap>
	return r;
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	89 d8                	mov    %ebx,%eax
}
  800ff2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 bf fe ff ff       	call   800eca <fd_lookup>
  80100b:	89 c2                	mov    %eax,%edx
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 d2                	test   %edx,%edx
  801012:	78 10                	js     801024 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	6a 01                	push   $0x1
  801019:	ff 75 f4             	pushl  -0xc(%ebp)
  80101c:	e8 57 ff ff ff       	call   800f78 <fd_close>
  801021:	83 c4 10             	add    $0x10,%esp
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <close_all>:

void
close_all(void)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	53                   	push   %ebx
  801036:	e8 be ff ff ff       	call   800ff9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80103b:	83 c3 01             	add    $0x1,%ebx
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	83 fb 20             	cmp    $0x20,%ebx
  801044:	75 ec                	jne    801032 <close_all+0xc>
		close(i);
}
  801046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 2c             	sub    $0x2c,%esp
  801054:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801057:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80105a:	50                   	push   %eax
  80105b:	ff 75 08             	pushl  0x8(%ebp)
  80105e:	e8 67 fe ff ff       	call   800eca <fd_lookup>
  801063:	89 c2                	mov    %eax,%edx
  801065:	83 c4 08             	add    $0x8,%esp
  801068:	85 d2                	test   %edx,%edx
  80106a:	0f 88 c1 00 00 00    	js     801131 <dup+0xe6>
		return r;
	close(newfdnum);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	56                   	push   %esi
  801074:	e8 80 ff ff ff       	call   800ff9 <close>

	newfd = INDEX2FD(newfdnum);
  801079:	89 f3                	mov    %esi,%ebx
  80107b:	c1 e3 0c             	shl    $0xc,%ebx
  80107e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801084:	83 c4 04             	add    $0x4,%esp
  801087:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108a:	e8 d5 fd ff ff       	call   800e64 <fd2data>
  80108f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801091:	89 1c 24             	mov    %ebx,(%esp)
  801094:	e8 cb fd ff ff       	call   800e64 <fd2data>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80109f:	89 f8                	mov    %edi,%eax
  8010a1:	c1 e8 16             	shr    $0x16,%eax
  8010a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ab:	a8 01                	test   $0x1,%al
  8010ad:	74 37                	je     8010e6 <dup+0x9b>
  8010af:	89 f8                	mov    %edi,%eax
  8010b1:	c1 e8 0c             	shr    $0xc,%eax
  8010b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bb:	f6 c2 01             	test   $0x1,%dl
  8010be:	74 26                	je     8010e6 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cf:	50                   	push   %eax
  8010d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d3:	6a 00                	push   $0x0
  8010d5:	57                   	push   %edi
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 28 fb ff ff       	call   800c05 <sys_page_map>
  8010dd:	89 c7                	mov    %eax,%edi
  8010df:	83 c4 20             	add    $0x20,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	78 2e                	js     801114 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010e9:	89 d0                	mov    %edx,%eax
  8010eb:	c1 e8 0c             	shr    $0xc,%eax
  8010ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fd:	50                   	push   %eax
  8010fe:	53                   	push   %ebx
  8010ff:	6a 00                	push   $0x0
  801101:	52                   	push   %edx
  801102:	6a 00                	push   $0x0
  801104:	e8 fc fa ff ff       	call   800c05 <sys_page_map>
  801109:	89 c7                	mov    %eax,%edi
  80110b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80110e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801110:	85 ff                	test   %edi,%edi
  801112:	79 1d                	jns    801131 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801114:	83 ec 08             	sub    $0x8,%esp
  801117:	53                   	push   %ebx
  801118:	6a 00                	push   $0x0
  80111a:	e8 28 fb ff ff       	call   800c47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	ff 75 d4             	pushl  -0x2c(%ebp)
  801125:	6a 00                	push   $0x0
  801127:	e8 1b fb ff ff       	call   800c47 <sys_page_unmap>
	return r;
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	89 f8                	mov    %edi,%eax
}
  801131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801134:	5b                   	pop    %ebx
  801135:	5e                   	pop    %esi
  801136:	5f                   	pop    %edi
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	53                   	push   %ebx
  80113d:	83 ec 14             	sub    $0x14,%esp
  801140:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801143:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801146:	50                   	push   %eax
  801147:	53                   	push   %ebx
  801148:	e8 7d fd ff ff       	call   800eca <fd_lookup>
  80114d:	83 c4 08             	add    $0x8,%esp
  801150:	89 c2                	mov    %eax,%edx
  801152:	85 c0                	test   %eax,%eax
  801154:	78 6d                	js     8011c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115c:	50                   	push   %eax
  80115d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801160:	ff 30                	pushl  (%eax)
  801162:	e8 b9 fd ff ff       	call   800f20 <dev_lookup>
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 4c                	js     8011ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80116e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801171:	8b 42 08             	mov    0x8(%edx),%eax
  801174:	83 e0 03             	and    $0x3,%eax
  801177:	83 f8 01             	cmp    $0x1,%eax
  80117a:	75 21                	jne    80119d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80117c:	a1 08 40 80 00       	mov    0x804008,%eax
  801181:	8b 40 48             	mov    0x48(%eax),%eax
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	53                   	push   %ebx
  801188:	50                   	push   %eax
  801189:	68 d0 27 80 00       	push   $0x8027d0
  80118e:	e8 9f f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119b:	eb 26                	jmp    8011c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80119d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a0:	8b 40 08             	mov    0x8(%eax),%eax
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	74 17                	je     8011be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	ff 75 10             	pushl  0x10(%ebp)
  8011ad:	ff 75 0c             	pushl  0xc(%ebp)
  8011b0:	52                   	push   %edx
  8011b1:	ff d0                	call   *%eax
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	eb 09                	jmp    8011c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	eb 05                	jmp    8011c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011c3:	89 d0                	mov    %edx,%eax
  8011c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011de:	eb 21                	jmp    801201 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e0:	83 ec 04             	sub    $0x4,%esp
  8011e3:	89 f0                	mov    %esi,%eax
  8011e5:	29 d8                	sub    %ebx,%eax
  8011e7:	50                   	push   %eax
  8011e8:	89 d8                	mov    %ebx,%eax
  8011ea:	03 45 0c             	add    0xc(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	57                   	push   %edi
  8011ef:	e8 45 ff ff ff       	call   801139 <read>
		if (m < 0)
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 0c                	js     801207 <readn+0x3d>
			return m;
		if (m == 0)
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	74 06                	je     801205 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ff:	01 c3                	add    %eax,%ebx
  801201:	39 f3                	cmp    %esi,%ebx
  801203:	72 db                	jb     8011e0 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801205:	89 d8                	mov    %ebx,%eax
}
  801207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120a:	5b                   	pop    %ebx
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	53                   	push   %ebx
  801213:	83 ec 14             	sub    $0x14,%esp
  801216:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801219:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	53                   	push   %ebx
  80121e:	e8 a7 fc ff ff       	call   800eca <fd_lookup>
  801223:	83 c4 08             	add    $0x8,%esp
  801226:	89 c2                	mov    %eax,%edx
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 68                	js     801294 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801232:	50                   	push   %eax
  801233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801236:	ff 30                	pushl  (%eax)
  801238:	e8 e3 fc ff ff       	call   800f20 <dev_lookup>
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	78 47                	js     80128b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801244:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801247:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124b:	75 21                	jne    80126e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80124d:	a1 08 40 80 00       	mov    0x804008,%eax
  801252:	8b 40 48             	mov    0x48(%eax),%eax
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	53                   	push   %ebx
  801259:	50                   	push   %eax
  80125a:	68 ec 27 80 00       	push   $0x8027ec
  80125f:	e8 ce ef ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80126c:	eb 26                	jmp    801294 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80126e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801271:	8b 52 0c             	mov    0xc(%edx),%edx
  801274:	85 d2                	test   %edx,%edx
  801276:	74 17                	je     80128f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	ff 75 10             	pushl  0x10(%ebp)
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	50                   	push   %eax
  801282:	ff d2                	call   *%edx
  801284:	89 c2                	mov    %eax,%edx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	eb 09                	jmp    801294 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	eb 05                	jmp    801294 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801294:	89 d0                	mov    %edx,%eax
  801296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <seek>:

int
seek(int fdnum, off_t offset)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	ff 75 08             	pushl  0x8(%ebp)
  8012a8:	e8 1d fc ff ff       	call   800eca <fd_lookup>
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 0e                	js     8012c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 14             	sub    $0x14,%esp
  8012cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	53                   	push   %ebx
  8012d3:	e8 f2 fb ff ff       	call   800eca <fd_lookup>
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 65                	js     801346 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012eb:	ff 30                	pushl  (%eax)
  8012ed:	e8 2e fc ff ff       	call   800f20 <dev_lookup>
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 44                	js     80133d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801300:	75 21                	jne    801323 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801302:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801307:	8b 40 48             	mov    0x48(%eax),%eax
  80130a:	83 ec 04             	sub    $0x4,%esp
  80130d:	53                   	push   %ebx
  80130e:	50                   	push   %eax
  80130f:	68 ac 27 80 00       	push   $0x8027ac
  801314:	e8 19 ef ff ff       	call   800232 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801321:	eb 23                	jmp    801346 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801323:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801326:	8b 52 18             	mov    0x18(%edx),%edx
  801329:	85 d2                	test   %edx,%edx
  80132b:	74 14                	je     801341 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	ff 75 0c             	pushl  0xc(%ebp)
  801333:	50                   	push   %eax
  801334:	ff d2                	call   *%edx
  801336:	89 c2                	mov    %eax,%edx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	eb 09                	jmp    801346 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	eb 05                	jmp    801346 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801341:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801346:	89 d0                	mov    %edx,%eax
  801348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	53                   	push   %ebx
  801351:	83 ec 14             	sub    $0x14,%esp
  801354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801357:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 08             	pushl  0x8(%ebp)
  80135e:	e8 67 fb ff ff       	call   800eca <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	89 c2                	mov    %eax,%edx
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 58                	js     8013c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801376:	ff 30                	pushl  (%eax)
  801378:	e8 a3 fb ff ff       	call   800f20 <dev_lookup>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 37                	js     8013bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801387:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80138b:	74 32                	je     8013bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80138d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801390:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801397:	00 00 00 
	stat->st_isdir = 0;
  80139a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a1:	00 00 00 
	stat->st_dev = dev;
  8013a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b1:	ff 50 14             	call   *0x14(%eax)
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	eb 09                	jmp    8013c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	eb 05                	jmp    8013c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c4:	89 d0                	mov    %edx,%eax
  8013c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	6a 00                	push   $0x0
  8013d5:	ff 75 08             	pushl  0x8(%ebp)
  8013d8:	e8 09 02 00 00       	call   8015e6 <open>
  8013dd:	89 c3                	mov    %eax,%ebx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 db                	test   %ebx,%ebx
  8013e4:	78 1b                	js     801401 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	53                   	push   %ebx
  8013ed:	e8 5b ff ff ff       	call   80134d <fstat>
  8013f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 fd fb ff ff       	call   800ff9 <close>
	return r;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	89 f0                	mov    %esi,%eax
}
  801401:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801404:	5b                   	pop    %ebx
  801405:	5e                   	pop    %esi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	89 c6                	mov    %eax,%esi
  80140f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801411:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801418:	75 12                	jne    80142c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	6a 01                	push   $0x1
  80141f:	e8 70 0c 00 00       	call   802094 <ipc_find_env>
  801424:	a3 00 40 80 00       	mov    %eax,0x804000
  801429:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142c:	6a 07                	push   $0x7
  80142e:	68 00 50 80 00       	push   $0x805000
  801433:	56                   	push   %esi
  801434:	ff 35 00 40 80 00    	pushl  0x804000
  80143a:	e8 01 0c 00 00       	call   802040 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143f:	83 c4 0c             	add    $0xc,%esp
  801442:	6a 00                	push   $0x0
  801444:	53                   	push   %ebx
  801445:	6a 00                	push   $0x0
  801447:	e8 8b 0b 00 00       	call   801fd7 <ipc_recv>
}
  80144c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
  801467:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 02 00 00 00       	mov    $0x2,%eax
  801476:	e8 8d ff ff ff       	call   801408 <fsipc>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	8b 40 0c             	mov    0xc(%eax),%eax
  801489:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148e:	ba 00 00 00 00       	mov    $0x0,%edx
  801493:	b8 06 00 00 00       	mov    $0x6,%eax
  801498:	e8 6b ff ff ff       	call   801408 <fsipc>
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8014af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014be:	e8 45 ff ff ff       	call   801408 <fsipc>
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	85 d2                	test   %edx,%edx
  8014c7:	78 2c                	js     8014f5 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	68 00 50 80 00       	push   $0x805000
  8014d1:	53                   	push   %ebx
  8014d2:	e8 e2 f2 ff ff       	call   8007b9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8014dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 40 0c             	mov    0xc(%eax),%eax
  80150c:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801514:	eb 3d                	jmp    801553 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801516:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80151c:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801521:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	57                   	push   %edi
  801528:	53                   	push   %ebx
  801529:	68 08 50 80 00       	push   $0x805008
  80152e:	e8 18 f4 ff ff       	call   80094b <memmove>
                fsipcbuf.write.req_n = tmp; 
  801533:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 04 00 00 00       	mov    $0x4,%eax
  801543:	e8 c0 fe ff ff       	call   801408 <fsipc>
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 0d                	js     80155c <devfile_write+0x62>
		        return r;
                n -= tmp;
  80154f:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801551:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801553:	85 f6                	test   %esi,%esi
  801555:	75 bf                	jne    801516 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801557:	89 d8                	mov    %ebx,%eax
  801559:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80155c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5f                   	pop    %edi
  801562:	5d                   	pop    %ebp
  801563:	c3                   	ret    

00801564 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	8b 40 0c             	mov    0xc(%eax),%eax
  801572:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801577:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	b8 03 00 00 00       	mov    $0x3,%eax
  801587:	e8 7c fe ff ff       	call   801408 <fsipc>
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 4b                	js     8015dd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801592:	39 c6                	cmp    %eax,%esi
  801594:	73 16                	jae    8015ac <devfile_read+0x48>
  801596:	68 20 28 80 00       	push   $0x802820
  80159b:	68 27 28 80 00       	push   $0x802827
  8015a0:	6a 7c                	push   $0x7c
  8015a2:	68 3c 28 80 00       	push   $0x80283c
  8015a7:	e8 ad eb ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  8015ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b1:	7e 16                	jle    8015c9 <devfile_read+0x65>
  8015b3:	68 47 28 80 00       	push   $0x802847
  8015b8:	68 27 28 80 00       	push   $0x802827
  8015bd:	6a 7d                	push   $0x7d
  8015bf:	68 3c 28 80 00       	push   $0x80283c
  8015c4:	e8 90 eb ff ff       	call   800159 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	50                   	push   %eax
  8015cd:	68 00 50 80 00       	push   $0x805000
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	e8 71 f3 ff ff       	call   80094b <memmove>
	return r;
  8015da:	83 c4 10             	add    $0x10,%esp
}
  8015dd:	89 d8                	mov    %ebx,%eax
  8015df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 20             	sub    $0x20,%esp
  8015ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015f0:	53                   	push   %ebx
  8015f1:	e8 8a f1 ff ff       	call   800780 <strlen>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fe:	7f 67                	jg     801667 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801600:	83 ec 0c             	sub    $0xc,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	e8 6f f8 ff ff       	call   800e7b <fd_alloc>
  80160c:	83 c4 10             	add    $0x10,%esp
		return r;
  80160f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801611:	85 c0                	test   %eax,%eax
  801613:	78 57                	js     80166c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	68 00 50 80 00       	push   $0x805000
  80161e:	e8 96 f1 ff ff       	call   8007b9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801623:	8b 45 0c             	mov    0xc(%ebp),%eax
  801626:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162e:	b8 01 00 00 00       	mov    $0x1,%eax
  801633:	e8 d0 fd ff ff       	call   801408 <fsipc>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	79 14                	jns    801655 <open+0x6f>
		fd_close(fd, 0);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	6a 00                	push   $0x0
  801646:	ff 75 f4             	pushl  -0xc(%ebp)
  801649:	e8 2a f9 ff ff       	call   800f78 <fd_close>
		return r;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	89 da                	mov    %ebx,%edx
  801653:	eb 17                	jmp    80166c <open+0x86>
	}

	return fd2num(fd);
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	ff 75 f4             	pushl  -0xc(%ebp)
  80165b:	e8 f4 f7 ff ff       	call   800e54 <fd2num>
  801660:	89 c2                	mov    %eax,%edx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 05                	jmp    80166c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801667:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80166c:	89 d0                	mov    %edx,%eax
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801679:	ba 00 00 00 00       	mov    $0x0,%edx
  80167e:	b8 08 00 00 00       	mov    $0x8,%eax
  801683:	e8 80 fd ff ff       	call   801408 <fsipc>
}
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801690:	68 53 28 80 00       	push   $0x802853
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	e8 1c f1 ff ff       	call   8007b9 <strcpy>
	return 0;
}
  80169d:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 10             	sub    $0x10,%esp
  8016ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016ae:	53                   	push   %ebx
  8016af:	e8 18 0a 00 00       	call   8020cc <pageref>
  8016b4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016bc:	83 f8 01             	cmp    $0x1,%eax
  8016bf:	75 10                	jne    8016d1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016c1:	83 ec 0c             	sub    $0xc,%esp
  8016c4:	ff 73 0c             	pushl  0xc(%ebx)
  8016c7:	e8 ca 02 00 00       	call   801996 <nsipc_close>
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016d1:	89 d0                	mov    %edx,%eax
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016de:	6a 00                	push   $0x0
  8016e0:	ff 75 10             	pushl  0x10(%ebp)
  8016e3:	ff 75 0c             	pushl  0xc(%ebp)
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	ff 70 0c             	pushl  0xc(%eax)
  8016ec:	e8 82 03 00 00       	call   801a73 <nsipc_send>
}
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016f9:	6a 00                	push   $0x0
  8016fb:	ff 75 10             	pushl  0x10(%ebp)
  8016fe:	ff 75 0c             	pushl  0xc(%ebp)
  801701:	8b 45 08             	mov    0x8(%ebp),%eax
  801704:	ff 70 0c             	pushl  0xc(%eax)
  801707:	e8 fb 02 00 00       	call   801a07 <nsipc_recv>
}
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801714:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801717:	52                   	push   %edx
  801718:	50                   	push   %eax
  801719:	e8 ac f7 ff ff       	call   800eca <fd_lookup>
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	78 17                	js     80173c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801728:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80172e:	39 08                	cmp    %ecx,(%eax)
  801730:	75 05                	jne    801737 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801732:	8b 40 0c             	mov    0xc(%eax),%eax
  801735:	eb 05                	jmp    80173c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801737:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	83 ec 1c             	sub    $0x1c,%esp
  801746:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	e8 2a f7 ff ff       	call   800e7b <fd_alloc>
  801751:	89 c3                	mov    %eax,%ebx
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 1b                	js     801775 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80175a:	83 ec 04             	sub    $0x4,%esp
  80175d:	68 07 04 00 00       	push   $0x407
  801762:	ff 75 f4             	pushl  -0xc(%ebp)
  801765:	6a 00                	push   $0x0
  801767:	e8 56 f4 ff ff       	call   800bc2 <sys_page_alloc>
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	79 10                	jns    801785 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801775:	83 ec 0c             	sub    $0xc,%esp
  801778:	56                   	push   %esi
  801779:	e8 18 02 00 00       	call   801996 <nsipc_close>
		return r;
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	89 d8                	mov    %ebx,%eax
  801783:	eb 24                	jmp    8017a9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801785:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801790:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801793:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  80179a:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	52                   	push   %edx
  8017a1:	e8 ae f6 ff ff       	call   800e54 <fd2num>
  8017a6:	83 c4 10             	add    $0x10,%esp
}
  8017a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	e8 50 ff ff ff       	call   80170e <fd2sockid>
		return r;
  8017be:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 1f                	js     8017e3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	ff 75 10             	pushl  0x10(%ebp)
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	50                   	push   %eax
  8017ce:	e8 1c 01 00 00       	call   8018ef <nsipc_accept>
  8017d3:	83 c4 10             	add    $0x10,%esp
		return r;
  8017d6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 07                	js     8017e3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017dc:	e8 5d ff ff ff       	call   80173e <alloc_sockfd>
  8017e1:	89 c1                	mov    %eax,%ecx
}
  8017e3:	89 c8                	mov    %ecx,%eax
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	e8 19 ff ff ff       	call   80170e <fd2sockid>
  8017f5:	89 c2                	mov    %eax,%edx
  8017f7:	85 d2                	test   %edx,%edx
  8017f9:	78 12                	js     80180d <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	ff 75 10             	pushl  0x10(%ebp)
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	52                   	push   %edx
  801805:	e8 35 01 00 00       	call   80193f <nsipc_bind>
  80180a:	83 c4 10             	add    $0x10,%esp
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <shutdown>:

int
shutdown(int s, int how)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	e8 f1 fe ff ff       	call   80170e <fd2sockid>
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	85 d2                	test   %edx,%edx
  801821:	78 0f                	js     801832 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	ff 75 0c             	pushl  0xc(%ebp)
  801829:	52                   	push   %edx
  80182a:	e8 45 01 00 00       	call   801974 <nsipc_shutdown>
  80182f:	83 c4 10             	add    $0x10,%esp
}
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	e8 cc fe ff ff       	call   80170e <fd2sockid>
  801842:	89 c2                	mov    %eax,%edx
  801844:	85 d2                	test   %edx,%edx
  801846:	78 12                	js     80185a <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801848:	83 ec 04             	sub    $0x4,%esp
  80184b:	ff 75 10             	pushl  0x10(%ebp)
  80184e:	ff 75 0c             	pushl  0xc(%ebp)
  801851:	52                   	push   %edx
  801852:	e8 59 01 00 00       	call   8019b0 <nsipc_connect>
  801857:	83 c4 10             	add    $0x10,%esp
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <listen>:

int
listen(int s, int backlog)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	e8 a4 fe ff ff       	call   80170e <fd2sockid>
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	85 d2                	test   %edx,%edx
  80186e:	78 0f                	js     80187f <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	52                   	push   %edx
  801877:	e8 69 01 00 00       	call   8019e5 <nsipc_listen>
  80187c:	83 c4 10             	add    $0x10,%esp
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801887:	ff 75 10             	pushl  0x10(%ebp)
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	ff 75 08             	pushl  0x8(%ebp)
  801890:	e8 3c 02 00 00       	call   801ad1 <nsipc_socket>
  801895:	89 c2                	mov    %eax,%edx
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 d2                	test   %edx,%edx
  80189c:	78 05                	js     8018a3 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  80189e:	e8 9b fe ff ff       	call   80173e <alloc_sockfd>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018ae:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018b5:	75 12                	jne    8018c9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	6a 02                	push   $0x2
  8018bc:	e8 d3 07 00 00       	call   802094 <ipc_find_env>
  8018c1:	a3 04 40 80 00       	mov    %eax,0x804004
  8018c6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018c9:	6a 07                	push   $0x7
  8018cb:	68 00 60 80 00       	push   $0x806000
  8018d0:	53                   	push   %ebx
  8018d1:	ff 35 04 40 80 00    	pushl  0x804004
  8018d7:	e8 64 07 00 00       	call   802040 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018dc:	83 c4 0c             	add    $0xc,%esp
  8018df:	6a 00                	push   $0x0
  8018e1:	6a 00                	push   $0x0
  8018e3:	6a 00                	push   $0x0
  8018e5:	e8 ed 06 00 00       	call   801fd7 <ipc_recv>
}
  8018ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018ff:	8b 06                	mov    (%esi),%eax
  801901:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801906:	b8 01 00 00 00       	mov    $0x1,%eax
  80190b:	e8 95 ff ff ff       	call   8018a5 <nsipc>
  801910:	89 c3                	mov    %eax,%ebx
  801912:	85 c0                	test   %eax,%eax
  801914:	78 20                	js     801936 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801916:	83 ec 04             	sub    $0x4,%esp
  801919:	ff 35 10 60 80 00    	pushl  0x806010
  80191f:	68 00 60 80 00       	push   $0x806000
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	e8 1f f0 ff ff       	call   80094b <memmove>
		*addrlen = ret->ret_addrlen;
  80192c:	a1 10 60 80 00       	mov    0x806010,%eax
  801931:	89 06                	mov    %eax,(%esi)
  801933:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801936:	89 d8                	mov    %ebx,%eax
  801938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	53                   	push   %ebx
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801951:	53                   	push   %ebx
  801952:	ff 75 0c             	pushl  0xc(%ebp)
  801955:	68 04 60 80 00       	push   $0x806004
  80195a:	e8 ec ef ff ff       	call   80094b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80195f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801965:	b8 02 00 00 00       	mov    $0x2,%eax
  80196a:	e8 36 ff ff ff       	call   8018a5 <nsipc>
}
  80196f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801982:	8b 45 0c             	mov    0xc(%ebp),%eax
  801985:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80198a:	b8 03 00 00 00       	mov    $0x3,%eax
  80198f:	e8 11 ff ff ff       	call   8018a5 <nsipc>
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <nsipc_close>:

int
nsipc_close(int s)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a9:	e8 f7 fe ff ff       	call   8018a5 <nsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019c2:	53                   	push   %ebx
  8019c3:	ff 75 0c             	pushl  0xc(%ebp)
  8019c6:	68 04 60 80 00       	push   $0x806004
  8019cb:	e8 7b ef ff ff       	call   80094b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019d0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8019db:	e8 c5 fe ff ff       	call   8018a5 <nsipc>
}
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801a00:	e8 a0 fe ff ff       	call   8018a5 <nsipc>
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a17:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a20:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a25:	b8 07 00 00 00       	mov    $0x7,%eax
  801a2a:	e8 76 fe ff ff       	call   8018a5 <nsipc>
  801a2f:	89 c3                	mov    %eax,%ebx
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 35                	js     801a6a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a35:	39 f0                	cmp    %esi,%eax
  801a37:	7f 07                	jg     801a40 <nsipc_recv+0x39>
  801a39:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a3e:	7e 16                	jle    801a56 <nsipc_recv+0x4f>
  801a40:	68 5f 28 80 00       	push   $0x80285f
  801a45:	68 27 28 80 00       	push   $0x802827
  801a4a:	6a 62                	push   $0x62
  801a4c:	68 74 28 80 00       	push   $0x802874
  801a51:	e8 03 e7 ff ff       	call   800159 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	50                   	push   %eax
  801a5a:	68 00 60 80 00       	push   $0x806000
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	e8 e4 ee ff ff       	call   80094b <memmove>
  801a67:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a6a:	89 d8                	mov    %ebx,%eax
  801a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	53                   	push   %ebx
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a80:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a85:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a8b:	7e 16                	jle    801aa3 <nsipc_send+0x30>
  801a8d:	68 80 28 80 00       	push   $0x802880
  801a92:	68 27 28 80 00       	push   $0x802827
  801a97:	6a 6d                	push   $0x6d
  801a99:	68 74 28 80 00       	push   $0x802874
  801a9e:	e8 b6 e6 ff ff       	call   800159 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	53                   	push   %ebx
  801aa7:	ff 75 0c             	pushl  0xc(%ebp)
  801aaa:	68 0c 60 80 00       	push   $0x80600c
  801aaf:	e8 97 ee ff ff       	call   80094b <memmove>
	nsipcbuf.send.req_size = size;
  801ab4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801aba:	8b 45 14             	mov    0x14(%ebp),%eax
  801abd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ac2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ac7:	e8 d9 fd ff ff       	call   8018a5 <nsipc>
}
  801acc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aea:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801aef:	b8 09 00 00 00       	mov    $0x9,%eax
  801af4:	e8 ac fd ff ff       	call   8018a5 <nsipc>
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 75 08             	pushl  0x8(%ebp)
  801b09:	e8 56 f3 ff ff       	call   800e64 <fd2data>
  801b0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b10:	83 c4 08             	add    $0x8,%esp
  801b13:	68 8c 28 80 00       	push   $0x80288c
  801b18:	53                   	push   %ebx
  801b19:	e8 9b ec ff ff       	call   8007b9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b1e:	8b 56 04             	mov    0x4(%esi),%edx
  801b21:	89 d0                	mov    %edx,%eax
  801b23:	2b 06                	sub    (%esi),%eax
  801b25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b2b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b32:	00 00 00 
	stat->st_dev = &devpipe;
  801b35:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b3c:	30 80 00 
	return 0;
}
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b55:	53                   	push   %ebx
  801b56:	6a 00                	push   $0x0
  801b58:	e8 ea f0 ff ff       	call   800c47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b5d:	89 1c 24             	mov    %ebx,(%esp)
  801b60:	e8 ff f2 ff ff       	call   800e64 <fd2data>
  801b65:	83 c4 08             	add    $0x8,%esp
  801b68:	50                   	push   %eax
  801b69:	6a 00                	push   $0x0
  801b6b:	e8 d7 f0 ff ff       	call   800c47 <sys_page_unmap>
}
  801b70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	57                   	push   %edi
  801b79:	56                   	push   %esi
  801b7a:	53                   	push   %ebx
  801b7b:	83 ec 1c             	sub    $0x1c,%esp
  801b7e:	89 c6                	mov    %eax,%esi
  801b80:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b83:	a1 08 40 80 00       	mov    0x804008,%eax
  801b88:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b8b:	83 ec 0c             	sub    $0xc,%esp
  801b8e:	56                   	push   %esi
  801b8f:	e8 38 05 00 00       	call   8020cc <pageref>
  801b94:	89 c7                	mov    %eax,%edi
  801b96:	83 c4 04             	add    $0x4,%esp
  801b99:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b9c:	e8 2b 05 00 00       	call   8020cc <pageref>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	39 c7                	cmp    %eax,%edi
  801ba6:	0f 94 c2             	sete   %dl
  801ba9:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801bac:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801bb2:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801bb5:	39 fb                	cmp    %edi,%ebx
  801bb7:	74 19                	je     801bd2 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801bb9:	84 d2                	test   %dl,%dl
  801bbb:	74 c6                	je     801b83 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bbd:	8b 51 58             	mov    0x58(%ecx),%edx
  801bc0:	50                   	push   %eax
  801bc1:	52                   	push   %edx
  801bc2:	53                   	push   %ebx
  801bc3:	68 93 28 80 00       	push   $0x802893
  801bc8:	e8 65 e6 ff ff       	call   800232 <cprintf>
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	eb b1                	jmp    801b83 <_pipeisclosed+0xe>
	}
}
  801bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5e                   	pop    %esi
  801bd7:	5f                   	pop    %edi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 28             	sub    $0x28,%esp
  801be3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be6:	56                   	push   %esi
  801be7:	e8 78 f2 ff ff       	call   800e64 <fd2data>
  801bec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf6:	eb 4b                	jmp    801c43 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf8:	89 da                	mov    %ebx,%edx
  801bfa:	89 f0                	mov    %esi,%eax
  801bfc:	e8 74 ff ff ff       	call   801b75 <_pipeisclosed>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	75 48                	jne    801c4d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c05:	e8 99 ef ff ff       	call   800ba3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c0a:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0d:	8b 0b                	mov    (%ebx),%ecx
  801c0f:	8d 51 20             	lea    0x20(%ecx),%edx
  801c12:	39 d0                	cmp    %edx,%eax
  801c14:	73 e2                	jae    801bf8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c19:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c1d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	c1 fa 1f             	sar    $0x1f,%edx
  801c25:	89 d1                	mov    %edx,%ecx
  801c27:	c1 e9 1b             	shr    $0x1b,%ecx
  801c2a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c2d:	83 e2 1f             	and    $0x1f,%edx
  801c30:	29 ca                	sub    %ecx,%edx
  801c32:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c36:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c3a:	83 c0 01             	add    $0x1,%eax
  801c3d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c40:	83 c7 01             	add    $0x1,%edi
  801c43:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c46:	75 c2                	jne    801c0a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c48:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4b:	eb 05                	jmp    801c52 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5f                   	pop    %edi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	57                   	push   %edi
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	83 ec 18             	sub    $0x18,%esp
  801c63:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c66:	57                   	push   %edi
  801c67:	e8 f8 f1 ff ff       	call   800e64 <fd2data>
  801c6c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c76:	eb 3d                	jmp    801cb5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c78:	85 db                	test   %ebx,%ebx
  801c7a:	74 04                	je     801c80 <devpipe_read+0x26>
				return i;
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	eb 44                	jmp    801cc4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c80:	89 f2                	mov    %esi,%edx
  801c82:	89 f8                	mov    %edi,%eax
  801c84:	e8 ec fe ff ff       	call   801b75 <_pipeisclosed>
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	75 32                	jne    801cbf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c8d:	e8 11 ef ff ff       	call   800ba3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c92:	8b 06                	mov    (%esi),%eax
  801c94:	3b 46 04             	cmp    0x4(%esi),%eax
  801c97:	74 df                	je     801c78 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c99:	99                   	cltd   
  801c9a:	c1 ea 1b             	shr    $0x1b,%edx
  801c9d:	01 d0                	add    %edx,%eax
  801c9f:	83 e0 1f             	and    $0x1f,%eax
  801ca2:	29 d0                	sub    %edx,%eax
  801ca4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cac:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801caf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb2:	83 c3 01             	add    $0x1,%ebx
  801cb5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb8:	75 d8                	jne    801c92 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cba:	8b 45 10             	mov    0x10(%ebp),%eax
  801cbd:	eb 05                	jmp    801cc4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cbf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	e8 9e f1 ff ff       	call   800e7b <fd_alloc>
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	89 c2                	mov    %eax,%edx
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	0f 88 2c 01 00 00    	js     801e16 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cea:	83 ec 04             	sub    $0x4,%esp
  801ced:	68 07 04 00 00       	push   $0x407
  801cf2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 c6 ee ff ff       	call   800bc2 <sys_page_alloc>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	89 c2                	mov    %eax,%edx
  801d01:	85 c0                	test   %eax,%eax
  801d03:	0f 88 0d 01 00 00    	js     801e16 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d09:	83 ec 0c             	sub    $0xc,%esp
  801d0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d0f:	50                   	push   %eax
  801d10:	e8 66 f1 ff ff       	call   800e7b <fd_alloc>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	0f 88 e2 00 00 00    	js     801e04 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	68 07 04 00 00       	push   $0x407
  801d2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2d:	6a 00                	push   $0x0
  801d2f:	e8 8e ee ff ff       	call   800bc2 <sys_page_alloc>
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 c3 00 00 00    	js     801e04 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	ff 75 f4             	pushl  -0xc(%ebp)
  801d47:	e8 18 f1 ff ff       	call   800e64 <fd2data>
  801d4c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	83 c4 0c             	add    $0xc,%esp
  801d51:	68 07 04 00 00       	push   $0x407
  801d56:	50                   	push   %eax
  801d57:	6a 00                	push   $0x0
  801d59:	e8 64 ee ff ff       	call   800bc2 <sys_page_alloc>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	0f 88 89 00 00 00    	js     801df4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6b:	83 ec 0c             	sub    $0xc,%esp
  801d6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d71:	e8 ee f0 ff ff       	call   800e64 <fd2data>
  801d76:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d7d:	50                   	push   %eax
  801d7e:	6a 00                	push   $0x0
  801d80:	56                   	push   %esi
  801d81:	6a 00                	push   $0x0
  801d83:	e8 7d ee ff ff       	call   800c05 <sys_page_map>
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	83 c4 20             	add    $0x20,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 55                	js     801de6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801daf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dbb:	83 ec 0c             	sub    $0xc,%esp
  801dbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc1:	e8 8e f0 ff ff       	call   800e54 <fd2num>
  801dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dcb:	83 c4 04             	add    $0x4,%esp
  801dce:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd1:	e8 7e f0 ff ff       	call   800e54 <fd2num>
  801dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  801de4:	eb 30                	jmp    801e16 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de6:	83 ec 08             	sub    $0x8,%esp
  801de9:	56                   	push   %esi
  801dea:	6a 00                	push   $0x0
  801dec:	e8 56 ee ff ff       	call   800c47 <sys_page_unmap>
  801df1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 46 ee ff ff       	call   800c47 <sys_page_unmap>
  801e01:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e04:	83 ec 08             	sub    $0x8,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	6a 00                	push   $0x0
  801e0c:	e8 36 ee ff ff       	call   800c47 <sys_page_unmap>
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e16:	89 d0                	mov    %edx,%eax
  801e18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e28:	50                   	push   %eax
  801e29:	ff 75 08             	pushl  0x8(%ebp)
  801e2c:	e8 99 f0 ff ff       	call   800eca <fd_lookup>
  801e31:	89 c2                	mov    %eax,%edx
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 d2                	test   %edx,%edx
  801e38:	78 18                	js     801e52 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e40:	e8 1f f0 ff ff       	call   800e64 <fd2data>
	return _pipeisclosed(fd, p);
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	e8 26 fd ff ff       	call   801b75 <_pipeisclosed>
  801e4f:	83 c4 10             	add    $0x10,%esp
}
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e57:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e64:	68 ab 28 80 00       	push   $0x8028ab
  801e69:	ff 75 0c             	pushl  0xc(%ebp)
  801e6c:	e8 48 e9 ff ff       	call   8007b9 <strcpy>
	return 0;
}
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	57                   	push   %edi
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e84:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e89:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8f:	eb 2d                	jmp    801ebe <devcons_write+0x46>
		m = n - tot;
  801e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e94:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e96:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e99:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e9e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	53                   	push   %ebx
  801ea5:	03 45 0c             	add    0xc(%ebp),%eax
  801ea8:	50                   	push   %eax
  801ea9:	57                   	push   %edi
  801eaa:	e8 9c ea ff ff       	call   80094b <memmove>
		sys_cputs(buf, m);
  801eaf:	83 c4 08             	add    $0x8,%esp
  801eb2:	53                   	push   %ebx
  801eb3:	57                   	push   %edi
  801eb4:	e8 4d ec ff ff       	call   800b06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb9:	01 de                	add    %ebx,%esi
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	89 f0                	mov    %esi,%eax
  801ec0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec3:	72 cc                	jb     801e91 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ed8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801edc:	75 07                	jne    801ee5 <devcons_read+0x18>
  801ede:	eb 28                	jmp    801f08 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ee0:	e8 be ec ff ff       	call   800ba3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ee5:	e8 3a ec ff ff       	call   800b24 <sys_cgetc>
  801eea:	85 c0                	test   %eax,%eax
  801eec:	74 f2                	je     801ee0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 16                	js     801f08 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ef2:	83 f8 04             	cmp    $0x4,%eax
  801ef5:	74 0c                	je     801f03 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efa:	88 02                	mov    %al,(%edx)
	return 1;
  801efc:	b8 01 00 00 00       	mov    $0x1,%eax
  801f01:	eb 05                	jmp    801f08 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f10:	8b 45 08             	mov    0x8(%ebp),%eax
  801f13:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f16:	6a 01                	push   $0x1
  801f18:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	e8 e5 eb ff ff       	call   800b06 <sys_cputs>
  801f21:	83 c4 10             	add    $0x10,%esp
}
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    

00801f26 <getchar>:

int
getchar(void)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f2c:	6a 01                	push   $0x1
  801f2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	6a 00                	push   $0x0
  801f34:	e8 00 f2 ff ff       	call   801139 <read>
	if (r < 0)
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 0f                	js     801f4f <getchar+0x29>
		return r;
	if (r < 1)
  801f40:	85 c0                	test   %eax,%eax
  801f42:	7e 06                	jle    801f4a <getchar+0x24>
		return -E_EOF;
	return c;
  801f44:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f48:	eb 05                	jmp    801f4f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f4a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5a:	50                   	push   %eax
  801f5b:	ff 75 08             	pushl  0x8(%ebp)
  801f5e:	e8 67 ef ff ff       	call   800eca <fd_lookup>
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 11                	js     801f7b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f73:	39 10                	cmp    %edx,(%eax)
  801f75:	0f 94 c0             	sete   %al
  801f78:	0f b6 c0             	movzbl %al,%eax
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <opencons>:

int
opencons(void)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	e8 ef ee ff ff       	call   800e7b <fd_alloc>
  801f8c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 3e                	js     801fd3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f95:	83 ec 04             	sub    $0x4,%esp
  801f98:	68 07 04 00 00       	push   $0x407
  801f9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa0:	6a 00                	push   $0x0
  801fa2:	e8 1b ec ff ff       	call   800bc2 <sys_page_alloc>
  801fa7:	83 c4 10             	add    $0x10,%esp
		return r;
  801faa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 23                	js     801fd3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	50                   	push   %eax
  801fc9:	e8 86 ee ff ff       	call   800e54 <fd2num>
  801fce:	89 c2                	mov    %eax,%edx
  801fd0:	83 c4 10             	add    $0x10,%esp
}
  801fd3:	89 d0                	mov    %edx,%eax
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fec:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	50                   	push   %eax
  801ff3:	e8 7a ed ff ff       	call   800d72 <sys_ipc_recv>
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	79 16                	jns    802015 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801fff:	85 f6                	test   %esi,%esi
  802001:	74 06                	je     802009 <ipc_recv+0x32>
  802003:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802009:	85 db                	test   %ebx,%ebx
  80200b:	74 2c                	je     802039 <ipc_recv+0x62>
  80200d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802013:	eb 24                	jmp    802039 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802015:	85 f6                	test   %esi,%esi
  802017:	74 0a                	je     802023 <ipc_recv+0x4c>
  802019:	a1 08 40 80 00       	mov    0x804008,%eax
  80201e:	8b 40 74             	mov    0x74(%eax),%eax
  802021:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802023:	85 db                	test   %ebx,%ebx
  802025:	74 0a                	je     802031 <ipc_recv+0x5a>
  802027:	a1 08 40 80 00       	mov    0x804008,%eax
  80202c:	8b 40 78             	mov    0x78(%eax),%eax
  80202f:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802031:	a1 08 40 80 00       	mov    0x804008,%eax
  802036:	8b 40 70             	mov    0x70(%eax),%eax
}
  802039:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	57                   	push   %edi
  802044:	56                   	push   %esi
  802045:	53                   	push   %ebx
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802052:	85 db                	test   %ebx,%ebx
  802054:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802059:	0f 44 d8             	cmove  %eax,%ebx
  80205c:	eb 1c                	jmp    80207a <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80205e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802061:	74 12                	je     802075 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802063:	50                   	push   %eax
  802064:	68 b7 28 80 00       	push   $0x8028b7
  802069:	6a 39                	push   $0x39
  80206b:	68 d2 28 80 00       	push   $0x8028d2
  802070:	e8 e4 e0 ff ff       	call   800159 <_panic>
                 sys_yield();
  802075:	e8 29 eb ff ff       	call   800ba3 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80207a:	ff 75 14             	pushl  0x14(%ebp)
  80207d:	53                   	push   %ebx
  80207e:	56                   	push   %esi
  80207f:	57                   	push   %edi
  802080:	e8 ca ec ff ff       	call   800d4f <sys_ipc_try_send>
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 d2                	js     80205e <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a8:	8b 52 50             	mov    0x50(%edx),%edx
  8020ab:	39 ca                	cmp    %ecx,%edx
  8020ad:	75 0d                	jne    8020bc <ipc_find_env+0x28>
			return envs[i].env_id;
  8020af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020b2:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8020b7:	8b 40 08             	mov    0x8(%eax),%eax
  8020ba:	eb 0e                	jmp    8020ca <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020bc:	83 c0 01             	add    $0x1,%eax
  8020bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c4:	75 d9                	jne    80209f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c6:	66 b8 00 00          	mov    $0x0,%ax
}
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    

008020cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d2:	89 d0                	mov    %edx,%eax
  8020d4:	c1 e8 16             	shr    $0x16,%eax
  8020d7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020de:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e3:	f6 c1 01             	test   $0x1,%cl
  8020e6:	74 1d                	je     802105 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e8:	c1 ea 0c             	shr    $0xc,%edx
  8020eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f2:	f6 c2 01             	test   $0x1,%dl
  8020f5:	74 0e                	je     802105 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f7:	c1 ea 0c             	shr    $0xc,%edx
  8020fa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802101:	ef 
  802102:	0f b7 c0             	movzwl %ax,%eax
}
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	66 90                	xchg   %ax,%ax
  802109:	66 90                	xchg   %ax,%ax
  80210b:	66 90                	xchg   %ax,%ax
  80210d:	66 90                	xchg   %ax,%ax
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	83 ec 10             	sub    $0x10,%esp
  802116:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80211a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80211e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802122:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802126:	85 d2                	test   %edx,%edx
  802128:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80212c:	89 34 24             	mov    %esi,(%esp)
  80212f:	89 c8                	mov    %ecx,%eax
  802131:	75 35                	jne    802168 <__udivdi3+0x58>
  802133:	39 f1                	cmp    %esi,%ecx
  802135:	0f 87 bd 00 00 00    	ja     8021f8 <__udivdi3+0xe8>
  80213b:	85 c9                	test   %ecx,%ecx
  80213d:	89 cd                	mov    %ecx,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f1                	div    %ecx
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 f0                	mov    %esi,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c6                	mov    %eax,%esi
  802154:	89 f8                	mov    %edi,%eax
  802156:	f7 f5                	div    %ebp
  802158:	89 f2                	mov    %esi,%edx
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	5e                   	pop    %esi
  80215e:	5f                   	pop    %edi
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    
  802161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802168:	3b 14 24             	cmp    (%esp),%edx
  80216b:	77 7b                	ja     8021e8 <__udivdi3+0xd8>
  80216d:	0f bd f2             	bsr    %edx,%esi
  802170:	83 f6 1f             	xor    $0x1f,%esi
  802173:	0f 84 97 00 00 00    	je     802210 <__udivdi3+0x100>
  802179:	bd 20 00 00 00       	mov    $0x20,%ebp
  80217e:	89 d7                	mov    %edx,%edi
  802180:	89 f1                	mov    %esi,%ecx
  802182:	29 f5                	sub    %esi,%ebp
  802184:	d3 e7                	shl    %cl,%edi
  802186:	89 c2                	mov    %eax,%edx
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	d3 ea                	shr    %cl,%edx
  80218c:	89 f1                	mov    %esi,%ecx
  80218e:	09 fa                	or     %edi,%edx
  802190:	8b 3c 24             	mov    (%esp),%edi
  802193:	d3 e0                	shl    %cl,%eax
  802195:	89 54 24 08          	mov    %edx,0x8(%esp)
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219f:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021a3:	89 fa                	mov    %edi,%edx
  8021a5:	d3 ea                	shr    %cl,%edx
  8021a7:	89 f1                	mov    %esi,%ecx
  8021a9:	d3 e7                	shl    %cl,%edi
  8021ab:	89 e9                	mov    %ebp,%ecx
  8021ad:	d3 e8                	shr    %cl,%eax
  8021af:	09 c7                	or     %eax,%edi
  8021b1:	89 f8                	mov    %edi,%eax
  8021b3:	f7 74 24 08          	divl   0x8(%esp)
  8021b7:	89 d5                	mov    %edx,%ebp
  8021b9:	89 c7                	mov    %eax,%edi
  8021bb:	f7 64 24 0c          	mull   0xc(%esp)
  8021bf:	39 d5                	cmp    %edx,%ebp
  8021c1:	89 14 24             	mov    %edx,(%esp)
  8021c4:	72 11                	jb     8021d7 <__udivdi3+0xc7>
  8021c6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021ca:	89 f1                	mov    %esi,%ecx
  8021cc:	d3 e2                	shl    %cl,%edx
  8021ce:	39 c2                	cmp    %eax,%edx
  8021d0:	73 5e                	jae    802230 <__udivdi3+0x120>
  8021d2:	3b 2c 24             	cmp    (%esp),%ebp
  8021d5:	75 59                	jne    802230 <__udivdi3+0x120>
  8021d7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021da:	31 f6                	xor    %esi,%esi
  8021dc:	89 f2                	mov    %esi,%edx
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	31 f6                	xor    %esi,%esi
  8021ea:	31 c0                	xor    %eax,%eax
  8021ec:	89 f2                	mov    %esi,%edx
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	89 f2                	mov    %esi,%edx
  8021fa:	31 f6                	xor    %esi,%esi
  8021fc:	89 f8                	mov    %edi,%eax
  8021fe:	f7 f1                	div    %ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802214:	76 0b                	jbe    802221 <__udivdi3+0x111>
  802216:	31 c0                	xor    %eax,%eax
  802218:	3b 14 24             	cmp    (%esp),%edx
  80221b:	0f 83 37 ff ff ff    	jae    802158 <__udivdi3+0x48>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	e9 2d ff ff ff       	jmp    802158 <__udivdi3+0x48>
  80222b:	90                   	nop
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f8                	mov    %edi,%eax
  802232:	31 f6                	xor    %esi,%esi
  802234:	e9 1f ff ff ff       	jmp    802158 <__udivdi3+0x48>
  802239:	66 90                	xchg   %ax,%ax
  80223b:	66 90                	xchg   %ax,%ax
  80223d:	66 90                	xchg   %ax,%ax
  80223f:	90                   	nop

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	83 ec 20             	sub    $0x20,%esp
  802246:	8b 44 24 34          	mov    0x34(%esp),%eax
  80224a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802252:	89 c6                	mov    %eax,%esi
  802254:	89 44 24 10          	mov    %eax,0x10(%esp)
  802258:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80225c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802260:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802264:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802268:	89 74 24 18          	mov    %esi,0x18(%esp)
  80226c:	85 c0                	test   %eax,%eax
  80226e:	89 c2                	mov    %eax,%edx
  802270:	75 1e                	jne    802290 <__umoddi3+0x50>
  802272:	39 f7                	cmp    %esi,%edi
  802274:	76 52                	jbe    8022c8 <__umoddi3+0x88>
  802276:	89 c8                	mov    %ecx,%eax
  802278:	89 f2                	mov    %esi,%edx
  80227a:	f7 f7                	div    %edi
  80227c:	89 d0                	mov    %edx,%eax
  80227e:	31 d2                	xor    %edx,%edx
  802280:	83 c4 20             	add    $0x20,%esp
  802283:	5e                   	pop    %esi
  802284:	5f                   	pop    %edi
  802285:	5d                   	pop    %ebp
  802286:	c3                   	ret    
  802287:	89 f6                	mov    %esi,%esi
  802289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802290:	39 f0                	cmp    %esi,%eax
  802292:	77 5c                	ja     8022f0 <__umoddi3+0xb0>
  802294:	0f bd e8             	bsr    %eax,%ebp
  802297:	83 f5 1f             	xor    $0x1f,%ebp
  80229a:	75 64                	jne    802300 <__umoddi3+0xc0>
  80229c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8022a0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8022a4:	0f 86 f6 00 00 00    	jbe    8023a0 <__umoddi3+0x160>
  8022aa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8022ae:	0f 82 ec 00 00 00    	jb     8023a0 <__umoddi3+0x160>
  8022b4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022b8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022bc:	83 c4 20             	add    $0x20,%esp
  8022bf:	5e                   	pop    %esi
  8022c0:	5f                   	pop    %edi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
  8022c3:	90                   	nop
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	85 ff                	test   %edi,%edi
  8022ca:	89 fd                	mov    %edi,%ebp
  8022cc:	75 0b                	jne    8022d9 <__umoddi3+0x99>
  8022ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f7                	div    %edi
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022dd:	31 d2                	xor    %edx,%edx
  8022df:	f7 f5                	div    %ebp
  8022e1:	89 c8                	mov    %ecx,%eax
  8022e3:	f7 f5                	div    %ebp
  8022e5:	eb 95                	jmp    80227c <__umoddi3+0x3c>
  8022e7:	89 f6                	mov    %esi,%esi
  8022e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 20             	add    $0x20,%esp
  8022f7:	5e                   	pop    %esi
  8022f8:	5f                   	pop    %edi
  8022f9:	5d                   	pop    %ebp
  8022fa:	c3                   	ret    
  8022fb:	90                   	nop
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	b8 20 00 00 00       	mov    $0x20,%eax
  802305:	89 e9                	mov    %ebp,%ecx
  802307:	29 e8                	sub    %ebp,%eax
  802309:	d3 e2                	shl    %cl,%edx
  80230b:	89 c7                	mov    %eax,%edi
  80230d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802311:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 c1                	mov    %eax,%ecx
  80231b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80231f:	09 d1                	or     %edx,%ecx
  802321:	89 fa                	mov    %edi,%edx
  802323:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802327:	89 e9                	mov    %ebp,%ecx
  802329:	d3 e0                	shl    %cl,%eax
  80232b:	89 f9                	mov    %edi,%ecx
  80232d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802331:	89 f0                	mov    %esi,%eax
  802333:	d3 e8                	shr    %cl,%eax
  802335:	89 e9                	mov    %ebp,%ecx
  802337:	89 c7                	mov    %eax,%edi
  802339:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80233d:	d3 e6                	shl    %cl,%esi
  80233f:	89 d1                	mov    %edx,%ecx
  802341:	89 fa                	mov    %edi,%edx
  802343:	d3 e8                	shr    %cl,%eax
  802345:	89 e9                	mov    %ebp,%ecx
  802347:	09 f0                	or     %esi,%eax
  802349:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80234d:	f7 74 24 10          	divl   0x10(%esp)
  802351:	d3 e6                	shl    %cl,%esi
  802353:	89 d1                	mov    %edx,%ecx
  802355:	f7 64 24 0c          	mull   0xc(%esp)
  802359:	39 d1                	cmp    %edx,%ecx
  80235b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80235f:	89 d7                	mov    %edx,%edi
  802361:	89 c6                	mov    %eax,%esi
  802363:	72 0a                	jb     80236f <__umoddi3+0x12f>
  802365:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802369:	73 10                	jae    80237b <__umoddi3+0x13b>
  80236b:	39 d1                	cmp    %edx,%ecx
  80236d:	75 0c                	jne    80237b <__umoddi3+0x13b>
  80236f:	89 d7                	mov    %edx,%edi
  802371:	89 c6                	mov    %eax,%esi
  802373:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802377:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80237b:	89 ca                	mov    %ecx,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802383:	29 f0                	sub    %esi,%eax
  802385:	19 fa                	sbb    %edi,%edx
  802387:	d3 e8                	shr    %cl,%eax
  802389:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80238e:	89 d7                	mov    %edx,%edi
  802390:	d3 e7                	shl    %cl,%edi
  802392:	89 e9                	mov    %ebp,%ecx
  802394:	09 f8                	or     %edi,%eax
  802396:	d3 ea                	shr    %cl,%edx
  802398:	83 c4 20             	add    $0x20,%esp
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    
  80239f:	90                   	nop
  8023a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023a4:	29 f9                	sub    %edi,%ecx
  8023a6:	19 c6                	sbb    %eax,%esi
  8023a8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023ac:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023b0:	e9 ff fe ff ff       	jmp    8022b4 <__umoddi3+0x74>
