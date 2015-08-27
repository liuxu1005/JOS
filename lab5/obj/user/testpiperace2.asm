
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 40 23 80 00       	push   $0x802340
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 45 1b 00 00       	call   801b96 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 23 80 00       	push   $0x80238e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 23 80 00       	push   $0x802397
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 03 0f 00 00       	call   800f72 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 5b 28 80 00       	push   $0x80285b
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 23 80 00       	push   $0x802397
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 9e 12 00 00       	call   801334 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 ac 23 80 00       	push   $0x8023ac
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 ae 12 00 00       	call   801386 <dup>
			sys_yield();
  8000d8:	e8 a3 0b 00 00       	call   800c80 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 4b 12 00 00       	call   801334 <close>
			sys_yield();
  8000e9:	e8 92 0b 00 00       	call   800c80 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 c7 1b 00 00       	call   801ce9 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b0 23 80 00       	push   $0x8023b0
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 e2 0a 00 00       	call   800c20 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 cc 23 80 00       	push   $0x8023cc
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 78 1b 00 00       	call   801ce9 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 23 80 00       	push   $0x802364
  800180:	6a 40                	push   $0x40
  800182:	68 97 23 80 00       	push   $0x802397
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 6f 10 00 00       	call   80120a <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 e2 23 80 00       	push   $0x8023e2
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 23 80 00       	push   $0x802397
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 e5 0f 00 00       	call   8011a4 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 fa 23 80 00 	movl   $0x8023fa,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8001e1:	e8 7b 0a 00 00       	call   800c61 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 3a 11 00 00       	call   801361 <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 ef 09 00 00       	call   800c20 <sys_env_destroy>
  800231:	83 c4 10             	add    $0x10,%esp
}
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 18 0a 00 00       	call   800c61 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 18 24 80 00       	push   $0x802418
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 99 28 80 00 	movl   $0x802899,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 37 09 00 00       	call   800be3 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 4f 01 00 00       	call   800441 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 dc 08 00 00       	call   800be3 <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 d1                	mov    %edx,%ecx
  800338:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033e:	8b 45 10             	mov    0x10(%ebp),%eax
  800341:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800344:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800347:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034e:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800351:	72 05                	jb     800358 <printnum+0x35>
  800353:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800356:	77 3e                	ja     800396 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	83 eb 01             	sub    $0x1,%ebx
  800361:	53                   	push   %ebx
  800362:	50                   	push   %eax
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 f9 1c 00 00       	call   802070 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 13                	jmp    80039d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800396:	83 eb 01             	sub    $0x1,%ebx
  800399:	85 db                	test   %ebx,%ebx
  80039b:	7f ed                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	56                   	push   %esi
  8003a1:	83 ec 04             	sub    $0x4,%esp
  8003a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b0:	e8 eb 1d 00 00       	call   8021a0 <__umoddi3>
  8003b5:	83 c4 14             	add    $0x14,%esp
  8003b8:	0f be 80 3b 24 80 00 	movsbl 0x80243b(%eax),%eax
  8003bf:	50                   	push   %eax
  8003c0:	ff d7                	call   *%edi
  8003c2:	83 c4 10             	add    $0x10,%esp
}
  8003c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c8:	5b                   	pop    %ebx
  8003c9:	5e                   	pop    %esi
  8003ca:	5f                   	pop    %edi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d0:	83 fa 01             	cmp    $0x1,%edx
  8003d3:	7e 0e                	jle    8003e3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003da:	89 08                	mov    %ecx,(%eax)
  8003dc:	8b 02                	mov    (%edx),%eax
  8003de:	8b 52 04             	mov    0x4(%edx),%edx
  8003e1:	eb 22                	jmp    800405 <getuint+0x38>
	else if (lflag)
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	74 10                	je     8003f7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e7:	8b 10                	mov    (%eax),%edx
  8003e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ec:	89 08                	mov    %ecx,(%eax)
  8003ee:	8b 02                	mov    (%edx),%eax
  8003f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f5:	eb 0e                	jmp    800405 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f7:	8b 10                	mov    (%eax),%edx
  8003f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fc:	89 08                	mov    %ecx,(%eax)
  8003fe:	8b 02                	mov    (%edx),%eax
  800400:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800411:	8b 10                	mov    (%eax),%edx
  800413:	3b 50 04             	cmp    0x4(%eax),%edx
  800416:	73 0a                	jae    800422 <sprintputch+0x1b>
		*b->buf++ = ch;
  800418:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	88 02                	mov    %al,(%edx)
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042d:	50                   	push   %eax
  80042e:	ff 75 10             	pushl  0x10(%ebp)
  800431:	ff 75 0c             	pushl  0xc(%ebp)
  800434:	ff 75 08             	pushl  0x8(%ebp)
  800437:	e8 05 00 00 00       	call   800441 <vprintfmt>
	va_end(ap);
  80043c:	83 c4 10             	add    $0x10,%esp
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 2c             	sub    $0x2c,%esp
  80044a:	8b 75 08             	mov    0x8(%ebp),%esi
  80044d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800450:	8b 7d 10             	mov    0x10(%ebp),%edi
  800453:	eb 12                	jmp    800467 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800455:	85 c0                	test   %eax,%eax
  800457:	0f 84 90 03 00 00    	je     8007ed <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	50                   	push   %eax
  800462:	ff d6                	call   *%esi
  800464:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800467:	83 c7 01             	add    $0x1,%edi
  80046a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046e:	83 f8 25             	cmp    $0x25,%eax
  800471:	75 e2                	jne    800455 <vprintfmt+0x14>
  800473:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800477:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800485:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80048c:	ba 00 00 00 00       	mov    $0x0,%edx
  800491:	eb 07                	jmp    80049a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800496:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8d 47 01             	lea    0x1(%edi),%eax
  80049d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a0:	0f b6 07             	movzbl (%edi),%eax
  8004a3:	0f b6 c8             	movzbl %al,%ecx
  8004a6:	83 e8 23             	sub    $0x23,%eax
  8004a9:	3c 55                	cmp    $0x55,%al
  8004ab:	0f 87 21 03 00 00    	ja     8007d2 <vprintfmt+0x391>
  8004b1:	0f b6 c0             	movzbl %al,%eax
  8004b4:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c2:	eb d6                	jmp    80049a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004dc:	83 fa 09             	cmp    $0x9,%edx
  8004df:	77 39                	ja     80051a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e4:	eb e9                	jmp    8004cf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f7:	eb 27                	jmp    800520 <vprintfmt+0xdf>
  8004f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800503:	0f 49 c8             	cmovns %eax,%ecx
  800506:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	eb 8c                	jmp    80049a <vprintfmt+0x59>
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800511:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800518:	eb 80                	jmp    80049a <vprintfmt+0x59>
  80051a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800520:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800524:	0f 89 70 ff ff ff    	jns    80049a <vprintfmt+0x59>
				width = precision, precision = -1;
  80052a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80052d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800530:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800537:	e9 5e ff ff ff       	jmp    80049a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800542:	e9 53 ff ff ff       	jmp    80049a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	ff 30                	pushl  (%eax)
  800556:	ff d6                	call   *%esi
			break;
  800558:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055e:	e9 04 ff ff ff       	jmp    800467 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	99                   	cltd   
  80056f:	31 d0                	xor    %edx,%eax
  800571:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800573:	83 f8 0f             	cmp    $0xf,%eax
  800576:	7f 0b                	jg     800583 <vprintfmt+0x142>
  800578:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 18                	jne    80059b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800583:	50                   	push   %eax
  800584:	68 53 24 80 00       	push   $0x802453
  800589:	53                   	push   %ebx
  80058a:	56                   	push   %esi
  80058b:	e8 94 fe ff ff       	call   800424 <printfmt>
  800590:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800596:	e9 cc fe ff ff       	jmp    800467 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80059b:	52                   	push   %edx
  80059c:	68 6d 29 80 00       	push   $0x80296d
  8005a1:	53                   	push   %ebx
  8005a2:	56                   	push   %esi
  8005a3:	e8 7c fe ff ff       	call   800424 <printfmt>
  8005a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ae:	e9 b4 fe ff ff       	jmp    800467 <vprintfmt+0x26>
  8005b3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c7:	85 ff                	test   %edi,%edi
  8005c9:	ba 4c 24 80 00       	mov    $0x80244c,%edx
  8005ce:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8005d1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d5:	0f 84 92 00 00 00    	je     80066d <vprintfmt+0x22c>
  8005db:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005df:	0f 8e 96 00 00 00    	jle    80067b <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	51                   	push   %ecx
  8005e9:	57                   	push   %edi
  8005ea:	e8 86 02 00 00       	call   800875 <strnlen>
  8005ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f2:	29 c1                	sub    %eax,%ecx
  8005f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800601:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800604:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800606:	eb 0f                	jmp    800617 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	ff 75 e0             	pushl  -0x20(%ebp)
  80060f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800611:	83 ef 01             	sub    $0x1,%edi
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	85 ff                	test   %edi,%edi
  800619:	7f ed                	jg     800608 <vprintfmt+0x1c7>
  80061b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800621:	85 c9                	test   %ecx,%ecx
  800623:	b8 00 00 00 00       	mov    $0x0,%eax
  800628:	0f 49 c1             	cmovns %ecx,%eax
  80062b:	29 c1                	sub    %eax,%ecx
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	89 cb                	mov    %ecx,%ebx
  800638:	eb 4d                	jmp    800687 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063e:	74 1b                	je     80065b <vprintfmt+0x21a>
  800640:	0f be c0             	movsbl %al,%eax
  800643:	83 e8 20             	sub    $0x20,%eax
  800646:	83 f8 5e             	cmp    $0x5e,%eax
  800649:	76 10                	jbe    80065b <vprintfmt+0x21a>
					putch('?', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	ff 75 0c             	pushl  0xc(%ebp)
  800651:	6a 3f                	push   $0x3f
  800653:	ff 55 08             	call   *0x8(%ebp)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 0d                	jmp    800668 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	ff 75 0c             	pushl  0xc(%ebp)
  800661:	52                   	push   %edx
  800662:	ff 55 08             	call   *0x8(%ebp)
  800665:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800668:	83 eb 01             	sub    $0x1,%ebx
  80066b:	eb 1a                	jmp    800687 <vprintfmt+0x246>
  80066d:	89 75 08             	mov    %esi,0x8(%ebp)
  800670:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800673:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800676:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800679:	eb 0c                	jmp    800687 <vprintfmt+0x246>
  80067b:	89 75 08             	mov    %esi,0x8(%ebp)
  80067e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800681:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800684:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800687:	83 c7 01             	add    $0x1,%edi
  80068a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068e:	0f be d0             	movsbl %al,%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	74 23                	je     8006b8 <vprintfmt+0x277>
  800695:	85 f6                	test   %esi,%esi
  800697:	78 a1                	js     80063a <vprintfmt+0x1f9>
  800699:	83 ee 01             	sub    $0x1,%esi
  80069c:	79 9c                	jns    80063a <vprintfmt+0x1f9>
  80069e:	89 df                	mov    %ebx,%edi
  8006a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a6:	eb 18                	jmp    8006c0 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 20                	push   $0x20
  8006ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b0:	83 ef 01             	sub    $0x1,%edi
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 08                	jmp    8006c0 <vprintfmt+0x27f>
  8006b8:	89 df                	mov    %ebx,%edi
  8006ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c0:	85 ff                	test   %edi,%edi
  8006c2:	7f e4                	jg     8006a8 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	e9 9b fd ff ff       	jmp    800467 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cc:	83 fa 01             	cmp    $0x1,%edx
  8006cf:	7e 16                	jle    8006e7 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 08             	lea    0x8(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 50 04             	mov    0x4(%eax),%edx
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e5:	eb 32                	jmp    800719 <vprintfmt+0x2d8>
	else if (lflag)
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	74 18                	je     800703 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 50 04             	lea    0x4(%eax),%edx
  8006f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f4:	8b 00                	mov    (%eax),%eax
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 c1                	mov    %eax,%ecx
  8006fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800701:	eb 16                	jmp    800719 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800711:	89 c1                	mov    %eax,%ecx
  800713:	c1 f9 1f             	sar    $0x1f,%ecx
  800716:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800719:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800724:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800728:	79 74                	jns    80079e <vprintfmt+0x35d>
				putch('-', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	6a 2d                	push   $0x2d
  800730:	ff d6                	call   *%esi
				num = -(long long) num;
  800732:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800735:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800738:	f7 d8                	neg    %eax
  80073a:	83 d2 00             	adc    $0x0,%edx
  80073d:	f7 da                	neg    %edx
  80073f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800742:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800747:	eb 55                	jmp    80079e <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
  80074c:	e8 7c fc ff ff       	call   8003cd <getuint>
			base = 10;
  800751:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800756:	eb 46                	jmp    80079e <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
  80075b:	e8 6d fc ff ff       	call   8003cd <getuint>
                        base = 8;
  800760:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800765:	eb 37                	jmp    80079e <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 30                	push   $0x30
  80076d:	ff d6                	call   *%esi
			putch('x', putdat);
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 78                	push   $0x78
  800775:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800780:	8b 00                	mov    (%eax),%eax
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800787:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078f:	eb 0d                	jmp    80079e <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 34 fc ff ff       	call   8003cd <getuint>
			base = 16;
  800799:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079e:	83 ec 0c             	sub    $0xc,%esp
  8007a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a5:	57                   	push   %edi
  8007a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a9:	51                   	push   %ecx
  8007aa:	52                   	push   %edx
  8007ab:	50                   	push   %eax
  8007ac:	89 da                	mov    %ebx,%edx
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	e8 6e fb ff ff       	call   800323 <printnum>
			break;
  8007b5:	83 c4 20             	add    $0x20,%esp
  8007b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bb:	e9 a7 fc ff ff       	jmp    800467 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	51                   	push   %ecx
  8007c5:	ff d6                	call   *%esi
			break;
  8007c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cd:	e9 95 fc ff ff       	jmp    800467 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	6a 25                	push   $0x25
  8007d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 03                	jmp    8007e2 <vprintfmt+0x3a1>
  8007df:	83 ef 01             	sub    $0x1,%edi
  8007e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e6:	75 f7                	jne    8007df <vprintfmt+0x39e>
  8007e8:	e9 7a fc ff ff       	jmp    800467 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 18             	sub    $0x18,%esp
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800804:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800808:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800812:	85 c0                	test   %eax,%eax
  800814:	74 26                	je     80083c <vsnprintf+0x47>
  800816:	85 d2                	test   %edx,%edx
  800818:	7e 22                	jle    80083c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081a:	ff 75 14             	pushl  0x14(%ebp)
  80081d:	ff 75 10             	pushl  0x10(%ebp)
  800820:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	68 07 04 80 00       	push   $0x800407
  800829:	e8 13 fc ff ff       	call   800441 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800831:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	eb 05                	jmp    800841 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084c:	50                   	push   %eax
  80084d:	ff 75 10             	pushl  0x10(%ebp)
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	ff 75 08             	pushl  0x8(%ebp)
  800856:	e8 9a ff ff ff       	call   8007f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 03                	jmp    80086d <strlen+0x10>
		n++;
  80086a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800871:	75 f7                	jne    80086a <strlen+0xd>
		n++;
	return n;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087e:	ba 00 00 00 00       	mov    $0x0,%edx
  800883:	eb 03                	jmp    800888 <strnlen+0x13>
		n++;
  800885:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800888:	39 c2                	cmp    %eax,%edx
  80088a:	74 08                	je     800894 <strnlen+0x1f>
  80088c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800890:	75 f3                	jne    800885 <strnlen+0x10>
  800892:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	83 c2 01             	add    $0x1,%edx
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bd:	53                   	push   %ebx
  8008be:	e8 9a ff ff ff       	call   80085d <strlen>
  8008c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c6:	ff 75 0c             	pushl  0xc(%ebp)
  8008c9:	01 d8                	add    %ebx,%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 c5 ff ff ff       	call   800896 <strcpy>
	return dst;
}
  8008d1:	89 d8                	mov    %ebx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e3:	89 f3                	mov    %esi,%ebx
  8008e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e8:	89 f2                	mov    %esi,%edx
  8008ea:	eb 0f                	jmp    8008fb <strncpy+0x23>
		*dst++ = *src;
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	0f b6 01             	movzbl (%ecx),%eax
  8008f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	39 da                	cmp    %ebx,%edx
  8008fd:	75 ed                	jne    8008ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ff:	89 f0                	mov    %esi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 75 08             	mov    0x8(%ebp),%esi
  80090d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800910:	8b 55 10             	mov    0x10(%ebp),%edx
  800913:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800915:	85 d2                	test   %edx,%edx
  800917:	74 21                	je     80093a <strlcpy+0x35>
  800919:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091d:	89 f2                	mov    %esi,%edx
  80091f:	eb 09                	jmp    80092a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800921:	83 c2 01             	add    $0x1,%edx
  800924:	83 c1 01             	add    $0x1,%ecx
  800927:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092a:	39 c2                	cmp    %eax,%edx
  80092c:	74 09                	je     800937 <strlcpy+0x32>
  80092e:	0f b6 19             	movzbl (%ecx),%ebx
  800931:	84 db                	test   %bl,%bl
  800933:	75 ec                	jne    800921 <strlcpy+0x1c>
  800935:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800937:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093a:	29 f0                	sub    %esi,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800949:	eb 06                	jmp    800951 <strcmp+0x11>
		p++, q++;
  80094b:	83 c1 01             	add    $0x1,%ecx
  80094e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800951:	0f b6 01             	movzbl (%ecx),%eax
  800954:	84 c0                	test   %al,%al
  800956:	74 04                	je     80095c <strcmp+0x1c>
  800958:	3a 02                	cmp    (%edx),%al
  80095a:	74 ef                	je     80094b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 c0             	movzbl %al,%eax
  80095f:	0f b6 12             	movzbl (%edx),%edx
  800962:	29 d0                	sub    %edx,%eax
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	89 c3                	mov    %eax,%ebx
  800972:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800975:	eb 06                	jmp    80097d <strncmp+0x17>
		n--, p++, q++;
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097d:	39 d8                	cmp    %ebx,%eax
  80097f:	74 15                	je     800996 <strncmp+0x30>
  800981:	0f b6 08             	movzbl (%eax),%ecx
  800984:	84 c9                	test   %cl,%cl
  800986:	74 04                	je     80098c <strncmp+0x26>
  800988:	3a 0a                	cmp    (%edx),%cl
  80098a:	74 eb                	je     800977 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098c:	0f b6 00             	movzbl (%eax),%eax
  80098f:	0f b6 12             	movzbl (%edx),%edx
  800992:	29 d0                	sub    %edx,%eax
  800994:	eb 05                	jmp    80099b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099b:	5b                   	pop    %ebx
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a8:	eb 07                	jmp    8009b1 <strchr+0x13>
		if (*s == c)
  8009aa:	38 ca                	cmp    %cl,%dl
  8009ac:	74 0f                	je     8009bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	84 d2                	test   %dl,%dl
  8009b6:	75 f2                	jne    8009aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c9:	eb 03                	jmp    8009ce <strfind+0xf>
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d1:	84 d2                	test   %dl,%dl
  8009d3:	74 04                	je     8009d9 <strfind+0x1a>
  8009d5:	38 ca                	cmp    %cl,%dl
  8009d7:	75 f2                	jne    8009cb <strfind+0xc>
			break;
	return (char *) s;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e7:	85 c9                	test   %ecx,%ecx
  8009e9:	74 36                	je     800a21 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f1:	75 28                	jne    800a1b <memset+0x40>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 23                	jne    800a1b <memset+0x40>
		c &= 0xFF;
  8009f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fc:	89 d3                	mov    %edx,%ebx
  8009fe:	c1 e3 08             	shl    $0x8,%ebx
  800a01:	89 d6                	mov    %edx,%esi
  800a03:	c1 e6 18             	shl    $0x18,%esi
  800a06:	89 d0                	mov    %edx,%eax
  800a08:	c1 e0 10             	shl    $0x10,%eax
  800a0b:	09 f0                	or     %esi,%eax
  800a0d:	09 c2                	or     %eax,%edx
  800a0f:	89 d0                	mov    %edx,%eax
  800a11:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a13:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a16:	fc                   	cld    
  800a17:	f3 ab                	rep stos %eax,%es:(%edi)
  800a19:	eb 06                	jmp    800a21 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	fc                   	cld    
  800a1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a21:	89 f8                	mov    %edi,%eax
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a36:	39 c6                	cmp    %eax,%esi
  800a38:	73 35                	jae    800a6f <memmove+0x47>
  800a3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	73 2e                	jae    800a6f <memmove+0x47>
		s += n;
		d += n;
  800a41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a48:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4e:	75 13                	jne    800a63 <memmove+0x3b>
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 0e                	jne    800a63 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a55:	83 ef 04             	sub    $0x4,%edi
  800a58:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a5e:	fd                   	std    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 09                	jmp    800a6c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a63:	83 ef 01             	sub    $0x1,%edi
  800a66:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a69:	fd                   	std    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6c:	fc                   	cld    
  800a6d:	eb 1d                	jmp    800a8c <memmove+0x64>
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	f6 c2 03             	test   $0x3,%dl
  800a76:	75 0f                	jne    800a87 <memmove+0x5f>
  800a78:	f6 c1 03             	test   $0x3,%cl
  800a7b:	75 0a                	jne    800a87 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a80:	89 c7                	mov    %eax,%edi
  800a82:	fc                   	cld    
  800a83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a85:	eb 05                	jmp    800a8c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	fc                   	cld    
  800a8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a93:	ff 75 10             	pushl  0x10(%ebp)
  800a96:	ff 75 0c             	pushl  0xc(%ebp)
  800a99:	ff 75 08             	pushl  0x8(%ebp)
  800a9c:	e8 87 ff ff ff       	call   800a28 <memmove>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	89 c6                	mov    %eax,%esi
  800ab0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab3:	eb 1a                	jmp    800acf <memcmp+0x2c>
		if (*s1 != *s2)
  800ab5:	0f b6 08             	movzbl (%eax),%ecx
  800ab8:	0f b6 1a             	movzbl (%edx),%ebx
  800abb:	38 d9                	cmp    %bl,%cl
  800abd:	74 0a                	je     800ac9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abf:	0f b6 c1             	movzbl %cl,%eax
  800ac2:	0f b6 db             	movzbl %bl,%ebx
  800ac5:	29 d8                	sub    %ebx,%eax
  800ac7:	eb 0f                	jmp    800ad8 <memcmp+0x35>
		s1++, s2++;
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	39 f0                	cmp    %esi,%eax
  800ad1:	75 e2                	jne    800ab5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aea:	eb 07                	jmp    800af3 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	38 08                	cmp    %cl,(%eax)
  800aee:	74 07                	je     800af7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af0:	83 c0 01             	add    $0x1,%eax
  800af3:	39 d0                	cmp    %edx,%eax
  800af5:	72 f5                	jb     800aec <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x11>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	74 f6                	je     800b07 <strtol+0xe>
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f2                	je     800b07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	75 0a                	jne    800b23 <strtol+0x2a>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	eb 10                	jmp    800b33 <strtol+0x3a>
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b28:	3c 2d                	cmp    $0x2d,%al
  800b2a:	75 07                	jne    800b33 <strtol+0x3a>
		s++, neg = 1;
  800b2c:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b2f:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	0f 94 c0             	sete   %al
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 19                	jne    800b59 <strtol+0x60>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 14                	jne    800b59 <strtol+0x60>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	0f 85 82 00 00 00    	jne    800bd1 <strtol+0xd8>
		s += 2, base = 16;
  800b4f:	83 c1 02             	add    $0x2,%ecx
  800b52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b57:	eb 16                	jmp    800b6f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b59:	84 c0                	test   %al,%al
  800b5b:	74 12                	je     800b6f <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b62:	80 39 30             	cmpb   $0x30,(%ecx)
  800b65:	75 08                	jne    800b6f <strtol+0x76>
		s++, base = 8;
  800b67:	83 c1 01             	add    $0x1,%ecx
  800b6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b77:	0f b6 11             	movzbl (%ecx),%edx
  800b7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	80 fb 09             	cmp    $0x9,%bl
  800b82:	77 08                	ja     800b8c <strtol+0x93>
			dig = *s - '0';
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 30             	sub    $0x30,%edx
  800b8a:	eb 22                	jmp    800bae <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 19             	cmp    $0x19,%bl
  800b94:	77 08                	ja     800b9e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b96:	0f be d2             	movsbl %dl,%edx
  800b99:	83 ea 57             	sub    $0x57,%edx
  800b9c:	eb 10                	jmp    800bae <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba1:	89 f3                	mov    %esi,%ebx
  800ba3:	80 fb 19             	cmp    $0x19,%bl
  800ba6:	77 16                	ja     800bbe <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba8:	0f be d2             	movsbl %dl,%edx
  800bab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb1:	7d 0f                	jge    800bc2 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbc:	eb b9                	jmp    800b77 <strtol+0x7e>
  800bbe:	89 c2                	mov    %eax,%edx
  800bc0:	eb 02                	jmp    800bc4 <strtol+0xcb>
  800bc2:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc8:	74 0d                	je     800bd7 <strtol+0xde>
		*endptr = (char *) s;
  800bca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcd:	89 0e                	mov    %ecx,(%esi)
  800bcf:	eb 06                	jmp    800bd7 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd1:	84 c0                	test   %al,%al
  800bd3:	75 92                	jne    800b67 <strtol+0x6e>
  800bd5:	eb 98                	jmp    800b6f <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd7:	f7 da                	neg    %edx
  800bd9:	85 ff                	test   %edi,%edi
  800bdb:	0f 45 c2             	cmovne %edx,%eax
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	89 c3                	mov    %eax,%ebx
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	89 c6                	mov    %eax,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	89 d7                	mov    %edx,%edi
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	89 cb                	mov    %ecx,%ebx
  800c38:	89 cf                	mov    %ecx,%edi
  800c3a:	89 ce                	mov    %ecx,%esi
  800c3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 03                	push   $0x3
  800c48:	68 5f 27 80 00       	push   $0x80275f
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 7c 27 80 00       	push   $0x80277c
  800c54:	e8 dd f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 d3                	mov    %edx,%ebx
  800c75:	89 d7                	mov    %edx,%edi
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_yield>:

void
sys_yield(void)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c90:	89 d1                	mov    %edx,%ecx
  800c92:	89 d3                	mov    %edx,%ebx
  800c94:	89 d7                	mov    %edx,%edi
  800c96:	89 d6                	mov    %edx,%esi
  800c98:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	89 f7                	mov    %esi,%edi
  800cbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 04                	push   $0x4
  800cc9:	68 5f 27 80 00       	push   $0x80275f
  800cce:	6a 23                	push   $0x23
  800cd0:	68 7c 27 80 00       	push   $0x80277c
  800cd5:	e8 5c f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfc:	8b 75 18             	mov    0x18(%ebp),%esi
  800cff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 05                	push   $0x5
  800d0b:	68 5f 27 80 00       	push   $0x80275f
  800d10:	6a 23                	push   $0x23
  800d12:	68 7c 27 80 00       	push   $0x80277c
  800d17:	e8 1a f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	b8 06 00 00 00       	mov    $0x6,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 df                	mov    %ebx,%edi
  800d3f:	89 de                	mov    %ebx,%esi
  800d41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 06                	push   $0x6
  800d4d:	68 5f 27 80 00       	push   $0x80275f
  800d52:	6a 23                	push   $0x23
  800d54:	68 7c 27 80 00       	push   $0x80277c
  800d59:	e8 d8 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	b8 08 00 00 00       	mov    $0x8,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 17                	jle    800da0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 08                	push   $0x8
  800d8f:	68 5f 27 80 00       	push   $0x80275f
  800d94:	6a 23                	push   $0x23
  800d96:	68 7c 27 80 00       	push   $0x80277c
  800d9b:	e8 96 f4 ff ff       	call   800236 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	b8 09 00 00 00       	mov    $0x9,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 17                	jle    800de2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 09                	push   $0x9
  800dd1:	68 5f 27 80 00       	push   $0x80275f
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 7c 27 80 00       	push   $0x80277c
  800ddd:	e8 54 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	89 df                	mov    %ebx,%edi
  800e05:	89 de                	mov    %ebx,%esi
  800e07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 17                	jle    800e24 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 0a                	push   $0xa
  800e13:	68 5f 27 80 00       	push   $0x80275f
  800e18:	6a 23                	push   $0x23
  800e1a:	68 7c 27 80 00       	push   $0x80277c
  800e1f:	e8 12 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 cb                	mov    %ecx,%ebx
  800e67:	89 cf                	mov    %ecx,%edi
  800e69:	89 ce                	mov    %ecx,%esi
  800e6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 17                	jle    800e88 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	83 ec 0c             	sub    $0xc,%esp
  800e74:	50                   	push   %eax
  800e75:	6a 0d                	push   $0xd
  800e77:	68 5f 27 80 00       	push   $0x80275f
  800e7c:	6a 23                	push   $0x23
  800e7e:	68 7c 27 80 00       	push   $0x80277c
  800e83:	e8 ae f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	53                   	push   %ebx
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e9a:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e9c:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ea0:	74 2e                	je     800ed0 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	c1 ea 16             	shr    $0x16,%edx
  800ea7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eae:	f6 c2 01             	test   $0x1,%dl
  800eb1:	74 1d                	je     800ed0 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	c1 ea 0c             	shr    $0xc,%edx
  800eb8:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ebf:	f6 c1 01             	test   $0x1,%cl
  800ec2:	74 0c                	je     800ed0 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ec4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ecb:	f6 c6 08             	test   $0x8,%dh
  800ece:	75 14                	jne    800ee4 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	68 8c 27 80 00       	push   $0x80278c
  800ed8:	6a 21                	push   $0x21
  800eda:	68 1f 28 80 00       	push   $0x80281f
  800edf:	e8 52 f3 ff ff       	call   800236 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800ee4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee9:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	6a 07                	push   $0x7
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	6a 00                	push   $0x0
  800ef7:	e8 a3 fd ff ff       	call   800c9f <sys_page_alloc>
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	79 14                	jns    800f17 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	68 2a 28 80 00       	push   $0x80282a
  800f0b:	6a 2b                	push   $0x2b
  800f0d:	68 1f 28 80 00       	push   $0x80281f
  800f12:	e8 1f f3 ff ff       	call   800236 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	68 00 10 00 00       	push   $0x1000
  800f1f:	53                   	push   %ebx
  800f20:	68 00 f0 7f 00       	push   $0x7ff000
  800f25:	e8 fe fa ff ff       	call   800a28 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800f2a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f31:	53                   	push   %ebx
  800f32:	6a 00                	push   $0x0
  800f34:	68 00 f0 7f 00       	push   $0x7ff000
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 a2 fd ff ff       	call   800ce2 <sys_page_map>
  800f40:	83 c4 20             	add    $0x20,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	79 14                	jns    800f5b <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	68 40 28 80 00       	push   $0x802840
  800f4f:	6a 2e                	push   $0x2e
  800f51:	68 1f 28 80 00       	push   $0x80281f
  800f56:	e8 db f2 ff ff       	call   800236 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	6a 00                	push   $0x0
  800f65:	e8 ba fd ff ff       	call   800d24 <sys_page_unmap>
  800f6a:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f7b:	68 90 0e 80 00       	push   $0x800e90
  800f80:	e8 1c 0f 00 00       	call   801ea1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f85:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8a:	cd 30                	int    $0x30
  800f8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 12                	jns    800fa8 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f96:	50                   	push   %eax
  800f97:	68 54 28 80 00       	push   $0x802854
  800f9c:	6a 6d                	push   $0x6d
  800f9e:	68 1f 28 80 00       	push   $0x80281f
  800fa3:	e8 8e f2 ff ff       	call   800236 <_panic>
  800fa8:	89 c7                	mov    %eax,%edi
  800faa:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800faf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb3:	75 21                	jne    800fd6 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800fb5:	e8 a7 fc ff ff       	call   800c61 <sys_getenvid>
  800fba:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	e9 9c 01 00 00       	jmp    801172 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	c1 e8 16             	shr    $0x16,%eax
  800fdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe2:	a8 01                	test   $0x1,%al
  800fe4:	0f 84 f3 00 00 00    	je     8010dd <fork+0x16b>
  800fea:	89 d8                	mov    %ebx,%eax
  800fec:	c1 e8 0c             	shr    $0xc,%eax
  800fef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff6:	f6 c2 01             	test   $0x1,%dl
  800ff9:	0f 84 de 00 00 00    	je     8010dd <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800fff:	89 c6                	mov    %eax,%esi
  801001:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801004:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100b:	f6 c6 04             	test   $0x4,%dh
  80100e:	74 37                	je     801047 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	25 07 0e 00 00       	and    $0xe07,%eax
  80101f:	50                   	push   %eax
  801020:	56                   	push   %esi
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	e8 b8 fc ff ff       	call   800ce2 <sys_page_map>
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	0f 89 a8 00 00 00    	jns    8010dd <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  801035:	50                   	push   %eax
  801036:	68 b0 27 80 00       	push   $0x8027b0
  80103b:	6a 49                	push   $0x49
  80103d:	68 1f 28 80 00       	push   $0x80281f
  801042:	e8 ef f1 ff ff       	call   800236 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801047:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104e:	f6 c6 08             	test   $0x8,%dh
  801051:	75 0b                	jne    80105e <fork+0xec>
  801053:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105a:	a8 02                	test   $0x2,%al
  80105c:	74 57                	je     8010b5 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	68 05 08 00 00       	push   $0x805
  801066:	56                   	push   %esi
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	6a 00                	push   $0x0
  80106b:	e8 72 fc ff ff       	call   800ce2 <sys_page_map>
  801070:	83 c4 20             	add    $0x20,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	79 12                	jns    801089 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  801077:	50                   	push   %eax
  801078:	68 b0 27 80 00       	push   $0x8027b0
  80107d:	6a 4c                	push   $0x4c
  80107f:	68 1f 28 80 00       	push   $0x80281f
  801084:	e8 ad f1 ff ff       	call   800236 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	68 05 08 00 00       	push   $0x805
  801091:	56                   	push   %esi
  801092:	6a 00                	push   $0x0
  801094:	56                   	push   %esi
  801095:	6a 00                	push   $0x0
  801097:	e8 46 fc ff ff       	call   800ce2 <sys_page_map>
  80109c:	83 c4 20             	add    $0x20,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 3a                	jns    8010dd <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  8010a3:	50                   	push   %eax
  8010a4:	68 d4 27 80 00       	push   $0x8027d4
  8010a9:	6a 4e                	push   $0x4e
  8010ab:	68 1f 28 80 00       	push   $0x80281f
  8010b0:	e8 81 f1 ff ff       	call   800236 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	6a 05                	push   $0x5
  8010ba:	56                   	push   %esi
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	6a 00                	push   $0x0
  8010bf:	e8 1e fc ff ff       	call   800ce2 <sys_page_map>
  8010c4:	83 c4 20             	add    $0x20,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 12                	jns    8010dd <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  8010cb:	50                   	push   %eax
  8010cc:	68 fc 27 80 00       	push   $0x8027fc
  8010d1:	6a 50                	push   $0x50
  8010d3:	68 1f 28 80 00       	push   $0x80281f
  8010d8:	e8 59 f1 ff ff       	call   800236 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8010dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010e9:	0f 85 e7 fe ff ff    	jne    800fd6 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	6a 07                	push   $0x7
  8010f4:	68 00 f0 bf ee       	push   $0xeebff000
  8010f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fc:	e8 9e fb ff ff       	call   800c9f <sys_page_alloc>
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	79 14                	jns    80111c <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	68 64 28 80 00       	push   $0x802864
  801110:	6a 76                	push   $0x76
  801112:	68 1f 28 80 00       	push   $0x80281f
  801117:	e8 1a f1 ff ff       	call   800236 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	68 10 1f 80 00       	push   $0x801f10
  801124:	ff 75 e4             	pushl  -0x1c(%ebp)
  801127:	e8 be fc ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	79 14                	jns    801147 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801133:	ff 75 e4             	pushl  -0x1c(%ebp)
  801136:	68 7e 28 80 00       	push   $0x80287e
  80113b:	6a 79                	push   $0x79
  80113d:	68 1f 28 80 00       	push   $0x80281f
  801142:	e8 ef f0 ff ff       	call   800236 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	6a 02                	push   $0x2
  80114c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114f:	e8 12 fc ff ff       	call   800d66 <sys_env_set_status>
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	79 14                	jns    80116f <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80115b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115e:	68 9b 28 80 00       	push   $0x80289b
  801163:	6a 7b                	push   $0x7b
  801165:	68 1f 28 80 00       	push   $0x80281f
  80116a:	e8 c7 f0 ff ff       	call   800236 <_panic>
        return forkid;
  80116f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <sfork>:

// Challenge!
int
sfork(void)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801180:	68 b2 28 80 00       	push   $0x8028b2
  801185:	68 83 00 00 00       	push   $0x83
  80118a:	68 1f 28 80 00       	push   $0x80281f
  80118f:	e8 a2 f0 ff ff       	call   800236 <_panic>

00801194 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801197:	8b 45 08             	mov    0x8(%ebp),%eax
  80119a:	05 00 00 00 30       	add    $0x30000000,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	c1 ea 16             	shr    $0x16,%edx
  8011cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	74 11                	je     8011e8 <fd_alloc+0x2d>
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	c1 ea 0c             	shr    $0xc,%edx
  8011dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e3:	f6 c2 01             	test   $0x1,%dl
  8011e6:	75 09                	jne    8011f1 <fd_alloc+0x36>
			*fd_store = fd;
  8011e8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ef:	eb 17                	jmp    801208 <fd_alloc+0x4d>
  8011f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011fb:	75 c9                	jne    8011c6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011fd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801203:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801210:	83 f8 1f             	cmp    $0x1f,%eax
  801213:	77 36                	ja     80124b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801215:	c1 e0 0c             	shl    $0xc,%eax
  801218:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 16             	shr    $0x16,%edx
  801222:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	74 24                	je     801252 <fd_lookup+0x48>
  80122e:	89 c2                	mov    %eax,%edx
  801230:	c1 ea 0c             	shr    $0xc,%edx
  801233:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123a:	f6 c2 01             	test   $0x1,%dl
  80123d:	74 1a                	je     801259 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801242:	89 02                	mov    %eax,(%edx)
	return 0;
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
  801249:	eb 13                	jmp    80125e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801250:	eb 0c                	jmp    80125e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801257:	eb 05                	jmp    80125e <fd_lookup+0x54>
  801259:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801269:	ba 44 29 80 00       	mov    $0x802944,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126e:	eb 13                	jmp    801283 <dev_lookup+0x23>
  801270:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801273:	39 08                	cmp    %ecx,(%eax)
  801275:	75 0c                	jne    801283 <dev_lookup+0x23>
			*dev = devtab[i];
  801277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
  801281:	eb 2e                	jmp    8012b1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801283:	8b 02                	mov    (%edx),%eax
  801285:	85 c0                	test   %eax,%eax
  801287:	75 e7                	jne    801270 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801289:	a1 04 40 80 00       	mov    0x804004,%eax
  80128e:	8b 40 48             	mov    0x48(%eax),%eax
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	51                   	push   %ecx
  801295:	50                   	push   %eax
  801296:	68 c8 28 80 00       	push   $0x8028c8
  80129b:	e8 6f f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  8012a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 10             	sub    $0x10,%esp
  8012bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012cb:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ce:	50                   	push   %eax
  8012cf:	e8 36 ff ff ff       	call   80120a <fd_lookup>
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 05                	js     8012e0 <fd_close+0x2d>
	    || fd != fd2)
  8012db:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012de:	74 0c                	je     8012ec <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e0:	84 db                	test   %bl,%bl
  8012e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e7:	0f 44 c2             	cmove  %edx,%eax
  8012ea:	eb 41                	jmp    80132d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	ff 36                	pushl  (%esi)
  8012f5:	e8 66 ff ff ff       	call   801260 <dev_lookup>
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 1a                	js     80131d <fd_close+0x6a>
		if (dev->dev_close)
  801303:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801306:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80130e:	85 c0                	test   %eax,%eax
  801310:	74 0b                	je     80131d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	56                   	push   %esi
  801316:	ff d0                	call   *%eax
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	56                   	push   %esi
  801321:	6a 00                	push   $0x0
  801323:	e8 fc f9 ff ff       	call   800d24 <sys_page_unmap>
	return r;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	89 d8                	mov    %ebx,%eax
}
  80132d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	ff 75 08             	pushl  0x8(%ebp)
  801341:	e8 c4 fe ff ff       	call   80120a <fd_lookup>
  801346:	89 c2                	mov    %eax,%edx
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	85 d2                	test   %edx,%edx
  80134d:	78 10                	js     80135f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	6a 01                	push   $0x1
  801354:	ff 75 f4             	pushl  -0xc(%ebp)
  801357:	e8 57 ff ff ff       	call   8012b3 <fd_close>
  80135c:	83 c4 10             	add    $0x10,%esp
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <close_all>:

