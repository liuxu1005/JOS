
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 40 23 80 00       	push   $0x802340
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 84 1c 00 00       	call   801cd4 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 59 23 80 00       	push   $0x802359
  80005d:	6a 0d                	push   $0xd
  80005f:	68 62 23 80 00       	push   $0x802362
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 12 0f 00 00       	call   800f80 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 9b 28 80 00       	push   $0x80289b
  80007a:	6a 10                	push   $0x10
  80007c:	68 62 23 80 00       	push   $0x802362
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 a2 13 00 00       	call   801437 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 7f 1d 00 00       	call   801e27 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 76 23 80 00       	push   $0x802376
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 c5 0b 00 00       	call   800c8e <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 c6 10 00 00       	call   8011a2 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 91 23 80 00       	push   $0x802391
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 9c 23 80 00       	push   $0x80239c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 6f 13 00 00       	call   801489 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 54 13 00 00       	call   801489 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 a7 23 80 00       	push   $0x8023a7
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 cf 1c 00 00       	call   801e27 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 00 24 80 00       	push   $0x802400
  800167:	6a 3a                	push   $0x3a
  800169:	68 62 23 80 00       	push   $0x802362
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 8b 11 00 00       	call   80130d <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 bd 23 80 00       	push   $0x8023bd
  80018f:	6a 3c                	push   $0x3c
  800191:	68 62 23 80 00       	push   $0x802362
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 01 11 00 00       	call   8012a7 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 1a 19 00 00       	call   801ac8 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 d5 23 80 00       	push   $0x8023d5
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 eb 23 80 00       	push   $0x8023eb
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8001ef:	e8 7b 0a 00 00       	call   800c6f <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
  800220:	83 c4 10             	add    $0x10,%esp
}
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 2f 12 00 00       	call   801464 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 ef 09 00 00       	call   800c2e <sys_env_destroy>
  80023f:	83 c4 10             	add    $0x10,%esp
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 18 0a 00 00       	call   800c6f <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 34 24 80 00       	push   $0x802434
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 57 23 80 00 	movl   $0x802357,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 37 09 00 00       	call   800bf1 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 4f 01 00 00       	call   80044f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 dc 08 00 00       	call   800bf1 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 d1                	mov    %edx,%ecx
  800346:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800349:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80034c:	8b 45 10             	mov    0x10(%ebp),%eax
  80034f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800352:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800355:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80035f:	72 05                	jb     800366 <printnum+0x35>
  800361:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800364:	77 3e                	ja     8003a4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800366:	83 ec 0c             	sub    $0xc,%esp
  800369:	ff 75 18             	pushl  0x18(%ebp)
  80036c:	83 eb 01             	sub    $0x1,%ebx
  80036f:	53                   	push   %ebx
  800370:	50                   	push   %eax
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 fb 1c 00 00       	call   802080 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 13                	jmp    8003ab <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a4:	83 eb 01             	sub    $0x1,%ebx
  8003a7:	85 db                	test   %ebx,%ebx
  8003a9:	7f ed                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	56                   	push   %esi
  8003af:	83 ec 04             	sub    $0x4,%esp
  8003b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003be:	e8 ed 1d 00 00       	call   8021b0 <__umoddi3>
  8003c3:	83 c4 14             	add    $0x14,%esp
  8003c6:	0f be 80 57 24 80 00 	movsbl 0x802457(%eax),%eax
  8003cd:	50                   	push   %eax
  8003ce:	ff d7                	call   *%edi
  8003d0:	83 c4 10             	add    $0x10,%esp
}
  8003d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d6:	5b                   	pop    %ebx
  8003d7:	5e                   	pop    %esi
  8003d8:	5f                   	pop    %edi
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003de:	83 fa 01             	cmp    $0x1,%edx
  8003e1:	7e 0e                	jle    8003f1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e3:	8b 10                	mov    (%eax),%edx
  8003e5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e8:	89 08                	mov    %ecx,(%eax)
  8003ea:	8b 02                	mov    (%edx),%eax
  8003ec:	8b 52 04             	mov    0x4(%edx),%edx
  8003ef:	eb 22                	jmp    800413 <getuint+0x38>
	else if (lflag)
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	74 10                	je     800405 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 02                	mov    (%edx),%eax
  8003fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800403:	eb 0e                	jmp    800413 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800405:	8b 10                	mov    (%eax),%edx
  800407:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040a:	89 08                	mov    %ecx,(%eax)
  80040c:	8b 02                	mov    (%edx),%eax
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80041b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041f:	8b 10                	mov    (%eax),%edx
  800421:	3b 50 04             	cmp    0x4(%eax),%edx
  800424:	73 0a                	jae    800430 <sprintputch+0x1b>
		*b->buf++ = ch;
  800426:	8d 4a 01             	lea    0x1(%edx),%ecx
  800429:	89 08                	mov    %ecx,(%eax)
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	88 02                	mov    %al,(%edx)
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800438:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80043b:	50                   	push   %eax
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	ff 75 0c             	pushl  0xc(%ebp)
  800442:	ff 75 08             	pushl  0x8(%ebp)
  800445:	e8 05 00 00 00       	call   80044f <vprintfmt>
	va_end(ap);
  80044a:	83 c4 10             	add    $0x10,%esp
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	57                   	push   %edi
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 2c             	sub    $0x2c,%esp
  800458:	8b 75 08             	mov    0x8(%ebp),%esi
  80045b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800461:	eb 12                	jmp    800475 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800463:	85 c0                	test   %eax,%eax
  800465:	0f 84 90 03 00 00    	je     8007fb <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	50                   	push   %eax
  800470:	ff d6                	call   *%esi
  800472:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800475:	83 c7 01             	add    $0x1,%edi
  800478:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047c:	83 f8 25             	cmp    $0x25,%eax
  80047f:	75 e2                	jne    800463 <vprintfmt+0x14>
  800481:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800485:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80048c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800493:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049a:	ba 00 00 00 00       	mov    $0x0,%edx
  80049f:	eb 07                	jmp    8004a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8d 47 01             	lea    0x1(%edi),%eax
  8004ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ae:	0f b6 07             	movzbl (%edi),%eax
  8004b1:	0f b6 c8             	movzbl %al,%ecx
  8004b4:	83 e8 23             	sub    $0x23,%eax
  8004b7:	3c 55                	cmp    $0x55,%al
  8004b9:	0f 87 21 03 00 00    	ja     8007e0 <vprintfmt+0x391>
  8004bf:	0f b6 c0             	movzbl %al,%eax
  8004c2:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d0:	eb d6                	jmp    8004a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ea:	83 fa 09             	cmp    $0x9,%edx
  8004ed:	77 39                	ja     800528 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f2:	eb e9                	jmp    8004dd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800505:	eb 27                	jmp    80052e <vprintfmt+0xdf>
  800507:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050a:	85 c0                	test   %eax,%eax
  80050c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800511:	0f 49 c8             	cmovns %eax,%ecx
  800514:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051a:	eb 8c                	jmp    8004a8 <vprintfmt+0x59>
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800526:	eb 80                	jmp    8004a8 <vprintfmt+0x59>
  800528:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800532:	0f 89 70 ff ff ff    	jns    8004a8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800538:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80053b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800545:	e9 5e ff ff ff       	jmp    8004a8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800550:	e9 53 ff ff ff       	jmp    8004a8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	ff 30                	pushl  (%eax)
  800564:	ff d6                	call   *%esi
			break;
  800566:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056c:	e9 04 ff ff ff       	jmp    800475 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	99                   	cltd   
  80057d:	31 d0                	xor    %edx,%eax
  80057f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800581:	83 f8 0f             	cmp    $0xf,%eax
  800584:	7f 0b                	jg     800591 <vprintfmt+0x142>
  800586:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80058d:	85 d2                	test   %edx,%edx
  80058f:	75 18                	jne    8005a9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800591:	50                   	push   %eax
  800592:	68 6f 24 80 00       	push   $0x80246f
  800597:	53                   	push   %ebx
  800598:	56                   	push   %esi
  800599:	e8 94 fe ff ff       	call   800432 <printfmt>
  80059e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a4:	e9 cc fe ff ff       	jmp    800475 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a9:	52                   	push   %edx
  8005aa:	68 d5 29 80 00       	push   $0x8029d5
  8005af:	53                   	push   %ebx
  8005b0:	56                   	push   %esi
  8005b1:	e8 7c fe ff ff       	call   800432 <printfmt>
  8005b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bc:	e9 b4 fe ff ff       	jmp    800475 <vprintfmt+0x26>
  8005c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	ba 68 24 80 00       	mov    $0x802468,%edx
  8005dc:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8005df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e3:	0f 84 92 00 00 00    	je     80067b <vprintfmt+0x22c>
  8005e9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005ed:	0f 8e 96 00 00 00    	jle    800689 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	51                   	push   %ecx
  8005f7:	57                   	push   %edi
  8005f8:	e8 86 02 00 00       	call   800883 <strnlen>
  8005fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800600:	29 c1                	sub    %eax,%ecx
  800602:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800608:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800612:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	eb 0f                	jmp    800625 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	ff 75 e0             	pushl  -0x20(%ebp)
  80061d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	83 ef 01             	sub    $0x1,%edi
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	85 ff                	test   %edi,%edi
  800627:	7f ed                	jg     800616 <vprintfmt+0x1c7>
  800629:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062f:	85 c9                	test   %ecx,%ecx
  800631:	b8 00 00 00 00       	mov    $0x0,%eax
  800636:	0f 49 c1             	cmovns %ecx,%eax
  800639:	29 c1                	sub    %eax,%ecx
  80063b:	89 75 08             	mov    %esi,0x8(%ebp)
  80063e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800641:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800644:	89 cb                	mov    %ecx,%ebx
  800646:	eb 4d                	jmp    800695 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800648:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064c:	74 1b                	je     800669 <vprintfmt+0x21a>
  80064e:	0f be c0             	movsbl %al,%eax
  800651:	83 e8 20             	sub    $0x20,%eax
  800654:	83 f8 5e             	cmp    $0x5e,%eax
  800657:	76 10                	jbe    800669 <vprintfmt+0x21a>
					putch('?', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	6a 3f                	push   $0x3f
  800661:	ff 55 08             	call   *0x8(%ebp)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	eb 0d                	jmp    800676 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	ff 75 0c             	pushl  0xc(%ebp)
  80066f:	52                   	push   %edx
  800670:	ff 55 08             	call   *0x8(%ebp)
  800673:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800676:	83 eb 01             	sub    $0x1,%ebx
  800679:	eb 1a                	jmp    800695 <vprintfmt+0x246>
  80067b:	89 75 08             	mov    %esi,0x8(%ebp)
  80067e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800681:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800684:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800687:	eb 0c                	jmp    800695 <vprintfmt+0x246>
  800689:	89 75 08             	mov    %esi,0x8(%ebp)
  80068c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800692:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800695:	83 c7 01             	add    $0x1,%edi
  800698:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069c:	0f be d0             	movsbl %al,%edx
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	74 23                	je     8006c6 <vprintfmt+0x277>
  8006a3:	85 f6                	test   %esi,%esi
  8006a5:	78 a1                	js     800648 <vprintfmt+0x1f9>
  8006a7:	83 ee 01             	sub    $0x1,%esi
  8006aa:	79 9c                	jns    800648 <vprintfmt+0x1f9>
  8006ac:	89 df                	mov    %ebx,%edi
  8006ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b4:	eb 18                	jmp    8006ce <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 20                	push   $0x20
  8006bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006be:	83 ef 01             	sub    $0x1,%edi
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 08                	jmp    8006ce <vprintfmt+0x27f>
  8006c6:	89 df                	mov    %ebx,%edi
  8006c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ce:	85 ff                	test   %edi,%edi
  8006d0:	7f e4                	jg     8006b6 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	e9 9b fd ff ff       	jmp    800475 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006da:	83 fa 01             	cmp    $0x1,%edx
  8006dd:	7e 16                	jle    8006f5 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 08             	lea    0x8(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 50 04             	mov    0x4(%eax),%edx
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f3:	eb 32                	jmp    800727 <vprintfmt+0x2d8>
	else if (lflag)
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	74 18                	je     800711 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8d 50 04             	lea    0x4(%eax),%edx
  8006ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800702:	8b 00                	mov    (%eax),%eax
  800704:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800707:	89 c1                	mov    %eax,%ecx
  800709:	c1 f9 1f             	sar    $0x1f,%ecx
  80070c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070f:	eb 16                	jmp    800727 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8d 50 04             	lea    0x4(%eax),%edx
  800717:	89 55 14             	mov    %edx,0x14(%ebp)
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071f:	89 c1                	mov    %eax,%ecx
  800721:	c1 f9 1f             	sar    $0x1f,%ecx
  800724:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800727:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800732:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800736:	79 74                	jns    8007ac <vprintfmt+0x35d>
				putch('-', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 2d                	push   $0x2d
  80073e:	ff d6                	call   *%esi
				num = -(long long) num;
  800740:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800743:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800746:	f7 d8                	neg    %eax
  800748:	83 d2 00             	adc    $0x0,%edx
  80074b:	f7 da                	neg    %edx
  80074d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800750:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800755:	eb 55                	jmp    8007ac <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 7c fc ff ff       	call   8003db <getuint>
			base = 10;
  80075f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800764:	eb 46                	jmp    8007ac <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 6d fc ff ff       	call   8003db <getuint>
                        base = 8;
  80076e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800773:	eb 37                	jmp    8007ac <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 30                	push   $0x30
  80077b:	ff d6                	call   *%esi
			putch('x', putdat);
  80077d:	83 c4 08             	add    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 78                	push   $0x78
  800783:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800795:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800798:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079d:	eb 0d                	jmp    8007ac <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a2:	e8 34 fc ff ff       	call   8003db <getuint>
			base = 16;
  8007a7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ac:	83 ec 0c             	sub    $0xc,%esp
  8007af:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b3:	57                   	push   %edi
  8007b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b7:	51                   	push   %ecx
  8007b8:	52                   	push   %edx
  8007b9:	50                   	push   %eax
  8007ba:	89 da                	mov    %ebx,%edx
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	e8 6e fb ff ff       	call   800331 <printnum>
			break;
  8007c3:	83 c4 20             	add    $0x20,%esp
  8007c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c9:	e9 a7 fc ff ff       	jmp    800475 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	51                   	push   %ecx
  8007d3:	ff d6                	call   *%esi
			break;
  8007d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007db:	e9 95 fc ff ff       	jmp    800475 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	53                   	push   %ebx
  8007e4:	6a 25                	push   $0x25
  8007e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	eb 03                	jmp    8007f0 <vprintfmt+0x3a1>
  8007ed:	83 ef 01             	sub    $0x1,%edi
  8007f0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f4:	75 f7                	jne    8007ed <vprintfmt+0x39e>
  8007f6:	e9 7a fc ff ff       	jmp    800475 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5f                   	pop    %edi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 18             	sub    $0x18,%esp
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800812:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800816:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800819:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800820:	85 c0                	test   %eax,%eax
  800822:	74 26                	je     80084a <vsnprintf+0x47>
  800824:	85 d2                	test   %edx,%edx
  800826:	7e 22                	jle    80084a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800828:	ff 75 14             	pushl  0x14(%ebp)
  80082b:	ff 75 10             	pushl  0x10(%ebp)
  80082e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	68 15 04 80 00       	push   $0x800415
  800837:	e8 13 fc ff ff       	call   80044f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 05                	jmp    80084f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80084a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800857:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085a:	50                   	push   %eax
  80085b:	ff 75 10             	pushl  0x10(%ebp)
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	ff 75 08             	pushl  0x8(%ebp)
  800864:	e8 9a ff ff ff       	call   800803 <vsnprintf>
	va_end(ap);

	return rc;
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb 03                	jmp    80087b <strlen+0x10>
		n++;
  800878:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80087b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087f:	75 f7                	jne    800878 <strlen+0xd>
		n++;
	return n;
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088c:	ba 00 00 00 00       	mov    $0x0,%edx
  800891:	eb 03                	jmp    800896 <strnlen+0x13>
		n++;
  800893:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800896:	39 c2                	cmp    %eax,%edx
  800898:	74 08                	je     8008a2 <strnlen+0x1f>
  80089a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089e:	75 f3                	jne    800893 <strnlen+0x10>
  8008a0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ae:	89 c2                	mov    %eax,%edx
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ba:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bd:	84 db                	test   %bl,%bl
  8008bf:	75 ef                	jne    8008b0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008cb:	53                   	push   %ebx
  8008cc:	e8 9a ff ff ff       	call   80086b <strlen>
  8008d1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	01 d8                	add    %ebx,%eax
  8008d9:	50                   	push   %eax
  8008da:	e8 c5 ff ff ff       	call   8008a4 <strcpy>
	return dst;
}
  8008df:	89 d8                	mov    %ebx,%eax
  8008e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f1:	89 f3                	mov    %esi,%ebx
  8008f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f6:	89 f2                	mov    %esi,%edx
  8008f8:	eb 0f                	jmp    800909 <strncpy+0x23>
		*dst++ = *src;
  8008fa:	83 c2 01             	add    $0x1,%edx
  8008fd:	0f b6 01             	movzbl (%ecx),%eax
  800900:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 39 01             	cmpb   $0x1,(%ecx)
  800906:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	39 da                	cmp    %ebx,%edx
  80090b:	75 ed                	jne    8008fa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 75 08             	mov    0x8(%ebp),%esi
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091e:	8b 55 10             	mov    0x10(%ebp),%edx
  800921:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800923:	85 d2                	test   %edx,%edx
  800925:	74 21                	je     800948 <strlcpy+0x35>
  800927:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092b:	89 f2                	mov    %esi,%edx
  80092d:	eb 09                	jmp    800938 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092f:	83 c2 01             	add    $0x1,%edx
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800938:	39 c2                	cmp    %eax,%edx
  80093a:	74 09                	je     800945 <strlcpy+0x32>
  80093c:	0f b6 19             	movzbl (%ecx),%ebx
  80093f:	84 db                	test   %bl,%bl
  800941:	75 ec                	jne    80092f <strlcpy+0x1c>
  800943:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800945:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800948:	29 f0                	sub    %esi,%eax
}
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800957:	eb 06                	jmp    80095f <strcmp+0x11>
		p++, q++;
  800959:	83 c1 01             	add    $0x1,%ecx
  80095c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095f:	0f b6 01             	movzbl (%ecx),%eax
  800962:	84 c0                	test   %al,%al
  800964:	74 04                	je     80096a <strcmp+0x1c>
  800966:	3a 02                	cmp    (%edx),%al
  800968:	74 ef                	je     800959 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096a:	0f b6 c0             	movzbl %al,%eax
  80096d:	0f b6 12             	movzbl (%edx),%edx
  800970:	29 d0                	sub    %edx,%eax
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	53                   	push   %ebx
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097e:	89 c3                	mov    %eax,%ebx
  800980:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800983:	eb 06                	jmp    80098b <strncmp+0x17>
		n--, p++, q++;
  800985:	83 c0 01             	add    $0x1,%eax
  800988:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098b:	39 d8                	cmp    %ebx,%eax
  80098d:	74 15                	je     8009a4 <strncmp+0x30>
  80098f:	0f b6 08             	movzbl (%eax),%ecx
  800992:	84 c9                	test   %cl,%cl
  800994:	74 04                	je     80099a <strncmp+0x26>
  800996:	3a 0a                	cmp    (%edx),%cl
  800998:	74 eb                	je     800985 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099a:	0f b6 00             	movzbl (%eax),%eax
  80099d:	0f b6 12             	movzbl (%edx),%edx
  8009a0:	29 d0                	sub    %edx,%eax
  8009a2:	eb 05                	jmp    8009a9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b6:	eb 07                	jmp    8009bf <strchr+0x13>
		if (*s == c)
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	74 0f                	je     8009cb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	0f b6 10             	movzbl (%eax),%edx
  8009c2:	84 d2                	test   %dl,%dl
  8009c4:	75 f2                	jne    8009b8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d7:	eb 03                	jmp    8009dc <strfind+0xf>
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	74 04                	je     8009e7 <strfind+0x1a>
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	75 f2                	jne    8009d9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f5:	85 c9                	test   %ecx,%ecx
  8009f7:	74 36                	je     800a2f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ff:	75 28                	jne    800a29 <memset+0x40>
  800a01:	f6 c1 03             	test   $0x3,%cl
  800a04:	75 23                	jne    800a29 <memset+0x40>
		c &= 0xFF;
  800a06:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a0a:	89 d3                	mov    %edx,%ebx
  800a0c:	c1 e3 08             	shl    $0x8,%ebx
  800a0f:	89 d6                	mov    %edx,%esi
  800a11:	c1 e6 18             	shl    $0x18,%esi
  800a14:	89 d0                	mov    %edx,%eax
  800a16:	c1 e0 10             	shl    $0x10,%eax
  800a19:	09 f0                	or     %esi,%eax
  800a1b:	09 c2                	or     %eax,%edx
  800a1d:	89 d0                	mov    %edx,%eax
  800a1f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a21:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a24:	fc                   	cld    
  800a25:	f3 ab                	rep stos %eax,%es:(%edi)
  800a27:	eb 06                	jmp    800a2f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	fc                   	cld    
  800a2d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2f:	89 f8                	mov    %edi,%eax
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a44:	39 c6                	cmp    %eax,%esi
  800a46:	73 35                	jae    800a7d <memmove+0x47>
  800a48:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4b:	39 d0                	cmp    %edx,%eax
  800a4d:	73 2e                	jae    800a7d <memmove+0x47>
		s += n;
		d += n;
  800a4f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a52:	89 d6                	mov    %edx,%esi
  800a54:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5c:	75 13                	jne    800a71 <memmove+0x3b>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0e                	jne    800a71 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a63:	83 ef 04             	sub    $0x4,%edi
  800a66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a69:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6c:	fd                   	std    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 09                	jmp    800a7a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a71:	83 ef 01             	sub    $0x1,%edi
  800a74:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a77:	fd                   	std    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7a:	fc                   	cld    
  800a7b:	eb 1d                	jmp    800a9a <memmove+0x64>
  800a7d:	89 f2                	mov    %esi,%edx
  800a7f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	f6 c2 03             	test   $0x3,%dl
  800a84:	75 0f                	jne    800a95 <memmove+0x5f>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 0a                	jne    800a95 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8e:	89 c7                	mov    %eax,%edi
  800a90:	fc                   	cld    
  800a91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a93:	eb 05                	jmp    800a9a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a95:	89 c7                	mov    %eax,%edi
  800a97:	fc                   	cld    
  800a98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa1:	ff 75 10             	pushl  0x10(%ebp)
  800aa4:	ff 75 0c             	pushl  0xc(%ebp)
  800aa7:	ff 75 08             	pushl  0x8(%ebp)
  800aaa:	e8 87 ff ff ff       	call   800a36 <memmove>
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c6                	mov    %eax,%esi
  800abe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac1:	eb 1a                	jmp    800add <memcmp+0x2c>
		if (*s1 != *s2)
  800ac3:	0f b6 08             	movzbl (%eax),%ecx
  800ac6:	0f b6 1a             	movzbl (%edx),%ebx
  800ac9:	38 d9                	cmp    %bl,%cl
  800acb:	74 0a                	je     800ad7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acd:	0f b6 c1             	movzbl %cl,%eax
  800ad0:	0f b6 db             	movzbl %bl,%ebx
  800ad3:	29 d8                	sub    %ebx,%eax
  800ad5:	eb 0f                	jmp    800ae6 <memcmp+0x35>
		s1++, s2++;
  800ad7:	83 c0 01             	add    $0x1,%eax
  800ada:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	39 f0                	cmp    %esi,%eax
  800adf:	75 e2                	jne    800ac3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af8:	eb 07                	jmp    800b01 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afa:	38 08                	cmp    %cl,(%eax)
  800afc:	74 07                	je     800b05 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afe:	83 c0 01             	add    $0x1,%eax
  800b01:	39 d0                	cmp    %edx,%eax
  800b03:	72 f5                	jb     800afa <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	eb 03                	jmp    800b18 <strtol+0x11>
		s++;
  800b15:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	3c 09                	cmp    $0x9,%al
  800b1d:	74 f6                	je     800b15 <strtol+0xe>
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f2                	je     800b15 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b23:	3c 2b                	cmp    $0x2b,%al
  800b25:	75 0a                	jne    800b31 <strtol+0x2a>
		s++;
  800b27:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2f:	eb 10                	jmp    800b41 <strtol+0x3a>
  800b31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b36:	3c 2d                	cmp    $0x2d,%al
  800b38:	75 07                	jne    800b41 <strtol+0x3a>
		s++, neg = 1;
  800b3a:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	0f 94 c0             	sete   %al
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 19                	jne    800b67 <strtol+0x60>
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	75 14                	jne    800b67 <strtol+0x60>
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	0f 85 82 00 00 00    	jne    800bdf <strtol+0xd8>
		s += 2, base = 16;
  800b5d:	83 c1 02             	add    $0x2,%ecx
  800b60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b65:	eb 16                	jmp    800b7d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b67:	84 c0                	test   %al,%al
  800b69:	74 12                	je     800b7d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b70:	80 39 30             	cmpb   $0x30,(%ecx)
  800b73:	75 08                	jne    800b7d <strtol+0x76>
		s++, base = 8;
  800b75:	83 c1 01             	add    $0x1,%ecx
  800b78:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 11             	movzbl (%ecx),%edx
  800b88:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 09             	cmp    $0x9,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x93>
			dig = *s - '0';
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 30             	sub    $0x30,%edx
  800b98:	eb 22                	jmp    800bbc <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b9a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 08                	ja     800bac <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 57             	sub    $0x57,%edx
  800baa:	eb 10                	jmp    800bbc <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800bac:	8d 72 bf             	lea    -0x41(%edx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 16                	ja     800bcc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bb6:	0f be d2             	movsbl %dl,%edx
  800bb9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bbc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbf:	7d 0f                	jge    800bd0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800bc1:	83 c1 01             	add    $0x1,%ecx
  800bc4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bca:	eb b9                	jmp    800b85 <strtol+0x7e>
  800bcc:	89 c2                	mov    %eax,%edx
  800bce:	eb 02                	jmp    800bd2 <strtol+0xcb>
  800bd0:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd6:	74 0d                	je     800be5 <strtol+0xde>
		*endptr = (char *) s;
  800bd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bdb:	89 0e                	mov    %ecx,(%esi)
  800bdd:	eb 06                	jmp    800be5 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdf:	84 c0                	test   %al,%al
  800be1:	75 92                	jne    800b75 <strtol+0x6e>
  800be3:	eb 98                	jmp    800b7d <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800be5:	f7 da                	neg    %edx
  800be7:	85 ff                	test   %edi,%edi
  800be9:	0f 45 c2             	cmovne %edx,%eax
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	89 c3                	mov    %eax,%ebx
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 c6                	mov    %eax,%esi
  800c08:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 cb                	mov    %ecx,%ebx
  800c46:	89 cf                	mov    %ecx,%edi
  800c48:	89 ce                	mov    %ecx,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 03                	push   $0x3
  800c56:	68 9f 27 80 00       	push   $0x80279f
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 bc 27 80 00       	push   $0x8027bc
  800c62:	e8 dd f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_yield>:

void
sys_yield(void)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	be 00 00 00 00       	mov    $0x0,%esi
  800cbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc9:	89 f7                	mov    %esi,%edi
  800ccb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 04                	push   $0x4
  800cd7:	68 9f 27 80 00       	push   $0x80279f
  800cdc:	6a 23                	push   $0x23
  800cde:	68 bc 27 80 00       	push   $0x8027bc
  800ce3:	e8 5c f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d07:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 05                	push   $0x5
  800d19:	68 9f 27 80 00       	push   $0x80279f
  800d1e:	6a 23                	push   $0x23
  800d20:	68 bc 27 80 00       	push   $0x8027bc
  800d25:	e8 1a f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d40:	b8 06 00 00 00       	mov    $0x6,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 df                	mov    %ebx,%edi
  800d4d:	89 de                	mov    %ebx,%esi
  800d4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 06                	push   $0x6
  800d5b:	68 9f 27 80 00       	push   $0x80279f
  800d60:	6a 23                	push   $0x23
  800d62:	68 bc 27 80 00       	push   $0x8027bc
  800d67:	e8 d8 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d82:	b8 08 00 00 00       	mov    $0x8,%eax
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	89 df                	mov    %ebx,%edi
  800d8f:	89 de                	mov    %ebx,%esi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 08                	push   $0x8
  800d9d:	68 9f 27 80 00       	push   $0x80279f
  800da2:	6a 23                	push   $0x23
  800da4:	68 bc 27 80 00       	push   $0x8027bc
  800da9:	e8 96 f4 ff ff       	call   800244 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 09                	push   $0x9
  800ddf:	68 9f 27 80 00       	push   $0x80279f
  800de4:	6a 23                	push   $0x23
  800de6:	68 bc 27 80 00       	push   $0x8027bc
  800deb:	e8 54 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 0a                	push   $0xa
  800e21:	68 9f 27 80 00       	push   $0x80279f
  800e26:	6a 23                	push   $0x23
  800e28:	68 bc 27 80 00       	push   $0x8027bc
  800e2d:	e8 12 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e40:	be 00 00 00 00       	mov    $0x0,%esi
  800e45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e56:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 cb                	mov    %ecx,%ebx
  800e75:	89 cf                	mov    %ecx,%edi
  800e77:	89 ce                	mov    %ecx,%esi
  800e79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	7e 17                	jle    800e96 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	50                   	push   %eax
  800e83:	6a 0d                	push   $0xd
  800e85:	68 9f 27 80 00       	push   $0x80279f
  800e8a:	6a 23                	push   $0x23
  800e8c:	68 bc 27 80 00       	push   $0x8027bc
  800e91:	e8 ae f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ea8:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800eaa:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800eae:	74 2e                	je     800ede <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	c1 ea 16             	shr    $0x16,%edx
  800eb5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	74 1d                	je     800ede <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	c1 ea 0c             	shr    $0xc,%edx
  800ec6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ecd:	f6 c1 01             	test   $0x1,%cl
  800ed0:	74 0c                	je     800ede <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ed2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ed9:	f6 c6 08             	test   $0x8,%dh
  800edc:	75 14                	jne    800ef2 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	68 cc 27 80 00       	push   $0x8027cc
  800ee6:	6a 21                	push   $0x21
  800ee8:	68 5f 28 80 00       	push   $0x80285f
  800eed:	e8 52 f3 ff ff       	call   800244 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800ef2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ef7:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	6a 07                	push   $0x7
  800efe:	68 00 f0 7f 00       	push   $0x7ff000
  800f03:	6a 00                	push   $0x0
  800f05:	e8 a3 fd ff ff       	call   800cad <sys_page_alloc>
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	79 14                	jns    800f25 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	68 6a 28 80 00       	push   $0x80286a
  800f19:	6a 2b                	push   $0x2b
  800f1b:	68 5f 28 80 00       	push   $0x80285f
  800f20:	e8 1f f3 ff ff       	call   800244 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	68 00 10 00 00       	push   $0x1000
  800f2d:	53                   	push   %ebx
  800f2e:	68 00 f0 7f 00       	push   $0x7ff000
  800f33:	e8 fe fa ff ff       	call   800a36 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800f38:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f3f:	53                   	push   %ebx
  800f40:	6a 00                	push   $0x0
  800f42:	68 00 f0 7f 00       	push   $0x7ff000
  800f47:	6a 00                	push   $0x0
  800f49:	e8 a2 fd ff ff       	call   800cf0 <sys_page_map>
  800f4e:	83 c4 20             	add    $0x20,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	79 14                	jns    800f69 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	68 80 28 80 00       	push   $0x802880
  800f5d:	6a 2e                	push   $0x2e
  800f5f:	68 5f 28 80 00       	push   $0x80285f
  800f64:	e8 db f2 ff ff       	call   800244 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	68 00 f0 7f 00       	push   $0x7ff000
  800f71:	6a 00                	push   $0x0
  800f73:	e8 ba fd ff ff       	call   800d32 <sys_page_unmap>
  800f78:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f89:	68 9e 0e 80 00       	push   $0x800e9e
  800f8e:	e8 4c 10 00 00       	call   801fdf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f93:	b8 07 00 00 00       	mov    $0x7,%eax
  800f98:	cd 30                	int    $0x30
  800f9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	79 12                	jns    800fb6 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800fa4:	50                   	push   %eax
  800fa5:	68 94 28 80 00       	push   $0x802894
  800faa:	6a 6d                	push   $0x6d
  800fac:	68 5f 28 80 00       	push   $0x80285f
  800fb1:	e8 8e f2 ff ff       	call   800244 <_panic>
  800fb6:	89 c7                	mov    %eax,%edi
  800fb8:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800fbd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc1:	75 21                	jne    800fe4 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800fc3:	e8 a7 fc ff ff       	call   800c6f <sys_getenvid>
  800fc8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd5:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	e9 9c 01 00 00       	jmp    801180 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 16             	shr    $0x16,%eax
  800fe9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff0:	a8 01                	test   $0x1,%al
  800ff2:	0f 84 f3 00 00 00    	je     8010eb <fork+0x16b>
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
  800ffd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801004:	f6 c2 01             	test   $0x1,%dl
  801007:	0f 84 de 00 00 00    	je     8010eb <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  80100d:	89 c6                	mov    %eax,%esi
  80100f:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801012:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801019:	f6 c6 04             	test   $0x4,%dh
  80101c:	74 37                	je     801055 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  80101e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	25 07 0e 00 00       	and    $0xe07,%eax
  80102d:	50                   	push   %eax
  80102e:	56                   	push   %esi
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	6a 00                	push   $0x0
  801033:	e8 b8 fc ff ff       	call   800cf0 <sys_page_map>
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 89 a8 00 00 00    	jns    8010eb <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  801043:	50                   	push   %eax
  801044:	68 f0 27 80 00       	push   $0x8027f0
  801049:	6a 49                	push   $0x49
  80104b:	68 5f 28 80 00       	push   $0x80285f
  801050:	e8 ef f1 ff ff       	call   800244 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801055:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105c:	f6 c6 08             	test   $0x8,%dh
  80105f:	75 0b                	jne    80106c <fork+0xec>
  801061:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801068:	a8 02                	test   $0x2,%al
  80106a:	74 57                	je     8010c3 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	68 05 08 00 00       	push   $0x805
  801074:	56                   	push   %esi
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	6a 00                	push   $0x0
  801079:	e8 72 fc ff ff       	call   800cf0 <sys_page_map>
  80107e:	83 c4 20             	add    $0x20,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 12                	jns    801097 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  801085:	50                   	push   %eax
  801086:	68 f0 27 80 00       	push   $0x8027f0
  80108b:	6a 4c                	push   $0x4c
  80108d:	68 5f 28 80 00       	push   $0x80285f
  801092:	e8 ad f1 ff ff       	call   800244 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	68 05 08 00 00       	push   $0x805
  80109f:	56                   	push   %esi
  8010a0:	6a 00                	push   $0x0
  8010a2:	56                   	push   %esi
  8010a3:	6a 00                	push   $0x0
  8010a5:	e8 46 fc ff ff       	call   800cf0 <sys_page_map>
  8010aa:	83 c4 20             	add    $0x20,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	79 3a                	jns    8010eb <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  8010b1:	50                   	push   %eax
  8010b2:	68 14 28 80 00       	push   $0x802814
  8010b7:	6a 4e                	push   $0x4e
  8010b9:	68 5f 28 80 00       	push   $0x80285f
  8010be:	e8 81 f1 ff ff       	call   800244 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	6a 05                	push   $0x5
  8010c8:	56                   	push   %esi
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 1e fc ff ff       	call   800cf0 <sys_page_map>
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 12                	jns    8010eb <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  8010d9:	50                   	push   %eax
  8010da:	68 3c 28 80 00       	push   $0x80283c
  8010df:	6a 50                	push   $0x50
  8010e1:	68 5f 28 80 00       	push   $0x80285f
  8010e6:	e8 59 f1 ff ff       	call   800244 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8010eb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f1:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010f7:	0f 85 e7 fe ff ff    	jne    800fe4 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	6a 07                	push   $0x7
  801102:	68 00 f0 bf ee       	push   $0xeebff000
  801107:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110a:	e8 9e fb ff ff       	call   800cad <sys_page_alloc>
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	79 14                	jns    80112a <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	68 a4 28 80 00       	push   $0x8028a4
  80111e:	6a 76                	push   $0x76
  801120:	68 5f 28 80 00       	push   $0x80285f
  801125:	e8 1a f1 ff ff       	call   800244 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	68 4e 20 80 00       	push   $0x80204e
  801132:	ff 75 e4             	pushl  -0x1c(%ebp)
  801135:	e8 be fc ff ff       	call   800df8 <sys_env_set_pgfault_upcall>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 14                	jns    801155 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801141:	ff 75 e4             	pushl  -0x1c(%ebp)
  801144:	68 be 28 80 00       	push   $0x8028be
  801149:	6a 79                	push   $0x79
  80114b:	68 5f 28 80 00       	push   $0x80285f
  801150:	e8 ef f0 ff ff       	call   800244 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801155:	83 ec 08             	sub    $0x8,%esp
  801158:	6a 02                	push   $0x2
  80115a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115d:	e8 12 fc ff ff       	call   800d74 <sys_env_set_status>
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	85 c0                	test   %eax,%eax
  801167:	79 14                	jns    80117d <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801169:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116c:	68 db 28 80 00       	push   $0x8028db
  801171:	6a 7b                	push   $0x7b
  801173:	68 5f 28 80 00       	push   $0x80285f
  801178:	e8 c7 f0 ff ff       	call   800244 <_panic>
        return forkid;
  80117d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <sfork>:

// Challenge!
int
sfork(void)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80118e:	68 f2 28 80 00       	push   $0x8028f2
  801193:	68 83 00 00 00       	push   $0x83
  801198:	68 5f 28 80 00       	push   $0x80285f
  80119d:	e8 a2 f0 ff ff       	call   800244 <_panic>

008011a2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	56                   	push   %esi
  8011a6:	53                   	push   %ebx
  8011a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011b7:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	50                   	push   %eax
  8011be:	e8 9a fc ff ff       	call   800e5d <sys_ipc_recv>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	79 16                	jns    8011e0 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8011ca:	85 f6                	test   %esi,%esi
  8011cc:	74 06                	je     8011d4 <ipc_recv+0x32>
  8011ce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8011d4:	85 db                	test   %ebx,%ebx
  8011d6:	74 2c                	je     801204 <ipc_recv+0x62>
  8011d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011de:	eb 24                	jmp    801204 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8011e0:	85 f6                	test   %esi,%esi
  8011e2:	74 0a                	je     8011ee <ipc_recv+0x4c>
  8011e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e9:	8b 40 74             	mov    0x74(%eax),%eax
  8011ec:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8011ee:	85 db                	test   %ebx,%ebx
  8011f0:	74 0a                	je     8011fc <ipc_recv+0x5a>
  8011f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f7:	8b 40 78             	mov    0x78(%eax),%eax
  8011fa:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8011fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801201:	8b 40 70             	mov    0x70(%eax),%eax
}
  801204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	57                   	push   %edi
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 0c             	sub    $0xc,%esp
  801214:	8b 7d 08             	mov    0x8(%ebp),%edi
  801217:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80121d:	85 db                	test   %ebx,%ebx
  80121f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801224:	0f 44 d8             	cmove  %eax,%ebx
  801227:	eb 1c                	jmp    801245 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801229:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80122c:	74 12                	je     801240 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80122e:	50                   	push   %eax
  80122f:	68 08 29 80 00       	push   $0x802908
  801234:	6a 39                	push   $0x39
  801236:	68 23 29 80 00       	push   $0x802923
  80123b:	e8 04 f0 ff ff       	call   800244 <_panic>
                 sys_yield();
  801240:	e8 49 fa ff ff       	call   800c8e <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801245:	ff 75 14             	pushl  0x14(%ebp)
  801248:	53                   	push   %ebx
  801249:	56                   	push   %esi
  80124a:	57                   	push   %edi
  80124b:	e8 ea fb ff ff       	call   800e3a <sys_ipc_try_send>
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 d2                	js     801229 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80126a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80126d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801273:	8b 52 50             	mov    0x50(%edx),%edx
  801276:	39 ca                	cmp    %ecx,%edx
  801278:	75 0d                	jne    801287 <ipc_find_env+0x28>
			return envs[i].env_id;
  80127a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80127d:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801282:	8b 40 08             	mov    0x8(%eax),%eax
  801285:	eb 0e                	jmp    801295 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801287:	83 c0 01             	add    $0x1,%eax
  80128a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80128f:	75 d9                	jne    80126a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801291:	66 b8 00 00          	mov    $0x0,%ax
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a2:	c1 e8 0c             	shr    $0xc,%eax
}
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8012b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012b7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 11                	je     8012eb <fd_alloc+0x2d>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	75 09                	jne    8012f4 <fd_alloc+0x36>
			*fd_store = fd;
  8012eb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	eb 17                	jmp    80130b <fd_alloc+0x4d>
  8012f4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012f9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012fe:	75 c9                	jne    8012c9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801300:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801306:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801313:	83 f8 1f             	cmp    $0x1f,%eax
  801316:	77 36                	ja     80134e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801318:	c1 e0 0c             	shl    $0xc,%eax
  80131b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801320:	89 c2                	mov    %eax,%edx
  801322:	c1 ea 16             	shr    $0x16,%edx
  801325:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80132c:	f6 c2 01             	test   $0x1,%dl
  80132f:	74 24                	je     801355 <fd_lookup+0x48>
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 0c             	shr    $0xc,%edx
  801336:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 1a                	je     80135c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
  801345:	89 02                	mov    %eax,(%edx)
	return 0;
  801347:	b8 00 00 00 00       	mov    $0x0,%eax
  80134c:	eb 13                	jmp    801361 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801353:	eb 0c                	jmp    801361 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135a:	eb 05                	jmp    801361 <fd_lookup+0x54>
  80135c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136c:	ba ac 29 80 00       	mov    $0x8029ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801371:	eb 13                	jmp    801386 <dev_lookup+0x23>
  801373:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801376:	39 08                	cmp    %ecx,(%eax)
  801378:	75 0c                	jne    801386 <dev_lookup+0x23>
			*dev = devtab[i];
  80137a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
  801384:	eb 2e                	jmp    8013b4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801386:	8b 02                	mov    (%edx),%eax
  801388:	85 c0                	test   %eax,%eax
  80138a:	75 e7                	jne    801373 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80138c:	a1 04 40 80 00       	mov    0x804004,%eax
  801391:	8b 40 48             	mov    0x48(%eax),%eax
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	51                   	push   %ecx
  801398:	50                   	push   %eax
  801399:	68 30 29 80 00       	push   $0x802930
  80139e:	e8 7a ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  8013a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 10             	sub    $0x10,%esp
  8013be:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c7:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ce:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d1:	50                   	push   %eax
  8013d2:	e8 36 ff ff ff       	call   80130d <fd_lookup>
  8013d7:	83 c4 08             	add    $0x8,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 05                	js     8013e3 <fd_close+0x2d>
	    || fd != fd2)
  8013de:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013e1:	74 0c                	je     8013ef <fd_close+0x39>
		return (must_exist ? r : 0);
  8013e3:	84 db                	test   %bl,%bl
  8013e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ea:	0f 44 c2             	cmove  %edx,%eax
  8013ed:	eb 41                	jmp    801430 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 36                	pushl  (%esi)
  8013f8:	e8 66 ff ff ff       	call   801363 <dev_lookup>
  8013fd:	89 c3                	mov    %eax,%ebx
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 1a                	js     801420 <fd_close+0x6a>
		if (dev->dev_close)
  801406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801409:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80140c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801411:	85 c0                	test   %eax,%eax
  801413:	74 0b                	je     801420 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	56                   	push   %esi
  801419:	ff d0                	call   *%eax
  80141b:	89 c3                	mov    %eax,%ebx
  80141d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	56                   	push   %esi
  801424:	6a 00                	push   $0x0
  801426:	e8 07 f9 ff ff       	call   800d32 <sys_page_unmap>
	return r;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	89 d8                	mov    %ebx,%eax
}
  801430:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	ff 75 08             	pushl  0x8(%ebp)
  801444:	e8 c4 fe ff ff       	call   80130d <fd_lookup>
  801449:	89 c2                	mov    %eax,%edx
  80144b:	83 c4 08             	add    $0x8,%esp
  80144e:	85 d2                	test   %edx,%edx
  801450:	78 10                	js     801462 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	6a 01                	push   $0x1
  801457:	ff 75 f4             	pushl  -0xc(%ebp)
  80145a:	e8 57 ff ff ff       	call   8013b6 <fd_close>
  80145f:	83 c4 10             	add    $0x10,%esp
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <close_all>:

void
close_all(void)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80146b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801470:	83 ec 0c             	sub    $0xc,%esp
  801473:	53                   	push   %ebx
  801474:	e8 be ff ff ff       	call   801437 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801479:	83 c3 01             	add    $0x1,%ebx
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	83 fb 20             	cmp    $0x20,%ebx
  801482:	75 ec                	jne    801470 <close_all+0xc>
		close(i);
}
  801484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	57                   	push   %edi
  80148d:	56                   	push   %esi
  80148e:	53                   	push   %ebx
  80148f:	83 ec 2c             	sub    $0x2c,%esp
  801492:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801495:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 6c fe ff ff       	call   80130d <fd_lookup>
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	85 d2                	test   %edx,%edx
  8014a8:	0f 88 c1 00 00 00    	js     80156f <dup+0xe6>
		return r;
	close(newfdnum);
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	56                   	push   %esi
  8014b2:	e8 80 ff ff ff       	call   801437 <close>

	newfd = INDEX2FD(newfdnum);
  8014b7:	89 f3                	mov    %esi,%ebx
  8014b9:	c1 e3 0c             	shl    $0xc,%ebx
  8014bc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014c2:	83 c4 04             	add    $0x4,%esp
  8014c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c8:	e8 da fd ff ff       	call   8012a7 <fd2data>
  8014cd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014cf:	89 1c 24             	mov    %ebx,(%esp)
  8014d2:	e8 d0 fd ff ff       	call   8012a7 <fd2data>
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014dd:	89 f8                	mov    %edi,%eax
  8014df:	c1 e8 16             	shr    $0x16,%eax
  8014e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e9:	a8 01                	test   $0x1,%al
  8014eb:	74 37                	je     801524 <dup+0x9b>
  8014ed:	89 f8                	mov    %edi,%eax
  8014ef:	c1 e8 0c             	shr    $0xc,%eax
  8014f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f9:	f6 c2 01             	test   $0x1,%dl
  8014fc:	74 26                	je     801524 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	25 07 0e 00 00       	and    $0xe07,%eax
  80150d:	50                   	push   %eax
  80150e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801511:	6a 00                	push   $0x0
  801513:	57                   	push   %edi
  801514:	6a 00                	push   $0x0
  801516:	e8 d5 f7 ff ff       	call   800cf0 <sys_page_map>
  80151b:	89 c7                	mov    %eax,%edi
  80151d:	83 c4 20             	add    $0x20,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 2e                	js     801552 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801527:	89 d0                	mov    %edx,%eax
  801529:	c1 e8 0c             	shr    $0xc,%eax
  80152c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	25 07 0e 00 00       	and    $0xe07,%eax
  80153b:	50                   	push   %eax
  80153c:	53                   	push   %ebx
  80153d:	6a 00                	push   $0x0
  80153f:	52                   	push   %edx
  801540:	6a 00                	push   $0x0
  801542:	e8 a9 f7 ff ff       	call   800cf0 <sys_page_map>
  801547:	89 c7                	mov    %eax,%edi
  801549:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80154c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154e:	85 ff                	test   %edi,%edi
  801550:	79 1d                	jns    80156f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	53                   	push   %ebx
  801556:	6a 00                	push   $0x0
  801558:	e8 d5 f7 ff ff       	call   800d32 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	ff 75 d4             	pushl  -0x2c(%ebp)
  801563:	6a 00                	push   $0x0
  801565:	e8 c8 f7 ff ff       	call   800d32 <sys_page_unmap>
	return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	89 f8                	mov    %edi,%eax
}
  80156f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    

