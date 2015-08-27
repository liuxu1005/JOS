
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
  80003c:	68 40 28 80 00       	push   $0x802840
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 5c 20 00 00       	call   8020ad <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 28 80 00       	push   $0x80288e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 28 80 00       	push   $0x802897
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 a4 0f 00 00       	call   801013 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 5b 2d 80 00       	push   $0x802d5b
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 28 80 00       	push   $0x802897
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
  800091:	e8 44 13 00 00       	call   8013da <close>
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
  8000be:	68 ac 28 80 00       	push   $0x8028ac
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 54 13 00 00       	call   80142c <dup>
			sys_yield();
  8000d8:	e8 a3 0b 00 00       	call   800c80 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 f1 12 00 00       	call   8013da <close>
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
  80011d:	e8 de 20 00 00       	call   802200 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b0 28 80 00       	push   $0x8028b0
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
  80015c:	68 cc 28 80 00       	push   $0x8028cc
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 8f 20 00 00       	call   802200 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 28 80 00       	push   $0x802864
  800180:	6a 40                	push   $0x40
  800182:	68 97 28 80 00       	push   $0x802897
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 10 11 00 00       	call   8012ab <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 e2 28 80 00       	push   $0x8028e2
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 28 80 00       	push   $0x802897
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 86 10 00 00       	call   801245 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 fa 28 80 00 	movl   $0x8028fa,(%esp)
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
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800222:	e8 e0 11 00 00       	call   801407 <close_all>
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
  800254:	68 18 29 80 00       	push   $0x802918
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 99 2d 80 00 	movl   $0x802d99,(%esp)
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
  800372:	e8 09 22 00 00       	call   802580 <__udivdi3>
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
  8003b0:	e8 fb 22 00 00       	call   8026b0 <__umoddi3>
  8003b5:	83 c4 14             	add    $0x14,%esp
  8003b8:	0f be 80 3b 29 80 00 	movsbl 0x80293b(%eax),%eax
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
  8004b4:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
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
  800578:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 18                	jne    80059b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800583:	50                   	push   %eax
  800584:	68 53 29 80 00       	push   $0x802953
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
  80059c:	68 71 2e 80 00       	push   $0x802e71
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
  8005c9:	ba 4c 29 80 00       	mov    $0x80294c,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800c48:	68 5f 2c 80 00       	push   $0x802c5f
  800c4d:	6a 22                	push   $0x22
  800c4f:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
	// return value.
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
	// return value.
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
  800cc9:	68 5f 2c 80 00       	push   $0x802c5f
  800cce:	6a 22                	push   $0x22
  800cd0:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
  800d0b:	68 5f 2c 80 00       	push   $0x802c5f
  800d10:	6a 22                	push   $0x22
  800d12:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
  800d4d:	68 5f 2c 80 00       	push   $0x802c5f
  800d52:	6a 22                	push   $0x22
  800d54:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
  800d8f:	68 5f 2c 80 00       	push   $0x802c5f
  800d94:	6a 22                	push   $0x22
  800d96:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
  800dd1:	68 5f 2c 80 00       	push   $0x802c5f
  800dd6:	6a 22                	push   $0x22
  800dd8:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
  800e13:	68 5f 2c 80 00       	push   $0x802c5f
  800e18:	6a 22                	push   $0x22
  800e1a:	68 7c 2c 80 00       	push   $0x802c7c
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
	// return value.
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
	// return value.
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
  800e77:	68 5f 2c 80 00       	push   $0x802c5f
  800e7c:	6a 22                	push   $0x22
  800e7e:	68 7c 2c 80 00       	push   $0x802c7c
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

00800e90 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e96:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea0:	89 d1                	mov    %edx,%ecx
  800ea2:	89 d3                	mov    %edx,%ebx
  800ea4:	89 d7                	mov    %edx,%edi
  800ea6:	89 d6                	mov    %edx,%esi
  800ea8:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_transmit>:

int
sys_transmit(void *addr)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800eb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	89 cb                	mov    %ecx,%ebx
  800ec7:	89 cf                	mov    %ecx,%edi
  800ec9:	89 ce                	mov    %ecx,%esi
  800ecb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7e 17                	jle    800ee8 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	50                   	push   %eax
  800ed5:	6a 0f                	push   $0xf
  800ed7:	68 5f 2c 80 00       	push   $0x802c5f
  800edc:	6a 22                	push   $0x22
  800ede:	68 7c 2c 80 00       	push   $0x802c7c
  800ee3:	e8 4e f3 ff ff       	call   800236 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_recv>:

int
sys_recv(void *addr)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ef9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efe:	b8 10 00 00 00       	mov    $0x10,%eax
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 cb                	mov    %ecx,%ebx
  800f08:	89 cf                	mov    %ecx,%edi
  800f0a:	89 ce                	mov    %ecx,%esi
  800f0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 17                	jle    800f29 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	50                   	push   %eax
  800f16:	6a 10                	push   $0x10
  800f18:	68 5f 2c 80 00       	push   $0x802c5f
  800f1d:	6a 22                	push   $0x22
  800f1f:	68 7c 2c 80 00       	push   $0x802c7c
  800f24:	e8 0d f3 ff ff       	call   800236 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	53                   	push   %ebx
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f3b:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f3d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f41:	74 2e                	je     800f71 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	c1 ea 16             	shr    $0x16,%edx
  800f48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4f:	f6 c2 01             	test   $0x1,%dl
  800f52:	74 1d                	je     800f71 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f54:	89 c2                	mov    %eax,%edx
  800f56:	c1 ea 0c             	shr    $0xc,%edx
  800f59:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f60:	f6 c1 01             	test   $0x1,%cl
  800f63:	74 0c                	je     800f71 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f6c:	f6 c6 08             	test   $0x8,%dh
  800f6f:	75 14                	jne    800f85 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	68 8c 2c 80 00       	push   $0x802c8c
  800f79:	6a 21                	push   $0x21
  800f7b:	68 1f 2d 80 00       	push   $0x802d1f
  800f80:	e8 b1 f2 ff ff       	call   800236 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800f85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f8a:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800f8c:	83 ec 04             	sub    $0x4,%esp
  800f8f:	6a 07                	push   $0x7
  800f91:	68 00 f0 7f 00       	push   $0x7ff000
  800f96:	6a 00                	push   $0x0
  800f98:	e8 02 fd ff ff       	call   800c9f <sys_page_alloc>
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	79 14                	jns    800fb8 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	68 2a 2d 80 00       	push   $0x802d2a
  800fac:	6a 2b                	push   $0x2b
  800fae:	68 1f 2d 80 00       	push   $0x802d1f
  800fb3:	e8 7e f2 ff ff       	call   800236 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	68 00 10 00 00       	push   $0x1000
  800fc0:	53                   	push   %ebx
  800fc1:	68 00 f0 7f 00       	push   $0x7ff000
  800fc6:	e8 5d fa ff ff       	call   800a28 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800fcb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fd2:	53                   	push   %ebx
  800fd3:	6a 00                	push   $0x0
  800fd5:	68 00 f0 7f 00       	push   $0x7ff000
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 01 fd ff ff       	call   800ce2 <sys_page_map>
  800fe1:	83 c4 20             	add    $0x20,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	79 14                	jns    800ffc <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800fe8:	83 ec 04             	sub    $0x4,%esp
  800feb:	68 40 2d 80 00       	push   $0x802d40
  800ff0:	6a 2e                	push   $0x2e
  800ff2:	68 1f 2d 80 00       	push   $0x802d1f
  800ff7:	e8 3a f2 ff ff       	call   800236 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	68 00 f0 7f 00       	push   $0x7ff000
  801004:	6a 00                	push   $0x0
  801006:	e8 19 fd ff ff       	call   800d24 <sys_page_unmap>
  80100b:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  80100e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801011:	c9                   	leave  
  801012:	c3                   	ret    

