
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 40 80 00 80 	movl   $0x802980,0x804004
  800042:	29 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 3b 21 00 00       	call   802189 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 8c 29 80 00       	push   $0x80298c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 95 29 80 00       	push   $0x802995
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 81 10 00 00       	call   8010ef <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 1b 2f 80 00       	push   $0x802f1b
  80007a:	6a 11                	push   $0x11
  80007c:	68 95 29 80 00       	push   $0x802995
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 08 50 80 00       	mov    0x805008,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 a5 29 80 00       	push   $0x8029a5
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 04 14 00 00       	call   8014b6 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 50 80 00       	mov    0x805008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 c2 29 80 00       	push   $0x8029c2
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 ab 15 00 00       	call   801687 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 df 29 80 00       	push   $0x8029df
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 95 29 80 00       	push   $0x802995
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 40 80 00    	pushl  0x804000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0e 09 00 00       	call   800a1c <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 e8 29 80 00       	push   $0x8029e8
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 04 2a 80 00       	push   $0x802a04
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 08 50 80 00       	mov    0x805008,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 a5 29 80 00       	push   $0x8029a5
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 4c 13 00 00       	call   8014b6 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 50 80 00       	mov    0x805008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 17 2a 80 00       	push   $0x802a17
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 40 80 00    	pushl  0x804000
  80018c:	e8 a8 07 00 00       	call   800939 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 40 80 00    	pushl  0x804000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 29 15 00 00       	call   8016cc <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 40 80 00    	pushl  0x804000
  8001ae:	e8 86 07 00 00       	call   800939 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 34 2a 80 00       	push   $0x802a34
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 95 29 80 00       	push   $0x802995
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 df 12 00 00       	call   8014b6 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 2e 21 00 00       	call   802311 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 40 80 00 3e 	movl   $0x802a3e,0x804004
  8001ea:	2a 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 91 1f 00 00       	call   802189 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 8c 29 80 00       	push   $0x80298c
  800207:	6a 2c                	push   $0x2c
  800209:	68 95 29 80 00       	push   $0x802995
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 d7 0e 00 00       	call   8010ef <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 1b 2f 80 00       	push   $0x802f1b
  800224:	6a 2f                	push   $0x2f
  800226:	68 95 29 80 00       	push   $0x802995
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 77 12 00 00       	call   8014b6 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 4b 2a 80 00       	push   $0x802a4b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 4d 2a 80 00       	push   $0x802a4d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 6b 14 00 00       	call   8016cc <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 4f 2a 80 00       	push   $0x802a4f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 2d 12 00 00       	call   8014b6 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 22 12 00 00       	call   8014b6 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 75 20 00 00       	call   802311 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
  8002a8:	83 c4 10             	add    $0x10,%esp
}
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8002bd:	e8 7b 0a 00 00       	call   800d3d <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
  8002ee:	83 c4 10             	add    $0x10,%esp
}
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 e0 11 00 00       	call   8014e3 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 ef 09 00 00       	call   800cfc <sys_env_destroy>
  80030d:	83 c4 10             	add    $0x10,%esp
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800320:	e8 18 0a 00 00       	call   800d3d <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 d0 2a 80 00       	push   $0x802ad0
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 37 09 00 00       	call   800cbf <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 4f 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 dc 08 00 00       	call   800cbf <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 d1                	mov    %edx,%ecx
  800414:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800417:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80041a:	8b 45 10             	mov    0x10(%ebp),%eax
  80041d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80042d:	72 05                	jb     800434 <printnum+0x35>
  80042f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800432:	77 3e                	ja     800472 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800434:	83 ec 0c             	sub    $0xc,%esp
  800437:	ff 75 18             	pushl  0x18(%ebp)
  80043a:	83 eb 01             	sub    $0x1,%ebx
  80043d:	53                   	push   %ebx
  80043e:	50                   	push   %eax
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 5d 22 00 00       	call   8026b0 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 13                	jmp    800479 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	85 db                	test   %ebx,%ebx
  800477:	7f ed                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	83 ec 04             	sub    $0x4,%esp
  800480:	ff 75 e4             	pushl  -0x1c(%ebp)
  800483:	ff 75 e0             	pushl  -0x20(%ebp)
  800486:	ff 75 dc             	pushl  -0x24(%ebp)
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	e8 4f 23 00 00       	call   8027e0 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 f3 2a 80 00 	movsbl 0x802af3(%eax),%eax
  80049b:	50                   	push   %eax
  80049c:	ff d7                	call   *%edi
  80049e:	83 c4 10             	add    $0x10,%esp
}
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ac:	83 fa 01             	cmp    $0x1,%edx
  8004af:	7e 0e                	jle    8004bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b1:	8b 10                	mov    (%eax),%edx
  8004b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 02                	mov    (%edx),%eax
  8004ba:	8b 52 04             	mov    0x4(%edx),%edx
  8004bd:	eb 22                	jmp    8004e1 <getuint+0x38>
	else if (lflag)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 10                	je     8004d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	eb 0e                	jmp    8004e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f2:	73 0a                	jae    8004fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	88 02                	mov    %al,(%edx)
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800509:	50                   	push   %eax
  80050a:	ff 75 10             	pushl  0x10(%ebp)
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 05 00 00 00       	call   80051d <vprintfmt>
	va_end(ap);
  800518:	83 c4 10             	add    $0x10,%esp
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052f:	eb 12                	jmp    800543 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800531:	85 c0                	test   %eax,%eax
  800533:	0f 84 90 03 00 00    	je     8008c9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	50                   	push   %eax
  80053e:	ff d6                	call   *%esi
  800540:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800543:	83 c7 01             	add    $0x1,%edi
  800546:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054a:	83 f8 25             	cmp    $0x25,%eax
  80054d:	75 e2                	jne    800531 <vprintfmt+0x14>
  80054f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800553:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800561:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800568:	ba 00 00 00 00       	mov    $0x0,%edx
  80056d:	eb 07                	jmp    800576 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800572:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8d 47 01             	lea    0x1(%edi),%eax
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	0f b6 07             	movzbl (%edi),%eax
  80057f:	0f b6 c8             	movzbl %al,%ecx
  800582:	83 e8 23             	sub    $0x23,%eax
  800585:	3c 55                	cmp    $0x55,%al
  800587:	0f 87 21 03 00 00    	ja     8008ae <vprintfmt+0x391>
  80058d:	0f b6 c0             	movzbl %al,%eax
  800590:	ff 24 85 40 2c 80 00 	jmp    *0x802c40(,%eax,4)
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059e:	eb d6                	jmp    800576 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ae:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b8:	83 fa 09             	cmp    $0x9,%edx
  8005bb:	77 39                	ja     8005f6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c0:	eb e9                	jmp    8005ab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d3:	eb 27                	jmp    8005fc <vprintfmt+0xdf>
  8005d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	0f 49 c8             	cmovns %eax,%ecx
  8005e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	eb 8c                	jmp    800576 <vprintfmt+0x59>
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f4:	eb 80                	jmp    800576 <vprintfmt+0x59>
  8005f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800600:	0f 89 70 ff ff ff    	jns    800576 <vprintfmt+0x59>
				width = precision, precision = -1;
  800606:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800609:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800613:	e9 5e ff ff ff       	jmp    800576 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800618:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061e:	e9 53 ff ff ff       	jmp    800576 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	ff 30                	pushl  (%eax)
  800632:	ff d6                	call   *%esi
			break;
  800634:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063a:	e9 04 ff ff ff       	jmp    800543 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	99                   	cltd   
  80064b:	31 d0                	xor    %edx,%eax
  80064d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064f:	83 f8 0f             	cmp    $0xf,%eax
  800652:	7f 0b                	jg     80065f <vprintfmt+0x142>
  800654:	8b 14 85 c0 2d 80 00 	mov    0x802dc0(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	75 18                	jne    800677 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 0b 2b 80 00       	push   $0x802b0b
  800665:	53                   	push   %ebx
  800666:	56                   	push   %esi
  800667:	e8 94 fe ff ff       	call   800500 <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800672:	e9 cc fe ff ff       	jmp    800543 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800677:	52                   	push   %edx
  800678:	68 31 30 80 00       	push   $0x803031
  80067d:	53                   	push   %ebx
  80067e:	56                   	push   %esi
  80067f:	e8 7c fe ff ff       	call   800500 <printfmt>
  800684:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068a:	e9 b4 fe ff ff       	jmp    800543 <vprintfmt+0x26>
  80068f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800692:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800695:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a3:	85 ff                	test   %edi,%edi
  8006a5:	ba 04 2b 80 00       	mov    $0x802b04,%edx
  8006aa:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006ad:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b1:	0f 84 92 00 00 00    	je     800749 <vprintfmt+0x22c>
  8006b7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006bb:	0f 8e 96 00 00 00    	jle    800757 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	51                   	push   %ecx
  8006c5:	57                   	push   %edi
  8006c6:	e8 86 02 00 00       	call   800951 <strnlen>
  8006cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ce:	29 c1                	sub    %eax,%ecx
  8006d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006dd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	eb 0f                	jmp    8006f3 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	83 ef 01             	sub    $0x1,%edi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 ff                	test   %edi,%edi
  8006f5:	7f ed                	jg     8006e4 <vprintfmt+0x1c7>
  8006f7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fd:	85 c9                	test   %ecx,%ecx
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	0f 49 c1             	cmovns %ecx,%eax
  800707:	29 c1                	sub    %eax,%ecx
  800709:	89 75 08             	mov    %esi,0x8(%ebp)
  80070c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800712:	89 cb                	mov    %ecx,%ebx
  800714:	eb 4d                	jmp    800763 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800716:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071a:	74 1b                	je     800737 <vprintfmt+0x21a>
  80071c:	0f be c0             	movsbl %al,%eax
  80071f:	83 e8 20             	sub    $0x20,%eax
  800722:	83 f8 5e             	cmp    $0x5e,%eax
  800725:	76 10                	jbe    800737 <vprintfmt+0x21a>
					putch('?', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	6a 3f                	push   $0x3f
  80072f:	ff 55 08             	call   *0x8(%ebp)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 0d                	jmp    800744 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	52                   	push   %edx
  80073e:	ff 55 08             	call   *0x8(%ebp)
  800741:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	eb 1a                	jmp    800763 <vprintfmt+0x246>
  800749:	89 75 08             	mov    %esi,0x8(%ebp)
  80074c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800752:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800755:	eb 0c                	jmp    800763 <vprintfmt+0x246>
  800757:	89 75 08             	mov    %esi,0x8(%ebp)
  80075a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800760:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800763:	83 c7 01             	add    $0x1,%edi
  800766:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076a:	0f be d0             	movsbl %al,%edx
  80076d:	85 d2                	test   %edx,%edx
  80076f:	74 23                	je     800794 <vprintfmt+0x277>
  800771:	85 f6                	test   %esi,%esi
  800773:	78 a1                	js     800716 <vprintfmt+0x1f9>
  800775:	83 ee 01             	sub    $0x1,%esi
  800778:	79 9c                	jns    800716 <vprintfmt+0x1f9>
  80077a:	89 df                	mov    %ebx,%edi
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800782:	eb 18                	jmp    80079c <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 20                	push   $0x20
  80078a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	eb 08                	jmp    80079c <vprintfmt+0x27f>
  800794:	89 df                	mov    %ebx,%edi
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079c:	85 ff                	test   %edi,%edi
  80079e:	7f e4                	jg     800784 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a3:	e9 9b fd ff ff       	jmp    800543 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a8:	83 fa 01             	cmp    $0x1,%edx
  8007ab:	7e 16                	jle    8007c3 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 50 08             	lea    0x8(%eax),%edx
  8007b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b6:	8b 50 04             	mov    0x4(%eax),%edx
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c1:	eb 32                	jmp    8007f5 <vprintfmt+0x2d8>
	else if (lflag)
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 18                	je     8007df <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 04             	lea    0x4(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007dd:	eb 16                	jmp    8007f5 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800800:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800804:	79 74                	jns    80087a <vprintfmt+0x35d>
				putch('-', putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	6a 2d                	push   $0x2d
  80080c:	ff d6                	call   *%esi
				num = -(long long) num;
  80080e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800811:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800814:	f7 d8                	neg    %eax
  800816:	83 d2 00             	adc    $0x0,%edx
  800819:	f7 da                	neg    %edx
  80081b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800823:	eb 55                	jmp    80087a <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 7c fc ff ff       	call   8004a9 <getuint>
			base = 10;
  80082d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800832:	eb 46                	jmp    80087a <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800834:	8d 45 14             	lea    0x14(%ebp),%eax
  800837:	e8 6d fc ff ff       	call   8004a9 <getuint>
                        base = 8;
  80083c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800841:	eb 37                	jmp    80087a <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 30                	push   $0x30
  800849:	ff d6                	call   *%esi
			putch('x', putdat);
  80084b:	83 c4 08             	add    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 78                	push   $0x78
  800851:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8d 50 04             	lea    0x4(%eax),%edx
  800859:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085c:	8b 00                	mov    (%eax),%eax
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800863:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800866:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086b:	eb 0d                	jmp    80087a <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086d:	8d 45 14             	lea    0x14(%ebp),%eax
  800870:	e8 34 fc ff ff       	call   8004a9 <getuint>
			base = 16;
  800875:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087a:	83 ec 0c             	sub    $0xc,%esp
  80087d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800881:	57                   	push   %edi
  800882:	ff 75 e0             	pushl  -0x20(%ebp)
  800885:	51                   	push   %ecx
  800886:	52                   	push   %edx
  800887:	50                   	push   %eax
  800888:	89 da                	mov    %ebx,%edx
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	e8 6e fb ff ff       	call   8003ff <printnum>
			break;
  800891:	83 c4 20             	add    $0x20,%esp
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	e9 a7 fc ff ff       	jmp    800543 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	51                   	push   %ecx
  8008a1:	ff d6                	call   *%esi
			break;
  8008a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a9:	e9 95 fc ff ff       	jmp    800543 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	6a 25                	push   $0x25
  8008b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	eb 03                	jmp    8008be <vprintfmt+0x3a1>
  8008bb:	83 ef 01             	sub    $0x1,%edi
  8008be:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c2:	75 f7                	jne    8008bb <vprintfmt+0x39e>
  8008c4:	e9 7a fc ff ff       	jmp    800543 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5f                   	pop    %edi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 18             	sub    $0x18,%esp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	74 26                	je     800918 <vsnprintf+0x47>
  8008f2:	85 d2                	test   %edx,%edx
  8008f4:	7e 22                	jle    800918 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f6:	ff 75 14             	pushl  0x14(%ebp)
  8008f9:	ff 75 10             	pushl  0x10(%ebp)
  8008fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ff:	50                   	push   %eax
  800900:	68 e3 04 80 00       	push   $0x8004e3
  800905:	e8 13 fc ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	eb 05                	jmp    80091d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800918:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800925:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800928:	50                   	push   %eax
  800929:	ff 75 10             	pushl  0x10(%ebp)
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 9a ff ff ff       	call   8008d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb 03                	jmp    800949 <strlen+0x10>
		n++;
  800946:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800949:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094d:	75 f7                	jne    800946 <strlen+0xd>
		n++;
	return n;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	eb 03                	jmp    800964 <strnlen+0x13>
		n++;
  800961:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800964:	39 c2                	cmp    %eax,%edx
  800966:	74 08                	je     800970 <strnlen+0x1f>
  800968:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096c:	75 f3                	jne    800961 <strnlen+0x10>
  80096e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097c:	89 c2                	mov    %eax,%edx
  80097e:	83 c2 01             	add    $0x1,%edx
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800988:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098b:	84 db                	test   %bl,%bl
  80098d:	75 ef                	jne    80097e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800999:	53                   	push   %ebx
  80099a:	e8 9a ff ff ff       	call   800939 <strlen>
  80099f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a2:	ff 75 0c             	pushl  0xc(%ebp)
  8009a5:	01 d8                	add    %ebx,%eax
  8009a7:	50                   	push   %eax
  8009a8:	e8 c5 ff ff ff       	call   800972 <strcpy>
	return dst;
}
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bf:	89 f3                	mov    %esi,%ebx
  8009c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c4:	89 f2                	mov    %esi,%edx
  8009c6:	eb 0f                	jmp    8009d7 <strncpy+0x23>
		*dst++ = *src;
  8009c8:	83 c2 01             	add    $0x1,%edx
  8009cb:	0f b6 01             	movzbl (%ecx),%eax
  8009ce:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	75 ed                	jne    8009c8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009db:	89 f0                	mov    %esi,%eax
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f1:	85 d2                	test   %edx,%edx
  8009f3:	74 21                	je     800a16 <strlcpy+0x35>
  8009f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f9:	89 f2                	mov    %esi,%edx
  8009fb:	eb 09                	jmp    800a06 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fd:	83 c2 01             	add    $0x1,%edx
  800a00:	83 c1 01             	add    $0x1,%ecx
  800a03:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a06:	39 c2                	cmp    %eax,%edx
  800a08:	74 09                	je     800a13 <strlcpy+0x32>
  800a0a:	0f b6 19             	movzbl (%ecx),%ebx
  800a0d:	84 db                	test   %bl,%bl
  800a0f:	75 ec                	jne    8009fd <strlcpy+0x1c>
  800a11:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a13:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a16:	29 f0                	sub    %esi,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strcmp+0x11>
		p++, q++;
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	84 c0                	test   %al,%al
  800a32:	74 04                	je     800a38 <strcmp+0x1c>
  800a34:	3a 02                	cmp    (%edx),%al
  800a36:	74 ef                	je     800a27 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 c0             	movzbl %al,%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a51:	eb 06                	jmp    800a59 <strncmp+0x17>
		n--, p++, q++;
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a59:	39 d8                	cmp    %ebx,%eax
  800a5b:	74 15                	je     800a72 <strncmp+0x30>
  800a5d:	0f b6 08             	movzbl (%eax),%ecx
  800a60:	84 c9                	test   %cl,%cl
  800a62:	74 04                	je     800a68 <strncmp+0x26>
  800a64:	3a 0a                	cmp    (%edx),%cl
  800a66:	74 eb                	je     800a53 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
  800a70:	eb 05                	jmp    800a77 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a84:	eb 07                	jmp    800a8d <strchr+0x13>
		if (*s == c)
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	74 0f                	je     800a99 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f2                	jne    800a86 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	eb 03                	jmp    800aaa <strfind+0xf>
  800aa7:	83 c0 01             	add    $0x1,%eax
  800aaa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aad:	84 d2                	test   %dl,%dl
  800aaf:	74 04                	je     800ab5 <strfind+0x1a>
  800ab1:	38 ca                	cmp    %cl,%dl
  800ab3:	75 f2                	jne    800aa7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac3:	85 c9                	test   %ecx,%ecx
  800ac5:	74 36                	je     800afd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acd:	75 28                	jne    800af7 <memset+0x40>
  800acf:	f6 c1 03             	test   $0x3,%cl
  800ad2:	75 23                	jne    800af7 <memset+0x40>
		c &= 0xFF;
  800ad4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	c1 e3 08             	shl    $0x8,%ebx
  800add:	89 d6                	mov    %edx,%esi
  800adf:	c1 e6 18             	shl    $0x18,%esi
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	c1 e0 10             	shl    $0x10,%eax
  800ae7:	09 f0                	or     %esi,%eax
  800ae9:	09 c2                	or     %eax,%edx
  800aeb:	89 d0                	mov    %edx,%eax
  800aed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af2:	fc                   	cld    
  800af3:	f3 ab                	rep stos %eax,%es:(%edi)
  800af5:	eb 06                	jmp    800afd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	fc                   	cld    
  800afb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b12:	39 c6                	cmp    %eax,%esi
  800b14:	73 35                	jae    800b4b <memmove+0x47>
  800b16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b19:	39 d0                	cmp    %edx,%eax
  800b1b:	73 2e                	jae    800b4b <memmove+0x47>
		s += n;
		d += n;
  800b1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2a:	75 13                	jne    800b3f <memmove+0x3b>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 0e                	jne    800b3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b31:	83 ef 04             	sub    $0x4,%edi
  800b34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b3a:	fd                   	std    
  800b3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3d:	eb 09                	jmp    800b48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3f:	83 ef 01             	sub    $0x1,%edi
  800b42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b45:	fd                   	std    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b48:	fc                   	cld    
  800b49:	eb 1d                	jmp    800b68 <memmove+0x64>
  800b4b:	89 f2                	mov    %esi,%edx
  800b4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	f6 c2 03             	test   $0x3,%dl
  800b52:	75 0f                	jne    800b63 <memmove+0x5f>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 0a                	jne    800b63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b61:	eb 05                	jmp    800b68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	fc                   	cld    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6f:	ff 75 10             	pushl  0x10(%ebp)
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	ff 75 08             	pushl  0x8(%ebp)
  800b78:	e8 87 ff ff ff       	call   800b04 <memmove>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	eb 1a                	jmp    800bab <memcmp+0x2c>
		if (*s1 != *s2)
  800b91:	0f b6 08             	movzbl (%eax),%ecx
  800b94:	0f b6 1a             	movzbl (%edx),%ebx
  800b97:	38 d9                	cmp    %bl,%cl
  800b99:	74 0a                	je     800ba5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9b:	0f b6 c1             	movzbl %cl,%eax
  800b9e:	0f b6 db             	movzbl %bl,%ebx
  800ba1:	29 d8                	sub    %ebx,%eax
  800ba3:	eb 0f                	jmp    800bb4 <memcmp+0x35>
		s1++, s2++;
  800ba5:	83 c0 01             	add    $0x1,%eax
  800ba8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bab:	39 f0                	cmp    %esi,%eax
  800bad:	75 e2                	jne    800b91 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc6:	eb 07                	jmp    800bcf <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	38 08                	cmp    %cl,(%eax)
  800bca:	74 07                	je     800bd3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcc:	83 c0 01             	add    $0x1,%eax
  800bcf:	39 d0                	cmp    %edx,%eax
  800bd1:	72 f5                	jb     800bc8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be1:	eb 03                	jmp    800be6 <strtol+0x11>
		s++;
  800be3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be6:	0f b6 01             	movzbl (%ecx),%eax
  800be9:	3c 09                	cmp    $0x9,%al
  800beb:	74 f6                	je     800be3 <strtol+0xe>
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 f2                	je     800be3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf1:	3c 2b                	cmp    $0x2b,%al
  800bf3:	75 0a                	jne    800bff <strtol+0x2a>
		s++;
  800bf5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfd:	eb 10                	jmp    800c0f <strtol+0x3a>
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c04:	3c 2d                	cmp    $0x2d,%al
  800c06:	75 07                	jne    800c0f <strtol+0x3a>
		s++, neg = 1;
  800c08:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c0b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0f:	85 db                	test   %ebx,%ebx
  800c11:	0f 94 c0             	sete   %al
  800c14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1a:	75 19                	jne    800c35 <strtol+0x60>
  800c1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1f:	75 14                	jne    800c35 <strtol+0x60>
  800c21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c25:	0f 85 82 00 00 00    	jne    800cad <strtol+0xd8>
		s += 2, base = 16;
  800c2b:	83 c1 02             	add    $0x2,%ecx
  800c2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c33:	eb 16                	jmp    800c4b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c35:	84 c0                	test   %al,%al
  800c37:	74 12                	je     800c4b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c39:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c41:	75 08                	jne    800c4b <strtol+0x76>
		s++, base = 8;
  800c43:	83 c1 01             	add    $0x1,%ecx
  800c46:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c50:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c53:	0f b6 11             	movzbl (%ecx),%edx
  800c56:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c59:	89 f3                	mov    %esi,%ebx
  800c5b:	80 fb 09             	cmp    $0x9,%bl
  800c5e:	77 08                	ja     800c68 <strtol+0x93>
			dig = *s - '0';
  800c60:	0f be d2             	movsbl %dl,%edx
  800c63:	83 ea 30             	sub    $0x30,%edx
  800c66:	eb 22                	jmp    800c8a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c68:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6b:	89 f3                	mov    %esi,%ebx
  800c6d:	80 fb 19             	cmp    $0x19,%bl
  800c70:	77 08                	ja     800c7a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c72:	0f be d2             	movsbl %dl,%edx
  800c75:	83 ea 57             	sub    $0x57,%edx
  800c78:	eb 10                	jmp    800c8a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c7a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 19             	cmp    $0x19,%bl
  800c82:	77 16                	ja     800c9a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c84:	0f be d2             	movsbl %dl,%edx
  800c87:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8d:	7d 0f                	jge    800c9e <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c8f:	83 c1 01             	add    $0x1,%ecx
  800c92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c96:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c98:	eb b9                	jmp    800c53 <strtol+0x7e>
  800c9a:	89 c2                	mov    %eax,%edx
  800c9c:	eb 02                	jmp    800ca0 <strtol+0xcb>
  800c9e:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ca0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca4:	74 0d                	je     800cb3 <strtol+0xde>
		*endptr = (char *) s;
  800ca6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca9:	89 0e                	mov    %ecx,(%esi)
  800cab:	eb 06                	jmp    800cb3 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cad:	84 c0                	test   %al,%al
  800caf:	75 92                	jne    800c43 <strtol+0x6e>
  800cb1:	eb 98                	jmp    800c4b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb3:	f7 da                	neg    %edx
  800cb5:	85 ff                	test   %edi,%edi
  800cb7:	0f 45 c2             	cmovne %edx,%eax
}
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 c3                	mov    %eax,%ebx
  800cd2:	89 c7                	mov    %eax,%edi
  800cd4:	89 c6                	mov    %eax,%esi
  800cd6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	89 d3                	mov    %edx,%ebx
  800cf1:	89 d7                	mov    %edx,%edi
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 cb                	mov    %ecx,%ebx
  800d14:	89 cf                	mov    %ecx,%edi
  800d16:	89 ce                	mov    %ecx,%esi
  800d18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 17                	jle    800d35 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	50                   	push   %eax
  800d22:	6a 03                	push   $0x3
  800d24:	68 1f 2e 80 00       	push   $0x802e1f
  800d29:	6a 22                	push   $0x22
  800d2b:	68 3c 2e 80 00       	push   $0x802e3c
  800d30:	e8 dd f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d43:	ba 00 00 00 00       	mov    $0x0,%edx
  800d48:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4d:	89 d1                	mov    %edx,%ecx
  800d4f:	89 d3                	mov    %edx,%ebx
  800d51:	89 d7                	mov    %edx,%edi
  800d53:	89 d6                	mov    %edx,%esi
  800d55:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_yield>:

void
sys_yield(void)
{      
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d62:	ba 00 00 00 00       	mov    $0x0,%edx
  800d67:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6c:	89 d1                	mov    %edx,%ecx
  800d6e:	89 d3                	mov    %edx,%ebx
  800d70:	89 d7                	mov    %edx,%edi
  800d72:	89 d6                	mov    %edx,%esi
  800d74:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d84:	be 00 00 00 00       	mov    $0x0,%esi
  800d89:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d97:	89 f7                	mov    %esi,%edi
  800d99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7e 17                	jle    800db6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	50                   	push   %eax
  800da3:	6a 04                	push   $0x4
  800da5:	68 1f 2e 80 00       	push   $0x802e1f
  800daa:	6a 22                	push   $0x22
  800dac:	68 3c 2e 80 00       	push   $0x802e3c
  800db1:	e8 5c f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dc7:	b8 05 00 00 00       	mov    $0x5,%eax
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd8:	8b 75 18             	mov    0x18(%ebp),%esi
  800ddb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 05                	push   $0x5
  800de7:	68 1f 2e 80 00       	push   $0x802e1f
  800dec:	6a 22                	push   $0x22
  800dee:	68 3c 2e 80 00       	push   $0x802e3c
  800df3:	e8 1a f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 06                	push   $0x6
  800e29:	68 1f 2e 80 00       	push   $0x802e1f
  800e2e:	6a 22                	push   $0x22
  800e30:	68 3c 2e 80 00       	push   $0x802e3c
  800e35:	e8 d8 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e50:	b8 08 00 00 00       	mov    $0x8,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 df                	mov    %ebx,%edi
  800e5d:	89 de                	mov    %ebx,%esi
  800e5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 17                	jle    800e7c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 08                	push   $0x8
  800e6b:	68 1f 2e 80 00       	push   $0x802e1f
  800e70:	6a 22                	push   $0x22
  800e72:	68 3c 2e 80 00       	push   $0x802e3c
  800e77:	e8 96 f4 ff ff       	call   800312 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e92:	b8 09 00 00 00       	mov    $0x9,%eax
  800e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	89 df                	mov    %ebx,%edi
  800e9f:	89 de                	mov    %ebx,%esi
  800ea1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	7e 17                	jle    800ebe <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	50                   	push   %eax
  800eab:	6a 09                	push   $0x9
  800ead:	68 1f 2e 80 00       	push   $0x802e1f
  800eb2:	6a 22                	push   $0x22
  800eb4:	68 3c 2e 80 00       	push   $0x802e3c
  800eb9:	e8 54 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ecf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 df                	mov    %ebx,%edi
  800ee1:	89 de                	mov    %ebx,%esi
  800ee3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 0a                	push   $0xa
  800eef:	68 1f 2e 80 00       	push   $0x802e1f
  800ef4:	6a 22                	push   $0x22
  800ef6:	68 3c 2e 80 00       	push   $0x802e3c
  800efb:	e8 12 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f0e:	be 00 00 00 00       	mov    $0x0,%esi
  800f13:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f21:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f24:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f39:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	89 cb                	mov    %ecx,%ebx
  800f43:	89 cf                	mov    %ecx,%edi
  800f45:	89 ce                	mov    %ecx,%esi
  800f47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	7e 17                	jle    800f64 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	50                   	push   %eax
  800f51:	6a 0d                	push   $0xd
  800f53:	68 1f 2e 80 00       	push   $0x802e1f
  800f58:	6a 22                	push   $0x22
  800f5a:	68 3c 2e 80 00       	push   $0x802e3c
  800f5f:	e8 ae f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f72:	ba 00 00 00 00       	mov    $0x0,%edx
  800f77:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f7c:	89 d1                	mov    %edx,%ecx
  800f7e:	89 d3                	mov    %edx,%ebx
  800f80:	89 d7                	mov    %edx,%edi
  800f82:	89 d6                	mov    %edx,%esi
  800f84:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <sys_transmit>:

int
sys_transmit(void *addr)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f99:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	89 cb                	mov    %ecx,%ebx
  800fa3:	89 cf                	mov    %ecx,%edi
  800fa5:	89 ce                	mov    %ecx,%esi
  800fa7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 17                	jle    800fc4 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	50                   	push   %eax
  800fb1:	6a 0f                	push   $0xf
  800fb3:	68 1f 2e 80 00       	push   $0x802e1f
  800fb8:	6a 22                	push   $0x22
  800fba:	68 3c 2e 80 00       	push   $0x802e3c
  800fbf:	e8 4e f3 ff ff       	call   800312 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5e                   	pop    %esi
  800fc9:	5f                   	pop    %edi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_recv>:

int
sys_recv(void *addr)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800fd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fda:	b8 10 00 00 00       	mov    $0x10,%eax
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	89 cb                	mov    %ecx,%ebx
  800fe4:	89 cf                	mov    %ecx,%edi
  800fe6:	89 ce                	mov    %ecx,%esi
  800fe8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 17                	jle    801005 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	6a 10                	push   $0x10
  800ff4:	68 1f 2e 80 00       	push   $0x802e1f
  800ff9:	6a 22                	push   $0x22
  800ffb:	68 3c 2e 80 00       	push   $0x802e3c
  801000:	e8 0d f3 ff ff       	call   800312 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	53                   	push   %ebx
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801017:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801019:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80101d:	74 2e                	je     80104d <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80101f:	89 c2                	mov    %eax,%edx
  801021:	c1 ea 16             	shr    $0x16,%edx
  801024:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80102b:	f6 c2 01             	test   $0x1,%dl
  80102e:	74 1d                	je     80104d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801030:	89 c2                	mov    %eax,%edx
  801032:	c1 ea 0c             	shr    $0xc,%edx
  801035:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80103c:	f6 c1 01             	test   $0x1,%cl
  80103f:	74 0c                	je     80104d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801041:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801048:	f6 c6 08             	test   $0x8,%dh
  80104b:	75 14                	jne    801061 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	68 4c 2e 80 00       	push   $0x802e4c
  801055:	6a 21                	push   $0x21
  801057:	68 df 2e 80 00       	push   $0x802edf
  80105c:	e8 b1 f2 ff ff       	call   800312 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  801061:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801066:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  801068:	83 ec 04             	sub    $0x4,%esp
  80106b:	6a 07                	push   $0x7
  80106d:	68 00 f0 7f 00       	push   $0x7ff000
  801072:	6a 00                	push   $0x0
  801074:	e8 02 fd ff ff       	call   800d7b <sys_page_alloc>
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	79 14                	jns    801094 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  801080:	83 ec 04             	sub    $0x4,%esp
  801083:	68 ea 2e 80 00       	push   $0x802eea
  801088:	6a 2b                	push   $0x2b
  80108a:	68 df 2e 80 00       	push   $0x802edf
  80108f:	e8 7e f2 ff ff       	call   800312 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	68 00 10 00 00       	push   $0x1000
  80109c:	53                   	push   %ebx
  80109d:	68 00 f0 7f 00       	push   $0x7ff000
  8010a2:	e8 5d fa ff ff       	call   800b04 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  8010a7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010ae:	53                   	push   %ebx
  8010af:	6a 00                	push   $0x0
  8010b1:	68 00 f0 7f 00       	push   $0x7ff000
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 01 fd ff ff       	call   800dbe <sys_page_map>
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	79 14                	jns    8010d8 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  8010c4:	83 ec 04             	sub    $0x4,%esp
  8010c7:	68 00 2f 80 00       	push   $0x802f00
  8010cc:	6a 2e                	push   $0x2e
  8010ce:	68 df 2e 80 00       	push   $0x802edf
  8010d3:	e8 3a f2 ff ff       	call   800312 <_panic>
        sys_page_unmap(0, PFTEMP); 
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	68 00 f0 7f 00       	push   $0x7ff000
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 19 fd ff ff       	call   800e00 <sys_page_unmap>
  8010e7:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  8010ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	57                   	push   %edi
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  8010f8:	68 0d 10 80 00       	push   $0x80100d
  8010fd:	e8 e1 13 00 00       	call   8024e3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801102:	b8 07 00 00 00       	mov    $0x7,%eax
  801107:	cd 30                	int    $0x30
  801109:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 12                	jns    801125 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801113:	50                   	push   %eax
  801114:	68 14 2f 80 00       	push   $0x802f14
  801119:	6a 6d                	push   $0x6d
  80111b:	68 df 2e 80 00       	push   $0x802edf
  801120:	e8 ed f1 ff ff       	call   800312 <_panic>
  801125:	89 c7                	mov    %eax,%edi
  801127:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  80112c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801130:	75 21                	jne    801153 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801132:	e8 06 fc ff ff       	call   800d3d <sys_getenvid>
  801137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80113f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801144:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	e9 9c 01 00 00       	jmp    8012ef <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801153:	89 d8                	mov    %ebx,%eax
  801155:	c1 e8 16             	shr    $0x16,%eax
  801158:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115f:	a8 01                	test   $0x1,%al
  801161:	0f 84 f3 00 00 00    	je     80125a <fork+0x16b>
  801167:	89 d8                	mov    %ebx,%eax
  801169:	c1 e8 0c             	shr    $0xc,%eax
  80116c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801173:	f6 c2 01             	test   $0x1,%dl
  801176:	0f 84 de 00 00 00    	je     80125a <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  80117c:	89 c6                	mov    %eax,%esi
  80117e:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801181:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801188:	f6 c6 04             	test   $0x4,%dh
  80118b:	74 37                	je     8011c4 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  80118d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	25 07 0e 00 00       	and    $0xe07,%eax
  80119c:	50                   	push   %eax
  80119d:	56                   	push   %esi
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	6a 00                	push   $0x0
  8011a2:	e8 17 fc ff ff       	call   800dbe <sys_page_map>
  8011a7:	83 c4 20             	add    $0x20,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	0f 89 a8 00 00 00    	jns    80125a <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  8011b2:	50                   	push   %eax
  8011b3:	68 70 2e 80 00       	push   $0x802e70
  8011b8:	6a 49                	push   $0x49
  8011ba:	68 df 2e 80 00       	push   $0x802edf
  8011bf:	e8 4e f1 ff ff       	call   800312 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8011c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011cb:	f6 c6 08             	test   $0x8,%dh
  8011ce:	75 0b                	jne    8011db <fork+0xec>
  8011d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d7:	a8 02                	test   $0x2,%al
  8011d9:	74 57                	je     801232 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	68 05 08 00 00       	push   $0x805
  8011e3:	56                   	push   %esi
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	6a 00                	push   $0x0
  8011e8:	e8 d1 fb ff ff       	call   800dbe <sys_page_map>
  8011ed:	83 c4 20             	add    $0x20,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	79 12                	jns    801206 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  8011f4:	50                   	push   %eax
  8011f5:	68 70 2e 80 00       	push   $0x802e70
  8011fa:	6a 4c                	push   $0x4c
  8011fc:	68 df 2e 80 00       	push   $0x802edf
  801201:	e8 0c f1 ff ff       	call   800312 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	68 05 08 00 00       	push   $0x805
  80120e:	56                   	push   %esi
  80120f:	6a 00                	push   $0x0
  801211:	56                   	push   %esi
  801212:	6a 00                	push   $0x0
  801214:	e8 a5 fb ff ff       	call   800dbe <sys_page_map>
  801219:	83 c4 20             	add    $0x20,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	79 3a                	jns    80125a <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801220:	50                   	push   %eax
  801221:	68 94 2e 80 00       	push   $0x802e94
  801226:	6a 4e                	push   $0x4e
  801228:	68 df 2e 80 00       	push   $0x802edf
  80122d:	e8 e0 f0 ff ff       	call   800312 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	6a 05                	push   $0x5
  801237:	56                   	push   %esi
  801238:	57                   	push   %edi
  801239:	56                   	push   %esi
  80123a:	6a 00                	push   $0x0
  80123c:	e8 7d fb ff ff       	call   800dbe <sys_page_map>
  801241:	83 c4 20             	add    $0x20,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	79 12                	jns    80125a <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  801248:	50                   	push   %eax
  801249:	68 bc 2e 80 00       	push   $0x802ebc
  80124e:	6a 50                	push   $0x50
  801250:	68 df 2e 80 00       	push   $0x802edf
  801255:	e8 b8 f0 ff ff       	call   800312 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80125a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801260:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801266:	0f 85 e7 fe ff ff    	jne    801153 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	6a 07                	push   $0x7
  801271:	68 00 f0 bf ee       	push   $0xeebff000
  801276:	ff 75 e4             	pushl  -0x1c(%ebp)
  801279:	e8 fd fa ff ff       	call   800d7b <sys_page_alloc>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	79 14                	jns    801299 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	68 24 2f 80 00       	push   $0x802f24
  80128d:	6a 76                	push   $0x76
  80128f:	68 df 2e 80 00       	push   $0x802edf
  801294:	e8 79 f0 ff ff       	call   800312 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	68 52 25 80 00       	push   $0x802552
  8012a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a4:	e8 1d fc ff ff       	call   800ec6 <sys_env_set_pgfault_upcall>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	79 14                	jns    8012c4 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8012b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b3:	68 3e 2f 80 00       	push   $0x802f3e
  8012b8:	6a 79                	push   $0x79
  8012ba:	68 df 2e 80 00       	push   $0x802edf
  8012bf:	e8 4e f0 ff ff       	call   800312 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	6a 02                	push   $0x2
  8012c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012cc:	e8 71 fb ff ff       	call   800e42 <sys_env_set_status>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	79 14                	jns    8012ec <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8012d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012db:	68 5b 2f 80 00       	push   $0x802f5b
  8012e0:	6a 7b                	push   $0x7b
  8012e2:	68 df 2e 80 00       	push   $0x802edf
  8012e7:	e8 26 f0 ff ff       	call   800312 <_panic>
        return forkid;
  8012ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8012ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f2:	5b                   	pop    %ebx
  8012f3:	5e                   	pop    %esi
  8012f4:	5f                   	pop    %edi
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <sfork>:

// Challenge!
int
sfork(void)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012fd:	68 72 2f 80 00       	push   $0x802f72
  801302:	68 83 00 00 00       	push   $0x83
  801307:	68 df 2e 80 00       	push   $0x802edf
  80130c:	e8 01 f0 ff ff       	call   800312 <_panic>

00801311 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	05 00 00 00 30       	add    $0x30000000,%eax
  80131c:	c1 e8 0c             	shr    $0xc,%eax
}
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80132c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801331:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801343:	89 c2                	mov    %eax,%edx
  801345:	c1 ea 16             	shr    $0x16,%edx
  801348:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 11                	je     801365 <fd_alloc+0x2d>
  801354:	89 c2                	mov    %eax,%edx
  801356:	c1 ea 0c             	shr    $0xc,%edx
  801359:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	75 09                	jne    80136e <fd_alloc+0x36>
			*fd_store = fd;
  801365:	89 01                	mov    %eax,(%ecx)
			return 0;
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
  80136c:	eb 17                	jmp    801385 <fd_alloc+0x4d>
  80136e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801373:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801378:	75 c9                	jne    801343 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80137a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801380:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80138d:	83 f8 1f             	cmp    $0x1f,%eax
  801390:	77 36                	ja     8013c8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801392:	c1 e0 0c             	shl    $0xc,%eax
  801395:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	c1 ea 16             	shr    $0x16,%edx
  80139f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a6:	f6 c2 01             	test   $0x1,%dl
  8013a9:	74 24                	je     8013cf <fd_lookup+0x48>
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	c1 ea 0c             	shr    $0xc,%edx
  8013b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b7:	f6 c2 01             	test   $0x1,%dl
  8013ba:	74 1a                	je     8013d6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013bf:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c6:	eb 13                	jmp    8013db <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cd:	eb 0c                	jmp    8013db <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d4:	eb 05                	jmp    8013db <fd_lookup+0x54>
  8013d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	eb 13                	jmp    801400 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8013ed:	39 08                	cmp    %ecx,(%eax)
  8013ef:	75 0c                	jne    8013fd <dev_lookup+0x20>
			*dev = devtab[i];
  8013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	eb 36                	jmp    801433 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013fd:	83 c2 01             	add    $0x1,%edx
  801400:	8b 04 95 04 30 80 00 	mov    0x803004(,%edx,4),%eax
  801407:	85 c0                	test   %eax,%eax
  801409:	75 e2                	jne    8013ed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80140b:	a1 08 50 80 00       	mov    0x805008,%eax
  801410:	8b 40 48             	mov    0x48(%eax),%eax
  801413:	83 ec 04             	sub    $0x4,%esp
  801416:	51                   	push   %ecx
  801417:	50                   	push   %eax
  801418:	68 88 2f 80 00       	push   $0x802f88
  80141d:	e8 c9 ef ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801422:	8b 45 0c             	mov    0xc(%ebp),%eax
  801425:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	83 ec 10             	sub    $0x10,%esp
  80143d:	8b 75 08             	mov    0x8(%ebp),%esi
  801440:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801443:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801446:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801447:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80144d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801450:	50                   	push   %eax
  801451:	e8 31 ff ff ff       	call   801387 <fd_lookup>
  801456:	83 c4 08             	add    $0x8,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 05                	js     801462 <fd_close+0x2d>
	    || fd != fd2)
  80145d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801460:	74 0c                	je     80146e <fd_close+0x39>
		return (must_exist ? r : 0);
  801462:	84 db                	test   %bl,%bl
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	0f 44 c2             	cmove  %edx,%eax
  80146c:	eb 41                	jmp    8014af <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	ff 36                	pushl  (%esi)
  801477:	e8 61 ff ff ff       	call   8013dd <dev_lookup>
  80147c:	89 c3                	mov    %eax,%ebx
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	85 c0                	test   %eax,%eax
  801483:	78 1a                	js     80149f <fd_close+0x6a>
		if (dev->dev_close)
  801485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801488:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80148b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801490:	85 c0                	test   %eax,%eax
  801492:	74 0b                	je     80149f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	56                   	push   %esi
  801498:	ff d0                	call   *%eax
  80149a:	89 c3                	mov    %eax,%ebx
  80149c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	56                   	push   %esi
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 56 f9 ff ff       	call   800e00 <sys_page_unmap>
	return r;
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	89 d8                	mov    %ebx,%eax
}
  8014af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	ff 75 08             	pushl  0x8(%ebp)
  8014c3:	e8 bf fe ff ff       	call   801387 <fd_lookup>
  8014c8:	89 c2                	mov    %eax,%edx
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	85 d2                	test   %edx,%edx
  8014cf:	78 10                	js     8014e1 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	6a 01                	push   $0x1
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	e8 57 ff ff ff       	call   801435 <fd_close>
  8014de:	83 c4 10             	add    $0x10,%esp
}
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <close_all>:

