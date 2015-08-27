
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
  80003e:	68 80 23 80 00       	push   $0x802380
  800043:	e8 bb 18 00 00       	call   801903 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 85 23 80 00       	push   $0x802385
  800057:	6a 0c                	push   $0xc
  800059:	68 93 23 80 00       	push   $0x802393
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 4a 15 00 00       	call   8015b8 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 40 42 80 00       	push   $0x804240
  80007b:	53                   	push   %ebx
  80007c:	e8 66 14 00 00       	call   8014e7 <readn>
  800081:	89 c7                	mov    %eax,%edi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 a8 23 80 00       	push   $0x8023a8
  800090:	6a 0f                	push   $0xf
  800092:	68 93 23 80 00       	push   $0x802393
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 b3 0e 00 00       	call   800f54 <fork>
  8000a1:	89 c6                	mov    %eax,%esi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 1b 29 80 00       	push   $0x80291b
  8000ad:	6a 12                	push   $0x12
  8000af:	68 93 23 80 00       	push   $0x802393
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 ec 14 00 00       	call   8015b8 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 e8 23 80 00 	movl   $0x8023e8,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 40 40 80 00       	push   $0x804040
  8000e5:	53                   	push   %ebx
  8000e6:	e8 fc 13 00 00       	call   8014e7 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 f8                	cmp    %edi,%eax
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	57                   	push   %edi
  8000f7:	68 2c 24 80 00       	push   $0x80242c
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 93 23 80 00       	push   $0x802393
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	50                   	push   %eax
  80010c:	68 40 40 80 00       	push   $0x804040
  800111:	68 40 42 80 00       	push   $0x804240
  800116:	e8 6a 09 00 00       	call   800a85 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 58 24 80 00       	push   $0x802458
  80012a:	6a 19                	push   $0x19
  80012c:	68 93 23 80 00       	push   $0x802393
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 b2 23 80 00       	push   $0x8023b2
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 6a 14 00 00       	call   8015b8 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 c0 11 00 00       	call   801316 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	56                   	push   %esi
  800162:	e8 99 1b 00 00       	call   801d00 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 40 40 80 00       	push   $0x804040
  800174:	53                   	push   %ebx
  800175:	e8 6d 13 00 00       	call   8014e7 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 f8                	cmp    %edi,%eax
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	57                   	push   %edi
  800186:	68 90 24 80 00       	push   $0x802490
  80018b:	6a 21                	push   $0x21
  80018d:	68 93 23 80 00       	push   $0x802393
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 cb 23 80 00       	push   $0x8023cb
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 6a 11 00 00       	call   801316 <close>
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
  8001d5:	a3 40 44 80 00       	mov    %eax,0x804440

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800204:	e8 3a 11 00 00       	call   801343 <close_all>
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
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 18 0a 00 00       	call   800c43 <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 c0 24 80 00       	push   $0x8024c0
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 59 29 80 00 	movl   $0x802959,(%esp)
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
  800354:	e8 47 1d 00 00       	call   8020a0 <__udivdi3>
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
  800392:	e8 39 1e 00 00       	call   8021d0 <__umoddi3>
  800397:	83 c4 14             	add    $0x14,%esp
  80039a:	0f be 80 e3 24 80 00 	movsbl 0x8024e3(%eax),%eax
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
  800496:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
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
  80055a:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	75 18                	jne    80057d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800565:	50                   	push   %eax
  800566:	68 fb 24 80 00       	push   $0x8024fb
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
  80057e:	68 2d 2a 80 00       	push   $0x802a2d
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
  8005ab:	ba f4 24 80 00       	mov    $0x8024f4,%edx
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
  800c2a:	68 1f 28 80 00       	push   $0x80281f
  800c2f:	6a 23                	push   $0x23
  800c31:	68 3c 28 80 00       	push   $0x80283c
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
  800cab:	68 1f 28 80 00       	push   $0x80281f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 3c 28 80 00       	push   $0x80283c
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
  800ced:	68 1f 28 80 00       	push   $0x80281f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 3c 28 80 00       	push   $0x80283c
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
  800d2f:	68 1f 28 80 00       	push   $0x80281f
  800d34:	6a 23                	push   $0x23
  800d36:	68 3c 28 80 00       	push   $0x80283c
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
  800d71:	68 1f 28 80 00       	push   $0x80281f
  800d76:	6a 23                	push   $0x23
  800d78:	68 3c 28 80 00       	push   $0x80283c
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
  800db3:	68 1f 28 80 00       	push   $0x80281f
  800db8:	6a 23                	push   $0x23
  800dba:	68 3c 28 80 00       	push   $0x80283c
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
  800df5:	68 1f 28 80 00       	push   $0x80281f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 3c 28 80 00       	push   $0x80283c
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
  800e59:	68 1f 28 80 00       	push   $0x80281f
  800e5e:	6a 23                	push   $0x23
  800e60:	68 3c 28 80 00       	push   $0x80283c
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

