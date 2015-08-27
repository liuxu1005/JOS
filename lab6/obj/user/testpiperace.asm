
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
  80003b:	68 40 28 80 00       	push   $0x802840
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 9b 21 00 00       	call   8021eb <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 59 28 80 00       	push   $0x802859
  80005d:	6a 0d                	push   $0xd
  80005f:	68 62 28 80 00       	push   $0x802862
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 b3 0f 00 00       	call   801021 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 9b 2d 80 00       	push   $0x802d9b
  80007a:	6a 10                	push   $0x10
  80007c:	68 62 28 80 00       	push   $0x802862
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 48 14 00 00       	call   8014dd <close>
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
  8000a3:	e8 96 22 00 00       	call   80233e <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 76 28 80 00       	push   $0x802876
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
  8000d7:	e8 67 11 00 00       	call   801243 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 91 28 80 00       	push   $0x802891
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
  800103:	68 9c 28 80 00       	push   $0x80289c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 15 14 00 00       	call   80152f <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 fa 13 00 00       	call   80152f <dup>
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
  800143:	68 a7 28 80 00       	push   $0x8028a7
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 e6 21 00 00       	call   80233e <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 00 29 80 00       	push   $0x802900
  800167:	6a 3a                	push   $0x3a
  800169:	68 62 28 80 00       	push   $0x802862
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 2c 12 00 00       	call   8013ae <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 bd 28 80 00       	push   $0x8028bd
  80018f:	6a 3c                	push   $0x3c
  800191:	68 62 28 80 00       	push   $0x802862
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 a2 11 00 00       	call   801348 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 c0 19 00 00       	call   801b6e <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 d5 28 80 00       	push   $0x8028d5
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 eb 28 80 00       	push   $0x8028eb
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
  800201:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800230:	e8 d5 12 00 00       	call   80150a <close_all>
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
  800262:	68 34 29 80 00       	push   $0x802934
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 57 28 80 00 	movl   $0x802857,(%esp)
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
  800380:	e8 0b 22 00 00       	call   802590 <__udivdi3>
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
  8003be:	e8 fd 22 00 00       	call   8026c0 <__umoddi3>
  8003c3:	83 c4 14             	add    $0x14,%esp
  8003c6:	0f be 80 57 29 80 00 	movsbl 0x802957(%eax),%eax
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
  8004c2:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
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
  800586:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  80058d:	85 d2                	test   %edx,%edx
  80058f:	75 18                	jne    8005a9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800591:	50                   	push   %eax
  800592:	68 6f 29 80 00       	push   $0x80296f
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
  8005aa:	68 d9 2e 80 00       	push   $0x802ed9
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
  8005d7:	ba 68 29 80 00       	mov    $0x802968,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800c56:	68 9f 2c 80 00       	push   $0x802c9f
  800c5b:	6a 22                	push   $0x22
  800c5d:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
	// return value.
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
	// return value.
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
  800cd7:	68 9f 2c 80 00       	push   $0x802c9f
  800cdc:	6a 22                	push   $0x22
  800cde:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
  800d19:	68 9f 2c 80 00       	push   $0x802c9f
  800d1e:	6a 22                	push   $0x22
  800d20:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
  800d5b:	68 9f 2c 80 00       	push   $0x802c9f
  800d60:	6a 22                	push   $0x22
  800d62:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
  800d9d:	68 9f 2c 80 00       	push   $0x802c9f
  800da2:	6a 22                	push   $0x22
  800da4:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
  800ddf:	68 9f 2c 80 00       	push   $0x802c9f
  800de4:	6a 22                	push   $0x22
  800de6:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
  800e21:	68 9f 2c 80 00       	push   $0x802c9f
  800e26:	6a 22                	push   $0x22
  800e28:	68 bc 2c 80 00       	push   $0x802cbc
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
	// return value.
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
	// return value.
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
  800e85:	68 9f 2c 80 00       	push   $0x802c9f
  800e8a:	6a 22                	push   $0x22
  800e8c:	68 bc 2c 80 00       	push   $0x802cbc
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

00800e9e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ea4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eae:	89 d1                	mov    %edx,%ecx
  800eb0:	89 d3                	mov    %edx,%ebx
  800eb2:	89 d7                	mov    %edx,%edi
  800eb4:	89 d6                	mov    %edx,%esi
  800eb6:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_transmit>:

int
sys_transmit(void *addr)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ec6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecb:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	89 cb                	mov    %ecx,%ebx
  800ed5:	89 cf                	mov    %ecx,%edi
  800ed7:	89 ce                	mov    %ecx,%esi
  800ed9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edb:	85 c0                	test   %eax,%eax
  800edd:	7e 17                	jle    800ef6 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	50                   	push   %eax
  800ee3:	6a 0f                	push   $0xf
  800ee5:	68 9f 2c 80 00       	push   $0x802c9f
  800eea:	6a 22                	push   $0x22
  800eec:	68 bc 2c 80 00       	push   $0x802cbc
  800ef1:	e8 4e f3 ff ff       	call   800244 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <sys_recv>:

int
sys_recv(void *addr)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0c:	b8 10 00 00 00       	mov    $0x10,%eax
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 cb                	mov    %ecx,%ebx
  800f16:	89 cf                	mov    %ecx,%edi
  800f18:	89 ce                	mov    %ecx,%esi
  800f1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	7e 17                	jle    800f37 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	50                   	push   %eax
  800f24:	6a 10                	push   $0x10
  800f26:	68 9f 2c 80 00       	push   $0x802c9f
  800f2b:	6a 22                	push   $0x22
  800f2d:	68 bc 2c 80 00       	push   $0x802cbc
  800f32:	e8 0d f3 ff ff       	call   800244 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	53                   	push   %ebx
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f49:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f4b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f4f:	74 2e                	je     800f7f <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f51:	89 c2                	mov    %eax,%edx
  800f53:	c1 ea 16             	shr    $0x16,%edx
  800f56:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5d:	f6 c2 01             	test   $0x1,%dl
  800f60:	74 1d                	je     800f7f <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f62:	89 c2                	mov    %eax,%edx
  800f64:	c1 ea 0c             	shr    $0xc,%edx
  800f67:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f6e:	f6 c1 01             	test   $0x1,%cl
  800f71:	74 0c                	je     800f7f <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f7a:	f6 c6 08             	test   $0x8,%dh
  800f7d:	75 14                	jne    800f93 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 cc 2c 80 00       	push   $0x802ccc
  800f87:	6a 21                	push   $0x21
  800f89:	68 5f 2d 80 00       	push   $0x802d5f
  800f8e:	e8 b1 f2 ff ff       	call   800244 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800f93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f98:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	6a 07                	push   $0x7
  800f9f:	68 00 f0 7f 00       	push   $0x7ff000
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 02 fd ff ff       	call   800cad <sys_page_alloc>
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 14                	jns    800fc6 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	68 6a 2d 80 00       	push   $0x802d6a
  800fba:	6a 2b                	push   $0x2b
  800fbc:	68 5f 2d 80 00       	push   $0x802d5f
  800fc1:	e8 7e f2 ff ff       	call   800244 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 00 10 00 00       	push   $0x1000
  800fce:	53                   	push   %ebx
  800fcf:	68 00 f0 7f 00       	push   $0x7ff000
  800fd4:	e8 5d fa ff ff       	call   800a36 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800fd9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fe0:	53                   	push   %ebx
  800fe1:	6a 00                	push   $0x0
  800fe3:	68 00 f0 7f 00       	push   $0x7ff000
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 01 fd ff ff       	call   800cf0 <sys_page_map>
  800fef:	83 c4 20             	add    $0x20,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 14                	jns    80100a <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 80 2d 80 00       	push   $0x802d80
  800ffe:	6a 2e                	push   $0x2e
  801000:	68 5f 2d 80 00       	push   $0x802d5f
  801005:	e8 3a f2 ff ff       	call   800244 <_panic>
        sys_page_unmap(0, PFTEMP); 
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	68 00 f0 7f 00       	push   $0x7ff000
  801012:	6a 00                	push   $0x0
  801014:	e8 19 fd ff ff       	call   800d32 <sys_page_unmap>
  801019:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  80102a:	68 3f 0f 80 00       	push   $0x800f3f
  80102f:	e8 c2 14 00 00       	call   8024f6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801034:	b8 07 00 00 00       	mov    $0x7,%eax
  801039:	cd 30                	int    $0x30
  80103b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	79 12                	jns    801057 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801045:	50                   	push   %eax
  801046:	68 94 2d 80 00       	push   $0x802d94
  80104b:	6a 6d                	push   $0x6d
  80104d:	68 5f 2d 80 00       	push   $0x802d5f
  801052:	e8 ed f1 ff ff       	call   800244 <_panic>
  801057:	89 c7                	mov    %eax,%edi
  801059:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  80105e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801062:	75 21                	jne    801085 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801064:	e8 06 fc ff ff       	call   800c6f <sys_getenvid>
  801069:	25 ff 03 00 00       	and    $0x3ff,%eax
  80106e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801076:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
  801080:	e9 9c 01 00 00       	jmp    801221 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801085:	89 d8                	mov    %ebx,%eax
  801087:	c1 e8 16             	shr    $0x16,%eax
  80108a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801091:	a8 01                	test   $0x1,%al
  801093:	0f 84 f3 00 00 00    	je     80118c <fork+0x16b>
  801099:	89 d8                	mov    %ebx,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
  80109e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a5:	f6 c2 01             	test   $0x1,%dl
  8010a8:	0f 84 de 00 00 00    	je     80118c <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  8010ae:	89 c6                	mov    %eax,%esi
  8010b0:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  8010b3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ba:	f6 c6 04             	test   $0x4,%dh
  8010bd:	74 37                	je     8010f6 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  8010bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ce:	50                   	push   %eax
  8010cf:	56                   	push   %esi
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 17 fc ff ff       	call   800cf0 <sys_page_map>
  8010d9:	83 c4 20             	add    $0x20,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	0f 89 a8 00 00 00    	jns    80118c <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  8010e4:	50                   	push   %eax
  8010e5:	68 f0 2c 80 00       	push   $0x802cf0
  8010ea:	6a 49                	push   $0x49
  8010ec:	68 5f 2d 80 00       	push   $0x802d5f
  8010f1:	e8 4e f1 ff ff       	call   800244 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8010f6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010fd:	f6 c6 08             	test   $0x8,%dh
  801100:	75 0b                	jne    80110d <fork+0xec>
  801102:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801109:	a8 02                	test   $0x2,%al
  80110b:	74 57                	je     801164 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	68 05 08 00 00       	push   $0x805
  801115:	56                   	push   %esi
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	6a 00                	push   $0x0
  80111a:	e8 d1 fb ff ff       	call   800cf0 <sys_page_map>
  80111f:	83 c4 20             	add    $0x20,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	79 12                	jns    801138 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  801126:	50                   	push   %eax
  801127:	68 f0 2c 80 00       	push   $0x802cf0
  80112c:	6a 4c                	push   $0x4c
  80112e:	68 5f 2d 80 00       	push   $0x802d5f
  801133:	e8 0c f1 ff ff       	call   800244 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	68 05 08 00 00       	push   $0x805
  801140:	56                   	push   %esi
  801141:	6a 00                	push   $0x0
  801143:	56                   	push   %esi
  801144:	6a 00                	push   $0x0
  801146:	e8 a5 fb ff ff       	call   800cf0 <sys_page_map>
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	79 3a                	jns    80118c <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801152:	50                   	push   %eax
  801153:	68 14 2d 80 00       	push   $0x802d14
  801158:	6a 4e                	push   $0x4e
  80115a:	68 5f 2d 80 00       	push   $0x802d5f
  80115f:	e8 e0 f0 ff ff       	call   800244 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	6a 05                	push   $0x5
  801169:	56                   	push   %esi
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	6a 00                	push   $0x0
  80116e:	e8 7d fb ff ff       	call   800cf0 <sys_page_map>
  801173:	83 c4 20             	add    $0x20,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	79 12                	jns    80118c <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80117a:	50                   	push   %eax
  80117b:	68 3c 2d 80 00       	push   $0x802d3c
  801180:	6a 50                	push   $0x50
  801182:	68 5f 2d 80 00       	push   $0x802d5f
  801187:	e8 b8 f0 ff ff       	call   800244 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80118c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801192:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801198:	0f 85 e7 fe ff ff    	jne    801085 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	6a 07                	push   $0x7
  8011a3:	68 00 f0 bf ee       	push   $0xeebff000
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	e8 fd fa ff ff       	call   800cad <sys_page_alloc>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	79 14                	jns    8011cb <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	68 a4 2d 80 00       	push   $0x802da4
  8011bf:	6a 76                	push   $0x76
  8011c1:	68 5f 2d 80 00       	push   $0x802d5f
  8011c6:	e8 79 f0 ff ff       	call   800244 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	68 65 25 80 00       	push   $0x802565
  8011d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d6:	e8 1d fc ff ff       	call   800df8 <sys_env_set_pgfault_upcall>
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	79 14                	jns    8011f6 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8011e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e5:	68 be 2d 80 00       	push   $0x802dbe
  8011ea:	6a 79                	push   $0x79
  8011ec:	68 5f 2d 80 00       	push   $0x802d5f
  8011f1:	e8 4e f0 ff ff       	call   800244 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	6a 02                	push   $0x2
  8011fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fe:	e8 71 fb ff ff       	call   800d74 <sys_env_set_status>
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	79 14                	jns    80121e <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80120a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120d:	68 db 2d 80 00       	push   $0x802ddb
  801212:	6a 7b                	push   $0x7b
  801214:	68 5f 2d 80 00       	push   $0x802d5f
  801219:	e8 26 f0 ff ff       	call   800244 <_panic>
        return forkid;
  80121e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <sfork>:

// Challenge!
int
sfork(void)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80122f:	68 f2 2d 80 00       	push   $0x802df2
  801234:	68 83 00 00 00       	push   $0x83
  801239:	68 5f 2d 80 00       	push   $0x802d5f
  80123e:	e8 01 f0 ff ff       	call   800244 <_panic>

00801243 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	8b 75 08             	mov    0x8(%ebp),%esi
  80124b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801251:	85 c0                	test   %eax,%eax
  801253:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801258:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80125b:	83 ec 0c             	sub    $0xc,%esp
  80125e:	50                   	push   %eax
  80125f:	e8 f9 fb ff ff       	call   800e5d <sys_ipc_recv>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	79 16                	jns    801281 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80126b:	85 f6                	test   %esi,%esi
  80126d:	74 06                	je     801275 <ipc_recv+0x32>
  80126f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801275:	85 db                	test   %ebx,%ebx
  801277:	74 2c                	je     8012a5 <ipc_recv+0x62>
  801279:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80127f:	eb 24                	jmp    8012a5 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801281:	85 f6                	test   %esi,%esi
  801283:	74 0a                	je     80128f <ipc_recv+0x4c>
  801285:	a1 08 40 80 00       	mov    0x804008,%eax
  80128a:	8b 40 74             	mov    0x74(%eax),%eax
  80128d:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80128f:	85 db                	test   %ebx,%ebx
  801291:	74 0a                	je     80129d <ipc_recv+0x5a>
  801293:	a1 08 40 80 00       	mov    0x804008,%eax
  801298:	8b 40 78             	mov    0x78(%eax),%eax
  80129b:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80129d:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 0c             	sub    $0xc,%esp
  8012b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8012be:	85 db                	test   %ebx,%ebx
  8012c0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012c5:	0f 44 d8             	cmove  %eax,%ebx
  8012c8:	eb 1c                	jmp    8012e6 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8012ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012cd:	74 12                	je     8012e1 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8012cf:	50                   	push   %eax
  8012d0:	68 08 2e 80 00       	push   $0x802e08
  8012d5:	6a 39                	push   $0x39
  8012d7:	68 23 2e 80 00       	push   $0x802e23
  8012dc:	e8 63 ef ff ff       	call   800244 <_panic>
                 sys_yield();
  8012e1:	e8 a8 f9 ff ff       	call   800c8e <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8012e6:	ff 75 14             	pushl  0x14(%ebp)
  8012e9:	53                   	push   %ebx
  8012ea:	56                   	push   %esi
  8012eb:	57                   	push   %edi
  8012ec:	e8 49 fb ff ff       	call   800e3a <sys_ipc_try_send>
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 d2                	js     8012ca <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8012f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801306:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80130b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80130e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801314:	8b 52 50             	mov    0x50(%edx),%edx
  801317:	39 ca                	cmp    %ecx,%edx
  801319:	75 0d                	jne    801328 <ipc_find_env+0x28>
			return envs[i].env_id;
  80131b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80131e:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801323:	8b 40 08             	mov    0x8(%eax),%eax
  801326:	eb 0e                	jmp    801336 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801328:	83 c0 01             	add    $0x1,%eax
  80132b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801330:	75 d9                	jne    80130b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801332:	66 b8 00 00          	mov    $0x0,%ax
}
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	05 00 00 00 30       	add    $0x30000000,%eax
  801343:	c1 e8 0c             	shr    $0xc,%eax
}
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134b:	8b 45 08             	mov    0x8(%ebp),%eax
  80134e:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801353:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801358:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801365:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	c1 ea 16             	shr    $0x16,%edx
  80136f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801376:	f6 c2 01             	test   $0x1,%dl
  801379:	74 11                	je     80138c <fd_alloc+0x2d>
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	c1 ea 0c             	shr    $0xc,%edx
  801380:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801387:	f6 c2 01             	test   $0x1,%dl
  80138a:	75 09                	jne    801395 <fd_alloc+0x36>
			*fd_store = fd;
  80138c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	eb 17                	jmp    8013ac <fd_alloc+0x4d>
  801395:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80139a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80139f:	75 c9                	jne    80136a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013a1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013b4:	83 f8 1f             	cmp    $0x1f,%eax
  8013b7:	77 36                	ja     8013ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013b9:	c1 e0 0c             	shl    $0xc,%eax
  8013bc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	c1 ea 16             	shr    $0x16,%edx
  8013c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013cd:	f6 c2 01             	test   $0x1,%dl
  8013d0:	74 24                	je     8013f6 <fd_lookup+0x48>
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	c1 ea 0c             	shr    $0xc,%edx
  8013d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013de:	f6 c2 01             	test   $0x1,%dl
  8013e1:	74 1a                	je     8013fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e6:	89 02                	mov    %eax,(%edx)
	return 0;
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ed:	eb 13                	jmp    801402 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f4:	eb 0c                	jmp    801402 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fb:	eb 05                	jmp    801402 <fd_lookup+0x54>
  8013fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	eb 13                	jmp    801427 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801414:	39 08                	cmp    %ecx,(%eax)
  801416:	75 0c                	jne    801424 <dev_lookup+0x20>
			*dev = devtab[i];
  801418:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141d:	b8 00 00 00 00       	mov    $0x0,%eax
  801422:	eb 36                	jmp    80145a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801424:	83 c2 01             	add    $0x1,%edx
  801427:	8b 04 95 ac 2e 80 00 	mov    0x802eac(,%edx,4),%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	75 e2                	jne    801414 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801432:	a1 08 40 80 00       	mov    0x804008,%eax
  801437:	8b 40 48             	mov    0x48(%eax),%eax
  80143a:	83 ec 04             	sub    $0x4,%esp
  80143d:	51                   	push   %ecx
  80143e:	50                   	push   %eax
  80143f:	68 30 2e 80 00       	push   $0x802e30
  801444:	e8 d4 ee ff ff       	call   80031d <cprintf>
	*dev = 0;
  801449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    

0080145c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	83 ec 10             	sub    $0x10,%esp
  801464:	8b 75 08             	mov    0x8(%ebp),%esi
  801467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801477:	50                   	push   %eax
  801478:	e8 31 ff ff ff       	call   8013ae <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 05                	js     801489 <fd_close+0x2d>
	    || fd != fd2)
  801484:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801487:	74 0c                	je     801495 <fd_close+0x39>
		return (must_exist ? r : 0);
  801489:	84 db                	test   %bl,%bl
  80148b:	ba 00 00 00 00       	mov    $0x0,%edx
  801490:	0f 44 c2             	cmove  %edx,%eax
  801493:	eb 41                	jmp    8014d6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	ff 36                	pushl  (%esi)
  80149e:	e8 61 ff ff ff       	call   801404 <dev_lookup>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 1a                	js     8014c6 <fd_close+0x6a>
		if (dev->dev_close)
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	74 0b                	je     8014c6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	56                   	push   %esi
  8014bf:	ff d0                	call   *%eax
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	56                   	push   %esi
  8014ca:	6a 00                	push   $0x0
  8014cc:	e8 61 f8 ff ff       	call   800d32 <sys_page_unmap>
	return r;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	89 d8                	mov    %ebx,%eax
}
  8014d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	e8 bf fe ff ff       	call   8013ae <fd_lookup>
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	78 10                	js     801508 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	6a 01                	push   $0x1
  8014fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801500:	e8 57 ff ff ff       	call   80145c <fd_close>
  801505:	83 c4 10             	add    $0x10,%esp
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <close_all>:

void
close_all(void)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	53                   	push   %ebx
  80150e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801511:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	53                   	push   %ebx
  80151a:	e8 be ff ff ff       	call   8014dd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80151f:	83 c3 01             	add    $0x1,%ebx
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	83 fb 20             	cmp    $0x20,%ebx
  801528:	75 ec                	jne    801516 <close_all+0xc>
		close(i);
}
  80152a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	57                   	push   %edi
  801533:	56                   	push   %esi
  801534:	53                   	push   %ebx
  801535:	83 ec 2c             	sub    $0x2c,%esp
  801538:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80153b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	ff 75 08             	pushl  0x8(%ebp)
  801542:	e8 67 fe ff ff       	call   8013ae <fd_lookup>
  801547:	89 c2                	mov    %eax,%edx
  801549:	83 c4 08             	add    $0x8,%esp
  80154c:	85 d2                	test   %edx,%edx
  80154e:	0f 88 c1 00 00 00    	js     801615 <dup+0xe6>
		return r;
	close(newfdnum);
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	56                   	push   %esi
  801558:	e8 80 ff ff ff       	call   8014dd <close>

	newfd = INDEX2FD(newfdnum);
  80155d:	89 f3                	mov    %esi,%ebx
  80155f:	c1 e3 0c             	shl    $0xc,%ebx
  801562:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801568:	83 c4 04             	add    $0x4,%esp
  80156b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80156e:	e8 d5 fd ff ff       	call   801348 <fd2data>
  801573:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801575:	89 1c 24             	mov    %ebx,(%esp)
  801578:	e8 cb fd ff ff       	call   801348 <fd2data>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801583:	89 f8                	mov    %edi,%eax
  801585:	c1 e8 16             	shr    $0x16,%eax
  801588:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80158f:	a8 01                	test   $0x1,%al
  801591:	74 37                	je     8015ca <dup+0x9b>
  801593:	89 f8                	mov    %edi,%eax
  801595:	c1 e8 0c             	shr    $0xc,%eax
  801598:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80159f:	f6 c2 01             	test   $0x1,%dl
  8015a2:	74 26                	je     8015ca <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b7:	6a 00                	push   $0x0
  8015b9:	57                   	push   %edi
  8015ba:	6a 00                	push   $0x0
  8015bc:	e8 2f f7 ff ff       	call   800cf0 <sys_page_map>
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	83 c4 20             	add    $0x20,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 2e                	js     8015f8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015cd:	89 d0                	mov    %edx,%eax
  8015cf:	c1 e8 0c             	shr    $0xc,%eax
  8015d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e1:	50                   	push   %eax
  8015e2:	53                   	push   %ebx
  8015e3:	6a 00                	push   $0x0
  8015e5:	52                   	push   %edx
  8015e6:	6a 00                	push   $0x0
  8015e8:	e8 03 f7 ff ff       	call   800cf0 <sys_page_map>
  8015ed:	89 c7                	mov    %eax,%edi
  8015ef:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015f2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f4:	85 ff                	test   %edi,%edi
  8015f6:	79 1d                	jns    801615 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	6a 00                	push   $0x0
  8015fe:	e8 2f f7 ff ff       	call   800d32 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801603:	83 c4 08             	add    $0x8,%esp
  801606:	ff 75 d4             	pushl  -0x2c(%ebp)
  801609:	6a 00                	push   $0x0
  80160b:	e8 22 f7 ff ff       	call   800d32 <sys_page_unmap>
	return r;
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	89 f8                	mov    %edi,%eax
}
  801615:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5f                   	pop    %edi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	53                   	push   %ebx
  801621:	83 ec 14             	sub    $0x14,%esp
  801624:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801627:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	53                   	push   %ebx
  80162c:	e8 7d fd ff ff       	call   8013ae <fd_lookup>
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	89 c2                	mov    %eax,%edx
  801636:	85 c0                	test   %eax,%eax
  801638:	78 6d                	js     8016a7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801644:	ff 30                	pushl  (%eax)
  801646:	e8 b9 fd ff ff       	call   801404 <dev_lookup>
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 4c                	js     80169e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801652:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801655:	8b 42 08             	mov    0x8(%edx),%eax
  801658:	83 e0 03             	and    $0x3,%eax
  80165b:	83 f8 01             	cmp    $0x1,%eax
  80165e:	75 21                	jne    801681 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801660:	a1 08 40 80 00       	mov    0x804008,%eax
  801665:	8b 40 48             	mov    0x48(%eax),%eax
  801668:	83 ec 04             	sub    $0x4,%esp
  80166b:	53                   	push   %ebx
  80166c:	50                   	push   %eax
  80166d:	68 71 2e 80 00       	push   $0x802e71
  801672:	e8 a6 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167f:	eb 26                	jmp    8016a7 <read+0x8a>
	}
	if (!dev->dev_read)
  801681:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801684:	8b 40 08             	mov    0x8(%eax),%eax
  801687:	85 c0                	test   %eax,%eax
  801689:	74 17                	je     8016a2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	ff 75 10             	pushl  0x10(%ebp)
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	52                   	push   %edx
  801695:	ff d0                	call   *%eax
  801697:	89 c2                	mov    %eax,%edx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb 09                	jmp    8016a7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	eb 05                	jmp    8016a7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 0c             	sub    $0xc,%esp
  8016b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c2:	eb 21                	jmp    8016e5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016c4:	83 ec 04             	sub    $0x4,%esp
  8016c7:	89 f0                	mov    %esi,%eax
  8016c9:	29 d8                	sub    %ebx,%eax
  8016cb:	50                   	push   %eax
  8016cc:	89 d8                	mov    %ebx,%eax
  8016ce:	03 45 0c             	add    0xc(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	57                   	push   %edi
  8016d3:	e8 45 ff ff ff       	call   80161d <read>
		if (m < 0)
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 0c                	js     8016eb <readn+0x3d>
			return m;
		if (m == 0)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	74 06                	je     8016e9 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e3:	01 c3                	add    %eax,%ebx
  8016e5:	39 f3                	cmp    %esi,%ebx
  8016e7:	72 db                	jb     8016c4 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8016e9:	89 d8                	mov    %ebx,%eax
}
  8016eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5f                   	pop    %edi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 14             	sub    $0x14,%esp
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	53                   	push   %ebx
  801702:	e8 a7 fc ff ff       	call   8013ae <fd_lookup>
  801707:	83 c4 08             	add    $0x8,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 68                	js     801778 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	ff 30                	pushl  (%eax)
  80171c:	e8 e3 fc ff ff       	call   801404 <dev_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 47                	js     80176f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80172f:	75 21                	jne    801752 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801731:	a1 08 40 80 00       	mov    0x804008,%eax
  801736:	8b 40 48             	mov    0x48(%eax),%eax
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	53                   	push   %ebx
  80173d:	50                   	push   %eax
  80173e:	68 8d 2e 80 00       	push   $0x802e8d
  801743:	e8 d5 eb ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801750:	eb 26                	jmp    801778 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801752:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801755:	8b 52 0c             	mov    0xc(%edx),%edx
  801758:	85 d2                	test   %edx,%edx
  80175a:	74 17                	je     801773 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	ff 75 10             	pushl  0x10(%ebp)
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	50                   	push   %eax
  801766:	ff d2                	call   *%edx
  801768:	89 c2                	mov    %eax,%edx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	eb 09                	jmp    801778 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	89 c2                	mov    %eax,%edx
  801771:	eb 05                	jmp    801778 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801773:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801778:	89 d0                	mov    %edx,%eax
  80177a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <seek>:

int
seek(int fdnum, off_t offset)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801785:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801788:	50                   	push   %eax
  801789:	ff 75 08             	pushl  0x8(%ebp)
  80178c:	e8 1d fc ff ff       	call   8013ae <fd_lookup>
  801791:	83 c4 08             	add    $0x8,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	78 0e                	js     8017a6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801798:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 14             	sub    $0x14,%esp
  8017af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b5:	50                   	push   %eax
  8017b6:	53                   	push   %ebx
  8017b7:	e8 f2 fb ff ff       	call   8013ae <fd_lookup>
  8017bc:	83 c4 08             	add    $0x8,%esp
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 65                	js     80182a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cb:	50                   	push   %eax
  8017cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cf:	ff 30                	pushl  (%eax)
  8017d1:	e8 2e fc ff ff       	call   801404 <dev_lookup>
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 44                	js     801821 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e4:	75 21                	jne    801807 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017e6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017eb:	8b 40 48             	mov    0x48(%eax),%eax
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	53                   	push   %ebx
  8017f2:	50                   	push   %eax
  8017f3:	68 50 2e 80 00       	push   $0x802e50
  8017f8:	e8 20 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801805:	eb 23                	jmp    80182a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801807:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180a:	8b 52 18             	mov    0x18(%edx),%edx
  80180d:	85 d2                	test   %edx,%edx
  80180f:	74 14                	je     801825 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	ff 75 0c             	pushl  0xc(%ebp)
  801817:	50                   	push   %eax
  801818:	ff d2                	call   *%edx
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	eb 09                	jmp    80182a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801821:	89 c2                	mov    %eax,%edx
  801823:	eb 05                	jmp    80182a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801825:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80182a:	89 d0                	mov    %edx,%eax
  80182c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 14             	sub    $0x14,%esp
  801838:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183e:	50                   	push   %eax
  80183f:	ff 75 08             	pushl  0x8(%ebp)
  801842:	e8 67 fb ff ff       	call   8013ae <fd_lookup>
  801847:	83 c4 08             	add    $0x8,%esp
  80184a:	89 c2                	mov    %eax,%edx
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 58                	js     8018a8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801856:	50                   	push   %eax
  801857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185a:	ff 30                	pushl  (%eax)
  80185c:	e8 a3 fb ff ff       	call   801404 <dev_lookup>
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	78 37                	js     80189f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80186f:	74 32                	je     8018a3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801871:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801874:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80187b:	00 00 00 
	stat->st_isdir = 0;
  80187e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801885:	00 00 00 
	stat->st_dev = dev;
  801888:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	53                   	push   %ebx
  801892:	ff 75 f0             	pushl  -0x10(%ebp)
  801895:	ff 50 14             	call   *0x14(%eax)
  801898:	89 c2                	mov    %eax,%edx
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	eb 09                	jmp    8018a8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	eb 05                	jmp    8018a8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018a8:	89 d0                	mov    %edx,%eax
  8018aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	6a 00                	push   $0x0
  8018b9:	ff 75 08             	pushl  0x8(%ebp)
  8018bc:	e8 09 02 00 00       	call   801aca <open>
  8018c1:	89 c3                	mov    %eax,%ebx
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 db                	test   %ebx,%ebx
  8018c8:	78 1b                	js     8018e5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	53                   	push   %ebx
  8018d1:	e8 5b ff ff ff       	call   801831 <fstat>
  8018d6:	89 c6                	mov    %eax,%esi
	close(fd);
  8018d8:	89 1c 24             	mov    %ebx,(%esp)
  8018db:	e8 fd fb ff ff       	call   8014dd <close>
	return r;
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	89 f0                	mov    %esi,%eax
}
  8018e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	89 c6                	mov    %eax,%esi
  8018f3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018f5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018fc:	75 12                	jne    801910 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	6a 01                	push   $0x1
  801903:	e8 f8 f9 ff ff       	call   801300 <ipc_find_env>
  801908:	a3 00 40 80 00       	mov    %eax,0x804000
  80190d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801910:	6a 07                	push   $0x7
  801912:	68 00 50 80 00       	push   $0x805000
  801917:	56                   	push   %esi
  801918:	ff 35 00 40 80 00    	pushl  0x804000
  80191e:	e8 89 f9 ff ff       	call   8012ac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801923:	83 c4 0c             	add    $0xc,%esp
  801926:	6a 00                	push   $0x0
  801928:	53                   	push   %ebx
  801929:	6a 00                	push   $0x0
  80192b:	e8 13 f9 ff ff       	call   801243 <ipc_recv>
}
  801930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    