void
close_all(void)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	e8 be ff ff ff       	call   8014b6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f8:	83 c3 01             	add    $0x1,%ebx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	83 fb 20             	cmp    $0x20,%ebx
  801501:	75 ec                	jne    8014ef <close_all+0xc>
		close(i);
}
  801503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 2c             	sub    $0x2c,%esp
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801514:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	ff 75 08             	pushl  0x8(%ebp)
  80151b:	e8 67 fe ff ff       	call   801387 <fd_lookup>
  801520:	89 c2                	mov    %eax,%edx
  801522:	83 c4 08             	add    $0x8,%esp
  801525:	85 d2                	test   %edx,%edx
  801527:	0f 88 c1 00 00 00    	js     8015ee <dup+0xe6>
		return r;
	close(newfdnum);
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	56                   	push   %esi
  801531:	e8 80 ff ff ff       	call   8014b6 <close>

	newfd = INDEX2FD(newfdnum);
  801536:	89 f3                	mov    %esi,%ebx
  801538:	c1 e3 0c             	shl    $0xc,%ebx
  80153b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801541:	83 c4 04             	add    $0x4,%esp
  801544:	ff 75 e4             	pushl  -0x1c(%ebp)
  801547:	e8 d5 fd ff ff       	call   801321 <fd2data>
  80154c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80154e:	89 1c 24             	mov    %ebx,(%esp)
  801551:	e8 cb fd ff ff       	call   801321 <fd2data>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155c:	89 f8                	mov    %edi,%eax
  80155e:	c1 e8 16             	shr    $0x16,%eax
  801561:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801568:	a8 01                	test   $0x1,%al
  80156a:	74 37                	je     8015a3 <dup+0x9b>
  80156c:	89 f8                	mov    %edi,%eax
  80156e:	c1 e8 0c             	shr    $0xc,%eax
  801571:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801578:	f6 c2 01             	test   $0x1,%dl
  80157b:	74 26                	je     8015a3 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	25 07 0e 00 00       	and    $0xe07,%eax
  80158c:	50                   	push   %eax
  80158d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801590:	6a 00                	push   $0x0
  801592:	57                   	push   %edi
  801593:	6a 00                	push   $0x0
  801595:	e8 24 f8 ff ff       	call   800dbe <sys_page_map>
  80159a:	89 c7                	mov    %eax,%edi
  80159c:	83 c4 20             	add    $0x20,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 2e                	js     8015d1 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a6:	89 d0                	mov    %edx,%eax
  8015a8:	c1 e8 0c             	shr    $0xc,%eax
  8015ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ba:	50                   	push   %eax
  8015bb:	53                   	push   %ebx
  8015bc:	6a 00                	push   $0x0
  8015be:	52                   	push   %edx
  8015bf:	6a 00                	push   $0x0
  8015c1:	e8 f8 f7 ff ff       	call   800dbe <sys_page_map>
  8015c6:	89 c7                	mov    %eax,%edi
  8015c8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015cb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cd:	85 ff                	test   %edi,%edi
  8015cf:	79 1d                	jns    8015ee <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	6a 00                	push   $0x0
  8015d7:	e8 24 f8 ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e2:	6a 00                	push   $0x0
  8015e4:	e8 17 f8 ff ff       	call   800e00 <sys_page_unmap>
	return r;
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	89 f8                	mov    %edi,%eax
}
  8015ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5f                   	pop    %edi
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 14             	sub    $0x14,%esp
  8015fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801600:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	53                   	push   %ebx
  801605:	e8 7d fd ff ff       	call   801387 <fd_lookup>
  80160a:	83 c4 08             	add    $0x8,%esp
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 6d                	js     801680 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	ff 30                	pushl  (%eax)
  80161f:	e8 b9 fd ff ff       	call   8013dd <dev_lookup>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 4c                	js     801677 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80162b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80162e:	8b 42 08             	mov    0x8(%edx),%eax
  801631:	83 e0 03             	and    $0x3,%eax
  801634:	83 f8 01             	cmp    $0x1,%eax
  801637:	75 21                	jne    80165a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801639:	a1 08 50 80 00       	mov    0x805008,%eax
  80163e:	8b 40 48             	mov    0x48(%eax),%eax
  801641:	83 ec 04             	sub    $0x4,%esp
  801644:	53                   	push   %ebx
  801645:	50                   	push   %eax
  801646:	68 c9 2f 80 00       	push   $0x802fc9
  80164b:	e8 9b ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801658:	eb 26                	jmp    801680 <read+0x8a>
	}
	if (!dev->dev_read)
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	8b 40 08             	mov    0x8(%eax),%eax
  801660:	85 c0                	test   %eax,%eax
  801662:	74 17                	je     80167b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	ff 75 10             	pushl  0x10(%ebp)
  80166a:	ff 75 0c             	pushl  0xc(%ebp)
  80166d:	52                   	push   %edx
  80166e:	ff d0                	call   *%eax
  801670:	89 c2                	mov    %eax,%edx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	eb 09                	jmp    801680 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801677:	89 c2                	mov    %eax,%edx
  801679:	eb 05                	jmp    801680 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80167b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801680:	89 d0                	mov    %edx,%eax
  801682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	8b 7d 08             	mov    0x8(%ebp),%edi
  801693:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801696:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169b:	eb 21                	jmp    8016be <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	89 f0                	mov    %esi,%eax
  8016a2:	29 d8                	sub    %ebx,%eax
  8016a4:	50                   	push   %eax
  8016a5:	89 d8                	mov    %ebx,%eax
  8016a7:	03 45 0c             	add    0xc(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	57                   	push   %edi
  8016ac:	e8 45 ff ff ff       	call   8015f6 <read>
		if (m < 0)
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 0c                	js     8016c4 <readn+0x3d>
			return m;
		if (m == 0)
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	74 06                	je     8016c2 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016bc:	01 c3                	add    %eax,%ebx
  8016be:	39 f3                	cmp    %esi,%ebx
  8016c0:	72 db                	jb     80169d <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8016c2:	89 d8                	mov    %ebx,%eax
}
  8016c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5f                   	pop    %edi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 14             	sub    $0x14,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	53                   	push   %ebx
  8016db:	e8 a7 fc ff ff       	call   801387 <fd_lookup>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 68                	js     801751 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	ff 30                	pushl  (%eax)
  8016f5:	e8 e3 fc ff ff       	call   8013dd <dev_lookup>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 47                	js     801748 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801708:	75 21                	jne    80172b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80170a:	a1 08 50 80 00       	mov    0x805008,%eax
  80170f:	8b 40 48             	mov    0x48(%eax),%eax
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	68 e5 2f 80 00       	push   $0x802fe5
  80171c:	e8 ca ec ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801729:	eb 26                	jmp    801751 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172e:	8b 52 0c             	mov    0xc(%edx),%edx
  801731:	85 d2                	test   %edx,%edx
  801733:	74 17                	je     80174c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	50                   	push   %eax
  80173f:	ff d2                	call   *%edx
  801741:	89 c2                	mov    %eax,%edx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 09                	jmp    801751 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801748:	89 c2                	mov    %eax,%edx
  80174a:	eb 05                	jmp    801751 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <seek>:

int
seek(int fdnum, off_t offset)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	ff 75 08             	pushl  0x8(%ebp)
  801765:	e8 1d fc ff ff       	call   801387 <fd_lookup>
  80176a:	83 c4 08             	add    $0x8,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0e                	js     80177f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801771:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801774:	8b 55 0c             	mov    0xc(%ebp),%edx
  801777:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 14             	sub    $0x14,%esp
  801788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	53                   	push   %ebx
  801790:	e8 f2 fb ff ff       	call   801387 <fd_lookup>
  801795:	83 c4 08             	add    $0x8,%esp
  801798:	89 c2                	mov    %eax,%edx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 65                	js     801803 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	ff 30                	pushl  (%eax)
  8017aa:	e8 2e fc ff ff       	call   8013dd <dev_lookup>
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 44                	js     8017fa <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bd:	75 21                	jne    8017e0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017bf:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c4:	8b 40 48             	mov    0x48(%eax),%eax
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	53                   	push   %ebx
  8017cb:	50                   	push   %eax
  8017cc:	68 a8 2f 80 00       	push   $0x802fa8
  8017d1:	e8 15 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017de:	eb 23                	jmp    801803 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e3:	8b 52 18             	mov    0x18(%edx),%edx
  8017e6:	85 d2                	test   %edx,%edx
  8017e8:	74 14                	je     8017fe <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	ff 75 0c             	pushl  0xc(%ebp)
  8017f0:	50                   	push   %eax
  8017f1:	ff d2                	call   *%edx
  8017f3:	89 c2                	mov    %eax,%edx
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	eb 09                	jmp    801803 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	89 c2                	mov    %eax,%edx
  8017fc:	eb 05                	jmp    801803 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801803:	89 d0                	mov    %edx,%eax
  801805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801808:	c9                   	leave  
  801809:	c3                   	ret    