00800e72 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	53                   	push   %ebx
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e7c:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e7e:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e82:	74 2e                	je     800eb2 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	c1 ea 16             	shr    $0x16,%edx
  800e89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e90:	f6 c2 01             	test   $0x1,%dl
  800e93:	74 1d                	je     800eb2 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e95:	89 c2                	mov    %eax,%edx
  800e97:	c1 ea 0c             	shr    $0xc,%edx
  800e9a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ea1:	f6 c1 01             	test   $0x1,%cl
  800ea4:	74 0c                	je     800eb2 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ea6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ead:	f6 c6 08             	test   $0x8,%dh
  800eb0:	75 14                	jne    800ec6 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	68 4c 28 80 00       	push   $0x80284c
  800eba:	6a 21                	push   $0x21
  800ebc:	68 df 28 80 00       	push   $0x8028df
  800ec1:	e8 52 f3 ff ff       	call   800218 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800ec6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ecb:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 a3 fd ff ff       	call   800c81 <sys_page_alloc>
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	79 14                	jns    800ef9 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	68 ea 28 80 00       	push   $0x8028ea
  800eed:	6a 2b                	push   $0x2b
  800eef:	68 df 28 80 00       	push   $0x8028df
  800ef4:	e8 1f f3 ff ff       	call   800218 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	68 00 10 00 00       	push   $0x1000
  800f01:	53                   	push   %ebx
  800f02:	68 00 f0 7f 00       	push   $0x7ff000
  800f07:	e8 fe fa ff ff       	call   800a0a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800f0c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f13:	53                   	push   %ebx
  800f14:	6a 00                	push   $0x0
  800f16:	68 00 f0 7f 00       	push   $0x7ff000
  800f1b:	6a 00                	push   $0x0
  800f1d:	e8 a2 fd ff ff       	call   800cc4 <sys_page_map>
  800f22:	83 c4 20             	add    $0x20,%esp
  800f25:	85 c0                	test   %eax,%eax
  800f27:	79 14                	jns    800f3d <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	68 00 29 80 00       	push   $0x802900
  800f31:	6a 2e                	push   $0x2e
  800f33:	68 df 28 80 00       	push   $0x8028df
  800f38:	e8 db f2 ff ff       	call   800218 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	6a 00                	push   $0x0
  800f47:	e8 ba fd ff ff       	call   800d06 <sys_page_unmap>
  800f4c:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f5d:	68 72 0e 80 00       	push   $0x800e72
  800f62:	e8 6b 0f 00 00       	call   801ed2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f67:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6c:	cd 30                	int    $0x30
  800f6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	79 12                	jns    800f8a <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f78:	50                   	push   %eax
  800f79:	68 14 29 80 00       	push   $0x802914
  800f7e:	6a 6d                	push   $0x6d
  800f80:	68 df 28 80 00       	push   $0x8028df
  800f85:	e8 8e f2 ff ff       	call   800218 <_panic>
  800f8a:	89 c7                	mov    %eax,%edi
  800f8c:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f95:	75 21                	jne    800fb8 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f97:	e8 a7 fc ff ff       	call   800c43 <sys_getenvid>
  800f9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa9:	a3 40 44 80 00       	mov    %eax,0x804440
		return 0;
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb3:	e9 9c 01 00 00       	jmp    801154 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	c1 e8 16             	shr    $0x16,%eax
  800fbd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc4:	a8 01                	test   $0x1,%al
  800fc6:	0f 84 f3 00 00 00    	je     8010bf <fork+0x16b>
  800fcc:	89 d8                	mov    %ebx,%eax
  800fce:	c1 e8 0c             	shr    $0xc,%eax
  800fd1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd8:	f6 c2 01             	test   $0x1,%dl
  800fdb:	0f 84 de 00 00 00    	je     8010bf <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800fe1:	89 c6                	mov    %eax,%esi
  800fe3:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800fe6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fed:	f6 c6 04             	test   $0x4,%dh
  800ff0:	74 37                	je     801029 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800ff2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	25 07 0e 00 00       	and    $0xe07,%eax
  801001:	50                   	push   %eax
  801002:	56                   	push   %esi
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	6a 00                	push   $0x0
  801007:	e8 b8 fc ff ff       	call   800cc4 <sys_page_map>
  80100c:	83 c4 20             	add    $0x20,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	0f 89 a8 00 00 00    	jns    8010bf <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  801017:	50                   	push   %eax
  801018:	68 70 28 80 00       	push   $0x802870
  80101d:	6a 49                	push   $0x49
  80101f:	68 df 28 80 00       	push   $0x8028df
  801024:	e8 ef f1 ff ff       	call   800218 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801029:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801030:	f6 c6 08             	test   $0x8,%dh
  801033:	75 0b                	jne    801040 <fork+0xec>
  801035:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103c:	a8 02                	test   $0x2,%al
  80103e:	74 57                	je     801097 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	68 05 08 00 00       	push   $0x805
  801048:	56                   	push   %esi
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	6a 00                	push   $0x0
  80104d:	e8 72 fc ff ff       	call   800cc4 <sys_page_map>
  801052:	83 c4 20             	add    $0x20,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	79 12                	jns    80106b <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  801059:	50                   	push   %eax
  80105a:	68 70 28 80 00       	push   $0x802870
  80105f:	6a 4c                	push   $0x4c
  801061:	68 df 28 80 00       	push   $0x8028df
  801066:	e8 ad f1 ff ff       	call   800218 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	68 05 08 00 00       	push   $0x805
  801073:	56                   	push   %esi
  801074:	6a 00                	push   $0x0
  801076:	56                   	push   %esi
  801077:	6a 00                	push   $0x0
  801079:	e8 46 fc ff ff       	call   800cc4 <sys_page_map>
  80107e:	83 c4 20             	add    $0x20,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 3a                	jns    8010bf <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  801085:	50                   	push   %eax
  801086:	68 94 28 80 00       	push   $0x802894
  80108b:	6a 4e                	push   $0x4e
  80108d:	68 df 28 80 00       	push   $0x8028df
  801092:	e8 81 f1 ff ff       	call   800218 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	6a 05                	push   $0x5
  80109c:	56                   	push   %esi
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	6a 00                	push   $0x0
  8010a1:	e8 1e fc ff ff       	call   800cc4 <sys_page_map>
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	79 12                	jns    8010bf <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  8010ad:	50                   	push   %eax
  8010ae:	68 bc 28 80 00       	push   $0x8028bc
  8010b3:	6a 50                	push   $0x50
  8010b5:	68 df 28 80 00       	push   $0x8028df
  8010ba:	e8 59 f1 ff ff       	call   800218 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8010bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010cb:	0f 85 e7 fe ff ff    	jne    800fb8 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	6a 07                	push   $0x7
  8010d6:	68 00 f0 bf ee       	push   $0xeebff000
  8010db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010de:	e8 9e fb ff ff       	call   800c81 <sys_page_alloc>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 14                	jns    8010fe <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	68 24 29 80 00       	push   $0x802924
  8010f2:	6a 76                	push   $0x76
  8010f4:	68 df 28 80 00       	push   $0x8028df
  8010f9:	e8 1a f1 ff ff       	call   800218 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	68 41 1f 80 00       	push   $0x801f41
  801106:	ff 75 e4             	pushl  -0x1c(%ebp)
  801109:	e8 be fc ff ff       	call   800dcc <sys_env_set_pgfault_upcall>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 14                	jns    801129 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801115:	ff 75 e4             	pushl  -0x1c(%ebp)
  801118:	68 3e 29 80 00       	push   $0x80293e
  80111d:	6a 79                	push   $0x79
  80111f:	68 df 28 80 00       	push   $0x8028df
  801124:	e8 ef f0 ff ff       	call   800218 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	6a 02                	push   $0x2
  80112e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801131:	e8 12 fc ff ff       	call   800d48 <sys_env_set_status>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	79 14                	jns    801151 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80113d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801140:	68 5b 29 80 00       	push   $0x80295b
  801145:	6a 7b                	push   $0x7b
  801147:	68 df 28 80 00       	push   $0x8028df
  80114c:	e8 c7 f0 ff ff       	call   800218 <_panic>
        return forkid;
  801151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801154:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sfork>:

// Challenge!
int
sfork(void)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801162:	68 72 29 80 00       	push   $0x802972
  801167:	68 83 00 00 00       	push   $0x83
  80116c:	68 df 28 80 00       	push   $0x8028df
  801171:	e8 a2 f0 ff ff       	call   800218 <_panic>

00801176 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	05 00 00 00 30       	add    $0x30000000,%eax
  801181:	c1 e8 0c             	shr    $0xc,%eax
}
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801189:	8b 45 08             	mov    0x8(%ebp),%eax
  80118c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801191:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801196:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	c1 ea 16             	shr    $0x16,%edx
  8011ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b4:	f6 c2 01             	test   $0x1,%dl
  8011b7:	74 11                	je     8011ca <fd_alloc+0x2d>
  8011b9:	89 c2                	mov    %eax,%edx
  8011bb:	c1 ea 0c             	shr    $0xc,%edx
  8011be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c5:	f6 c2 01             	test   $0x1,%dl
  8011c8:	75 09                	jne    8011d3 <fd_alloc+0x36>
			*fd_store = fd;
  8011ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d1:	eb 17                	jmp    8011ea <fd_alloc+0x4d>
  8011d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011dd:	75 c9                	jne    8011a8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f2:	83 f8 1f             	cmp    $0x1f,%eax
  8011f5:	77 36                	ja     80122d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f7:	c1 e0 0c             	shl    $0xc,%eax
  8011fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 ea 16             	shr    $0x16,%edx
  801204:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	74 24                	je     801234 <fd_lookup+0x48>
  801210:	89 c2                	mov    %eax,%edx
  801212:	c1 ea 0c             	shr    $0xc,%edx
  801215:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121c:	f6 c2 01             	test   $0x1,%dl
  80121f:	74 1a                	je     80123b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801221:	8b 55 0c             	mov    0xc(%ebp),%edx
  801224:	89 02                	mov    %eax,(%edx)
	return 0;
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
  80122b:	eb 13                	jmp    801240 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb 0c                	jmp    801240 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb 05                	jmp    801240 <fd_lookup+0x54>
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124b:	ba 04 2a 80 00       	mov    $0x802a04,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801250:	eb 13                	jmp    801265 <dev_lookup+0x23>
  801252:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801255:	39 08                	cmp    %ecx,(%eax)
  801257:	75 0c                	jne    801265 <dev_lookup+0x23>
			*dev = devtab[i];
  801259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 2e                	jmp    801293 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801265:	8b 02                	mov    (%edx),%eax
  801267:	85 c0                	test   %eax,%eax
  801269:	75 e7                	jne    801252 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126b:	a1 40 44 80 00       	mov    0x804440,%eax
  801270:	8b 40 48             	mov    0x48(%eax),%eax
  801273:	83 ec 04             	sub    $0x4,%esp
  801276:	51                   	push   %ecx
  801277:	50                   	push   %eax
  801278:	68 88 29 80 00       	push   $0x802988
  80127d:	e8 6f f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801282:	8b 45 0c             	mov    0xc(%ebp),%eax
  801285:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 10             	sub    $0x10,%esp
  80129d:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ad:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b0:	50                   	push   %eax
  8012b1:	e8 36 ff ff ff       	call   8011ec <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 05                	js     8012c2 <fd_close+0x2d>
	    || fd != fd2)
  8012bd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c0:	74 0c                	je     8012ce <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c2:	84 db                	test   %bl,%bl
  8012c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c9:	0f 44 c2             	cmove  %edx,%eax
  8012cc:	eb 41                	jmp    80130f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	ff 36                	pushl  (%esi)
  8012d7:	e8 66 ff ff ff       	call   801242 <dev_lookup>
  8012dc:	89 c3                	mov    %eax,%ebx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 1a                	js     8012ff <fd_close+0x6a>
		if (dev->dev_close)
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	74 0b                	je     8012ff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f4:	83 ec 0c             	sub    $0xc,%esp
  8012f7:	56                   	push   %esi
  8012f8:	ff d0                	call   *%eax
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	56                   	push   %esi
  801303:	6a 00                	push   $0x0
  801305:	e8 fc f9 ff ff       	call   800d06 <sys_page_unmap>
	return r;
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	89 d8                	mov    %ebx,%eax
}
  80130f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	ff 75 08             	pushl  0x8(%ebp)
  801323:	e8 c4 fe ff ff       	call   8011ec <fd_lookup>
  801328:	89 c2                	mov    %eax,%edx
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	85 d2                	test   %edx,%edx
  80132f:	78 10                	js     801341 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	6a 01                	push   $0x1
  801336:	ff 75 f4             	pushl  -0xc(%ebp)
  801339:	e8 57 ff ff ff       	call   801295 <fd_close>
  80133e:	83 c4 10             	add    $0x10,%esp
}
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <close_all>:

void
close_all(void)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	53                   	push   %ebx
  801347:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	53                   	push   %ebx
  801353:	e8 be ff ff ff       	call   801316 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801358:	83 c3 01             	add    $0x1,%ebx
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	83 fb 20             	cmp    $0x20,%ebx
  801361:	75 ec                	jne    80134f <close_all+0xc>
		close(i);
}
  801363:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	57                   	push   %edi
  80136c:	56                   	push   %esi
  80136d:	53                   	push   %ebx
  80136e:	83 ec 2c             	sub    $0x2c,%esp
  801371:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801374:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 6c fe ff ff       	call   8011ec <fd_lookup>
  801380:	89 c2                	mov    %eax,%edx
  801382:	83 c4 08             	add    $0x8,%esp
  801385:	85 d2                	test   %edx,%edx
  801387:	0f 88 c1 00 00 00    	js     80144e <dup+0xe6>
		return r;
	close(newfdnum);
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	56                   	push   %esi
  801391:	e8 80 ff ff ff       	call   801316 <close>

	newfd = INDEX2FD(newfdnum);
  801396:	89 f3                	mov    %esi,%ebx
  801398:	c1 e3 0c             	shl    $0xc,%ebx
  80139b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a1:	83 c4 04             	add    $0x4,%esp
  8013a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a7:	e8 da fd ff ff       	call   801186 <fd2data>
  8013ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ae:	89 1c 24             	mov    %ebx,(%esp)
  8013b1:	e8 d0 fd ff ff       	call   801186 <fd2data>
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bc:	89 f8                	mov    %edi,%eax
  8013be:	c1 e8 16             	shr    $0x16,%eax
  8013c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c8:	a8 01                	test   $0x1,%al
  8013ca:	74 37                	je     801403 <dup+0x9b>
  8013cc:	89 f8                	mov    %edi,%eax
  8013ce:	c1 e8 0c             	shr    $0xc,%eax
  8013d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d8:	f6 c2 01             	test   $0x1,%dl
  8013db:	74 26                	je     801403 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ec:	50                   	push   %eax
  8013ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f0:	6a 00                	push   $0x0
  8013f2:	57                   	push   %edi
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 ca f8 ff ff       	call   800cc4 <sys_page_map>
  8013fa:	89 c7                	mov    %eax,%edi
  8013fc:	83 c4 20             	add    $0x20,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 2e                	js     801431 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801403:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801406:	89 d0                	mov    %edx,%eax
  801408:	c1 e8 0c             	shr    $0xc,%eax
  80140b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	25 07 0e 00 00       	and    $0xe07,%eax
  80141a:	50                   	push   %eax
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	52                   	push   %edx
  80141f:	6a 00                	push   $0x0
  801421:	e8 9e f8 ff ff       	call   800cc4 <sys_page_map>
  801426:	89 c7                	mov    %eax,%edi
  801428:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142d:	85 ff                	test   %edi,%edi
  80142f:	79 1d                	jns    80144e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	53                   	push   %ebx
  801435:	6a 00                	push   $0x0
  801437:	e8 ca f8 ff ff       	call   800d06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801442:	6a 00                	push   $0x0
  801444:	e8 bd f8 ff ff       	call   800d06 <sys_page_unmap>
	return r;
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	89 f8                	mov    %edi,%eax
}
  80144e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 14             	sub    $0x14,%esp
  80145d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801460:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	53                   	push   %ebx
  801465:	e8 82 fd ff ff       	call   8011ec <fd_lookup>
  80146a:	83 c4 08             	add    $0x8,%esp
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 6d                	js     8014e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147d:	ff 30                	pushl  (%eax)
  80147f:	e8 be fd ff ff       	call   801242 <dev_lookup>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 4c                	js     8014d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148e:	8b 42 08             	mov    0x8(%edx),%eax
  801491:	83 e0 03             	and    $0x3,%eax
  801494:	83 f8 01             	cmp    $0x1,%eax
  801497:	75 21                	jne    8014ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801499:	a1 40 44 80 00       	mov    0x804440,%eax
  80149e:	8b 40 48             	mov    0x48(%eax),%eax
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	50                   	push   %eax
  8014a6:	68 c9 29 80 00       	push   $0x8029c9
  8014ab:	e8 41 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b8:	eb 26                	jmp    8014e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bd:	8b 40 08             	mov    0x8(%eax),%eax
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	74 17                	je     8014db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c4:	83 ec 04             	sub    $0x4,%esp
  8014c7:	ff 75 10             	pushl  0x10(%ebp)
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	52                   	push   %edx
  8014ce:	ff d0                	call   *%eax
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb 09                	jmp    8014e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	eb 05                	jmp    8014e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	57                   	push   %edi
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fb:	eb 21                	jmp    80151e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fd:	83 ec 04             	sub    $0x4,%esp
  801500:	89 f0                	mov    %esi,%eax
  801502:	29 d8                	sub    %ebx,%eax
  801504:	50                   	push   %eax
  801505:	89 d8                	mov    %ebx,%eax
  801507:	03 45 0c             	add    0xc(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	57                   	push   %edi
  80150c:	e8 45 ff ff ff       	call   801456 <read>
		if (m < 0)
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 0c                	js     801524 <readn+0x3d>
			return m;
		if (m == 0)
  801518:	85 c0                	test   %eax,%eax
  80151a:	74 06                	je     801522 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151c:	01 c3                	add    %eax,%ebx
  80151e:	39 f3                	cmp    %esi,%ebx
  801520:	72 db                	jb     8014fd <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801522:	89 d8                	mov    %ebx,%eax
}
  801524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	53                   	push   %ebx
  801530:	83 ec 14             	sub    $0x14,%esp
  801533:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801536:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	53                   	push   %ebx
  80153b:	e8 ac fc ff ff       	call   8011ec <fd_lookup>
  801540:	83 c4 08             	add    $0x8,%esp
  801543:	89 c2                	mov    %eax,%edx
  801545:	85 c0                	test   %eax,%eax
  801547:	78 68                	js     8015b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801553:	ff 30                	pushl  (%eax)
  801555:	e8 e8 fc ff ff       	call   801242 <dev_lookup>
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 47                	js     8015a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801568:	75 21                	jne    80158b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156a:	a1 40 44 80 00       	mov    0x804440,%eax
  80156f:	8b 40 48             	mov    0x48(%eax),%eax
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	53                   	push   %ebx
  801576:	50                   	push   %eax
  801577:	68 e5 29 80 00       	push   $0x8029e5
  80157c:	e8 70 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801589:	eb 26                	jmp    8015b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158e:	8b 52 0c             	mov    0xc(%edx),%edx
  801591:	85 d2                	test   %edx,%edx
  801593:	74 17                	je     8015ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	ff 75 10             	pushl  0x10(%ebp)
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	50                   	push   %eax
  80159f:	ff d2                	call   *%edx
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb 09                	jmp    8015b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	eb 05                	jmp    8015b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	ff 75 08             	pushl  0x8(%ebp)
  8015c5:	e8 22 fc ff ff       	call   8011ec <fd_lookup>
  8015ca:	83 c4 08             	add    $0x8,%esp
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 0e                	js     8015df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 14             	sub    $0x14,%esp
  8015e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	53                   	push   %ebx
  8015f0:	e8 f7 fb ff ff       	call   8011ec <fd_lookup>
  8015f5:	83 c4 08             	add    $0x8,%esp
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 65                	js     801663 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fe:	83 ec 08             	sub    $0x8,%esp
  801601:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801608:	ff 30                	pushl  (%eax)
  80160a:	e8 33 fc ff ff       	call   801242 <dev_lookup>
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 44                	js     80165a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801619:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161d:	75 21                	jne    801640 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80161f:	a1 40 44 80 00       	mov    0x804440,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801624:	8b 40 48             	mov    0x48(%eax),%eax
  801627:	83 ec 04             	sub    $0x4,%esp
  80162a:	53                   	push   %ebx
  80162b:	50                   	push   %eax
  80162c:	68 a8 29 80 00       	push   $0x8029a8
  801631:	e8 bb ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163e:	eb 23                	jmp    801663 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801640:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801643:	8b 52 18             	mov    0x18(%edx),%edx
  801646:	85 d2                	test   %edx,%edx
  801648:	74 14                	je     80165e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	ff 75 0c             	pushl  0xc(%ebp)
  801650:	50                   	push   %eax
  801651:	ff d2                	call   *%edx
  801653:	89 c2                	mov    %eax,%edx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb 09                	jmp    801663 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	eb 05                	jmp    801663 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80165e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801663:	89 d0                	mov    %edx,%eax
  801665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 14             	sub    $0x14,%esp
  801671:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	e8 6c fb ff ff       	call   8011ec <fd_lookup>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	89 c2                	mov    %eax,%edx
  801685:	85 c0                	test   %eax,%eax
  801687:	78 58                	js     8016e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	ff 30                	pushl  (%eax)
  801695:	e8 a8 fb ff ff       	call   801242 <dev_lookup>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 37                	js     8016d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a8:	74 32                	je     8016dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b4:	00 00 00 
	stat->st_isdir = 0;
  8016b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016be:	00 00 00 
	stat->st_dev = dev;
  8016c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	53                   	push   %ebx
  8016cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ce:	ff 50 14             	call   *0x14(%eax)
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	eb 09                	jmp    8016e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	eb 05                	jmp    8016e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e1:	89 d0                	mov    %edx,%eax
  8016e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	6a 00                	push   $0x0
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 09 02 00 00       	call   801903 <open>
  8016fa:	89 c3                	mov    %eax,%ebx
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 db                	test   %ebx,%ebx
  801701:	78 1b                	js     80171e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	53                   	push   %ebx
  80170a:	e8 5b ff ff ff       	call   80166a <fstat>
  80170f:	89 c6                	mov    %eax,%esi
	close(fd);
  801711:	89 1c 24             	mov    %ebx,(%esp)
  801714:	e8 fd fb ff ff       	call   801316 <close>
	return r;
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	89 f0                	mov    %esi,%eax
}
  80171e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	89 c6                	mov    %eax,%esi
  80172c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80172e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801735:	75 12                	jne    801749 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	6a 01                	push   $0x1
  80173c:	e8 e1 08 00 00       	call   802022 <ipc_find_env>
  801741:	a3 00 40 80 00       	mov    %eax,0x804000
  801746:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801749:	6a 07                	push   $0x7
  80174b:	68 00 50 80 00       	push   $0x805000
  801750:	56                   	push   %esi
  801751:	ff 35 00 40 80 00    	pushl  0x804000
  801757:	e8 72 08 00 00       	call   801fce <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175c:	83 c4 0c             	add    $0xc,%esp
  80175f:	6a 00                	push   $0x0
  801761:	53                   	push   %ebx
  801762:	6a 00                	push   $0x0
  801764:	e8 fc 07 00 00       	call   801f65 <ipc_recv>
}
  801769:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176c:	5b                   	pop    %ebx
  80176d:	5e                   	pop    %esi
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    