00801937 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	8b 40 0c             	mov    0xc(%eax),%eax
  801943:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801950:	ba 00 00 00 00       	mov    $0x0,%edx
  801955:	b8 02 00 00 00       	mov    $0x2,%eax
  80195a:	e8 8d ff ff ff       	call   8018ec <fsipc>
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	8b 40 0c             	mov    0xc(%eax),%eax
  80196d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801972:	ba 00 00 00 00       	mov    $0x0,%edx
  801977:	b8 06 00 00 00       	mov    $0x6,%eax
  80197c:	e8 6b ff ff ff       	call   8018ec <fsipc>
}
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	53                   	push   %ebx
  801987:	83 ec 04             	sub    $0x4,%esp
  80198a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	8b 40 0c             	mov    0xc(%eax),%eax
  801993:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801998:	ba 00 00 00 00       	mov    $0x0,%edx
  80199d:	b8 05 00 00 00       	mov    $0x5,%eax
  8019a2:	e8 45 ff ff ff       	call   8018ec <fsipc>
  8019a7:	89 c2                	mov    %eax,%edx
  8019a9:	85 d2                	test   %edx,%edx
  8019ab:	78 2c                	js     8019d9 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	68 00 50 80 00       	push   $0x805000
  8019b5:	53                   	push   %ebx
  8019b6:	e8 e9 ee ff ff       	call   8008a4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019bb:	a1 80 50 80 00       	mov    0x805080,%eax
  8019c0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019c6:	a1 84 50 80 00       	mov    0x805084,%eax
  8019cb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f0:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8019f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8019f8:	eb 3d                	jmp    801a37 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8019fa:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801a00:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801a05:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	57                   	push   %edi
  801a0c:	53                   	push   %ebx
  801a0d:	68 08 50 80 00       	push   $0x805008
  801a12:	e8 1f f0 ff ff       	call   800a36 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801a17:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	b8 04 00 00 00       	mov    $0x4,%eax
  801a27:	e8 c0 fe ff ff       	call   8018ec <fsipc>
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 0d                	js     801a40 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801a33:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801a35:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801a37:	85 f6                	test   %esi,%esi
  801a39:	75 bf                	jne    8019fa <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801a3b:	89 d8                	mov    %ebx,%eax
  801a3d:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801a40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5e                   	pop    %esi
  801a45:	5f                   	pop    %edi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	8b 40 0c             	mov    0xc(%eax),%eax
  801a56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6b:	e8 7c fe ff ff       	call   8018ec <fsipc>
  801a70:	89 c3                	mov    %eax,%ebx
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 4b                	js     801ac1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a76:	39 c6                	cmp    %eax,%esi
  801a78:	73 16                	jae    801a90 <devfile_read+0x48>
  801a7a:	68 c0 2e 80 00       	push   $0x802ec0
  801a7f:	68 c7 2e 80 00       	push   $0x802ec7
  801a84:	6a 7c                	push   $0x7c
  801a86:	68 dc 2e 80 00       	push   $0x802edc
  801a8b:	e8 b4 e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a90:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a95:	7e 16                	jle    801aad <devfile_read+0x65>
  801a97:	68 e7 2e 80 00       	push   $0x802ee7
  801a9c:	68 c7 2e 80 00       	push   $0x802ec7
  801aa1:	6a 7d                	push   $0x7d
  801aa3:	68 dc 2e 80 00       	push   $0x802edc
  801aa8:	e8 97 e7 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aad:	83 ec 04             	sub    $0x4,%esp
  801ab0:	50                   	push   %eax
  801ab1:	68 00 50 80 00       	push   $0x805000
  801ab6:	ff 75 0c             	pushl  0xc(%ebp)
  801ab9:	e8 78 ef ff ff       	call   800a36 <memmove>
	return r;
  801abe:	83 c4 10             	add    $0x10,%esp
}
  801ac1:	89 d8                	mov    %ebx,%eax
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	53                   	push   %ebx
  801ace:	83 ec 20             	sub    $0x20,%esp
  801ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad4:	53                   	push   %ebx
  801ad5:	e8 91 ed ff ff       	call   80086b <strlen>
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae2:	7f 67                	jg     801b4b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aea:	50                   	push   %eax
  801aeb:	e8 6f f8 ff ff       	call   80135f <fd_alloc>
  801af0:	83 c4 10             	add    $0x10,%esp
		return r;
  801af3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 57                	js     801b50 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801af9:	83 ec 08             	sub    $0x8,%esp
  801afc:	53                   	push   %ebx
  801afd:	68 00 50 80 00       	push   $0x805000
  801b02:	e8 9d ed ff ff       	call   8008a4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b12:	b8 01 00 00 00       	mov    $0x1,%eax
  801b17:	e8 d0 fd ff ff       	call   8018ec <fsipc>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	79 14                	jns    801b39 <open+0x6f>
		fd_close(fd, 0);
  801b25:	83 ec 08             	sub    $0x8,%esp
  801b28:	6a 00                	push   $0x0
  801b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2d:	e8 2a f9 ff ff       	call   80145c <fd_close>
		return r;
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	89 da                	mov    %ebx,%edx
  801b37:	eb 17                	jmp    801b50 <open+0x86>
	}

	return fd2num(fd);
  801b39:	83 ec 0c             	sub    $0xc,%esp
  801b3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3f:	e8 f4 f7 ff ff       	call   801338 <fd2num>
  801b44:	89 c2                	mov    %eax,%edx
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	eb 05                	jmp    801b50 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b4b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b62:	b8 08 00 00 00       	mov    $0x8,%eax
  801b67:	e8 80 fd ff ff       	call   8018ec <fsipc>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b74:	89 d0                	mov    %edx,%eax
  801b76:	c1 e8 16             	shr    $0x16,%eax
  801b79:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b85:	f6 c1 01             	test   $0x1,%cl
  801b88:	74 1d                	je     801ba7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b8a:	c1 ea 0c             	shr    $0xc,%edx
  801b8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b94:	f6 c2 01             	test   $0x1,%dl
  801b97:	74 0e                	je     801ba7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b99:	c1 ea 0c             	shr    $0xc,%edx
  801b9c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba3:	ef 
  801ba4:	0f b7 c0             	movzwl %ax,%eax
}
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801baf:	68 f3 2e 80 00       	push   $0x802ef3
  801bb4:	ff 75 0c             	pushl  0xc(%ebp)
  801bb7:	e8 e8 ec ff ff       	call   8008a4 <strcpy>
	return 0;
}
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 10             	sub    $0x10,%esp
  801bca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bcd:	53                   	push   %ebx
  801bce:	e8 9b ff ff ff       	call   801b6e <pageref>
  801bd3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bd6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bdb:	83 f8 01             	cmp    $0x1,%eax
  801bde:	75 10                	jne    801bf0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	ff 73 0c             	pushl  0xc(%ebx)
  801be6:	e8 ca 02 00 00       	call   801eb5 <nsipc_close>
  801beb:	89 c2                	mov    %eax,%edx
  801bed:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801bf0:	89 d0                	mov    %edx,%eax
  801bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bfd:	6a 00                	push   $0x0
  801bff:	ff 75 10             	pushl  0x10(%ebp)
  801c02:	ff 75 0c             	pushl  0xc(%ebp)
  801c05:	8b 45 08             	mov    0x8(%ebp),%eax
  801c08:	ff 70 0c             	pushl  0xc(%eax)
  801c0b:	e8 82 03 00 00       	call   801f92 <nsipc_send>
}
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c18:	6a 00                	push   $0x0
  801c1a:	ff 75 10             	pushl  0x10(%ebp)
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	ff 70 0c             	pushl  0xc(%eax)
  801c26:	e8 fb 02 00 00       	call   801f26 <nsipc_recv>
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c33:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c36:	52                   	push   %edx
  801c37:	50                   	push   %eax
  801c38:	e8 71 f7 ff ff       	call   8013ae <fd_lookup>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 17                	js     801c5b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c47:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c4d:	39 08                	cmp    %ecx,(%eax)
  801c4f:	75 05                	jne    801c56 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c51:	8b 40 0c             	mov    0xc(%eax),%eax
  801c54:	eb 05                	jmp    801c5b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c56:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
  801c62:	83 ec 1c             	sub    $0x1c,%esp
  801c65:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	e8 ef f6 ff ff       	call   80135f <fd_alloc>
  801c70:	89 c3                	mov    %eax,%ebx
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 1b                	js     801c94 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	68 07 04 00 00       	push   $0x407
  801c81:	ff 75 f4             	pushl  -0xc(%ebp)
  801c84:	6a 00                	push   $0x0
  801c86:	e8 22 f0 ff ff       	call   800cad <sys_page_alloc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	79 10                	jns    801ca4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	56                   	push   %esi
  801c98:	e8 18 02 00 00       	call   801eb5 <nsipc_close>
		return r;
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	eb 24                	jmp    801cc8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ca4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cad:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb2:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801cb9:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	52                   	push   %edx
  801cc0:	e8 73 f6 ff ff       	call   801338 <fd2num>
  801cc5:	83 c4 10             	add    $0x10,%esp
}
  801cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	e8 50 ff ff ff       	call   801c2d <fd2sockid>
		return r;
  801cdd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 1f                	js     801d02 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ce3:	83 ec 04             	sub    $0x4,%esp
  801ce6:	ff 75 10             	pushl  0x10(%ebp)
  801ce9:	ff 75 0c             	pushl  0xc(%ebp)
  801cec:	50                   	push   %eax
  801ced:	e8 1c 01 00 00       	call   801e0e <nsipc_accept>
  801cf2:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 07                	js     801d02 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801cfb:	e8 5d ff ff ff       	call   801c5d <alloc_sockfd>
  801d00:	89 c1                	mov    %eax,%ecx
}
  801d02:	89 c8                	mov    %ecx,%eax
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	e8 19 ff ff ff       	call   801c2d <fd2sockid>
  801d14:	89 c2                	mov    %eax,%edx
  801d16:	85 d2                	test   %edx,%edx
  801d18:	78 12                	js     801d2c <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801d1a:	83 ec 04             	sub    $0x4,%esp
  801d1d:	ff 75 10             	pushl  0x10(%ebp)
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	52                   	push   %edx
  801d24:	e8 35 01 00 00       	call   801e5e <nsipc_bind>
  801d29:	83 c4 10             	add    $0x10,%esp
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <shutdown>:

int
shutdown(int s, int how)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	e8 f1 fe ff ff       	call   801c2d <fd2sockid>
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	85 d2                	test   %edx,%edx
  801d40:	78 0f                	js     801d51 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801d42:	83 ec 08             	sub    $0x8,%esp
  801d45:	ff 75 0c             	pushl  0xc(%ebp)
  801d48:	52                   	push   %edx
  801d49:	e8 45 01 00 00       	call   801e93 <nsipc_shutdown>
  801d4e:	83 c4 10             	add    $0x10,%esp
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	e8 cc fe ff ff       	call   801c2d <fd2sockid>
  801d61:	89 c2                	mov    %eax,%edx
  801d63:	85 d2                	test   %edx,%edx
  801d65:	78 12                	js     801d79 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	ff 75 10             	pushl  0x10(%ebp)
  801d6d:	ff 75 0c             	pushl  0xc(%ebp)
  801d70:	52                   	push   %edx
  801d71:	e8 59 01 00 00       	call   801ecf <nsipc_connect>
  801d76:	83 c4 10             	add    $0x10,%esp
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <listen>:

int
listen(int s, int backlog)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	e8 a4 fe ff ff       	call   801c2d <fd2sockid>
  801d89:	89 c2                	mov    %eax,%edx
  801d8b:	85 d2                	test   %edx,%edx
  801d8d:	78 0f                	js     801d9e <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801d8f:	83 ec 08             	sub    $0x8,%esp
  801d92:	ff 75 0c             	pushl  0xc(%ebp)
  801d95:	52                   	push   %edx
  801d96:	e8 69 01 00 00       	call   801f04 <nsipc_listen>
  801d9b:	83 c4 10             	add    $0x10,%esp
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801da6:	ff 75 10             	pushl  0x10(%ebp)
  801da9:	ff 75 0c             	pushl  0xc(%ebp)
  801dac:	ff 75 08             	pushl  0x8(%ebp)
  801daf:	e8 3c 02 00 00       	call   801ff0 <nsipc_socket>
  801db4:	89 c2                	mov    %eax,%edx
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	85 d2                	test   %edx,%edx
  801dbb:	78 05                	js     801dc2 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801dbd:	e8 9b fe ff ff       	call   801c5d <alloc_sockfd>
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dcd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801dd4:	75 12                	jne    801de8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801dd6:	83 ec 0c             	sub    $0xc,%esp
  801dd9:	6a 02                	push   $0x2
  801ddb:	e8 20 f5 ff ff       	call   801300 <ipc_find_env>
  801de0:	a3 04 40 80 00       	mov    %eax,0x804004
  801de5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801de8:	6a 07                	push   $0x7
  801dea:	68 00 60 80 00       	push   $0x806000
  801def:	53                   	push   %ebx
  801df0:	ff 35 04 40 80 00    	pushl  0x804004
  801df6:	e8 b1 f4 ff ff       	call   8012ac <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dfb:	83 c4 0c             	add    $0xc,%esp
  801dfe:	6a 00                	push   $0x0
  801e00:	6a 00                	push   $0x0
  801e02:	6a 00                	push   $0x0
  801e04:	e8 3a f4 ff ff       	call   801243 <ipc_recv>
}
  801e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	56                   	push   %esi
  801e12:	53                   	push   %ebx
  801e13:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e1e:	8b 06                	mov    (%esi),%eax
  801e20:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e25:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2a:	e8 95 ff ff ff       	call   801dc4 <nsipc>
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 20                	js     801e55 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	ff 35 10 60 80 00    	pushl  0x806010
  801e3e:	68 00 60 80 00       	push   $0x806000
  801e43:	ff 75 0c             	pushl  0xc(%ebp)
  801e46:	e8 eb eb ff ff       	call   800a36 <memmove>
		*addrlen = ret->ret_addrlen;
  801e4b:	a1 10 60 80 00       	mov    0x806010,%eax
  801e50:	89 06                	mov    %eax,(%esi)
  801e52:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e55:	89 d8                	mov    %ebx,%eax
  801e57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	53                   	push   %ebx
  801e62:	83 ec 08             	sub    $0x8,%esp
  801e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e68:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e70:	53                   	push   %ebx
  801e71:	ff 75 0c             	pushl  0xc(%ebp)
  801e74:	68 04 60 80 00       	push   $0x806004
  801e79:	e8 b8 eb ff ff       	call   800a36 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e7e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e84:	b8 02 00 00 00       	mov    $0x2,%eax
  801e89:	e8 36 ff ff ff       	call   801dc4 <nsipc>
}
  801e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e99:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ea9:	b8 03 00 00 00       	mov    $0x3,%eax
  801eae:	e8 11 ff ff ff       	call   801dc4 <nsipc>
}
  801eb3:	c9                   	leave  
  801eb4:	c3                   	ret    

00801eb5 <nsipc_close>:

int
nsipc_close(int s)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ec3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ec8:	e8 f7 fe ff ff       	call   801dc4 <nsipc>
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	53                   	push   %ebx
  801ed3:	83 ec 08             	sub    $0x8,%esp
  801ed6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  801edc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ee1:	53                   	push   %ebx
  801ee2:	ff 75 0c             	pushl  0xc(%ebp)
  801ee5:	68 04 60 80 00       	push   $0x806004
  801eea:	e8 47 eb ff ff       	call   800a36 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801eef:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ef5:	b8 05 00 00 00       	mov    $0x5,%eax
  801efa:	e8 c5 fe ff ff       	call   801dc4 <nsipc>
}
  801eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f02:	c9                   	leave  
  801f03:	c3                   	ret    

00801f04 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f15:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f1a:	b8 06 00 00 00       	mov    $0x6,%eax
  801f1f:	e8 a0 fe ff ff       	call   801dc4 <nsipc>
}
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    

00801f26 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	56                   	push   %esi
  801f2a:	53                   	push   %ebx
  801f2b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f36:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f44:	b8 07 00 00 00       	mov    $0x7,%eax
  801f49:	e8 76 fe ff ff       	call   801dc4 <nsipc>
  801f4e:	89 c3                	mov    %eax,%ebx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 35                	js     801f89 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f54:	39 f0                	cmp    %esi,%eax
  801f56:	7f 07                	jg     801f5f <nsipc_recv+0x39>
  801f58:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f5d:	7e 16                	jle    801f75 <nsipc_recv+0x4f>
  801f5f:	68 ff 2e 80 00       	push   $0x802eff
  801f64:	68 c7 2e 80 00       	push   $0x802ec7
  801f69:	6a 62                	push   $0x62
  801f6b:	68 14 2f 80 00       	push   $0x802f14
  801f70:	e8 cf e2 ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f75:	83 ec 04             	sub    $0x4,%esp
  801f78:	50                   	push   %eax
  801f79:	68 00 60 80 00       	push   $0x806000
  801f7e:	ff 75 0c             	pushl  0xc(%ebp)
  801f81:	e8 b0 ea ff ff       	call   800a36 <memmove>
  801f86:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f89:	89 d8                	mov    %ebx,%eax
  801f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	83 ec 04             	sub    $0x4,%esp
  801f99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fa4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801faa:	7e 16                	jle    801fc2 <nsipc_send+0x30>
  801fac:	68 20 2f 80 00       	push   $0x802f20
  801fb1:	68 c7 2e 80 00       	push   $0x802ec7
  801fb6:	6a 6d                	push   $0x6d
  801fb8:	68 14 2f 80 00       	push   $0x802f14
  801fbd:	e8 82 e2 ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fc2:	83 ec 04             	sub    $0x4,%esp
  801fc5:	53                   	push   %ebx
  801fc6:	ff 75 0c             	pushl  0xc(%ebp)
  801fc9:	68 0c 60 80 00       	push   $0x80600c
  801fce:	e8 63 ea ff ff       	call   800a36 <memmove>
	nsipcbuf.send.req_size = size;
  801fd3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fe1:	b8 08 00 00 00       	mov    $0x8,%eax
  801fe6:	e8 d9 fd ff ff       	call   801dc4 <nsipc>
}
  801feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802001:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802006:	8b 45 10             	mov    0x10(%ebp),%eax
  802009:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80200e:	b8 09 00 00 00       	mov    $0x9,%eax
  802013:	e8 ac fd ff ff       	call   801dc4 <nsipc>
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	56                   	push   %esi
  80201e:	53                   	push   %ebx
  80201f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802022:	83 ec 0c             	sub    $0xc,%esp
  802025:	ff 75 08             	pushl  0x8(%ebp)
  802028:	e8 1b f3 ff ff       	call   801348 <fd2data>
  80202d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80202f:	83 c4 08             	add    $0x8,%esp
  802032:	68 2c 2f 80 00       	push   $0x802f2c
  802037:	53                   	push   %ebx
  802038:	e8 67 e8 ff ff       	call   8008a4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80203d:	8b 56 04             	mov    0x4(%esi),%edx
  802040:	89 d0                	mov    %edx,%eax
  802042:	2b 06                	sub    (%esi),%eax
  802044:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80204a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802051:	00 00 00 
	stat->st_dev = &devpipe;
  802054:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80205b:	30 80 00 
	return 0;
}
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
  802063:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802066:	5b                   	pop    %ebx
  802067:	5e                   	pop    %esi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    

