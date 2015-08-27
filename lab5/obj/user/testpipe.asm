
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
  80003b:	c7 05 04 30 80 00 40 	movl   $0x802440,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 24 1c 00 00       	call   801c72 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 4c 24 80 00       	push   $0x80244c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 55 24 80 00       	push   $0x802455
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 e0 0f 00 00       	call   80104e <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 db 29 80 00       	push   $0x8029db
  80007a:	6a 11                	push   $0x11
  80007c:	68 55 24 80 00       	push   $0x802455
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 65 24 80 00       	push   $0x802465
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 5e 13 00 00       	call   801410 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 82 24 80 00       	push   $0x802482
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 05 15 00 00       	call   8015e1 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 9f 24 80 00       	push   $0x80249f
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 55 24 80 00       	push   $0x802455
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0e 09 00 00       	call   800a1c <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 a8 24 80 00       	push   $0x8024a8
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 c4 24 80 00       	push   $0x8024c4
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 65 24 80 00       	push   $0x802465
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 a6 12 00 00       	call   801410 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 d7 24 80 00       	push   $0x8024d7
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a8 07 00 00       	call   800939 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 83 14 00 00       	call   801626 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 86 07 00 00       	call   800939 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 f4 24 80 00       	push   $0x8024f4
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 55 24 80 00       	push   $0x802455
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 39 12 00 00       	call   801410 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 17 1c 00 00       	call   801dfa <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 fe 	movl   $0x8024fe,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 7a 1a 00 00       	call   801c72 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 4c 24 80 00       	push   $0x80244c
  800207:	6a 2c                	push   $0x2c
  800209:	68 55 24 80 00       	push   $0x802455
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 36 0e 00 00       	call   80104e <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 db 29 80 00       	push   $0x8029db
  800224:	6a 2f                	push   $0x2f
  800226:	68 55 24 80 00       	push   $0x802455
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 d1 11 00 00       	call   801410 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 0b 25 80 00       	push   $0x80250b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 0d 25 80 00       	push   $0x80250d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 c5 13 00 00       	call   801626 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 0f 25 80 00       	push   $0x80250f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 87 11 00 00       	call   801410 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 7c 11 00 00       	call   801410 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 5e 1b 00 00       	call   801dfa <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
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
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

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
  8002fe:	e8 3a 11 00 00       	call   80143d <close_all>
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
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 18 0a 00 00       	call   800d3d <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 90 25 80 00       	push   $0x802590
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
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
  80044e:	e8 3d 1d 00 00       	call   802190 <__udivdi3>
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
  80048c:	e8 2f 1e 00 00       	call   8022c0 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 b3 25 80 00 	movsbl 0x8025b3(%eax),%eax
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
  800590:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
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
  800654:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	75 18                	jne    800677 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 cb 25 80 00       	push   $0x8025cb
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
  800678:	68 ed 2a 80 00       	push   $0x802aed
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
  8006a5:	ba c4 25 80 00       	mov    $0x8025c4,%edx
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
  800d24:	68 df 28 80 00       	push   $0x8028df
  800d29:	6a 23                	push   $0x23
  800d2b:	68 fc 28 80 00       	push   $0x8028fc
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
  800da5:	68 df 28 80 00       	push   $0x8028df
  800daa:	6a 23                	push   $0x23
  800dac:	68 fc 28 80 00       	push   $0x8028fc
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
  800de7:	68 df 28 80 00       	push   $0x8028df
  800dec:	6a 23                	push   $0x23
  800dee:	68 fc 28 80 00       	push   $0x8028fc
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
  800e29:	68 df 28 80 00       	push   $0x8028df
  800e2e:	6a 23                	push   $0x23
  800e30:	68 fc 28 80 00       	push   $0x8028fc
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
  800e6b:	68 df 28 80 00       	push   $0x8028df
  800e70:	6a 23                	push   $0x23
  800e72:	68 fc 28 80 00       	push   $0x8028fc
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
  800ead:	68 df 28 80 00       	push   $0x8028df
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 fc 28 80 00       	push   $0x8028fc
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
  800eef:	68 df 28 80 00       	push   $0x8028df
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 fc 28 80 00       	push   $0x8028fc
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
  800f53:	68 df 28 80 00       	push   $0x8028df
  800f58:	6a 23                	push   $0x23
  800f5a:	68 fc 28 80 00       	push   $0x8028fc
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