00801770 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	8b 40 0c             	mov    0xc(%eax),%eax
  80177c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801781:	8b 45 0c             	mov    0xc(%ebp),%eax
  801784:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 02 00 00 00       	mov    $0x2,%eax
  801793:	e8 8d ff ff ff       	call   801725 <fsipc>
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b5:	e8 6b ff ff ff       	call   801725 <fsipc>
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 04             	sub    $0x4,%esp
  8017c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8017db:	e8 45 ff ff ff       	call   801725 <fsipc>
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	85 d2                	test   %edx,%edx
  8017e4:	78 2c                	js     801812 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	68 00 50 80 00       	push   $0x805000
  8017ee:	53                   	push   %ebx
  8017ef:	e8 84 f0 ff ff       	call   800878 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801804:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	57                   	push   %edi
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80182e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801831:	eb 3d                	jmp    801870 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801833:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801839:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80183e:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801841:	83 ec 04             	sub    $0x4,%esp
  801844:	57                   	push   %edi
  801845:	53                   	push   %ebx
  801846:	68 08 50 80 00       	push   $0x805008
  80184b:	e8 ba f1 ff ff       	call   800a0a <memmove>
                fsipcbuf.write.req_n = tmp; 
  801850:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 04 00 00 00       	mov    $0x4,%eax
  801860:	e8 c0 fe ff ff       	call   801725 <fsipc>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 0d                	js     801879 <devfile_write+0x62>
		        return r;
                n -= tmp;
  80186c:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80186e:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801870:	85 f6                	test   %esi,%esi
  801872:	75 bf                	jne    801833 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801874:	89 d8                	mov    %ebx,%eax
  801876:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801879:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5f                   	pop    %edi
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801894:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189a:	ba 00 00 00 00       	mov    $0x0,%edx
  80189f:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a4:	e8 7c fe ff ff       	call   801725 <fsipc>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 4b                	js     8018fa <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018af:	39 c6                	cmp    %eax,%esi
  8018b1:	73 16                	jae    8018c9 <devfile_read+0x48>
  8018b3:	68 14 2a 80 00       	push   $0x802a14
  8018b8:	68 1b 2a 80 00       	push   $0x802a1b
  8018bd:	6a 7c                	push   $0x7c
  8018bf:	68 30 2a 80 00       	push   $0x802a30
  8018c4:	e8 4f e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8018c9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ce:	7e 16                	jle    8018e6 <devfile_read+0x65>
  8018d0:	68 3b 2a 80 00       	push   $0x802a3b
  8018d5:	68 1b 2a 80 00       	push   $0x802a1b
  8018da:	6a 7d                	push   $0x7d
  8018dc:	68 30 2a 80 00       	push   $0x802a30
  8018e1:	e8 32 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	50                   	push   %eax
  8018ea:	68 00 50 80 00       	push   $0x805000
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	e8 13 f1 ff ff       	call   800a0a <memmove>
	return r;
  8018f7:	83 c4 10             	add    $0x10,%esp
}
  8018fa:	89 d8                	mov    %ebx,%eax
  8018fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 20             	sub    $0x20,%esp
  80190a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190d:	53                   	push   %ebx
  80190e:	e8 2c ef ff ff       	call   80083f <strlen>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191b:	7f 67                	jg     801984 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191d:	83 ec 0c             	sub    $0xc,%esp
  801920:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801923:	50                   	push   %eax
  801924:	e8 74 f8 ff ff       	call   80119d <fd_alloc>
  801929:	83 c4 10             	add    $0x10,%esp
		return r;
  80192c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 57                	js     801989 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	53                   	push   %ebx
  801936:	68 00 50 80 00       	push   $0x805000
  80193b:	e8 38 ef ff ff       	call   800878 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801940:	8b 45 0c             	mov    0xc(%ebp),%eax
  801943:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801948:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194b:	b8 01 00 00 00       	mov    $0x1,%eax
  801950:	e8 d0 fd ff ff       	call   801725 <fsipc>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	85 c0                	test   %eax,%eax
  80195c:	79 14                	jns    801972 <open+0x6f>
		fd_close(fd, 0);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	6a 00                	push   $0x0
  801963:	ff 75 f4             	pushl  -0xc(%ebp)
  801966:	e8 2a f9 ff ff       	call   801295 <fd_close>
		return r;
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	89 da                	mov    %ebx,%edx
  801970:	eb 17                	jmp    801989 <open+0x86>
	}

	return fd2num(fd);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	ff 75 f4             	pushl  -0xc(%ebp)
  801978:	e8 f9 f7 ff ff       	call   801176 <fd2num>
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	eb 05                	jmp    801989 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801984:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801989:	89 d0                	mov    %edx,%eax
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801996:	ba 00 00 00 00       	mov    $0x0,%edx
  80199b:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a0:	e8 80 fd ff ff       	call   801725 <fsipc>
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
  8019ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff 75 08             	pushl  0x8(%ebp)
  8019b5:	e8 cc f7 ff ff       	call   801186 <fd2data>
  8019ba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bc:	83 c4 08             	add    $0x8,%esp
  8019bf:	68 47 2a 80 00       	push   $0x802a47
  8019c4:	53                   	push   %ebx
  8019c5:	e8 ae ee ff ff       	call   800878 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ca:	8b 56 04             	mov    0x4(%esi),%edx
  8019cd:	89 d0                	mov    %edx,%eax
  8019cf:	2b 06                	sub    (%esi),%eax
  8019d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019de:	00 00 00 
	stat->st_dev = &devpipe;
  8019e1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e8:	30 80 00 
	return 0;
}
  8019eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a01:	53                   	push   %ebx
  801a02:	6a 00                	push   $0x0
  801a04:	e8 fd f2 ff ff       	call   800d06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a09:	89 1c 24             	mov    %ebx,(%esp)
  801a0c:	e8 75 f7 ff ff       	call   801186 <fd2data>
  801a11:	83 c4 08             	add    $0x8,%esp
  801a14:	50                   	push   %eax
  801a15:	6a 00                	push   $0x0
  801a17:	e8 ea f2 ff ff       	call   800d06 <sys_page_unmap>
}
  801a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 1c             	sub    $0x1c,%esp
  801a2a:	89 c6                	mov    %eax,%esi
  801a2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2f:	a1 40 44 80 00       	mov    0x804440,%eax
  801a34:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	56                   	push   %esi
  801a3b:	e8 1a 06 00 00       	call   80205a <pageref>
  801a40:	89 c7                	mov    %eax,%edi
  801a42:	83 c4 04             	add    $0x4,%esp
  801a45:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a48:	e8 0d 06 00 00       	call   80205a <pageref>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	39 c7                	cmp    %eax,%edi
  801a52:	0f 94 c2             	sete   %dl
  801a55:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a58:	8b 0d 40 44 80 00    	mov    0x804440,%ecx
  801a5e:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a61:	39 fb                	cmp    %edi,%ebx
  801a63:	74 19                	je     801a7e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801a65:	84 d2                	test   %dl,%dl
  801a67:	74 c6                	je     801a2f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a69:	8b 51 58             	mov    0x58(%ecx),%edx
  801a6c:	50                   	push   %eax
  801a6d:	52                   	push   %edx
  801a6e:	53                   	push   %ebx
  801a6f:	68 4e 2a 80 00       	push   $0x802a4e
  801a74:	e8 78 e8 ff ff       	call   8002f1 <cprintf>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb b1                	jmp    801a2f <_pipeisclosed+0xe>
	}
}
  801a7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 28             	sub    $0x28,%esp
  801a8f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a92:	56                   	push   %esi
  801a93:	e8 ee f6 ff ff       	call   801186 <fd2data>
  801a98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa2:	eb 4b                	jmp    801aef <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa4:	89 da                	mov    %ebx,%edx
  801aa6:	89 f0                	mov    %esi,%eax
  801aa8:	e8 74 ff ff ff       	call   801a21 <_pipeisclosed>
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	75 48                	jne    801af9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab1:	e8 ac f1 ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ab9:	8b 0b                	mov    (%ebx),%ecx
  801abb:	8d 51 20             	lea    0x20(%ecx),%edx
  801abe:	39 d0                	cmp    %edx,%eax
  801ac0:	73 e2                	jae    801aa4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ac9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	c1 fa 1f             	sar    $0x1f,%edx
  801ad1:	89 d1                	mov    %edx,%ecx
  801ad3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ad6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ad9:	83 e2 1f             	and    $0x1f,%edx
  801adc:	29 ca                	sub    %ecx,%edx
  801ade:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae6:	83 c0 01             	add    $0x1,%eax
  801ae9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aec:	83 c7 01             	add    $0x1,%edi
  801aef:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af2:	75 c2                	jne    801ab6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af4:	8b 45 10             	mov    0x10(%ebp),%eax
  801af7:	eb 05                	jmp    801afe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	57                   	push   %edi
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 18             	sub    $0x18,%esp
  801b0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b12:	57                   	push   %edi
  801b13:	e8 6e f6 ff ff       	call   801186 <fd2data>
  801b18:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b22:	eb 3d                	jmp    801b61 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b24:	85 db                	test   %ebx,%ebx
  801b26:	74 04                	je     801b2c <devpipe_read+0x26>
				return i;
  801b28:	89 d8                	mov    %ebx,%eax
  801b2a:	eb 44                	jmp    801b70 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b2c:	89 f2                	mov    %esi,%edx
  801b2e:	89 f8                	mov    %edi,%eax
  801b30:	e8 ec fe ff ff       	call   801a21 <_pipeisclosed>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	75 32                	jne    801b6b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b39:	e8 24 f1 ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b3e:	8b 06                	mov    (%esi),%eax
  801b40:	3b 46 04             	cmp    0x4(%esi),%eax
  801b43:	74 df                	je     801b24 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b45:	99                   	cltd   
  801b46:	c1 ea 1b             	shr    $0x1b,%edx
  801b49:	01 d0                	add    %edx,%eax
  801b4b:	83 e0 1f             	and    $0x1f,%eax
  801b4e:	29 d0                	sub    %edx,%eax
  801b50:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b58:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b5b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5e:	83 c3 01             	add    $0x1,%ebx
  801b61:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b64:	75 d8                	jne    801b3e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b66:	8b 45 10             	mov    0x10(%ebp),%eax
  801b69:	eb 05                	jmp    801b70 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	56                   	push   %esi
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b83:	50                   	push   %eax
  801b84:	e8 14 f6 ff ff       	call   80119d <fd_alloc>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	0f 88 2c 01 00 00    	js     801cc2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b96:	83 ec 04             	sub    $0x4,%esp
  801b99:	68 07 04 00 00       	push   $0x407
  801b9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba1:	6a 00                	push   $0x0
  801ba3:	e8 d9 f0 ff ff       	call   800c81 <sys_page_alloc>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	89 c2                	mov    %eax,%edx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 0d 01 00 00    	js     801cc2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bbb:	50                   	push   %eax
  801bbc:	e8 dc f5 ff ff       	call   80119d <fd_alloc>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	0f 88 e2 00 00 00    	js     801cb0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	68 07 04 00 00       	push   $0x407
  801bd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 a1 f0 ff ff       	call   800c81 <sys_page_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 c3 00 00 00    	js     801cb0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	e8 8e f5 ff ff       	call   801186 <fd2data>
  801bf8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfa:	83 c4 0c             	add    $0xc,%esp
  801bfd:	68 07 04 00 00       	push   $0x407
  801c02:	50                   	push   %eax
  801c03:	6a 00                	push   $0x0
  801c05:	e8 77 f0 ff ff       	call   800c81 <sys_page_alloc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 89 00 00 00    	js     801ca0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1d:	e8 64 f5 ff ff       	call   801186 <fd2data>
  801c22:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c29:	50                   	push   %eax
  801c2a:	6a 00                	push   $0x0
  801c2c:	56                   	push   %esi
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 90 f0 ff ff       	call   800cc4 <sys_page_map>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	83 c4 20             	add    $0x20,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 55                	js     801c92 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c52:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c60:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6d:	e8 04 f5 ff ff       	call   801176 <fd2num>
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c75:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c77:	83 c4 04             	add    $0x4,%esp
  801c7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7d:	e8 f4 f4 ff ff       	call   801176 <fd2num>
  801c82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c85:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c90:	eb 30                	jmp    801cc2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c92:	83 ec 08             	sub    $0x8,%esp
  801c95:	56                   	push   %esi
  801c96:	6a 00                	push   $0x0
  801c98:	e8 69 f0 ff ff       	call   800d06 <sys_page_unmap>
  801c9d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 59 f0 ff ff       	call   800d06 <sys_page_unmap>
  801cad:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 49 f0 ff ff       	call   800d06 <sys_page_unmap>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	ff 75 08             	pushl  0x8(%ebp)
  801cd8:	e8 0f f5 ff ff       	call   8011ec <fd_lookup>
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 d2                	test   %edx,%edx
  801ce4:	78 18                	js     801cfe <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	e8 95 f4 ff ff       	call   801186 <fd2data>
	return _pipeisclosed(fd, p);
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	e8 26 fd ff ff       	call   801a21 <_pipeisclosed>
  801cfb:	83 c4 10             	add    $0x10,%esp
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d08:	85 f6                	test   %esi,%esi
  801d0a:	75 16                	jne    801d22 <wait+0x22>
  801d0c:	68 66 2a 80 00       	push   $0x802a66
  801d11:	68 1b 2a 80 00       	push   $0x802a1b
  801d16:	6a 09                	push   $0x9
  801d18:	68 71 2a 80 00       	push   $0x802a71
  801d1d:	e8 f6 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d22:	89 f3                	mov    %esi,%ebx
  801d24:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d2a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d2d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d33:	eb 05                	jmp    801d3a <wait+0x3a>
		sys_yield();
  801d35:	e8 28 ef ff ff       	call   800c62 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d3a:	8b 43 48             	mov    0x48(%ebx),%eax
  801d3d:	39 f0                	cmp    %esi,%eax
  801d3f:	75 07                	jne    801d48 <wait+0x48>
  801d41:	8b 43 54             	mov    0x54(%ebx),%eax
  801d44:	85 c0                	test   %eax,%eax
  801d46:	75 ed                	jne    801d35 <wait+0x35>
		sys_yield();
}
  801d48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    