00801013 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  80101c:	68 31 0f 80 00       	push   $0x800f31
  801021:	e8 92 13 00 00       	call   8023b8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801026:	b8 07 00 00 00       	mov    $0x7,%eax
  80102b:	cd 30                	int    $0x30
  80102d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	79 12                	jns    801049 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801037:	50                   	push   %eax
  801038:	68 54 2d 80 00       	push   $0x802d54
  80103d:	6a 6d                	push   $0x6d
  80103f:	68 1f 2d 80 00       	push   $0x802d1f
  801044:	e8 ed f1 ff ff       	call   800236 <_panic>
  801049:	89 c7                	mov    %eax,%edi
  80104b:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  801050:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801054:	75 21                	jne    801077 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801056:	e8 06 fc ff ff       	call   800c61 <sys_getenvid>
  80105b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801060:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801068:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80106d:	b8 00 00 00 00       	mov    $0x0,%eax
  801072:	e9 9c 01 00 00       	jmp    801213 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801077:	89 d8                	mov    %ebx,%eax
  801079:	c1 e8 16             	shr    $0x16,%eax
  80107c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	0f 84 f3 00 00 00    	je     80117e <fork+0x16b>
  80108b:	89 d8                	mov    %ebx,%eax
  80108d:	c1 e8 0c             	shr    $0xc,%eax
  801090:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801097:	f6 c2 01             	test   $0x1,%dl
  80109a:	0f 84 de 00 00 00    	je     80117e <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  8010a0:	89 c6                	mov    %eax,%esi
  8010a2:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  8010a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ac:	f6 c6 04             	test   $0x4,%dh
  8010af:	74 37                	je     8010e8 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  8010b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c0:	50                   	push   %eax
  8010c1:	56                   	push   %esi
  8010c2:	57                   	push   %edi
  8010c3:	56                   	push   %esi
  8010c4:	6a 00                	push   $0x0
  8010c6:	e8 17 fc ff ff       	call   800ce2 <sys_page_map>
  8010cb:	83 c4 20             	add    $0x20,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	0f 89 a8 00 00 00    	jns    80117e <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  8010d6:	50                   	push   %eax
  8010d7:	68 b0 2c 80 00       	push   $0x802cb0
  8010dc:	6a 49                	push   $0x49
  8010de:	68 1f 2d 80 00       	push   $0x802d1f
  8010e3:	e8 4e f1 ff ff       	call   800236 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8010e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ef:	f6 c6 08             	test   $0x8,%dh
  8010f2:	75 0b                	jne    8010ff <fork+0xec>
  8010f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fb:	a8 02                	test   $0x2,%al
  8010fd:	74 57                	je     801156 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010ff:	83 ec 0c             	sub    $0xc,%esp
  801102:	68 05 08 00 00       	push   $0x805
  801107:	56                   	push   %esi
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	6a 00                	push   $0x0
  80110c:	e8 d1 fb ff ff       	call   800ce2 <sys_page_map>
  801111:	83 c4 20             	add    $0x20,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	79 12                	jns    80112a <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  801118:	50                   	push   %eax
  801119:	68 b0 2c 80 00       	push   $0x802cb0
  80111e:	6a 4c                	push   $0x4c
  801120:	68 1f 2d 80 00       	push   $0x802d1f
  801125:	e8 0c f1 ff ff       	call   800236 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	68 05 08 00 00       	push   $0x805
  801132:	56                   	push   %esi
  801133:	6a 00                	push   $0x0
  801135:	56                   	push   %esi
  801136:	6a 00                	push   $0x0
  801138:	e8 a5 fb ff ff       	call   800ce2 <sys_page_map>
  80113d:	83 c4 20             	add    $0x20,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	79 3a                	jns    80117e <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801144:	50                   	push   %eax
  801145:	68 d4 2c 80 00       	push   $0x802cd4
  80114a:	6a 4e                	push   $0x4e
  80114c:	68 1f 2d 80 00       	push   $0x802d1f
  801151:	e8 e0 f0 ff ff       	call   800236 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	6a 05                	push   $0x5
  80115b:	56                   	push   %esi
  80115c:	57                   	push   %edi
  80115d:	56                   	push   %esi
  80115e:	6a 00                	push   $0x0
  801160:	e8 7d fb ff ff       	call   800ce2 <sys_page_map>
  801165:	83 c4 20             	add    $0x20,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	79 12                	jns    80117e <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80116c:	50                   	push   %eax
  80116d:	68 fc 2c 80 00       	push   $0x802cfc
  801172:	6a 50                	push   $0x50
  801174:	68 1f 2d 80 00       	push   $0x802d1f
  801179:	e8 b8 f0 ff ff       	call   800236 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80117e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801184:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80118a:	0f 85 e7 fe ff ff    	jne    801077 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	6a 07                	push   $0x7
  801195:	68 00 f0 bf ee       	push   $0xeebff000
  80119a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119d:	e8 fd fa ff ff       	call   800c9f <sys_page_alloc>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	79 14                	jns    8011bd <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	68 64 2d 80 00       	push   $0x802d64
  8011b1:	6a 76                	push   $0x76
  8011b3:	68 1f 2d 80 00       	push   $0x802d1f
  8011b8:	e8 79 f0 ff ff       	call   800236 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	68 27 24 80 00       	push   $0x802427
  8011c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c8:	e8 1d fc ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	79 14                	jns    8011e8 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8011d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d7:	68 7e 2d 80 00       	push   $0x802d7e
  8011dc:	6a 79                	push   $0x79
  8011de:	68 1f 2d 80 00       	push   $0x802d1f
  8011e3:	e8 4e f0 ff ff       	call   800236 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	6a 02                	push   $0x2
  8011ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f0:	e8 71 fb ff ff       	call   800d66 <sys_env_set_status>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	79 14                	jns    801210 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8011fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ff:	68 9b 2d 80 00       	push   $0x802d9b
  801204:	6a 7b                	push   $0x7b
  801206:	68 1f 2d 80 00       	push   $0x802d1f
  80120b:	e8 26 f0 ff ff       	call   800236 <_panic>
        return forkid;
  801210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sfork>:

// Challenge!
int
sfork(void)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801221:	68 b2 2d 80 00       	push   $0x802db2
  801226:	68 83 00 00 00       	push   $0x83
  80122b:	68 1f 2d 80 00       	push   $0x802d1f
  801230:	e8 01 f0 ff ff       	call   800236 <_panic>

00801235 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	05 00 00 00 30       	add    $0x30000000,%eax
  801240:	c1 e8 0c             	shr    $0xc,%eax
}
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801248:	8b 45 08             	mov    0x8(%ebp),%eax
  80124b:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801250:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801255:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801262:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 16             	shr    $0x16,%edx
  80126c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801273:	f6 c2 01             	test   $0x1,%dl
  801276:	74 11                	je     801289 <fd_alloc+0x2d>
  801278:	89 c2                	mov    %eax,%edx
  80127a:	c1 ea 0c             	shr    $0xc,%edx
  80127d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801284:	f6 c2 01             	test   $0x1,%dl
  801287:	75 09                	jne    801292 <fd_alloc+0x36>
			*fd_store = fd;
  801289:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	eb 17                	jmp    8012a9 <fd_alloc+0x4d>
  801292:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801297:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129c:	75 c9                	jne    801267 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80129e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012a4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b1:	83 f8 1f             	cmp    $0x1f,%eax
  8012b4:	77 36                	ja     8012ec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b6:	c1 e0 0c             	shl    $0xc,%eax
  8012b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	c1 ea 16             	shr    $0x16,%edx
  8012c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	74 24                	je     8012f3 <fd_lookup+0x48>
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	c1 ea 0c             	shr    $0xc,%edx
  8012d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012db:	f6 c2 01             	test   $0x1,%dl
  8012de:	74 1a                	je     8012fa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	eb 13                	jmp    8012ff <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f1:	eb 0c                	jmp    8012ff <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb 05                	jmp    8012ff <fd_lookup+0x54>
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80130a:	ba 00 00 00 00       	mov    $0x0,%edx
  80130f:	eb 13                	jmp    801324 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801311:	39 08                	cmp    %ecx,(%eax)
  801313:	75 0c                	jne    801321 <dev_lookup+0x20>
			*dev = devtab[i];
  801315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801318:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
  80131f:	eb 36                	jmp    801357 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801321:	83 c2 01             	add    $0x1,%edx
  801324:	8b 04 95 44 2e 80 00 	mov    0x802e44(,%edx,4),%eax
  80132b:	85 c0                	test   %eax,%eax
  80132d:	75 e2                	jne    801311 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80132f:	a1 08 40 80 00       	mov    0x804008,%eax
  801334:	8b 40 48             	mov    0x48(%eax),%eax
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	51                   	push   %ecx
  80133b:	50                   	push   %eax
  80133c:	68 c8 2d 80 00       	push   $0x802dc8
  801341:	e8 c9 ef ff ff       	call   80030f <cprintf>
	*dev = 0;
  801346:	8b 45 0c             	mov    0xc(%ebp),%eax
  801349:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	83 ec 10             	sub    $0x10,%esp
  801361:	8b 75 08             	mov    0x8(%ebp),%esi
  801364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801371:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801374:	50                   	push   %eax
  801375:	e8 31 ff ff ff       	call   8012ab <fd_lookup>
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 05                	js     801386 <fd_close+0x2d>
	    || fd != fd2)
  801381:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801384:	74 0c                	je     801392 <fd_close+0x39>
		return (must_exist ? r : 0);
  801386:	84 db                	test   %bl,%bl
  801388:	ba 00 00 00 00       	mov    $0x0,%edx
  80138d:	0f 44 c2             	cmove  %edx,%eax
  801390:	eb 41                	jmp    8013d3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 36                	pushl  (%esi)
  80139b:	e8 61 ff ff ff       	call   801301 <dev_lookup>
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 1a                	js     8013c3 <fd_close+0x6a>
		if (dev->dev_close)
  8013a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ac:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013af:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	74 0b                	je     8013c3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	56                   	push   %esi
  8013bc:	ff d0                	call   *%eax
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	56                   	push   %esi
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 56 f9 ff ff       	call   800d24 <sys_page_unmap>
	return r;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	89 d8                	mov    %ebx,%eax
}
  8013d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	ff 75 08             	pushl  0x8(%ebp)
  8013e7:	e8 bf fe ff ff       	call   8012ab <fd_lookup>
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	85 d2                	test   %edx,%edx
  8013f3:	78 10                	js     801405 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	6a 01                	push   $0x1
  8013fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fd:	e8 57 ff ff ff       	call   801359 <fd_close>
  801402:	83 c4 10             	add    $0x10,%esp
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <close_all>:

void
close_all(void)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	53                   	push   %ebx
  801417:	e8 be ff ff ff       	call   8013da <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80141c:	83 c3 01             	add    $0x1,%ebx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	83 fb 20             	cmp    $0x20,%ebx
  801425:	75 ec                	jne    801413 <close_all+0xc>
		close(i);
}
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	57                   	push   %edi
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 2c             	sub    $0x2c,%esp
  801435:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801438:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	e8 67 fe ff ff       	call   8012ab <fd_lookup>
  801444:	89 c2                	mov    %eax,%edx
  801446:	83 c4 08             	add    $0x8,%esp
  801449:	85 d2                	test   %edx,%edx
  80144b:	0f 88 c1 00 00 00    	js     801512 <dup+0xe6>
		return r;
	close(newfdnum);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	56                   	push   %esi
  801455:	e8 80 ff ff ff       	call   8013da <close>

	newfd = INDEX2FD(newfdnum);
  80145a:	89 f3                	mov    %esi,%ebx
  80145c:	c1 e3 0c             	shl    $0xc,%ebx
  80145f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801465:	83 c4 04             	add    $0x4,%esp
  801468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80146b:	e8 d5 fd ff ff       	call   801245 <fd2data>
  801470:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801472:	89 1c 24             	mov    %ebx,(%esp)
  801475:	e8 cb fd ff ff       	call   801245 <fd2data>
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801480:	89 f8                	mov    %edi,%eax
  801482:	c1 e8 16             	shr    $0x16,%eax
  801485:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148c:	a8 01                	test   $0x1,%al
  80148e:	74 37                	je     8014c7 <dup+0x9b>
  801490:	89 f8                	mov    %edi,%eax
  801492:	c1 e8 0c             	shr    $0xc,%eax
  801495:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149c:	f6 c2 01             	test   $0x1,%dl
  80149f:	74 26                	je     8014c7 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b0:	50                   	push   %eax
  8014b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b4:	6a 00                	push   $0x0
  8014b6:	57                   	push   %edi
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 24 f8 ff ff       	call   800ce2 <sys_page_map>
  8014be:	89 c7                	mov    %eax,%edi
  8014c0:	83 c4 20             	add    $0x20,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 2e                	js     8014f5 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ca:	89 d0                	mov    %edx,%eax
  8014cc:	c1 e8 0c             	shr    $0xc,%eax
  8014cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014de:	50                   	push   %eax
  8014df:	53                   	push   %ebx
  8014e0:	6a 00                	push   $0x0
  8014e2:	52                   	push   %edx
  8014e3:	6a 00                	push   $0x0
  8014e5:	e8 f8 f7 ff ff       	call   800ce2 <sys_page_map>
  8014ea:	89 c7                	mov    %eax,%edi
  8014ec:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ef:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f1:	85 ff                	test   %edi,%edi
  8014f3:	79 1d                	jns    801512 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	53                   	push   %ebx
  8014f9:	6a 00                	push   $0x0
  8014fb:	e8 24 f8 ff ff       	call   800d24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	ff 75 d4             	pushl  -0x2c(%ebp)
  801506:	6a 00                	push   $0x0
  801508:	e8 17 f8 ff ff       	call   800d24 <sys_page_unmap>
	return r;
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	89 f8                	mov    %edi,%eax
}
  801512:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5f                   	pop    %edi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	53                   	push   %ebx
  80151e:	83 ec 14             	sub    $0x14,%esp
  801521:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801524:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	53                   	push   %ebx
  801529:	e8 7d fd ff ff       	call   8012ab <fd_lookup>
  80152e:	83 c4 08             	add    $0x8,%esp
  801531:	89 c2                	mov    %eax,%edx
  801533:	85 c0                	test   %eax,%eax
  801535:	78 6d                	js     8015a4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801541:	ff 30                	pushl  (%eax)
  801543:	e8 b9 fd ff ff       	call   801301 <dev_lookup>
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 4c                	js     80159b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801552:	8b 42 08             	mov    0x8(%edx),%eax
  801555:	83 e0 03             	and    $0x3,%eax
  801558:	83 f8 01             	cmp    $0x1,%eax
  80155b:	75 21                	jne    80157e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155d:	a1 08 40 80 00       	mov    0x804008,%eax
  801562:	8b 40 48             	mov    0x48(%eax),%eax
  801565:	83 ec 04             	sub    $0x4,%esp
  801568:	53                   	push   %ebx
  801569:	50                   	push   %eax
  80156a:	68 09 2e 80 00       	push   $0x802e09
  80156f:	e8 9b ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157c:	eb 26                	jmp    8015a4 <read+0x8a>
	}
	if (!dev->dev_read)
  80157e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801581:	8b 40 08             	mov    0x8(%eax),%eax
  801584:	85 c0                	test   %eax,%eax
  801586:	74 17                	je     80159f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	ff 75 10             	pushl  0x10(%ebp)
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	52                   	push   %edx
  801592:	ff d0                	call   *%eax
  801594:	89 c2                	mov    %eax,%edx
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	eb 09                	jmp    8015a4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159b:	89 c2                	mov    %eax,%edx
  80159d:	eb 05                	jmp    8015a4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015a4:	89 d0                	mov    %edx,%eax
  8015a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bf:	eb 21                	jmp    8015e2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c1:	83 ec 04             	sub    $0x4,%esp
  8015c4:	89 f0                	mov    %esi,%eax
  8015c6:	29 d8                	sub    %ebx,%eax
  8015c8:	50                   	push   %eax
  8015c9:	89 d8                	mov    %ebx,%eax
  8015cb:	03 45 0c             	add    0xc(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	57                   	push   %edi
  8015d0:	e8 45 ff ff ff       	call   80151a <read>
		if (m < 0)
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 0c                	js     8015e8 <readn+0x3d>
			return m;
		if (m == 0)
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	74 06                	je     8015e6 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e0:	01 c3                	add    %eax,%ebx
  8015e2:	39 f3                	cmp    %esi,%ebx
  8015e4:	72 db                	jb     8015c1 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015e6:	89 d8                	mov    %ebx,%eax
}
  8015e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	53                   	push   %ebx
  8015ff:	e8 a7 fc ff ff       	call   8012ab <fd_lookup>
  801604:	83 c4 08             	add    $0x8,%esp
  801607:	89 c2                	mov    %eax,%edx
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 68                	js     801675 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801617:	ff 30                	pushl  (%eax)
  801619:	e8 e3 fc ff ff       	call   801301 <dev_lookup>
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 47                	js     80166c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801628:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162c:	75 21                	jne    80164f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162e:	a1 08 40 80 00       	mov    0x804008,%eax
  801633:	8b 40 48             	mov    0x48(%eax),%eax
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	53                   	push   %ebx
  80163a:	50                   	push   %eax
  80163b:	68 25 2e 80 00       	push   $0x802e25
  801640:	e8 ca ec ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164d:	eb 26                	jmp    801675 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801652:	8b 52 0c             	mov    0xc(%edx),%edx
  801655:	85 d2                	test   %edx,%edx
  801657:	74 17                	je     801670 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	ff 75 10             	pushl  0x10(%ebp)
  80165f:	ff 75 0c             	pushl  0xc(%ebp)
  801662:	50                   	push   %eax
  801663:	ff d2                	call   *%edx
  801665:	89 c2                	mov    %eax,%edx
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	eb 09                	jmp    801675 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	eb 05                	jmp    801675 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801670:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801675:	89 d0                	mov    %edx,%eax
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <seek>:

int
seek(int fdnum, off_t offset)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801682:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	ff 75 08             	pushl  0x8(%ebp)
  801689:	e8 1d fc ff ff       	call   8012ab <fd_lookup>
  80168e:	83 c4 08             	add    $0x8,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	78 0e                	js     8016a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801695:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801698:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 14             	sub    $0x14,%esp
  8016ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b2:	50                   	push   %eax
  8016b3:	53                   	push   %ebx
  8016b4:	e8 f2 fb ff ff       	call   8012ab <fd_lookup>
  8016b9:	83 c4 08             	add    $0x8,%esp
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 65                	js     801727 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	ff 30                	pushl  (%eax)
  8016ce:	e8 2e fc ff ff       	call   801301 <dev_lookup>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 44                	js     80171e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e1:	75 21                	jne    801704 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e8:	8b 40 48             	mov    0x48(%eax),%eax
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	50                   	push   %eax
  8016f0:	68 e8 2d 80 00       	push   $0x802de8
  8016f5:	e8 15 ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801702:	eb 23                	jmp    801727 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801704:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801707:	8b 52 18             	mov    0x18(%edx),%edx
  80170a:	85 d2                	test   %edx,%edx
  80170c:	74 14                	je     801722 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	50                   	push   %eax
  801715:	ff d2                	call   *%edx
  801717:	89 c2                	mov    %eax,%edx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	eb 09                	jmp    801727 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171e:	89 c2                	mov    %eax,%edx
  801720:	eb 05                	jmp    801727 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801722:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801727:	89 d0                	mov    %edx,%eax
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 14             	sub    $0x14,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	e8 67 fb ff ff       	call   8012ab <fd_lookup>
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	89 c2                	mov    %eax,%edx
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 58                	js     8017a5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174d:	83 ec 08             	sub    $0x8,%esp
  801750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801757:	ff 30                	pushl  (%eax)
  801759:	e8 a3 fb ff ff       	call   801301 <dev_lookup>
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	78 37                	js     80179c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801768:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176c:	74 32                	je     8017a0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801771:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801778:	00 00 00 
	stat->st_isdir = 0;
  80177b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801782:	00 00 00 
	stat->st_dev = dev;
  801785:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	53                   	push   %ebx
  80178f:	ff 75 f0             	pushl  -0x10(%ebp)
  801792:	ff 50 14             	call   *0x14(%eax)
  801795:	89 c2                	mov    %eax,%edx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	eb 09                	jmp    8017a5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	eb 05                	jmp    8017a5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a5:	89 d0                	mov    %edx,%eax
  8017a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	6a 00                	push   $0x0
  8017b6:	ff 75 08             	pushl  0x8(%ebp)
  8017b9:	e8 09 02 00 00       	call   8019c7 <open>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 db                	test   %ebx,%ebx
  8017c5:	78 1b                	js     8017e2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	53                   	push   %ebx
  8017ce:	e8 5b ff ff ff       	call   80172e <fstat>
  8017d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d5:	89 1c 24             	mov    %ebx,(%esp)
  8017d8:	e8 fd fb ff ff       	call   8013da <close>
	return r;
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	89 f0                	mov    %esi,%eax
}
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	89 c6                	mov    %eax,%esi
  8017f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f9:	75 12                	jne    80180d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	6a 01                	push   $0x1
  801800:	e8 03 0d 00 00       	call   802508 <ipc_find_env>
  801805:	a3 00 40 80 00       	mov    %eax,0x804000
  80180a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180d:	6a 07                	push   $0x7
  80180f:	68 00 50 80 00       	push   $0x805000
  801814:	56                   	push   %esi
  801815:	ff 35 00 40 80 00    	pushl  0x804000
  80181b:	e8 94 0c 00 00       	call   8024b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801820:	83 c4 0c             	add    $0xc,%esp
  801823:	6a 00                	push   $0x0
  801825:	53                   	push   %ebx
  801826:	6a 00                	push   $0x0
  801828:	e8 1e 0c 00 00       	call   80244b <ipc_recv>
}
  80182d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801830:	5b                   	pop    %ebx
  801831:	5e                   	pop    %esi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 02 00 00 00       	mov    $0x2,%eax
  801857:	e8 8d ff ff ff       	call   8017e9 <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	8b 40 0c             	mov    0xc(%eax),%eax
  80186a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 06 00 00 00       	mov    $0x6,%eax
  801879:	e8 6b ff ff ff       	call   8017e9 <fsipc>
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	8b 40 0c             	mov    0xc(%eax),%eax
  801890:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 05 00 00 00       	mov    $0x5,%eax
  80189f:	e8 45 ff ff ff       	call   8017e9 <fsipc>
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	85 d2                	test   %edx,%edx
  8018a8:	78 2c                	js     8018d6 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	53                   	push   %ebx
  8018b3:	e8 de ef ff ff       	call   800896 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	57                   	push   %edi
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8018f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018f5:	eb 3d                	jmp    801934 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8018f7:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8018fd:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801902:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	57                   	push   %edi
  801909:	53                   	push   %ebx
  80190a:	68 08 50 80 00       	push   $0x805008
  80190f:	e8 14 f1 ff ff       	call   800a28 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801914:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80191a:	ba 00 00 00 00       	mov    $0x0,%edx
  80191f:	b8 04 00 00 00       	mov    $0x4,%eax
  801924:	e8 c0 fe ff ff       	call   8017e9 <fsipc>
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 0d                	js     80193d <devfile_write+0x62>
		        return r;
                n -= tmp;
  801930:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801932:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801934:	85 f6                	test   %esi,%esi
  801936:	75 bf                	jne    8018f7 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80193d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801940:	5b                   	pop    %ebx
  801941:	5e                   	pop    %esi
  801942:	5f                   	pop    %edi
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	8b 40 0c             	mov    0xc(%eax),%eax
  801953:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801958:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80195e:	ba 00 00 00 00       	mov    $0x0,%edx
  801963:	b8 03 00 00 00       	mov    $0x3,%eax
  801968:	e8 7c fe ff ff       	call   8017e9 <fsipc>
  80196d:	89 c3                	mov    %eax,%ebx
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 4b                	js     8019be <devfile_read+0x79>
		return r;
	assert(r <= n);
  801973:	39 c6                	cmp    %eax,%esi
  801975:	73 16                	jae    80198d <devfile_read+0x48>
  801977:	68 58 2e 80 00       	push   $0x802e58
  80197c:	68 5f 2e 80 00       	push   $0x802e5f
  801981:	6a 7c                	push   $0x7c
  801983:	68 74 2e 80 00       	push   $0x802e74
  801988:	e8 a9 e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  80198d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801992:	7e 16                	jle    8019aa <devfile_read+0x65>
  801994:	68 7f 2e 80 00       	push   $0x802e7f
  801999:	68 5f 2e 80 00       	push   $0x802e5f
  80199e:	6a 7d                	push   $0x7d
  8019a0:	68 74 2e 80 00       	push   $0x802e74
  8019a5:	e8 8c e8 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019aa:	83 ec 04             	sub    $0x4,%esp
  8019ad:	50                   	push   %eax
  8019ae:	68 00 50 80 00       	push   $0x805000
  8019b3:	ff 75 0c             	pushl  0xc(%ebp)
  8019b6:	e8 6d f0 ff ff       	call   800a28 <memmove>
	return r;
  8019bb:	83 c4 10             	add    $0x10,%esp
}
  8019be:	89 d8                	mov    %ebx,%eax
  8019c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	5d                   	pop    %ebp
  8019c6:	c3                   	ret    