0080206a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	53                   	push   %ebx
  80206e:	83 ec 0c             	sub    $0xc,%esp
  802071:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802074:	53                   	push   %ebx
  802075:	6a 00                	push   $0x0
  802077:	e8 b6 ec ff ff       	call   800d32 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80207c:	89 1c 24             	mov    %ebx,(%esp)
  80207f:	e8 c4 f2 ff ff       	call   801348 <fd2data>
  802084:	83 c4 08             	add    $0x8,%esp
  802087:	50                   	push   %eax
  802088:	6a 00                	push   $0x0
  80208a:	e8 a3 ec ff ff       	call   800d32 <sys_page_unmap>
}
  80208f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	57                   	push   %edi
  802098:	56                   	push   %esi
  802099:	53                   	push   %ebx
  80209a:	83 ec 1c             	sub    $0x1c,%esp
  80209d:	89 c6                	mov    %eax,%esi
  80209f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020a2:	a1 08 40 80 00       	mov    0x804008,%eax
  8020a7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	56                   	push   %esi
  8020ae:	e8 bb fa ff ff       	call   801b6e <pageref>
  8020b3:	89 c7                	mov    %eax,%edi
  8020b5:	83 c4 04             	add    $0x4,%esp
  8020b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020bb:	e8 ae fa ff ff       	call   801b6e <pageref>
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	39 c7                	cmp    %eax,%edi
  8020c5:	0f 94 c2             	sete   %dl
  8020c8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8020cb:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8020d1:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8020d4:	39 fb                	cmp    %edi,%ebx
  8020d6:	74 19                	je     8020f1 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8020d8:	84 d2                	test   %dl,%dl
  8020da:	74 c6                	je     8020a2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020dc:	8b 51 58             	mov    0x58(%ecx),%edx
  8020df:	50                   	push   %eax
  8020e0:	52                   	push   %edx
  8020e1:	53                   	push   %ebx
  8020e2:	68 33 2f 80 00       	push   $0x802f33
  8020e7:	e8 31 e2 ff ff       	call   80031d <cprintf>
  8020ec:	83 c4 10             	add    $0x10,%esp
  8020ef:	eb b1                	jmp    8020a2 <_pipeisclosed+0xe>
	}
}
  8020f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    

008020f9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	57                   	push   %edi
  8020fd:	56                   	push   %esi
  8020fe:	53                   	push   %ebx
  8020ff:	83 ec 28             	sub    $0x28,%esp
  802102:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802105:	56                   	push   %esi
  802106:	e8 3d f2 ff ff       	call   801348 <fd2data>
  80210b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	bf 00 00 00 00       	mov    $0x0,%edi
  802115:	eb 4b                	jmp    802162 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802117:	89 da                	mov    %ebx,%edx
  802119:	89 f0                	mov    %esi,%eax
  80211b:	e8 74 ff ff ff       	call   802094 <_pipeisclosed>
  802120:	85 c0                	test   %eax,%eax
  802122:	75 48                	jne    80216c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802124:	e8 65 eb ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802129:	8b 43 04             	mov    0x4(%ebx),%eax
  80212c:	8b 0b                	mov    (%ebx),%ecx
  80212e:	8d 51 20             	lea    0x20(%ecx),%edx
  802131:	39 d0                	cmp    %edx,%eax
  802133:	73 e2                	jae    802117 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802138:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80213c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80213f:	89 c2                	mov    %eax,%edx
  802141:	c1 fa 1f             	sar    $0x1f,%edx
  802144:	89 d1                	mov    %edx,%ecx
  802146:	c1 e9 1b             	shr    $0x1b,%ecx
  802149:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80214c:	83 e2 1f             	and    $0x1f,%edx
  80214f:	29 ca                	sub    %ecx,%edx
  802151:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802159:	83 c0 01             	add    $0x1,%eax
  80215c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80215f:	83 c7 01             	add    $0x1,%edi
  802162:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802165:	75 c2                	jne    802129 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802167:	8b 45 10             	mov    0x10(%ebp),%eax
  80216a:	eb 05                	jmp    802171 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80216c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802171:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    

00802179 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	57                   	push   %edi
  80217d:	56                   	push   %esi
  80217e:	53                   	push   %ebx
  80217f:	83 ec 18             	sub    $0x18,%esp
  802182:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802185:	57                   	push   %edi
  802186:	e8 bd f1 ff ff       	call   801348 <fd2data>
  80218b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80218d:	83 c4 10             	add    $0x10,%esp
  802190:	bb 00 00 00 00       	mov    $0x0,%ebx
  802195:	eb 3d                	jmp    8021d4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802197:	85 db                	test   %ebx,%ebx
  802199:	74 04                	je     80219f <devpipe_read+0x26>
				return i;
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	eb 44                	jmp    8021e3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	89 f8                	mov    %edi,%eax
  8021a3:	e8 ec fe ff ff       	call   802094 <_pipeisclosed>
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	75 32                	jne    8021de <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021ac:	e8 dd ea ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021b1:	8b 06                	mov    (%esi),%eax
  8021b3:	3b 46 04             	cmp    0x4(%esi),%eax
  8021b6:	74 df                	je     802197 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021b8:	99                   	cltd   
  8021b9:	c1 ea 1b             	shr    $0x1b,%edx
  8021bc:	01 d0                	add    %edx,%eax
  8021be:	83 e0 1f             	and    $0x1f,%eax
  8021c1:	29 d0                	sub    %edx,%eax
  8021c3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021cb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021ce:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d1:	83 c3 01             	add    $0x1,%ebx
  8021d4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021d7:	75 d8                	jne    8021b1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8021dc:	eb 05                	jmp    8021e3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021de:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e6:	5b                   	pop    %ebx
  8021e7:	5e                   	pop    %esi
  8021e8:	5f                   	pop    %edi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    

008021eb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	56                   	push   %esi
  8021ef:	53                   	push   %ebx
  8021f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f6:	50                   	push   %eax
  8021f7:	e8 63 f1 ff ff       	call   80135f <fd_alloc>
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	89 c2                	mov    %eax,%edx
  802201:	85 c0                	test   %eax,%eax
  802203:	0f 88 2c 01 00 00    	js     802335 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802209:	83 ec 04             	sub    $0x4,%esp
  80220c:	68 07 04 00 00       	push   $0x407
  802211:	ff 75 f4             	pushl  -0xc(%ebp)
  802214:	6a 00                	push   $0x0
  802216:	e8 92 ea ff ff       	call   800cad <sys_page_alloc>
  80221b:	83 c4 10             	add    $0x10,%esp
  80221e:	89 c2                	mov    %eax,%edx
  802220:	85 c0                	test   %eax,%eax
  802222:	0f 88 0d 01 00 00    	js     802335 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802228:	83 ec 0c             	sub    $0xc,%esp
  80222b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80222e:	50                   	push   %eax
  80222f:	e8 2b f1 ff ff       	call   80135f <fd_alloc>
  802234:	89 c3                	mov    %eax,%ebx
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	85 c0                	test   %eax,%eax
  80223b:	0f 88 e2 00 00 00    	js     802323 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802241:	83 ec 04             	sub    $0x4,%esp
  802244:	68 07 04 00 00       	push   $0x407
  802249:	ff 75 f0             	pushl  -0x10(%ebp)
  80224c:	6a 00                	push   $0x0
  80224e:	e8 5a ea ff ff       	call   800cad <sys_page_alloc>
  802253:	89 c3                	mov    %eax,%ebx
  802255:	83 c4 10             	add    $0x10,%esp
  802258:	85 c0                	test   %eax,%eax
  80225a:	0f 88 c3 00 00 00    	js     802323 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802260:	83 ec 0c             	sub    $0xc,%esp
  802263:	ff 75 f4             	pushl  -0xc(%ebp)
  802266:	e8 dd f0 ff ff       	call   801348 <fd2data>
  80226b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80226d:	83 c4 0c             	add    $0xc,%esp
  802270:	68 07 04 00 00       	push   $0x407
  802275:	50                   	push   %eax
  802276:	6a 00                	push   $0x0
  802278:	e8 30 ea ff ff       	call   800cad <sys_page_alloc>
  80227d:	89 c3                	mov    %eax,%ebx
  80227f:	83 c4 10             	add    $0x10,%esp
  802282:	85 c0                	test   %eax,%eax
  802284:	0f 88 89 00 00 00    	js     802313 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80228a:	83 ec 0c             	sub    $0xc,%esp
  80228d:	ff 75 f0             	pushl  -0x10(%ebp)
  802290:	e8 b3 f0 ff ff       	call   801348 <fd2data>
  802295:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80229c:	50                   	push   %eax
  80229d:	6a 00                	push   $0x0
  80229f:	56                   	push   %esi
  8022a0:	6a 00                	push   $0x0
  8022a2:	e8 49 ea ff ff       	call   800cf0 <sys_page_map>
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	83 c4 20             	add    $0x20,%esp
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	78 55                	js     802305 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ce:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022da:	83 ec 0c             	sub    $0xc,%esp
  8022dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e0:	e8 53 f0 ff ff       	call   801338 <fd2num>
  8022e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022e8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022ea:	83 c4 04             	add    $0x4,%esp
  8022ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8022f0:	e8 43 f0 ff ff       	call   801338 <fd2num>
  8022f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022f8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022fb:	83 c4 10             	add    $0x10,%esp
  8022fe:	ba 00 00 00 00       	mov    $0x0,%edx
  802303:	eb 30                	jmp    802335 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802305:	83 ec 08             	sub    $0x8,%esp
  802308:	56                   	push   %esi
  802309:	6a 00                	push   $0x0
  80230b:	e8 22 ea ff ff       	call   800d32 <sys_page_unmap>
  802310:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802313:	83 ec 08             	sub    $0x8,%esp
  802316:	ff 75 f0             	pushl  -0x10(%ebp)
  802319:	6a 00                	push   $0x0
  80231b:	e8 12 ea ff ff       	call   800d32 <sys_page_unmap>
  802320:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802323:	83 ec 08             	sub    $0x8,%esp
  802326:	ff 75 f4             	pushl  -0xc(%ebp)
  802329:	6a 00                	push   $0x0
  80232b:	e8 02 ea ff ff       	call   800d32 <sys_page_unmap>
  802330:	83 c4 10             	add    $0x10,%esp
  802333:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802335:	89 d0                	mov    %edx,%eax
  802337:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233a:	5b                   	pop    %ebx
  80233b:	5e                   	pop    %esi
  80233c:	5d                   	pop    %ebp
  80233d:	c3                   	ret    