00801d59 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d5f:	68 7c 2a 80 00       	push   $0x802a7c
  801d64:	ff 75 0c             	pushl  0xc(%ebp)
  801d67:	e8 0c eb ff ff       	call   800878 <strcpy>
	return 0;
}
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	57                   	push   %edi
  801d77:	56                   	push   %esi
  801d78:	53                   	push   %ebx
  801d79:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d84:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8a:	eb 2d                	jmp    801db9 <devcons_write+0x46>
		m = n - tot;
  801d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d8f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d91:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d94:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d99:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	53                   	push   %ebx
  801da0:	03 45 0c             	add    0xc(%ebp),%eax
  801da3:	50                   	push   %eax
  801da4:	57                   	push   %edi
  801da5:	e8 60 ec ff ff       	call   800a0a <memmove>
		sys_cputs(buf, m);
  801daa:	83 c4 08             	add    $0x8,%esp
  801dad:	53                   	push   %ebx
  801dae:	57                   	push   %edi
  801daf:	e8 11 ee ff ff       	call   800bc5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db4:	01 de                	add    %ebx,%esi
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbe:	72 cc                	jb     801d8c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801dd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd7:	75 07                	jne    801de0 <devcons_read+0x18>
  801dd9:	eb 28                	jmp    801e03 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ddb:	e8 82 ee ff ff       	call   800c62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de0:	e8 fe ed ff ff       	call   800be3 <sys_cgetc>
  801de5:	85 c0                	test   %eax,%eax
  801de7:	74 f2                	je     801ddb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 16                	js     801e03 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ded:	83 f8 04             	cmp    $0x4,%eax
  801df0:	74 0c                	je     801dfe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df5:	88 02                	mov    %al,(%edx)
	return 1;
  801df7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfc:	eb 05                	jmp    801e03 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e11:	6a 01                	push   $0x1
  801e13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	e8 a9 ed ff ff       	call   800bc5 <sys_cputs>
  801e1c:	83 c4 10             	add    $0x10,%esp
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <getchar>:

int
getchar(void)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e27:	6a 01                	push   $0x1
  801e29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2c:	50                   	push   %eax
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 22 f6 ff ff       	call   801456 <read>
	if (r < 0)
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 0f                	js     801e4a <getchar+0x29>
		return r;
	if (r < 1)
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	7e 06                	jle    801e45 <getchar+0x24>
		return -E_EOF;
	return c;
  801e3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e43:	eb 05                	jmp    801e4a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	ff 75 08             	pushl  0x8(%ebp)
  801e59:	e8 8e f3 ff ff       	call   8011ec <fd_lookup>
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 11                	js     801e76 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e68:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6e:	39 10                	cmp    %edx,(%eax)
  801e70:	0f 94 c0             	sete   %al
  801e73:	0f b6 c0             	movzbl %al,%eax
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <opencons>:

int
opencons(void)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e81:	50                   	push   %eax
  801e82:	e8 16 f3 ff ff       	call   80119d <fd_alloc>
  801e87:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 3e                	js     801ece <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	68 07 04 00 00       	push   $0x407
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 df ed ff ff       	call   800c81 <sys_page_alloc>
  801ea2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 23                	js     801ece <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	50                   	push   %eax
  801ec4:	e8 ad f2 ff ff       	call   801176 <fd2num>
  801ec9:	89 c2                	mov    %eax,%edx
  801ecb:	83 c4 10             	add    $0x10,%esp
}
  801ece:	89 d0                	mov    %edx,%eax
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801edf:	75 2c                	jne    801f0d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801ee1:	83 ec 04             	sub    $0x4,%esp
  801ee4:	6a 07                	push   $0x7
  801ee6:	68 00 f0 bf ee       	push   $0xeebff000
  801eeb:	6a 00                	push   $0x0
  801eed:	e8 8f ed ff ff       	call   800c81 <sys_page_alloc>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	74 14                	je     801f0d <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	68 88 2a 80 00       	push   $0x802a88
  801f01:	6a 21                	push   $0x21
  801f03:	68 ec 2a 80 00       	push   $0x802aec
  801f08:	e8 0b e3 ff ff       	call   800218 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	68 41 1f 80 00       	push   $0x801f41
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 a8 ee ff ff       	call   800dcc <sys_env_set_pgfault_upcall>
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	79 14                	jns    801f3f <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	68 b4 2a 80 00       	push   $0x802ab4
  801f33:	6a 29                	push   $0x29
  801f35:	68 ec 2a 80 00       	push   $0x802aec
  801f3a:	e8 d9 e2 ff ff       	call   800218 <_panic>
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f41:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f42:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f47:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f49:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801f4c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801f51:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801f55:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801f59:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801f5b:	83 c4 08             	add    $0x8,%esp
        popal
  801f5e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f5f:	83 c4 04             	add    $0x4,%esp
        popfl
  801f62:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801f63:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f64:	c3                   	ret    