008019c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 20             	sub    $0x20,%esp
  8019ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019d1:	53                   	push   %ebx
  8019d2:	e8 86 ee ff ff       	call   80085d <strlen>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019df:	7f 67                	jg     801a48 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 6f f8 ff ff       	call   80125c <fd_alloc>
  8019ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 57                	js     801a4d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	53                   	push   %ebx
  8019fa:	68 00 50 80 00       	push   $0x805000
  8019ff:	e8 92 ee ff ff       	call   800896 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a07:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a14:	e8 d0 fd ff ff       	call   8017e9 <fsipc>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	79 14                	jns    801a36 <open+0x6f>
		fd_close(fd, 0);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	6a 00                	push   $0x0
  801a27:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2a:	e8 2a f9 ff ff       	call   801359 <fd_close>
		return r;
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	89 da                	mov    %ebx,%edx
  801a34:	eb 17                	jmp    801a4d <open+0x86>
	}

	return fd2num(fd);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3c:	e8 f4 f7 ff ff       	call   801235 <fd2num>
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	eb 05                	jmp    801a4d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a48:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a4d:	89 d0                	mov    %edx,%eax
  801a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a64:	e8 80 fd ff ff       	call   8017e9 <fsipc>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a71:	68 8b 2e 80 00       	push   $0x802e8b
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	e8 18 ee ff ff       	call   800896 <strcpy>
	return 0;
}
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	53                   	push   %ebx
  801a89:	83 ec 10             	sub    $0x10,%esp
  801a8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a8f:	53                   	push   %ebx
  801a90:	e8 ab 0a 00 00       	call   802540 <pageref>
  801a95:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a98:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a9d:	83 f8 01             	cmp    $0x1,%eax
  801aa0:	75 10                	jne    801ab2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	ff 73 0c             	pushl  0xc(%ebx)
  801aa8:	e8 ca 02 00 00       	call   801d77 <nsipc_close>
  801aad:	89 c2                	mov    %eax,%edx
  801aaf:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ab2:	89 d0                	mov    %edx,%eax
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801abf:	6a 00                	push   $0x0
  801ac1:	ff 75 10             	pushl  0x10(%ebp)
  801ac4:	ff 75 0c             	pushl  0xc(%ebp)
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	ff 70 0c             	pushl  0xc(%eax)
  801acd:	e8 82 03 00 00       	call   801e54 <nsipc_send>
}
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    

00801ad4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ada:	6a 00                	push   $0x0
  801adc:	ff 75 10             	pushl  0x10(%ebp)
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	ff 70 0c             	pushl  0xc(%eax)
  801ae8:	e8 fb 02 00 00       	call   801de8 <nsipc_recv>
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801af5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801af8:	52                   	push   %edx
  801af9:	50                   	push   %eax
  801afa:	e8 ac f7 ff ff       	call   8012ab <fd_lookup>
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 17                	js     801b1d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b0f:	39 08                	cmp    %ecx,(%eax)
  801b11:	75 05                	jne    801b18 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b13:	8b 40 0c             	mov    0xc(%eax),%eax
  801b16:	eb 05                	jmp    801b1d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b18:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	56                   	push   %esi
  801b23:	53                   	push   %ebx
  801b24:	83 ec 1c             	sub    $0x1c,%esp
  801b27:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2c:	50                   	push   %eax
  801b2d:	e8 2a f7 ff ff       	call   80125c <fd_alloc>
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 1b                	js     801b56 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	68 07 04 00 00       	push   $0x407
  801b43:	ff 75 f4             	pushl  -0xc(%ebp)
  801b46:	6a 00                	push   $0x0
  801b48:	e8 52 f1 ff ff       	call   800c9f <sys_page_alloc>
  801b4d:	89 c3                	mov    %eax,%ebx
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	79 10                	jns    801b66 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	56                   	push   %esi
  801b5a:	e8 18 02 00 00       	call   801d77 <nsipc_close>
		return r;
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	89 d8                	mov    %ebx,%eax
  801b64:	eb 24                	jmp    801b8a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b74:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b7b:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	52                   	push   %edx
  801b82:	e8 ae f6 ff ff       	call   801235 <fd2num>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	e8 50 ff ff ff       	call   801aef <fd2sockid>
		return r;
  801b9f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 1f                	js     801bc4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ba5:	83 ec 04             	sub    $0x4,%esp
  801ba8:	ff 75 10             	pushl  0x10(%ebp)
  801bab:	ff 75 0c             	pushl  0xc(%ebp)
  801bae:	50                   	push   %eax
  801baf:	e8 1c 01 00 00       	call   801cd0 <nsipc_accept>
  801bb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 07                	js     801bc4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bbd:	e8 5d ff ff ff       	call   801b1f <alloc_sockfd>
  801bc2:	89 c1                	mov    %eax,%ecx
}
  801bc4:	89 c8                	mov    %ecx,%eax
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	e8 19 ff ff ff       	call   801aef <fd2sockid>
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	85 d2                	test   %edx,%edx
  801bda:	78 12                	js     801bee <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	ff 75 10             	pushl  0x10(%ebp)
  801be2:	ff 75 0c             	pushl  0xc(%ebp)
  801be5:	52                   	push   %edx
  801be6:	e8 35 01 00 00       	call   801d20 <nsipc_bind>
  801beb:	83 c4 10             	add    $0x10,%esp
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <shutdown>:

int
shutdown(int s, int how)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	e8 f1 fe ff ff       	call   801aef <fd2sockid>
  801bfe:	89 c2                	mov    %eax,%edx
  801c00:	85 d2                	test   %edx,%edx
  801c02:	78 0f                	js     801c13 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c04:	83 ec 08             	sub    $0x8,%esp
  801c07:	ff 75 0c             	pushl  0xc(%ebp)
  801c0a:	52                   	push   %edx
  801c0b:	e8 45 01 00 00       	call   801d55 <nsipc_shutdown>
  801c10:	83 c4 10             	add    $0x10,%esp
}
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	e8 cc fe ff ff       	call   801aef <fd2sockid>
  801c23:	89 c2                	mov    %eax,%edx
  801c25:	85 d2                	test   %edx,%edx
  801c27:	78 12                	js     801c3b <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c29:	83 ec 04             	sub    $0x4,%esp
  801c2c:	ff 75 10             	pushl  0x10(%ebp)
  801c2f:	ff 75 0c             	pushl  0xc(%ebp)
  801c32:	52                   	push   %edx
  801c33:	e8 59 01 00 00       	call   801d91 <nsipc_connect>
  801c38:	83 c4 10             	add    $0x10,%esp
}
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    

00801c3d <listen>:

int
listen(int s, int backlog)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	e8 a4 fe ff ff       	call   801aef <fd2sockid>
  801c4b:	89 c2                	mov    %eax,%edx
  801c4d:	85 d2                	test   %edx,%edx
  801c4f:	78 0f                	js     801c60 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c51:	83 ec 08             	sub    $0x8,%esp
  801c54:	ff 75 0c             	pushl  0xc(%ebp)
  801c57:	52                   	push   %edx
  801c58:	e8 69 01 00 00       	call   801dc6 <nsipc_listen>
  801c5d:	83 c4 10             	add    $0x10,%esp
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c68:	ff 75 10             	pushl  0x10(%ebp)
  801c6b:	ff 75 0c             	pushl  0xc(%ebp)
  801c6e:	ff 75 08             	pushl  0x8(%ebp)
  801c71:	e8 3c 02 00 00       	call   801eb2 <nsipc_socket>
  801c76:	89 c2                	mov    %eax,%edx
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 d2                	test   %edx,%edx
  801c7d:	78 05                	js     801c84 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801c7f:	e8 9b fe ff ff       	call   801b1f <alloc_sockfd>
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 04             	sub    $0x4,%esp
  801c8d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c8f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c96:	75 12                	jne    801caa <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c98:	83 ec 0c             	sub    $0xc,%esp
  801c9b:	6a 02                	push   $0x2
  801c9d:	e8 66 08 00 00       	call   802508 <ipc_find_env>
  801ca2:	a3 04 40 80 00       	mov    %eax,0x804004
  801ca7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801caa:	6a 07                	push   $0x7
  801cac:	68 00 60 80 00       	push   $0x806000
  801cb1:	53                   	push   %ebx
  801cb2:	ff 35 04 40 80 00    	pushl  0x804004
  801cb8:	e8 f7 07 00 00       	call   8024b4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cbd:	83 c4 0c             	add    $0xc,%esp
  801cc0:	6a 00                	push   $0x0
  801cc2:	6a 00                	push   $0x0
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 80 07 00 00       	call   80244b <ipc_recv>
}
  801ccb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ce0:	8b 06                	mov    (%esi),%eax
  801ce2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cec:	e8 95 ff ff ff       	call   801c86 <nsipc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 20                	js     801d17 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cf7:	83 ec 04             	sub    $0x4,%esp
  801cfa:	ff 35 10 60 80 00    	pushl  0x806010
  801d00:	68 00 60 80 00       	push   $0x806000
  801d05:	ff 75 0c             	pushl  0xc(%ebp)
  801d08:	e8 1b ed ff ff       	call   800a28 <memmove>
		*addrlen = ret->ret_addrlen;
  801d0d:	a1 10 60 80 00       	mov    0x806010,%eax
  801d12:	89 06                	mov    %eax,(%esi)
  801d14:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d17:	89 d8                	mov    %ebx,%eax
  801d19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1c:	5b                   	pop    %ebx
  801d1d:	5e                   	pop    %esi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d32:	53                   	push   %ebx
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	68 04 60 80 00       	push   $0x806004
  801d3b:	e8 e8 ec ff ff       	call   800a28 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d40:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d46:	b8 02 00 00 00       	mov    $0x2,%eax
  801d4b:	e8 36 ff ff ff       	call   801c86 <nsipc>
}
  801d50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d66:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d6b:	b8 03 00 00 00       	mov    $0x3,%eax
  801d70:	e8 11 ff ff ff       	call   801c86 <nsipc>
}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <nsipc_close>:

int
nsipc_close(int s)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d85:	b8 04 00 00 00       	mov    $0x4,%eax
  801d8a:	e8 f7 fe ff ff       	call   801c86 <nsipc>
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    

00801d91 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	53                   	push   %ebx
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801da3:	53                   	push   %ebx
  801da4:	ff 75 0c             	pushl  0xc(%ebp)
  801da7:	68 04 60 80 00       	push   $0x806004
  801dac:	e8 77 ec ff ff       	call   800a28 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801db1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801db7:	b8 05 00 00 00       	mov    $0x5,%eax
  801dbc:	e8 c5 fe ff ff       	call   801c86 <nsipc>
}
  801dc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ddc:	b8 06 00 00 00       	mov    $0x6,%eax
  801de1:	e8 a0 fe ff ff       	call   801c86 <nsipc>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801df8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dfe:	8b 45 14             	mov    0x14(%ebp),%eax
  801e01:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e06:	b8 07 00 00 00       	mov    $0x7,%eax
  801e0b:	e8 76 fe ff ff       	call   801c86 <nsipc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 35                	js     801e4b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e16:	39 f0                	cmp    %esi,%eax
  801e18:	7f 07                	jg     801e21 <nsipc_recv+0x39>
  801e1a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e1f:	7e 16                	jle    801e37 <nsipc_recv+0x4f>
  801e21:	68 97 2e 80 00       	push   $0x802e97
  801e26:	68 5f 2e 80 00       	push   $0x802e5f
  801e2b:	6a 62                	push   $0x62
  801e2d:	68 ac 2e 80 00       	push   $0x802eac
  801e32:	e8 ff e3 ff ff       	call   800236 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e37:	83 ec 04             	sub    $0x4,%esp
  801e3a:	50                   	push   %eax
  801e3b:	68 00 60 80 00       	push   $0x806000
  801e40:	ff 75 0c             	pushl  0xc(%ebp)
  801e43:	e8 e0 eb ff ff       	call   800a28 <memmove>
  801e48:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e4b:	89 d8                	mov    %ebx,%eax
  801e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	53                   	push   %ebx
  801e58:	83 ec 04             	sub    $0x4,%esp
  801e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e61:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e66:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e6c:	7e 16                	jle    801e84 <nsipc_send+0x30>
  801e6e:	68 b8 2e 80 00       	push   $0x802eb8
  801e73:	68 5f 2e 80 00       	push   $0x802e5f
  801e78:	6a 6d                	push   $0x6d
  801e7a:	68 ac 2e 80 00       	push   $0x802eac
  801e7f:	e8 b2 e3 ff ff       	call   800236 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	53                   	push   %ebx
  801e88:	ff 75 0c             	pushl  0xc(%ebp)
  801e8b:	68 0c 60 80 00       	push   $0x80600c
  801e90:	e8 93 eb ff ff       	call   800a28 <memmove>
	nsipcbuf.send.req_size = size;
  801e95:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea8:	e8 d9 fd ff ff       	call   801c86 <nsipc>
}
  801ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ec8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ed0:	b8 09 00 00 00       	mov    $0x9,%eax
  801ed5:	e8 ac fd ff ff       	call   801c86 <nsipc>
}
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	56                   	push   %esi
  801ee0:	53                   	push   %ebx
  801ee1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ee4:	83 ec 0c             	sub    $0xc,%esp
  801ee7:	ff 75 08             	pushl  0x8(%ebp)
  801eea:	e8 56 f3 ff ff       	call   801245 <fd2data>
  801eef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ef1:	83 c4 08             	add    $0x8,%esp
  801ef4:	68 c4 2e 80 00       	push   $0x802ec4
  801ef9:	53                   	push   %ebx
  801efa:	e8 97 e9 ff ff       	call   800896 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eff:	8b 56 04             	mov    0x4(%esi),%edx
  801f02:	89 d0                	mov    %edx,%eax
  801f04:	2b 06                	sub    (%esi),%eax
  801f06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f13:	00 00 00 
	stat->st_dev = &devpipe;
  801f16:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f1d:	30 80 00 
	return 0;
}
  801f20:	b8 00 00 00 00       	mov    $0x0,%eax
  801f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f36:	53                   	push   %ebx
  801f37:	6a 00                	push   $0x0
  801f39:	e8 e6 ed ff ff       	call   800d24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f3e:	89 1c 24             	mov    %ebx,(%esp)
  801f41:	e8 ff f2 ff ff       	call   801245 <fd2data>
  801f46:	83 c4 08             	add    $0x8,%esp
  801f49:	50                   	push   %eax
  801f4a:	6a 00                	push   $0x0
  801f4c:	e8 d3 ed ff ff       	call   800d24 <sys_page_unmap>
}
  801f51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	57                   	push   %edi
  801f5a:	56                   	push   %esi
  801f5b:	53                   	push   %ebx
  801f5c:	83 ec 1c             	sub    $0x1c,%esp
  801f5f:	89 c6                	mov    %eax,%esi
  801f61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f64:	a1 08 40 80 00       	mov    0x804008,%eax
  801f69:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f6c:	83 ec 0c             	sub    $0xc,%esp
  801f6f:	56                   	push   %esi
  801f70:	e8 cb 05 00 00       	call   802540 <pageref>
  801f75:	89 c7                	mov    %eax,%edi
  801f77:	83 c4 04             	add    $0x4,%esp
  801f7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f7d:	e8 be 05 00 00       	call   802540 <pageref>
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	39 c7                	cmp    %eax,%edi
  801f87:	0f 94 c2             	sete   %dl
  801f8a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801f8d:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801f93:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f96:	39 fb                	cmp    %edi,%ebx
  801f98:	74 19                	je     801fb3 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801f9a:	84 d2                	test   %dl,%dl
  801f9c:	74 c6                	je     801f64 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f9e:	8b 51 58             	mov    0x58(%ecx),%edx
  801fa1:	50                   	push   %eax
  801fa2:	52                   	push   %edx
  801fa3:	53                   	push   %ebx
  801fa4:	68 cb 2e 80 00       	push   $0x802ecb
  801fa9:	e8 61 e3 ff ff       	call   80030f <cprintf>
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	eb b1                	jmp    801f64 <_pipeisclosed+0xe>
	}
}
  801fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	57                   	push   %edi
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 28             	sub    $0x28,%esp
  801fc4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fc7:	56                   	push   %esi
  801fc8:	e8 78 f2 ff ff       	call   801245 <fd2data>
  801fcd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fd7:	eb 4b                	jmp    802024 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fd9:	89 da                	mov    %ebx,%edx
  801fdb:	89 f0                	mov    %esi,%eax
  801fdd:	e8 74 ff ff ff       	call   801f56 <_pipeisclosed>
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	75 48                	jne    80202e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fe6:	e8 95 ec ff ff       	call   800c80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801feb:	8b 43 04             	mov    0x4(%ebx),%eax
  801fee:	8b 0b                	mov    (%ebx),%ecx
  801ff0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ff3:	39 d0                	cmp    %edx,%eax
  801ff5:	73 e2                	jae    801fd9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ffe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802001:	89 c2                	mov    %eax,%edx
  802003:	c1 fa 1f             	sar    $0x1f,%edx
  802006:	89 d1                	mov    %edx,%ecx
  802008:	c1 e9 1b             	shr    $0x1b,%ecx
  80200b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80200e:	83 e2 1f             	and    $0x1f,%edx
  802011:	29 ca                	sub    %ecx,%edx
  802013:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802017:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80201b:	83 c0 01             	add    $0x1,%eax
  80201e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802021:	83 c7 01             	add    $0x1,%edi
  802024:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802027:	75 c2                	jne    801feb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802029:	8b 45 10             	mov    0x10(%ebp),%eax
  80202c:	eb 05                	jmp    802033 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802033:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802036:	5b                   	pop    %ebx
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    