00800f6c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f76:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f78:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f7c:	74 2e                	je     800fac <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 16             	shr    $0x16,%edx
  800f83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	74 1d                	je     800fac <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	c1 ea 0c             	shr    $0xc,%edx
  800f94:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f9b:	f6 c1 01             	test   $0x1,%cl
  800f9e:	74 0c                	je     800fac <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800fa0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800fa7:	f6 c6 08             	test   $0x8,%dh
  800faa:	75 14                	jne    800fc0 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	68 0c 29 80 00       	push   $0x80290c
  800fb4:	6a 21                	push   $0x21
  800fb6:	68 9f 29 80 00       	push   $0x80299f
  800fbb:	e8 52 f3 ff ff       	call   800312 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800fc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fc5:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	6a 07                	push   $0x7
  800fcc:	68 00 f0 7f 00       	push   $0x7ff000
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 a3 fd ff ff       	call   800d7b <sys_page_alloc>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 14                	jns    800ff3 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 aa 29 80 00       	push   $0x8029aa
  800fe7:	6a 2b                	push   $0x2b
  800fe9:	68 9f 29 80 00       	push   $0x80299f
  800fee:	e8 1f f3 ff ff       	call   800312 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	68 00 10 00 00       	push   $0x1000
  800ffb:	53                   	push   %ebx
  800ffc:	68 00 f0 7f 00       	push   $0x7ff000
  801001:	e8 fe fa ff ff       	call   800b04 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  801006:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80100d:	53                   	push   %ebx
  80100e:	6a 00                	push   $0x0
  801010:	68 00 f0 7f 00       	push   $0x7ff000
  801015:	6a 00                	push   $0x0
  801017:	e8 a2 fd ff ff       	call   800dbe <sys_page_map>
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 14                	jns    801037 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	68 c0 29 80 00       	push   $0x8029c0
  80102b:	6a 2e                	push   $0x2e
  80102d:	68 9f 29 80 00       	push   $0x80299f
  801032:	e8 db f2 ff ff       	call   800312 <_panic>
        sys_page_unmap(0, PFTEMP); 
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	68 00 f0 7f 00       	push   $0x7ff000
  80103f:	6a 00                	push   $0x0
  801041:	e8 ba fd ff ff       	call   800e00 <sys_page_unmap>
  801046:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  801049:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  801057:	68 6c 0f 80 00       	push   $0x800f6c
  80105c:	e8 6b 0f 00 00       	call   801fcc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801061:	b8 07 00 00 00       	mov    $0x7,%eax
  801066:	cd 30                	int    $0x30
  801068:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 12                	jns    801084 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801072:	50                   	push   %eax
  801073:	68 d4 29 80 00       	push   $0x8029d4
  801078:	6a 6d                	push   $0x6d
  80107a:	68 9f 29 80 00       	push   $0x80299f
  80107f:	e8 8e f2 ff ff       	call   800312 <_panic>
  801084:	89 c7                	mov    %eax,%edi
  801086:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  80108b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80108f:	75 21                	jne    8010b2 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801091:	e8 a7 fc ff ff       	call   800d3d <sys_getenvid>
  801096:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80109e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a3:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	e9 9c 01 00 00       	jmp    80124e <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  8010b2:	89 d8                	mov    %ebx,%eax
  8010b4:	c1 e8 16             	shr    $0x16,%eax
  8010b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010be:	a8 01                	test   $0x1,%al
  8010c0:	0f 84 f3 00 00 00    	je     8011b9 <fork+0x16b>
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
  8010cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d2:	f6 c2 01             	test   $0x1,%dl
  8010d5:	0f 84 de 00 00 00    	je     8011b9 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  8010db:	89 c6                	mov    %eax,%esi
  8010dd:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  8010e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e7:	f6 c6 04             	test   $0x4,%dh
  8010ea:	74 37                	je     801123 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  8010ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fb:	50                   	push   %eax
  8010fc:	56                   	push   %esi
  8010fd:	57                   	push   %edi
  8010fe:	56                   	push   %esi
  8010ff:	6a 00                	push   $0x0
  801101:	e8 b8 fc ff ff       	call   800dbe <sys_page_map>
  801106:	83 c4 20             	add    $0x20,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	0f 89 a8 00 00 00    	jns    8011b9 <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  801111:	50                   	push   %eax
  801112:	68 30 29 80 00       	push   $0x802930
  801117:	6a 49                	push   $0x49
  801119:	68 9f 29 80 00       	push   $0x80299f
  80111e:	e8 ef f1 ff ff       	call   800312 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801123:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112a:	f6 c6 08             	test   $0x8,%dh
  80112d:	75 0b                	jne    80113a <fork+0xec>
  80112f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801136:	a8 02                	test   $0x2,%al
  801138:	74 57                	je     801191 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	68 05 08 00 00       	push   $0x805
  801142:	56                   	push   %esi
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 72 fc ff ff       	call   800dbe <sys_page_map>
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 12                	jns    801165 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  801153:	50                   	push   %eax
  801154:	68 30 29 80 00       	push   $0x802930
  801159:	6a 4c                	push   $0x4c
  80115b:	68 9f 29 80 00       	push   $0x80299f
  801160:	e8 ad f1 ff ff       	call   800312 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	68 05 08 00 00       	push   $0x805
  80116d:	56                   	push   %esi
  80116e:	6a 00                	push   $0x0
  801170:	56                   	push   %esi
  801171:	6a 00                	push   $0x0
  801173:	e8 46 fc ff ff       	call   800dbe <sys_page_map>
  801178:	83 c4 20             	add    $0x20,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 3a                	jns    8011b9 <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  80117f:	50                   	push   %eax
  801180:	68 54 29 80 00       	push   $0x802954
  801185:	6a 4e                	push   $0x4e
  801187:	68 9f 29 80 00       	push   $0x80299f
  80118c:	e8 81 f1 ff ff       	call   800312 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	6a 05                	push   $0x5
  801196:	56                   	push   %esi
  801197:	57                   	push   %edi
  801198:	56                   	push   %esi
  801199:	6a 00                	push   $0x0
  80119b:	e8 1e fc ff ff       	call   800dbe <sys_page_map>
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	79 12                	jns    8011b9 <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  8011a7:	50                   	push   %eax
  8011a8:	68 7c 29 80 00       	push   $0x80297c
  8011ad:	6a 50                	push   $0x50
  8011af:	68 9f 29 80 00       	push   $0x80299f
  8011b4:	e8 59 f1 ff ff       	call   800312 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8011b9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011bf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011c5:	0f 85 e7 fe ff ff    	jne    8010b2 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	6a 07                	push   $0x7
  8011d0:	68 00 f0 bf ee       	push   $0xeebff000
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	e8 9e fb ff ff       	call   800d7b <sys_page_alloc>
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	79 14                	jns    8011f8 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	68 e4 29 80 00       	push   $0x8029e4
  8011ec:	6a 76                	push   $0x76
  8011ee:	68 9f 29 80 00       	push   $0x80299f
  8011f3:	e8 1a f1 ff ff       	call   800312 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	68 3b 20 80 00       	push   $0x80203b
  801200:	ff 75 e4             	pushl  -0x1c(%ebp)
  801203:	e8 be fc ff ff       	call   800ec6 <sys_env_set_pgfault_upcall>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 14                	jns    801223 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  80120f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801212:	68 fe 29 80 00       	push   $0x8029fe
  801217:	6a 79                	push   $0x79
  801219:	68 9f 29 80 00       	push   $0x80299f
  80121e:	e8 ef f0 ff ff       	call   800312 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	6a 02                	push   $0x2
  801228:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122b:	e8 12 fc ff ff       	call   800e42 <sys_env_set_status>
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	79 14                	jns    80124b <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801237:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123a:	68 1b 2a 80 00       	push   $0x802a1b
  80123f:	6a 7b                	push   $0x7b
  801241:	68 9f 29 80 00       	push   $0x80299f
  801246:	e8 c7 f0 ff ff       	call   800312 <_panic>
        return forkid;
  80124b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80124e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sfork>:

// Challenge!
int
sfork(void)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80125c:	68 32 2a 80 00       	push   $0x802a32
  801261:	68 83 00 00 00       	push   $0x83
  801266:	68 9f 29 80 00       	push   $0x80299f
  80126b:	e8 a2 f0 ff ff       	call   800312 <_panic>

00801270 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	05 00 00 00 30       	add    $0x30000000,%eax
  80127b:	c1 e8 0c             	shr    $0xc,%eax
}
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801283:	8b 45 08             	mov    0x8(%ebp),%eax
  801286:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80128b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801290:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 16             	shr    $0x16,%edx
  8012a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 11                	je     8012c4 <fd_alloc+0x2d>
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	c1 ea 0c             	shr    $0xc,%edx
  8012b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bf:	f6 c2 01             	test   $0x1,%dl
  8012c2:	75 09                	jne    8012cd <fd_alloc+0x36>
			*fd_store = fd;
  8012c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cb:	eb 17                	jmp    8012e4 <fd_alloc+0x4d>
  8012cd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d7:	75 c9                	jne    8012a2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ec:	83 f8 1f             	cmp    $0x1f,%eax
  8012ef:	77 36                	ja     801327 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012f1:	c1 e0 0c             	shl    $0xc,%eax
  8012f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 ea 16             	shr    $0x16,%edx
  8012fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801305:	f6 c2 01             	test   $0x1,%dl
  801308:	74 24                	je     80132e <fd_lookup+0x48>
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	c1 ea 0c             	shr    $0xc,%edx
  80130f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	74 1a                	je     801335 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80131b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131e:	89 02                	mov    %eax,(%edx)
	return 0;
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
  801325:	eb 13                	jmp    80133a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801327:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132c:	eb 0c                	jmp    80133a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801333:	eb 05                	jmp    80133a <fd_lookup+0x54>
  801335:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801345:	ba c4 2a 80 00       	mov    $0x802ac4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80134a:	eb 13                	jmp    80135f <dev_lookup+0x23>
  80134c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80134f:	39 08                	cmp    %ecx,(%eax)
  801351:	75 0c                	jne    80135f <dev_lookup+0x23>
			*dev = devtab[i];
  801353:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801356:	89 01                	mov    %eax,(%ecx)
			return 0;
  801358:	b8 00 00 00 00       	mov    $0x0,%eax
  80135d:	eb 2e                	jmp    80138d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135f:	8b 02                	mov    (%edx),%eax
  801361:	85 c0                	test   %eax,%eax
  801363:	75 e7                	jne    80134c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801365:	a1 04 40 80 00       	mov    0x804004,%eax
  80136a:	8b 40 48             	mov    0x48(%eax),%eax
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	51                   	push   %ecx
  801371:	50                   	push   %eax
  801372:	68 48 2a 80 00       	push   $0x802a48
  801377:	e8 6f f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  80137c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 10             	sub    $0x10,%esp
  801397:	8b 75 08             	mov    0x8(%ebp),%esi
  80139a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a7:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013aa:	50                   	push   %eax
  8013ab:	e8 36 ff ff ff       	call   8012e6 <fd_lookup>
  8013b0:	83 c4 08             	add    $0x8,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 05                	js     8013bc <fd_close+0x2d>
	    || fd != fd2)
  8013b7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ba:	74 0c                	je     8013c8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013bc:	84 db                	test   %bl,%bl
  8013be:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c3:	0f 44 c2             	cmove  %edx,%eax
  8013c6:	eb 41                	jmp    801409 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	ff 36                	pushl  (%esi)
  8013d1:	e8 66 ff ff ff       	call   80133c <dev_lookup>
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 1a                	js     8013f9 <fd_close+0x6a>
		if (dev->dev_close)
  8013df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 0b                	je     8013f9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	56                   	push   %esi
  8013f2:	ff d0                	call   *%eax
  8013f4:	89 c3                	mov    %eax,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	56                   	push   %esi
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 fc f9 ff ff       	call   800e00 <sys_page_unmap>
	return r;
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	89 d8                	mov    %ebx,%eax
}
  801409:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5e                   	pop    %esi
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	ff 75 08             	pushl  0x8(%ebp)
  80141d:	e8 c4 fe ff ff       	call   8012e6 <fd_lookup>
  801422:	89 c2                	mov    %eax,%edx
  801424:	83 c4 08             	add    $0x8,%esp
  801427:	85 d2                	test   %edx,%edx
  801429:	78 10                	js     80143b <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	6a 01                	push   $0x1
  801430:	ff 75 f4             	pushl  -0xc(%ebp)
  801433:	e8 57 ff ff ff       	call   80138f <fd_close>
  801438:	83 c4 10             	add    $0x10,%esp
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <close_all>:

void
close_all(void)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	53                   	push   %ebx
  801441:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801444:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	53                   	push   %ebx
  80144d:	e8 be ff ff ff       	call   801410 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801452:	83 c3 01             	add    $0x1,%ebx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	83 fb 20             	cmp    $0x20,%ebx
  80145b:	75 ec                	jne    801449 <close_all+0xc>
		close(i);
}
  80145d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	57                   	push   %edi
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	83 ec 2c             	sub    $0x2c,%esp
  80146b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80146e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 6c fe ff ff       	call   8012e6 <fd_lookup>
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	85 d2                	test   %edx,%edx
  801481:	0f 88 c1 00 00 00    	js     801548 <dup+0xe6>
		return r;
	close(newfdnum);
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	56                   	push   %esi
  80148b:	e8 80 ff ff ff       	call   801410 <close>

	newfd = INDEX2FD(newfdnum);
  801490:	89 f3                	mov    %esi,%ebx
  801492:	c1 e3 0c             	shl    $0xc,%ebx
  801495:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80149b:	83 c4 04             	add    $0x4,%esp
  80149e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a1:	e8 da fd ff ff       	call   801280 <fd2data>
  8014a6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a8:	89 1c 24             	mov    %ebx,(%esp)
  8014ab:	e8 d0 fd ff ff       	call   801280 <fd2data>
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b6:	89 f8                	mov    %edi,%eax
  8014b8:	c1 e8 16             	shr    $0x16,%eax
  8014bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c2:	a8 01                	test   $0x1,%al
  8014c4:	74 37                	je     8014fd <dup+0x9b>
  8014c6:	89 f8                	mov    %edi,%eax
  8014c8:	c1 e8 0c             	shr    $0xc,%eax
  8014cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d2:	f6 c2 01             	test   $0x1,%dl
  8014d5:	74 26                	je     8014fd <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e6:	50                   	push   %eax
  8014e7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ea:	6a 00                	push   $0x0
  8014ec:	57                   	push   %edi
  8014ed:	6a 00                	push   $0x0
  8014ef:	e8 ca f8 ff ff       	call   800dbe <sys_page_map>
  8014f4:	89 c7                	mov    %eax,%edi
  8014f6:	83 c4 20             	add    $0x20,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 2e                	js     80152b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801500:	89 d0                	mov    %edx,%eax
  801502:	c1 e8 0c             	shr    $0xc,%eax
  801505:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	25 07 0e 00 00       	and    $0xe07,%eax
  801514:	50                   	push   %eax
  801515:	53                   	push   %ebx
  801516:	6a 00                	push   $0x0
  801518:	52                   	push   %edx
  801519:	6a 00                	push   $0x0
  80151b:	e8 9e f8 ff ff       	call   800dbe <sys_page_map>
  801520:	89 c7                	mov    %eax,%edi
  801522:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801525:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801527:	85 ff                	test   %edi,%edi
  801529:	79 1d                	jns    801548 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80152b:	83 ec 08             	sub    $0x8,%esp
  80152e:	53                   	push   %ebx
  80152f:	6a 00                	push   $0x0
  801531:	e8 ca f8 ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801536:	83 c4 08             	add    $0x8,%esp
  801539:	ff 75 d4             	pushl  -0x2c(%ebp)
  80153c:	6a 00                	push   $0x0
  80153e:	e8 bd f8 ff ff       	call   800e00 <sys_page_unmap>
	return r;
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	89 f8                	mov    %edi,%eax
}
  801548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 14             	sub    $0x14,%esp
  801557:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	53                   	push   %ebx
  80155f:	e8 82 fd ff ff       	call   8012e6 <fd_lookup>
  801564:	83 c4 08             	add    $0x8,%esp
  801567:	89 c2                	mov    %eax,%edx
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 6d                	js     8015da <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801577:	ff 30                	pushl  (%eax)
  801579:	e8 be fd ff ff       	call   80133c <dev_lookup>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 4c                	js     8015d1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801585:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801588:	8b 42 08             	mov    0x8(%edx),%eax
  80158b:	83 e0 03             	and    $0x3,%eax
  80158e:	83 f8 01             	cmp    $0x1,%eax
  801591:	75 21                	jne    8015b4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801593:	a1 04 40 80 00       	mov    0x804004,%eax
  801598:	8b 40 48             	mov    0x48(%eax),%eax
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	53                   	push   %ebx
  80159f:	50                   	push   %eax
  8015a0:	68 89 2a 80 00       	push   $0x802a89
  8015a5:	e8 41 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b2:	eb 26                	jmp    8015da <read+0x8a>
	}
	if (!dev->dev_read)
  8015b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b7:	8b 40 08             	mov    0x8(%eax),%eax
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	74 17                	je     8015d5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	ff 75 10             	pushl  0x10(%ebp)
  8015c4:	ff 75 0c             	pushl  0xc(%ebp)
  8015c7:	52                   	push   %edx
  8015c8:	ff d0                	call   *%eax
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	eb 09                	jmp    8015da <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	eb 05                	jmp    8015da <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015da:	89 d0                	mov    %edx,%eax
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	57                   	push   %edi
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f5:	eb 21                	jmp    801618 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f7:	83 ec 04             	sub    $0x4,%esp
  8015fa:	89 f0                	mov    %esi,%eax
  8015fc:	29 d8                	sub    %ebx,%eax
  8015fe:	50                   	push   %eax
  8015ff:	89 d8                	mov    %ebx,%eax
  801601:	03 45 0c             	add    0xc(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	57                   	push   %edi
  801606:	e8 45 ff ff ff       	call   801550 <read>
		if (m < 0)
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 0c                	js     80161e <readn+0x3d>
			return m;
		if (m == 0)
  801612:	85 c0                	test   %eax,%eax
  801614:	74 06                	je     80161c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801616:	01 c3                	add    %eax,%ebx
  801618:	39 f3                	cmp    %esi,%ebx
  80161a:	72 db                	jb     8015f7 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80161c:	89 d8                	mov    %ebx,%eax
}
  80161e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801621:	5b                   	pop    %ebx
  801622:	5e                   	pop    %esi
  801623:	5f                   	pop    %edi
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	53                   	push   %ebx
  80162a:	83 ec 14             	sub    $0x14,%esp
  80162d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801633:	50                   	push   %eax
  801634:	53                   	push   %ebx
  801635:	e8 ac fc ff ff       	call   8012e6 <fd_lookup>
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 68                	js     8016ab <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	ff 30                	pushl  (%eax)
  80164f:	e8 e8 fc ff ff       	call   80133c <dev_lookup>
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 47                	js     8016a2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801662:	75 21                	jne    801685 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801664:	a1 04 40 80 00       	mov    0x804004,%eax
  801669:	8b 40 48             	mov    0x48(%eax),%eax
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	53                   	push   %ebx
  801670:	50                   	push   %eax
  801671:	68 a5 2a 80 00       	push   $0x802aa5
  801676:	e8 70 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801683:	eb 26                	jmp    8016ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801688:	8b 52 0c             	mov    0xc(%edx),%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	74 17                	je     8016a6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	50                   	push   %eax
  801699:	ff d2                	call   *%edx
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	eb 09                	jmp    8016ab <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	eb 05                	jmp    8016ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016ab:	89 d0                	mov    %edx,%eax
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016bb:	50                   	push   %eax
  8016bc:	ff 75 08             	pushl  0x8(%ebp)
  8016bf:	e8 22 fc ff ff       	call   8012e6 <fd_lookup>
  8016c4:	83 c4 08             	add    $0x8,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 0e                	js     8016d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 14             	sub    $0x14,%esp
  8016e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	53                   	push   %ebx
  8016ea:	e8 f7 fb ff ff       	call   8012e6 <fd_lookup>
  8016ef:	83 c4 08             	add    $0x8,%esp
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 65                	js     80175d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801702:	ff 30                	pushl  (%eax)
  801704:	e8 33 fc ff ff       	call   80133c <dev_lookup>
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 44                	js     801754 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801713:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801717:	75 21                	jne    80173a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801719:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80171e:	8b 40 48             	mov    0x48(%eax),%eax
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	53                   	push   %ebx
  801725:	50                   	push   %eax
  801726:	68 68 2a 80 00       	push   $0x802a68
  80172b:	e8 bb ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801738:	eb 23                	jmp    80175d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80173a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173d:	8b 52 18             	mov    0x18(%edx),%edx
  801740:	85 d2                	test   %edx,%edx
  801742:	74 14                	je     801758 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	ff 75 0c             	pushl  0xc(%ebp)
  80174a:	50                   	push   %eax
  80174b:	ff d2                	call   *%edx
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	eb 09                	jmp    80175d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801754:	89 c2                	mov    %eax,%edx
  801756:	eb 05                	jmp    80175d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801758:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80175d:	89 d0                	mov    %edx,%eax
  80175f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	53                   	push   %ebx
  801768:	83 ec 14             	sub    $0x14,%esp
  80176b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	ff 75 08             	pushl  0x8(%ebp)
  801775:	e8 6c fb ff ff       	call   8012e6 <fd_lookup>
  80177a:	83 c4 08             	add    $0x8,%esp
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 58                	js     8017db <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801789:	50                   	push   %eax
  80178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178d:	ff 30                	pushl  (%eax)
  80178f:	e8 a8 fb ff ff       	call   80133c <dev_lookup>
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	78 37                	js     8017d2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a2:	74 32                	je     8017d6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ae:	00 00 00 
	stat->st_isdir = 0;
  8017b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b8:	00 00 00 
	stat->st_dev = dev;
  8017bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c1:	83 ec 08             	sub    $0x8,%esp
  8017c4:	53                   	push   %ebx
  8017c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c8:	ff 50 14             	call   *0x14(%eax)
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	eb 09                	jmp    8017db <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d2:	89 c2                	mov    %eax,%edx
  8017d4:	eb 05                	jmp    8017db <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017db:	89 d0                	mov    %edx,%eax
  8017dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	56                   	push   %esi
  8017e6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	6a 00                	push   $0x0
  8017ec:	ff 75 08             	pushl  0x8(%ebp)
  8017ef:	e8 09 02 00 00       	call   8019fd <open>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 db                	test   %ebx,%ebx
  8017fb:	78 1b                	js     801818 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	ff 75 0c             	pushl  0xc(%ebp)
  801803:	53                   	push   %ebx
  801804:	e8 5b ff ff ff       	call   801764 <fstat>
  801809:	89 c6                	mov    %eax,%esi
	close(fd);
  80180b:	89 1c 24             	mov    %ebx,(%esp)
  80180e:	e8 fd fb ff ff       	call   801410 <close>
	return r;
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	89 f0                	mov    %esi,%eax
}
  801818:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	56                   	push   %esi
  801823:	53                   	push   %ebx
  801824:	89 c6                	mov    %eax,%esi
  801826:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801828:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182f:	75 12                	jne    801843 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801831:	83 ec 0c             	sub    $0xc,%esp
  801834:	6a 01                	push   $0x1
  801836:	e8 e1 08 00 00       	call   80211c <ipc_find_env>
  80183b:	a3 00 40 80 00       	mov    %eax,0x804000
  801840:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801843:	6a 07                	push   $0x7
  801845:	68 00 50 80 00       	push   $0x805000
  80184a:	56                   	push   %esi
  80184b:	ff 35 00 40 80 00    	pushl  0x804000
  801851:	e8 72 08 00 00       	call   8020c8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801856:	83 c4 0c             	add    $0xc,%esp
  801859:	6a 00                	push   $0x0
  80185b:	53                   	push   %ebx
  80185c:	6a 00                	push   $0x0
  80185e:	e8 fc 07 00 00       	call   80205f <ipc_recv>
}
  801863:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 40 0c             	mov    0xc(%eax),%eax
  801876:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80187b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 02 00 00 00       	mov    $0x2,%eax
  80188d:	e8 8d ff ff ff       	call   80181f <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8018af:	e8 6b ff ff ff       	call   80181f <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d5:	e8 45 ff ff ff       	call   80181f <fsipc>
  8018da:	89 c2                	mov    %eax,%edx
  8018dc:	85 d2                	test   %edx,%edx
  8018de:	78 2c                	js     80190c <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	68 00 50 80 00       	push   $0x805000
  8018e8:	53                   	push   %ebx
  8018e9:	e8 84 f0 ff ff       	call   800972 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8018fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	57                   	push   %edi
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
  801923:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801928:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80192b:	eb 3d                	jmp    80196a <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80192d:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801933:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801938:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	57                   	push   %edi
  80193f:	53                   	push   %ebx
  801940:	68 08 50 80 00       	push   $0x805008
  801945:	e8 ba f1 ff ff       	call   800b04 <memmove>
                fsipcbuf.write.req_n = tmp; 
  80194a:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801950:	ba 00 00 00 00       	mov    $0x0,%edx
  801955:	b8 04 00 00 00       	mov    $0x4,%eax
  80195a:	e8 c0 fe ff ff       	call   80181f <fsipc>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 0d                	js     801973 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801966:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801968:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80196a:	85 f6                	test   %esi,%esi
  80196c:	75 bf                	jne    80192d <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801973:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5f                   	pop    %edi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	8b 40 0c             	mov    0xc(%eax),%eax
  801989:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80198e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801994:	ba 00 00 00 00       	mov    $0x0,%edx
  801999:	b8 03 00 00 00       	mov    $0x3,%eax
  80199e:	e8 7c fe ff ff       	call   80181f <fsipc>
  8019a3:	89 c3                	mov    %eax,%ebx
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 4b                	js     8019f4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019a9:	39 c6                	cmp    %eax,%esi
  8019ab:	73 16                	jae    8019c3 <devfile_read+0x48>
  8019ad:	68 d4 2a 80 00       	push   $0x802ad4
  8019b2:	68 db 2a 80 00       	push   $0x802adb
  8019b7:	6a 7c                	push   $0x7c
  8019b9:	68 f0 2a 80 00       	push   $0x802af0
  8019be:	e8 4f e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  8019c3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c8:	7e 16                	jle    8019e0 <devfile_read+0x65>
  8019ca:	68 fb 2a 80 00       	push   $0x802afb
  8019cf:	68 db 2a 80 00       	push   $0x802adb
  8019d4:	6a 7d                	push   $0x7d
  8019d6:	68 f0 2a 80 00       	push   $0x802af0
  8019db:	e8 32 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019e0:	83 ec 04             	sub    $0x4,%esp
  8019e3:	50                   	push   %eax
  8019e4:	68 00 50 80 00       	push   $0x805000
  8019e9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ec:	e8 13 f1 ff ff       	call   800b04 <memmove>
	return r;
  8019f1:	83 c4 10             	add    $0x10,%esp
}
  8019f4:	89 d8                	mov    %ebx,%eax
  8019f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    

