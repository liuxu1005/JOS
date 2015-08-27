
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 80 28 80 00       	push   $0x802880
  800043:	e8 61 19 00 00       	call   8019a9 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 85 28 80 00       	push   $0x802885
  800057:	6a 0c                	push   $0xc
  800059:	68 93 28 80 00       	push   $0x802893
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 f0 15 00 00       	call   80165e <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 40 52 80 00       	push   $0x805240
  80007b:	53                   	push   %ebx
  80007c:	e8 0c 15 00 00       	call   80158d <readn>
  800081:	89 c7                	mov    %eax,%edi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 a8 28 80 00       	push   $0x8028a8
  800090:	6a 0f                	push   $0xf
  800092:	68 93 28 80 00       	push   $0x802893
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 54 0f 00 00       	call   800ff5 <fork>
  8000a1:	89 c6                	mov    %eax,%esi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 1b 2e 80 00       	push   $0x802e1b
  8000ad:	6a 12                	push   $0x12
  8000af:	68 93 28 80 00       	push   $0x802893
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 92 15 00 00       	call   80165e <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 e8 28 80 00 	movl   $0x8028e8,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 40 50 80 00       	push   $0x805040
  8000e5:	53                   	push   %ebx
  8000e6:	e8 a2 14 00 00       	call   80158d <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 f8                	cmp    %edi,%eax
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	57                   	push   %edi
  8000f7:	68 2c 29 80 00       	push   $0x80292c
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 93 28 80 00       	push   $0x802893
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	50                   	push   %eax
  80010c:	68 40 50 80 00       	push   $0x805040
  800111:	68 40 52 80 00       	push   $0x805240
  800116:	e8 6a 09 00 00       	call   800a85 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 58 29 80 00       	push   $0x802958
  80012a:	6a 19                	push   $0x19
  80012c:	68 93 28 80 00       	push   $0x802893
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 b2 28 80 00       	push   $0x8028b2
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 10 15 00 00       	call   80165e <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 66 12 00 00       	call   8013bc <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	56                   	push   %esi
  800162:	e8 b0 20 00 00       	call   802217 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 40 50 80 00       	push   $0x805040
  800174:	53                   	push   %ebx
  800175:	e8 13 14 00 00       	call   80158d <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 f8                	cmp    %edi,%eax
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	57                   	push   %edi
  800186:	68 90 29 80 00       	push   $0x802990
  80018b:	6a 21                	push   $0x21
  80018d:	68 93 28 80 00       	push   $0x802893
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 cb 28 80 00       	push   $0x8028cb
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 10 12 00 00       	call   8013bc <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   
  8001ad:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8001c3:	e8 7b 0a 00 00       	call   800c43 <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 40 54 80 00       	mov    %eax,0x805440

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
  8001f4:	83 c4 10             	add    $0x10,%esp
}
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 e0 11 00 00       	call   8013e9 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 ef 09 00 00       	call   800c02 <sys_env_destroy>
  800213:	83 c4 10             	add    $0x10,%esp
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800226:	e8 18 0a 00 00       	call   800c43 <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 c0 29 80 00       	push   $0x8029c0
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 59 2e 80 00 	movl   $0x802e59,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 37 09 00 00       	call   800bc5 <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 4f 01 00 00       	call   800423 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 dc 08 00 00       	call   800bc5 <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 d1                	mov    %edx,%ecx
  80031a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800320:	8b 45 10             	mov    0x10(%ebp),%eax
  800323:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800326:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800333:	72 05                	jb     80033a <printnum+0x35>
  800335:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800338:	77 3e                	ja     800378 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033a:	83 ec 0c             	sub    $0xc,%esp
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	83 eb 01             	sub    $0x1,%ebx
  800343:	53                   	push   %ebx
  800344:	50                   	push   %eax
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 57 22 00 00       	call   8025b0 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 13                	jmp    80037f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800378:	83 eb 01             	sub    $0x1,%ebx
  80037b:	85 db                	test   %ebx,%ebx
  80037d:	7f ed                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	56                   	push   %esi
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff 75 e4             	pushl  -0x1c(%ebp)
  800389:	ff 75 e0             	pushl  -0x20(%ebp)
  80038c:	ff 75 dc             	pushl  -0x24(%ebp)
  80038f:	ff 75 d8             	pushl  -0x28(%ebp)
  800392:	e8 49 23 00 00       	call   8026e0 <__umoddi3>
  800397:	83 c4 14             	add    $0x14,%esp
  80039a:	0f be 80 e3 29 80 00 	movsbl 0x8029e3(%eax),%eax
  8003a1:	50                   	push   %eax
  8003a2:	ff d7                	call   *%edi
  8003a4:	83 c4 10             	add    $0x10,%esp
}
  8003a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	88 02                	mov    %al,(%edx)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	50                   	push   %eax
  800410:	ff 75 10             	pushl  0x10(%ebp)
  800413:	ff 75 0c             	pushl  0xc(%ebp)
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	e8 05 00 00 00       	call   800423 <vprintfmt>
	va_end(ap);
  80041e:	83 c4 10             	add    $0x10,%esp
}
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	57                   	push   %edi
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 2c             	sub    $0x2c,%esp
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 7d 10             	mov    0x10(%ebp),%edi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 90 03 00 00    	je     8007cf <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	53                   	push   %ebx
  800443:	50                   	push   %eax
  800444:	ff d6                	call   *%esi
  800446:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	83 c7 01             	add    $0x1,%edi
  80044c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800450:	83 f8 25             	cmp    $0x25,%eax
  800453:	75 e2                	jne    800437 <vprintfmt+0x14>
  800455:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800459:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800460:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800467:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	eb 07                	jmp    80047c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8d 47 01             	lea    0x1(%edi),%eax
  80047f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800482:	0f b6 07             	movzbl (%edi),%eax
  800485:	0f b6 c8             	movzbl %al,%ecx
  800488:	83 e8 23             	sub    $0x23,%eax
  80048b:	3c 55                	cmp    $0x55,%al
  80048d:	0f 87 21 03 00 00    	ja     8007b4 <vprintfmt+0x391>
  800493:	0f b6 c0             	movzbl %al,%eax
  800496:	ff 24 85 40 2b 80 00 	jmp    *0x802b40(,%eax,4)
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a4:	eb d6                	jmp    80047c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004be:	83 fa 09             	cmp    $0x9,%edx
  8004c1:	77 39                	ja     8004fc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c6:	eb e9                	jmp    8004b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d9:	eb 27                	jmp    800502 <vprintfmt+0xdf>
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e5:	0f 49 c8             	cmovns %eax,%ecx
  8004e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	eb 8c                	jmp    80047c <vprintfmt+0x59>
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004fa:	eb 80                	jmp    80047c <vprintfmt+0x59>
  8004fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ff:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800502:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800506:	0f 89 70 ff ff ff    	jns    80047c <vprintfmt+0x59>
				width = precision, precision = -1;
  80050c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800512:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800519:	e9 5e ff ff ff       	jmp    80047c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800524:	e9 53 ff ff ff       	jmp    80047c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 50 04             	lea    0x4(%eax),%edx
  80052f:	89 55 14             	mov    %edx,0x14(%ebp)
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 30                	pushl  (%eax)
  800538:	ff d6                	call   *%esi
			break;
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800540:	e9 04 ff ff ff       	jmp    800449 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	99                   	cltd   
  800551:	31 d0                	xor    %edx,%eax
  800553:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800555:	83 f8 0f             	cmp    $0xf,%eax
  800558:	7f 0b                	jg     800565 <vprintfmt+0x142>
  80055a:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	75 18                	jne    80057d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800565:	50                   	push   %eax
  800566:	68 fb 29 80 00       	push   $0x8029fb
  80056b:	53                   	push   %ebx
  80056c:	56                   	push   %esi
  80056d:	e8 94 fe ff ff       	call   800406 <printfmt>
  800572:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800578:	e9 cc fe ff ff       	jmp    800449 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057d:	52                   	push   %edx
  80057e:	68 31 2f 80 00       	push   $0x802f31
  800583:	53                   	push   %ebx
  800584:	56                   	push   %esi
  800585:	e8 7c fe ff ff       	call   800406 <printfmt>
  80058a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 b4 fe ff ff       	jmp    800449 <vprintfmt+0x26>
  800595:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800598:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059b:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 50 04             	lea    0x4(%eax),%edx
  8005a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a9:	85 ff                	test   %edi,%edi
  8005ab:	ba f4 29 80 00       	mov    $0x8029f4,%edx
  8005b0:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8005b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b7:	0f 84 92 00 00 00    	je     80064f <vprintfmt+0x22c>
  8005bd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005c1:	0f 8e 96 00 00 00    	jle    80065d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	51                   	push   %ecx
  8005cb:	57                   	push   %edi
  8005cc:	e8 86 02 00 00       	call   800857 <strnlen>
  8005d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d4:	29 c1                	sub    %eax,%ecx
  8005d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005dc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	eb 0f                	jmp    8005f9 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	83 ef 01             	sub    $0x1,%edi
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	7f ed                	jg     8005ea <vprintfmt+0x1c7>
  8005fd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800600:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800603:	85 c9                	test   %ecx,%ecx
  800605:	b8 00 00 00 00       	mov    $0x0,%eax
  80060a:	0f 49 c1             	cmovns %ecx,%eax
  80060d:	29 c1                	sub    %eax,%ecx
  80060f:	89 75 08             	mov    %esi,0x8(%ebp)
  800612:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800615:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800618:	89 cb                	mov    %ecx,%ebx
  80061a:	eb 4d                	jmp    800669 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800620:	74 1b                	je     80063d <vprintfmt+0x21a>
  800622:	0f be c0             	movsbl %al,%eax
  800625:	83 e8 20             	sub    $0x20,%eax
  800628:	83 f8 5e             	cmp    $0x5e,%eax
  80062b:	76 10                	jbe    80063d <vprintfmt+0x21a>
					putch('?', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	ff 75 0c             	pushl  0xc(%ebp)
  800633:	6a 3f                	push   $0x3f
  800635:	ff 55 08             	call   *0x8(%ebp)
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	eb 0d                	jmp    80064a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	ff 75 0c             	pushl  0xc(%ebp)
  800643:	52                   	push   %edx
  800644:	ff 55 08             	call   *0x8(%ebp)
  800647:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064a:	83 eb 01             	sub    $0x1,%ebx
  80064d:	eb 1a                	jmp    800669 <vprintfmt+0x246>
  80064f:	89 75 08             	mov    %esi,0x8(%ebp)
  800652:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800655:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800658:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065b:	eb 0c                	jmp    800669 <vprintfmt+0x246>
  80065d:	89 75 08             	mov    %esi,0x8(%ebp)
  800660:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800663:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800666:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800669:	83 c7 01             	add    $0x1,%edi
  80066c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800670:	0f be d0             	movsbl %al,%edx
  800673:	85 d2                	test   %edx,%edx
  800675:	74 23                	je     80069a <vprintfmt+0x277>
  800677:	85 f6                	test   %esi,%esi
  800679:	78 a1                	js     80061c <vprintfmt+0x1f9>
  80067b:	83 ee 01             	sub    $0x1,%esi
  80067e:	79 9c                	jns    80061c <vprintfmt+0x1f9>
  800680:	89 df                	mov    %ebx,%edi
  800682:	8b 75 08             	mov    0x8(%ebp),%esi
  800685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800688:	eb 18                	jmp    8006a2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 20                	push   $0x20
  800690:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800692:	83 ef 01             	sub    $0x1,%edi
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb 08                	jmp    8006a2 <vprintfmt+0x27f>
  80069a:	89 df                	mov    %ebx,%edi
  80069c:	8b 75 08             	mov    0x8(%ebp),%esi
  80069f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	7f e4                	jg     80068a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	e9 9b fd ff ff       	jmp    800449 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ae:	83 fa 01             	cmp    $0x1,%edx
  8006b1:	7e 16                	jle    8006c9 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 50 08             	lea    0x8(%eax),%edx
  8006b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bc:	8b 50 04             	mov    0x4(%eax),%edx
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c7:	eb 32                	jmp    8006fb <vprintfmt+0x2d8>
	else if (lflag)
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	74 18                	je     8006e5 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006db:	89 c1                	mov    %eax,%ecx
  8006dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e3:	eb 16                	jmp    8006fb <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 50 04             	lea    0x4(%eax),%edx
  8006eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f3:	89 c1                	mov    %eax,%ecx
  8006f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800701:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800706:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070a:	79 74                	jns    800780 <vprintfmt+0x35d>
				putch('-', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 2d                	push   $0x2d
  800712:	ff d6                	call   *%esi
				num = -(long long) num;
  800714:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800717:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80071a:	f7 d8                	neg    %eax
  80071c:	83 d2 00             	adc    $0x0,%edx
  80071f:	f7 da                	neg    %edx
  800721:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800724:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800729:	eb 55                	jmp    800780 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 7c fc ff ff       	call   8003af <getuint>
			base = 10;
  800733:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800738:	eb 46                	jmp    800780 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
  80073d:	e8 6d fc ff ff       	call   8003af <getuint>
                        base = 8;
  800742:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800747:	eb 37                	jmp    800780 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 30                	push   $0x30
  80074f:	ff d6                	call   *%esi
			putch('x', putdat);
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 78                	push   $0x78
  800757:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 50 04             	lea    0x4(%eax),%edx
  80075f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800762:	8b 00                	mov    (%eax),%eax
  800764:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800769:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800771:	eb 0d                	jmp    800780 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 34 fc ff ff       	call   8003af <getuint>
			base = 16;
  80077b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800787:	57                   	push   %edi
  800788:	ff 75 e0             	pushl  -0x20(%ebp)
  80078b:	51                   	push   %ecx
  80078c:	52                   	push   %edx
  80078d:	50                   	push   %eax
  80078e:	89 da                	mov    %ebx,%edx
  800790:	89 f0                	mov    %esi,%eax
  800792:	e8 6e fb ff ff       	call   800305 <printnum>
			break;
  800797:	83 c4 20             	add    $0x20,%esp
  80079a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079d:	e9 a7 fc ff ff       	jmp    800449 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	51                   	push   %ecx
  8007a7:	ff d6                	call   *%esi
			break;
  8007a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007af:	e9 95 fc ff ff       	jmp    800449 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 25                	push   $0x25
  8007ba:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	eb 03                	jmp    8007c4 <vprintfmt+0x3a1>
  8007c1:	83 ef 01             	sub    $0x1,%edi
  8007c4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c8:	75 f7                	jne    8007c1 <vprintfmt+0x39e>
  8007ca:	e9 7a fc ff ff       	jmp    800449 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5f                   	pop    %edi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 18             	sub    $0x18,%esp
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	74 26                	je     80081e <vsnprintf+0x47>
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	7e 22                	jle    80081e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fc:	ff 75 14             	pushl  0x14(%ebp)
  8007ff:	ff 75 10             	pushl  0x10(%ebp)
  800802:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800805:	50                   	push   %eax
  800806:	68 e9 03 80 00       	push   $0x8003e9
  80080b:	e8 13 fc ff ff       	call   800423 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800810:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800813:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800816:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	eb 05                	jmp    800823 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082e:	50                   	push   %eax
  80082f:	ff 75 10             	pushl  0x10(%ebp)
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	ff 75 08             	pushl  0x8(%ebp)
  800838:	e8 9a ff ff ff       	call   8007d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	eb 03                	jmp    80084f <strlen+0x10>
		n++;
  80084c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800853:	75 f7                	jne    80084c <strlen+0xd>
		n++;
	return n;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800860:	ba 00 00 00 00       	mov    $0x0,%edx
  800865:	eb 03                	jmp    80086a <strnlen+0x13>
		n++;
  800867:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086a:	39 c2                	cmp    %eax,%edx
  80086c:	74 08                	je     800876 <strnlen+0x1f>
  80086e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800872:	75 f3                	jne    800867 <strnlen+0x10>
  800874:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800882:	89 c2                	mov    %eax,%edx
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	83 c1 01             	add    $0x1,%ecx
  80088a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800891:	84 db                	test   %bl,%bl
  800893:	75 ef                	jne    800884 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089f:	53                   	push   %ebx
  8008a0:	e8 9a ff ff ff       	call   80083f <strlen>
  8008a5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	01 d8                	add    %ebx,%eax
  8008ad:	50                   	push   %eax
  8008ae:	e8 c5 ff ff ff       	call   800878 <strcpy>
	return dst;
}
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c5:	89 f3                	mov    %esi,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ca:	89 f2                	mov    %esi,%edx
  8008cc:	eb 0f                	jmp    8008dd <strncpy+0x23>
		*dst++ = *src;
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	0f b6 01             	movzbl (%ecx),%eax
  8008d4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d7:	80 39 01             	cmpb   $0x1,(%ecx)
  8008da:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	39 da                	cmp    %ebx,%edx
  8008df:	75 ed                	jne    8008ce <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f2:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f7:	85 d2                	test   %edx,%edx
  8008f9:	74 21                	je     80091c <strlcpy+0x35>
  8008fb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ff:	89 f2                	mov    %esi,%edx
  800901:	eb 09                	jmp    80090c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800903:	83 c2 01             	add    $0x1,%edx
  800906:	83 c1 01             	add    $0x1,%ecx
  800909:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090c:	39 c2                	cmp    %eax,%edx
  80090e:	74 09                	je     800919 <strlcpy+0x32>
  800910:	0f b6 19             	movzbl (%ecx),%ebx
  800913:	84 db                	test   %bl,%bl
  800915:	75 ec                	jne    800903 <strlcpy+0x1c>
  800917:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800919:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091c:	29 f0                	sub    %esi,%eax
}
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092b:	eb 06                	jmp    800933 <strcmp+0x11>
		p++, q++;
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800933:	0f b6 01             	movzbl (%ecx),%eax
  800936:	84 c0                	test   %al,%al
  800938:	74 04                	je     80093e <strcmp+0x1c>
  80093a:	3a 02                	cmp    (%edx),%al
  80093c:	74 ef                	je     80092d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093e:	0f b6 c0             	movzbl %al,%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800952:	89 c3                	mov    %eax,%ebx
  800954:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800957:	eb 06                	jmp    80095f <strncmp+0x17>
		n--, p++, q++;
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095f:	39 d8                	cmp    %ebx,%eax
  800961:	74 15                	je     800978 <strncmp+0x30>
  800963:	0f b6 08             	movzbl (%eax),%ecx
  800966:	84 c9                	test   %cl,%cl
  800968:	74 04                	je     80096e <strncmp+0x26>
  80096a:	3a 0a                	cmp    (%edx),%cl
  80096c:	74 eb                	je     800959 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096e:	0f b6 00             	movzbl (%eax),%eax
  800971:	0f b6 12             	movzbl (%edx),%edx
  800974:	29 d0                	sub    %edx,%eax
  800976:	eb 05                	jmp    80097d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098a:	eb 07                	jmp    800993 <strchr+0x13>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	74 0f                	je     80099f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	0f b6 10             	movzbl (%eax),%edx
  800996:	84 d2                	test   %dl,%dl
  800998:	75 f2                	jne    80098c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ab:	eb 03                	jmp    8009b0 <strfind+0xf>
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b3:	84 d2                	test   %dl,%dl
  8009b5:	74 04                	je     8009bb <strfind+0x1a>
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	75 f2                	jne    8009ad <strfind+0xc>
			break;
	return (char *) s;
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c9:	85 c9                	test   %ecx,%ecx
  8009cb:	74 36                	je     800a03 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d3:	75 28                	jne    8009fd <memset+0x40>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 23                	jne    8009fd <memset+0x40>
		c &= 0xFF;
  8009da:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009de:	89 d3                	mov    %edx,%ebx
  8009e0:	c1 e3 08             	shl    $0x8,%ebx
  8009e3:	89 d6                	mov    %edx,%esi
  8009e5:	c1 e6 18             	shl    $0x18,%esi
  8009e8:	89 d0                	mov    %edx,%eax
  8009ea:	c1 e0 10             	shl    $0x10,%eax
  8009ed:	09 f0                	or     %esi,%eax
  8009ef:	09 c2                	or     %eax,%edx
  8009f1:	89 d0                	mov    %edx,%eax
  8009f3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f8:	fc                   	cld    
  8009f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fb:	eb 06                	jmp    800a03 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a00:	fc                   	cld    
  800a01:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a03:	89 f8                	mov    %edi,%eax
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a18:	39 c6                	cmp    %eax,%esi
  800a1a:	73 35                	jae    800a51 <memmove+0x47>
  800a1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	73 2e                	jae    800a51 <memmove+0x47>
		s += n;
		d += n;
  800a23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a26:	89 d6                	mov    %edx,%esi
  800a28:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a30:	75 13                	jne    800a45 <memmove+0x3b>
  800a32:	f6 c1 03             	test   $0x3,%cl
  800a35:	75 0e                	jne    800a45 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a37:	83 ef 04             	sub    $0x4,%edi
  800a3a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a40:	fd                   	std    
  800a41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a43:	eb 09                	jmp    800a4e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a45:	83 ef 01             	sub    $0x1,%edi
  800a48:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4b:	fd                   	std    
  800a4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4e:	fc                   	cld    
  800a4f:	eb 1d                	jmp    800a6e <memmove+0x64>
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a55:	f6 c2 03             	test   $0x3,%dl
  800a58:	75 0f                	jne    800a69 <memmove+0x5f>
  800a5a:	f6 c1 03             	test   $0x3,%cl
  800a5d:	75 0a                	jne    800a69 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a67:	eb 05                	jmp    800a6e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a69:	89 c7                	mov    %eax,%edi
  800a6b:	fc                   	cld    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a75:	ff 75 10             	pushl  0x10(%ebp)
  800a78:	ff 75 0c             	pushl  0xc(%ebp)
  800a7b:	ff 75 08             	pushl  0x8(%ebp)
  800a7e:	e8 87 ff ff ff       	call   800a0a <memmove>
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a90:	89 c6                	mov    %eax,%esi
  800a92:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a95:	eb 1a                	jmp    800ab1 <memcmp+0x2c>
		if (*s1 != *s2)
  800a97:	0f b6 08             	movzbl (%eax),%ecx
  800a9a:	0f b6 1a             	movzbl (%edx),%ebx
  800a9d:	38 d9                	cmp    %bl,%cl
  800a9f:	74 0a                	je     800aab <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa1:	0f b6 c1             	movzbl %cl,%eax
  800aa4:	0f b6 db             	movzbl %bl,%ebx
  800aa7:	29 d8                	sub    %ebx,%eax
  800aa9:	eb 0f                	jmp    800aba <memcmp+0x35>
		s1++, s2++;
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	39 f0                	cmp    %esi,%eax
  800ab3:	75 e2                	jne    800a97 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800acc:	eb 07                	jmp    800ad5 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	38 08                	cmp    %cl,(%eax)
  800ad0:	74 07                	je     800ad9 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	39 d0                	cmp    %edx,%eax
  800ad7:	72 f5                	jb     800ace <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae7:	eb 03                	jmp    800aec <strtol+0x11>
		s++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aec:	0f b6 01             	movzbl (%ecx),%eax
  800aef:	3c 09                	cmp    $0x9,%al
  800af1:	74 f6                	je     800ae9 <strtol+0xe>
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f2                	je     800ae9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af7:	3c 2b                	cmp    $0x2b,%al
  800af9:	75 0a                	jne    800b05 <strtol+0x2a>
		s++;
  800afb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afe:	bf 00 00 00 00       	mov    $0x0,%edi
  800b03:	eb 10                	jmp    800b15 <strtol+0x3a>
  800b05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0a:	3c 2d                	cmp    $0x2d,%al
  800b0c:	75 07                	jne    800b15 <strtol+0x3a>
		s++, neg = 1;
  800b0e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b11:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b15:	85 db                	test   %ebx,%ebx
  800b17:	0f 94 c0             	sete   %al
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 19                	jne    800b3b <strtol+0x60>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 14                	jne    800b3b <strtol+0x60>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	0f 85 82 00 00 00    	jne    800bb3 <strtol+0xd8>
		s += 2, base = 16;
  800b31:	83 c1 02             	add    $0x2,%ecx
  800b34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b39:	eb 16                	jmp    800b51 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b3b:	84 c0                	test   %al,%al
  800b3d:	74 12                	je     800b51 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	80 39 30             	cmpb   $0x30,(%ecx)
  800b47:	75 08                	jne    800b51 <strtol+0x76>
		s++, base = 8;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b59:	0f b6 11             	movzbl (%ecx),%edx
  800b5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5f:	89 f3                	mov    %esi,%ebx
  800b61:	80 fb 09             	cmp    $0x9,%bl
  800b64:	77 08                	ja     800b6e <strtol+0x93>
			dig = *s - '0';
  800b66:	0f be d2             	movsbl %dl,%edx
  800b69:	83 ea 30             	sub    $0x30,%edx
  800b6c:	eb 22                	jmp    800b90 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b71:	89 f3                	mov    %esi,%ebx
  800b73:	80 fb 19             	cmp    $0x19,%bl
  800b76:	77 08                	ja     800b80 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b78:	0f be d2             	movsbl %dl,%edx
  800b7b:	83 ea 57             	sub    $0x57,%edx
  800b7e:	eb 10                	jmp    800b90 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b83:	89 f3                	mov    %esi,%ebx
  800b85:	80 fb 19             	cmp    $0x19,%bl
  800b88:	77 16                	ja     800ba0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b8a:	0f be d2             	movsbl %dl,%edx
  800b8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b93:	7d 0f                	jge    800ba4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b95:	83 c1 01             	add    $0x1,%ecx
  800b98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9e:	eb b9                	jmp    800b59 <strtol+0x7e>
  800ba0:	89 c2                	mov    %eax,%edx
  800ba2:	eb 02                	jmp    800ba6 <strtol+0xcb>
  800ba4:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 0d                	je     800bb9 <strtol+0xde>
		*endptr = (char *) s;
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	89 0e                	mov    %ecx,(%esi)
  800bb1:	eb 06                	jmp    800bb9 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb3:	84 c0                	test   %al,%al
  800bb5:	75 92                	jne    800b49 <strtol+0x6e>
  800bb7:	eb 98                	jmp    800b51 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bb9:	f7 da                	neg    %edx
  800bbb:	85 ff                	test   %edi,%edi
  800bbd:	0f 45 c2             	cmovne %edx,%eax
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	89 c3                	mov    %eax,%ebx
  800bd8:	89 c7                	mov    %eax,%edi
  800bda:	89 c6                	mov    %eax,%esi
  800bdc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bee:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf3:	89 d1                	mov    %edx,%ecx
  800bf5:	89 d3                	mov    %edx,%ebx
  800bf7:	89 d7                	mov    %edx,%edi
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c10:	b8 03 00 00 00       	mov    $0x3,%eax
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 cb                	mov    %ecx,%ebx
  800c1a:	89 cf                	mov    %ecx,%edi
  800c1c:	89 ce                	mov    %ecx,%esi
  800c1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 03                	push   $0x3
  800c2a:	68 1f 2d 80 00       	push   $0x802d1f
  800c2f:	6a 22                	push   $0x22
  800c31:	68 3c 2d 80 00       	push   $0x802d3c
  800c36:	e8 dd f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_yield>:

void
sys_yield(void)
{      
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c68:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c72:	89 d1                	mov    %edx,%ecx
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	89 d7                	mov    %edx,%edi
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c8a:	be 00 00 00 00       	mov    $0x0,%esi
  800c8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	89 f7                	mov    %esi,%edi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 04                	push   $0x4
  800cab:	68 1f 2d 80 00       	push   $0x802d1f
  800cb0:	6a 22                	push   $0x22
  800cb2:	68 3c 2d 80 00       	push   $0x802d3c
  800cb7:	e8 5c f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ccd:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cde:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 05                	push   $0x5
  800ced:	68 1f 2d 80 00       	push   $0x802d1f
  800cf2:	6a 22                	push   $0x22
  800cf4:	68 3c 2d 80 00       	push   $0x802d3c
  800cf9:	e8 1a f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d14:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800d27:	7e 17                	jle    800d40 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 06                	push   $0x6
  800d2f:	68 1f 2d 80 00       	push   $0x802d1f
  800d34:	6a 22                	push   $0x22
  800d36:	68 3c 2d 80 00       	push   $0x802d3c
  800d3b:	e8 d8 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d56:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800d69:	7e 17                	jle    800d82 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 08                	push   $0x8
  800d71:	68 1f 2d 80 00       	push   $0x802d1f
  800d76:	6a 22                	push   $0x22
  800d78:	68 3c 2d 80 00       	push   $0x802d3c
  800d7d:	e8 96 f4 ff ff       	call   800218 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 09                	push   $0x9
  800db3:	68 1f 2d 80 00       	push   $0x802d1f
  800db8:	6a 22                	push   $0x22
  800dba:	68 3c 2d 80 00       	push   $0x802d3c
  800dbf:	e8 54 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0a                	push   $0xa
  800df5:	68 1f 2d 80 00       	push   $0x802d1f
  800dfa:	6a 22                	push   $0x22
  800dfc:	68 3c 2d 80 00       	push   $0x802d3c
  800e01:	e8 12 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e14:	be 00 00 00 00       	mov    $0x0,%esi
  800e19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 17                	jle    800e6a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 0d                	push   $0xd
  800e59:	68 1f 2d 80 00       	push   $0x802d1f
  800e5e:	6a 22                	push   $0x22
  800e60:	68 3c 2d 80 00       	push   $0x802d3c
  800e65:	e8 ae f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e78:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e82:	89 d1                	mov    %edx,%ecx
  800e84:	89 d3                	mov    %edx,%ebx
  800e86:	89 d7                	mov    %edx,%edi
  800e88:	89 d6                	mov    %edx,%esi
  800e8a:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 cb                	mov    %ecx,%ebx
  800ea9:	89 cf                	mov    %ecx,%edi
  800eab:	89 ce                	mov    %ecx,%esi
  800ead:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7e 17                	jle    800eca <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	50                   	push   %eax
  800eb7:	6a 0f                	push   $0xf
  800eb9:	68 1f 2d 80 00       	push   $0x802d1f
  800ebe:	6a 22                	push   $0x22
  800ec0:	68 3c 2d 80 00       	push   $0x802d3c
  800ec5:	e8 4e f3 ff ff       	call   800218 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <sys_recv>:

int
sys_recv(void *addr)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800edb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee0:	b8 10 00 00 00       	mov    $0x10,%eax
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	89 cb                	mov    %ecx,%ebx
  800eea:	89 cf                	mov    %ecx,%edi
  800eec:	89 ce                	mov    %ecx,%esi
  800eee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	7e 17                	jle    800f0b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	50                   	push   %eax
  800ef8:	6a 10                	push   $0x10
  800efa:	68 1f 2d 80 00       	push   $0x802d1f
  800eff:	6a 22                	push   $0x22
  800f01:	68 3c 2d 80 00       	push   $0x802d3c
  800f06:	e8 0d f3 ff ff       	call   800218 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	53                   	push   %ebx
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f1d:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f1f:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f23:	74 2e                	je     800f53 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	c1 ea 16             	shr    $0x16,%edx
  800f2a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f31:	f6 c2 01             	test   $0x1,%dl
  800f34:	74 1d                	je     800f53 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f36:	89 c2                	mov    %eax,%edx
  800f38:	c1 ea 0c             	shr    $0xc,%edx
  800f3b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f42:	f6 c1 01             	test   $0x1,%cl
  800f45:	74 0c                	je     800f53 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f4e:	f6 c6 08             	test   $0x8,%dh
  800f51:	75 14                	jne    800f67 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	68 4c 2d 80 00       	push   $0x802d4c
  800f5b:	6a 21                	push   $0x21
  800f5d:	68 df 2d 80 00       	push   $0x802ddf
  800f62:	e8 b1 f2 ff ff       	call   800218 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800f67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f6c:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	6a 07                	push   $0x7
  800f73:	68 00 f0 7f 00       	push   $0x7ff000
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 02 fd ff ff       	call   800c81 <sys_page_alloc>
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	79 14                	jns    800f9a <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	68 ea 2d 80 00       	push   $0x802dea
  800f8e:	6a 2b                	push   $0x2b
  800f90:	68 df 2d 80 00       	push   $0x802ddf
  800f95:	e8 7e f2 ff ff       	call   800218 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 00 10 00 00       	push   $0x1000
  800fa2:	53                   	push   %ebx
  800fa3:	68 00 f0 7f 00       	push   $0x7ff000
  800fa8:	e8 5d fa ff ff       	call   800a0a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800fad:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb4:	53                   	push   %ebx
  800fb5:	6a 00                	push   $0x0
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 01 fd ff ff       	call   800cc4 <sys_page_map>
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 14                	jns    800fde <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 00 2e 80 00       	push   $0x802e00
  800fd2:	6a 2e                	push   $0x2e
  800fd4:	68 df 2d 80 00       	push   $0x802ddf
  800fd9:	e8 3a f2 ff ff       	call   800218 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	68 00 f0 7f 00       	push   $0x7ff000
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 19 fd ff ff       	call   800d06 <sys_page_unmap>
  800fed:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800ffe:	68 13 0f 80 00       	push   $0x800f13
  801003:	e8 e1 13 00 00       	call   8023e9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801008:	b8 07 00 00 00       	mov    $0x7,%eax
  80100d:	cd 30                	int    $0x30
  80100f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 12                	jns    80102b <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801019:	50                   	push   %eax
  80101a:	68 14 2e 80 00       	push   $0x802e14
  80101f:	6a 6d                	push   $0x6d
  801021:	68 df 2d 80 00       	push   $0x802ddf
  801026:	e8 ed f1 ff ff       	call   800218 <_panic>
  80102b:	89 c7                	mov    %eax,%edi
  80102d:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  801032:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801036:	75 21                	jne    801059 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801038:	e8 06 fc ff ff       	call   800c43 <sys_getenvid>
  80103d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801042:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801045:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80104a:	a3 40 54 80 00       	mov    %eax,0x805440
		return 0;
  80104f:	b8 00 00 00 00       	mov    $0x0,%eax
  801054:	e9 9c 01 00 00       	jmp    8011f5 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	c1 e8 16             	shr    $0x16,%eax
  80105e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801065:	a8 01                	test   $0x1,%al
  801067:	0f 84 f3 00 00 00    	je     801160 <fork+0x16b>
  80106d:	89 d8                	mov    %ebx,%eax
  80106f:	c1 e8 0c             	shr    $0xc,%eax
  801072:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801079:	f6 c2 01             	test   $0x1,%dl
  80107c:	0f 84 de 00 00 00    	je     801160 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  801082:	89 c6                	mov    %eax,%esi
  801084:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801087:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108e:	f6 c6 04             	test   $0x4,%dh
  801091:	74 37                	je     8010ca <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801093:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a2:	50                   	push   %eax
  8010a3:	56                   	push   %esi
  8010a4:	57                   	push   %edi
  8010a5:	56                   	push   %esi
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 17 fc ff ff       	call   800cc4 <sys_page_map>
  8010ad:	83 c4 20             	add    $0x20,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	0f 89 a8 00 00 00    	jns    801160 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  8010b8:	50                   	push   %eax
  8010b9:	68 70 2d 80 00       	push   $0x802d70
  8010be:	6a 49                	push   $0x49
  8010c0:	68 df 2d 80 00       	push   $0x802ddf
  8010c5:	e8 4e f1 ff ff       	call   800218 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8010ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d1:	f6 c6 08             	test   $0x8,%dh
  8010d4:	75 0b                	jne    8010e1 <fork+0xec>
  8010d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010dd:	a8 02                	test   $0x2,%al
  8010df:	74 57                	je     801138 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	68 05 08 00 00       	push   $0x805
  8010e9:	56                   	push   %esi
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 d1 fb ff ff       	call   800cc4 <sys_page_map>
  8010f3:	83 c4 20             	add    $0x20,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 12                	jns    80110c <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  8010fa:	50                   	push   %eax
  8010fb:	68 70 2d 80 00       	push   $0x802d70
  801100:	6a 4c                	push   $0x4c
  801102:	68 df 2d 80 00       	push   $0x802ddf
  801107:	e8 0c f1 ff ff       	call   800218 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	68 05 08 00 00       	push   $0x805
  801114:	56                   	push   %esi
  801115:	6a 00                	push   $0x0
  801117:	56                   	push   %esi
  801118:	6a 00                	push   $0x0
  80111a:	e8 a5 fb ff ff       	call   800cc4 <sys_page_map>
  80111f:	83 c4 20             	add    $0x20,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	79 3a                	jns    801160 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801126:	50                   	push   %eax
  801127:	68 94 2d 80 00       	push   $0x802d94
  80112c:	6a 4e                	push   $0x4e
  80112e:	68 df 2d 80 00       	push   $0x802ddf
  801133:	e8 e0 f0 ff ff       	call   800218 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	6a 05                	push   $0x5
  80113d:	56                   	push   %esi
  80113e:	57                   	push   %edi
  80113f:	56                   	push   %esi
  801140:	6a 00                	push   $0x0
  801142:	e8 7d fb ff ff       	call   800cc4 <sys_page_map>
  801147:	83 c4 20             	add    $0x20,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	79 12                	jns    801160 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80114e:	50                   	push   %eax
  80114f:	68 bc 2d 80 00       	push   $0x802dbc
  801154:	6a 50                	push   $0x50
  801156:	68 df 2d 80 00       	push   $0x802ddf
  80115b:	e8 b8 f0 ff ff       	call   800218 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801160:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801166:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80116c:	0f 85 e7 fe ff ff    	jne    801059 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	6a 07                	push   $0x7
  801177:	68 00 f0 bf ee       	push   $0xeebff000
  80117c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117f:	e8 fd fa ff ff       	call   800c81 <sys_page_alloc>
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 14                	jns    80119f <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80118b:	83 ec 04             	sub    $0x4,%esp
  80118e:	68 24 2e 80 00       	push   $0x802e24
  801193:	6a 76                	push   $0x76
  801195:	68 df 2d 80 00       	push   $0x802ddf
  80119a:	e8 79 f0 ff ff       	call   800218 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	68 58 24 80 00       	push   $0x802458
  8011a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011aa:	e8 1d fc ff ff       	call   800dcc <sys_env_set_pgfault_upcall>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	79 14                	jns    8011ca <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8011b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b9:	68 3e 2e 80 00       	push   $0x802e3e
  8011be:	6a 79                	push   $0x79
  8011c0:	68 df 2d 80 00       	push   $0x802ddf
  8011c5:	e8 4e f0 ff ff       	call   800218 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	6a 02                	push   $0x2
  8011cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d2:	e8 71 fb ff ff       	call   800d48 <sys_env_set_status>
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	79 14                	jns    8011f2 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8011de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e1:	68 5b 2e 80 00       	push   $0x802e5b
  8011e6:	6a 7b                	push   $0x7b
  8011e8:	68 df 2d 80 00       	push   $0x802ddf
  8011ed:	e8 26 f0 ff ff       	call   800218 <_panic>
        return forkid;
  8011f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8011f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <sfork>:

// Challenge!
int
sfork(void)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801203:	68 72 2e 80 00       	push   $0x802e72
  801208:	68 83 00 00 00       	push   $0x83
  80120d:	68 df 2d 80 00       	push   $0x802ddf
  801212:	e8 01 f0 ff ff       	call   800218 <_panic>

00801217 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
  80121d:	05 00 00 00 30       	add    $0x30000000,%eax
  801222:	c1 e8 0c             	shr    $0xc,%eax
}
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801232:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801237:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801244:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 16             	shr    $0x16,%edx
  80124e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	74 11                	je     80126b <fd_alloc+0x2d>
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 0c             	shr    $0xc,%edx
  80125f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	75 09                	jne    801274 <fd_alloc+0x36>
			*fd_store = fd;
  80126b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126d:	b8 00 00 00 00       	mov    $0x0,%eax
  801272:	eb 17                	jmp    80128b <fd_alloc+0x4d>
  801274:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801279:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127e:	75 c9                	jne    801249 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801280:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801286:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801293:	83 f8 1f             	cmp    $0x1f,%eax
  801296:	77 36                	ja     8012ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801298:	c1 e0 0c             	shl    $0xc,%eax
  80129b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 16             	shr    $0x16,%edx
  8012a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 24                	je     8012d5 <fd_lookup+0x48>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 0c             	shr    $0xc,%edx
  8012b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	74 1a                	je     8012dc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c5:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	eb 13                	jmp    8012e1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d3:	eb 0c                	jmp    8012e1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012da:	eb 05                	jmp    8012e1 <fd_lookup+0x54>
  8012dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f1:	eb 13                	jmp    801306 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8012f3:	39 08                	cmp    %ecx,(%eax)
  8012f5:	75 0c                	jne    801303 <dev_lookup+0x20>
			*dev = devtab[i];
  8012f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	eb 36                	jmp    801339 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801303:	83 c2 01             	add    $0x1,%edx
  801306:	8b 04 95 04 2f 80 00 	mov    0x802f04(,%edx,4),%eax
  80130d:	85 c0                	test   %eax,%eax
  80130f:	75 e2                	jne    8012f3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801311:	a1 40 54 80 00       	mov    0x805440,%eax
  801316:	8b 40 48             	mov    0x48(%eax),%eax
  801319:	83 ec 04             	sub    $0x4,%esp
  80131c:	51                   	push   %ecx
  80131d:	50                   	push   %eax
  80131e:	68 88 2e 80 00       	push   $0x802e88
  801323:	e8 c9 ef ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 10             	sub    $0x10,%esp
  801343:	8b 75 08             	mov    0x8(%ebp),%esi
  801346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801349:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801353:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801356:	50                   	push   %eax
  801357:	e8 31 ff ff ff       	call   80128d <fd_lookup>
  80135c:	83 c4 08             	add    $0x8,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 05                	js     801368 <fd_close+0x2d>
	    || fd != fd2)
  801363:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801366:	74 0c                	je     801374 <fd_close+0x39>
		return (must_exist ? r : 0);
  801368:	84 db                	test   %bl,%bl
  80136a:	ba 00 00 00 00       	mov    $0x0,%edx
  80136f:	0f 44 c2             	cmove  %edx,%eax
  801372:	eb 41                	jmp    8013b5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 36                	pushl  (%esi)
  80137d:	e8 61 ff ff ff       	call   8012e3 <dev_lookup>
  801382:	89 c3                	mov    %eax,%ebx
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 1a                	js     8013a5 <fd_close+0x6a>
		if (dev->dev_close)
  80138b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801391:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801396:	85 c0                	test   %eax,%eax
  801398:	74 0b                	je     8013a5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	56                   	push   %esi
  80139e:	ff d0                	call   *%eax
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	56                   	push   %esi
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 56 f9 ff ff       	call   800d06 <sys_page_unmap>
	return r;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	89 d8                	mov    %ebx,%eax
}
  8013b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	ff 75 08             	pushl  0x8(%ebp)
  8013c9:	e8 bf fe ff ff       	call   80128d <fd_lookup>
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	85 d2                	test   %edx,%edx
  8013d5:	78 10                	js     8013e7 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	6a 01                	push   $0x1
  8013dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8013df:	e8 57 ff ff ff       	call   80133b <fd_close>
  8013e4:	83 c4 10             	add    $0x10,%esp
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <close_all>:

void
close_all(void)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f5:	83 ec 0c             	sub    $0xc,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	e8 be ff ff ff       	call   8013bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fe:	83 c3 01             	add    $0x1,%ebx
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	83 fb 20             	cmp    $0x20,%ebx
  801407:	75 ec                	jne    8013f5 <close_all+0xc>
		close(i);
}
  801409:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	53                   	push   %ebx
  801414:	83 ec 2c             	sub    $0x2c,%esp
  801417:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	ff 75 08             	pushl  0x8(%ebp)
  801421:	e8 67 fe ff ff       	call   80128d <fd_lookup>
  801426:	89 c2                	mov    %eax,%edx
  801428:	83 c4 08             	add    $0x8,%esp
  80142b:	85 d2                	test   %edx,%edx
  80142d:	0f 88 c1 00 00 00    	js     8014f4 <dup+0xe6>
		return r;
	close(newfdnum);
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	56                   	push   %esi
  801437:	e8 80 ff ff ff       	call   8013bc <close>

	newfd = INDEX2FD(newfdnum);
  80143c:	89 f3                	mov    %esi,%ebx
  80143e:	c1 e3 0c             	shl    $0xc,%ebx
  801441:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801447:	83 c4 04             	add    $0x4,%esp
  80144a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144d:	e8 d5 fd ff ff       	call   801227 <fd2data>
  801452:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801454:	89 1c 24             	mov    %ebx,(%esp)
  801457:	e8 cb fd ff ff       	call   801227 <fd2data>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801462:	89 f8                	mov    %edi,%eax
  801464:	c1 e8 16             	shr    $0x16,%eax
  801467:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146e:	a8 01                	test   $0x1,%al
  801470:	74 37                	je     8014a9 <dup+0x9b>
  801472:	89 f8                	mov    %edi,%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
  801477:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	74 26                	je     8014a9 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801483:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148a:	83 ec 0c             	sub    $0xc,%esp
  80148d:	25 07 0e 00 00       	and    $0xe07,%eax
  801492:	50                   	push   %eax
  801493:	ff 75 d4             	pushl  -0x2c(%ebp)
  801496:	6a 00                	push   $0x0
  801498:	57                   	push   %edi
  801499:	6a 00                	push   $0x0
  80149b:	e8 24 f8 ff ff       	call   800cc4 <sys_page_map>
  8014a0:	89 c7                	mov    %eax,%edi
  8014a2:	83 c4 20             	add    $0x20,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 2e                	js     8014d7 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ac:	89 d0                	mov    %edx,%eax
  8014ae:	c1 e8 0c             	shr    $0xc,%eax
  8014b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c0:	50                   	push   %eax
  8014c1:	53                   	push   %ebx
  8014c2:	6a 00                	push   $0x0
  8014c4:	52                   	push   %edx
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 f8 f7 ff ff       	call   800cc4 <sys_page_map>
  8014cc:	89 c7                	mov    %eax,%edi
  8014ce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d3:	85 ff                	test   %edi,%edi
  8014d5:	79 1d                	jns    8014f4 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	53                   	push   %ebx
  8014db:	6a 00                	push   $0x0
  8014dd:	e8 24 f8 ff ff       	call   800d06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e2:	83 c4 08             	add    $0x8,%esp
  8014e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 17 f8 ff ff       	call   800d06 <sys_page_unmap>
	return r;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	89 f8                	mov    %edi,%eax
}
  8014f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 14             	sub    $0x14,%esp
  801503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	53                   	push   %ebx
  80150b:	e8 7d fd ff ff       	call   80128d <fd_lookup>
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	89 c2                	mov    %eax,%edx
  801515:	85 c0                	test   %eax,%eax
  801517:	78 6d                	js     801586 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	ff 30                	pushl  (%eax)
  801525:	e8 b9 fd ff ff       	call   8012e3 <dev_lookup>
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 4c                	js     80157d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801531:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801534:	8b 42 08             	mov    0x8(%edx),%eax
  801537:	83 e0 03             	and    $0x3,%eax
  80153a:	83 f8 01             	cmp    $0x1,%eax
  80153d:	75 21                	jne    801560 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153f:	a1 40 54 80 00       	mov    0x805440,%eax
  801544:	8b 40 48             	mov    0x48(%eax),%eax
  801547:	83 ec 04             	sub    $0x4,%esp
  80154a:	53                   	push   %ebx
  80154b:	50                   	push   %eax
  80154c:	68 c9 2e 80 00       	push   $0x802ec9
  801551:	e8 9b ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155e:	eb 26                	jmp    801586 <read+0x8a>
	}
	if (!dev->dev_read)
  801560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801563:	8b 40 08             	mov    0x8(%eax),%eax
  801566:	85 c0                	test   %eax,%eax
  801568:	74 17                	je     801581 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	ff 75 10             	pushl  0x10(%ebp)
  801570:	ff 75 0c             	pushl  0xc(%ebp)
  801573:	52                   	push   %edx
  801574:	ff d0                	call   *%eax
  801576:	89 c2                	mov    %eax,%edx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	eb 09                	jmp    801586 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	eb 05                	jmp    801586 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801581:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801586:	89 d0                	mov    %edx,%eax
  801588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	57                   	push   %edi
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	8b 7d 08             	mov    0x8(%ebp),%edi
  801599:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a1:	eb 21                	jmp    8015c4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	89 f0                	mov    %esi,%eax
  8015a8:	29 d8                	sub    %ebx,%eax
  8015aa:	50                   	push   %eax
  8015ab:	89 d8                	mov    %ebx,%eax
  8015ad:	03 45 0c             	add    0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	57                   	push   %edi
  8015b2:	e8 45 ff ff ff       	call   8014fc <read>
		if (m < 0)
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 0c                	js     8015ca <readn+0x3d>
			return m;
		if (m == 0)
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 06                	je     8015c8 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c2:	01 c3                	add    %eax,%ebx
  8015c4:	39 f3                	cmp    %esi,%ebx
  8015c6:	72 db                	jb     8015a3 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015c8:	89 d8                	mov    %ebx,%eax
}
  8015ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5f                   	pop    %edi
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 14             	sub    $0x14,%esp
  8015d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	53                   	push   %ebx
  8015e1:	e8 a7 fc ff ff       	call   80128d <fd_lookup>
  8015e6:	83 c4 08             	add    $0x8,%esp
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 68                	js     801657 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f9:	ff 30                	pushl  (%eax)
  8015fb:	e8 e3 fc ff ff       	call   8012e3 <dev_lookup>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 47                	js     80164e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801607:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160e:	75 21                	jne    801631 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801610:	a1 40 54 80 00       	mov    0x805440,%eax
  801615:	8b 40 48             	mov    0x48(%eax),%eax
  801618:	83 ec 04             	sub    $0x4,%esp
  80161b:	53                   	push   %ebx
  80161c:	50                   	push   %eax
  80161d:	68 e5 2e 80 00       	push   $0x802ee5
  801622:	e8 ca ec ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162f:	eb 26                	jmp    801657 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801631:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801634:	8b 52 0c             	mov    0xc(%edx),%edx
  801637:	85 d2                	test   %edx,%edx
  801639:	74 17                	je     801652 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	ff 75 10             	pushl  0x10(%ebp)
  801641:	ff 75 0c             	pushl  0xc(%ebp)
  801644:	50                   	push   %eax
  801645:	ff d2                	call   *%edx
  801647:	89 c2                	mov    %eax,%edx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	eb 09                	jmp    801657 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164e:	89 c2                	mov    %eax,%edx
  801650:	eb 05                	jmp    801657 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801652:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801657:	89 d0                	mov    %edx,%eax
  801659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <seek>:

int
seek(int fdnum, off_t offset)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801664:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	ff 75 08             	pushl  0x8(%ebp)
  80166b:	e8 1d fc ff ff       	call   80128d <fd_lookup>
  801670:	83 c4 08             	add    $0x8,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 0e                	js     801685 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801677:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 14             	sub    $0x14,%esp
  80168e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	53                   	push   %ebx
  801696:	e8 f2 fb ff ff       	call   80128d <fd_lookup>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 65                	js     801709 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	ff 30                	pushl  (%eax)
  8016b0:	e8 2e fc ff ff       	call   8012e3 <dev_lookup>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 44                	js     801700 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c3:	75 21                	jne    8016e6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c5:	a1 40 54 80 00       	mov    0x805440,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ca:	8b 40 48             	mov    0x48(%eax),%eax
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	50                   	push   %eax
  8016d2:	68 a8 2e 80 00       	push   $0x802ea8
  8016d7:	e8 15 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e4:	eb 23                	jmp    801709 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e9:	8b 52 18             	mov    0x18(%edx),%edx
  8016ec:	85 d2                	test   %edx,%edx
  8016ee:	74 14                	je     801704 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	50                   	push   %eax
  8016f7:	ff d2                	call   *%edx
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	eb 09                	jmp    801709 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801700:	89 c2                	mov    %eax,%edx
  801702:	eb 05                	jmp    801709 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801704:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801709:	89 d0                	mov    %edx,%eax
  80170b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	53                   	push   %ebx
  801714:	83 ec 14             	sub    $0x14,%esp
  801717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	ff 75 08             	pushl  0x8(%ebp)
  801721:	e8 67 fb ff ff       	call   80128d <fd_lookup>
  801726:	83 c4 08             	add    $0x8,%esp
  801729:	89 c2                	mov    %eax,%edx
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 58                	js     801787 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801739:	ff 30                	pushl  (%eax)
  80173b:	e8 a3 fb ff ff       	call   8012e3 <dev_lookup>
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	85 c0                	test   %eax,%eax
  801745:	78 37                	js     80177e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174e:	74 32                	je     801782 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801750:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801753:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80175a:	00 00 00 
	stat->st_isdir = 0;
  80175d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801764:	00 00 00 
	stat->st_dev = dev;
  801767:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	53                   	push   %ebx
  801771:	ff 75 f0             	pushl  -0x10(%ebp)
  801774:	ff 50 14             	call   *0x14(%eax)
  801777:	89 c2                	mov    %eax,%edx
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	eb 09                	jmp    801787 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177e:	89 c2                	mov    %eax,%edx
  801780:	eb 05                	jmp    801787 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801782:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801787:	89 d0                	mov    %edx,%eax
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	6a 00                	push   $0x0
  801798:	ff 75 08             	pushl  0x8(%ebp)
  80179b:	e8 09 02 00 00       	call   8019a9 <open>
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	85 db                	test   %ebx,%ebx
  8017a7:	78 1b                	js     8017c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	ff 75 0c             	pushl  0xc(%ebp)
  8017af:	53                   	push   %ebx
  8017b0:	e8 5b ff ff ff       	call   801710 <fstat>
  8017b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b7:	89 1c 24             	mov    %ebx,(%esp)
  8017ba:	e8 fd fb ff ff       	call   8013bc <close>
	return r;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	89 f0                	mov    %esi,%eax
}
  8017c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	56                   	push   %esi
  8017cf:	53                   	push   %ebx
  8017d0:	89 c6                	mov    %eax,%esi
  8017d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8017db:	75 12                	jne    8017ef <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	6a 01                	push   $0x1
  8017e2:	e8 52 0d 00 00       	call   802539 <ipc_find_env>
  8017e7:	a3 00 50 80 00       	mov    %eax,0x805000
  8017ec:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ef:	6a 07                	push   $0x7
  8017f1:	68 00 60 80 00       	push   $0x806000
  8017f6:	56                   	push   %esi
  8017f7:	ff 35 00 50 80 00    	pushl  0x805000
  8017fd:	e8 e3 0c 00 00       	call   8024e5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801802:	83 c4 0c             	add    $0xc,%esp
  801805:	6a 00                	push   $0x0
  801807:	53                   	push   %ebx
  801808:	6a 00                	push   $0x0
  80180a:	e8 6d 0c 00 00       	call   80247c <ipc_recv>
}
  80180f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181c:	8b 45 08             	mov    0x8(%ebp),%eax
  80181f:	8b 40 0c             	mov    0xc(%eax),%eax
  801822:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 02 00 00 00       	mov    $0x2,%eax
  801839:	e8 8d ff ff ff       	call   8017cb <fsipc>
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	8b 40 0c             	mov    0xc(%eax),%eax
  80184c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 06 00 00 00       	mov    $0x6,%eax
  80185b:	e8 6b ff ff ff       	call   8017cb <fsipc>
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 40 0c             	mov    0xc(%eax),%eax
  801872:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 05 00 00 00       	mov    $0x5,%eax
  801881:	e8 45 ff ff ff       	call   8017cb <fsipc>
  801886:	89 c2                	mov    %eax,%edx
  801888:	85 d2                	test   %edx,%edx
  80188a:	78 2c                	js     8018b8 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	68 00 60 80 00       	push   $0x806000
  801894:	53                   	push   %ebx
  801895:	e8 de ef ff ff       	call   800878 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189a:	a1 80 60 80 00       	mov    0x806080,%eax
  80189f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a5:	a1 84 60 80 00       	mov    0x806084,%eax
  8018aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bb:	c9                   	leave  
  8018bc:	c3                   	ret    