0080203b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	57                   	push   %edi
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	83 ec 18             	sub    $0x18,%esp
  802044:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802047:	57                   	push   %edi
  802048:	e8 f8 f1 ff ff       	call   801245 <fd2data>
  80204d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	bb 00 00 00 00       	mov    $0x0,%ebx
  802057:	eb 3d                	jmp    802096 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802059:	85 db                	test   %ebx,%ebx
  80205b:	74 04                	je     802061 <devpipe_read+0x26>
				return i;
  80205d:	89 d8                	mov    %ebx,%eax
  80205f:	eb 44                	jmp    8020a5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802061:	89 f2                	mov    %esi,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	e8 ec fe ff ff       	call   801f56 <_pipeisclosed>
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 32                	jne    8020a0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80206e:	e8 0d ec ff ff       	call   800c80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802073:	8b 06                	mov    (%esi),%eax
  802075:	3b 46 04             	cmp    0x4(%esi),%eax
  802078:	74 df                	je     802059 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80207a:	99                   	cltd   
  80207b:	c1 ea 1b             	shr    $0x1b,%edx
  80207e:	01 d0                	add    %edx,%eax
  802080:	83 e0 1f             	and    $0x1f,%eax
  802083:	29 d0                	sub    %edx,%eax
  802085:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80208a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80208d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802090:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802093:	83 c3 01             	add    $0x1,%ebx
  802096:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802099:	75 d8                	jne    802073 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80209b:	8b 45 10             	mov    0x10(%ebp),%eax
  80209e:	eb 05                	jmp    8020a5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020a0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5f                   	pop    %edi
  8020ab:	5d                   	pop    %ebp
  8020ac:	c3                   	ret    

008020ad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	e8 9e f1 ff ff       	call   80125c <fd_alloc>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	0f 88 2c 01 00 00    	js     8021f7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cb:	83 ec 04             	sub    $0x4,%esp
  8020ce:	68 07 04 00 00       	push   $0x407
  8020d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d6:	6a 00                	push   $0x0
  8020d8:	e8 c2 eb ff ff       	call   800c9f <sys_page_alloc>
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	89 c2                	mov    %eax,%edx
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	0f 88 0d 01 00 00    	js     8021f7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ea:	83 ec 0c             	sub    $0xc,%esp
  8020ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020f0:	50                   	push   %eax
  8020f1:	e8 66 f1 ff ff       	call   80125c <fd_alloc>
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	0f 88 e2 00 00 00    	js     8021e5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	68 07 04 00 00       	push   $0x407
  80210b:	ff 75 f0             	pushl  -0x10(%ebp)
  80210e:	6a 00                	push   $0x0
  802110:	e8 8a eb ff ff       	call   800c9f <sys_page_alloc>
  802115:	89 c3                	mov    %eax,%ebx
  802117:	83 c4 10             	add    $0x10,%esp
  80211a:	85 c0                	test   %eax,%eax
  80211c:	0f 88 c3 00 00 00    	js     8021e5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	ff 75 f4             	pushl  -0xc(%ebp)
  802128:	e8 18 f1 ff ff       	call   801245 <fd2data>
  80212d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212f:	83 c4 0c             	add    $0xc,%esp
  802132:	68 07 04 00 00       	push   $0x407
  802137:	50                   	push   %eax
  802138:	6a 00                	push   $0x0
  80213a:	e8 60 eb ff ff       	call   800c9f <sys_page_alloc>
  80213f:	89 c3                	mov    %eax,%ebx
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	85 c0                	test   %eax,%eax
  802146:	0f 88 89 00 00 00    	js     8021d5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214c:	83 ec 0c             	sub    $0xc,%esp
  80214f:	ff 75 f0             	pushl  -0x10(%ebp)
  802152:	e8 ee f0 ff ff       	call   801245 <fd2data>
  802157:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80215e:	50                   	push   %eax
  80215f:	6a 00                	push   $0x0
  802161:	56                   	push   %esi
  802162:	6a 00                	push   $0x0
  802164:	e8 79 eb ff ff       	call   800ce2 <sys_page_map>
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	83 c4 20             	add    $0x20,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 55                	js     8021c7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802172:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80217d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802180:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802187:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802190:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802195:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80219c:	83 ec 0c             	sub    $0xc,%esp
  80219f:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a2:	e8 8e f0 ff ff       	call   801235 <fd2num>
  8021a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021aa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ac:	83 c4 04             	add    $0x4,%esp
  8021af:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b2:	e8 7e f0 ff ff       	call   801235 <fd2num>
  8021b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021bd:	83 c4 10             	add    $0x10,%esp
  8021c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c5:	eb 30                	jmp    8021f7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	56                   	push   %esi
  8021cb:	6a 00                	push   $0x0
  8021cd:	e8 52 eb ff ff       	call   800d24 <sys_page_unmap>
  8021d2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021d5:	83 ec 08             	sub    $0x8,%esp
  8021d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8021db:	6a 00                	push   $0x0
  8021dd:	e8 42 eb ff ff       	call   800d24 <sys_page_unmap>
  8021e2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021e5:	83 ec 08             	sub    $0x8,%esp
  8021e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021eb:	6a 00                	push   $0x0
  8021ed:	e8 32 eb ff ff       	call   800d24 <sys_page_unmap>
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021f7:	89 d0                	mov    %edx,%eax
  8021f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802209:	50                   	push   %eax
  80220a:	ff 75 08             	pushl  0x8(%ebp)
  80220d:	e8 99 f0 ff ff       	call   8012ab <fd_lookup>
  802212:	89 c2                	mov    %eax,%edx
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	85 d2                	test   %edx,%edx
  802219:	78 18                	js     802233 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80221b:	83 ec 0c             	sub    $0xc,%esp
  80221e:	ff 75 f4             	pushl  -0xc(%ebp)
  802221:	e8 1f f0 ff ff       	call   801245 <fd2data>
	return _pipeisclosed(fd, p);
  802226:	89 c2                	mov    %eax,%edx
  802228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222b:	e8 26 fd ff ff       	call   801f56 <_pipeisclosed>
  802230:	83 c4 10             	add    $0x10,%esp
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802238:	b8 00 00 00 00       	mov    $0x0,%eax
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    

0080223f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802245:	68 e3 2e 80 00       	push   $0x802ee3
  80224a:	ff 75 0c             	pushl  0xc(%ebp)
  80224d:	e8 44 e6 ff ff       	call   800896 <strcpy>
	return 0;
}
  802252:	b8 00 00 00 00       	mov    $0x0,%eax
  802257:	c9                   	leave  
  802258:	c3                   	ret    

00802259 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	57                   	push   %edi
  80225d:	56                   	push   %esi
  80225e:	53                   	push   %ebx
  80225f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802265:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80226a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802270:	eb 2d                	jmp    80229f <devcons_write+0x46>
		m = n - tot;
  802272:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802275:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802277:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80227a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80227f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802282:	83 ec 04             	sub    $0x4,%esp
  802285:	53                   	push   %ebx
  802286:	03 45 0c             	add    0xc(%ebp),%eax
  802289:	50                   	push   %eax
  80228a:	57                   	push   %edi
  80228b:	e8 98 e7 ff ff       	call   800a28 <memmove>
		sys_cputs(buf, m);
  802290:	83 c4 08             	add    $0x8,%esp
  802293:	53                   	push   %ebx
  802294:	57                   	push   %edi
  802295:	e8 49 e9 ff ff       	call   800be3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80229a:	01 de                	add    %ebx,%esi
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	89 f0                	mov    %esi,%eax
  8022a1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022a4:	72 cc                	jb     802272 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a9:	5b                   	pop    %ebx
  8022aa:	5e                   	pop    %esi
  8022ab:	5f                   	pop    %edi
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    

008022ae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8022b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022bd:	75 07                	jne    8022c6 <devcons_read+0x18>
  8022bf:	eb 28                	jmp    8022e9 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022c1:	e8 ba e9 ff ff       	call   800c80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022c6:	e8 36 e9 ff ff       	call   800c01 <sys_cgetc>
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	74 f2                	je     8022c1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 16                	js     8022e9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022d3:	83 f8 04             	cmp    $0x4,%eax
  8022d6:	74 0c                	je     8022e4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022db:	88 02                	mov    %al,(%edx)
	return 1;
  8022dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e2:	eb 05                	jmp    8022e9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022e9:	c9                   	leave  
  8022ea:	c3                   	ret    

008022eb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022f7:	6a 01                	push   $0x1
  8022f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022fc:	50                   	push   %eax
  8022fd:	e8 e1 e8 ff ff       	call   800be3 <sys_cputs>
  802302:	83 c4 10             	add    $0x10,%esp
}
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <getchar>:

int
getchar(void)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80230d:	6a 01                	push   $0x1
  80230f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802312:	50                   	push   %eax
  802313:	6a 00                	push   $0x0
  802315:	e8 00 f2 ff ff       	call   80151a <read>
	if (r < 0)
  80231a:	83 c4 10             	add    $0x10,%esp
  80231d:	85 c0                	test   %eax,%eax
  80231f:	78 0f                	js     802330 <getchar+0x29>
		return r;
	if (r < 1)
  802321:	85 c0                	test   %eax,%eax
  802323:	7e 06                	jle    80232b <getchar+0x24>
		return -E_EOF;
	return c;
  802325:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802329:	eb 05                	jmp    802330 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80232b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    

00802332 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80233b:	50                   	push   %eax
  80233c:	ff 75 08             	pushl  0x8(%ebp)
  80233f:	e8 67 ef ff ff       	call   8012ab <fd_lookup>
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	85 c0                	test   %eax,%eax
  802349:	78 11                	js     80235c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80234b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802354:	39 10                	cmp    %edx,(%eax)
  802356:	0f 94 c0             	sete   %al
  802359:	0f b6 c0             	movzbl %al,%eax
}
  80235c:	c9                   	leave  
  80235d:	c3                   	ret    