008019fd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	53                   	push   %ebx
  801a01:	83 ec 20             	sub    $0x20,%esp
  801a04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a07:	53                   	push   %ebx
  801a08:	e8 2c ef ff ff       	call   800939 <strlen>
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a15:	7f 67                	jg     801a7e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	e8 74 f8 ff ff       	call   801297 <fd_alloc>
  801a23:	83 c4 10             	add    $0x10,%esp
		return r;
  801a26:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 57                	js     801a83 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a2c:	83 ec 08             	sub    $0x8,%esp
  801a2f:	53                   	push   %ebx
  801a30:	68 00 50 80 00       	push   $0x805000
  801a35:	e8 38 ef ff ff       	call   800972 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a45:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4a:	e8 d0 fd ff ff       	call   80181f <fsipc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	79 14                	jns    801a6c <open+0x6f>
		fd_close(fd, 0);
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	6a 00                	push   $0x0
  801a5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a60:	e8 2a f9 ff ff       	call   80138f <fd_close>
		return r;
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	89 da                	mov    %ebx,%edx
  801a6a:	eb 17                	jmp    801a83 <open+0x86>
	}

	return fd2num(fd);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a72:	e8 f9 f7 ff ff       	call   801270 <fd2num>
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb 05                	jmp    801a83 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a7e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a83:	89 d0                	mov    %edx,%eax
  801a85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a90:	ba 00 00 00 00       	mov    $0x0,%edx
  801a95:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9a:	e8 80 fd ff ff       	call   80181f <fsipc>
}
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	ff 75 08             	pushl  0x8(%ebp)
  801aaf:	e8 cc f7 ff ff       	call   801280 <fd2data>
  801ab4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab6:	83 c4 08             	add    $0x8,%esp
  801ab9:	68 07 2b 80 00       	push   $0x802b07
  801abe:	53                   	push   %ebx
  801abf:	e8 ae ee ff ff       	call   800972 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac4:	8b 56 04             	mov    0x4(%esi),%edx
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	2b 06                	sub    (%esi),%eax
  801acb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad8:	00 00 00 
	stat->st_dev = &devpipe;
  801adb:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ae2:	30 80 00 
	return 0;
}
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	53                   	push   %ebx
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801afb:	53                   	push   %ebx
  801afc:	6a 00                	push   $0x0
  801afe:	e8 fd f2 ff ff       	call   800e00 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b03:	89 1c 24             	mov    %ebx,(%esp)
  801b06:	e8 75 f7 ff ff       	call   801280 <fd2data>
  801b0b:	83 c4 08             	add    $0x8,%esp
  801b0e:	50                   	push   %eax
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 ea f2 ff ff       	call   800e00 <sys_page_unmap>
}
  801b16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	83 ec 1c             	sub    $0x1c,%esp
  801b24:	89 c6                	mov    %eax,%esi
  801b26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b29:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	56                   	push   %esi
  801b35:	e8 1a 06 00 00       	call   802154 <pageref>
  801b3a:	89 c7                	mov    %eax,%edi
  801b3c:	83 c4 04             	add    $0x4,%esp
  801b3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b42:	e8 0d 06 00 00       	call   802154 <pageref>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	39 c7                	cmp    %eax,%edi
  801b4c:	0f 94 c2             	sete   %dl
  801b4f:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801b52:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801b58:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801b5b:	39 fb                	cmp    %edi,%ebx
  801b5d:	74 19                	je     801b78 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801b5f:	84 d2                	test   %dl,%dl
  801b61:	74 c6                	je     801b29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b63:	8b 51 58             	mov    0x58(%ecx),%edx
  801b66:	50                   	push   %eax
  801b67:	52                   	push   %edx
  801b68:	53                   	push   %ebx
  801b69:	68 0e 2b 80 00       	push   $0x802b0e
  801b6e:	e8 78 e8 ff ff       	call   8003eb <cprintf>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	eb b1                	jmp    801b29 <_pipeisclosed+0xe>
	}
}
  801b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 28             	sub    $0x28,%esp
  801b89:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b8c:	56                   	push   %esi
  801b8d:	e8 ee f6 ff ff       	call   801280 <fd2data>
  801b92:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	bf 00 00 00 00       	mov    $0x0,%edi
  801b9c:	eb 4b                	jmp    801be9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b9e:	89 da                	mov    %ebx,%edx
  801ba0:	89 f0                	mov    %esi,%eax
  801ba2:	e8 74 ff ff ff       	call   801b1b <_pipeisclosed>
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	75 48                	jne    801bf3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bab:	e8 ac f1 ff ff       	call   800d5c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb3:	8b 0b                	mov    (%ebx),%ecx
  801bb5:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb8:	39 d0                	cmp    %edx,%eax
  801bba:	73 e2                	jae    801b9e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	c1 fa 1f             	sar    $0x1f,%edx
  801bcb:	89 d1                	mov    %edx,%ecx
  801bcd:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd3:	83 e2 1f             	and    $0x1f,%edx
  801bd6:	29 ca                	sub    %ecx,%edx
  801bd8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bdc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be0:	83 c0 01             	add    $0x1,%eax
  801be3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be6:	83 c7 01             	add    $0x1,%edi
  801be9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bec:	75 c2                	jne    801bb0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bee:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf1:	eb 05                	jmp    801bf8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	57                   	push   %edi
  801c04:	56                   	push   %esi
  801c05:	53                   	push   %ebx
  801c06:	83 ec 18             	sub    $0x18,%esp
  801c09:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c0c:	57                   	push   %edi
  801c0d:	e8 6e f6 ff ff       	call   801280 <fd2data>
  801c12:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1c:	eb 3d                	jmp    801c5b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c1e:	85 db                	test   %ebx,%ebx
  801c20:	74 04                	je     801c26 <devpipe_read+0x26>
				return i;
  801c22:	89 d8                	mov    %ebx,%eax
  801c24:	eb 44                	jmp    801c6a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c26:	89 f2                	mov    %esi,%edx
  801c28:	89 f8                	mov    %edi,%eax
  801c2a:	e8 ec fe ff ff       	call   801b1b <_pipeisclosed>
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	75 32                	jne    801c65 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c33:	e8 24 f1 ff ff       	call   800d5c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c38:	8b 06                	mov    (%esi),%eax
  801c3a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c3d:	74 df                	je     801c1e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3f:	99                   	cltd   
  801c40:	c1 ea 1b             	shr    $0x1b,%edx
  801c43:	01 d0                	add    %edx,%eax
  801c45:	83 e0 1f             	and    $0x1f,%eax
  801c48:	29 d0                	sub    %edx,%eax
  801c4a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c52:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c55:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c58:	83 c3 01             	add    $0x1,%ebx
  801c5b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c5e:	75 d8                	jne    801c38 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c60:	8b 45 10             	mov    0x10(%ebp),%eax
  801c63:	eb 05                	jmp    801c6a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	e8 14 f6 ff ff       	call   801297 <fd_alloc>
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	89 c2                	mov    %eax,%edx
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 2c 01 00 00    	js     801dbc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	68 07 04 00 00       	push   $0x407
  801c98:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 d9 f0 ff ff       	call   800d7b <sys_page_alloc>
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	89 c2                	mov    %eax,%edx
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 0d 01 00 00    	js     801dbc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	e8 dc f5 ff ff       	call   801297 <fd_alloc>
  801cbb:	89 c3                	mov    %eax,%ebx
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	0f 88 e2 00 00 00    	js     801daa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	68 07 04 00 00       	push   $0x407
  801cd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 a1 f0 ff ff       	call   800d7b <sys_page_alloc>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 c3 00 00 00    	js     801daa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	e8 8e f5 ff ff       	call   801280 <fd2data>
  801cf2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf4:	83 c4 0c             	add    $0xc,%esp
  801cf7:	68 07 04 00 00       	push   $0x407
  801cfc:	50                   	push   %eax
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 77 f0 ff ff       	call   800d7b <sys_page_alloc>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 89 00 00 00    	js     801d9a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	ff 75 f0             	pushl  -0x10(%ebp)
  801d17:	e8 64 f5 ff ff       	call   801280 <fd2data>
  801d1c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d23:	50                   	push   %eax
  801d24:	6a 00                	push   $0x0
  801d26:	56                   	push   %esi
  801d27:	6a 00                	push   $0x0
  801d29:	e8 90 f0 ff ff       	call   800dbe <sys_page_map>
  801d2e:	89 c3                	mov    %eax,%ebx
  801d30:	83 c4 20             	add    $0x20,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 55                	js     801d8c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d37:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d40:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d45:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d4c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	ff 75 f4             	pushl  -0xc(%ebp)
  801d67:	e8 04 f5 ff ff       	call   801270 <fd2num>
  801d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d71:	83 c4 04             	add    $0x4,%esp
  801d74:	ff 75 f0             	pushl  -0x10(%ebp)
  801d77:	e8 f4 f4 ff ff       	call   801270 <fd2num>
  801d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8a:	eb 30                	jmp    801dbc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	56                   	push   %esi
  801d90:	6a 00                	push   $0x0
  801d92:	e8 69 f0 ff ff       	call   800e00 <sys_page_unmap>
  801d97:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d9a:	83 ec 08             	sub    $0x8,%esp
  801d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801da0:	6a 00                	push   $0x0
  801da2:	e8 59 f0 ff ff       	call   800e00 <sys_page_unmap>
  801da7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 f4             	pushl  -0xc(%ebp)
  801db0:	6a 00                	push   $0x0
  801db2:	e8 49 f0 ff ff       	call   800e00 <sys_page_unmap>
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dbc:	89 d0                	mov    %edx,%eax
  801dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	ff 75 08             	pushl  0x8(%ebp)
  801dd2:	e8 0f f5 ff ff       	call   8012e6 <fd_lookup>
  801dd7:	89 c2                	mov    %eax,%edx
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 d2                	test   %edx,%edx
  801dde:	78 18                	js     801df8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801de0:	83 ec 0c             	sub    $0xc,%esp
  801de3:	ff 75 f4             	pushl  -0xc(%ebp)
  801de6:	e8 95 f4 ff ff       	call   801280 <fd2data>
	return _pipeisclosed(fd, p);
  801deb:	89 c2                	mov    %eax,%edx
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	e8 26 fd ff ff       	call   801b1b <_pipeisclosed>
  801df5:	83 c4 10             	add    $0x10,%esp
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e02:	85 f6                	test   %esi,%esi
  801e04:	75 16                	jne    801e1c <wait+0x22>
  801e06:	68 26 2b 80 00       	push   $0x802b26
  801e0b:	68 db 2a 80 00       	push   $0x802adb
  801e10:	6a 09                	push   $0x9
  801e12:	68 31 2b 80 00       	push   $0x802b31
  801e17:	e8 f6 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e1c:	89 f3                	mov    %esi,%ebx
  801e1e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e24:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e27:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e2d:	eb 05                	jmp    801e34 <wait+0x3a>
		sys_yield();
  801e2f:	e8 28 ef ff ff       	call   800d5c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e34:	8b 43 48             	mov    0x48(%ebx),%eax
  801e37:	39 f0                	cmp    %esi,%eax
  801e39:	75 07                	jne    801e42 <wait+0x48>
  801e3b:	8b 43 54             	mov    0x54(%ebx),%eax
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	75 ed                	jne    801e2f <wait+0x35>
		sys_yield();
}
  801e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e59:	68 3c 2b 80 00       	push   $0x802b3c
  801e5e:	ff 75 0c             	pushl  0xc(%ebp)
  801e61:	e8 0c eb ff ff       	call   800972 <strcpy>
	return 0;
}
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	57                   	push   %edi
  801e71:	56                   	push   %esi
  801e72:	53                   	push   %ebx
  801e73:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e79:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e84:	eb 2d                	jmp    801eb3 <devcons_write+0x46>
		m = n - tot;
  801e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e89:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e8e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e93:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e96:	83 ec 04             	sub    $0x4,%esp
  801e99:	53                   	push   %ebx
  801e9a:	03 45 0c             	add    0xc(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	57                   	push   %edi
  801e9f:	e8 60 ec ff ff       	call   800b04 <memmove>
		sys_cputs(buf, m);
  801ea4:	83 c4 08             	add    $0x8,%esp
  801ea7:	53                   	push   %ebx
  801ea8:	57                   	push   %edi
  801ea9:	e8 11 ee ff ff       	call   800cbf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eae:	01 de                	add    %ebx,%esi
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	89 f0                	mov    %esi,%eax
  801eb5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb8:	72 cc                	jb     801e86 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ecd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed1:	75 07                	jne    801eda <devcons_read+0x18>
  801ed3:	eb 28                	jmp    801efd <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed5:	e8 82 ee ff ff       	call   800d5c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eda:	e8 fe ed ff ff       	call   800cdd <sys_cgetc>
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	74 f2                	je     801ed5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 16                	js     801efd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee7:	83 f8 04             	cmp    $0x4,%eax
  801eea:	74 0c                	je     801ef8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eef:	88 02                	mov    %al,(%edx)
	return 1;
  801ef1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef6:	eb 05                	jmp    801efd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f05:	8b 45 08             	mov    0x8(%ebp),%eax
  801f08:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0b:	6a 01                	push   $0x1
  801f0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f10:	50                   	push   %eax
  801f11:	e8 a9 ed ff ff       	call   800cbf <sys_cputs>
  801f16:	83 c4 10             	add    $0x10,%esp
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <getchar>:

int
getchar(void)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f21:	6a 01                	push   $0x1
  801f23:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f26:	50                   	push   %eax
  801f27:	6a 00                	push   $0x0
  801f29:	e8 22 f6 ff ff       	call   801550 <read>
	if (r < 0)
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 0f                	js     801f44 <getchar+0x29>
		return r;
	if (r < 1)
  801f35:	85 c0                	test   %eax,%eax
  801f37:	7e 06                	jle    801f3f <getchar+0x24>
		return -E_EOF;
	return c;
  801f39:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3d:	eb 05                	jmp    801f44 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f3f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	ff 75 08             	pushl  0x8(%ebp)
  801f53:	e8 8e f3 ff ff       	call   8012e6 <fd_lookup>
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 11                	js     801f70 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f68:	39 10                	cmp    %edx,(%eax)
  801f6a:	0f 94 c0             	sete   %al
  801f6d:	0f b6 c0             	movzbl %al,%eax
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <opencons>:

int
opencons(void)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	e8 16 f3 ff ff       	call   801297 <fd_alloc>
  801f81:	83 c4 10             	add    $0x10,%esp
		return r;
  801f84:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 3e                	js     801fc8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8a:	83 ec 04             	sub    $0x4,%esp
  801f8d:	68 07 04 00 00       	push   $0x407
  801f92:	ff 75 f4             	pushl  -0xc(%ebp)
  801f95:	6a 00                	push   $0x0
  801f97:	e8 df ed ff ff       	call   800d7b <sys_page_alloc>
  801f9c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 23                	js     801fc8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fae:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	50                   	push   %eax
  801fbe:	e8 ad f2 ff ff       	call   801270 <fd2num>
  801fc3:	89 c2                	mov    %eax,%edx
  801fc5:	83 c4 10             	add    $0x10,%esp
}
  801fc8:	89 d0                	mov    %edx,%eax
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fd2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fd9:	75 2c                	jne    802007 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801fdb:	83 ec 04             	sub    $0x4,%esp
  801fde:	6a 07                	push   $0x7
  801fe0:	68 00 f0 bf ee       	push   $0xeebff000
  801fe5:	6a 00                	push   $0x0
  801fe7:	e8 8f ed ff ff       	call   800d7b <sys_page_alloc>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	74 14                	je     802007 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	68 48 2b 80 00       	push   $0x802b48
  801ffb:	6a 21                	push   $0x21
  801ffd:	68 ac 2b 80 00       	push   $0x802bac
  802002:	e8 0b e3 ff ff       	call   800312 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802007:	8b 45 08             	mov    0x8(%ebp),%eax
  80200a:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80200f:	83 ec 08             	sub    $0x8,%esp
  802012:	68 3b 20 80 00       	push   $0x80203b
  802017:	6a 00                	push   $0x0
  802019:	e8 a8 ee ff ff       	call   800ec6 <sys_env_set_pgfault_upcall>
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	85 c0                	test   %eax,%eax
  802023:	79 14                	jns    802039 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802025:	83 ec 04             	sub    $0x4,%esp
  802028:	68 74 2b 80 00       	push   $0x802b74
  80202d:	6a 29                	push   $0x29
  80202f:	68 ac 2b 80 00       	push   $0x802bac
  802034:	e8 d9 e2 ff ff       	call   800312 <_panic>
}
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80203b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80203c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802041:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802043:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802046:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80204b:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80204f:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802053:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802055:	83 c4 08             	add    $0x8,%esp
        popal
  802058:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802059:	83 c4 04             	add    $0x4,%esp
        popfl
  80205c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  80205d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80205e:	c3                   	ret    