void
close_all(void)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	53                   	push   %ebx
  801365:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801368:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	53                   	push   %ebx
  801371:	e8 be ff ff ff       	call   801334 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801376:	83 c3 01             	add    $0x1,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	83 fb 20             	cmp    $0x20,%ebx
  80137f:	75 ec                	jne    80136d <close_all+0xc>
		close(i);
}
  801381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	83 ec 2c             	sub    $0x2c,%esp
  80138f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801392:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 6c fe ff ff       	call   80120a <fd_lookup>
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	83 c4 08             	add    $0x8,%esp
  8013a3:	85 d2                	test   %edx,%edx
  8013a5:	0f 88 c1 00 00 00    	js     80146c <dup+0xe6>
		return r;
	close(newfdnum);
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	56                   	push   %esi
  8013af:	e8 80 ff ff ff       	call   801334 <close>

	newfd = INDEX2FD(newfdnum);
  8013b4:	89 f3                	mov    %esi,%ebx
  8013b6:	c1 e3 0c             	shl    $0xc,%ebx
  8013b9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013bf:	83 c4 04             	add    $0x4,%esp
  8013c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c5:	e8 da fd ff ff       	call   8011a4 <fd2data>
  8013ca:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013cc:	89 1c 24             	mov    %ebx,(%esp)
  8013cf:	e8 d0 fd ff ff       	call   8011a4 <fd2data>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013da:	89 f8                	mov    %edi,%eax
  8013dc:	c1 e8 16             	shr    $0x16,%eax
  8013df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e6:	a8 01                	test   $0x1,%al
  8013e8:	74 37                	je     801421 <dup+0x9b>
  8013ea:	89 f8                	mov    %edi,%eax
  8013ec:	c1 e8 0c             	shr    $0xc,%eax
  8013ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 26                	je     801421 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	25 07 0e 00 00       	and    $0xe07,%eax
  80140a:	50                   	push   %eax
  80140b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140e:	6a 00                	push   $0x0
  801410:	57                   	push   %edi
  801411:	6a 00                	push   $0x0
  801413:	e8 ca f8 ff ff       	call   800ce2 <sys_page_map>
  801418:	89 c7                	mov    %eax,%edi
  80141a:	83 c4 20             	add    $0x20,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 2e                	js     80144f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801424:	89 d0                	mov    %edx,%eax
  801426:	c1 e8 0c             	shr    $0xc,%eax
  801429:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801430:	83 ec 0c             	sub    $0xc,%esp
  801433:	25 07 0e 00 00       	and    $0xe07,%eax
  801438:	50                   	push   %eax
  801439:	53                   	push   %ebx
  80143a:	6a 00                	push   $0x0
  80143c:	52                   	push   %edx
  80143d:	6a 00                	push   $0x0
  80143f:	e8 9e f8 ff ff       	call   800ce2 <sys_page_map>
  801444:	89 c7                	mov    %eax,%edi
  801446:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801449:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144b:	85 ff                	test   %edi,%edi
  80144d:	79 1d                	jns    80146c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	53                   	push   %ebx
  801453:	6a 00                	push   $0x0
  801455:	e8 ca f8 ff ff       	call   800d24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801460:	6a 00                	push   $0x0
  801462:	e8 bd f8 ff ff       	call   800d24 <sys_page_unmap>
	return r;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	89 f8                	mov    %edi,%eax
}
  80146c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 14             	sub    $0x14,%esp
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	53                   	push   %ebx
  801483:	e8 82 fd ff ff       	call   80120a <fd_lookup>
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 6d                	js     8014fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	ff 30                	pushl  (%eax)
  80149d:	e8 be fd ff ff       	call   801260 <dev_lookup>
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 4c                	js     8014f5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ac:	8b 42 08             	mov    0x8(%edx),%eax
  8014af:	83 e0 03             	and    $0x3,%eax
  8014b2:	83 f8 01             	cmp    $0x1,%eax
  8014b5:	75 21                	jne    8014d8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bc:	8b 40 48             	mov    0x48(%eax),%eax
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	53                   	push   %ebx
  8014c3:	50                   	push   %eax
  8014c4:	68 09 29 80 00       	push   $0x802909
  8014c9:	e8 41 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d6:	eb 26                	jmp    8014fe <read+0x8a>
	}
	if (!dev->dev_read)
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	8b 40 08             	mov    0x8(%eax),%eax
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	74 17                	je     8014f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	ff 75 10             	pushl  0x10(%ebp)
  8014e8:	ff 75 0c             	pushl  0xc(%ebp)
  8014eb:	52                   	push   %edx
  8014ec:	ff d0                	call   *%eax
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 09                	jmp    8014fe <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	eb 05                	jmp    8014fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014fe:	89 d0                	mov    %edx,%eax
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	57                   	push   %edi
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801511:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801514:	bb 00 00 00 00       	mov    $0x0,%ebx
  801519:	eb 21                	jmp    80153c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	89 f0                	mov    %esi,%eax
  801520:	29 d8                	sub    %ebx,%eax
  801522:	50                   	push   %eax
  801523:	89 d8                	mov    %ebx,%eax
  801525:	03 45 0c             	add    0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	57                   	push   %edi
  80152a:	e8 45 ff ff ff       	call   801474 <read>
		if (m < 0)
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 0c                	js     801542 <readn+0x3d>
			return m;
		if (m == 0)
  801536:	85 c0                	test   %eax,%eax
  801538:	74 06                	je     801540 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153a:	01 c3                	add    %eax,%ebx
  80153c:	39 f3                	cmp    %esi,%ebx
  80153e:	72 db                	jb     80151b <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801540:	89 d8                	mov    %ebx,%eax
}
  801542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 14             	sub    $0x14,%esp
  801551:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801554:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	53                   	push   %ebx
  801559:	e8 ac fc ff ff       	call   80120a <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	89 c2                	mov    %eax,%edx
  801563:	85 c0                	test   %eax,%eax
  801565:	78 68                	js     8015cf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	ff 30                	pushl  (%eax)
  801573:	e8 e8 fc ff ff       	call   801260 <dev_lookup>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 47                	js     8015c6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801586:	75 21                	jne    8015a9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801588:	a1 04 40 80 00       	mov    0x804004,%eax
  80158d:	8b 40 48             	mov    0x48(%eax),%eax
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	53                   	push   %ebx
  801594:	50                   	push   %eax
  801595:	68 25 29 80 00       	push   $0x802925
  80159a:	e8 70 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a7:	eb 26                	jmp    8015cf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ac:	8b 52 0c             	mov    0xc(%edx),%edx
  8015af:	85 d2                	test   %edx,%edx
  8015b1:	74 17                	je     8015ca <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b3:	83 ec 04             	sub    $0x4,%esp
  8015b6:	ff 75 10             	pushl  0x10(%ebp)
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	50                   	push   %eax
  8015bd:	ff d2                	call   *%edx
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	eb 09                	jmp    8015cf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	eb 05                	jmp    8015cf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015cf:	89 d0                	mov    %edx,%eax
  8015d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	e8 22 fc ff ff       	call   80120a <fd_lookup>
  8015e8:	83 c4 08             	add    $0x8,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 0e                	js     8015fd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 14             	sub    $0x14,%esp
  801606:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801609:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	53                   	push   %ebx
  80160e:	e8 f7 fb ff ff       	call   80120a <fd_lookup>
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	89 c2                	mov    %eax,%edx
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 65                	js     801681 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	ff 30                	pushl  (%eax)
  801628:	e8 33 fc ff ff       	call   801260 <dev_lookup>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 44                	js     801678 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801634:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801637:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163b:	75 21                	jne    80165e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801642:	8b 40 48             	mov    0x48(%eax),%eax
  801645:	83 ec 04             	sub    $0x4,%esp
  801648:	53                   	push   %ebx
  801649:	50                   	push   %eax
  80164a:	68 e8 28 80 00       	push   $0x8028e8
  80164f:	e8 bb ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165c:	eb 23                	jmp    801681 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80165e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801661:	8b 52 18             	mov    0x18(%edx),%edx
  801664:	85 d2                	test   %edx,%edx
  801666:	74 14                	je     80167c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	50                   	push   %eax
  80166f:	ff d2                	call   *%edx
  801671:	89 c2                	mov    %eax,%edx
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	eb 09                	jmp    801681 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801678:	89 c2                	mov    %eax,%edx
  80167a:	eb 05                	jmp    801681 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801681:	89 d0                	mov    %edx,%eax
  801683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 14             	sub    $0x14,%esp
  80168f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801692:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	e8 6c fb ff ff       	call   80120a <fd_lookup>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 58                	js     8016ff <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b1:	ff 30                	pushl  (%eax)
  8016b3:	e8 a8 fb ff ff       	call   801260 <dev_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 37                	js     8016f6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c6:	74 32                	je     8016fa <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016cb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d2:	00 00 00 
	stat->st_isdir = 0;
  8016d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016dc:	00 00 00 
	stat->st_dev = dev;
  8016df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	53                   	push   %ebx
  8016e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ec:	ff 50 14             	call   *0x14(%eax)
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	eb 09                	jmp    8016ff <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	eb 05                	jmp    8016ff <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ff:	89 d0                	mov    %edx,%eax
  801701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	6a 00                	push   $0x0
  801710:	ff 75 08             	pushl  0x8(%ebp)
  801713:	e8 09 02 00 00       	call   801921 <open>
  801718:	89 c3                	mov    %eax,%ebx
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 db                	test   %ebx,%ebx
  80171f:	78 1b                	js     80173c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	ff 75 0c             	pushl  0xc(%ebp)
  801727:	53                   	push   %ebx
  801728:	e8 5b ff ff ff       	call   801688 <fstat>
  80172d:	89 c6                	mov    %eax,%esi
	close(fd);
  80172f:	89 1c 24             	mov    %ebx,(%esp)
  801732:	e8 fd fb ff ff       	call   801334 <close>
	return r;
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	89 f0                	mov    %esi,%eax
}
  80173c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5d                   	pop    %ebp
  801742:	c3                   	ret    