00801f65 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	56                   	push   %esi
  801f69:	53                   	push   %ebx
  801f6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f73:	85 c0                	test   %eax,%eax
  801f75:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f7a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f7d:	83 ec 0c             	sub    $0xc,%esp
  801f80:	50                   	push   %eax
  801f81:	e8 ab ee ff ff       	call   800e31 <sys_ipc_recv>
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	79 16                	jns    801fa3 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f8d:	85 f6                	test   %esi,%esi
  801f8f:	74 06                	je     801f97 <ipc_recv+0x32>
  801f91:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f97:	85 db                	test   %ebx,%ebx
  801f99:	74 2c                	je     801fc7 <ipc_recv+0x62>
  801f9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fa1:	eb 24                	jmp    801fc7 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801fa3:	85 f6                	test   %esi,%esi
  801fa5:	74 0a                	je     801fb1 <ipc_recv+0x4c>
  801fa7:	a1 40 44 80 00       	mov    0x804440,%eax
  801fac:	8b 40 74             	mov    0x74(%eax),%eax
  801faf:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801fb1:	85 db                	test   %ebx,%ebx
  801fb3:	74 0a                	je     801fbf <ipc_recv+0x5a>
  801fb5:	a1 40 44 80 00       	mov    0x804440,%eax
  801fba:	8b 40 78             	mov    0x78(%eax),%eax
  801fbd:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801fbf:	a1 40 44 80 00       	mov    0x804440,%eax
  801fc4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fca:	5b                   	pop    %ebx
  801fcb:	5e                   	pop    %esi
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    

00801fce <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fda:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fe7:	0f 44 d8             	cmove  %eax,%ebx
  801fea:	eb 1c                	jmp    802008 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fef:	74 12                	je     802003 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ff1:	50                   	push   %eax
  801ff2:	68 fa 2a 80 00       	push   $0x802afa
  801ff7:	6a 39                	push   $0x39
  801ff9:	68 15 2b 80 00       	push   $0x802b15
  801ffe:	e8 15 e2 ff ff       	call   800218 <_panic>
                 sys_yield();
  802003:	e8 5a ec ff ff       	call   800c62 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802008:	ff 75 14             	pushl  0x14(%ebp)
  80200b:	53                   	push   %ebx
  80200c:	56                   	push   %esi
  80200d:	57                   	push   %edi
  80200e:	e8 fb ed ff ff       	call   800e0e <sys_ipc_try_send>
  802013:	83 c4 10             	add    $0x10,%esp
  802016:	85 c0                	test   %eax,%eax
  802018:	78 d2                	js     801fec <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80201a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    