0080180a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 14             	sub    $0x14,%esp
  801811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	ff 75 08             	pushl  0x8(%ebp)
  80181b:	e8 67 fb ff ff       	call   801387 <fd_lookup>
  801820:	83 c4 08             	add    $0x8,%esp
  801823:	89 c2                	mov    %eax,%edx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 58                	js     801881 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182f:	50                   	push   %eax
  801830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801833:	ff 30                	pushl  (%eax)
  801835:	e8 a3 fb ff ff       	call   8013dd <dev_lookup>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 37                	js     801878 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801844:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801848:	74 32                	je     80187c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80184d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801854:	00 00 00 
	stat->st_isdir = 0;
  801857:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80185e:	00 00 00 
	stat->st_dev = dev;
  801861:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	53                   	push   %ebx
  80186b:	ff 75 f0             	pushl  -0x10(%ebp)
  80186e:	ff 50 14             	call   *0x14(%eax)
  801871:	89 c2                	mov    %eax,%edx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	eb 09                	jmp    801881 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801878:	89 c2                	mov    %eax,%edx
  80187a:	eb 05                	jmp    801881 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801881:	89 d0                	mov    %edx,%eax
  801883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	56                   	push   %esi
  80188c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	6a 00                	push   $0x0
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 09 02 00 00       	call   801aa3 <open>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 db                	test   %ebx,%ebx
  8018a1:	78 1b                	js     8018be <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	ff 75 0c             	pushl  0xc(%ebp)
  8018a9:	53                   	push   %ebx
  8018aa:	e8 5b ff ff ff       	call   80180a <fstat>
  8018af:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b1:	89 1c 24             	mov    %ebx,(%esp)
  8018b4:	e8 fd fb ff ff       	call   8014b6 <close>
	return r;
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	89 f0                	mov    %esi,%eax
}
  8018be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c1:	5b                   	pop    %ebx
  8018c2:	5e                   	pop    %esi
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	89 c6                	mov    %eax,%esi
  8018cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018ce:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8018d5:	75 12                	jne    8018e9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	6a 01                	push   $0x1
  8018dc:	e8 52 0d 00 00       	call   802633 <ipc_find_env>
  8018e1:	a3 00 50 80 00       	mov    %eax,0x805000
  8018e6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e9:	6a 07                	push   $0x7
  8018eb:	68 00 60 80 00       	push   $0x806000
  8018f0:	56                   	push   %esi
  8018f1:	ff 35 00 50 80 00    	pushl  0x805000
  8018f7:	e8 e3 0c 00 00       	call   8025df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018fc:	83 c4 0c             	add    $0xc,%esp
  8018ff:	6a 00                	push   $0x0
  801901:	53                   	push   %ebx
  801902:	6a 00                	push   $0x0
  801904:	e8 6d 0c 00 00       	call   802576 <ipc_recv>
}
  801909:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	b8 02 00 00 00       	mov    $0x2,%eax
  801933:	e8 8d ff ff ff       	call   8018c5 <fsipc>
}
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	8b 40 0c             	mov    0xc(%eax),%eax
  801946:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	b8 06 00 00 00       	mov    $0x6,%eax
  801955:	e8 6b ff ff ff       	call   8018c5 <fsipc>
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 40 0c             	mov    0xc(%eax),%eax
  80196c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801971:	ba 00 00 00 00       	mov    $0x0,%edx
  801976:	b8 05 00 00 00       	mov    $0x5,%eax
  80197b:	e8 45 ff ff ff       	call   8018c5 <fsipc>
  801980:	89 c2                	mov    %eax,%edx
  801982:	85 d2                	test   %edx,%edx
  801984:	78 2c                	js     8019b2 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	68 00 60 80 00       	push   $0x806000
  80198e:	53                   	push   %ebx
  80198f:	e8 de ef ff ff       	call   800972 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801994:	a1 80 60 80 00       	mov    0x806080,%eax
  801999:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80199f:	a1 84 60 80 00       	mov    0x806084,%eax
  8019a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	57                   	push   %edi
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8019ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8019d1:	eb 3d                	jmp    801a10 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8019d3:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8019d9:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8019de:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8019e1:	83 ec 04             	sub    $0x4,%esp
  8019e4:	57                   	push   %edi
  8019e5:	53                   	push   %ebx
  8019e6:	68 08 60 80 00       	push   $0x806008
  8019eb:	e8 14 f1 ff ff       	call   800b04 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8019f0:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801a00:	e8 c0 fe ff ff       	call   8018c5 <fsipc>
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 0d                	js     801a19 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801a0c:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801a0e:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801a10:	85 f6                	test   %esi,%esi
  801a12:	75 bf                	jne    8019d3 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801a14:	89 d8                	mov    %ebx,%eax
  801a16:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5f                   	pop    %edi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a34:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 03 00 00 00       	mov    $0x3,%eax
  801a44:	e8 7c fe ff ff       	call   8018c5 <fsipc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	78 4b                	js     801a9a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a4f:	39 c6                	cmp    %eax,%esi
  801a51:	73 16                	jae    801a69 <devfile_read+0x48>
  801a53:	68 18 30 80 00       	push   $0x803018
  801a58:	68 1f 30 80 00       	push   $0x80301f
  801a5d:	6a 7c                	push   $0x7c
  801a5f:	68 34 30 80 00       	push   $0x803034
  801a64:	e8 a9 e8 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801a69:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a6e:	7e 16                	jle    801a86 <devfile_read+0x65>
  801a70:	68 3f 30 80 00       	push   $0x80303f
  801a75:	68 1f 30 80 00       	push   $0x80301f
  801a7a:	6a 7d                	push   $0x7d
  801a7c:	68 34 30 80 00       	push   $0x803034
  801a81:	e8 8c e8 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a86:	83 ec 04             	sub    $0x4,%esp
  801a89:	50                   	push   %eax
  801a8a:	68 00 60 80 00       	push   $0x806000
  801a8f:	ff 75 0c             	pushl  0xc(%ebp)
  801a92:	e8 6d f0 ff ff       	call   800b04 <memmove>
	return r;
  801a97:	83 c4 10             	add    $0x10,%esp
}
  801a9a:	89 d8                	mov    %ebx,%eax
  801a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 20             	sub    $0x20,%esp
  801aaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aad:	53                   	push   %ebx
  801aae:	e8 86 ee ff ff       	call   800939 <strlen>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801abb:	7f 67                	jg     801b24 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac3:	50                   	push   %eax
  801ac4:	e8 6f f8 ff ff       	call   801338 <fd_alloc>
  801ac9:	83 c4 10             	add    $0x10,%esp
		return r;
  801acc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 57                	js     801b29 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ad2:	83 ec 08             	sub    $0x8,%esp
  801ad5:	53                   	push   %ebx
  801ad6:	68 00 60 80 00       	push   $0x806000
  801adb:	e8 92 ee ff ff       	call   800972 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae3:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ae8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aeb:	b8 01 00 00 00       	mov    $0x1,%eax
  801af0:	e8 d0 fd ff ff       	call   8018c5 <fsipc>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	79 14                	jns    801b12 <open+0x6f>
		fd_close(fd, 0);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	6a 00                	push   $0x0
  801b03:	ff 75 f4             	pushl  -0xc(%ebp)
  801b06:	e8 2a f9 ff ff       	call   801435 <fd_close>
		return r;
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	89 da                	mov    %ebx,%edx
  801b10:	eb 17                	jmp    801b29 <open+0x86>
	}

	return fd2num(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	ff 75 f4             	pushl  -0xc(%ebp)
  801b18:	e8 f4 f7 ff ff       	call   801311 <fd2num>
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	eb 05                	jmp    801b29 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b24:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b29:	89 d0                	mov    %edx,%eax
  801b2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b36:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3b:	b8 08 00 00 00       	mov    $0x8,%eax
  801b40:	e8 80 fd ff ff       	call   8018c5 <fsipc>
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b4d:	68 4b 30 80 00       	push   $0x80304b
  801b52:	ff 75 0c             	pushl  0xc(%ebp)
  801b55:	e8 18 ee ff ff       	call   800972 <strcpy>
	return 0;
}
  801b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    