00801577 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	53                   	push   %ebx
  80157b:	83 ec 14             	sub    $0x14,%esp
  80157e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801581:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	53                   	push   %ebx
  801586:	e8 82 fd ff ff       	call   80130d <fd_lookup>
  80158b:	83 c4 08             	add    $0x8,%esp
  80158e:	89 c2                	mov    %eax,%edx
  801590:	85 c0                	test   %eax,%eax
  801592:	78 6d                	js     801601 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	ff 30                	pushl  (%eax)
  8015a0:	e8 be fd ff ff       	call   801363 <dev_lookup>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 4c                	js     8015f8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015af:	8b 42 08             	mov    0x8(%edx),%eax
  8015b2:	83 e0 03             	and    $0x3,%eax
  8015b5:	83 f8 01             	cmp    $0x1,%eax
  8015b8:	75 21                	jne    8015db <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bf:	8b 40 48             	mov    0x48(%eax),%eax
  8015c2:	83 ec 04             	sub    $0x4,%esp
  8015c5:	53                   	push   %ebx
  8015c6:	50                   	push   %eax
  8015c7:	68 71 29 80 00       	push   $0x802971
  8015cc:	e8 4c ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d9:	eb 26                	jmp    801601 <read+0x8a>
	}
	if (!dev->dev_read)
  8015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015de:	8b 40 08             	mov    0x8(%eax),%eax
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	74 17                	je     8015fc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	ff 75 10             	pushl  0x10(%ebp)
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	52                   	push   %edx
  8015ef:	ff d0                	call   *%eax
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	eb 09                	jmp    801601 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	eb 05                	jmp    801601 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801601:	89 d0                	mov    %edx,%eax
  801603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	57                   	push   %edi
  80160c:	56                   	push   %esi
  80160d:	53                   	push   %ebx
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	8b 7d 08             	mov    0x8(%ebp),%edi
  801614:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801617:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161c:	eb 21                	jmp    80163f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	89 f0                	mov    %esi,%eax
  801623:	29 d8                	sub    %ebx,%eax
  801625:	50                   	push   %eax
  801626:	89 d8                	mov    %ebx,%eax
  801628:	03 45 0c             	add    0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	57                   	push   %edi
  80162d:	e8 45 ff ff ff       	call   801577 <read>
		if (m < 0)
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 0c                	js     801645 <readn+0x3d>
			return m;
		if (m == 0)
  801639:	85 c0                	test   %eax,%eax
  80163b:	74 06                	je     801643 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80163d:	01 c3                	add    %eax,%ebx
  80163f:	39 f3                	cmp    %esi,%ebx
  801641:	72 db                	jb     80161e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801643:	89 d8                	mov    %ebx,%eax
}
  801645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801648:	5b                   	pop    %ebx
  801649:	5e                   	pop    %esi
  80164a:	5f                   	pop    %edi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	53                   	push   %ebx
  801651:	83 ec 14             	sub    $0x14,%esp
  801654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801657:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	53                   	push   %ebx
  80165c:	e8 ac fc ff ff       	call   80130d <fd_lookup>
  801661:	83 c4 08             	add    $0x8,%esp
  801664:	89 c2                	mov    %eax,%edx
  801666:	85 c0                	test   %eax,%eax
  801668:	78 68                	js     8016d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801674:	ff 30                	pushl  (%eax)
  801676:	e8 e8 fc ff ff       	call   801363 <dev_lookup>
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 47                	js     8016c9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801689:	75 21                	jne    8016ac <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80168b:	a1 04 40 80 00       	mov    0x804004,%eax
  801690:	8b 40 48             	mov    0x48(%eax),%eax
  801693:	83 ec 04             	sub    $0x4,%esp
  801696:	53                   	push   %ebx
  801697:	50                   	push   %eax
  801698:	68 8d 29 80 00       	push   $0x80298d
  80169d:	e8 7b ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016aa:	eb 26                	jmp    8016d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016af:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b2:	85 d2                	test   %edx,%edx
  8016b4:	74 17                	je     8016cd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b6:	83 ec 04             	sub    $0x4,%esp
  8016b9:	ff 75 10             	pushl  0x10(%ebp)
  8016bc:	ff 75 0c             	pushl  0xc(%ebp)
  8016bf:	50                   	push   %eax
  8016c0:	ff d2                	call   *%edx
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	eb 09                	jmp    8016d2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	eb 05                	jmp    8016d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016d2:	89 d0                	mov    %edx,%eax
  8016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 22 fc ff ff       	call   80130d <fd_lookup>
  8016eb:	83 c4 08             	add    $0x8,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 0e                	js     801700 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	83 ec 14             	sub    $0x14,%esp
  801709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	53                   	push   %ebx
  801711:	e8 f7 fb ff ff       	call   80130d <fd_lookup>
  801716:	83 c4 08             	add    $0x8,%esp
  801719:	89 c2                	mov    %eax,%edx
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 65                	js     801784 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801729:	ff 30                	pushl  (%eax)
  80172b:	e8 33 fc ff ff       	call   801363 <dev_lookup>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 44                	js     80177b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173e:	75 21                	jne    801761 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801740:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801745:	8b 40 48             	mov    0x48(%eax),%eax
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	53                   	push   %ebx
  80174c:	50                   	push   %eax
  80174d:	68 50 29 80 00       	push   $0x802950
  801752:	e8 c6 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175f:	eb 23                	jmp    801784 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801761:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801764:	8b 52 18             	mov    0x18(%edx),%edx
  801767:	85 d2                	test   %edx,%edx
  801769:	74 14                	je     80177f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	50                   	push   %eax
  801772:	ff d2                	call   *%edx
  801774:	89 c2                	mov    %eax,%edx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	eb 09                	jmp    801784 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	eb 05                	jmp    801784 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80177f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801784:	89 d0                	mov    %edx,%eax
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	53                   	push   %ebx
  80178f:	83 ec 14             	sub    $0x14,%esp
  801792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801795:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	ff 75 08             	pushl  0x8(%ebp)
  80179c:	e8 6c fb ff ff       	call   80130d <fd_lookup>
  8017a1:	83 c4 08             	add    $0x8,%esp
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 58                	js     801802 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b4:	ff 30                	pushl  (%eax)
  8017b6:	e8 a8 fb ff ff       	call   801363 <dev_lookup>
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 37                	js     8017f9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c9:	74 32                	je     8017fd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d5:	00 00 00 
	stat->st_isdir = 0;
  8017d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017df:	00 00 00 
	stat->st_dev = dev;
  8017e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	53                   	push   %ebx
  8017ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ef:	ff 50 14             	call   *0x14(%eax)
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	eb 09                	jmp    801802 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	eb 05                	jmp    801802 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801802:	89 d0                	mov    %edx,%eax
  801804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	6a 00                	push   $0x0
  801813:	ff 75 08             	pushl  0x8(%ebp)
  801816:	e8 09 02 00 00       	call   801a24 <open>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 db                	test   %ebx,%ebx
  801822:	78 1b                	js     80183f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	53                   	push   %ebx
  80182b:	e8 5b ff ff ff       	call   80178b <fstat>
  801830:	89 c6                	mov    %eax,%esi
	close(fd);
  801832:	89 1c 24             	mov    %ebx,(%esp)
  801835:	e8 fd fb ff ff       	call   801437 <close>
	return r;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	89 f0                	mov    %esi,%eax
}
  80183f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	89 c6                	mov    %eax,%esi
  80184d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80184f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801856:	75 12                	jne    80186a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	6a 01                	push   $0x1
  80185d:	e8 fd f9 ff ff       	call   80125f <ipc_find_env>
  801862:	a3 00 40 80 00       	mov    %eax,0x804000
  801867:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186a:	6a 07                	push   $0x7
  80186c:	68 00 50 80 00       	push   $0x805000
  801871:	56                   	push   %esi
  801872:	ff 35 00 40 80 00    	pushl  0x804000
  801878:	e8 8e f9 ff ff       	call   80120b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80187d:	83 c4 0c             	add    $0xc,%esp
  801880:	6a 00                	push   $0x0
  801882:	53                   	push   %ebx
  801883:	6a 00                	push   $0x0
  801885:	e8 18 f9 ff ff       	call   8011a2 <ipc_recv>
}
  80188a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b4:	e8 8d ff ff ff       	call   801846 <fsipc>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d6:	e8 6b ff ff ff       	call   801846 <fsipc>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fc:	e8 45 ff ff ff       	call   801846 <fsipc>
  801901:	89 c2                	mov    %eax,%edx
  801903:	85 d2                	test   %edx,%edx
  801905:	78 2c                	js     801933 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	68 00 50 80 00       	push   $0x805000
  80190f:	53                   	push   %ebx
  801910:	e8 8f ef ff ff       	call   8008a4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801915:	a1 80 50 80 00       	mov    0x805080,%eax
  80191a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801920:	a1 84 50 80 00       	mov    0x805084,%eax
  801925:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	57                   	push   %edi
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	8b 40 0c             	mov    0xc(%eax),%eax
  80194a:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80194f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801952:	eb 3d                	jmp    801991 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801954:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80195a:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80195f:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	57                   	push   %edi
  801966:	53                   	push   %ebx
  801967:	68 08 50 80 00       	push   $0x805008
  80196c:	e8 c5 f0 ff ff       	call   800a36 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801971:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 04 00 00 00       	mov    $0x4,%eax
  801981:	e8 c0 fe ff ff       	call   801846 <fsipc>
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 0d                	js     80199a <devfile_write+0x62>
		        return r;
                n -= tmp;
  80198d:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80198f:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801991:	85 f6                	test   %esi,%esi
  801993:	75 bf                	jne    801954 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801995:	89 d8                	mov    %ebx,%eax
  801997:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80199a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5f                   	pop    %edi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	56                   	push   %esi
  8019a6:	53                   	push   %ebx
  8019a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c5:	e8 7c fe ff ff       	call   801846 <fsipc>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 4b                	js     801a1b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019d0:	39 c6                	cmp    %eax,%esi
  8019d2:	73 16                	jae    8019ea <devfile_read+0x48>
  8019d4:	68 bc 29 80 00       	push   $0x8029bc
  8019d9:	68 c3 29 80 00       	push   $0x8029c3
  8019de:	6a 7c                	push   $0x7c
  8019e0:	68 d8 29 80 00       	push   $0x8029d8
  8019e5:	e8 5a e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  8019ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ef:	7e 16                	jle    801a07 <devfile_read+0x65>
  8019f1:	68 e3 29 80 00       	push   $0x8029e3
  8019f6:	68 c3 29 80 00       	push   $0x8029c3
  8019fb:	6a 7d                	push   $0x7d
  8019fd:	68 d8 29 80 00       	push   $0x8029d8
  801a02:	e8 3d e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	50                   	push   %eax
  801a0b:	68 00 50 80 00       	push   $0x805000
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	e8 1e f0 ff ff       	call   800a36 <memmove>
	return r;
  801a18:	83 c4 10             	add    $0x10,%esp
}
  801a1b:	89 d8                	mov    %ebx,%eax
  801a1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	53                   	push   %ebx
  801a28:	83 ec 20             	sub    $0x20,%esp
  801a2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a2e:	53                   	push   %ebx
  801a2f:	e8 37 ee ff ff       	call   80086b <strlen>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a3c:	7f 67                	jg     801aa5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	e8 74 f8 ff ff       	call   8012be <fd_alloc>
  801a4a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a4d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 57                	js     801aaa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	68 00 50 80 00       	push   $0x805000
  801a5c:	e8 43 ee ff ff       	call   8008a4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a64:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a71:	e8 d0 fd ff ff       	call   801846 <fsipc>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	79 14                	jns    801a93 <open+0x6f>
		fd_close(fd, 0);
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	6a 00                	push   $0x0
  801a84:	ff 75 f4             	pushl  -0xc(%ebp)
  801a87:	e8 2a f9 ff ff       	call   8013b6 <fd_close>
		return r;
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	89 da                	mov    %ebx,%edx
  801a91:	eb 17                	jmp    801aaa <open+0x86>
	}

	return fd2num(fd);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	ff 75 f4             	pushl  -0xc(%ebp)
  801a99:	e8 f9 f7 ff ff       	call   801297 <fd2num>
  801a9e:	89 c2                	mov    %eax,%edx
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb 05                	jmp    801aaa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aa5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aaa:	89 d0                	mov    %edx,%eax
  801aac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ab7:	ba 00 00 00 00       	mov    $0x0,%edx
  801abc:	b8 08 00 00 00       	mov    $0x8,%eax
  801ac1:	e8 80 fd ff ff       	call   801846 <fsipc>
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ace:	89 d0                	mov    %edx,%eax
  801ad0:	c1 e8 16             	shr    $0x16,%eax
  801ad3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801adf:	f6 c1 01             	test   $0x1,%cl
  801ae2:	74 1d                	je     801b01 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae4:	c1 ea 0c             	shr    $0xc,%edx
  801ae7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801aee:	f6 c2 01             	test   $0x1,%dl
  801af1:	74 0e                	je     801b01 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af3:	c1 ea 0c             	shr    $0xc,%edx
  801af6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801afd:	ef 
  801afe:	0f b7 c0             	movzwl %ax,%eax
}
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	56                   	push   %esi
  801b07:	53                   	push   %ebx
  801b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 08             	pushl  0x8(%ebp)
  801b11:	e8 91 f7 ff ff       	call   8012a7 <fd2data>
  801b16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b18:	83 c4 08             	add    $0x8,%esp
  801b1b:	68 ef 29 80 00       	push   $0x8029ef
  801b20:	53                   	push   %ebx
  801b21:	e8 7e ed ff ff       	call   8008a4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b26:	8b 56 04             	mov    0x4(%esi),%edx
  801b29:	89 d0                	mov    %edx,%eax
  801b2b:	2b 06                	sub    (%esi),%eax
  801b2d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b33:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3a:	00 00 00 
	stat->st_dev = &devpipe;
  801b3d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b44:	30 80 00 
	return 0;
}
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5d:	53                   	push   %ebx
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 cd f1 ff ff       	call   800d32 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b65:	89 1c 24             	mov    %ebx,(%esp)
  801b68:	e8 3a f7 ff ff       	call   8012a7 <fd2data>
  801b6d:	83 c4 08             	add    $0x8,%esp
  801b70:	50                   	push   %eax
  801b71:	6a 00                	push   $0x0
  801b73:	e8 ba f1 ff ff       	call   800d32 <sys_page_unmap>
}
  801b78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	57                   	push   %edi
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	83 ec 1c             	sub    $0x1c,%esp
  801b86:	89 c6                	mov    %eax,%esi
  801b88:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b90:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	56                   	push   %esi
  801b97:	e8 2c ff ff ff       	call   801ac8 <pageref>
  801b9c:	89 c7                	mov    %eax,%edi
  801b9e:	83 c4 04             	add    $0x4,%esp
  801ba1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba4:	e8 1f ff ff ff       	call   801ac8 <pageref>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	39 c7                	cmp    %eax,%edi
  801bae:	0f 94 c2             	sete   %dl
  801bb1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801bb4:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801bba:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801bbd:	39 fb                	cmp    %edi,%ebx
  801bbf:	74 19                	je     801bda <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801bc1:	84 d2                	test   %dl,%dl
  801bc3:	74 c6                	je     801b8b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc5:	8b 51 58             	mov    0x58(%ecx),%edx
  801bc8:	50                   	push   %eax
  801bc9:	52                   	push   %edx
  801bca:	53                   	push   %ebx
  801bcb:	68 f6 29 80 00       	push   $0x8029f6
  801bd0:	e8 48 e7 ff ff       	call   80031d <cprintf>
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	eb b1                	jmp    801b8b <_pipeisclosed+0xe>
	}
}
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	57                   	push   %edi
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	83 ec 28             	sub    $0x28,%esp
  801beb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bee:	56                   	push   %esi
  801bef:	e8 b3 f6 ff ff       	call   8012a7 <fd2data>
  801bf4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	bf 00 00 00 00       	mov    $0x0,%edi
  801bfe:	eb 4b                	jmp    801c4b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c00:	89 da                	mov    %ebx,%edx
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	e8 74 ff ff ff       	call   801b7d <_pipeisclosed>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	75 48                	jne    801c55 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c0d:	e8 7c f0 ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c12:	8b 43 04             	mov    0x4(%ebx),%eax
  801c15:	8b 0b                	mov    (%ebx),%ecx
  801c17:	8d 51 20             	lea    0x20(%ecx),%edx
  801c1a:	39 d0                	cmp    %edx,%eax
  801c1c:	73 e2                	jae    801c00 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c21:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c25:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	c1 fa 1f             	sar    $0x1f,%edx
  801c2d:	89 d1                	mov    %edx,%ecx
  801c2f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c32:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c35:	83 e2 1f             	and    $0x1f,%edx
  801c38:	29 ca                	sub    %ecx,%edx
  801c3a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c42:	83 c0 01             	add    $0x1,%eax
  801c45:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c48:	83 c7 01             	add    $0x1,%edi
  801c4b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c4e:	75 c2                	jne    801c12 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c50:	8b 45 10             	mov    0x10(%ebp),%eax
  801c53:	eb 05                	jmp    801c5a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 18             	sub    $0x18,%esp
  801c6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c6e:	57                   	push   %edi
  801c6f:	e8 33 f6 ff ff       	call   8012a7 <fd2data>
  801c74:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7e:	eb 3d                	jmp    801cbd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c80:	85 db                	test   %ebx,%ebx
  801c82:	74 04                	je     801c88 <devpipe_read+0x26>
				return i;
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	eb 44                	jmp    801ccc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	89 f8                	mov    %edi,%eax
  801c8c:	e8 ec fe ff ff       	call   801b7d <_pipeisclosed>
  801c91:	85 c0                	test   %eax,%eax
  801c93:	75 32                	jne    801cc7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c95:	e8 f4 ef ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c9a:	8b 06                	mov    (%esi),%eax
  801c9c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c9f:	74 df                	je     801c80 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca1:	99                   	cltd   
  801ca2:	c1 ea 1b             	shr    $0x1b,%edx
  801ca5:	01 d0                	add    %edx,%eax
  801ca7:	83 e0 1f             	and    $0x1f,%eax
  801caa:	29 d0                	sub    %edx,%eax
  801cac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cb7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cba:	83 c3 01             	add    $0x1,%ebx
  801cbd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc0:	75 d8                	jne    801c9a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc5:	eb 05                	jmp    801ccc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	e8 d9 f5 ff ff       	call   8012be <fd_alloc>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	89 c2                	mov    %eax,%edx
  801cea:	85 c0                	test   %eax,%eax
  801cec:	0f 88 2c 01 00 00    	js     801e1e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	68 07 04 00 00       	push   $0x407
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 a9 ef ff ff       	call   800cad <sys_page_alloc>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	89 c2                	mov    %eax,%edx
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 0d 01 00 00    	js     801e1e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	e8 a1 f5 ff ff       	call   8012be <fd_alloc>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	0f 88 e2 00 00 00    	js     801e0c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2a:	83 ec 04             	sub    $0x4,%esp
  801d2d:	68 07 04 00 00       	push   $0x407
  801d32:	ff 75 f0             	pushl  -0x10(%ebp)
  801d35:	6a 00                	push   $0x0
  801d37:	e8 71 ef ff ff       	call   800cad <sys_page_alloc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	0f 88 c3 00 00 00    	js     801e0c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4f:	e8 53 f5 ff ff       	call   8012a7 <fd2data>
  801d54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d56:	83 c4 0c             	add    $0xc,%esp
  801d59:	68 07 04 00 00       	push   $0x407
  801d5e:	50                   	push   %eax
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 47 ef ff ff       	call   800cad <sys_page_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	0f 88 89 00 00 00    	js     801dfc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 f0             	pushl  -0x10(%ebp)
  801d79:	e8 29 f5 ff ff       	call   8012a7 <fd2data>
  801d7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d85:	50                   	push   %eax
  801d86:	6a 00                	push   $0x0
  801d88:	56                   	push   %esi
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 60 ef ff ff       	call   800cf0 <sys_page_map>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	83 c4 20             	add    $0x20,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 55                	js     801dee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc9:	e8 c9 f4 ff ff       	call   801297 <fd2num>
  801dce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd3:	83 c4 04             	add    $0x4,%esp
  801dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd9:	e8 b9 f4 ff ff       	call   801297 <fd2num>
  801dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dec:	eb 30                	jmp    801e1e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dee:	83 ec 08             	sub    $0x8,%esp
  801df1:	56                   	push   %esi
  801df2:	6a 00                	push   $0x0
  801df4:	e8 39 ef ff ff       	call   800d32 <sys_page_unmap>
  801df9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	ff 75 f0             	pushl  -0x10(%ebp)
  801e02:	6a 00                	push   $0x0
  801e04:	e8 29 ef ff ff       	call   800d32 <sys_page_unmap>
  801e09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e12:	6a 00                	push   $0x0
  801e14:	e8 19 ef ff ff       	call   800d32 <sys_page_unmap>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e1e:	89 d0                	mov    %edx,%eax
  801e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	ff 75 08             	pushl  0x8(%ebp)
  801e34:	e8 d4 f4 ff ff       	call   80130d <fd_lookup>
  801e39:	89 c2                	mov    %eax,%edx
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	85 d2                	test   %edx,%edx
  801e40:	78 18                	js     801e5a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	ff 75 f4             	pushl  -0xc(%ebp)
  801e48:	e8 5a f4 ff ff       	call   8012a7 <fd2data>
	return _pipeisclosed(fd, p);
  801e4d:	89 c2                	mov    %eax,%edx
  801e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e52:	e8 26 fd ff ff       	call   801b7d <_pipeisclosed>
  801e57:	83 c4 10             	add    $0x10,%esp
}
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e6c:	68 0e 2a 80 00       	push   $0x802a0e
  801e71:	ff 75 0c             	pushl  0xc(%ebp)
  801e74:	e8 2b ea ff ff       	call   8008a4 <strcpy>
	return 0;
}
  801e79:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e91:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e97:	eb 2d                	jmp    801ec6 <devcons_write+0x46>
		m = n - tot;
  801e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e9c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e9e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ea1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ea6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea9:	83 ec 04             	sub    $0x4,%esp
  801eac:	53                   	push   %ebx
  801ead:	03 45 0c             	add    0xc(%ebp),%eax
  801eb0:	50                   	push   %eax
  801eb1:	57                   	push   %edi
  801eb2:	e8 7f eb ff ff       	call   800a36 <memmove>
		sys_cputs(buf, m);
  801eb7:	83 c4 08             	add    $0x8,%esp
  801eba:	53                   	push   %ebx
  801ebb:	57                   	push   %edi
  801ebc:	e8 30 ed ff ff       	call   800bf1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec1:	01 de                	add    %ebx,%esi
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	89 f0                	mov    %esi,%eax
  801ec8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ecb:	72 cc                	jb     801e99 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ee0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee4:	75 07                	jne    801eed <devcons_read+0x18>
  801ee6:	eb 28                	jmp    801f10 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ee8:	e8 a1 ed ff ff       	call   800c8e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eed:	e8 1d ed ff ff       	call   800c0f <sys_cgetc>
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	74 f2                	je     801ee8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 16                	js     801f10 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801efa:	83 f8 04             	cmp    $0x4,%eax
  801efd:	74 0c                	je     801f0b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f02:	88 02                	mov    %al,(%edx)
	return 1;
  801f04:	b8 01 00 00 00       	mov    $0x1,%eax
  801f09:	eb 05                	jmp    801f10 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f1e:	6a 01                	push   $0x1
  801f20:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f23:	50                   	push   %eax
  801f24:	e8 c8 ec ff ff       	call   800bf1 <sys_cputs>
  801f29:	83 c4 10             	add    $0x10,%esp
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <getchar>:

int
getchar(void)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f34:	6a 01                	push   $0x1
  801f36:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f39:	50                   	push   %eax
  801f3a:	6a 00                	push   $0x0
  801f3c:	e8 36 f6 ff ff       	call   801577 <read>
	if (r < 0)
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 0f                	js     801f57 <getchar+0x29>
		return r;
	if (r < 1)
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	7e 06                	jle    801f52 <getchar+0x24>
		return -E_EOF;
	return c;
  801f4c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f50:	eb 05                	jmp    801f57 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f52:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	ff 75 08             	pushl  0x8(%ebp)
  801f66:	e8 a2 f3 ff ff       	call   80130d <fd_lookup>
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 11                	js     801f83 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f75:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f7b:	39 10                	cmp    %edx,(%eax)
  801f7d:	0f 94 c0             	sete   %al
  801f80:	0f b6 c0             	movzbl %al,%eax
}
  801f83:	c9                   	leave  
  801f84:	c3                   	ret    

00801f85 <opencons>:

int
opencons(void)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8e:	50                   	push   %eax
  801f8f:	e8 2a f3 ff ff       	call   8012be <fd_alloc>
  801f94:	83 c4 10             	add    $0x10,%esp
		return r;
  801f97:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	78 3e                	js     801fdb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9d:	83 ec 04             	sub    $0x4,%esp
  801fa0:	68 07 04 00 00       	push   $0x407
  801fa5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa8:	6a 00                	push   $0x0
  801faa:	e8 fe ec ff ff       	call   800cad <sys_page_alloc>
  801faf:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	78 23                	js     801fdb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fcd:	83 ec 0c             	sub    $0xc,%esp
  801fd0:	50                   	push   %eax
  801fd1:	e8 c1 f2 ff ff       	call   801297 <fd2num>
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	83 c4 10             	add    $0x10,%esp
}
  801fdb:	89 d0                	mov    %edx,%eax
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fe5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fec:	75 2c                	jne    80201a <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801fee:	83 ec 04             	sub    $0x4,%esp
  801ff1:	6a 07                	push   $0x7
  801ff3:	68 00 f0 bf ee       	push   $0xeebff000
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 ae ec ff ff       	call   800cad <sys_page_alloc>
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	74 14                	je     80201a <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802006:	83 ec 04             	sub    $0x4,%esp
  802009:	68 1c 2a 80 00       	push   $0x802a1c
  80200e:	6a 21                	push   $0x21
  802010:	68 80 2a 80 00       	push   $0x802a80
  802015:	e8 2a e2 ff ff       	call   800244 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80201a:	8b 45 08             	mov    0x8(%ebp),%eax
  80201d:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802022:	83 ec 08             	sub    $0x8,%esp
  802025:	68 4e 20 80 00       	push   $0x80204e
  80202a:	6a 00                	push   $0x0
  80202c:	e8 c7 ed ff ff       	call   800df8 <sys_env_set_pgfault_upcall>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	79 14                	jns    80204c <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	68 48 2a 80 00       	push   $0x802a48
  802040:	6a 29                	push   $0x29
  802042:	68 80 2a 80 00       	push   $0x802a80
  802047:	e8 f8 e1 ff ff       	call   800244 <_panic>
}
  80204c:	c9                   	leave  
  80204d:	c3                   	ret    