008018bd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	57                   	push   %edi
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cf:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8018d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018d7:	eb 3d                	jmp    801916 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8018d9:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8018df:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8018e4:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	57                   	push   %edi
  8018eb:	53                   	push   %ebx
  8018ec:	68 08 60 80 00       	push   $0x806008
  8018f1:	e8 14 f1 ff ff       	call   800a0a <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018f6:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801901:	b8 04 00 00 00       	mov    $0x4,%eax
  801906:	e8 c0 fe ff ff       	call   8017cb <fsipc>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 0d                	js     80191f <devfile_write+0x62>
		        return r;
                n -= tmp;
  801912:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801914:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801916:	85 f6                	test   %esi,%esi
  801918:	75 bf                	jne    8018d9 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80191a:	89 d8                	mov    %ebx,%eax
  80191c:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80191f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5f                   	pop    %edi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	8b 40 0c             	mov    0xc(%eax),%eax
  801935:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80193a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801940:	ba 00 00 00 00       	mov    $0x0,%edx
  801945:	b8 03 00 00 00       	mov    $0x3,%eax
  80194a:	e8 7c fe ff ff       	call   8017cb <fsipc>
  80194f:	89 c3                	mov    %eax,%ebx
  801951:	85 c0                	test   %eax,%eax
  801953:	78 4b                	js     8019a0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801955:	39 c6                	cmp    %eax,%esi
  801957:	73 16                	jae    80196f <devfile_read+0x48>
  801959:	68 18 2f 80 00       	push   $0x802f18
  80195e:	68 1f 2f 80 00       	push   $0x802f1f
  801963:	6a 7c                	push   $0x7c
  801965:	68 34 2f 80 00       	push   $0x802f34
  80196a:	e8 a9 e8 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  80196f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801974:	7e 16                	jle    80198c <devfile_read+0x65>
  801976:	68 3f 2f 80 00       	push   $0x802f3f
  80197b:	68 1f 2f 80 00       	push   $0x802f1f
  801980:	6a 7d                	push   $0x7d
  801982:	68 34 2f 80 00       	push   $0x802f34
  801987:	e8 8c e8 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	50                   	push   %eax
  801990:	68 00 60 80 00       	push   $0x806000
  801995:	ff 75 0c             	pushl  0xc(%ebp)
  801998:	e8 6d f0 ff ff       	call   800a0a <memmove>
	return r;
  80199d:	83 c4 10             	add    $0x10,%esp
}
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 20             	sub    $0x20,%esp
  8019b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b3:	53                   	push   %ebx
  8019b4:	e8 86 ee ff ff       	call   80083f <strlen>
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c1:	7f 67                	jg     801a2a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c9:	50                   	push   %eax
  8019ca:	e8 6f f8 ff ff       	call   80123e <fd_alloc>
  8019cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 57                	js     801a2f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	53                   	push   %ebx
  8019dc:	68 00 60 80 00       	push   $0x806000
  8019e1:	e8 92 ee ff ff       	call   800878 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f6:	e8 d0 fd ff ff       	call   8017cb <fsipc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	79 14                	jns    801a18 <open+0x6f>
		fd_close(fd, 0);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	6a 00                	push   $0x0
  801a09:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0c:	e8 2a f9 ff ff       	call   80133b <fd_close>
		return r;
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	89 da                	mov    %ebx,%edx
  801a16:	eb 17                	jmp    801a2f <open+0x86>
	}

	return fd2num(fd);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1e:	e8 f4 f7 ff ff       	call   801217 <fd2num>
  801a23:	89 c2                	mov    %eax,%edx
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	eb 05                	jmp    801a2f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a2f:	89 d0                	mov    %edx,%eax
  801a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a41:	b8 08 00 00 00       	mov    $0x8,%eax
  801a46:	e8 80 fd ff ff       	call   8017cb <fsipc>
}
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a53:	68 4b 2f 80 00       	push   $0x802f4b
  801a58:	ff 75 0c             	pushl  0xc(%ebp)
  801a5b:	e8 18 ee ff ff       	call   800878 <strcpy>
	return 0;
}
  801a60:	b8 00 00 00 00       	mov    $0x0,%eax
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	53                   	push   %ebx
  801a6b:	83 ec 10             	sub    $0x10,%esp
  801a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a71:	53                   	push   %ebx
  801a72:	e8 fa 0a 00 00       	call   802571 <pageref>
  801a77:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a7a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a7f:	83 f8 01             	cmp    $0x1,%eax
  801a82:	75 10                	jne    801a94 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	ff 73 0c             	pushl  0xc(%ebx)
  801a8a:	e8 ca 02 00 00       	call   801d59 <nsipc_close>
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a94:	89 d0                	mov    %edx,%eax
  801a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aa1:	6a 00                	push   $0x0
  801aa3:	ff 75 10             	pushl  0x10(%ebp)
  801aa6:	ff 75 0c             	pushl  0xc(%ebp)
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	ff 70 0c             	pushl  0xc(%eax)
  801aaf:	e8 82 03 00 00       	call   801e36 <nsipc_send>
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801abc:	6a 00                	push   $0x0
  801abe:	ff 75 10             	pushl  0x10(%ebp)
  801ac1:	ff 75 0c             	pushl  0xc(%ebp)
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	ff 70 0c             	pushl  0xc(%eax)
  801aca:	e8 fb 02 00 00       	call   801dca <nsipc_recv>
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ad7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ada:	52                   	push   %edx
  801adb:	50                   	push   %eax
  801adc:	e8 ac f7 ff ff       	call   80128d <fd_lookup>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 17                	js     801aff <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801af1:	39 08                	cmp    %ecx,(%eax)
  801af3:	75 05                	jne    801afa <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801af5:	8b 40 0c             	mov    0xc(%eax),%eax
  801af8:	eb 05                	jmp    801aff <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801afa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	83 ec 1c             	sub    $0x1c,%esp
  801b09:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0e:	50                   	push   %eax
  801b0f:	e8 2a f7 ff ff       	call   80123e <fd_alloc>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 1b                	js     801b38 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b1d:	83 ec 04             	sub    $0x4,%esp
  801b20:	68 07 04 00 00       	push   $0x407
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	6a 00                	push   $0x0
  801b2a:	e8 52 f1 ff ff       	call   800c81 <sys_page_alloc>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	79 10                	jns    801b48 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	56                   	push   %esi
  801b3c:	e8 18 02 00 00       	call   801d59 <nsipc_close>
		return r;
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	eb 24                	jmp    801b6c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b48:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b56:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b5d:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b60:	83 ec 0c             	sub    $0xc,%esp
  801b63:	52                   	push   %edx
  801b64:	e8 ae f6 ff ff       	call   801217 <fd2num>
  801b69:	83 c4 10             	add    $0x10,%esp
}
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	e8 50 ff ff ff       	call   801ad1 <fd2sockid>
		return r;
  801b81:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 1f                	js     801ba6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	ff 75 10             	pushl  0x10(%ebp)
  801b8d:	ff 75 0c             	pushl  0xc(%ebp)
  801b90:	50                   	push   %eax
  801b91:	e8 1c 01 00 00       	call   801cb2 <nsipc_accept>
  801b96:	83 c4 10             	add    $0x10,%esp
		return r;
  801b99:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 07                	js     801ba6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b9f:	e8 5d ff ff ff       	call   801b01 <alloc_sockfd>
  801ba4:	89 c1                	mov    %eax,%ecx
}
  801ba6:	89 c8                	mov    %ecx,%eax
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb3:	e8 19 ff ff ff       	call   801ad1 <fd2sockid>
  801bb8:	89 c2                	mov    %eax,%edx
  801bba:	85 d2                	test   %edx,%edx
  801bbc:	78 12                	js     801bd0 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	ff 75 10             	pushl  0x10(%ebp)
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	52                   	push   %edx
  801bc8:	e8 35 01 00 00       	call   801d02 <nsipc_bind>
  801bcd:	83 c4 10             	add    $0x10,%esp
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <shutdown>:

int
shutdown(int s, int how)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	e8 f1 fe ff ff       	call   801ad1 <fd2sockid>
  801be0:	89 c2                	mov    %eax,%edx
  801be2:	85 d2                	test   %edx,%edx
  801be4:	78 0f                	js     801bf5 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	52                   	push   %edx
  801bed:	e8 45 01 00 00       	call   801d37 <nsipc_shutdown>
  801bf2:	83 c4 10             	add    $0x10,%esp
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801c00:	e8 cc fe ff ff       	call   801ad1 <fd2sockid>
  801c05:	89 c2                	mov    %eax,%edx
  801c07:	85 d2                	test   %edx,%edx
  801c09:	78 12                	js     801c1d <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	ff 75 10             	pushl  0x10(%ebp)
  801c11:	ff 75 0c             	pushl  0xc(%ebp)
  801c14:	52                   	push   %edx
  801c15:	e8 59 01 00 00       	call   801d73 <nsipc_connect>
  801c1a:	83 c4 10             	add    $0x10,%esp
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <listen>:

int
listen(int s, int backlog)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	e8 a4 fe ff ff       	call   801ad1 <fd2sockid>
  801c2d:	89 c2                	mov    %eax,%edx
  801c2f:	85 d2                	test   %edx,%edx
  801c31:	78 0f                	js     801c42 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	ff 75 0c             	pushl  0xc(%ebp)
  801c39:	52                   	push   %edx
  801c3a:	e8 69 01 00 00       	call   801da8 <nsipc_listen>
  801c3f:	83 c4 10             	add    $0x10,%esp
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c4a:	ff 75 10             	pushl  0x10(%ebp)
  801c4d:	ff 75 0c             	pushl  0xc(%ebp)
  801c50:	ff 75 08             	pushl  0x8(%ebp)
  801c53:	e8 3c 02 00 00       	call   801e94 <nsipc_socket>
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 d2                	test   %edx,%edx
  801c5f:	78 05                	js     801c66 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801c61:	e8 9b fe ff ff       	call   801b01 <alloc_sockfd>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 04             	sub    $0x4,%esp
  801c6f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c71:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801c78:	75 12                	jne    801c8c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	6a 02                	push   $0x2
  801c7f:	e8 b5 08 00 00       	call   802539 <ipc_find_env>
  801c84:	a3 04 50 80 00       	mov    %eax,0x805004
  801c89:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c8c:	6a 07                	push   $0x7
  801c8e:	68 00 70 80 00       	push   $0x807000
  801c93:	53                   	push   %ebx
  801c94:	ff 35 04 50 80 00    	pushl  0x805004
  801c9a:	e8 46 08 00 00       	call   8024e5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c9f:	83 c4 0c             	add    $0xc,%esp
  801ca2:	6a 00                	push   $0x0
  801ca4:	6a 00                	push   $0x0
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 cf 07 00 00       	call   80247c <ipc_recv>
}
  801cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cba:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cc2:	8b 06                	mov    (%esi),%eax
  801cc4:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cce:	e8 95 ff ff ff       	call   801c68 <nsipc>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 20                	js     801cf9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cd9:	83 ec 04             	sub    $0x4,%esp
  801cdc:	ff 35 10 70 80 00    	pushl  0x807010
  801ce2:	68 00 70 80 00       	push   $0x807000
  801ce7:	ff 75 0c             	pushl  0xc(%ebp)
  801cea:	e8 1b ed ff ff       	call   800a0a <memmove>
		*addrlen = ret->ret_addrlen;
  801cef:	a1 10 70 80 00       	mov    0x807010,%eax
  801cf4:	89 06                	mov    %eax,(%esi)
  801cf6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cf9:	89 d8                	mov    %ebx,%eax
  801cfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5e                   	pop    %esi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    