00801743 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	89 c6                	mov    %eax,%esi
  80174a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801753:	75 12                	jne    801767 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801755:	83 ec 0c             	sub    $0xc,%esp
  801758:	6a 01                	push   $0x1
  80175a:	e8 92 08 00 00       	call   801ff1 <ipc_find_env>
  80175f:	a3 00 40 80 00       	mov    %eax,0x804000
  801764:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801767:	6a 07                	push   $0x7
  801769:	68 00 50 80 00       	push   $0x805000
  80176e:	56                   	push   %esi
  80176f:	ff 35 00 40 80 00    	pushl  0x804000
  801775:	e8 23 08 00 00       	call   801f9d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177a:	83 c4 0c             	add    $0xc,%esp
  80177d:	6a 00                	push   $0x0
  80177f:	53                   	push   %ebx
  801780:	6a 00                	push   $0x0
  801782:	e8 ad 07 00 00       	call   801f34 <ipc_recv>
}
  801787:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	8b 40 0c             	mov    0xc(%eax),%eax
  80179a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b1:	e8 8d ff ff ff       	call   801743 <fsipc>
}
  8017b6:	c9                   	leave  
  8017b7:	c3                   	ret    

008017b8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d3:	e8 6b ff ff ff       	call   801743 <fsipc>
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f9:	e8 45 ff ff ff       	call   801743 <fsipc>
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	85 d2                	test   %edx,%edx
  801802:	78 2c                	js     801830 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	68 00 50 80 00       	push   $0x805000
  80180c:	53                   	push   %ebx
  80180d:	e8 84 f0 ff ff       	call   800896 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801812:	a1 80 50 80 00       	mov    0x805080,%eax
  801817:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181d:	a1 84 50 80 00       	mov    0x805084,%eax
  801822:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	57                   	push   %edi
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
  801847:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80184c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80184f:	eb 3d                	jmp    80188e <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801851:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801857:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80185c:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	57                   	push   %edi
  801863:	53                   	push   %ebx
  801864:	68 08 50 80 00       	push   $0x805008
  801869:	e8 ba f1 ff ff       	call   800a28 <memmove>
                fsipcbuf.write.req_n = tmp; 
  80186e:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 04 00 00 00       	mov    $0x4,%eax
  80187e:	e8 c0 fe ff ff       	call   801743 <fsipc>
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	78 0d                	js     801897 <devfile_write+0x62>
		        return r;
                n -= tmp;
  80188a:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80188c:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80188e:	85 f6                	test   %esi,%esi
  801890:	75 bf                	jne    801851 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801892:	89 d8                	mov    %ebx,%eax
  801894:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801897:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189a:	5b                   	pop    %ebx
  80189b:	5e                   	pop    %esi
  80189c:	5f                   	pop    %edi
  80189d:	5d                   	pop    %ebp
  80189e:	c3                   	ret    