00801b61 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	53                   	push   %ebx
  801b65:	83 ec 10             	sub    $0x10,%esp
  801b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b6b:	53                   	push   %ebx
  801b6c:	e8 fa 0a 00 00       	call   80266b <pageref>
  801b71:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b74:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b79:	83 f8 01             	cmp    $0x1,%eax
  801b7c:	75 10                	jne    801b8e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	ff 73 0c             	pushl  0xc(%ebx)
  801b84:	e8 ca 02 00 00       	call   801e53 <nsipc_close>
  801b89:	89 c2                	mov    %eax,%edx
  801b8b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b8e:	89 d0                	mov    %edx,%eax
  801b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b9b:	6a 00                	push   $0x0
  801b9d:	ff 75 10             	pushl  0x10(%ebp)
  801ba0:	ff 75 0c             	pushl  0xc(%ebp)
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	ff 70 0c             	pushl  0xc(%eax)
  801ba9:	e8 82 03 00 00       	call   801f30 <nsipc_send>
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bb6:	6a 00                	push   $0x0
  801bb8:	ff 75 10             	pushl  0x10(%ebp)
  801bbb:	ff 75 0c             	pushl  0xc(%ebp)
  801bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc1:	ff 70 0c             	pushl  0xc(%eax)
  801bc4:	e8 fb 02 00 00       	call   801ec4 <nsipc_recv>
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bd1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bd4:	52                   	push   %edx
  801bd5:	50                   	push   %eax
  801bd6:	e8 ac f7 ff ff       	call   801387 <fd_lookup>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 17                	js     801bf9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801beb:	39 08                	cmp    %ecx,(%eax)
  801bed:	75 05                	jne    801bf4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bef:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf2:	eb 05                	jmp    801bf9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bf4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	83 ec 1c             	sub    $0x1c,%esp
  801c03:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c08:	50                   	push   %eax
  801c09:	e8 2a f7 ff ff       	call   801338 <fd_alloc>
  801c0e:	89 c3                	mov    %eax,%ebx
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	85 c0                	test   %eax,%eax
  801c15:	78 1b                	js     801c32 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	68 07 04 00 00       	push   $0x407
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	6a 00                	push   $0x0
  801c24:	e8 52 f1 ff ff       	call   800d7b <sys_page_alloc>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	79 10                	jns    801c42 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	56                   	push   %esi
  801c36:	e8 18 02 00 00       	call   801e53 <nsipc_close>
		return r;
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	89 d8                	mov    %ebx,%eax
  801c40:	eb 24                	jmp    801c66 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c42:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c50:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801c57:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	52                   	push   %edx
  801c5e:	e8 ae f6 ff ff       	call   801311 <fd2num>
  801c63:	83 c4 10             	add    $0x10,%esp
}
  801c66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	e8 50 ff ff ff       	call   801bcb <fd2sockid>
		return r;
  801c7b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 1f                	js     801ca0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	ff 75 10             	pushl  0x10(%ebp)
  801c87:	ff 75 0c             	pushl  0xc(%ebp)
  801c8a:	50                   	push   %eax
  801c8b:	e8 1c 01 00 00       	call   801dac <nsipc_accept>
  801c90:	83 c4 10             	add    $0x10,%esp
		return r;
  801c93:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 07                	js     801ca0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c99:	e8 5d ff ff ff       	call   801bfb <alloc_sockfd>
  801c9e:	89 c1                	mov    %eax,%ecx
}
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	e8 19 ff ff ff       	call   801bcb <fd2sockid>
  801cb2:	89 c2                	mov    %eax,%edx
  801cb4:	85 d2                	test   %edx,%edx
  801cb6:	78 12                	js     801cca <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801cb8:	83 ec 04             	sub    $0x4,%esp
  801cbb:	ff 75 10             	pushl  0x10(%ebp)
  801cbe:	ff 75 0c             	pushl  0xc(%ebp)
  801cc1:	52                   	push   %edx
  801cc2:	e8 35 01 00 00       	call   801dfc <nsipc_bind>
  801cc7:	83 c4 10             	add    $0x10,%esp
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <shutdown>:

int
shutdown(int s, int how)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	e8 f1 fe ff ff       	call   801bcb <fd2sockid>
  801cda:	89 c2                	mov    %eax,%edx
  801cdc:	85 d2                	test   %edx,%edx
  801cde:	78 0f                	js     801cef <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	52                   	push   %edx
  801ce7:	e8 45 01 00 00       	call   801e31 <nsipc_shutdown>
  801cec:	83 c4 10             	add    $0x10,%esp
}
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	e8 cc fe ff ff       	call   801bcb <fd2sockid>
  801cff:	89 c2                	mov    %eax,%edx
  801d01:	85 d2                	test   %edx,%edx
  801d03:	78 12                	js     801d17 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	ff 75 10             	pushl  0x10(%ebp)
  801d0b:	ff 75 0c             	pushl  0xc(%ebp)
  801d0e:	52                   	push   %edx
  801d0f:	e8 59 01 00 00       	call   801e6d <nsipc_connect>
  801d14:	83 c4 10             	add    $0x10,%esp
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <listen>:

int
listen(int s, int backlog)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	e8 a4 fe ff ff       	call   801bcb <fd2sockid>
  801d27:	89 c2                	mov    %eax,%edx
  801d29:	85 d2                	test   %edx,%edx
  801d2b:	78 0f                	js     801d3c <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801d2d:	83 ec 08             	sub    $0x8,%esp
  801d30:	ff 75 0c             	pushl  0xc(%ebp)
  801d33:	52                   	push   %edx
  801d34:	e8 69 01 00 00       	call   801ea2 <nsipc_listen>
  801d39:	83 c4 10             	add    $0x10,%esp
}
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d44:	ff 75 10             	pushl  0x10(%ebp)
  801d47:	ff 75 0c             	pushl  0xc(%ebp)
  801d4a:	ff 75 08             	pushl  0x8(%ebp)
  801d4d:	e8 3c 02 00 00       	call   801f8e <nsipc_socket>
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 d2                	test   %edx,%edx
  801d59:	78 05                	js     801d60 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801d5b:	e8 9b fe ff ff       	call   801bfb <alloc_sockfd>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	53                   	push   %ebx
  801d66:	83 ec 04             	sub    $0x4,%esp
  801d69:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d6b:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801d72:	75 12                	jne    801d86 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d74:	83 ec 0c             	sub    $0xc,%esp
  801d77:	6a 02                	push   $0x2
  801d79:	e8 b5 08 00 00       	call   802633 <ipc_find_env>
  801d7e:	a3 04 50 80 00       	mov    %eax,0x805004
  801d83:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d86:	6a 07                	push   $0x7
  801d88:	68 00 70 80 00       	push   $0x807000
  801d8d:	53                   	push   %ebx
  801d8e:	ff 35 04 50 80 00    	pushl  0x805004
  801d94:	e8 46 08 00 00       	call   8025df <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d99:	83 c4 0c             	add    $0xc,%esp
  801d9c:	6a 00                	push   $0x0
  801d9e:	6a 00                	push   $0x0
  801da0:	6a 00                	push   $0x0
  801da2:	e8 cf 07 00 00       	call   802576 <ipc_recv>
}
  801da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dbc:	8b 06                	mov    (%esi),%eax
  801dbe:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801dc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc8:	e8 95 ff ff ff       	call   801d62 <nsipc>
  801dcd:	89 c3                	mov    %eax,%ebx
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 20                	js     801df3 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	ff 35 10 70 80 00    	pushl  0x807010
  801ddc:	68 00 70 80 00       	push   $0x807000
  801de1:	ff 75 0c             	pushl  0xc(%ebp)
  801de4:	e8 1b ed ff ff       	call   800b04 <memmove>
		*addrlen = ret->ret_addrlen;
  801de9:	a1 10 70 80 00       	mov    0x807010,%eax
  801dee:	89 06                	mov    %eax,(%esi)
  801df0:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801df3:	89 d8                	mov    %ebx,%eax
  801df5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    