00802022 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802028:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80202d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802030:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802036:	8b 52 50             	mov    0x50(%edx),%edx
  802039:	39 ca                	cmp    %ecx,%edx
  80203b:	75 0d                	jne    80204a <ipc_find_env+0x28>
			return envs[i].env_id;
  80203d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802040:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802045:	8b 40 08             	mov    0x8(%eax),%eax
  802048:	eb 0e                	jmp    802058 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80204a:	83 c0 01             	add    $0x1,%eax
  80204d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802052:	75 d9                	jne    80202d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802054:	66 b8 00 00          	mov    $0x0,%ax
}
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802060:	89 d0                	mov    %edx,%eax
  802062:	c1 e8 16             	shr    $0x16,%eax
  802065:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80206c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802071:	f6 c1 01             	test   $0x1,%cl
  802074:	74 1d                	je     802093 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802076:	c1 ea 0c             	shr    $0xc,%edx
  802079:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802080:	f6 c2 01             	test   $0x1,%dl
  802083:	74 0e                	je     802093 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802085:	c1 ea 0c             	shr    $0xc,%edx
  802088:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80208f:	ef 
  802090:	0f b7 c0             	movzwl %ax,%eax
}
  802093:	5d                   	pop    %ebp
  802094:	c3                   	ret    
  802095:	66 90                	xchg   %ax,%ax
  802097:	66 90                	xchg   %ax,%ax
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	83 ec 10             	sub    $0x10,%esp
  8020a6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020aa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020ae:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020b6:	85 d2                	test   %edx,%edx
  8020b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020bc:	89 34 24             	mov    %esi,(%esp)
  8020bf:	89 c8                	mov    %ecx,%eax
  8020c1:	75 35                	jne    8020f8 <__udivdi3+0x58>
  8020c3:	39 f1                	cmp    %esi,%ecx
  8020c5:	0f 87 bd 00 00 00    	ja     802188 <__udivdi3+0xe8>
  8020cb:	85 c9                	test   %ecx,%ecx
  8020cd:	89 cd                	mov    %ecx,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f1                	div    %ecx
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 f0                	mov    %esi,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c6                	mov    %eax,%esi
  8020e4:	89 f8                	mov    %edi,%eax
  8020e6:	f7 f5                	div    %ebp
  8020e8:	89 f2                	mov    %esi,%edx
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	5e                   	pop    %esi
  8020ee:	5f                   	pop    %edi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    
  8020f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	3b 14 24             	cmp    (%esp),%edx
  8020fb:	77 7b                	ja     802178 <__udivdi3+0xd8>
  8020fd:	0f bd f2             	bsr    %edx,%esi
  802100:	83 f6 1f             	xor    $0x1f,%esi
  802103:	0f 84 97 00 00 00    	je     8021a0 <__udivdi3+0x100>
  802109:	bd 20 00 00 00       	mov    $0x20,%ebp
  80210e:	89 d7                	mov    %edx,%edi
  802110:	89 f1                	mov    %esi,%ecx
  802112:	29 f5                	sub    %esi,%ebp
  802114:	d3 e7                	shl    %cl,%edi
  802116:	89 c2                	mov    %eax,%edx
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	d3 ea                	shr    %cl,%edx
  80211c:	89 f1                	mov    %esi,%ecx
  80211e:	09 fa                	or     %edi,%edx
  802120:	8b 3c 24             	mov    (%esp),%edi
  802123:	d3 e0                	shl    %cl,%eax
  802125:	89 54 24 08          	mov    %edx,0x8(%esp)
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802133:	89 fa                	mov    %edi,%edx
  802135:	d3 ea                	shr    %cl,%edx
  802137:	89 f1                	mov    %esi,%ecx
  802139:	d3 e7                	shl    %cl,%edi
  80213b:	89 e9                	mov    %ebp,%ecx
  80213d:	d3 e8                	shr    %cl,%eax
  80213f:	09 c7                	or     %eax,%edi
  802141:	89 f8                	mov    %edi,%eax
  802143:	f7 74 24 08          	divl   0x8(%esp)
  802147:	89 d5                	mov    %edx,%ebp
  802149:	89 c7                	mov    %eax,%edi
  80214b:	f7 64 24 0c          	mull   0xc(%esp)
  80214f:	39 d5                	cmp    %edx,%ebp
  802151:	89 14 24             	mov    %edx,(%esp)
  802154:	72 11                	jb     802167 <__udivdi3+0xc7>
  802156:	8b 54 24 04          	mov    0x4(%esp),%edx
  80215a:	89 f1                	mov    %esi,%ecx
  80215c:	d3 e2                	shl    %cl,%edx
  80215e:	39 c2                	cmp    %eax,%edx
  802160:	73 5e                	jae    8021c0 <__udivdi3+0x120>
  802162:	3b 2c 24             	cmp    (%esp),%ebp
  802165:	75 59                	jne    8021c0 <__udivdi3+0x120>
  802167:	8d 47 ff             	lea    -0x1(%edi),%eax
  80216a:	31 f6                	xor    %esi,%esi
  80216c:	89 f2                	mov    %esi,%edx
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi
  802178:	31 f6                	xor    %esi,%esi
  80217a:	31 c0                	xor    %eax,%eax
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	89 f2                	mov    %esi,%edx
  80218a:	31 f6                	xor    %esi,%esi
  80218c:	89 f8                	mov    %edi,%eax
  80218e:	f7 f1                	div    %ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021a4:	76 0b                	jbe    8021b1 <__udivdi3+0x111>
  8021a6:	31 c0                	xor    %eax,%eax
  8021a8:	3b 14 24             	cmp    (%esp),%edx
  8021ab:	0f 83 37 ff ff ff    	jae    8020e8 <__udivdi3+0x48>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	e9 2d ff ff ff       	jmp    8020e8 <__udivdi3+0x48>
  8021bb:	90                   	nop
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 f8                	mov    %edi,%eax
  8021c2:	31 f6                	xor    %esi,%esi
  8021c4:	e9 1f ff ff ff       	jmp    8020e8 <__udivdi3+0x48>
  8021c9:	66 90                	xchg   %ax,%ax
  8021cb:	66 90                	xchg   %ax,%ax
  8021cd:	66 90                	xchg   %ax,%ax
  8021cf:	90                   	nop

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	83 ec 20             	sub    $0x20,%esp
  8021d6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021da:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021de:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e2:	89 c6                	mov    %eax,%esi
  8021e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021e8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ec:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021f0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021f4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021f8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	89 c2                	mov    %eax,%edx
  802200:	75 1e                	jne    802220 <__umoddi3+0x50>
  802202:	39 f7                	cmp    %esi,%edi
  802204:	76 52                	jbe    802258 <__umoddi3+0x88>
  802206:	89 c8                	mov    %ecx,%eax
  802208:	89 f2                	mov    %esi,%edx
  80220a:	f7 f7                	div    %edi
  80220c:	89 d0                	mov    %edx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	83 c4 20             	add    $0x20,%esp
  802213:	5e                   	pop    %esi
  802214:	5f                   	pop    %edi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    
  802217:	89 f6                	mov    %esi,%esi
  802219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802220:	39 f0                	cmp    %esi,%eax
  802222:	77 5c                	ja     802280 <__umoddi3+0xb0>
  802224:	0f bd e8             	bsr    %eax,%ebp
  802227:	83 f5 1f             	xor    $0x1f,%ebp
  80222a:	75 64                	jne    802290 <__umoddi3+0xc0>
  80222c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802230:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802234:	0f 86 f6 00 00 00    	jbe    802330 <__umoddi3+0x160>
  80223a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80223e:	0f 82 ec 00 00 00    	jb     802330 <__umoddi3+0x160>
  802244:	8b 44 24 14          	mov    0x14(%esp),%eax
  802248:	8b 54 24 18          	mov    0x18(%esp),%edx
  80224c:	83 c4 20             	add    $0x20,%esp
  80224f:	5e                   	pop    %esi
  802250:	5f                   	pop    %edi
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    
  802253:	90                   	nop
  802254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802258:	85 ff                	test   %edi,%edi
  80225a:	89 fd                	mov    %edi,%ebp
  80225c:	75 0b                	jne    802269 <__umoddi3+0x99>
  80225e:	b8 01 00 00 00       	mov    $0x1,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f7                	div    %edi
  802267:	89 c5                	mov    %eax,%ebp
  802269:	8b 44 24 10          	mov    0x10(%esp),%eax
  80226d:	31 d2                	xor    %edx,%edx
  80226f:	f7 f5                	div    %ebp
  802271:	89 c8                	mov    %ecx,%eax
  802273:	f7 f5                	div    %ebp
  802275:	eb 95                	jmp    80220c <__umoddi3+0x3c>
  802277:	89 f6                	mov    %esi,%esi
  802279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 20             	add    $0x20,%esp
  802287:	5e                   	pop    %esi
  802288:	5f                   	pop    %edi
  802289:	5d                   	pop    %ebp
  80228a:	c3                   	ret    
  80228b:	90                   	nop
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	b8 20 00 00 00       	mov    $0x20,%eax
  802295:	89 e9                	mov    %ebp,%ecx
  802297:	29 e8                	sub    %ebp,%eax
  802299:	d3 e2                	shl    %cl,%edx
  80229b:	89 c7                	mov    %eax,%edi
  80229d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 c1                	mov    %eax,%ecx
  8022ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022af:	09 d1                	or     %edx,%ecx
  8022b1:	89 fa                	mov    %edi,%edx
  8022b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022b7:	89 e9                	mov    %ebp,%ecx
  8022b9:	d3 e0                	shl    %cl,%eax
  8022bb:	89 f9                	mov    %edi,%ecx
  8022bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	d3 e8                	shr    %cl,%eax
  8022c5:	89 e9                	mov    %ebp,%ecx
  8022c7:	89 c7                	mov    %eax,%edi
  8022c9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022cd:	d3 e6                	shl    %cl,%esi
  8022cf:	89 d1                	mov    %edx,%ecx
  8022d1:	89 fa                	mov    %edi,%edx
  8022d3:	d3 e8                	shr    %cl,%eax
  8022d5:	89 e9                	mov    %ebp,%ecx
  8022d7:	09 f0                	or     %esi,%eax
  8022d9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022dd:	f7 74 24 10          	divl   0x10(%esp)
  8022e1:	d3 e6                	shl    %cl,%esi
  8022e3:	89 d1                	mov    %edx,%ecx
  8022e5:	f7 64 24 0c          	mull   0xc(%esp)
  8022e9:	39 d1                	cmp    %edx,%ecx
  8022eb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022ef:	89 d7                	mov    %edx,%edi
  8022f1:	89 c6                	mov    %eax,%esi
  8022f3:	72 0a                	jb     8022ff <__umoddi3+0x12f>
  8022f5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022f9:	73 10                	jae    80230b <__umoddi3+0x13b>
  8022fb:	39 d1                	cmp    %edx,%ecx
  8022fd:	75 0c                	jne    80230b <__umoddi3+0x13b>
  8022ff:	89 d7                	mov    %edx,%edi
  802301:	89 c6                	mov    %eax,%esi
  802303:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802307:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80230b:	89 ca                	mov    %ecx,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802313:	29 f0                	sub    %esi,%eax
  802315:	19 fa                	sbb    %edi,%edx
  802317:	d3 e8                	shr    %cl,%eax
  802319:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80231e:	89 d7                	mov    %edx,%edi
  802320:	d3 e7                	shl    %cl,%edi
  802322:	89 e9                	mov    %ebp,%ecx
  802324:	09 f8                	or     %edi,%eax
  802326:	d3 ea                	shr    %cl,%edx
  802328:	83 c4 20             	add    $0x20,%esp
  80232b:	5e                   	pop    %esi
  80232c:	5f                   	pop    %edi
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    
  80232f:	90                   	nop
  802330:	8b 74 24 10          	mov    0x10(%esp),%esi
  802334:	29 f9                	sub    %edi,%ecx
  802336:	19 c6                	sbb    %eax,%esi
  802338:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80233c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802340:	e9 ff fe ff ff       	jmp    802244 <__umoddi3+0x74>