0080189f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c2:	e8 7c fe ff ff       	call   801743 <fsipc>
  8018c7:	89 c3                	mov    %eax,%ebx
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 4b                	js     801918 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018cd:	39 c6                	cmp    %eax,%esi
  8018cf:	73 16                	jae    8018e7 <devfile_read+0x48>
  8018d1:	68 54 29 80 00       	push   $0x802954
  8018d6:	68 5b 29 80 00       	push   $0x80295b
  8018db:	6a 7c                	push   $0x7c
  8018dd:	68 70 29 80 00       	push   $0x802970
  8018e2:	e8 4f e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ec:	7e 16                	jle    801904 <devfile_read+0x65>
  8018ee:	68 7b 29 80 00       	push   $0x80297b
  8018f3:	68 5b 29 80 00       	push   $0x80295b
  8018f8:	6a 7d                	push   $0x7d
  8018fa:	68 70 29 80 00       	push   $0x802970
  8018ff:	e8 32 e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	50                   	push   %eax
  801908:	68 00 50 80 00       	push   $0x805000
  80190d:	ff 75 0c             	pushl  0xc(%ebp)
  801910:	e8 13 f1 ff ff       	call   800a28 <memmove>
	return r;
  801915:	83 c4 10             	add    $0x10,%esp
}
  801918:	89 d8                	mov    %ebx,%eax
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 20             	sub    $0x20,%esp
  801928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80192b:	53                   	push   %ebx
  80192c:	e8 2c ef ff ff       	call   80085d <strlen>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801939:	7f 67                	jg     8019a2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	e8 74 f8 ff ff       	call   8011bb <fd_alloc>
  801947:	83 c4 10             	add    $0x10,%esp
		return r;
  80194a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 57                	js     8019a7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	53                   	push   %ebx
  801954:	68 00 50 80 00       	push   $0x805000
  801959:	e8 38 ef ff ff       	call   800896 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801961:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801966:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801969:	b8 01 00 00 00       	mov    $0x1,%eax
  80196e:	e8 d0 fd ff ff       	call   801743 <fsipc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	85 c0                	test   %eax,%eax
  80197a:	79 14                	jns    801990 <open+0x6f>
		fd_close(fd, 0);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	6a 00                	push   $0x0
  801981:	ff 75 f4             	pushl  -0xc(%ebp)
  801984:	e8 2a f9 ff ff       	call   8012b3 <fd_close>
		return r;
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	89 da                	mov    %ebx,%edx
  80198e:	eb 17                	jmp    8019a7 <open+0x86>
	}

	return fd2num(fd);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	ff 75 f4             	pushl  -0xc(%ebp)
  801996:	e8 f9 f7 ff ff       	call   801194 <fd2num>
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	eb 05                	jmp    8019a7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019a7:	89 d0                	mov    %edx,%eax
  8019a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8019be:	e8 80 fd ff ff       	call   801743 <fsipc>
}
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	56                   	push   %esi
  8019c9:	53                   	push   %ebx
  8019ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	ff 75 08             	pushl  0x8(%ebp)
  8019d3:	e8 cc f7 ff ff       	call   8011a4 <fd2data>
  8019d8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019da:	83 c4 08             	add    $0x8,%esp
  8019dd:	68 87 29 80 00       	push   $0x802987
  8019e2:	53                   	push   %ebx
  8019e3:	e8 ae ee ff ff       	call   800896 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e8:	8b 56 04             	mov    0x4(%esi),%edx
  8019eb:	89 d0                	mov    %edx,%eax
  8019ed:	2b 06                	sub    (%esi),%eax
  8019ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fc:	00 00 00 
	stat->st_dev = &devpipe;
  8019ff:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a06:	30 80 00 
	return 0;
}
  801a09:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a11:	5b                   	pop    %ebx
  801a12:	5e                   	pop    %esi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1f:	53                   	push   %ebx
  801a20:	6a 00                	push   $0x0
  801a22:	e8 fd f2 ff ff       	call   800d24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a27:	89 1c 24             	mov    %ebx,(%esp)
  801a2a:	e8 75 f7 ff ff       	call   8011a4 <fd2data>
  801a2f:	83 c4 08             	add    $0x8,%esp
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 ea f2 ff ff       	call   800d24 <sys_page_unmap>
}
  801a3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
  801a48:	89 c6                	mov    %eax,%esi
  801a4a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a52:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	56                   	push   %esi
  801a59:	e8 cb 05 00 00       	call   802029 <pageref>
  801a5e:	89 c7                	mov    %eax,%edi
  801a60:	83 c4 04             	add    $0x4,%esp
  801a63:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a66:	e8 be 05 00 00       	call   802029 <pageref>
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	39 c7                	cmp    %eax,%edi
  801a70:	0f 94 c2             	sete   %dl
  801a73:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a76:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a7c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a7f:	39 fb                	cmp    %edi,%ebx
  801a81:	74 19                	je     801a9c <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801a83:	84 d2                	test   %dl,%dl
  801a85:	74 c6                	je     801a4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a87:	8b 51 58             	mov    0x58(%ecx),%edx
  801a8a:	50                   	push   %eax
  801a8b:	52                   	push   %edx
  801a8c:	53                   	push   %ebx
  801a8d:	68 8e 29 80 00       	push   $0x80298e
  801a92:	e8 78 e8 ff ff       	call   80030f <cprintf>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	eb b1                	jmp    801a4d <_pipeisclosed+0xe>
	}
}
  801a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 28             	sub    $0x28,%esp
  801aad:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab0:	56                   	push   %esi
  801ab1:	e8 ee f6 ff ff       	call   8011a4 <fd2data>
  801ab6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac0:	eb 4b                	jmp    801b0d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac2:	89 da                	mov    %ebx,%edx
  801ac4:	89 f0                	mov    %esi,%eax
  801ac6:	e8 74 ff ff ff       	call   801a3f <_pipeisclosed>
  801acb:	85 c0                	test   %eax,%eax
  801acd:	75 48                	jne    801b17 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801acf:	e8 ac f1 ff ff       	call   800c80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad7:	8b 0b                	mov    (%ebx),%ecx
  801ad9:	8d 51 20             	lea    0x20(%ecx),%edx
  801adc:	39 d0                	cmp    %edx,%eax
  801ade:	73 e2                	jae    801ac2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	c1 fa 1f             	sar    $0x1f,%edx
  801aef:	89 d1                	mov    %edx,%ecx
  801af1:	c1 e9 1b             	shr    $0x1b,%ecx
  801af4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af7:	83 e2 1f             	and    $0x1f,%edx
  801afa:	29 ca                	sub    %ecx,%edx
  801afc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b04:	83 c0 01             	add    $0x1,%eax
  801b07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0a:	83 c7 01             	add    $0x1,%edi
  801b0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b10:	75 c2                	jne    801ad4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b12:	8b 45 10             	mov    0x10(%ebp),%eax
  801b15:	eb 05                	jmp    801b1c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 18             	sub    $0x18,%esp
  801b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b30:	57                   	push   %edi
  801b31:	e8 6e f6 ff ff       	call   8011a4 <fd2data>
  801b36:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b40:	eb 3d                	jmp    801b7f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b42:	85 db                	test   %ebx,%ebx
  801b44:	74 04                	je     801b4a <devpipe_read+0x26>
				return i;
  801b46:	89 d8                	mov    %ebx,%eax
  801b48:	eb 44                	jmp    801b8e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4a:	89 f2                	mov    %esi,%edx
  801b4c:	89 f8                	mov    %edi,%eax
  801b4e:	e8 ec fe ff ff       	call   801a3f <_pipeisclosed>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	75 32                	jne    801b89 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b57:	e8 24 f1 ff ff       	call   800c80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b5c:	8b 06                	mov    (%esi),%eax
  801b5e:	3b 46 04             	cmp    0x4(%esi),%eax
  801b61:	74 df                	je     801b42 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b63:	99                   	cltd   
  801b64:	c1 ea 1b             	shr    $0x1b,%edx
  801b67:	01 d0                	add    %edx,%eax
  801b69:	83 e0 1f             	and    $0x1f,%eax
  801b6c:	29 d0                	sub    %edx,%eax
  801b6e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b76:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b79:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7c:	83 c3 01             	add    $0x1,%ebx
  801b7f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b82:	75 d8                	jne    801b5c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	eb 05                	jmp    801b8e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 14 f6 ff ff       	call   8011bb <fd_alloc>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 2c 01 00 00    	js     801ce0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	68 07 04 00 00       	push   $0x407
  801bbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 d9 f0 ff ff       	call   800c9f <sys_page_alloc>
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	0f 88 0d 01 00 00    	js     801ce0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd9:	50                   	push   %eax
  801bda:	e8 dc f5 ff ff       	call   8011bb <fd_alloc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	0f 88 e2 00 00 00    	js     801cce <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bec:	83 ec 04             	sub    $0x4,%esp
  801bef:	68 07 04 00 00       	push   $0x407
  801bf4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 a1 f0 ff ff       	call   800c9f <sys_page_alloc>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 c3 00 00 00    	js     801cce <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c11:	e8 8e f5 ff ff       	call   8011a4 <fd2data>
  801c16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 c4 0c             	add    $0xc,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	50                   	push   %eax
  801c21:	6a 00                	push   $0x0
  801c23:	e8 77 f0 ff ff       	call   800c9f <sys_page_alloc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 89 00 00 00    	js     801cbe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3b:	e8 64 f5 ff ff       	call   8011a4 <fd2data>
  801c40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c47:	50                   	push   %eax
  801c48:	6a 00                	push   $0x0
  801c4a:	56                   	push   %esi
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 90 f0 ff ff       	call   800ce2 <sys_page_map>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 20             	add    $0x20,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 55                	js     801cb0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8b:	e8 04 f5 ff ff       	call   801194 <fd2num>
  801c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c95:	83 c4 04             	add    $0x4,%esp
  801c98:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9b:	e8 f4 f4 ff ff       	call   801194 <fd2num>
  801ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cae:	eb 30                	jmp    801ce0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	56                   	push   %esi
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 69 f0 ff ff       	call   800d24 <sys_page_unmap>
  801cbb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 59 f0 ff ff       	call   800d24 <sys_page_unmap>
  801ccb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cce:	83 ec 08             	sub    $0x8,%esp
  801cd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 49 f0 ff ff       	call   800d24 <sys_page_unmap>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce0:	89 d0                	mov    %edx,%eax
  801ce2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf2:	50                   	push   %eax
  801cf3:	ff 75 08             	pushl  0x8(%ebp)
  801cf6:	e8 0f f5 ff ff       	call   80120a <fd_lookup>
  801cfb:	89 c2                	mov    %eax,%edx
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 d2                	test   %edx,%edx
  801d02:	78 18                	js     801d1c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0a:	e8 95 f4 ff ff       	call   8011a4 <fd2data>
	return _pipeisclosed(fd, p);
  801d0f:	89 c2                	mov    %eax,%edx
  801d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d14:	e8 26 fd ff ff       	call   801a3f <_pipeisclosed>
  801d19:	83 c4 10             	add    $0x10,%esp
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2e:	68 a6 29 80 00       	push   $0x8029a6
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	e8 5b eb ff ff       	call   800896 <strcpy>
	return 0;
}
  801d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d53:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d59:	eb 2d                	jmp    801d88 <devcons_write+0x46>
		m = n - tot;
  801d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d60:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d63:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d68:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	53                   	push   %ebx
  801d6f:	03 45 0c             	add    0xc(%ebp),%eax
  801d72:	50                   	push   %eax
  801d73:	57                   	push   %edi
  801d74:	e8 af ec ff ff       	call   800a28 <memmove>
		sys_cputs(buf, m);
  801d79:	83 c4 08             	add    $0x8,%esp
  801d7c:	53                   	push   %ebx
  801d7d:	57                   	push   %edi
  801d7e:	e8 60 ee ff ff       	call   800be3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d83:	01 de                	add    %ebx,%esi
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	89 f0                	mov    %esi,%eax
  801d8a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8d:	72 cc                	jb     801d5b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d92:	5b                   	pop    %ebx
  801d93:	5e                   	pop    %esi
  801d94:	5f                   	pop    %edi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801da2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da6:	75 07                	jne    801daf <devcons_read+0x18>
  801da8:	eb 28                	jmp    801dd2 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801daa:	e8 d1 ee ff ff       	call   800c80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801daf:	e8 4d ee ff ff       	call   800c01 <sys_cgetc>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	74 f2                	je     801daa <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 16                	js     801dd2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbc:	83 f8 04             	cmp    $0x4,%eax
  801dbf:	74 0c                	je     801dcd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc4:	88 02                	mov    %al,(%edx)
	return 1;
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	eb 05                	jmp    801dd2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de0:	6a 01                	push   $0x1
  801de2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	e8 f8 ed ff ff       	call   800be3 <sys_cputs>
  801deb:	83 c4 10             	add    $0x10,%esp
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <getchar>:

int
getchar(void)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df6:	6a 01                	push   $0x1
  801df8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 71 f6 ff ff       	call   801474 <read>
	if (r < 0)
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 0f                	js     801e19 <getchar+0x29>
		return r;
	if (r < 1)
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	7e 06                	jle    801e14 <getchar+0x24>
		return -E_EOF;
	return c;
  801e0e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e12:	eb 05                	jmp    801e19 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e14:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	ff 75 08             	pushl  0x8(%ebp)
  801e28:	e8 dd f3 ff ff       	call   80120a <fd_lookup>
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 11                	js     801e45 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3d:	39 10                	cmp    %edx,(%eax)
  801e3f:	0f 94 c0             	sete   %al
  801e42:	0f b6 c0             	movzbl %al,%eax
}
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <opencons>:

int
opencons(void)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	e8 65 f3 ff ff       	call   8011bb <fd_alloc>
  801e56:	83 c4 10             	add    $0x10,%esp
		return r;
  801e59:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 3e                	js     801e9d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	68 07 04 00 00       	push   $0x407
  801e67:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 2e ee ff ff       	call   800c9f <sys_page_alloc>
  801e71:	83 c4 10             	add    $0x10,%esp
		return r;
  801e74:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 23                	js     801e9d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e83:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	50                   	push   %eax
  801e93:	e8 fc f2 ff ff       	call   801194 <fd2num>
  801e98:	89 c2                	mov    %eax,%edx
  801e9a:	83 c4 10             	add    $0x10,%esp
}
  801e9d:	89 d0                	mov    %edx,%eax
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ea7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eae:	75 2c                	jne    801edc <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801eb0:	83 ec 04             	sub    $0x4,%esp
  801eb3:	6a 07                	push   $0x7
  801eb5:	68 00 f0 bf ee       	push   $0xeebff000
  801eba:	6a 00                	push   $0x0
  801ebc:	e8 de ed ff ff       	call   800c9f <sys_page_alloc>
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	74 14                	je     801edc <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801ec8:	83 ec 04             	sub    $0x4,%esp
  801ecb:	68 b4 29 80 00       	push   $0x8029b4
  801ed0:	6a 21                	push   $0x21
  801ed2:	68 18 2a 80 00       	push   $0x802a18
  801ed7:	e8 5a e3 ff ff       	call   800236 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801edc:	8b 45 08             	mov    0x8(%ebp),%eax
  801edf:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ee4:	83 ec 08             	sub    $0x8,%esp
  801ee7:	68 10 1f 80 00       	push   $0x801f10
  801eec:	6a 00                	push   $0x0
  801eee:	e8 f7 ee ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	79 14                	jns    801f0e <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801efa:	83 ec 04             	sub    $0x4,%esp
  801efd:	68 e0 29 80 00       	push   $0x8029e0
  801f02:	6a 29                	push   $0x29
  801f04:	68 18 2a 80 00       	push   $0x802a18
  801f09:	e8 28 e3 ff ff       	call   800236 <_panic>
}
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    