00801d02 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	53                   	push   %ebx
  801d06:	83 ec 08             	sub    $0x8,%esp
  801d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d14:	53                   	push   %ebx
  801d15:	ff 75 0c             	pushl  0xc(%ebp)
  801d18:	68 04 70 80 00       	push   $0x807004
  801d1d:	e8 e8 ec ff ff       	call   800a0a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d22:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d28:	b8 02 00 00 00       	mov    $0x2,%eax
  801d2d:	e8 36 ff ff ff       	call   801c68 <nsipc>
}
  801d32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d48:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d4d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d52:	e8 11 ff ff ff       	call   801c68 <nsipc>
}
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <nsipc_close>:

int
nsipc_close(int s)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d67:	b8 04 00 00 00       	mov    $0x4,%eax
  801d6c:	e8 f7 fe ff ff       	call   801c68 <nsipc>
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	53                   	push   %ebx
  801d77:	83 ec 08             	sub    $0x8,%esp
  801d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d85:	53                   	push   %ebx
  801d86:	ff 75 0c             	pushl  0xc(%ebp)
  801d89:	68 04 70 80 00       	push   $0x807004
  801d8e:	e8 77 ec ff ff       	call   800a0a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d93:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d99:	b8 05 00 00 00       	mov    $0x5,%eax
  801d9e:	e8 c5 fe ff ff       	call   801c68 <nsipc>
}
  801da3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801dbe:	b8 06 00 00 00       	mov    $0x6,%eax
  801dc3:	e8 a0 fe ff ff       	call   801c68 <nsipc>
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801dda:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801de0:	8b 45 14             	mov    0x14(%ebp),%eax
  801de3:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801de8:	b8 07 00 00 00       	mov    $0x7,%eax
  801ded:	e8 76 fe ff ff       	call   801c68 <nsipc>
  801df2:	89 c3                	mov    %eax,%ebx
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 35                	js     801e2d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801df8:	39 f0                	cmp    %esi,%eax
  801dfa:	7f 07                	jg     801e03 <nsipc_recv+0x39>
  801dfc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e01:	7e 16                	jle    801e19 <nsipc_recv+0x4f>
  801e03:	68 57 2f 80 00       	push   $0x802f57
  801e08:	68 1f 2f 80 00       	push   $0x802f1f
  801e0d:	6a 62                	push   $0x62
  801e0f:	68 6c 2f 80 00       	push   $0x802f6c
  801e14:	e8 ff e3 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e19:	83 ec 04             	sub    $0x4,%esp
  801e1c:	50                   	push   %eax
  801e1d:	68 00 70 80 00       	push   $0x807000
  801e22:	ff 75 0c             	pushl  0xc(%ebp)
  801e25:	e8 e0 eb ff ff       	call   800a0a <memmove>
  801e2a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e2d:	89 d8                	mov    %ebx,%eax
  801e2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e32:	5b                   	pop    %ebx
  801e33:	5e                   	pop    %esi
  801e34:	5d                   	pop    %ebp
  801e35:	c3                   	ret    

00801e36 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	53                   	push   %ebx
  801e3a:	83 ec 04             	sub    $0x4,%esp
  801e3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e48:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e4e:	7e 16                	jle    801e66 <nsipc_send+0x30>
  801e50:	68 78 2f 80 00       	push   $0x802f78
  801e55:	68 1f 2f 80 00       	push   $0x802f1f
  801e5a:	6a 6d                	push   $0x6d
  801e5c:	68 6c 2f 80 00       	push   $0x802f6c
  801e61:	e8 b2 e3 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	53                   	push   %ebx
  801e6a:	ff 75 0c             	pushl  0xc(%ebp)
  801e6d:	68 0c 70 80 00       	push   $0x80700c
  801e72:	e8 93 eb ff ff       	call   800a0a <memmove>
	nsipcbuf.send.req_size = size;
  801e77:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e7d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e80:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e85:	b8 08 00 00 00       	mov    $0x8,%eax
  801e8a:	e8 d9 fd ff ff       	call   801c68 <nsipc>
}
  801e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801eaa:	8b 45 10             	mov    0x10(%ebp),%eax
  801ead:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801eb2:	b8 09 00 00 00       	mov    $0x9,%eax
  801eb7:	e8 ac fd ff ff       	call   801c68 <nsipc>
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	ff 75 08             	pushl  0x8(%ebp)
  801ecc:	e8 56 f3 ff ff       	call   801227 <fd2data>
  801ed1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ed3:	83 c4 08             	add    $0x8,%esp
  801ed6:	68 84 2f 80 00       	push   $0x802f84
  801edb:	53                   	push   %ebx
  801edc:	e8 97 e9 ff ff       	call   800878 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ee1:	8b 56 04             	mov    0x4(%esi),%edx
  801ee4:	89 d0                	mov    %edx,%eax
  801ee6:	2b 06                	sub    (%esi),%eax
  801ee8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ef5:	00 00 00 
	stat->st_dev = &devpipe;
  801ef8:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  801eff:	40 80 00 
	return 0;
}
  801f02:	b8 00 00 00 00       	mov    $0x0,%eax
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	53                   	push   %ebx
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f18:	53                   	push   %ebx
  801f19:	6a 00                	push   $0x0
  801f1b:	e8 e6 ed ff ff       	call   800d06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f20:	89 1c 24             	mov    %ebx,(%esp)
  801f23:	e8 ff f2 ff ff       	call   801227 <fd2data>
  801f28:	83 c4 08             	add    $0x8,%esp
  801f2b:	50                   	push   %eax
  801f2c:	6a 00                	push   $0x0
  801f2e:	e8 d3 ed ff ff       	call   800d06 <sys_page_unmap>
}
  801f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	57                   	push   %edi
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 1c             	sub    $0x1c,%esp
  801f41:	89 c6                	mov    %eax,%esi
  801f43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f46:	a1 40 54 80 00       	mov    0x805440,%eax
  801f4b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f4e:	83 ec 0c             	sub    $0xc,%esp
  801f51:	56                   	push   %esi
  801f52:	e8 1a 06 00 00       	call   802571 <pageref>
  801f57:	89 c7                	mov    %eax,%edi
  801f59:	83 c4 04             	add    $0x4,%esp
  801f5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f5f:	e8 0d 06 00 00       	call   802571 <pageref>
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	39 c7                	cmp    %eax,%edi
  801f69:	0f 94 c2             	sete   %dl
  801f6c:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801f6f:	8b 0d 40 54 80 00    	mov    0x805440,%ecx
  801f75:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f78:	39 fb                	cmp    %edi,%ebx
  801f7a:	74 19                	je     801f95 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801f7c:	84 d2                	test   %dl,%dl
  801f7e:	74 c6                	je     801f46 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f80:	8b 51 58             	mov    0x58(%ecx),%edx
  801f83:	50                   	push   %eax
  801f84:	52                   	push   %edx
  801f85:	53                   	push   %ebx
  801f86:	68 8b 2f 80 00       	push   $0x802f8b
  801f8b:	e8 61 e3 ff ff       	call   8002f1 <cprintf>
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	eb b1                	jmp    801f46 <_pipeisclosed+0xe>
	}
}
  801f95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 28             	sub    $0x28,%esp
  801fa6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fa9:	56                   	push   %esi
  801faa:	e8 78 f2 ff ff       	call   801227 <fd2data>
  801faf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	bf 00 00 00 00       	mov    $0x0,%edi
  801fb9:	eb 4b                	jmp    802006 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fbb:	89 da                	mov    %ebx,%edx
  801fbd:	89 f0                	mov    %esi,%eax
  801fbf:	e8 74 ff ff ff       	call   801f38 <_pipeisclosed>
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	75 48                	jne    802010 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fc8:	e8 95 ec ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fcd:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd0:	8b 0b                	mov    (%ebx),%ecx
  801fd2:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd5:	39 d0                	cmp    %edx,%eax
  801fd7:	73 e2                	jae    801fbb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fdc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe3:	89 c2                	mov    %eax,%edx
  801fe5:	c1 fa 1f             	sar    $0x1f,%edx
  801fe8:	89 d1                	mov    %edx,%ecx
  801fea:	c1 e9 1b             	shr    $0x1b,%ecx
  801fed:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff0:	83 e2 1f             	and    $0x1f,%edx
  801ff3:	29 ca                	sub    %ecx,%edx
  801ff5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ff9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ffd:	83 c0 01             	add    $0x1,%eax
  802000:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802003:	83 c7 01             	add    $0x1,%edi
  802006:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802009:	75 c2                	jne    801fcd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80200b:	8b 45 10             	mov    0x10(%ebp),%eax
  80200e:	eb 05                	jmp    802015 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	57                   	push   %edi
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	83 ec 18             	sub    $0x18,%esp
  802026:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802029:	57                   	push   %edi
  80202a:	e8 f8 f1 ff ff       	call   801227 <fd2data>
  80202f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	bb 00 00 00 00       	mov    $0x0,%ebx
  802039:	eb 3d                	jmp    802078 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80203b:	85 db                	test   %ebx,%ebx
  80203d:	74 04                	je     802043 <devpipe_read+0x26>
				return i;
  80203f:	89 d8                	mov    %ebx,%eax
  802041:	eb 44                	jmp    802087 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802043:	89 f2                	mov    %esi,%edx
  802045:	89 f8                	mov    %edi,%eax
  802047:	e8 ec fe ff ff       	call   801f38 <_pipeisclosed>
  80204c:	85 c0                	test   %eax,%eax
  80204e:	75 32                	jne    802082 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802050:	e8 0d ec ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802055:	8b 06                	mov    (%esi),%eax
  802057:	3b 46 04             	cmp    0x4(%esi),%eax
  80205a:	74 df                	je     80203b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80205c:	99                   	cltd   
  80205d:	c1 ea 1b             	shr    $0x1b,%edx
  802060:	01 d0                	add    %edx,%eax
  802062:	83 e0 1f             	and    $0x1f,%eax
  802065:	29 d0                	sub    %edx,%eax
  802067:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80206c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802072:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802075:	83 c3 01             	add    $0x1,%ebx
  802078:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80207b:	75 d8                	jne    802055 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80207d:	8b 45 10             	mov    0x10(%ebp),%eax
  802080:	eb 05                	jmp    802087 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5f                   	pop    %edi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802097:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209a:	50                   	push   %eax
  80209b:	e8 9e f1 ff ff       	call   80123e <fd_alloc>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	89 c2                	mov    %eax,%edx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	0f 88 2c 01 00 00    	js     8021d9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ad:	83 ec 04             	sub    $0x4,%esp
  8020b0:	68 07 04 00 00       	push   $0x407
  8020b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b8:	6a 00                	push   $0x0
  8020ba:	e8 c2 eb ff ff       	call   800c81 <sys_page_alloc>
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	89 c2                	mov    %eax,%edx
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	0f 88 0d 01 00 00    	js     8021d9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020cc:	83 ec 0c             	sub    $0xc,%esp
  8020cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d2:	50                   	push   %eax
  8020d3:	e8 66 f1 ff ff       	call   80123e <fd_alloc>
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 88 e2 00 00 00    	js     8021c7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e5:	83 ec 04             	sub    $0x4,%esp
  8020e8:	68 07 04 00 00       	push   $0x407
  8020ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 8a eb ff ff       	call   800c81 <sys_page_alloc>
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 88 c3 00 00 00    	js     8021c7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802104:	83 ec 0c             	sub    $0xc,%esp
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	e8 18 f1 ff ff       	call   801227 <fd2data>
  80210f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802111:	83 c4 0c             	add    $0xc,%esp
  802114:	68 07 04 00 00       	push   $0x407
  802119:	50                   	push   %eax
  80211a:	6a 00                	push   $0x0
  80211c:	e8 60 eb ff ff       	call   800c81 <sys_page_alloc>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	85 c0                	test   %eax,%eax
  802128:	0f 88 89 00 00 00    	js     8021b7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212e:	83 ec 0c             	sub    $0xc,%esp
  802131:	ff 75 f0             	pushl  -0x10(%ebp)
  802134:	e8 ee f0 ff ff       	call   801227 <fd2data>
  802139:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802140:	50                   	push   %eax
  802141:	6a 00                	push   $0x0
  802143:	56                   	push   %esi
  802144:	6a 00                	push   $0x0
  802146:	e8 79 eb ff ff       	call   800cc4 <sys_page_map>
  80214b:	89 c3                	mov    %eax,%ebx
  80214d:	83 c4 20             	add    $0x20,%esp
  802150:	85 c0                	test   %eax,%eax
  802152:	78 55                	js     8021a9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802154:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80215a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80215f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802162:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802169:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802172:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802174:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802177:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80217e:	83 ec 0c             	sub    $0xc,%esp
  802181:	ff 75 f4             	pushl  -0xc(%ebp)
  802184:	e8 8e f0 ff ff       	call   801217 <fd2num>
  802189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80218e:	83 c4 04             	add    $0x4,%esp
  802191:	ff 75 f0             	pushl  -0x10(%ebp)
  802194:	e8 7e f0 ff ff       	call   801217 <fd2num>
  802199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80219f:	83 c4 10             	add    $0x10,%esp
  8021a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a7:	eb 30                	jmp    8021d9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021a9:	83 ec 08             	sub    $0x8,%esp
  8021ac:	56                   	push   %esi
  8021ad:	6a 00                	push   $0x0
  8021af:	e8 52 eb ff ff       	call   800d06 <sys_page_unmap>
  8021b4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021b7:	83 ec 08             	sub    $0x8,%esp
  8021ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bd:	6a 00                	push   $0x0
  8021bf:	e8 42 eb ff ff       	call   800d06 <sys_page_unmap>
  8021c4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 32 eb ff ff       	call   800d06 <sys_page_unmap>
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021d9:	89 d0                	mov    %edx,%eax
  8021db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021de:	5b                   	pop    %ebx
  8021df:	5e                   	pop    %esi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021eb:	50                   	push   %eax
  8021ec:	ff 75 08             	pushl  0x8(%ebp)
  8021ef:	e8 99 f0 ff ff       	call   80128d <fd_lookup>
  8021f4:	89 c2                	mov    %eax,%edx
  8021f6:	83 c4 10             	add    $0x10,%esp
  8021f9:	85 d2                	test   %edx,%edx
  8021fb:	78 18                	js     802215 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021fd:	83 ec 0c             	sub    $0xc,%esp
  802200:	ff 75 f4             	pushl  -0xc(%ebp)
  802203:	e8 1f f0 ff ff       	call   801227 <fd2data>
	return _pipeisclosed(fd, p);
  802208:	89 c2                	mov    %eax,%edx
  80220a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220d:	e8 26 fd ff ff       	call   801f38 <_pipeisclosed>
  802212:	83 c4 10             	add    $0x10,%esp
}
  802215:	c9                   	leave  
  802216:	c3                   	ret    