0080233e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802347:	50                   	push   %eax
  802348:	ff 75 08             	pushl  0x8(%ebp)
  80234b:	e8 5e f0 ff ff       	call   8013ae <fd_lookup>
  802350:	89 c2                	mov    %eax,%edx
  802352:	83 c4 10             	add    $0x10,%esp
  802355:	85 d2                	test   %edx,%edx
  802357:	78 18                	js     802371 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802359:	83 ec 0c             	sub    $0xc,%esp
  80235c:	ff 75 f4             	pushl  -0xc(%ebp)
  80235f:	e8 e4 ef ff ff       	call   801348 <fd2data>
	return _pipeisclosed(fd, p);
  802364:	89 c2                	mov    %eax,%edx
  802366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802369:	e8 26 fd ff ff       	call   802094 <_pipeisclosed>
  80236e:	83 c4 10             	add    $0x10,%esp
}
  802371:	c9                   	leave  
  802372:	c3                   	ret    

00802373 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802376:	b8 00 00 00 00       	mov    $0x0,%eax
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    

0080237d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802383:	68 4b 2f 80 00       	push   $0x802f4b
  802388:	ff 75 0c             	pushl  0xc(%ebp)
  80238b:	e8 14 e5 ff ff       	call   8008a4 <strcpy>
	return 0;
}
  802390:	b8 00 00 00 00       	mov    $0x0,%eax
  802395:	c9                   	leave  
  802396:	c3                   	ret    

00802397 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	57                   	push   %edi
  80239b:	56                   	push   %esi
  80239c:	53                   	push   %ebx
  80239d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023a3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023a8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ae:	eb 2d                	jmp    8023dd <devcons_write+0x46>
		m = n - tot;
  8023b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023b3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023b5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023b8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023bd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023c0:	83 ec 04             	sub    $0x4,%esp
  8023c3:	53                   	push   %ebx
  8023c4:	03 45 0c             	add    0xc(%ebp),%eax
  8023c7:	50                   	push   %eax
  8023c8:	57                   	push   %edi
  8023c9:	e8 68 e6 ff ff       	call   800a36 <memmove>
		sys_cputs(buf, m);
  8023ce:	83 c4 08             	add    $0x8,%esp
  8023d1:	53                   	push   %ebx
  8023d2:	57                   	push   %edi
  8023d3:	e8 19 e8 ff ff       	call   800bf1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023d8:	01 de                	add    %ebx,%esi
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	89 f0                	mov    %esi,%eax
  8023df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023e2:	72 cc                	jb     8023b0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023f2:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023fb:	75 07                	jne    802404 <devcons_read+0x18>
  8023fd:	eb 28                	jmp    802427 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023ff:	e8 8a e8 ff ff       	call   800c8e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802404:	e8 06 e8 ff ff       	call   800c0f <sys_cgetc>
  802409:	85 c0                	test   %eax,%eax
  80240b:	74 f2                	je     8023ff <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 16                	js     802427 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802411:	83 f8 04             	cmp    $0x4,%eax
  802414:	74 0c                	je     802422 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802416:	8b 55 0c             	mov    0xc(%ebp),%edx
  802419:	88 02                	mov    %al,(%edx)
	return 1;
  80241b:	b8 01 00 00 00       	mov    $0x1,%eax
  802420:	eb 05                	jmp    802427 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802422:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802427:	c9                   	leave  
  802428:	c3                   	ret    

00802429 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80242f:	8b 45 08             	mov    0x8(%ebp),%eax
  802432:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802435:	6a 01                	push   $0x1
  802437:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80243a:	50                   	push   %eax
  80243b:	e8 b1 e7 ff ff       	call   800bf1 <sys_cputs>
  802440:	83 c4 10             	add    $0x10,%esp
}
  802443:	c9                   	leave  
  802444:	c3                   	ret    

00802445 <getchar>:

int
getchar(void)
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80244b:	6a 01                	push   $0x1
  80244d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802450:	50                   	push   %eax
  802451:	6a 00                	push   $0x0
  802453:	e8 c5 f1 ff ff       	call   80161d <read>
	if (r < 0)
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	85 c0                	test   %eax,%eax
  80245d:	78 0f                	js     80246e <getchar+0x29>
		return r;
	if (r < 1)
  80245f:	85 c0                	test   %eax,%eax
  802461:	7e 06                	jle    802469 <getchar+0x24>
		return -E_EOF;
	return c;
  802463:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802467:	eb 05                	jmp    80246e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802469:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80246e:	c9                   	leave  
  80246f:	c3                   	ret    

00802470 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802479:	50                   	push   %eax
  80247a:	ff 75 08             	pushl  0x8(%ebp)
  80247d:	e8 2c ef ff ff       	call   8013ae <fd_lookup>
  802482:	83 c4 10             	add    $0x10,%esp
  802485:	85 c0                	test   %eax,%eax
  802487:	78 11                	js     80249a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802492:	39 10                	cmp    %edx,(%eax)
  802494:	0f 94 c0             	sete   %al
  802497:	0f b6 c0             	movzbl %al,%eax
}
  80249a:	c9                   	leave  
  80249b:	c3                   	ret    

0080249c <opencons>:

int
opencons(void)
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a5:	50                   	push   %eax
  8024a6:	e8 b4 ee ff ff       	call   80135f <fd_alloc>
  8024ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8024ae:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024b0:	85 c0                	test   %eax,%eax
  8024b2:	78 3e                	js     8024f2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b4:	83 ec 04             	sub    $0x4,%esp
  8024b7:	68 07 04 00 00       	push   $0x407
  8024bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8024bf:	6a 00                	push   $0x0
  8024c1:	e8 e7 e7 ff ff       	call   800cad <sys_page_alloc>
  8024c6:	83 c4 10             	add    $0x10,%esp
		return r;
  8024c9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	78 23                	js     8024f2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024cf:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024e4:	83 ec 0c             	sub    $0xc,%esp
  8024e7:	50                   	push   %eax
  8024e8:	e8 4b ee ff ff       	call   801338 <fd2num>
  8024ed:	89 c2                	mov    %eax,%edx
  8024ef:	83 c4 10             	add    $0x10,%esp
}
  8024f2:	89 d0                	mov    %edx,%eax
  8024f4:	c9                   	leave  
  8024f5:	c3                   	ret    

008024f6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024fc:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802503:	75 2c                	jne    802531 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802505:	83 ec 04             	sub    $0x4,%esp
  802508:	6a 07                	push   $0x7
  80250a:	68 00 f0 bf ee       	push   $0xeebff000
  80250f:	6a 00                	push   $0x0
  802511:	e8 97 e7 ff ff       	call   800cad <sys_page_alloc>
  802516:	83 c4 10             	add    $0x10,%esp
  802519:	85 c0                	test   %eax,%eax
  80251b:	74 14                	je     802531 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  80251d:	83 ec 04             	sub    $0x4,%esp
  802520:	68 58 2f 80 00       	push   $0x802f58
  802525:	6a 21                	push   $0x21
  802527:	68 bc 2f 80 00       	push   $0x802fbc
  80252c:	e8 13 dd ff ff       	call   800244 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802531:	8b 45 08             	mov    0x8(%ebp),%eax
  802534:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802539:	83 ec 08             	sub    $0x8,%esp
  80253c:	68 65 25 80 00       	push   $0x802565
  802541:	6a 00                	push   $0x0
  802543:	e8 b0 e8 ff ff       	call   800df8 <sys_env_set_pgfault_upcall>
  802548:	83 c4 10             	add    $0x10,%esp
  80254b:	85 c0                	test   %eax,%eax
  80254d:	79 14                	jns    802563 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80254f:	83 ec 04             	sub    $0x4,%esp
  802552:	68 84 2f 80 00       	push   $0x802f84
  802557:	6a 29                	push   $0x29
  802559:	68 bc 2f 80 00       	push   $0x802fbc
  80255e:	e8 e1 dc ff ff       	call   800244 <_panic>
}
  802563:	c9                   	leave  
  802564:	c3                   	ret    