00801f10 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f10:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f11:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f16:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f18:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801f1b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801f20:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801f24:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801f28:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801f2a:	83 c4 08             	add    $0x8,%esp
        popal
  801f2d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f2e:	83 c4 04             	add    $0x4,%esp
        popfl
  801f31:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801f32:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f33:	c3                   	ret    

00801f34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f42:	85 c0                	test   %eax,%eax
  801f44:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f49:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	50                   	push   %eax
  801f50:	e8 fa ee ff ff       	call   800e4f <sys_ipc_recv>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	79 16                	jns    801f72 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f5c:	85 f6                	test   %esi,%esi
  801f5e:	74 06                	je     801f66 <ipc_recv+0x32>
  801f60:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f66:	85 db                	test   %ebx,%ebx
  801f68:	74 2c                	je     801f96 <ipc_recv+0x62>
  801f6a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f70:	eb 24                	jmp    801f96 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f72:	85 f6                	test   %esi,%esi
  801f74:	74 0a                	je     801f80 <ipc_recv+0x4c>
  801f76:	a1 04 40 80 00       	mov    0x804004,%eax
  801f7b:	8b 40 74             	mov    0x74(%eax),%eax
  801f7e:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f80:	85 db                	test   %ebx,%ebx
  801f82:	74 0a                	je     801f8e <ipc_recv+0x5a>
  801f84:	a1 04 40 80 00       	mov    0x804004,%eax
  801f89:	8b 40 78             	mov    0x78(%eax),%eax
  801f8c:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801f93:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 0c             	sub    $0xc,%esp
  801fa6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801faf:	85 db                	test   %ebx,%ebx
  801fb1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fb6:	0f 44 d8             	cmove  %eax,%ebx
  801fb9:	eb 1c                	jmp    801fd7 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fbb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fbe:	74 12                	je     801fd2 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fc0:	50                   	push   %eax
  801fc1:	68 26 2a 80 00       	push   $0x802a26
  801fc6:	6a 39                	push   $0x39
  801fc8:	68 41 2a 80 00       	push   $0x802a41
  801fcd:	e8 64 e2 ff ff       	call   800236 <_panic>
                 sys_yield();
  801fd2:	e8 a9 ec ff ff       	call   800c80 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fd7:	ff 75 14             	pushl  0x14(%ebp)
  801fda:	53                   	push   %ebx
  801fdb:	56                   	push   %esi
  801fdc:	57                   	push   %edi
  801fdd:	e8 4a ee ff ff       	call   800e2c <sys_ipc_try_send>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 d2                	js     801fbb <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fe9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5e                   	pop    %esi
  801fee:	5f                   	pop    %edi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    