0080205f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	8b 75 08             	mov    0x8(%ebp),%esi
  802067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80206d:	85 c0                	test   %eax,%eax
  80206f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802074:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	50                   	push   %eax
  80207b:	e8 ab ee ff ff       	call   800f2b <sys_ipc_recv>
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	79 16                	jns    80209d <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802087:	85 f6                	test   %esi,%esi
  802089:	74 06                	je     802091 <ipc_recv+0x32>
  80208b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802091:	85 db                	test   %ebx,%ebx
  802093:	74 2c                	je     8020c1 <ipc_recv+0x62>
  802095:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80209b:	eb 24                	jmp    8020c1 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80209d:	85 f6                	test   %esi,%esi
  80209f:	74 0a                	je     8020ab <ipc_recv+0x4c>
  8020a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a6:	8b 40 74             	mov    0x74(%eax),%eax
  8020a9:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8020ab:	85 db                	test   %ebx,%ebx
  8020ad:	74 0a                	je     8020b9 <ipc_recv+0x5a>
  8020af:	a1 04 40 80 00       	mov    0x804004,%eax
  8020b4:	8b 40 78             	mov    0x78(%eax),%eax
  8020b7:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8020b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020be:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    

008020c8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	57                   	push   %edi
  8020cc:	56                   	push   %esi
  8020cd:	53                   	push   %ebx
  8020ce:	83 ec 0c             	sub    $0xc,%esp
  8020d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8020da:	85 db                	test   %ebx,%ebx
  8020dc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020e1:	0f 44 d8             	cmove  %eax,%ebx
  8020e4:	eb 1c                	jmp    802102 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8020e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e9:	74 12                	je     8020fd <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8020eb:	50                   	push   %eax
  8020ec:	68 ba 2b 80 00       	push   $0x802bba
  8020f1:	6a 39                	push   $0x39
  8020f3:	68 d5 2b 80 00       	push   $0x802bd5
  8020f8:	e8 15 e2 ff ff       	call   800312 <_panic>
                 sys_yield();
  8020fd:	e8 5a ec ff ff       	call   800d5c <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802102:	ff 75 14             	pushl  0x14(%ebp)
  802105:	53                   	push   %ebx
  802106:	56                   	push   %esi
  802107:	57                   	push   %edi
  802108:	e8 fb ed ff ff       	call   800f08 <sys_ipc_try_send>
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	85 c0                	test   %eax,%eax
  802112:	78 d2                	js     8020e6 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802122:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802127:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80212a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802130:	8b 52 50             	mov    0x50(%edx),%edx
  802133:	39 ca                	cmp    %ecx,%edx
  802135:	75 0d                	jne    802144 <ipc_find_env+0x28>
			return envs[i].env_id;
  802137:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80213a:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80213f:	8b 40 08             	mov    0x8(%eax),%eax
  802142:	eb 0e                	jmp    802152 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802144:	83 c0 01             	add    $0x1,%eax
  802147:	3d 00 04 00 00       	cmp    $0x400,%eax
  80214c:	75 d9                	jne    802127 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80214e:	66 b8 00 00          	mov    $0x0,%ax
}
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	c1 e8 16             	shr    $0x16,%eax
  80215f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802166:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216b:	f6 c1 01             	test   $0x1,%cl
  80216e:	74 1d                	je     80218d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802170:	c1 ea 0c             	shr    $0xc,%edx
  802173:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80217a:	f6 c2 01             	test   $0x1,%dl
  80217d:	74 0e                	je     80218d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80217f:	c1 ea 0c             	shr    $0xc,%edx
  802182:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802189:	ef 
  80218a:	0f b7 c0             	movzwl %ax,%eax
}
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	83 ec 10             	sub    $0x10,%esp
  802196:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80219a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80219e:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021a6:	85 d2                	test   %edx,%edx
  8021a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021ac:	89 34 24             	mov    %esi,(%esp)
  8021af:	89 c8                	mov    %ecx,%eax
  8021b1:	75 35                	jne    8021e8 <__udivdi3+0x58>
  8021b3:	39 f1                	cmp    %esi,%ecx
  8021b5:	0f 87 bd 00 00 00    	ja     802278 <__udivdi3+0xe8>
  8021bb:	85 c9                	test   %ecx,%ecx
  8021bd:	89 cd                	mov    %ecx,%ebp
  8021bf:	75 0b                	jne    8021cc <__udivdi3+0x3c>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	31 d2                	xor    %edx,%edx
  8021c8:	f7 f1                	div    %ecx
  8021ca:	89 c5                	mov    %eax,%ebp
  8021cc:	89 f0                	mov    %esi,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	f7 f5                	div    %ebp
  8021d2:	89 c6                	mov    %eax,%esi
  8021d4:	89 f8                	mov    %edi,%eax
  8021d6:	f7 f5                	div    %ebp
  8021d8:	89 f2                	mov    %esi,%edx
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	5e                   	pop    %esi
  8021de:	5f                   	pop    %edi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    
  8021e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	3b 14 24             	cmp    (%esp),%edx
  8021eb:	77 7b                	ja     802268 <__udivdi3+0xd8>
  8021ed:	0f bd f2             	bsr    %edx,%esi
  8021f0:	83 f6 1f             	xor    $0x1f,%esi
  8021f3:	0f 84 97 00 00 00    	je     802290 <__udivdi3+0x100>
  8021f9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021fe:	89 d7                	mov    %edx,%edi
  802200:	89 f1                	mov    %esi,%ecx
  802202:	29 f5                	sub    %esi,%ebp
  802204:	d3 e7                	shl    %cl,%edi
  802206:	89 c2                	mov    %eax,%edx
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	d3 ea                	shr    %cl,%edx
  80220c:	89 f1                	mov    %esi,%ecx
  80220e:	09 fa                	or     %edi,%edx
  802210:	8b 3c 24             	mov    (%esp),%edi
  802213:	d3 e0                	shl    %cl,%eax
  802215:	89 54 24 08          	mov    %edx,0x8(%esp)
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802223:	89 fa                	mov    %edi,%edx
  802225:	d3 ea                	shr    %cl,%edx
  802227:	89 f1                	mov    %esi,%ecx
  802229:	d3 e7                	shl    %cl,%edi
  80222b:	89 e9                	mov    %ebp,%ecx
  80222d:	d3 e8                	shr    %cl,%eax
  80222f:	09 c7                	or     %eax,%edi
  802231:	89 f8                	mov    %edi,%eax
  802233:	f7 74 24 08          	divl   0x8(%esp)
  802237:	89 d5                	mov    %edx,%ebp
  802239:	89 c7                	mov    %eax,%edi
  80223b:	f7 64 24 0c          	mull   0xc(%esp)
  80223f:	39 d5                	cmp    %edx,%ebp
  802241:	89 14 24             	mov    %edx,(%esp)
  802244:	72 11                	jb     802257 <__udivdi3+0xc7>
  802246:	8b 54 24 04          	mov    0x4(%esp),%edx
  80224a:	89 f1                	mov    %esi,%ecx
  80224c:	d3 e2                	shl    %cl,%edx
  80224e:	39 c2                	cmp    %eax,%edx
  802250:	73 5e                	jae    8022b0 <__udivdi3+0x120>
  802252:	3b 2c 24             	cmp    (%esp),%ebp
  802255:	75 59                	jne    8022b0 <__udivdi3+0x120>
  802257:	8d 47 ff             	lea    -0x1(%edi),%eax
  80225a:	31 f6                	xor    %esi,%esi
  80225c:	89 f2                	mov    %esi,%edx
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
  802268:	31 f6                	xor    %esi,%esi
  80226a:	31 c0                	xor    %eax,%eax
  80226c:	89 f2                	mov    %esi,%edx
  80226e:	83 c4 10             	add    $0x10,%esp
  802271:	5e                   	pop    %esi
  802272:	5f                   	pop    %edi
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    
  802275:	8d 76 00             	lea    0x0(%esi),%esi
  802278:	89 f2                	mov    %esi,%edx
  80227a:	31 f6                	xor    %esi,%esi
  80227c:	89 f8                	mov    %edi,%eax
  80227e:	f7 f1                	div    %ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	83 c4 10             	add    $0x10,%esp
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802294:	76 0b                	jbe    8022a1 <__udivdi3+0x111>
  802296:	31 c0                	xor    %eax,%eax
  802298:	3b 14 24             	cmp    (%esp),%edx
  80229b:	0f 83 37 ff ff ff    	jae    8021d8 <__udivdi3+0x48>
  8022a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a6:	e9 2d ff ff ff       	jmp    8021d8 <__udivdi3+0x48>
  8022ab:	90                   	nop
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 f8                	mov    %edi,%eax
  8022b2:	31 f6                	xor    %esi,%esi
  8022b4:	e9 1f ff ff ff       	jmp    8021d8 <__udivdi3+0x48>
  8022b9:	66 90                	xchg   %ax,%ax
  8022bb:	66 90                	xchg   %ax,%ax
  8022bd:	66 90                	xchg   %ax,%ax
  8022bf:	90                   	nop