0080235e <opencons>:

int
opencons(void)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802367:	50                   	push   %eax
  802368:	e8 ef ee ff ff       	call   80125c <fd_alloc>
  80236d:	83 c4 10             	add    $0x10,%esp
		return r;
  802370:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802372:	85 c0                	test   %eax,%eax
  802374:	78 3e                	js     8023b4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802376:	83 ec 04             	sub    $0x4,%esp
  802379:	68 07 04 00 00       	push   $0x407
  80237e:	ff 75 f4             	pushl  -0xc(%ebp)
  802381:	6a 00                	push   $0x0
  802383:	e8 17 e9 ff ff       	call   800c9f <sys_page_alloc>
  802388:	83 c4 10             	add    $0x10,%esp
		return r;
  80238b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 23                	js     8023b4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802391:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802397:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80239c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023a6:	83 ec 0c             	sub    $0xc,%esp
  8023a9:	50                   	push   %eax
  8023aa:	e8 86 ee ff ff       	call   801235 <fd2num>
  8023af:	89 c2                	mov    %eax,%edx
  8023b1:	83 c4 10             	add    $0x10,%esp
}
  8023b4:	89 d0                	mov    %edx,%eax
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    

008023b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
  8023bb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023be:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023c5:	75 2c                	jne    8023f3 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8023c7:	83 ec 04             	sub    $0x4,%esp
  8023ca:	6a 07                	push   $0x7
  8023cc:	68 00 f0 bf ee       	push   $0xeebff000
  8023d1:	6a 00                	push   $0x0
  8023d3:	e8 c7 e8 ff ff       	call   800c9f <sys_page_alloc>
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	74 14                	je     8023f3 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8023df:	83 ec 04             	sub    $0x4,%esp
  8023e2:	68 f0 2e 80 00       	push   $0x802ef0
  8023e7:	6a 21                	push   $0x21
  8023e9:	68 54 2f 80 00       	push   $0x802f54
  8023ee:	e8 43 de ff ff       	call   800236 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f6:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8023fb:	83 ec 08             	sub    $0x8,%esp
  8023fe:	68 27 24 80 00       	push   $0x802427
  802403:	6a 00                	push   $0x0
  802405:	e8 e0 e9 ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  80240a:	83 c4 10             	add    $0x10,%esp
  80240d:	85 c0                	test   %eax,%eax
  80240f:	79 14                	jns    802425 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802411:	83 ec 04             	sub    $0x4,%esp
  802414:	68 1c 2f 80 00       	push   $0x802f1c
  802419:	6a 29                	push   $0x29
  80241b:	68 54 2f 80 00       	push   $0x802f54
  802420:	e8 11 de ff ff       	call   800236 <_panic>
}
  802425:	c9                   	leave  
  802426:	c3                   	ret    

00802427 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802427:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802428:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80242d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80242f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802432:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802437:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80243b:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80243f:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802441:	83 c4 08             	add    $0x8,%esp
        popal
  802444:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802445:	83 c4 04             	add    $0x4,%esp
        popfl
  802448:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802449:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80244a:	c3                   	ret    

0080244b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	56                   	push   %esi
  80244f:	53                   	push   %ebx
  802450:	8b 75 08             	mov    0x8(%ebp),%esi
  802453:	8b 45 0c             	mov    0xc(%ebp),%eax
  802456:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802459:	85 c0                	test   %eax,%eax
  80245b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802460:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802463:	83 ec 0c             	sub    $0xc,%esp
  802466:	50                   	push   %eax
  802467:	e8 e3 e9 ff ff       	call   800e4f <sys_ipc_recv>
  80246c:	83 c4 10             	add    $0x10,%esp
  80246f:	85 c0                	test   %eax,%eax
  802471:	79 16                	jns    802489 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802473:	85 f6                	test   %esi,%esi
  802475:	74 06                	je     80247d <ipc_recv+0x32>
  802477:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80247d:	85 db                	test   %ebx,%ebx
  80247f:	74 2c                	je     8024ad <ipc_recv+0x62>
  802481:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802487:	eb 24                	jmp    8024ad <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802489:	85 f6                	test   %esi,%esi
  80248b:	74 0a                	je     802497 <ipc_recv+0x4c>
  80248d:	a1 08 40 80 00       	mov    0x804008,%eax
  802492:	8b 40 74             	mov    0x74(%eax),%eax
  802495:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802497:	85 db                	test   %ebx,%ebx
  802499:	74 0a                	je     8024a5 <ipc_recv+0x5a>
  80249b:	a1 08 40 80 00       	mov    0x804008,%eax
  8024a0:	8b 40 78             	mov    0x78(%eax),%eax
  8024a3:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8024a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8024aa:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b0:	5b                   	pop    %ebx
  8024b1:	5e                   	pop    %esi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    

008024b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	57                   	push   %edi
  8024b8:	56                   	push   %esi
  8024b9:	53                   	push   %ebx
  8024ba:	83 ec 0c             	sub    $0xc,%esp
  8024bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8024c6:	85 db                	test   %ebx,%ebx
  8024c8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024cd:	0f 44 d8             	cmove  %eax,%ebx
  8024d0:	eb 1c                	jmp    8024ee <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8024d2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024d5:	74 12                	je     8024e9 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8024d7:	50                   	push   %eax
  8024d8:	68 62 2f 80 00       	push   $0x802f62
  8024dd:	6a 39                	push   $0x39
  8024df:	68 7d 2f 80 00       	push   $0x802f7d
  8024e4:	e8 4d dd ff ff       	call   800236 <_panic>
                 sys_yield();
  8024e9:	e8 92 e7 ff ff       	call   800c80 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8024ee:	ff 75 14             	pushl  0x14(%ebp)
  8024f1:	53                   	push   %ebx
  8024f2:	56                   	push   %esi
  8024f3:	57                   	push   %edi
  8024f4:	e8 33 e9 ff ff       	call   800e2c <sys_ipc_try_send>
  8024f9:	83 c4 10             	add    $0x10,%esp
  8024fc:	85 c0                	test   %eax,%eax
  8024fe:	78 d2                	js     8024d2 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    

00802508 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80250e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802513:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802516:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80251c:	8b 52 50             	mov    0x50(%edx),%edx
  80251f:	39 ca                	cmp    %ecx,%edx
  802521:	75 0d                	jne    802530 <ipc_find_env+0x28>
			return envs[i].env_id;
  802523:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802526:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80252b:	8b 40 08             	mov    0x8(%eax),%eax
  80252e:	eb 0e                	jmp    80253e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802530:	83 c0 01             	add    $0x1,%eax
  802533:	3d 00 04 00 00       	cmp    $0x400,%eax
  802538:	75 d9                	jne    802513 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80253a:	66 b8 00 00          	mov    $0x0,%ax
}
  80253e:	5d                   	pop    %ebp
  80253f:	c3                   	ret    

00802540 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802546:	89 d0                	mov    %edx,%eax
  802548:	c1 e8 16             	shr    $0x16,%eax
  80254b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802552:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802557:	f6 c1 01             	test   $0x1,%cl
  80255a:	74 1d                	je     802579 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80255c:	c1 ea 0c             	shr    $0xc,%edx
  80255f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802566:	f6 c2 01             	test   $0x1,%dl
  802569:	74 0e                	je     802579 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80256b:	c1 ea 0c             	shr    $0xc,%edx
  80256e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802575:	ef 
  802576:	0f b7 c0             	movzwl %ax,%eax
}
  802579:	5d                   	pop    %ebp
  80257a:	c3                   	ret    
  80257b:	66 90                	xchg   %ax,%ax
  80257d:	66 90                	xchg   %ax,%ax
  80257f:	90                   	nop