00801ff1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ffc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fff:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802005:	8b 52 50             	mov    0x50(%edx),%edx
  802008:	39 ca                	cmp    %ecx,%edx
  80200a:	75 0d                	jne    802019 <ipc_find_env+0x28>
			return envs[i].env_id;
  80200c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200f:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802014:	8b 40 08             	mov    0x8(%eax),%eax
  802017:	eb 0e                	jmp    802027 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802019:	83 c0 01             	add    $0x1,%eax
  80201c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802021:	75 d9                	jne    801ffc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802023:	66 b8 00 00          	mov    $0x0,%ax
}
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202f:	89 d0                	mov    %edx,%eax
  802031:	c1 e8 16             	shr    $0x16,%eax
  802034:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802040:	f6 c1 01             	test   $0x1,%cl
  802043:	74 1d                	je     802062 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802045:	c1 ea 0c             	shr    $0xc,%edx
  802048:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204f:	f6 c2 01             	test   $0x1,%dl
  802052:	74 0e                	je     802062 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802054:	c1 ea 0c             	shr    $0xc,%edx
  802057:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205e:	ef 
  80205f:	0f b7 c0             	movzwl %ax,%eax
}
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	83 ec 10             	sub    $0x10,%esp
  802076:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80207a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80207e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802082:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802086:	85 d2                	test   %edx,%edx
  802088:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80208c:	89 34 24             	mov    %esi,(%esp)
  80208f:	89 c8                	mov    %ecx,%eax
  802091:	75 35                	jne    8020c8 <__udivdi3+0x58>
  802093:	39 f1                	cmp    %esi,%ecx
  802095:	0f 87 bd 00 00 00    	ja     802158 <__udivdi3+0xe8>
  80209b:	85 c9                	test   %ecx,%ecx
  80209d:	89 cd                	mov    %ecx,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f1                	div    %ecx
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 f0                	mov    %esi,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c6                	mov    %eax,%esi
  8020b4:	89 f8                	mov    %edi,%eax
  8020b6:	f7 f5                	div    %ebp
  8020b8:	89 f2                	mov    %esi,%edx
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	5e                   	pop    %esi
  8020be:	5f                   	pop    %edi
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    
  8020c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	3b 14 24             	cmp    (%esp),%edx
  8020cb:	77 7b                	ja     802148 <__udivdi3+0xd8>
  8020cd:	0f bd f2             	bsr    %edx,%esi
  8020d0:	83 f6 1f             	xor    $0x1f,%esi
  8020d3:	0f 84 97 00 00 00    	je     802170 <__udivdi3+0x100>
  8020d9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020de:	89 d7                	mov    %edx,%edi
  8020e0:	89 f1                	mov    %esi,%ecx
  8020e2:	29 f5                	sub    %esi,%ebp
  8020e4:	d3 e7                	shl    %cl,%edi
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	d3 ea                	shr    %cl,%edx
  8020ec:	89 f1                	mov    %esi,%ecx
  8020ee:	09 fa                	or     %edi,%edx
  8020f0:	8b 3c 24             	mov    (%esp),%edi
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802103:	89 fa                	mov    %edi,%edx
  802105:	d3 ea                	shr    %cl,%edx
  802107:	89 f1                	mov    %esi,%ecx
  802109:	d3 e7                	shl    %cl,%edi
  80210b:	89 e9                	mov    %ebp,%ecx
  80210d:	d3 e8                	shr    %cl,%eax
  80210f:	09 c7                	or     %eax,%edi
  802111:	89 f8                	mov    %edi,%eax
  802113:	f7 74 24 08          	divl   0x8(%esp)
  802117:	89 d5                	mov    %edx,%ebp
  802119:	89 c7                	mov    %eax,%edi
  80211b:	f7 64 24 0c          	mull   0xc(%esp)
  80211f:	39 d5                	cmp    %edx,%ebp
  802121:	89 14 24             	mov    %edx,(%esp)
  802124:	72 11                	jb     802137 <__udivdi3+0xc7>
  802126:	8b 54 24 04          	mov    0x4(%esp),%edx
  80212a:	89 f1                	mov    %esi,%ecx
  80212c:	d3 e2                	shl    %cl,%edx
  80212e:	39 c2                	cmp    %eax,%edx
  802130:	73 5e                	jae    802190 <__udivdi3+0x120>
  802132:	3b 2c 24             	cmp    (%esp),%ebp
  802135:	75 59                	jne    802190 <__udivdi3+0x120>
  802137:	8d 47 ff             	lea    -0x1(%edi),%eax
  80213a:	31 f6                	xor    %esi,%esi
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	31 f6                	xor    %esi,%esi
  80214a:	31 c0                	xor    %eax,%eax
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	89 f2                	mov    %esi,%edx
  80215a:	31 f6                	xor    %esi,%esi
  80215c:	89 f8                	mov    %edi,%eax
  80215e:	f7 f1                	div    %ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802174:	76 0b                	jbe    802181 <__udivdi3+0x111>
  802176:	31 c0                	xor    %eax,%eax
  802178:	3b 14 24             	cmp    (%esp),%edx
  80217b:	0f 83 37 ff ff ff    	jae    8020b8 <__udivdi3+0x48>
  802181:	b8 01 00 00 00       	mov    $0x1,%eax
  802186:	e9 2d ff ff ff       	jmp    8020b8 <__udivdi3+0x48>
  80218b:	90                   	nop
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 f8                	mov    %edi,%eax
  802192:	31 f6                	xor    %esi,%esi
  802194:	e9 1f ff ff ff       	jmp    8020b8 <__udivdi3+0x48>
  802199:	66 90                	xchg   %ax,%ax
  80219b:	66 90                	xchg   %ax,%ax
  80219d:	66 90                	xchg   %ax,%ax
  80219f:	90                   	nop

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	83 ec 20             	sub    $0x20,%esp
  8021a6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021aa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b2:	89 c6                	mov    %eax,%esi
  8021b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021b8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021bc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021c8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	75 1e                	jne    8021f0 <__umoddi3+0x50>
  8021d2:	39 f7                	cmp    %esi,%edi
  8021d4:	76 52                	jbe    802228 <__umoddi3+0x88>
  8021d6:	89 c8                	mov    %ecx,%eax
  8021d8:	89 f2                	mov    %esi,%edx
  8021da:	f7 f7                	div    %edi
  8021dc:	89 d0                	mov    %edx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	83 c4 20             	add    $0x20,%esp
  8021e3:	5e                   	pop    %esi
  8021e4:	5f                   	pop    %edi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    
  8021e7:	89 f6                	mov    %esi,%esi
  8021e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021f0:	39 f0                	cmp    %esi,%eax
  8021f2:	77 5c                	ja     802250 <__umoddi3+0xb0>
  8021f4:	0f bd e8             	bsr    %eax,%ebp
  8021f7:	83 f5 1f             	xor    $0x1f,%ebp
  8021fa:	75 64                	jne    802260 <__umoddi3+0xc0>
  8021fc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802200:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802204:	0f 86 f6 00 00 00    	jbe    802300 <__umoddi3+0x160>
  80220a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80220e:	0f 82 ec 00 00 00    	jb     802300 <__umoddi3+0x160>
  802214:	8b 44 24 14          	mov    0x14(%esp),%eax
  802218:	8b 54 24 18          	mov    0x18(%esp),%edx
  80221c:	83 c4 20             	add    $0x20,%esp
  80221f:	5e                   	pop    %esi
  802220:	5f                   	pop    %edi
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    
  802223:	90                   	nop
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	85 ff                	test   %edi,%edi
  80222a:	89 fd                	mov    %edi,%ebp
  80222c:	75 0b                	jne    802239 <__umoddi3+0x99>
  80222e:	b8 01 00 00 00       	mov    $0x1,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f7                	div    %edi
  802237:	89 c5                	mov    %eax,%ebp
  802239:	8b 44 24 10          	mov    0x10(%esp),%eax
  80223d:	31 d2                	xor    %edx,%edx
  80223f:	f7 f5                	div    %ebp
  802241:	89 c8                	mov    %ecx,%eax
  802243:	f7 f5                	div    %ebp
  802245:	eb 95                	jmp    8021dc <__umoddi3+0x3c>
  802247:	89 f6                	mov    %esi,%esi
  802249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 20             	add    $0x20,%esp
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	90                   	nop
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	b8 20 00 00 00       	mov    $0x20,%eax
  802265:	89 e9                	mov    %ebp,%ecx
  802267:	29 e8                	sub    %ebp,%eax
  802269:	d3 e2                	shl    %cl,%edx
  80226b:	89 c7                	mov    %eax,%edi
  80226d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802271:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 c1                	mov    %eax,%ecx
  80227b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80227f:	09 d1                	or     %edx,%ecx
  802281:	89 fa                	mov    %edi,%edx
  802283:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802287:	89 e9                	mov    %ebp,%ecx
  802289:	d3 e0                	shl    %cl,%eax
  80228b:	89 f9                	mov    %edi,%ecx
  80228d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802291:	89 f0                	mov    %esi,%eax
  802293:	d3 e8                	shr    %cl,%eax
  802295:	89 e9                	mov    %ebp,%ecx
  802297:	89 c7                	mov    %eax,%edi
  802299:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80229d:	d3 e6                	shl    %cl,%esi
  80229f:	89 d1                	mov    %edx,%ecx
  8022a1:	89 fa                	mov    %edi,%edx
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	09 f0                	or     %esi,%eax
  8022a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022ad:	f7 74 24 10          	divl   0x10(%esp)
  8022b1:	d3 e6                	shl    %cl,%esi
  8022b3:	89 d1                	mov    %edx,%ecx
  8022b5:	f7 64 24 0c          	mull   0xc(%esp)
  8022b9:	39 d1                	cmp    %edx,%ecx
  8022bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022bf:	89 d7                	mov    %edx,%edi
  8022c1:	89 c6                	mov    %eax,%esi
  8022c3:	72 0a                	jb     8022cf <__umoddi3+0x12f>
  8022c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022c9:	73 10                	jae    8022db <__umoddi3+0x13b>
  8022cb:	39 d1                	cmp    %edx,%ecx
  8022cd:	75 0c                	jne    8022db <__umoddi3+0x13b>
  8022cf:	89 d7                	mov    %edx,%edi
  8022d1:	89 c6                	mov    %eax,%esi
  8022d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022db:	89 ca                	mov    %ecx,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022e3:	29 f0                	sub    %esi,%eax
  8022e5:	19 fa                	sbb    %edi,%edx
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022ee:	89 d7                	mov    %edx,%edi
  8022f0:	d3 e7                	shl    %cl,%edi
  8022f2:	89 e9                	mov    %ebp,%ecx
  8022f4:	09 f8                	or     %edi,%eax
  8022f6:	d3 ea                	shr    %cl,%edx
  8022f8:	83 c4 20             	add    $0x20,%esp
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
  8022ff:	90                   	nop
  802300:	8b 74 24 10          	mov    0x10(%esp),%esi
  802304:	29 f9                	sub    %edi,%ecx
  802306:	19 c6                	sbb    %eax,%esi
  802308:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80230c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802310:	e9 ff fe ff ff       	jmp    802214 <__umoddi3+0x74>