00802217 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80221f:	85 f6                	test   %esi,%esi
  802221:	75 16                	jne    802239 <wait+0x22>
  802223:	68 a3 2f 80 00       	push   $0x802fa3
  802228:	68 1f 2f 80 00       	push   $0x802f1f
  80222d:	6a 09                	push   $0x9
  80222f:	68 ae 2f 80 00       	push   $0x802fae
  802234:	e8 df df ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  802239:	89 f3                	mov    %esi,%ebx
  80223b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802241:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802244:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80224a:	eb 05                	jmp    802251 <wait+0x3a>
		sys_yield();
  80224c:	e8 11 ea ff ff       	call   800c62 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802251:	8b 43 48             	mov    0x48(%ebx),%eax
  802254:	39 f0                	cmp    %esi,%eax
  802256:	75 07                	jne    80225f <wait+0x48>
  802258:	8b 43 54             	mov    0x54(%ebx),%eax
  80225b:	85 c0                	test   %eax,%eax
  80225d:	75 ed                	jne    80224c <wait+0x35>
		sys_yield();
}
  80225f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802262:	5b                   	pop    %ebx
  802263:	5e                   	pop    %esi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802276:	68 b9 2f 80 00       	push   $0x802fb9
  80227b:	ff 75 0c             	pushl  0xc(%ebp)
  80227e:	e8 f5 e5 ff ff       	call   800878 <strcpy>
	return 0;
}
  802283:	b8 00 00 00 00       	mov    $0x0,%eax
  802288:	c9                   	leave  
  802289:	c3                   	ret    

0080228a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	57                   	push   %edi
  80228e:	56                   	push   %esi
  80228f:	53                   	push   %ebx
  802290:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802296:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80229b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a1:	eb 2d                	jmp    8022d0 <devcons_write+0x46>
		m = n - tot;
  8022a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022a8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022b0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022b3:	83 ec 04             	sub    $0x4,%esp
  8022b6:	53                   	push   %ebx
  8022b7:	03 45 0c             	add    0xc(%ebp),%eax
  8022ba:	50                   	push   %eax
  8022bb:	57                   	push   %edi
  8022bc:	e8 49 e7 ff ff       	call   800a0a <memmove>
		sys_cputs(buf, m);
  8022c1:	83 c4 08             	add    $0x8,%esp
  8022c4:	53                   	push   %ebx
  8022c5:	57                   	push   %edi
  8022c6:	e8 fa e8 ff ff       	call   800bc5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022cb:	01 de                	add    %ebx,%esi
  8022cd:	83 c4 10             	add    $0x10,%esp
  8022d0:	89 f0                	mov    %esi,%eax
  8022d2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d5:	72 cc                	jb     8022a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022da:	5b                   	pop    %ebx
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    

008022df <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8022e5:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8022ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ee:	75 07                	jne    8022f7 <devcons_read+0x18>
  8022f0:	eb 28                	jmp    80231a <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022f2:	e8 6b e9 ff ff       	call   800c62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022f7:	e8 e7 e8 ff ff       	call   800be3 <sys_cgetc>
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	74 f2                	je     8022f2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802300:	85 c0                	test   %eax,%eax
  802302:	78 16                	js     80231a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802304:	83 f8 04             	cmp    $0x4,%eax
  802307:	74 0c                	je     802315 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230c:	88 02                	mov    %al,(%edx)
	return 1;
  80230e:	b8 01 00 00 00       	mov    $0x1,%eax
  802313:	eb 05                	jmp    80231a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802315:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80231a:	c9                   	leave  
  80231b:	c3                   	ret    

0080231c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802322:	8b 45 08             	mov    0x8(%ebp),%eax
  802325:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802328:	6a 01                	push   $0x1
  80232a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80232d:	50                   	push   %eax
  80232e:	e8 92 e8 ff ff       	call   800bc5 <sys_cputs>
  802333:	83 c4 10             	add    $0x10,%esp
}
  802336:	c9                   	leave  
  802337:	c3                   	ret    

00802338 <getchar>:

int
getchar(void)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80233e:	6a 01                	push   $0x1
  802340:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802343:	50                   	push   %eax
  802344:	6a 00                	push   $0x0
  802346:	e8 b1 f1 ff ff       	call   8014fc <read>
	if (r < 0)
  80234b:	83 c4 10             	add    $0x10,%esp
  80234e:	85 c0                	test   %eax,%eax
  802350:	78 0f                	js     802361 <getchar+0x29>
		return r;
	if (r < 1)
  802352:	85 c0                	test   %eax,%eax
  802354:	7e 06                	jle    80235c <getchar+0x24>
		return -E_EOF;
	return c;
  802356:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80235a:	eb 05                	jmp    802361 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80235c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802361:	c9                   	leave  
  802362:	c3                   	ret    

00802363 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802363:	55                   	push   %ebp
  802364:	89 e5                	mov    %esp,%ebp
  802366:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236c:	50                   	push   %eax
  80236d:	ff 75 08             	pushl  0x8(%ebp)
  802370:	e8 18 ef ff ff       	call   80128d <fd_lookup>
  802375:	83 c4 10             	add    $0x10,%esp
  802378:	85 c0                	test   %eax,%eax
  80237a:	78 11                	js     80238d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237f:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802385:	39 10                	cmp    %edx,(%eax)
  802387:	0f 94 c0             	sete   %al
  80238a:	0f b6 c0             	movzbl %al,%eax
}
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <opencons>:

int
opencons(void)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802398:	50                   	push   %eax
  802399:	e8 a0 ee ff ff       	call   80123e <fd_alloc>
  80239e:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a3:	85 c0                	test   %eax,%eax
  8023a5:	78 3e                	js     8023e5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a7:	83 ec 04             	sub    $0x4,%esp
  8023aa:	68 07 04 00 00       	push   $0x407
  8023af:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b2:	6a 00                	push   $0x0
  8023b4:	e8 c8 e8 ff ff       	call   800c81 <sys_page_alloc>
  8023b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8023bc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	78 23                	js     8023e5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023c2:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8023c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023d7:	83 ec 0c             	sub    $0xc,%esp
  8023da:	50                   	push   %eax
  8023db:	e8 37 ee ff ff       	call   801217 <fd2num>
  8023e0:	89 c2                	mov    %eax,%edx
  8023e2:	83 c4 10             	add    $0x10,%esp
}
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	c9                   	leave  
  8023e8:	c3                   	ret    

008023e9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023ef:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8023f6:	75 2c                	jne    802424 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8023f8:	83 ec 04             	sub    $0x4,%esp
  8023fb:	6a 07                	push   $0x7
  8023fd:	68 00 f0 bf ee       	push   $0xeebff000
  802402:	6a 00                	push   $0x0
  802404:	e8 78 e8 ff ff       	call   800c81 <sys_page_alloc>
  802409:	83 c4 10             	add    $0x10,%esp
  80240c:	85 c0                	test   %eax,%eax
  80240e:	74 14                	je     802424 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802410:	83 ec 04             	sub    $0x4,%esp
  802413:	68 c8 2f 80 00       	push   $0x802fc8
  802418:	6a 21                	push   $0x21
  80241a:	68 2c 30 80 00       	push   $0x80302c
  80241f:	e8 f4 dd ff ff       	call   800218 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802424:	8b 45 08             	mov    0x8(%ebp),%eax
  802427:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80242c:	83 ec 08             	sub    $0x8,%esp
  80242f:	68 58 24 80 00       	push   $0x802458
  802434:	6a 00                	push   $0x0
  802436:	e8 91 e9 ff ff       	call   800dcc <sys_env_set_pgfault_upcall>
  80243b:	83 c4 10             	add    $0x10,%esp
  80243e:	85 c0                	test   %eax,%eax
  802440:	79 14                	jns    802456 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802442:	83 ec 04             	sub    $0x4,%esp
  802445:	68 f4 2f 80 00       	push   $0x802ff4
  80244a:	6a 29                	push   $0x29
  80244c:	68 2c 30 80 00       	push   $0x80302c
  802451:	e8 c2 dd ff ff       	call   800218 <_panic>
}
  802456:	c9                   	leave  
  802457:	c3                   	ret    

00802458 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802458:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802459:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80245e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802460:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802463:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802468:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80246c:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802470:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802472:	83 c4 08             	add    $0x8,%esp
        popal
  802475:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802476:	83 c4 04             	add    $0x4,%esp
        popfl
  802479:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  80247a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80247b:	c3                   	ret    

0080247c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	56                   	push   %esi
  802480:	53                   	push   %ebx
  802481:	8b 75 08             	mov    0x8(%ebp),%esi
  802484:	8b 45 0c             	mov    0xc(%ebp),%eax
  802487:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80248a:	85 c0                	test   %eax,%eax
  80248c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802491:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802494:	83 ec 0c             	sub    $0xc,%esp
  802497:	50                   	push   %eax
  802498:	e8 94 e9 ff ff       	call   800e31 <sys_ipc_recv>
  80249d:	83 c4 10             	add    $0x10,%esp
  8024a0:	85 c0                	test   %eax,%eax
  8024a2:	79 16                	jns    8024ba <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8024a4:	85 f6                	test   %esi,%esi
  8024a6:	74 06                	je     8024ae <ipc_recv+0x32>
  8024a8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8024ae:	85 db                	test   %ebx,%ebx
  8024b0:	74 2c                	je     8024de <ipc_recv+0x62>
  8024b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024b8:	eb 24                	jmp    8024de <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8024ba:	85 f6                	test   %esi,%esi
  8024bc:	74 0a                	je     8024c8 <ipc_recv+0x4c>
  8024be:	a1 40 54 80 00       	mov    0x805440,%eax
  8024c3:	8b 40 74             	mov    0x74(%eax),%eax
  8024c6:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8024c8:	85 db                	test   %ebx,%ebx
  8024ca:	74 0a                	je     8024d6 <ipc_recv+0x5a>
  8024cc:	a1 40 54 80 00       	mov    0x805440,%eax
  8024d1:	8b 40 78             	mov    0x78(%eax),%eax
  8024d4:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8024d6:	a1 40 54 80 00       	mov    0x805440,%eax
  8024db:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    

008024e5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
  8024e8:	57                   	push   %edi
  8024e9:	56                   	push   %esi
  8024ea:	53                   	push   %ebx
  8024eb:	83 ec 0c             	sub    $0xc,%esp
  8024ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8024f7:	85 db                	test   %ebx,%ebx
  8024f9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024fe:	0f 44 d8             	cmove  %eax,%ebx
  802501:	eb 1c                	jmp    80251f <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802503:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802506:	74 12                	je     80251a <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802508:	50                   	push   %eax
  802509:	68 3a 30 80 00       	push   $0x80303a
  80250e:	6a 39                	push   $0x39
  802510:	68 55 30 80 00       	push   $0x803055
  802515:	e8 fe dc ff ff       	call   800218 <_panic>
                 sys_yield();
  80251a:	e8 43 e7 ff ff       	call   800c62 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80251f:	ff 75 14             	pushl  0x14(%ebp)
  802522:	53                   	push   %ebx
  802523:	56                   	push   %esi
  802524:	57                   	push   %edi
  802525:	e8 e4 e8 ff ff       	call   800e0e <sys_ipc_try_send>
  80252a:	83 c4 10             	add    $0x10,%esp
  80252d:	85 c0                	test   %eax,%eax
  80252f:	78 d2                	js     802503 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    