00801dfc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	53                   	push   %ebx
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e0e:	53                   	push   %ebx
  801e0f:	ff 75 0c             	pushl  0xc(%ebp)
  801e12:	68 04 70 80 00       	push   $0x807004
  801e17:	e8 e8 ec ff ff       	call   800b04 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e1c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801e22:	b8 02 00 00 00       	mov    $0x2,%eax
  801e27:	e8 36 ff ff ff       	call   801d62 <nsipc>
}
  801e2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e42:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801e47:	b8 03 00 00 00       	mov    $0x3,%eax
  801e4c:	e8 11 ff ff ff       	call   801d62 <nsipc>
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <nsipc_close>:

int
nsipc_close(int s)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801e61:	b8 04 00 00 00       	mov    $0x4,%eax
  801e66:	e8 f7 fe ff ff       	call   801d62 <nsipc>
}
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	53                   	push   %ebx
  801e71:	83 ec 08             	sub    $0x8,%esp
  801e74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e77:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e7f:	53                   	push   %ebx
  801e80:	ff 75 0c             	pushl  0xc(%ebp)
  801e83:	68 04 70 80 00       	push   $0x807004
  801e88:	e8 77 ec ff ff       	call   800b04 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e8d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e93:	b8 05 00 00 00       	mov    $0x5,%eax
  801e98:	e8 c5 fe ff ff       	call   801d62 <nsipc>
}
  801e9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  801eab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801eb8:	b8 06 00 00 00       	mov    $0x6,%eax
  801ebd:	e8 a0 fe ff ff       	call   801d62 <nsipc>
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801ed4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801eda:	8b 45 14             	mov    0x14(%ebp),%eax
  801edd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ee2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ee7:	e8 76 fe ff ff       	call   801d62 <nsipc>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 35                	js     801f27 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ef2:	39 f0                	cmp    %esi,%eax
  801ef4:	7f 07                	jg     801efd <nsipc_recv+0x39>
  801ef6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801efb:	7e 16                	jle    801f13 <nsipc_recv+0x4f>
  801efd:	68 57 30 80 00       	push   $0x803057
  801f02:	68 1f 30 80 00       	push   $0x80301f
  801f07:	6a 62                	push   $0x62
  801f09:	68 6c 30 80 00       	push   $0x80306c
  801f0e:	e8 ff e3 ff ff       	call   800312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f13:	83 ec 04             	sub    $0x4,%esp
  801f16:	50                   	push   %eax
  801f17:	68 00 70 80 00       	push   $0x807000
  801f1c:	ff 75 0c             	pushl  0xc(%ebp)
  801f1f:	e8 e0 eb ff ff       	call   800b04 <memmove>
  801f24:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f27:	89 d8                	mov    %ebx,%eax
  801f29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	53                   	push   %ebx
  801f34:	83 ec 04             	sub    $0x4,%esp
  801f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801f42:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f48:	7e 16                	jle    801f60 <nsipc_send+0x30>
  801f4a:	68 78 30 80 00       	push   $0x803078
  801f4f:	68 1f 30 80 00       	push   $0x80301f
  801f54:	6a 6d                	push   $0x6d
  801f56:	68 6c 30 80 00       	push   $0x80306c
  801f5b:	e8 b2 e3 ff ff       	call   800312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	53                   	push   %ebx
  801f64:	ff 75 0c             	pushl  0xc(%ebp)
  801f67:	68 0c 70 80 00       	push   $0x80700c
  801f6c:	e8 93 eb ff ff       	call   800b04 <memmove>
	nsipcbuf.send.req_size = size;
  801f71:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801f77:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f7f:	b8 08 00 00 00       	mov    $0x8,%eax
  801f84:	e8 d9 fd ff ff       	call   801d62 <nsipc>
}
  801f89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f94:	8b 45 08             	mov    0x8(%ebp),%eax
  801f97:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801fac:	b8 09 00 00 00       	mov    $0x9,%eax
  801fb1:	e8 ac fd ff ff       	call   801d62 <nsipc>
}
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	ff 75 08             	pushl  0x8(%ebp)
  801fc6:	e8 56 f3 ff ff       	call   801321 <fd2data>
  801fcb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fcd:	83 c4 08             	add    $0x8,%esp
  801fd0:	68 84 30 80 00       	push   $0x803084
  801fd5:	53                   	push   %ebx
  801fd6:	e8 97 e9 ff ff       	call   800972 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fdb:	8b 56 04             	mov    0x4(%esi),%edx
  801fde:	89 d0                	mov    %edx,%eax
  801fe0:	2b 06                	sub    (%esi),%eax
  801fe2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fe8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fef:	00 00 00 
	stat->st_dev = &devpipe;
  801ff2:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  801ff9:	40 80 00 
	return 0;
}
  801ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  802001:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    

00802008 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	53                   	push   %ebx
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802012:	53                   	push   %ebx
  802013:	6a 00                	push   $0x0
  802015:	e8 e6 ed ff ff       	call   800e00 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80201a:	89 1c 24             	mov    %ebx,(%esp)
  80201d:	e8 ff f2 ff ff       	call   801321 <fd2data>
  802022:	83 c4 08             	add    $0x8,%esp
  802025:	50                   	push   %eax
  802026:	6a 00                	push   $0x0
  802028:	e8 d3 ed ff ff       	call   800e00 <sys_page_unmap>
}
  80202d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	83 ec 1c             	sub    $0x1c,%esp
  80203b:	89 c6                	mov    %eax,%esi
  80203d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802040:	a1 08 50 80 00       	mov    0x805008,%eax
  802045:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	56                   	push   %esi
  80204c:	e8 1a 06 00 00       	call   80266b <pageref>
  802051:	89 c7                	mov    %eax,%edi
  802053:	83 c4 04             	add    $0x4,%esp
  802056:	ff 75 e4             	pushl  -0x1c(%ebp)
  802059:	e8 0d 06 00 00       	call   80266b <pageref>
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	39 c7                	cmp    %eax,%edi
  802063:	0f 94 c2             	sete   %dl
  802066:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802069:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  80206f:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802072:	39 fb                	cmp    %edi,%ebx
  802074:	74 19                	je     80208f <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  802076:	84 d2                	test   %dl,%dl
  802078:	74 c6                	je     802040 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80207a:	8b 51 58             	mov    0x58(%ecx),%edx
  80207d:	50                   	push   %eax
  80207e:	52                   	push   %edx
  80207f:	53                   	push   %ebx
  802080:	68 8b 30 80 00       	push   $0x80308b
  802085:	e8 61 e3 ff ff       	call   8003eb <cprintf>
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	eb b1                	jmp    802040 <_pipeisclosed+0xe>
	}
}
  80208f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	57                   	push   %edi
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	83 ec 28             	sub    $0x28,%esp
  8020a0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020a3:	56                   	push   %esi
  8020a4:	e8 78 f2 ff ff       	call   801321 <fd2data>
  8020a9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8020b3:	eb 4b                	jmp    802100 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020b5:	89 da                	mov    %ebx,%edx
  8020b7:	89 f0                	mov    %esi,%eax
  8020b9:	e8 74 ff ff ff       	call   802032 <_pipeisclosed>
  8020be:	85 c0                	test   %eax,%eax
  8020c0:	75 48                	jne    80210a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020c2:	e8 95 ec ff ff       	call   800d5c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8020ca:	8b 0b                	mov    (%ebx),%ecx
  8020cc:	8d 51 20             	lea    0x20(%ecx),%edx
  8020cf:	39 d0                	cmp    %edx,%eax
  8020d1:	73 e2                	jae    8020b5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020da:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020dd:	89 c2                	mov    %eax,%edx
  8020df:	c1 fa 1f             	sar    $0x1f,%edx
  8020e2:	89 d1                	mov    %edx,%ecx
  8020e4:	c1 e9 1b             	shr    $0x1b,%ecx
  8020e7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020ea:	83 e2 1f             	and    $0x1f,%edx
  8020ed:	29 ca                	sub    %ecx,%edx
  8020ef:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020f3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020f7:	83 c0 01             	add    $0x1,%eax
  8020fa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020fd:	83 c7 01             	add    $0x1,%edi
  802100:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802103:	75 c2                	jne    8020c7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802105:	8b 45 10             	mov    0x10(%ebp),%eax
  802108:	eb 05                	jmp    80210f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80210a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80210f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802112:	5b                   	pop    %ebx
  802113:	5e                   	pop    %esi
  802114:	5f                   	pop    %edi
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    

00802117 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	57                   	push   %edi
  80211b:	56                   	push   %esi
  80211c:	53                   	push   %ebx
  80211d:	83 ec 18             	sub    $0x18,%esp
  802120:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802123:	57                   	push   %edi
  802124:	e8 f8 f1 ff ff       	call   801321 <fd2data>
  802129:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802133:	eb 3d                	jmp    802172 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802135:	85 db                	test   %ebx,%ebx
  802137:	74 04                	je     80213d <devpipe_read+0x26>
				return i;
  802139:	89 d8                	mov    %ebx,%eax
  80213b:	eb 44                	jmp    802181 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	e8 ec fe ff ff       	call   802032 <_pipeisclosed>
  802146:	85 c0                	test   %eax,%eax
  802148:	75 32                	jne    80217c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80214a:	e8 0d ec ff ff       	call   800d5c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80214f:	8b 06                	mov    (%esi),%eax
  802151:	3b 46 04             	cmp    0x4(%esi),%eax
  802154:	74 df                	je     802135 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802156:	99                   	cltd   
  802157:	c1 ea 1b             	shr    $0x1b,%edx
  80215a:	01 d0                	add    %edx,%eax
  80215c:	83 e0 1f             	and    $0x1f,%eax
  80215f:	29 d0                	sub    %edx,%eax
  802161:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802169:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80216c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80216f:	83 c3 01             	add    $0x1,%ebx
  802172:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802175:	75 d8                	jne    80214f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802177:	8b 45 10             	mov    0x10(%ebp),%eax
  80217a:	eb 05                	jmp    802181 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    

00802189 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	56                   	push   %esi
  80218d:	53                   	push   %ebx
  80218e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802191:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802194:	50                   	push   %eax
  802195:	e8 9e f1 ff ff       	call   801338 <fd_alloc>
  80219a:	83 c4 10             	add    $0x10,%esp
  80219d:	89 c2                	mov    %eax,%edx
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	0f 88 2c 01 00 00    	js     8022d3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a7:	83 ec 04             	sub    $0x4,%esp
  8021aa:	68 07 04 00 00       	push   $0x407
  8021af:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b2:	6a 00                	push   $0x0
  8021b4:	e8 c2 eb ff ff       	call   800d7b <sys_page_alloc>
  8021b9:	83 c4 10             	add    $0x10,%esp
  8021bc:	89 c2                	mov    %eax,%edx
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	0f 88 0d 01 00 00    	js     8022d3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021c6:	83 ec 0c             	sub    $0xc,%esp
  8021c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021cc:	50                   	push   %eax
  8021cd:	e8 66 f1 ff ff       	call   801338 <fd_alloc>
  8021d2:	89 c3                	mov    %eax,%ebx
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	0f 88 e2 00 00 00    	js     8022c1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021df:	83 ec 04             	sub    $0x4,%esp
  8021e2:	68 07 04 00 00       	push   $0x407
  8021e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ea:	6a 00                	push   $0x0
  8021ec:	e8 8a eb ff ff       	call   800d7b <sys_page_alloc>
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	0f 88 c3 00 00 00    	js     8022c1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021fe:	83 ec 0c             	sub    $0xc,%esp
  802201:	ff 75 f4             	pushl  -0xc(%ebp)
  802204:	e8 18 f1 ff ff       	call   801321 <fd2data>
  802209:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80220b:	83 c4 0c             	add    $0xc,%esp
  80220e:	68 07 04 00 00       	push   $0x407
  802213:	50                   	push   %eax
  802214:	6a 00                	push   $0x0
  802216:	e8 60 eb ff ff       	call   800d7b <sys_page_alloc>
  80221b:	89 c3                	mov    %eax,%ebx
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	0f 88 89 00 00 00    	js     8022b1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802228:	83 ec 0c             	sub    $0xc,%esp
  80222b:	ff 75 f0             	pushl  -0x10(%ebp)
  80222e:	e8 ee f0 ff ff       	call   801321 <fd2data>
  802233:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80223a:	50                   	push   %eax
  80223b:	6a 00                	push   $0x0
  80223d:	56                   	push   %esi
  80223e:	6a 00                	push   $0x0
  802240:	e8 79 eb ff ff       	call   800dbe <sys_page_map>
  802245:	89 c3                	mov    %eax,%ebx
  802247:	83 c4 20             	add    $0x20,%esp
  80224a:	85 c0                	test   %eax,%eax
  80224c:	78 55                	js     8022a3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80224e:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802254:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802257:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802259:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802263:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80226c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80226e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802271:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802278:	83 ec 0c             	sub    $0xc,%esp
  80227b:	ff 75 f4             	pushl  -0xc(%ebp)
  80227e:	e8 8e f0 ff ff       	call   801311 <fd2num>
  802283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802286:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802288:	83 c4 04             	add    $0x4,%esp
  80228b:	ff 75 f0             	pushl  -0x10(%ebp)
  80228e:	e8 7e f0 ff ff       	call   801311 <fd2num>
  802293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802296:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a1:	eb 30                	jmp    8022d3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022a3:	83 ec 08             	sub    $0x8,%esp
  8022a6:	56                   	push   %esi
  8022a7:	6a 00                	push   $0x0
  8022a9:	e8 52 eb ff ff       	call   800e00 <sys_page_unmap>
  8022ae:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022b1:	83 ec 08             	sub    $0x8,%esp
  8022b4:	ff 75 f0             	pushl  -0x10(%ebp)
  8022b7:	6a 00                	push   $0x0
  8022b9:	e8 42 eb ff ff       	call   800e00 <sys_page_unmap>
  8022be:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022c1:	83 ec 08             	sub    $0x8,%esp
  8022c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c7:	6a 00                	push   $0x0
  8022c9:	e8 32 eb ff ff       	call   800e00 <sys_page_unmap>
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022d3:	89 d0                	mov    %edx,%eax
  8022d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    