00802565 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802565:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802566:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80256b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80256d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802570:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802575:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802579:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80257d:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80257f:	83 c4 08             	add    $0x8,%esp
        popal
  802582:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802583:	83 c4 04             	add    $0x4,%esp
        popfl
  802586:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802587:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802588:	c3                   	ret    
  802589:	66 90                	xchg   %ax,%ax
  80258b:	66 90                	xchg   %ax,%ax
  80258d:	66 90                	xchg   %ax,%ax
  80258f:	90                   	nop

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	83 ec 10             	sub    $0x10,%esp
  802596:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80259a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80259e:	8b 74 24 24          	mov    0x24(%esp),%esi
  8025a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8025a6:	85 d2                	test   %edx,%edx
  8025a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025ac:	89 34 24             	mov    %esi,(%esp)
  8025af:	89 c8                	mov    %ecx,%eax
  8025b1:	75 35                	jne    8025e8 <__udivdi3+0x58>
  8025b3:	39 f1                	cmp    %esi,%ecx
  8025b5:	0f 87 bd 00 00 00    	ja     802678 <__udivdi3+0xe8>
  8025bb:	85 c9                	test   %ecx,%ecx
  8025bd:	89 cd                	mov    %ecx,%ebp
  8025bf:	75 0b                	jne    8025cc <__udivdi3+0x3c>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	31 d2                	xor    %edx,%edx
  8025c8:	f7 f1                	div    %ecx
  8025ca:	89 c5                	mov    %eax,%ebp
  8025cc:	89 f0                	mov    %esi,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	f7 f5                	div    %ebp
  8025d2:	89 c6                	mov    %eax,%esi
  8025d4:	89 f8                	mov    %edi,%eax
  8025d6:	f7 f5                	div    %ebp
  8025d8:	89 f2                	mov    %esi,%edx
  8025da:	83 c4 10             	add    $0x10,%esp
  8025dd:	5e                   	pop    %esi
  8025de:	5f                   	pop    %edi
  8025df:	5d                   	pop    %ebp
  8025e0:	c3                   	ret    
  8025e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	3b 14 24             	cmp    (%esp),%edx
  8025eb:	77 7b                	ja     802668 <__udivdi3+0xd8>
  8025ed:	0f bd f2             	bsr    %edx,%esi
  8025f0:	83 f6 1f             	xor    $0x1f,%esi
  8025f3:	0f 84 97 00 00 00    	je     802690 <__udivdi3+0x100>
  8025f9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8025fe:	89 d7                	mov    %edx,%edi
  802600:	89 f1                	mov    %esi,%ecx
  802602:	29 f5                	sub    %esi,%ebp
  802604:	d3 e7                	shl    %cl,%edi
  802606:	89 c2                	mov    %eax,%edx
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	d3 ea                	shr    %cl,%edx
  80260c:	89 f1                	mov    %esi,%ecx
  80260e:	09 fa                	or     %edi,%edx
  802610:	8b 3c 24             	mov    (%esp),%edi
  802613:	d3 e0                	shl    %cl,%eax
  802615:	89 54 24 08          	mov    %edx,0x8(%esp)
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802623:	89 fa                	mov    %edi,%edx
  802625:	d3 ea                	shr    %cl,%edx
  802627:	89 f1                	mov    %esi,%ecx
  802629:	d3 e7                	shl    %cl,%edi
  80262b:	89 e9                	mov    %ebp,%ecx
  80262d:	d3 e8                	shr    %cl,%eax
  80262f:	09 c7                	or     %eax,%edi
  802631:	89 f8                	mov    %edi,%eax
  802633:	f7 74 24 08          	divl   0x8(%esp)
  802637:	89 d5                	mov    %edx,%ebp
  802639:	89 c7                	mov    %eax,%edi
  80263b:	f7 64 24 0c          	mull   0xc(%esp)
  80263f:	39 d5                	cmp    %edx,%ebp
  802641:	89 14 24             	mov    %edx,(%esp)
  802644:	72 11                	jb     802657 <__udivdi3+0xc7>
  802646:	8b 54 24 04          	mov    0x4(%esp),%edx
  80264a:	89 f1                	mov    %esi,%ecx
  80264c:	d3 e2                	shl    %cl,%edx
  80264e:	39 c2                	cmp    %eax,%edx
  802650:	73 5e                	jae    8026b0 <__udivdi3+0x120>
  802652:	3b 2c 24             	cmp    (%esp),%ebp
  802655:	75 59                	jne    8026b0 <__udivdi3+0x120>
  802657:	8d 47 ff             	lea    -0x1(%edi),%eax
  80265a:	31 f6                	xor    %esi,%esi
  80265c:	89 f2                	mov    %esi,%edx
  80265e:	83 c4 10             	add    $0x10,%esp
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi
  802668:	31 f6                	xor    %esi,%esi
  80266a:	31 c0                	xor    %eax,%eax
  80266c:	89 f2                	mov    %esi,%edx
  80266e:	83 c4 10             	add    $0x10,%esp
  802671:	5e                   	pop    %esi
  802672:	5f                   	pop    %edi
  802673:	5d                   	pop    %ebp
  802674:	c3                   	ret    
  802675:	8d 76 00             	lea    0x0(%esi),%esi
  802678:	89 f2                	mov    %esi,%edx
  80267a:	31 f6                	xor    %esi,%esi
  80267c:	89 f8                	mov    %edi,%eax
  80267e:	f7 f1                	div    %ecx
  802680:	89 f2                	mov    %esi,%edx
  802682:	83 c4 10             	add    $0x10,%esp
  802685:	5e                   	pop    %esi
  802686:	5f                   	pop    %edi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802694:	76 0b                	jbe    8026a1 <__udivdi3+0x111>
  802696:	31 c0                	xor    %eax,%eax
  802698:	3b 14 24             	cmp    (%esp),%edx
  80269b:	0f 83 37 ff ff ff    	jae    8025d8 <__udivdi3+0x48>
  8026a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a6:	e9 2d ff ff ff       	jmp    8025d8 <__udivdi3+0x48>
  8026ab:	90                   	nop
  8026ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	89 f8                	mov    %edi,%eax
  8026b2:	31 f6                	xor    %esi,%esi
  8026b4:	e9 1f ff ff ff       	jmp    8025d8 <__udivdi3+0x48>
  8026b9:	66 90                	xchg   %ax,%ax
  8026bb:	66 90                	xchg   %ax,%ax
  8026bd:	66 90                	xchg   %ax,%ax
  8026bf:	90                   	nop

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	83 ec 20             	sub    $0x20,%esp
  8026c6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8026ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d2:	89 c6                	mov    %eax,%esi
  8026d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8026e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8026e8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	89 c2                	mov    %eax,%edx
  8026f0:	75 1e                	jne    802710 <__umoddi3+0x50>
  8026f2:	39 f7                	cmp    %esi,%edi
  8026f4:	76 52                	jbe    802748 <__umoddi3+0x88>
  8026f6:	89 c8                	mov    %ecx,%eax
  8026f8:	89 f2                	mov    %esi,%edx
  8026fa:	f7 f7                	div    %edi
  8026fc:	89 d0                	mov    %edx,%eax
  8026fe:	31 d2                	xor    %edx,%edx
  802700:	83 c4 20             	add    $0x20,%esp
  802703:	5e                   	pop    %esi
  802704:	5f                   	pop    %edi
  802705:	5d                   	pop    %ebp
  802706:	c3                   	ret    
  802707:	89 f6                	mov    %esi,%esi
  802709:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802710:	39 f0                	cmp    %esi,%eax
  802712:	77 5c                	ja     802770 <__umoddi3+0xb0>
  802714:	0f bd e8             	bsr    %eax,%ebp
  802717:	83 f5 1f             	xor    $0x1f,%ebp
  80271a:	75 64                	jne    802780 <__umoddi3+0xc0>
  80271c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802720:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802724:	0f 86 f6 00 00 00    	jbe    802820 <__umoddi3+0x160>
  80272a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80272e:	0f 82 ec 00 00 00    	jb     802820 <__umoddi3+0x160>
  802734:	8b 44 24 14          	mov    0x14(%esp),%eax
  802738:	8b 54 24 18          	mov    0x18(%esp),%edx
  80273c:	83 c4 20             	add    $0x20,%esp
  80273f:	5e                   	pop    %esi
  802740:	5f                   	pop    %edi
  802741:	5d                   	pop    %ebp
  802742:	c3                   	ret    
  802743:	90                   	nop
  802744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802748:	85 ff                	test   %edi,%edi
  80274a:	89 fd                	mov    %edi,%ebp
  80274c:	75 0b                	jne    802759 <__umoddi3+0x99>
  80274e:	b8 01 00 00 00       	mov    $0x1,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f7                	div    %edi
  802757:	89 c5                	mov    %eax,%ebp
  802759:	8b 44 24 10          	mov    0x10(%esp),%eax
  80275d:	31 d2                	xor    %edx,%edx
  80275f:	f7 f5                	div    %ebp
  802761:	89 c8                	mov    %ecx,%eax
  802763:	f7 f5                	div    %ebp
  802765:	eb 95                	jmp    8026fc <__umoddi3+0x3c>
  802767:	89 f6                	mov    %esi,%esi
  802769:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802770:	89 c8                	mov    %ecx,%eax
  802772:	89 f2                	mov    %esi,%edx
  802774:	83 c4 20             	add    $0x20,%esp
  802777:	5e                   	pop    %esi
  802778:	5f                   	pop    %edi
  802779:	5d                   	pop    %ebp
  80277a:	c3                   	ret    
  80277b:	90                   	nop
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	b8 20 00 00 00       	mov    $0x20,%eax
  802785:	89 e9                	mov    %ebp,%ecx
  802787:	29 e8                	sub    %ebp,%eax
  802789:	d3 e2                	shl    %cl,%edx
  80278b:	89 c7                	mov    %eax,%edi
  80278d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802791:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802795:	89 f9                	mov    %edi,%ecx
  802797:	d3 e8                	shr    %cl,%eax
  802799:	89 c1                	mov    %eax,%ecx
  80279b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80279f:	09 d1                	or     %edx,%ecx
  8027a1:	89 fa                	mov    %edi,%edx
  8027a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8027a7:	89 e9                	mov    %ebp,%ecx
  8027a9:	d3 e0                	shl    %cl,%eax
  8027ab:	89 f9                	mov    %edi,%ecx
  8027ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027b1:	89 f0                	mov    %esi,%eax
  8027b3:	d3 e8                	shr    %cl,%eax
  8027b5:	89 e9                	mov    %ebp,%ecx
  8027b7:	89 c7                	mov    %eax,%edi
  8027b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8027bd:	d3 e6                	shl    %cl,%esi
  8027bf:	89 d1                	mov    %edx,%ecx
  8027c1:	89 fa                	mov    %edi,%edx
  8027c3:	d3 e8                	shr    %cl,%eax
  8027c5:	89 e9                	mov    %ebp,%ecx
  8027c7:	09 f0                	or     %esi,%eax
  8027c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8027cd:	f7 74 24 10          	divl   0x10(%esp)
  8027d1:	d3 e6                	shl    %cl,%esi
  8027d3:	89 d1                	mov    %edx,%ecx
  8027d5:	f7 64 24 0c          	mull   0xc(%esp)
  8027d9:	39 d1                	cmp    %edx,%ecx
  8027db:	89 74 24 14          	mov    %esi,0x14(%esp)
  8027df:	89 d7                	mov    %edx,%edi
  8027e1:	89 c6                	mov    %eax,%esi
  8027e3:	72 0a                	jb     8027ef <__umoddi3+0x12f>
  8027e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8027e9:	73 10                	jae    8027fb <__umoddi3+0x13b>
  8027eb:	39 d1                	cmp    %edx,%ecx
  8027ed:	75 0c                	jne    8027fb <__umoddi3+0x13b>
  8027ef:	89 d7                	mov    %edx,%edi
  8027f1:	89 c6                	mov    %eax,%esi
  8027f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8027f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8027fb:	89 ca                	mov    %ecx,%edx
  8027fd:	89 e9                	mov    %ebp,%ecx
  8027ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802803:	29 f0                	sub    %esi,%eax
  802805:	19 fa                	sbb    %edi,%edx
  802807:	d3 e8                	shr    %cl,%eax
  802809:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80280e:	89 d7                	mov    %edx,%edi
  802810:	d3 e7                	shl    %cl,%edi
  802812:	89 e9                	mov    %ebp,%ecx
  802814:	09 f8                	or     %edi,%eax
  802816:	d3 ea                	shr    %cl,%edx
  802818:	83 c4 20             	add    $0x20,%esp
  80281b:	5e                   	pop    %esi
  80281c:	5f                   	pop    %edi
  80281d:	5d                   	pop    %ebp
  80281e:	c3                   	ret    
  80281f:	90                   	nop
  802820:	8b 74 24 10          	mov    0x10(%esp),%esi
  802824:	29 f9                	sub    %edi,%ecx
  802826:	19 c6                	sbb    %eax,%esi
  802828:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80282c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802830:	e9 ff fe ff ff       	jmp    802734 <__umoddi3+0x74>