008022c0 <__umoddi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	83 ec 20             	sub    $0x20,%esp
  8022c6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8022ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022d2:	89 c6                	mov    %eax,%esi
  8022d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8022e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022e8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	89 c2                	mov    %eax,%edx
  8022f0:	75 1e                	jne    802310 <__umoddi3+0x50>
  8022f2:	39 f7                	cmp    %esi,%edi
  8022f4:	76 52                	jbe    802348 <__umoddi3+0x88>
  8022f6:	89 c8                	mov    %ecx,%eax
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	f7 f7                	div    %edi
  8022fc:	89 d0                	mov    %edx,%eax
  8022fe:	31 d2                	xor    %edx,%edx
  802300:	83 c4 20             	add    $0x20,%esp
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	5d                   	pop    %ebp
  802306:	c3                   	ret    
  802307:	89 f6                	mov    %esi,%esi
  802309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802310:	39 f0                	cmp    %esi,%eax
  802312:	77 5c                	ja     802370 <__umoddi3+0xb0>
  802314:	0f bd e8             	bsr    %eax,%ebp
  802317:	83 f5 1f             	xor    $0x1f,%ebp
  80231a:	75 64                	jne    802380 <__umoddi3+0xc0>
  80231c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802320:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802324:	0f 86 f6 00 00 00    	jbe    802420 <__umoddi3+0x160>
  80232a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80232e:	0f 82 ec 00 00 00    	jb     802420 <__umoddi3+0x160>
  802334:	8b 44 24 14          	mov    0x14(%esp),%eax
  802338:	8b 54 24 18          	mov    0x18(%esp),%edx
  80233c:	83 c4 20             	add    $0x20,%esp
  80233f:	5e                   	pop    %esi
  802340:	5f                   	pop    %edi
  802341:	5d                   	pop    %ebp
  802342:	c3                   	ret    
  802343:	90                   	nop
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	85 ff                	test   %edi,%edi
  80234a:	89 fd                	mov    %edi,%ebp
  80234c:	75 0b                	jne    802359 <__umoddi3+0x99>
  80234e:	b8 01 00 00 00       	mov    $0x1,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f7                	div    %edi
  802357:	89 c5                	mov    %eax,%ebp
  802359:	8b 44 24 10          	mov    0x10(%esp),%eax
  80235d:	31 d2                	xor    %edx,%edx
  80235f:	f7 f5                	div    %ebp
  802361:	89 c8                	mov    %ecx,%eax
  802363:	f7 f5                	div    %ebp
  802365:	eb 95                	jmp    8022fc <__umoddi3+0x3c>
  802367:	89 f6                	mov    %esi,%esi
  802369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	83 c4 20             	add    $0x20,%esp
  802377:	5e                   	pop    %esi
  802378:	5f                   	pop    %edi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
  80237b:	90                   	nop
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	b8 20 00 00 00       	mov    $0x20,%eax
  802385:	89 e9                	mov    %ebp,%ecx
  802387:	29 e8                	sub    %ebp,%eax
  802389:	d3 e2                	shl    %cl,%edx
  80238b:	89 c7                	mov    %eax,%edi
  80238d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802391:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 c1                	mov    %eax,%ecx
  80239b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80239f:	09 d1                	or     %edx,%ecx
  8023a1:	89 fa                	mov    %edi,%edx
  8023a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8023a7:	89 e9                	mov    %ebp,%ecx
  8023a9:	d3 e0                	shl    %cl,%eax
  8023ab:	89 f9                	mov    %edi,%ecx
  8023ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023b1:	89 f0                	mov    %esi,%eax
  8023b3:	d3 e8                	shr    %cl,%eax
  8023b5:	89 e9                	mov    %ebp,%ecx
  8023b7:	89 c7                	mov    %eax,%edi
  8023b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023bd:	d3 e6                	shl    %cl,%esi
  8023bf:	89 d1                	mov    %edx,%ecx
  8023c1:	89 fa                	mov    %edi,%edx
  8023c3:	d3 e8                	shr    %cl,%eax
  8023c5:	89 e9                	mov    %ebp,%ecx
  8023c7:	09 f0                	or     %esi,%eax
  8023c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8023cd:	f7 74 24 10          	divl   0x10(%esp)
  8023d1:	d3 e6                	shl    %cl,%esi
  8023d3:	89 d1                	mov    %edx,%ecx
  8023d5:	f7 64 24 0c          	mull   0xc(%esp)
  8023d9:	39 d1                	cmp    %edx,%ecx
  8023db:	89 74 24 14          	mov    %esi,0x14(%esp)
  8023df:	89 d7                	mov    %edx,%edi
  8023e1:	89 c6                	mov    %eax,%esi
  8023e3:	72 0a                	jb     8023ef <__umoddi3+0x12f>
  8023e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8023e9:	73 10                	jae    8023fb <__umoddi3+0x13b>
  8023eb:	39 d1                	cmp    %edx,%ecx
  8023ed:	75 0c                	jne    8023fb <__umoddi3+0x13b>
  8023ef:	89 d7                	mov    %edx,%edi
  8023f1:	89 c6                	mov    %eax,%esi
  8023f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8023f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8023fb:	89 ca                	mov    %ecx,%edx
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802403:	29 f0                	sub    %esi,%eax
  802405:	19 fa                	sbb    %edi,%edx
  802407:	d3 e8                	shr    %cl,%eax
  802409:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80240e:	89 d7                	mov    %edx,%edi
  802410:	d3 e7                	shl    %cl,%edi
  802412:	89 e9                	mov    %ebp,%ecx
  802414:	09 f8                	or     %edi,%eax
  802416:	d3 ea                	shr    %cl,%edx
  802418:	83 c4 20             	add    $0x20,%esp
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    
  80241f:	90                   	nop
  802420:	8b 74 24 10          	mov    0x10(%esp),%esi
  802424:	29 f9                	sub    %edi,%ecx
  802426:	19 c6                	sbb    %eax,%esi
  802428:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80242c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802430:	e9 ff fe ff ff       	jmp    802334 <__umoddi3+0x74>