008022dc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e5:	50                   	push   %eax
  8022e6:	ff 75 08             	pushl  0x8(%ebp)
  8022e9:	e8 99 f0 ff ff       	call   801387 <fd_lookup>
  8022ee:	89 c2                	mov    %eax,%edx
  8022f0:	83 c4 10             	add    $0x10,%esp
  8022f3:	85 d2                	test   %edx,%edx
  8022f5:	78 18                	js     80230f <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022f7:	83 ec 0c             	sub    $0xc,%esp
  8022fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8022fd:	e8 1f f0 ff ff       	call   801321 <fd2data>
	return _pipeisclosed(fd, p);
  802302:	89 c2                	mov    %eax,%edx
  802304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802307:	e8 26 fd ff ff       	call   802032 <_pipeisclosed>
  80230c:	83 c4 10             	add    $0x10,%esp
}
  80230f:	c9                   	leave  
  802310:	c3                   	ret    

00802311 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	56                   	push   %esi
  802315:	53                   	push   %ebx
  802316:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802319:	85 f6                	test   %esi,%esi
  80231b:	75 16                	jne    802333 <wait+0x22>
  80231d:	68 a3 30 80 00       	push   $0x8030a3
  802322:	68 1f 30 80 00       	push   $0x80301f
  802327:	6a 09                	push   $0x9
  802329:	68 ae 30 80 00       	push   $0x8030ae
  80232e:	e8 df df ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  802333:	89 f3                	mov    %esi,%ebx
  802335:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80233b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80233e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802344:	eb 05                	jmp    80234b <wait+0x3a>
		sys_yield();
  802346:	e8 11 ea ff ff       	call   800d5c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80234b:	8b 43 48             	mov    0x48(%ebx),%eax
  80234e:	39 f0                	cmp    %esi,%eax
  802350:	75 07                	jne    802359 <wait+0x48>
  802352:	8b 43 54             	mov    0x54(%ebx),%eax
  802355:	85 c0                	test   %eax,%eax
  802357:	75 ed                	jne    802346 <wait+0x35>
		sys_yield();
}
  802359:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80235c:	5b                   	pop    %ebx
  80235d:	5e                   	pop    %esi
  80235e:	5d                   	pop    %ebp
  80235f:	c3                   	ret    

00802360 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802363:	b8 00 00 00 00       	mov    $0x0,%eax
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802370:	68 b9 30 80 00       	push   $0x8030b9
  802375:	ff 75 0c             	pushl  0xc(%ebp)
  802378:	e8 f5 e5 ff ff       	call   800972 <strcpy>
	return 0;
}
  80237d:	b8 00 00 00 00       	mov    $0x0,%eax
  802382:	c9                   	leave  
  802383:	c3                   	ret    

00802384 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
  802387:	57                   	push   %edi
  802388:	56                   	push   %esi
  802389:	53                   	push   %ebx
  80238a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802390:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802395:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80239b:	eb 2d                	jmp    8023ca <devcons_write+0x46>
		m = n - tot;
  80239d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023a0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023a2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023a5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023aa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023ad:	83 ec 04             	sub    $0x4,%esp
  8023b0:	53                   	push   %ebx
  8023b1:	03 45 0c             	add    0xc(%ebp),%eax
  8023b4:	50                   	push   %eax
  8023b5:	57                   	push   %edi
  8023b6:	e8 49 e7 ff ff       	call   800b04 <memmove>
		sys_cputs(buf, m);
  8023bb:	83 c4 08             	add    $0x8,%esp
  8023be:	53                   	push   %ebx
  8023bf:	57                   	push   %edi
  8023c0:	e8 fa e8 ff ff       	call   800cbf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023c5:	01 de                	add    %ebx,%esi
  8023c7:	83 c4 10             	add    $0x10,%esp
  8023ca:	89 f0                	mov    %esi,%eax
  8023cc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023cf:	72 cc                	jb     80239d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    

008023d9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d9:	55                   	push   %ebp
  8023da:	89 e5                	mov    %esp,%ebp
  8023dc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023df:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023e8:	75 07                	jne    8023f1 <devcons_read+0x18>
  8023ea:	eb 28                	jmp    802414 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023ec:	e8 6b e9 ff ff       	call   800d5c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023f1:	e8 e7 e8 ff ff       	call   800cdd <sys_cgetc>
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	74 f2                	je     8023ec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023fa:	85 c0                	test   %eax,%eax
  8023fc:	78 16                	js     802414 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023fe:	83 f8 04             	cmp    $0x4,%eax
  802401:	74 0c                	je     80240f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802403:	8b 55 0c             	mov    0xc(%ebp),%edx
  802406:	88 02                	mov    %al,(%edx)
	return 1;
  802408:	b8 01 00 00 00       	mov    $0x1,%eax
  80240d:	eb 05                	jmp    802414 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80240f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802414:	c9                   	leave  
  802415:	c3                   	ret    

00802416 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802416:	55                   	push   %ebp
  802417:	89 e5                	mov    %esp,%ebp
  802419:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80241c:	8b 45 08             	mov    0x8(%ebp),%eax
  80241f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802422:	6a 01                	push   $0x1
  802424:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802427:	50                   	push   %eax
  802428:	e8 92 e8 ff ff       	call   800cbf <sys_cputs>
  80242d:	83 c4 10             	add    $0x10,%esp
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    

00802432 <getchar>:

int
getchar(void)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802438:	6a 01                	push   $0x1
  80243a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80243d:	50                   	push   %eax
  80243e:	6a 00                	push   $0x0
  802440:	e8 b1 f1 ff ff       	call   8015f6 <read>
	if (r < 0)
  802445:	83 c4 10             	add    $0x10,%esp
  802448:	85 c0                	test   %eax,%eax
  80244a:	78 0f                	js     80245b <getchar+0x29>
		return r;
	if (r < 1)
  80244c:	85 c0                	test   %eax,%eax
  80244e:	7e 06                	jle    802456 <getchar+0x24>
		return -E_EOF;
	return c;
  802450:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802454:	eb 05                	jmp    80245b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802456:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80245b:	c9                   	leave  
  80245c:	c3                   	ret    

0080245d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802466:	50                   	push   %eax
  802467:	ff 75 08             	pushl  0x8(%ebp)
  80246a:	e8 18 ef ff ff       	call   801387 <fd_lookup>
  80246f:	83 c4 10             	add    $0x10,%esp
  802472:	85 c0                	test   %eax,%eax
  802474:	78 11                	js     802487 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802479:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80247f:	39 10                	cmp    %edx,(%eax)
  802481:	0f 94 c0             	sete   %al
  802484:	0f b6 c0             	movzbl %al,%eax
}
  802487:	c9                   	leave  
  802488:	c3                   	ret    

00802489 <opencons>:

int
opencons(void)
{
  802489:	55                   	push   %ebp
  80248a:	89 e5                	mov    %esp,%ebp
  80248c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80248f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802492:	50                   	push   %eax
  802493:	e8 a0 ee ff ff       	call   801338 <fd_alloc>
  802498:	83 c4 10             	add    $0x10,%esp
		return r;
  80249b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80249d:	85 c0                	test   %eax,%eax
  80249f:	78 3e                	js     8024df <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024a1:	83 ec 04             	sub    $0x4,%esp
  8024a4:	68 07 04 00 00       	push   $0x407
  8024a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ac:	6a 00                	push   $0x0
  8024ae:	e8 c8 e8 ff ff       	call   800d7b <sys_page_alloc>
  8024b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8024b6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b8:	85 c0                	test   %eax,%eax
  8024ba:	78 23                	js     8024df <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024bc:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8024c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024d1:	83 ec 0c             	sub    $0xc,%esp
  8024d4:	50                   	push   %eax
  8024d5:	e8 37 ee ff ff       	call   801311 <fd2num>
  8024da:	89 c2                	mov    %eax,%edx
  8024dc:	83 c4 10             	add    $0x10,%esp
}
  8024df:	89 d0                	mov    %edx,%eax
  8024e1:	c9                   	leave  
  8024e2:	c3                   	ret    

008024e3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024e9:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8024f0:	75 2c                	jne    80251e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8024f2:	83 ec 04             	sub    $0x4,%esp
  8024f5:	6a 07                	push   $0x7
  8024f7:	68 00 f0 bf ee       	push   $0xeebff000
  8024fc:	6a 00                	push   $0x0
  8024fe:	e8 78 e8 ff ff       	call   800d7b <sys_page_alloc>
  802503:	83 c4 10             	add    $0x10,%esp
  802506:	85 c0                	test   %eax,%eax
  802508:	74 14                	je     80251e <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  80250a:	83 ec 04             	sub    $0x4,%esp
  80250d:	68 c8 30 80 00       	push   $0x8030c8
  802512:	6a 21                	push   $0x21
  802514:	68 2c 31 80 00       	push   $0x80312c
  802519:	e8 f4 dd ff ff       	call   800312 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80251e:	8b 45 08             	mov    0x8(%ebp),%eax
  802521:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802526:	83 ec 08             	sub    $0x8,%esp
  802529:	68 52 25 80 00       	push   $0x802552
  80252e:	6a 00                	push   $0x0
  802530:	e8 91 e9 ff ff       	call   800ec6 <sys_env_set_pgfault_upcall>
  802535:	83 c4 10             	add    $0x10,%esp
  802538:	85 c0                	test   %eax,%eax
  80253a:	79 14                	jns    802550 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80253c:	83 ec 04             	sub    $0x4,%esp
  80253f:	68 f4 30 80 00       	push   $0x8030f4
  802544:	6a 29                	push   $0x29
  802546:	68 2c 31 80 00       	push   $0x80312c
  80254b:	e8 c2 dd ff ff       	call   800312 <_panic>
}
  802550:	c9                   	leave  
  802551:	c3                   	ret    

00802552 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802552:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802553:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802558:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80255a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80255d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802562:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802566:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80256a:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80256c:	83 c4 08             	add    $0x8,%esp
        popal
  80256f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802570:	83 c4 04             	add    $0x4,%esp
        popfl
  802573:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802574:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802575:	c3                   	ret    

00802576 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802576:	55                   	push   %ebp
  802577:	89 e5                	mov    %esp,%ebp
  802579:	56                   	push   %esi
  80257a:	53                   	push   %ebx
  80257b:	8b 75 08             	mov    0x8(%ebp),%esi
  80257e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802581:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802584:	85 c0                	test   %eax,%eax
  802586:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80258b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80258e:	83 ec 0c             	sub    $0xc,%esp
  802591:	50                   	push   %eax
  802592:	e8 94 e9 ff ff       	call   800f2b <sys_ipc_recv>
  802597:	83 c4 10             	add    $0x10,%esp
  80259a:	85 c0                	test   %eax,%eax
  80259c:	79 16                	jns    8025b4 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80259e:	85 f6                	test   %esi,%esi
  8025a0:	74 06                	je     8025a8 <ipc_recv+0x32>
  8025a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8025a8:	85 db                	test   %ebx,%ebx
  8025aa:	74 2c                	je     8025d8 <ipc_recv+0x62>
  8025ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8025b2:	eb 24                	jmp    8025d8 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8025b4:	85 f6                	test   %esi,%esi
  8025b6:	74 0a                	je     8025c2 <ipc_recv+0x4c>
  8025b8:	a1 08 50 80 00       	mov    0x805008,%eax
  8025bd:	8b 40 74             	mov    0x74(%eax),%eax
  8025c0:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8025c2:	85 db                	test   %ebx,%ebx
  8025c4:	74 0a                	je     8025d0 <ipc_recv+0x5a>
  8025c6:	a1 08 50 80 00       	mov    0x805008,%eax
  8025cb:	8b 40 78             	mov    0x78(%eax),%eax
  8025ce:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8025d0:	a1 08 50 80 00       	mov    0x805008,%eax
  8025d5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025db:	5b                   	pop    %ebx
  8025dc:	5e                   	pop    %esi
  8025dd:	5d                   	pop    %ebp
  8025de:	c3                   	ret    

008025df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025df:	55                   	push   %ebp
  8025e0:	89 e5                	mov    %esp,%ebp
  8025e2:	57                   	push   %edi
  8025e3:	56                   	push   %esi
  8025e4:	53                   	push   %ebx
  8025e5:	83 ec 0c             	sub    $0xc,%esp
  8025e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8025f1:	85 db                	test   %ebx,%ebx
  8025f3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025f8:	0f 44 d8             	cmove  %eax,%ebx
  8025fb:	eb 1c                	jmp    802619 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8025fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802600:	74 12                	je     802614 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802602:	50                   	push   %eax
  802603:	68 3a 31 80 00       	push   $0x80313a
  802608:	6a 39                	push   $0x39
  80260a:	68 55 31 80 00       	push   $0x803155
  80260f:	e8 fe dc ff ff       	call   800312 <_panic>
                 sys_yield();
  802614:	e8 43 e7 ff ff       	call   800d5c <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802619:	ff 75 14             	pushl  0x14(%ebp)
  80261c:	53                   	push   %ebx
  80261d:	56                   	push   %esi
  80261e:	57                   	push   %edi
  80261f:	e8 e4 e8 ff ff       	call   800f08 <sys_ipc_try_send>
  802624:	83 c4 10             	add    $0x10,%esp
  802627:	85 c0                	test   %eax,%eax
  802629:	78 d2                	js     8025fd <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80262b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80262e:	5b                   	pop    %ebx
  80262f:	5e                   	pop    %esi
  802630:	5f                   	pop    %edi
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    

00802633 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802633:	55                   	push   %ebp
  802634:	89 e5                	mov    %esp,%ebp
  802636:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802639:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80263e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802641:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802647:	8b 52 50             	mov    0x50(%edx),%edx
  80264a:	39 ca                	cmp    %ecx,%edx
  80264c:	75 0d                	jne    80265b <ipc_find_env+0x28>
			return envs[i].env_id;
  80264e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802651:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802656:	8b 40 08             	mov    0x8(%eax),%eax
  802659:	eb 0e                	jmp    802669 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80265b:	83 c0 01             	add    $0x1,%eax
  80265e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802663:	75 d9                	jne    80263e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802665:	66 b8 00 00          	mov    $0x0,%ax
}
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    