00802539 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802539:	55                   	push   %ebp
  80253a:	89 e5                	mov    %esp,%ebp
  80253c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80253f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802544:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802547:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80254d:	8b 52 50             	mov    0x50(%edx),%edx
  802550:	39 ca                	cmp    %ecx,%edx
  802552:	75 0d                	jne    802561 <ipc_find_env+0x28>
			return envs[i].env_id;
  802554:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802557:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80255c:	8b 40 08             	mov    0x8(%eax),%eax
  80255f:	eb 0e                	jmp    80256f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802561:	83 c0 01             	add    $0x1,%eax
  802564:	3d 00 04 00 00       	cmp    $0x400,%eax
  802569:	75 d9                	jne    802544 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80256b:	66 b8 00 00          	mov    $0x0,%ax
}
  80256f:	5d                   	pop    %ebp
  802570:	c3                   	ret    

00802571 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802571:	55                   	push   %ebp
  802572:	89 e5                	mov    %esp,%ebp
  802574:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802577:	89 d0                	mov    %edx,%eax
  802579:	c1 e8 16             	shr    $0x16,%eax
  80257c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802583:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802588:	f6 c1 01             	test   $0x1,%cl
  80258b:	74 1d                	je     8025aa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258d:	c1 ea 0c             	shr    $0xc,%edx
  802590:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802597:	f6 c2 01             	test   $0x1,%dl
  80259a:	74 0e                	je     8025aa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259c:	c1 ea 0c             	shr    $0xc,%edx
  80259f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a6:	ef 
  8025a7:	0f b7 c0             	movzwl %ax,%eax
}
  8025aa:	5d                   	pop    %ebp
  8025ab:	c3                   	ret    
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	83 ec 10             	sub    $0x10,%esp
  8025b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8025ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8025be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8025c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8025c6:	85 d2                	test   %edx,%edx
  8025c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025cc:	89 34 24             	mov    %esi,(%esp)
  8025cf:	89 c8                	mov    %ecx,%eax
  8025d1:	75 35                	jne    802608 <__udivdi3+0x58>
  8025d3:	39 f1                	cmp    %esi,%ecx
  8025d5:	0f 87 bd 00 00 00    	ja     802698 <__udivdi3+0xe8>
  8025db:	85 c9                	test   %ecx,%ecx
  8025dd:	89 cd                	mov    %ecx,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f1                	div    %ecx
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 f0                	mov    %esi,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c6                	mov    %eax,%esi
  8025f4:	89 f8                	mov    %edi,%eax
  8025f6:	f7 f5                	div    %ebp
  8025f8:	89 f2                	mov    %esi,%edx
  8025fa:	83 c4 10             	add    $0x10,%esp
  8025fd:	5e                   	pop    %esi
  8025fe:	5f                   	pop    %edi
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    
  802601:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802608:	3b 14 24             	cmp    (%esp),%edx
  80260b:	77 7b                	ja     802688 <__udivdi3+0xd8>
  80260d:	0f bd f2             	bsr    %edx,%esi
  802610:	83 f6 1f             	xor    $0x1f,%esi
  802613:	0f 84 97 00 00 00    	je     8026b0 <__udivdi3+0x100>
  802619:	bd 20 00 00 00       	mov    $0x20,%ebp
  80261e:	89 d7                	mov    %edx,%edi
  802620:	89 f1                	mov    %esi,%ecx
  802622:	29 f5                	sub    %esi,%ebp
  802624:	d3 e7                	shl    %cl,%edi
  802626:	89 c2                	mov    %eax,%edx
  802628:	89 e9                	mov    %ebp,%ecx
  80262a:	d3 ea                	shr    %cl,%edx
  80262c:	89 f1                	mov    %esi,%ecx
  80262e:	09 fa                	or     %edi,%edx
  802630:	8b 3c 24             	mov    (%esp),%edi
  802633:	d3 e0                	shl    %cl,%eax
  802635:	89 54 24 08          	mov    %edx,0x8(%esp)
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802643:	89 fa                	mov    %edi,%edx
  802645:	d3 ea                	shr    %cl,%edx
  802647:	89 f1                	mov    %esi,%ecx
  802649:	d3 e7                	shl    %cl,%edi
  80264b:	89 e9                	mov    %ebp,%ecx
  80264d:	d3 e8                	shr    %cl,%eax
  80264f:	09 c7                	or     %eax,%edi
  802651:	89 f8                	mov    %edi,%eax
  802653:	f7 74 24 08          	divl   0x8(%esp)
  802657:	89 d5                	mov    %edx,%ebp
  802659:	89 c7                	mov    %eax,%edi
  80265b:	f7 64 24 0c          	mull   0xc(%esp)
  80265f:	39 d5                	cmp    %edx,%ebp
  802661:	89 14 24             	mov    %edx,(%esp)
  802664:	72 11                	jb     802677 <__udivdi3+0xc7>
  802666:	8b 54 24 04          	mov    0x4(%esp),%edx
  80266a:	89 f1                	mov    %esi,%ecx
  80266c:	d3 e2                	shl    %cl,%edx
  80266e:	39 c2                	cmp    %eax,%edx
  802670:	73 5e                	jae    8026d0 <__udivdi3+0x120>
  802672:	3b 2c 24             	cmp    (%esp),%ebp
  802675:	75 59                	jne    8026d0 <__udivdi3+0x120>
  802677:	8d 47 ff             	lea    -0x1(%edi),%eax
  80267a:	31 f6                	xor    %esi,%esi
  80267c:	89 f2                	mov    %esi,%edx
  80267e:	83 c4 10             	add    $0x10,%esp
  802681:	5e                   	pop    %esi
  802682:	5f                   	pop    %edi
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    
  802685:	8d 76 00             	lea    0x0(%esi),%esi
  802688:	31 f6                	xor    %esi,%esi
  80268a:	31 c0                	xor    %eax,%eax
  80268c:	89 f2                	mov    %esi,%edx
  80268e:	83 c4 10             	add    $0x10,%esp
  802691:	5e                   	pop    %esi
  802692:	5f                   	pop    %edi
  802693:	5d                   	pop    %ebp
  802694:	c3                   	ret    
  802695:	8d 76 00             	lea    0x0(%esi),%esi
  802698:	89 f2                	mov    %esi,%edx
  80269a:	31 f6                	xor    %esi,%esi
  80269c:	89 f8                	mov    %edi,%eax
  80269e:	f7 f1                	div    %ecx
  8026a0:	89 f2                	mov    %esi,%edx
  8026a2:	83 c4 10             	add    $0x10,%esp
  8026a5:	5e                   	pop    %esi
  8026a6:	5f                   	pop    %edi
  8026a7:	5d                   	pop    %ebp
  8026a8:	c3                   	ret    
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8026b4:	76 0b                	jbe    8026c1 <__udivdi3+0x111>
  8026b6:	31 c0                	xor    %eax,%eax
  8026b8:	3b 14 24             	cmp    (%esp),%edx
  8026bb:	0f 83 37 ff ff ff    	jae    8025f8 <__udivdi3+0x48>
  8026c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026c6:	e9 2d ff ff ff       	jmp    8025f8 <__udivdi3+0x48>
  8026cb:	90                   	nop
  8026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	89 f8                	mov    %edi,%eax
  8026d2:	31 f6                	xor    %esi,%esi
  8026d4:	e9 1f ff ff ff       	jmp    8025f8 <__udivdi3+0x48>
  8026d9:	66 90                	xchg   %ax,%ax
  8026db:	66 90                	xchg   %ax,%ax
  8026dd:	66 90                	xchg   %ax,%ax
  8026df:	90                   	nop

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	83 ec 20             	sub    $0x20,%esp
  8026e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8026ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f2:	89 c6                	mov    %eax,%esi
  8026f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802700:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802704:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802708:	89 74 24 18          	mov    %esi,0x18(%esp)
  80270c:	85 c0                	test   %eax,%eax
  80270e:	89 c2                	mov    %eax,%edx
  802710:	75 1e                	jne    802730 <__umoddi3+0x50>
  802712:	39 f7                	cmp    %esi,%edi
  802714:	76 52                	jbe    802768 <__umoddi3+0x88>
  802716:	89 c8                	mov    %ecx,%eax
  802718:	89 f2                	mov    %esi,%edx
  80271a:	f7 f7                	div    %edi
  80271c:	89 d0                	mov    %edx,%eax
  80271e:	31 d2                	xor    %edx,%edx
  802720:	83 c4 20             	add    $0x20,%esp
  802723:	5e                   	pop    %esi
  802724:	5f                   	pop    %edi
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    
  802727:	89 f6                	mov    %esi,%esi
  802729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802730:	39 f0                	cmp    %esi,%eax
  802732:	77 5c                	ja     802790 <__umoddi3+0xb0>
  802734:	0f bd e8             	bsr    %eax,%ebp
  802737:	83 f5 1f             	xor    $0x1f,%ebp
  80273a:	75 64                	jne    8027a0 <__umoddi3+0xc0>
  80273c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802740:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802744:	0f 86 f6 00 00 00    	jbe    802840 <__umoddi3+0x160>
  80274a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80274e:	0f 82 ec 00 00 00    	jb     802840 <__umoddi3+0x160>
  802754:	8b 44 24 14          	mov    0x14(%esp),%eax
  802758:	8b 54 24 18          	mov    0x18(%esp),%edx
  80275c:	83 c4 20             	add    $0x20,%esp
  80275f:	5e                   	pop    %esi
  802760:	5f                   	pop    %edi
  802761:	5d                   	pop    %ebp
  802762:	c3                   	ret    
  802763:	90                   	nop
  802764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802768:	85 ff                	test   %edi,%edi
  80276a:	89 fd                	mov    %edi,%ebp
  80276c:	75 0b                	jne    802779 <__umoddi3+0x99>
  80276e:	b8 01 00 00 00       	mov    $0x1,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f7                	div    %edi
  802777:	89 c5                	mov    %eax,%ebp
  802779:	8b 44 24 10          	mov    0x10(%esp),%eax
  80277d:	31 d2                	xor    %edx,%edx
  80277f:	f7 f5                	div    %ebp
  802781:	89 c8                	mov    %ecx,%eax
  802783:	f7 f5                	div    %ebp
  802785:	eb 95                	jmp    80271c <__umoddi3+0x3c>
  802787:	89 f6                	mov    %esi,%esi
  802789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802790:	89 c8                	mov    %ecx,%eax
  802792:	89 f2                	mov    %esi,%edx
  802794:	83 c4 20             	add    $0x20,%esp
  802797:	5e                   	pop    %esi
  802798:	5f                   	pop    %edi
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	90                   	nop
  80279c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8027a5:	89 e9                	mov    %ebp,%ecx
  8027a7:	29 e8                	sub    %ebp,%eax
  8027a9:	d3 e2                	shl    %cl,%edx
  8027ab:	89 c7                	mov    %eax,%edi
  8027ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8027b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027b5:	89 f9                	mov    %edi,%ecx
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	89 c1                	mov    %eax,%ecx
  8027bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027bf:	09 d1                	or     %edx,%ecx
  8027c1:	89 fa                	mov    %edi,%edx
  8027c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8027c7:	89 e9                	mov    %ebp,%ecx
  8027c9:	d3 e0                	shl    %cl,%eax
  8027cb:	89 f9                	mov    %edi,%ecx
  8027cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027d1:	89 f0                	mov    %esi,%eax
  8027d3:	d3 e8                	shr    %cl,%eax
  8027d5:	89 e9                	mov    %ebp,%ecx
  8027d7:	89 c7                	mov    %eax,%edi
  8027d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8027dd:	d3 e6                	shl    %cl,%esi
  8027df:	89 d1                	mov    %edx,%ecx
  8027e1:	89 fa                	mov    %edi,%edx
  8027e3:	d3 e8                	shr    %cl,%eax
  8027e5:	89 e9                	mov    %ebp,%ecx
  8027e7:	09 f0                	or     %esi,%eax
  8027e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8027ed:	f7 74 24 10          	divl   0x10(%esp)
  8027f1:	d3 e6                	shl    %cl,%esi
  8027f3:	89 d1                	mov    %edx,%ecx
  8027f5:	f7 64 24 0c          	mull   0xc(%esp)
  8027f9:	39 d1                	cmp    %edx,%ecx
  8027fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8027ff:	89 d7                	mov    %edx,%edi
  802801:	89 c6                	mov    %eax,%esi
  802803:	72 0a                	jb     80280f <__umoddi3+0x12f>
  802805:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802809:	73 10                	jae    80281b <__umoddi3+0x13b>
  80280b:	39 d1                	cmp    %edx,%ecx
  80280d:	75 0c                	jne    80281b <__umoddi3+0x13b>
  80280f:	89 d7                	mov    %edx,%edi
  802811:	89 c6                	mov    %eax,%esi
  802813:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802817:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80281b:	89 ca                	mov    %ecx,%edx
  80281d:	89 e9                	mov    %ebp,%ecx
  80281f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802823:	29 f0                	sub    %esi,%eax
  802825:	19 fa                	sbb    %edi,%edx
  802827:	d3 e8                	shr    %cl,%eax
  802829:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80282e:	89 d7                	mov    %edx,%edi
  802830:	d3 e7                	shl    %cl,%edi
  802832:	89 e9                	mov    %ebp,%ecx
  802834:	09 f8                	or     %edi,%eax
  802836:	d3 ea                	shr    %cl,%edx
  802838:	83 c4 20             	add    $0x20,%esp
  80283b:	5e                   	pop    %esi
  80283c:	5f                   	pop    %edi
  80283d:	5d                   	pop    %ebp
  80283e:	c3                   	ret    
  80283f:	90                   	nop
  802840:	8b 74 24 10          	mov    0x10(%esp),%esi
  802844:	29 f9                	sub    %edi,%ecx
  802846:	19 c6                	sbb    %eax,%esi
  802848:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80284c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802850:	e9 ff fe ff ff       	jmp    802754 <__umoddi3+0x74>