00802580 <__udivdi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	83 ec 10             	sub    $0x10,%esp
  802586:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80258a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80258e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802592:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802596:	85 d2                	test   %edx,%edx
  802598:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80259c:	89 34 24             	mov    %esi,(%esp)
  80259f:	89 c8                	mov    %ecx,%eax
  8025a1:	75 35                	jne    8025d8 <__udivdi3+0x58>
  8025a3:	39 f1                	cmp    %esi,%ecx
  8025a5:	0f 87 bd 00 00 00    	ja     802668 <__udivdi3+0xe8>
  8025ab:	85 c9                	test   %ecx,%ecx
  8025ad:	89 cd                	mov    %ecx,%ebp
  8025af:	75 0b                	jne    8025bc <__udivdi3+0x3c>
  8025b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b6:	31 d2                	xor    %edx,%edx
  8025b8:	f7 f1                	div    %ecx
  8025ba:	89 c5                	mov    %eax,%ebp
  8025bc:	89 f0                	mov    %esi,%eax
  8025be:	31 d2                	xor    %edx,%edx
  8025c0:	f7 f5                	div    %ebp
  8025c2:	89 c6                	mov    %eax,%esi
  8025c4:	89 f8                	mov    %edi,%eax
  8025c6:	f7 f5                	div    %ebp
  8025c8:	89 f2                	mov    %esi,%edx
  8025ca:	83 c4 10             	add    $0x10,%esp
  8025cd:	5e                   	pop    %esi
  8025ce:	5f                   	pop    %edi
  8025cf:	5d                   	pop    %ebp
  8025d0:	c3                   	ret    
  8025d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	3b 14 24             	cmp    (%esp),%edx
  8025db:	77 7b                	ja     802658 <__udivdi3+0xd8>
  8025dd:	0f bd f2             	bsr    %edx,%esi
  8025e0:	83 f6 1f             	xor    $0x1f,%esi
  8025e3:	0f 84 97 00 00 00    	je     802680 <__udivdi3+0x100>
  8025e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8025ee:	89 d7                	mov    %edx,%edi
  8025f0:	89 f1                	mov    %esi,%ecx
  8025f2:	29 f5                	sub    %esi,%ebp
  8025f4:	d3 e7                	shl    %cl,%edi
  8025f6:	89 c2                	mov    %eax,%edx
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	d3 ea                	shr    %cl,%edx
  8025fc:	89 f1                	mov    %esi,%ecx
  8025fe:	09 fa                	or     %edi,%edx
  802600:	8b 3c 24             	mov    (%esp),%edi
  802603:	d3 e0                	shl    %cl,%eax
  802605:	89 54 24 08          	mov    %edx,0x8(%esp)
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80260f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802613:	89 fa                	mov    %edi,%edx
  802615:	d3 ea                	shr    %cl,%edx
  802617:	89 f1                	mov    %esi,%ecx
  802619:	d3 e7                	shl    %cl,%edi
  80261b:	89 e9                	mov    %ebp,%ecx
  80261d:	d3 e8                	shr    %cl,%eax
  80261f:	09 c7                	or     %eax,%edi
  802621:	89 f8                	mov    %edi,%eax
  802623:	f7 74 24 08          	divl   0x8(%esp)
  802627:	89 d5                	mov    %edx,%ebp
  802629:	89 c7                	mov    %eax,%edi
  80262b:	f7 64 24 0c          	mull   0xc(%esp)
  80262f:	39 d5                	cmp    %edx,%ebp
  802631:	89 14 24             	mov    %edx,(%esp)
  802634:	72 11                	jb     802647 <__udivdi3+0xc7>
  802636:	8b 54 24 04          	mov    0x4(%esp),%edx
  80263a:	89 f1                	mov    %esi,%ecx
  80263c:	d3 e2                	shl    %cl,%edx
  80263e:	39 c2                	cmp    %eax,%edx
  802640:	73 5e                	jae    8026a0 <__udivdi3+0x120>
  802642:	3b 2c 24             	cmp    (%esp),%ebp
  802645:	75 59                	jne    8026a0 <__udivdi3+0x120>
  802647:	8d 47 ff             	lea    -0x1(%edi),%eax
  80264a:	31 f6                	xor    %esi,%esi
  80264c:	89 f2                	mov    %esi,%edx
  80264e:	83 c4 10             	add    $0x10,%esp
  802651:	5e                   	pop    %esi
  802652:	5f                   	pop    %edi
  802653:	5d                   	pop    %ebp
  802654:	c3                   	ret    
  802655:	8d 76 00             	lea    0x0(%esi),%esi
  802658:	31 f6                	xor    %esi,%esi
  80265a:	31 c0                	xor    %eax,%eax
  80265c:	89 f2                	mov    %esi,%edx
  80265e:	83 c4 10             	add    $0x10,%esp
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi
  802668:	89 f2                	mov    %esi,%edx
  80266a:	31 f6                	xor    %esi,%esi
  80266c:	89 f8                	mov    %edi,%eax
  80266e:	f7 f1                	div    %ecx
  802670:	89 f2                	mov    %esi,%edx
  802672:	83 c4 10             	add    $0x10,%esp
  802675:	5e                   	pop    %esi
  802676:	5f                   	pop    %edi
  802677:	5d                   	pop    %ebp
  802678:	c3                   	ret    
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802684:	76 0b                	jbe    802691 <__udivdi3+0x111>
  802686:	31 c0                	xor    %eax,%eax
  802688:	3b 14 24             	cmp    (%esp),%edx
  80268b:	0f 83 37 ff ff ff    	jae    8025c8 <__udivdi3+0x48>
  802691:	b8 01 00 00 00       	mov    $0x1,%eax
  802696:	e9 2d ff ff ff       	jmp    8025c8 <__udivdi3+0x48>
  80269b:	90                   	nop
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 f8                	mov    %edi,%eax
  8026a2:	31 f6                	xor    %esi,%esi
  8026a4:	e9 1f ff ff ff       	jmp    8025c8 <__udivdi3+0x48>
  8026a9:	66 90                	xchg   %ax,%ax
  8026ab:	66 90                	xchg   %ax,%ax
  8026ad:	66 90                	xchg   %ax,%ax
  8026af:	90                   	nop

008026b0 <__umoddi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	83 ec 20             	sub    $0x20,%esp
  8026b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8026ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c2:	89 c6                	mov    %eax,%esi
  8026c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8026d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8026d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8026dc:	85 c0                	test   %eax,%eax
  8026de:	89 c2                	mov    %eax,%edx
  8026e0:	75 1e                	jne    802700 <__umoddi3+0x50>
  8026e2:	39 f7                	cmp    %esi,%edi
  8026e4:	76 52                	jbe    802738 <__umoddi3+0x88>
  8026e6:	89 c8                	mov    %ecx,%eax
  8026e8:	89 f2                	mov    %esi,%edx
  8026ea:	f7 f7                	div    %edi
  8026ec:	89 d0                	mov    %edx,%eax
  8026ee:	31 d2                	xor    %edx,%edx
  8026f0:	83 c4 20             	add    $0x20,%esp
  8026f3:	5e                   	pop    %esi
  8026f4:	5f                   	pop    %edi
  8026f5:	5d                   	pop    %ebp
  8026f6:	c3                   	ret    
  8026f7:	89 f6                	mov    %esi,%esi
  8026f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802700:	39 f0                	cmp    %esi,%eax
  802702:	77 5c                	ja     802760 <__umoddi3+0xb0>
  802704:	0f bd e8             	bsr    %eax,%ebp
  802707:	83 f5 1f             	xor    $0x1f,%ebp
  80270a:	75 64                	jne    802770 <__umoddi3+0xc0>
  80270c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802710:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802714:	0f 86 f6 00 00 00    	jbe    802810 <__umoddi3+0x160>
  80271a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80271e:	0f 82 ec 00 00 00    	jb     802810 <__umoddi3+0x160>
  802724:	8b 44 24 14          	mov    0x14(%esp),%eax
  802728:	8b 54 24 18          	mov    0x18(%esp),%edx
  80272c:	83 c4 20             	add    $0x20,%esp
  80272f:	5e                   	pop    %esi
  802730:	5f                   	pop    %edi
  802731:	5d                   	pop    %ebp
  802732:	c3                   	ret    
  802733:	90                   	nop
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	85 ff                	test   %edi,%edi
  80273a:	89 fd                	mov    %edi,%ebp
  80273c:	75 0b                	jne    802749 <__umoddi3+0x99>
  80273e:	b8 01 00 00 00       	mov    $0x1,%eax
  802743:	31 d2                	xor    %edx,%edx
  802745:	f7 f7                	div    %edi
  802747:	89 c5                	mov    %eax,%ebp
  802749:	8b 44 24 10          	mov    0x10(%esp),%eax
  80274d:	31 d2                	xor    %edx,%edx
  80274f:	f7 f5                	div    %ebp
  802751:	89 c8                	mov    %ecx,%eax
  802753:	f7 f5                	div    %ebp
  802755:	eb 95                	jmp    8026ec <__umoddi3+0x3c>
  802757:	89 f6                	mov    %esi,%esi
  802759:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 20             	add    $0x20,%esp
  802767:	5e                   	pop    %esi
  802768:	5f                   	pop    %edi
  802769:	5d                   	pop    %ebp
  80276a:	c3                   	ret    
  80276b:	90                   	nop
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	b8 20 00 00 00       	mov    $0x20,%eax
  802775:	89 e9                	mov    %ebp,%ecx
  802777:	29 e8                	sub    %ebp,%eax
  802779:	d3 e2                	shl    %cl,%edx
  80277b:	89 c7                	mov    %eax,%edi
  80277d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802781:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802785:	89 f9                	mov    %edi,%ecx
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 c1                	mov    %eax,%ecx
  80278b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80278f:	09 d1                	or     %edx,%ecx
  802791:	89 fa                	mov    %edi,%edx
  802793:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802797:	89 e9                	mov    %ebp,%ecx
  802799:	d3 e0                	shl    %cl,%eax
  80279b:	89 f9                	mov    %edi,%ecx
  80279d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027a1:	89 f0                	mov    %esi,%eax
  8027a3:	d3 e8                	shr    %cl,%eax
  8027a5:	89 e9                	mov    %ebp,%ecx
  8027a7:	89 c7                	mov    %eax,%edi
  8027a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8027ad:	d3 e6                	shl    %cl,%esi
  8027af:	89 d1                	mov    %edx,%ecx
  8027b1:	89 fa                	mov    %edi,%edx
  8027b3:	d3 e8                	shr    %cl,%eax
  8027b5:	89 e9                	mov    %ebp,%ecx
  8027b7:	09 f0                	or     %esi,%eax
  8027b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8027bd:	f7 74 24 10          	divl   0x10(%esp)
  8027c1:	d3 e6                	shl    %cl,%esi
  8027c3:	89 d1                	mov    %edx,%ecx
  8027c5:	f7 64 24 0c          	mull   0xc(%esp)
  8027c9:	39 d1                	cmp    %edx,%ecx
  8027cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8027cf:	89 d7                	mov    %edx,%edi
  8027d1:	89 c6                	mov    %eax,%esi
  8027d3:	72 0a                	jb     8027df <__umoddi3+0x12f>
  8027d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8027d9:	73 10                	jae    8027eb <__umoddi3+0x13b>
  8027db:	39 d1                	cmp    %edx,%ecx
  8027dd:	75 0c                	jne    8027eb <__umoddi3+0x13b>
  8027df:	89 d7                	mov    %edx,%edi
  8027e1:	89 c6                	mov    %eax,%esi
  8027e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8027e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8027eb:	89 ca                	mov    %ecx,%edx
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027f3:	29 f0                	sub    %esi,%eax
  8027f5:	19 fa                	sbb    %edi,%edx
  8027f7:	d3 e8                	shr    %cl,%eax
  8027f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8027fe:	89 d7                	mov    %edx,%edi
  802800:	d3 e7                	shl    %cl,%edi
  802802:	89 e9                	mov    %ebp,%ecx
  802804:	09 f8                	or     %edi,%eax
  802806:	d3 ea                	shr    %cl,%edx
  802808:	83 c4 20             	add    $0x20,%esp
  80280b:	5e                   	pop    %esi
  80280c:	5f                   	pop    %edi
  80280d:	5d                   	pop    %ebp
  80280e:	c3                   	ret    
  80280f:	90                   	nop
  802810:	8b 74 24 10          	mov    0x10(%esp),%esi
  802814:	29 f9                	sub    %edi,%ecx
  802816:	19 c6                	sbb    %eax,%esi
  802818:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80281c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802820:	e9 ff fe ff ff       	jmp    802724 <__umoddi3+0x74>