0080266b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80266b:	55                   	push   %ebp
  80266c:	89 e5                	mov    %esp,%ebp
  80266e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802671:	89 d0                	mov    %edx,%eax
  802673:	c1 e8 16             	shr    $0x16,%eax
  802676:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80267d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802682:	f6 c1 01             	test   $0x1,%cl
  802685:	74 1d                	je     8026a4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802687:	c1 ea 0c             	shr    $0xc,%edx
  80268a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802691:	f6 c2 01             	test   $0x1,%dl
  802694:	74 0e                	je     8026a4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802696:	c1 ea 0c             	shr    $0xc,%edx
  802699:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026a0:	ef 
  8026a1:	0f b7 c0             	movzwl %ax,%eax
}
  8026a4:	5d                   	pop    %ebp
  8026a5:	c3                   	ret    
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__udivdi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	83 ec 10             	sub    $0x10,%esp
  8026b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8026ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8026be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8026c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8026c6:	85 d2                	test   %edx,%edx
  8026c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026cc:	89 34 24             	mov    %esi,(%esp)
  8026cf:	89 c8                	mov    %ecx,%eax
  8026d1:	75 35                	jne    802708 <__udivdi3+0x58>
  8026d3:	39 f1                	cmp    %esi,%ecx
  8026d5:	0f 87 bd 00 00 00    	ja     802798 <__udivdi3+0xe8>
  8026db:	85 c9                	test   %ecx,%ecx
  8026dd:	89 cd                	mov    %ecx,%ebp
  8026df:	75 0b                	jne    8026ec <__udivdi3+0x3c>
  8026e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e6:	31 d2                	xor    %edx,%edx
  8026e8:	f7 f1                	div    %ecx
  8026ea:	89 c5                	mov    %eax,%ebp
  8026ec:	89 f0                	mov    %esi,%eax
  8026ee:	31 d2                	xor    %edx,%edx
  8026f0:	f7 f5                	div    %ebp
  8026f2:	89 c6                	mov    %eax,%esi
  8026f4:	89 f8                	mov    %edi,%eax
  8026f6:	f7 f5                	div    %ebp
  8026f8:	89 f2                	mov    %esi,%edx
  8026fa:	83 c4 10             	add    $0x10,%esp
  8026fd:	5e                   	pop    %esi
  8026fe:	5f                   	pop    %edi
  8026ff:	5d                   	pop    %ebp
  802700:	c3                   	ret    
  802701:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802708:	3b 14 24             	cmp    (%esp),%edx
  80270b:	77 7b                	ja     802788 <__udivdi3+0xd8>
  80270d:	0f bd f2             	bsr    %edx,%esi
  802710:	83 f6 1f             	xor    $0x1f,%esi
  802713:	0f 84 97 00 00 00    	je     8027b0 <__udivdi3+0x100>
  802719:	bd 20 00 00 00       	mov    $0x20,%ebp
  80271e:	89 d7                	mov    %edx,%edi
  802720:	89 f1                	mov    %esi,%ecx
  802722:	29 f5                	sub    %esi,%ebp
  802724:	d3 e7                	shl    %cl,%edi
  802726:	89 c2                	mov    %eax,%edx
  802728:	89 e9                	mov    %ebp,%ecx
  80272a:	d3 ea                	shr    %cl,%edx
  80272c:	89 f1                	mov    %esi,%ecx
  80272e:	09 fa                	or     %edi,%edx
  802730:	8b 3c 24             	mov    (%esp),%edi
  802733:	d3 e0                	shl    %cl,%eax
  802735:	89 54 24 08          	mov    %edx,0x8(%esp)
  802739:	89 e9                	mov    %ebp,%ecx
  80273b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802743:	89 fa                	mov    %edi,%edx
  802745:	d3 ea                	shr    %cl,%edx
  802747:	89 f1                	mov    %esi,%ecx
  802749:	d3 e7                	shl    %cl,%edi
  80274b:	89 e9                	mov    %ebp,%ecx
  80274d:	d3 e8                	shr    %cl,%eax
  80274f:	09 c7                	or     %eax,%edi
  802751:	89 f8                	mov    %edi,%eax
  802753:	f7 74 24 08          	divl   0x8(%esp)
  802757:	89 d5                	mov    %edx,%ebp
  802759:	89 c7                	mov    %eax,%edi
  80275b:	f7 64 24 0c          	mull   0xc(%esp)
  80275f:	39 d5                	cmp    %edx,%ebp
  802761:	89 14 24             	mov    %edx,(%esp)
  802764:	72 11                	jb     802777 <__udivdi3+0xc7>
  802766:	8b 54 24 04          	mov    0x4(%esp),%edx
  80276a:	89 f1                	mov    %esi,%ecx
  80276c:	d3 e2                	shl    %cl,%edx
  80276e:	39 c2                	cmp    %eax,%edx
  802770:	73 5e                	jae    8027d0 <__udivdi3+0x120>
  802772:	3b 2c 24             	cmp    (%esp),%ebp
  802775:	75 59                	jne    8027d0 <__udivdi3+0x120>
  802777:	8d 47 ff             	lea    -0x1(%edi),%eax
  80277a:	31 f6                	xor    %esi,%esi
  80277c:	89 f2                	mov    %esi,%edx
  80277e:	83 c4 10             	add    $0x10,%esp
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    
  802785:	8d 76 00             	lea    0x0(%esi),%esi
  802788:	31 f6                	xor    %esi,%esi
  80278a:	31 c0                	xor    %eax,%eax
  80278c:	89 f2                	mov    %esi,%edx
  80278e:	83 c4 10             	add    $0x10,%esp
  802791:	5e                   	pop    %esi
  802792:	5f                   	pop    %edi
  802793:	5d                   	pop    %ebp
  802794:	c3                   	ret    
  802795:	8d 76 00             	lea    0x0(%esi),%esi
  802798:	89 f2                	mov    %esi,%edx
  80279a:	31 f6                	xor    %esi,%esi
  80279c:	89 f8                	mov    %edi,%eax
  80279e:	f7 f1                	div    %ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	83 c4 10             	add    $0x10,%esp
  8027a5:	5e                   	pop    %esi
  8027a6:	5f                   	pop    %edi
  8027a7:	5d                   	pop    %ebp
  8027a8:	c3                   	ret    
  8027a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8027b4:	76 0b                	jbe    8027c1 <__udivdi3+0x111>
  8027b6:	31 c0                	xor    %eax,%eax
  8027b8:	3b 14 24             	cmp    (%esp),%edx
  8027bb:	0f 83 37 ff ff ff    	jae    8026f8 <__udivdi3+0x48>
  8027c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c6:	e9 2d ff ff ff       	jmp    8026f8 <__udivdi3+0x48>
  8027cb:	90                   	nop
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	89 f8                	mov    %edi,%eax
  8027d2:	31 f6                	xor    %esi,%esi
  8027d4:	e9 1f ff ff ff       	jmp    8026f8 <__udivdi3+0x48>
  8027d9:	66 90                	xchg   %ax,%ax
  8027db:	66 90                	xchg   %ax,%ax
  8027dd:	66 90                	xchg   %ax,%ax
  8027df:	90                   	nop

008027e0 <__umoddi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	83 ec 20             	sub    $0x20,%esp
  8027e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8027ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027f2:	89 c6                	mov    %eax,%esi
  8027f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8027fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802800:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802804:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802808:	89 74 24 18          	mov    %esi,0x18(%esp)
  80280c:	85 c0                	test   %eax,%eax
  80280e:	89 c2                	mov    %eax,%edx
  802810:	75 1e                	jne    802830 <__umoddi3+0x50>
  802812:	39 f7                	cmp    %esi,%edi
  802814:	76 52                	jbe    802868 <__umoddi3+0x88>
  802816:	89 c8                	mov    %ecx,%eax
  802818:	89 f2                	mov    %esi,%edx
  80281a:	f7 f7                	div    %edi
  80281c:	89 d0                	mov    %edx,%eax
  80281e:	31 d2                	xor    %edx,%edx
  802820:	83 c4 20             	add    $0x20,%esp
  802823:	5e                   	pop    %esi
  802824:	5f                   	pop    %edi
  802825:	5d                   	pop    %ebp
  802826:	c3                   	ret    
  802827:	89 f6                	mov    %esi,%esi
  802829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802830:	39 f0                	cmp    %esi,%eax
  802832:	77 5c                	ja     802890 <__umoddi3+0xb0>
  802834:	0f bd e8             	bsr    %eax,%ebp
  802837:	83 f5 1f             	xor    $0x1f,%ebp
  80283a:	75 64                	jne    8028a0 <__umoddi3+0xc0>
  80283c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802840:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802844:	0f 86 f6 00 00 00    	jbe    802940 <__umoddi3+0x160>
  80284a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80284e:	0f 82 ec 00 00 00    	jb     802940 <__umoddi3+0x160>
  802854:	8b 44 24 14          	mov    0x14(%esp),%eax
  802858:	8b 54 24 18          	mov    0x18(%esp),%edx
  80285c:	83 c4 20             	add    $0x20,%esp
  80285f:	5e                   	pop    %esi
  802860:	5f                   	pop    %edi
  802861:	5d                   	pop    %ebp
  802862:	c3                   	ret    
  802863:	90                   	nop
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	85 ff                	test   %edi,%edi
  80286a:	89 fd                	mov    %edi,%ebp
  80286c:	75 0b                	jne    802879 <__umoddi3+0x99>
  80286e:	b8 01 00 00 00       	mov    $0x1,%eax
  802873:	31 d2                	xor    %edx,%edx
  802875:	f7 f7                	div    %edi
  802877:	89 c5                	mov    %eax,%ebp
  802879:	8b 44 24 10          	mov    0x10(%esp),%eax
  80287d:	31 d2                	xor    %edx,%edx
  80287f:	f7 f5                	div    %ebp
  802881:	89 c8                	mov    %ecx,%eax
  802883:	f7 f5                	div    %ebp
  802885:	eb 95                	jmp    80281c <__umoddi3+0x3c>
  802887:	89 f6                	mov    %esi,%esi
  802889:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802890:	89 c8                	mov    %ecx,%eax
  802892:	89 f2                	mov    %esi,%edx
  802894:	83 c4 20             	add    $0x20,%esp
  802897:	5e                   	pop    %esi
  802898:	5f                   	pop    %edi
  802899:	5d                   	pop    %ebp
  80289a:	c3                   	ret    
  80289b:	90                   	nop
  80289c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8028a5:	89 e9                	mov    %ebp,%ecx
  8028a7:	29 e8                	sub    %ebp,%eax
  8028a9:	d3 e2                	shl    %cl,%edx
  8028ab:	89 c7                	mov    %eax,%edi
  8028ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8028b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028b5:	89 f9                	mov    %edi,%ecx
  8028b7:	d3 e8                	shr    %cl,%eax
  8028b9:	89 c1                	mov    %eax,%ecx
  8028bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028bf:	09 d1                	or     %edx,%ecx
  8028c1:	89 fa                	mov    %edi,%edx
  8028c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8028c7:	89 e9                	mov    %ebp,%ecx
  8028c9:	d3 e0                	shl    %cl,%eax
  8028cb:	89 f9                	mov    %edi,%ecx
  8028cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028d1:	89 f0                	mov    %esi,%eax
  8028d3:	d3 e8                	shr    %cl,%eax
  8028d5:	89 e9                	mov    %ebp,%ecx
  8028d7:	89 c7                	mov    %eax,%edi
  8028d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028dd:	d3 e6                	shl    %cl,%esi
  8028df:	89 d1                	mov    %edx,%ecx
  8028e1:	89 fa                	mov    %edi,%edx
  8028e3:	d3 e8                	shr    %cl,%eax
  8028e5:	89 e9                	mov    %ebp,%ecx
  8028e7:	09 f0                	or     %esi,%eax
  8028e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8028ed:	f7 74 24 10          	divl   0x10(%esp)
  8028f1:	d3 e6                	shl    %cl,%esi
  8028f3:	89 d1                	mov    %edx,%ecx
  8028f5:	f7 64 24 0c          	mull   0xc(%esp)
  8028f9:	39 d1                	cmp    %edx,%ecx
  8028fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8028ff:	89 d7                	mov    %edx,%edi
  802901:	89 c6                	mov    %eax,%esi
  802903:	72 0a                	jb     80290f <__umoddi3+0x12f>
  802905:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802909:	73 10                	jae    80291b <__umoddi3+0x13b>
  80290b:	39 d1                	cmp    %edx,%ecx
  80290d:	75 0c                	jne    80291b <__umoddi3+0x13b>
  80290f:	89 d7                	mov    %edx,%edi
  802911:	89 c6                	mov    %eax,%esi
  802913:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802917:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80291b:	89 ca                	mov    %ecx,%edx
  80291d:	89 e9                	mov    %ebp,%ecx
  80291f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802923:	29 f0                	sub    %esi,%eax
  802925:	19 fa                	sbb    %edi,%edx
  802927:	d3 e8                	shr    %cl,%eax
  802929:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80292e:	89 d7                	mov    %edx,%edi
  802930:	d3 e7                	shl    %cl,%edi
  802932:	89 e9                	mov    %ebp,%ecx
  802934:	09 f8                	or     %edi,%eax
  802936:	d3 ea                	shr    %cl,%edx
  802938:	83 c4 20             	add    $0x20,%esp
  80293b:	5e                   	pop    %esi
  80293c:	5f                   	pop    %edi
  80293d:	5d                   	pop    %ebp
  80293e:	c3                   	ret    
  80293f:	90                   	nop
  802940:	8b 74 24 10          	mov    0x10(%esp),%esi
  802944:	29 f9                	sub    %edi,%ecx
  802946:	19 c6                	sbb    %eax,%esi
  802948:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80294c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802950:	e9 ff fe ff ff       	jmp    802854 <__umoddi3+0x74>