0080204e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80204e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80204f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802054:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802056:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802059:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80205e:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802062:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802066:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802068:	83 c4 08             	add    $0x8,%esp
        popal
  80206b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80206c:	83 c4 04             	add    $0x4,%esp
        popfl
  80206f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802070:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802071:	c3                   	ret    
  802072:	66 90                	xchg   %ax,%ax
  802074:	66 90                	xchg   %ax,%ax
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	83 ec 10             	sub    $0x10,%esp
  802086:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80208a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80208e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802092:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802096:	85 d2                	test   %edx,%edx
  802098:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209c:	89 34 24             	mov    %esi,(%esp)
  80209f:	89 c8                	mov    %ecx,%eax
  8020a1:	75 35                	jne    8020d8 <__udivdi3+0x58>
  8020a3:	39 f1                	cmp    %esi,%ecx
  8020a5:	0f 87 bd 00 00 00    	ja     802168 <__udivdi3+0xe8>
  8020ab:	85 c9                	test   %ecx,%ecx
  8020ad:	89 cd                	mov    %ecx,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f1                	div    %ecx
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 f0                	mov    %esi,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c6                	mov    %eax,%esi
  8020c4:	89 f8                	mov    %edi,%eax
  8020c6:	f7 f5                	div    %ebp
  8020c8:	89 f2                	mov    %esi,%edx
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	5e                   	pop    %esi
  8020ce:	5f                   	pop    %edi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    
  8020d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	3b 14 24             	cmp    (%esp),%edx
  8020db:	77 7b                	ja     802158 <__udivdi3+0xd8>
  8020dd:	0f bd f2             	bsr    %edx,%esi
  8020e0:	83 f6 1f             	xor    $0x1f,%esi
  8020e3:	0f 84 97 00 00 00    	je     802180 <__udivdi3+0x100>
  8020e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ee:	89 d7                	mov    %edx,%edi
  8020f0:	89 f1                	mov    %esi,%ecx
  8020f2:	29 f5                	sub    %esi,%ebp
  8020f4:	d3 e7                	shl    %cl,%edi
  8020f6:	89 c2                	mov    %eax,%edx
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	d3 ea                	shr    %cl,%edx
  8020fc:	89 f1                	mov    %esi,%ecx
  8020fe:	09 fa                	or     %edi,%edx
  802100:	8b 3c 24             	mov    (%esp),%edi
  802103:	d3 e0                	shl    %cl,%eax
  802105:	89 54 24 08          	mov    %edx,0x8(%esp)
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802113:	89 fa                	mov    %edi,%edx
  802115:	d3 ea                	shr    %cl,%edx
  802117:	89 f1                	mov    %esi,%ecx
  802119:	d3 e7                	shl    %cl,%edi
  80211b:	89 e9                	mov    %ebp,%ecx
  80211d:	d3 e8                	shr    %cl,%eax
  80211f:	09 c7                	or     %eax,%edi
  802121:	89 f8                	mov    %edi,%eax
  802123:	f7 74 24 08          	divl   0x8(%esp)
  802127:	89 d5                	mov    %edx,%ebp
  802129:	89 c7                	mov    %eax,%edi
  80212b:	f7 64 24 0c          	mull   0xc(%esp)
  80212f:	39 d5                	cmp    %edx,%ebp
  802131:	89 14 24             	mov    %edx,(%esp)
  802134:	72 11                	jb     802147 <__udivdi3+0xc7>
  802136:	8b 54 24 04          	mov    0x4(%esp),%edx
  80213a:	89 f1                	mov    %esi,%ecx
  80213c:	d3 e2                	shl    %cl,%edx
  80213e:	39 c2                	cmp    %eax,%edx
  802140:	73 5e                	jae    8021a0 <__udivdi3+0x120>
  802142:	3b 2c 24             	cmp    (%esp),%ebp
  802145:	75 59                	jne    8021a0 <__udivdi3+0x120>
  802147:	8d 47 ff             	lea    -0x1(%edi),%eax
  80214a:	31 f6                	xor    %esi,%esi
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	31 f6                	xor    %esi,%esi
  80215a:	31 c0                	xor    %eax,%eax
  80215c:	89 f2                	mov    %esi,%edx
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	89 f2                	mov    %esi,%edx
  80216a:	31 f6                	xor    %esi,%esi
  80216c:	89 f8                	mov    %edi,%eax
  80216e:	f7 f1                	div    %ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802184:	76 0b                	jbe    802191 <__udivdi3+0x111>
  802186:	31 c0                	xor    %eax,%eax
  802188:	3b 14 24             	cmp    (%esp),%edx
  80218b:	0f 83 37 ff ff ff    	jae    8020c8 <__udivdi3+0x48>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	e9 2d ff ff ff       	jmp    8020c8 <__udivdi3+0x48>
  80219b:	90                   	nop
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 f8                	mov    %edi,%eax
  8021a2:	31 f6                	xor    %esi,%esi
  8021a4:	e9 1f ff ff ff       	jmp    8020c8 <__udivdi3+0x48>
  8021a9:	66 90                	xchg   %ax,%ax
  8021ab:	66 90                	xchg   %ax,%ax
  8021ad:	66 90                	xchg   %ax,%ax
  8021af:	90                   	nop

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	83 ec 20             	sub    $0x20,%esp
  8021b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c2:	89 c6                	mov    %eax,%esi
  8021c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	75 1e                	jne    802200 <__umoddi3+0x50>
  8021e2:	39 f7                	cmp    %esi,%edi
  8021e4:	76 52                	jbe    802238 <__umoddi3+0x88>
  8021e6:	89 c8                	mov    %ecx,%eax
  8021e8:	89 f2                	mov    %esi,%edx
  8021ea:	f7 f7                	div    %edi
  8021ec:	89 d0                	mov    %edx,%eax
  8021ee:	31 d2                	xor    %edx,%edx
  8021f0:	83 c4 20             	add    $0x20,%esp
  8021f3:	5e                   	pop    %esi
  8021f4:	5f                   	pop    %edi
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    
  8021f7:	89 f6                	mov    %esi,%esi
  8021f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802200:	39 f0                	cmp    %esi,%eax
  802202:	77 5c                	ja     802260 <__umoddi3+0xb0>
  802204:	0f bd e8             	bsr    %eax,%ebp
  802207:	83 f5 1f             	xor    $0x1f,%ebp
  80220a:	75 64                	jne    802270 <__umoddi3+0xc0>
  80220c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802210:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802214:	0f 86 f6 00 00 00    	jbe    802310 <__umoddi3+0x160>
  80221a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80221e:	0f 82 ec 00 00 00    	jb     802310 <__umoddi3+0x160>
  802224:	8b 44 24 14          	mov    0x14(%esp),%eax
  802228:	8b 54 24 18          	mov    0x18(%esp),%edx
  80222c:	83 c4 20             	add    $0x20,%esp
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    
  802233:	90                   	nop
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	85 ff                	test   %edi,%edi
  80223a:	89 fd                	mov    %edi,%ebp
  80223c:	75 0b                	jne    802249 <__umoddi3+0x99>
  80223e:	b8 01 00 00 00       	mov    $0x1,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f7                	div    %edi
  802247:	89 c5                	mov    %eax,%ebp
  802249:	8b 44 24 10          	mov    0x10(%esp),%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	f7 f5                	div    %ebp
  802251:	89 c8                	mov    %ecx,%eax
  802253:	f7 f5                	div    %ebp
  802255:	eb 95                	jmp    8021ec <__umoddi3+0x3c>
  802257:	89 f6                	mov    %esi,%esi
  802259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 20             	add    $0x20,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
  80226b:	90                   	nop
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	b8 20 00 00 00       	mov    $0x20,%eax
  802275:	89 e9                	mov    %ebp,%ecx
  802277:	29 e8                	sub    %ebp,%eax
  802279:	d3 e2                	shl    %cl,%edx
  80227b:	89 c7                	mov    %eax,%edi
  80227d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802281:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 c1                	mov    %eax,%ecx
  80228b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80228f:	09 d1                	or     %edx,%ecx
  802291:	89 fa                	mov    %edi,%edx
  802293:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802297:	89 e9                	mov    %ebp,%ecx
  802299:	d3 e0                	shl    %cl,%eax
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	89 c7                	mov    %eax,%edi
  8022a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022ad:	d3 e6                	shl    %cl,%esi
  8022af:	89 d1                	mov    %edx,%ecx
  8022b1:	89 fa                	mov    %edi,%edx
  8022b3:	d3 e8                	shr    %cl,%eax
  8022b5:	89 e9                	mov    %ebp,%ecx
  8022b7:	09 f0                	or     %esi,%eax
  8022b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022bd:	f7 74 24 10          	divl   0x10(%esp)
  8022c1:	d3 e6                	shl    %cl,%esi
  8022c3:	89 d1                	mov    %edx,%ecx
  8022c5:	f7 64 24 0c          	mull   0xc(%esp)
  8022c9:	39 d1                	cmp    %edx,%ecx
  8022cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022cf:	89 d7                	mov    %edx,%edi
  8022d1:	89 c6                	mov    %eax,%esi
  8022d3:	72 0a                	jb     8022df <__umoddi3+0x12f>
  8022d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022d9:	73 10                	jae    8022eb <__umoddi3+0x13b>
  8022db:	39 d1                	cmp    %edx,%ecx
  8022dd:	75 0c                	jne    8022eb <__umoddi3+0x13b>
  8022df:	89 d7                	mov    %edx,%edi
  8022e1:	89 c6                	mov    %eax,%esi
  8022e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022eb:	89 ca                	mov    %ecx,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022f3:	29 f0                	sub    %esi,%eax
  8022f5:	19 fa                	sbb    %edi,%edx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022fe:	89 d7                	mov    %edx,%edi
  802300:	d3 e7                	shl    %cl,%edi
  802302:	89 e9                	mov    %ebp,%ecx
  802304:	09 f8                	or     %edi,%eax
  802306:	d3 ea                	shr    %cl,%edx
  802308:	83 c4 20             	add    $0x20,%esp
  80230b:	5e                   	pop    %esi
  80230c:	5f                   	pop    %edi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    
  80230f:	90                   	nop
  802310:	8b 74 24 10          	mov    0x10(%esp),%esi
  802314:	29 f9                	sub    %edi,%ecx
  802316:	19 c6                	sbb    %eax,%esi
  802318:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80231c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802320:	e9 ff fe ff ff       	jmp    802224 <__umoddi3+0x74>
