
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 bc 15 00 00       	call   80160d <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 c0 28 80 00       	push   $0x8028c0
  80006d:	6a 15                	push   $0x15
  80006f:	68 ef 28 80 00       	push   $0x8028ef
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 17 2e 80 00       	push   $0x802e17
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 7e 20 00 00       	call   80210f <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 01 29 80 00       	push   $0x802901
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 ef 28 80 00       	push   $0x8028ef
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 c3 0f 00 00       	call   801075 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 db 2d 80 00       	push   $0x802ddb
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 ef 28 80 00       	push   $0x8028ef
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 67 13 00 00       	call   80143c <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 5c 13 00 00       	call   80143c <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 46 13 00 00       	call   80143c <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 02 15 00 00       	call   80160d <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 0a 29 80 00       	push   $0x80290a
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 ef 28 80 00       	push   $0x8028ef
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 04 15 00 00       	call   801652 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 26 29 80 00       	push   $0x802926
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 ef 28 80 00       	push   $0x8028ef
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 40 80 00 40 	movl   $0x802940,0x804000
  800187:	29 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 7c 1f 00 00       	call   80210f <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 01 29 80 00       	push   $0x802901
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 ef 28 80 00       	push   $0x8028ef
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 c1 0e 00 00       	call   801075 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 db 2d 80 00       	push   $0x802ddb
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 ef 28 80 00       	push   $0x8028ef
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 63 12 00 00       	call   80143c <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 4d 12 00 00       	call   80143c <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 48 14 00 00       	call   801652 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 4b 29 80 00       	push   $0x80294b
  800226:	6a 4a                	push   $0x4a
  800228:	68 ef 28 80 00       	push   $0x8028ef
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800243:	e8 7b 0a 00 00       	call   800cc3 <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
  800274:	83 c4 10             	add    $0x10,%esp
}
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 e0 11 00 00       	call   801469 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 ef 09 00 00       	call   800c82 <sys_env_destroy>
  800293:	83 c4 10             	add    $0x10,%esp
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8002a6:	e8 18 0a 00 00       	call   800cc3 <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 70 29 80 00       	push   $0x802970
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 19 2e 80 00 	movl   $0x802e19,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 37 09 00 00       	call   800c45 <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 4f 01 00 00       	call   8004a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 dc 08 00 00       	call   800c45 <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 d1                	mov    %edx,%ecx
  80039a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b0:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8003b3:	72 05                	jb     8003ba <printnum+0x35>
  8003b5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003b8:	77 3e                	ja     8003f8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ba:	83 ec 0c             	sub    $0xc,%esp
  8003bd:	ff 75 18             	pushl  0x18(%ebp)
  8003c0:	83 eb 01             	sub    $0x1,%ebx
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 07 22 00 00       	call   8025e0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 13                	jmp    8003ff <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003f8:	83 eb 01             	sub    $0x1,%ebx
  8003fb:	85 db                	test   %ebx,%ebx
  8003fd:	7f ed                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	56                   	push   %esi
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	ff 75 e4             	pushl  -0x1c(%ebp)
  800409:	ff 75 e0             	pushl  -0x20(%ebp)
  80040c:	ff 75 dc             	pushl  -0x24(%ebp)
  80040f:	ff 75 d8             	pushl  -0x28(%ebp)
  800412:	e8 f9 22 00 00       	call   802710 <__umoddi3>
  800417:	83 c4 14             	add    $0x14,%esp
  80041a:	0f be 80 93 29 80 00 	movsbl 0x802993(%eax),%eax
  800421:	50                   	push   %eax
  800422:	ff d7                	call   *%edi
  800424:	83 c4 10             	add    $0x10,%esp
}
  800427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800432:	83 fa 01             	cmp    $0x1,%edx
  800435:	7e 0e                	jle    800445 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	8b 52 04             	mov    0x4(%edx),%edx
  800443:	eb 22                	jmp    800467 <getuint+0x38>
	else if (lflag)
  800445:	85 d2                	test   %edx,%edx
  800447:	74 10                	je     800459 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
  800457:	eb 0e                	jmp    800467 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 02                	mov    (%edx),%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800473:	8b 10                	mov    (%eax),%edx
  800475:	3b 50 04             	cmp    0x4(%eax),%edx
  800478:	73 0a                	jae    800484 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 45 08             	mov    0x8(%ebp),%eax
  800482:	88 02                	mov    %al,(%edx)
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80048c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048f:	50                   	push   %eax
  800490:	ff 75 10             	pushl  0x10(%ebp)
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	ff 75 08             	pushl  0x8(%ebp)
  800499:	e8 05 00 00 00       	call   8004a3 <vprintfmt>
	va_end(ap);
  80049e:	83 c4 10             	add    $0x10,%esp
}
  8004a1:	c9                   	leave  
  8004a2:	c3                   	ret    

008004a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a3:	55                   	push   %ebp
  8004a4:	89 e5                	mov    %esp,%ebp
  8004a6:	57                   	push   %edi
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 2c             	sub    $0x2c,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004b5:	eb 12                	jmp    8004c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	0f 84 90 03 00 00    	je     80084f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	53                   	push   %ebx
  8004c3:	50                   	push   %eax
  8004c4:	ff d6                	call   *%esi
  8004c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c9:	83 c7 01             	add    $0x1,%edi
  8004cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d0:	83 f8 25             	cmp    $0x25,%eax
  8004d3:	75 e2                	jne    8004b7 <vprintfmt+0x14>
  8004d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f3:	eb 07                	jmp    8004fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8d 47 01             	lea    0x1(%edi),%eax
  8004ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800502:	0f b6 07             	movzbl (%edi),%eax
  800505:	0f b6 c8             	movzbl %al,%ecx
  800508:	83 e8 23             	sub    $0x23,%eax
  80050b:	3c 55                	cmp    $0x55,%al
  80050d:	0f 87 21 03 00 00    	ja     800834 <vprintfmt+0x391>
  800513:	0f b6 c0             	movzbl %al,%eax
  800516:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800520:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800524:	eb d6                	jmp    8004fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	b8 00 00 00 00       	mov    $0x0,%eax
  80052e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800531:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800534:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800538:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80053b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80053e:	83 fa 09             	cmp    $0x9,%edx
  800541:	77 39                	ja     80057c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800543:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800546:	eb e9                	jmp    800531 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 48 04             	lea    0x4(%eax),%ecx
  80054e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800559:	eb 27                	jmp    800582 <vprintfmt+0xdf>
  80055b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055e:	85 c0                	test   %eax,%eax
  800560:	b9 00 00 00 00       	mov    $0x0,%ecx
  800565:	0f 49 c8             	cmovns %eax,%ecx
  800568:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	eb 8c                	jmp    8004fc <vprintfmt+0x59>
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800573:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057a:	eb 80                	jmp    8004fc <vprintfmt+0x59>
  80057c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800582:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800586:	0f 89 70 ff ff ff    	jns    8004fc <vprintfmt+0x59>
				width = precision, precision = -1;
  80058c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800592:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800599:	e9 5e ff ff ff       	jmp    8004fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80059e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a4:	e9 53 ff ff ff       	jmp    8004fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	ff 30                	pushl  (%eax)
  8005b8:	ff d6                	call   *%esi
			break;
  8005ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c0:	e9 04 ff ff ff       	jmp    8004c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	99                   	cltd   
  8005d1:	31 d0                	xor    %edx,%eax
  8005d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d5:	83 f8 0f             	cmp    $0xf,%eax
  8005d8:	7f 0b                	jg     8005e5 <vprintfmt+0x142>
  8005da:	8b 14 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%edx
  8005e1:	85 d2                	test   %edx,%edx
  8005e3:	75 18                	jne    8005fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005e5:	50                   	push   %eax
  8005e6:	68 ab 29 80 00       	push   $0x8029ab
  8005eb:	53                   	push   %ebx
  8005ec:	56                   	push   %esi
  8005ed:	e8 94 fe ff ff       	call   800486 <printfmt>
  8005f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005f8:	e9 cc fe ff ff       	jmp    8004c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005fd:	52                   	push   %edx
  8005fe:	68 f1 2e 80 00       	push   $0x802ef1
  800603:	53                   	push   %ebx
  800604:	56                   	push   %esi
  800605:	e8 7c fe ff ff       	call   800486 <printfmt>
  80060a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800610:	e9 b4 fe ff ff       	jmp    8004c9 <vprintfmt+0x26>
  800615:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800618:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061b:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800629:	85 ff                	test   %edi,%edi
  80062b:	ba a4 29 80 00       	mov    $0x8029a4,%edx
  800630:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800633:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800637:	0f 84 92 00 00 00    	je     8006cf <vprintfmt+0x22c>
  80063d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800641:	0f 8e 96 00 00 00    	jle    8006dd <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	51                   	push   %ecx
  80064b:	57                   	push   %edi
  80064c:	e8 86 02 00 00       	call   8008d7 <strnlen>
  800651:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800654:	29 c1                	sub    %eax,%ecx
  800656:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800660:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800663:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800666:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800668:	eb 0f                	jmp    800679 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	ff 75 e0             	pushl  -0x20(%ebp)
  800671:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800673:	83 ef 01             	sub    $0x1,%edi
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	85 ff                	test   %edi,%edi
  80067b:	7f ed                	jg     80066a <vprintfmt+0x1c7>
  80067d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800680:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800683:	85 c9                	test   %ecx,%ecx
  800685:	b8 00 00 00 00       	mov    $0x0,%eax
  80068a:	0f 49 c1             	cmovns %ecx,%eax
  80068d:	29 c1                	sub    %eax,%ecx
  80068f:	89 75 08             	mov    %esi,0x8(%ebp)
  800692:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800695:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800698:	89 cb                	mov    %ecx,%ebx
  80069a:	eb 4d                	jmp    8006e9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a0:	74 1b                	je     8006bd <vprintfmt+0x21a>
  8006a2:	0f be c0             	movsbl %al,%eax
  8006a5:	83 e8 20             	sub    $0x20,%eax
  8006a8:	83 f8 5e             	cmp    $0x5e,%eax
  8006ab:	76 10                	jbe    8006bd <vprintfmt+0x21a>
					putch('?', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	6a 3f                	push   $0x3f
  8006b5:	ff 55 08             	call   *0x8(%ebp)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 0d                	jmp    8006ca <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	52                   	push   %edx
  8006c4:	ff 55 08             	call   *0x8(%ebp)
  8006c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ca:	83 eb 01             	sub    $0x1,%ebx
  8006cd:	eb 1a                	jmp    8006e9 <vprintfmt+0x246>
  8006cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006db:	eb 0c                	jmp    8006e9 <vprintfmt+0x246>
  8006dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e9:	83 c7 01             	add    $0x1,%edi
  8006ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f0:	0f be d0             	movsbl %al,%edx
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 23                	je     80071a <vprintfmt+0x277>
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	78 a1                	js     80069c <vprintfmt+0x1f9>
  8006fb:	83 ee 01             	sub    $0x1,%esi
  8006fe:	79 9c                	jns    80069c <vprintfmt+0x1f9>
  800700:	89 df                	mov    %ebx,%edi
  800702:	8b 75 08             	mov    0x8(%ebp),%esi
  800705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800708:	eb 18                	jmp    800722 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 20                	push   $0x20
  800710:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800712:	83 ef 01             	sub    $0x1,%edi
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	eb 08                	jmp    800722 <vprintfmt+0x27f>
  80071a:	89 df                	mov    %ebx,%edi
  80071c:	8b 75 08             	mov    0x8(%ebp),%esi
  80071f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800722:	85 ff                	test   %edi,%edi
  800724:	7f e4                	jg     80070a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800729:	e9 9b fd ff ff       	jmp    8004c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072e:	83 fa 01             	cmp    $0x1,%edx
  800731:	7e 16                	jle    800749 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8d 50 08             	lea    0x8(%eax),%edx
  800739:	89 55 14             	mov    %edx,0x14(%ebp)
  80073c:	8b 50 04             	mov    0x4(%eax),%edx
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800747:	eb 32                	jmp    80077b <vprintfmt+0x2d8>
	else if (lflag)
  800749:	85 d2                	test   %edx,%edx
  80074b:	74 18                	je     800765 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8d 50 04             	lea    0x4(%eax),%edx
  800753:	89 55 14             	mov    %edx,0x14(%ebp)
  800756:	8b 00                	mov    (%eax),%eax
  800758:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075b:	89 c1                	mov    %eax,%ecx
  80075d:	c1 f9 1f             	sar    $0x1f,%ecx
  800760:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800763:	eb 16                	jmp    80077b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 04             	lea    0x4(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 00                	mov    (%eax),%eax
  800770:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800773:	89 c1                	mov    %eax,%ecx
  800775:	c1 f9 1f             	sar    $0x1f,%ecx
  800778:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80077b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800781:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800786:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80078a:	79 74                	jns    800800 <vprintfmt+0x35d>
				putch('-', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 2d                	push   $0x2d
  800792:	ff d6                	call   *%esi
				num = -(long long) num;
  800794:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800797:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80079a:	f7 d8                	neg    %eax
  80079c:	83 d2 00             	adc    $0x0,%edx
  80079f:	f7 da                	neg    %edx
  8007a1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a9:	eb 55                	jmp    800800 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ae:	e8 7c fc ff ff       	call   80042f <getuint>
			base = 10;
  8007b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b8:	eb 46                	jmp    800800 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 6d fc ff ff       	call   80042f <getuint>
                        base = 8;
  8007c2:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8007c7:	eb 37                	jmp    800800 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	6a 30                	push   $0x30
  8007cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d1:	83 c4 08             	add    $0x8,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	6a 78                	push   $0x78
  8007d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e2:	8b 00                	mov    (%eax),%eax
  8007e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f1:	eb 0d                	jmp    800800 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f6:	e8 34 fc ff ff       	call   80042f <getuint>
			base = 16;
  8007fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800800:	83 ec 0c             	sub    $0xc,%esp
  800803:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800807:	57                   	push   %edi
  800808:	ff 75 e0             	pushl  -0x20(%ebp)
  80080b:	51                   	push   %ecx
  80080c:	52                   	push   %edx
  80080d:	50                   	push   %eax
  80080e:	89 da                	mov    %ebx,%edx
  800810:	89 f0                	mov    %esi,%eax
  800812:	e8 6e fb ff ff       	call   800385 <printnum>
			break;
  800817:	83 c4 20             	add    $0x20,%esp
  80081a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081d:	e9 a7 fc ff ff       	jmp    8004c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	53                   	push   %ebx
  800826:	51                   	push   %ecx
  800827:	ff d6                	call   *%esi
			break;
  800829:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082f:	e9 95 fc ff ff       	jmp    8004c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	53                   	push   %ebx
  800838:	6a 25                	push   $0x25
  80083a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083c:	83 c4 10             	add    $0x10,%esp
  80083f:	eb 03                	jmp    800844 <vprintfmt+0x3a1>
  800841:	83 ef 01             	sub    $0x1,%edi
  800844:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800848:	75 f7                	jne    800841 <vprintfmt+0x39e>
  80084a:	e9 7a fc ff ff       	jmp    8004c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5f                   	pop    %edi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 18             	sub    $0x18,%esp
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800863:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800866:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80086a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800874:	85 c0                	test   %eax,%eax
  800876:	74 26                	je     80089e <vsnprintf+0x47>
  800878:	85 d2                	test   %edx,%edx
  80087a:	7e 22                	jle    80089e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087c:	ff 75 14             	pushl  0x14(%ebp)
  80087f:	ff 75 10             	pushl  0x10(%ebp)
  800882:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	68 69 04 80 00       	push   $0x800469
  80088b:	e8 13 fc ff ff       	call   8004a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800890:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800893:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800896:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	eb 05                	jmp    8008a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ae:	50                   	push   %eax
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	ff 75 0c             	pushl  0xc(%ebp)
  8008b5:	ff 75 08             	pushl  0x8(%ebp)
  8008b8:	e8 9a ff ff ff       	call   800857 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	eb 03                	jmp    8008cf <strlen+0x10>
		n++;
  8008cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d3:	75 f7                	jne    8008cc <strlen+0xd>
		n++;
	return n;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e5:	eb 03                	jmp    8008ea <strnlen+0x13>
		n++;
  8008e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ea:	39 c2                	cmp    %eax,%edx
  8008ec:	74 08                	je     8008f6 <strnlen+0x1f>
  8008ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f2:	75 f3                	jne    8008e7 <strnlen+0x10>
  8008f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	53                   	push   %ebx
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800902:	89 c2                	mov    %eax,%edx
  800904:	83 c2 01             	add    $0x1,%edx
  800907:	83 c1 01             	add    $0x1,%ecx
  80090a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800911:	84 db                	test   %bl,%bl
  800913:	75 ef                	jne    800904 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800915:	5b                   	pop    %ebx
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091f:	53                   	push   %ebx
  800920:	e8 9a ff ff ff       	call   8008bf <strlen>
  800925:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800928:	ff 75 0c             	pushl  0xc(%ebp)
  80092b:	01 d8                	add    %ebx,%eax
  80092d:	50                   	push   %eax
  80092e:	e8 c5 ff ff ff       	call   8008f8 <strcpy>
	return dst;
}
  800933:	89 d8                	mov    %ebx,%eax
  800935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 75 08             	mov    0x8(%ebp),%esi
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800945:	89 f3                	mov    %esi,%ebx
  800947:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094a:	89 f2                	mov    %esi,%edx
  80094c:	eb 0f                	jmp    80095d <strncpy+0x23>
		*dst++ = *src;
  80094e:	83 c2 01             	add    $0x1,%edx
  800951:	0f b6 01             	movzbl (%ecx),%eax
  800954:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800957:	80 39 01             	cmpb   $0x1,(%ecx)
  80095a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095d:	39 da                	cmp    %ebx,%edx
  80095f:	75 ed                	jne    80094e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800961:	89 f0                	mov    %esi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 75 08             	mov    0x8(%ebp),%esi
  80096f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800972:	8b 55 10             	mov    0x10(%ebp),%edx
  800975:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800977:	85 d2                	test   %edx,%edx
  800979:	74 21                	je     80099c <strlcpy+0x35>
  80097b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097f:	89 f2                	mov    %esi,%edx
  800981:	eb 09                	jmp    80098c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800983:	83 c2 01             	add    $0x1,%edx
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	74 09                	je     800999 <strlcpy+0x32>
  800990:	0f b6 19             	movzbl (%ecx),%ebx
  800993:	84 db                	test   %bl,%bl
  800995:	75 ec                	jne    800983 <strlcpy+0x1c>
  800997:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800999:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099c:	29 f0                	sub    %esi,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strcmp+0x11>
		p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 04                	je     8009be <strcmp+0x1c>
  8009ba:	3a 02                	cmp    (%edx),%al
  8009bc:	74 ef                	je     8009ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 12             	movzbl (%edx),%edx
  8009c4:	29 d0                	sub    %edx,%eax
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c3                	mov    %eax,%ebx
  8009d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d7:	eb 06                	jmp    8009df <strncmp+0x17>
		n--, p++, q++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009df:	39 d8                	cmp    %ebx,%eax
  8009e1:	74 15                	je     8009f8 <strncmp+0x30>
  8009e3:	0f b6 08             	movzbl (%eax),%ecx
  8009e6:	84 c9                	test   %cl,%cl
  8009e8:	74 04                	je     8009ee <strncmp+0x26>
  8009ea:	3a 0a                	cmp    (%edx),%cl
  8009ec:	74 eb                	je     8009d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 00             	movzbl (%eax),%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
  8009f6:	eb 05                	jmp    8009fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0a:	eb 07                	jmp    800a13 <strchr+0x13>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	74 0f                	je     800a1f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a10:	83 c0 01             	add    $0x1,%eax
  800a13:	0f b6 10             	movzbl (%eax),%edx
  800a16:	84 d2                	test   %dl,%dl
  800a18:	75 f2                	jne    800a0c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2b:	eb 03                	jmp    800a30 <strfind+0xf>
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a33:	84 d2                	test   %dl,%dl
  800a35:	74 04                	je     800a3b <strfind+0x1a>
  800a37:	38 ca                	cmp    %cl,%dl
  800a39:	75 f2                	jne    800a2d <strfind+0xc>
			break;
	return (char *) s;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 36                	je     800a83 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a53:	75 28                	jne    800a7d <memset+0x40>
  800a55:	f6 c1 03             	test   $0x3,%cl
  800a58:	75 23                	jne    800a7d <memset+0x40>
		c &= 0xFF;
  800a5a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5e:	89 d3                	mov    %edx,%ebx
  800a60:	c1 e3 08             	shl    $0x8,%ebx
  800a63:	89 d6                	mov    %edx,%esi
  800a65:	c1 e6 18             	shl    $0x18,%esi
  800a68:	89 d0                	mov    %edx,%eax
  800a6a:	c1 e0 10             	shl    $0x10,%eax
  800a6d:	09 f0                	or     %esi,%eax
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	89 d0                	mov    %edx,%eax
  800a73:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a75:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a78:	fc                   	cld    
  800a79:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7b:	eb 06                	jmp    800a83 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a80:	fc                   	cld    
  800a81:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a83:	89 f8                	mov    %edi,%eax
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a98:	39 c6                	cmp    %eax,%esi
  800a9a:	73 35                	jae    800ad1 <memmove+0x47>
  800a9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9f:	39 d0                	cmp    %edx,%eax
  800aa1:	73 2e                	jae    800ad1 <memmove+0x47>
		s += n;
		d += n;
  800aa3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aa6:	89 d6                	mov    %edx,%esi
  800aa8:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab0:	75 13                	jne    800ac5 <memmove+0x3b>
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 0e                	jne    800ac5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab7:	83 ef 04             	sub    $0x4,%edi
  800aba:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ac0:	fd                   	std    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac3:	eb 09                	jmp    800ace <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac5:	83 ef 01             	sub    $0x1,%edi
  800ac8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800acb:	fd                   	std    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ace:	fc                   	cld    
  800acf:	eb 1d                	jmp    800aee <memmove+0x64>
  800ad1:	89 f2                	mov    %esi,%edx
  800ad3:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	f6 c2 03             	test   $0x3,%dl
  800ad8:	75 0f                	jne    800ae9 <memmove+0x5f>
  800ada:	f6 c1 03             	test   $0x3,%cl
  800add:	75 0a                	jne    800ae9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	fc                   	cld    
  800ae5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae7:	eb 05                	jmp    800aee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	fc                   	cld    
  800aec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af5:	ff 75 10             	pushl  0x10(%ebp)
  800af8:	ff 75 0c             	pushl  0xc(%ebp)
  800afb:	ff 75 08             	pushl  0x8(%ebp)
  800afe:	e8 87 ff ff ff       	call   800a8a <memmove>
}
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	89 c6                	mov    %eax,%esi
  800b12:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b15:	eb 1a                	jmp    800b31 <memcmp+0x2c>
		if (*s1 != *s2)
  800b17:	0f b6 08             	movzbl (%eax),%ecx
  800b1a:	0f b6 1a             	movzbl (%edx),%ebx
  800b1d:	38 d9                	cmp    %bl,%cl
  800b1f:	74 0a                	je     800b2b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b21:	0f b6 c1             	movzbl %cl,%eax
  800b24:	0f b6 db             	movzbl %bl,%ebx
  800b27:	29 d8                	sub    %ebx,%eax
  800b29:	eb 0f                	jmp    800b3a <memcmp+0x35>
		s1++, s2++;
  800b2b:	83 c0 01             	add    $0x1,%eax
  800b2e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	39 f0                	cmp    %esi,%eax
  800b33:	75 e2                	jne    800b17 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4c:	eb 07                	jmp    800b55 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	38 08                	cmp    %cl,(%eax)
  800b50:	74 07                	je     800b59 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	39 d0                	cmp    %edx,%eax
  800b57:	72 f5                	jb     800b4e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b67:	eb 03                	jmp    800b6c <strtol+0x11>
		s++;
  800b69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6c:	0f b6 01             	movzbl (%ecx),%eax
  800b6f:	3c 09                	cmp    $0x9,%al
  800b71:	74 f6                	je     800b69 <strtol+0xe>
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f2                	je     800b69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b77:	3c 2b                	cmp    $0x2b,%al
  800b79:	75 0a                	jne    800b85 <strtol+0x2a>
		s++;
  800b7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b83:	eb 10                	jmp    800b95 <strtol+0x3a>
  800b85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8a:	3c 2d                	cmp    $0x2d,%al
  800b8c:	75 07                	jne    800b95 <strtol+0x3a>
		s++, neg = 1;
  800b8e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b91:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	0f 94 c0             	sete   %al
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 19                	jne    800bbb <strtol+0x60>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	75 14                	jne    800bbb <strtol+0x60>
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	0f 85 82 00 00 00    	jne    800c33 <strtol+0xd8>
		s += 2, base = 16;
  800bb1:	83 c1 02             	add    $0x2,%ecx
  800bb4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb9:	eb 16                	jmp    800bd1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bbb:	84 c0                	test   %al,%al
  800bbd:	74 12                	je     800bd1 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	75 08                	jne    800bd1 <strtol+0x76>
		s++, base = 8;
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd9:	0f b6 11             	movzbl (%ecx),%edx
  800bdc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	77 08                	ja     800bee <strtol+0x93>
			dig = *s - '0';
  800be6:	0f be d2             	movsbl %dl,%edx
  800be9:	83 ea 30             	sub    $0x30,%edx
  800bec:	eb 22                	jmp    800c10 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800bee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 08                	ja     800c00 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800bf8:	0f be d2             	movsbl %dl,%edx
  800bfb:	83 ea 57             	sub    $0x57,%edx
  800bfe:	eb 10                	jmp    800c10 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c00:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c03:	89 f3                	mov    %esi,%ebx
  800c05:	80 fb 19             	cmp    $0x19,%bl
  800c08:	77 16                	ja     800c20 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c0a:	0f be d2             	movsbl %dl,%edx
  800c0d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c10:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c13:	7d 0f                	jge    800c24 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c15:	83 c1 01             	add    $0x1,%ecx
  800c18:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c1c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c1e:	eb b9                	jmp    800bd9 <strtol+0x7e>
  800c20:	89 c2                	mov    %eax,%edx
  800c22:	eb 02                	jmp    800c26 <strtol+0xcb>
  800c24:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2a:	74 0d                	je     800c39 <strtol+0xde>
		*endptr = (char *) s;
  800c2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2f:	89 0e                	mov    %ecx,(%esi)
  800c31:	eb 06                	jmp    800c39 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c33:	84 c0                	test   %al,%al
  800c35:	75 92                	jne    800bc9 <strtol+0x6e>
  800c37:	eb 98                	jmp    800bd1 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c39:	f7 da                	neg    %edx
  800c3b:	85 ff                	test   %edi,%edi
  800c3d:	0f 45 c2             	cmovne %edx,%eax
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	89 c7                	mov    %eax,%edi
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	89 d7                	mov    %edx,%edi
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c90:	b8 03 00 00 00       	mov    $0x3,%eax
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 cb                	mov    %ecx,%ebx
  800c9a:	89 cf                	mov    %ecx,%edi
  800c9c:	89 ce                	mov    %ecx,%esi
  800c9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 03                	push   $0x3
  800caa:	68 df 2c 80 00       	push   $0x802cdf
  800caf:	6a 22                	push   $0x22
  800cb1:	68 fc 2c 80 00       	push   $0x802cfc
  800cb6:	e8 dd f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	89 d3                	mov    %edx,%ebx
  800cd7:	89 d7                	mov    %edx,%edi
  800cd9:	89 d6                	mov    %edx,%esi
  800cdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_yield>:

void
sys_yield(void)
{      
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf2:	89 d1                	mov    %edx,%ecx
  800cf4:	89 d3                	mov    %edx,%ebx
  800cf6:	89 d7                	mov    %edx,%edi
  800cf8:	89 d6                	mov    %edx,%esi
  800cfa:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	89 f7                	mov    %esi,%edi
  800d1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7e 17                	jle    800d3c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 04                	push   $0x4
  800d2b:	68 df 2c 80 00       	push   $0x802cdf
  800d30:	6a 22                	push   $0x22
  800d32:	68 fc 2c 80 00       	push   $0x802cfc
  800d37:	e8 5c f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d4d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 17                	jle    800d7e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 05                	push   $0x5
  800d6d:	68 df 2c 80 00       	push   $0x802cdf
  800d72:	6a 22                	push   $0x22
  800d74:	68 fc 2c 80 00       	push   $0x802cfc
  800d79:	e8 1a f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	b8 06 00 00 00       	mov    $0x6,%eax
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 06                	push   $0x6
  800daf:	68 df 2c 80 00       	push   $0x802cdf
  800db4:	6a 22                	push   $0x22
  800db6:	68 fc 2c 80 00       	push   $0x802cfc
  800dbb:	e8 d8 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 08                	push   $0x8
  800df1:	68 df 2c 80 00       	push   $0x802cdf
  800df6:	6a 22                	push   $0x22
  800df8:	68 fc 2c 80 00       	push   $0x802cfc
  800dfd:	e8 96 f4 ff ff       	call   800298 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 09                	push   $0x9
  800e33:	68 df 2c 80 00       	push   $0x802cdf
  800e38:	6a 22                	push   $0x22
  800e3a:	68 fc 2c 80 00       	push   $0x802cfc
  800e3f:	e8 54 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 0a                	push   $0xa
  800e75:	68 df 2c 80 00       	push   $0x802cdf
  800e7a:	6a 22                	push   $0x22
  800e7c:	68 fc 2c 80 00       	push   $0x802cfc
  800e81:	e8 12 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e94:	be 00 00 00 00       	mov    $0x0,%esi
  800e99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eaa:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
  800eb7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800eba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	89 cb                	mov    %ecx,%ebx
  800ec9:	89 cf                	mov    %ecx,%edi
  800ecb:	89 ce                	mov    %ecx,%esi
  800ecd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	7e 17                	jle    800eea <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	50                   	push   %eax
  800ed7:	6a 0d                	push   $0xd
  800ed9:	68 df 2c 80 00       	push   $0x802cdf
  800ede:	6a 22                	push   $0x22
  800ee0:	68 fc 2c 80 00       	push   $0x802cfc
  800ee5:	e8 ae f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ef8:	ba 00 00 00 00       	mov    $0x0,%edx
  800efd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	89 d3                	mov    %edx,%ebx
  800f06:	89 d7                	mov    %edx,%edi
  800f08:	89 d6                	mov    %edx,%esi
  800f0a:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
  800f17:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f24:	8b 55 08             	mov    0x8(%ebp),%edx
  800f27:	89 cb                	mov    %ecx,%ebx
  800f29:	89 cf                	mov    %ecx,%edi
  800f2b:	89 ce                	mov    %ecx,%esi
  800f2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	7e 17                	jle    800f4a <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f33:	83 ec 0c             	sub    $0xc,%esp
  800f36:	50                   	push   %eax
  800f37:	6a 0f                	push   $0xf
  800f39:	68 df 2c 80 00       	push   $0x802cdf
  800f3e:	6a 22                	push   $0x22
  800f40:	68 fc 2c 80 00       	push   $0x802cfc
  800f45:	e8 4e f3 ff ff       	call   800298 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <sys_recv>:

int
sys_recv(void *addr)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f60:	b8 10 00 00 00       	mov    $0x10,%eax
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	89 cb                	mov    %ecx,%ebx
  800f6a:	89 cf                	mov    %ecx,%edi
  800f6c:	89 ce                	mov    %ecx,%esi
  800f6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7e 17                	jle    800f8b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	50                   	push   %eax
  800f78:	6a 10                	push   $0x10
  800f7a:	68 df 2c 80 00       	push   $0x802cdf
  800f7f:	6a 22                	push   $0x22
  800f81:	68 fc 2c 80 00       	push   $0x802cfc
  800f86:	e8 0d f3 ff ff       	call   800298 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	53                   	push   %ebx
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f9d:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f9f:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fa3:	74 2e                	je     800fd3 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800fa5:	89 c2                	mov    %eax,%edx
  800fa7:	c1 ea 16             	shr    $0x16,%edx
  800faa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb1:	f6 c2 01             	test   $0x1,%dl
  800fb4:	74 1d                	je     800fd3 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800fb6:	89 c2                	mov    %eax,%edx
  800fb8:	c1 ea 0c             	shr    $0xc,%edx
  800fbb:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800fc2:	f6 c1 01             	test   $0x1,%cl
  800fc5:	74 0c                	je     800fd3 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800fc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800fce:	f6 c6 08             	test   $0x8,%dh
  800fd1:	75 14                	jne    800fe7 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800fd3:	83 ec 04             	sub    $0x4,%esp
  800fd6:	68 0c 2d 80 00       	push   $0x802d0c
  800fdb:	6a 21                	push   $0x21
  800fdd:	68 9f 2d 80 00       	push   $0x802d9f
  800fe2:	e8 b1 f2 ff ff       	call   800298 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800fe7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fec:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	6a 07                	push   $0x7
  800ff3:	68 00 f0 7f 00       	push   $0x7ff000
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 02 fd ff ff       	call   800d01 <sys_page_alloc>
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	79 14                	jns    80101a <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	68 aa 2d 80 00       	push   $0x802daa
  80100e:	6a 2b                	push   $0x2b
  801010:	68 9f 2d 80 00       	push   $0x802d9f
  801015:	e8 7e f2 ff ff       	call   800298 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	68 00 10 00 00       	push   $0x1000
  801022:	53                   	push   %ebx
  801023:	68 00 f0 7f 00       	push   $0x7ff000
  801028:	e8 5d fa ff ff       	call   800a8a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  80102d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801034:	53                   	push   %ebx
  801035:	6a 00                	push   $0x0
  801037:	68 00 f0 7f 00       	push   $0x7ff000
  80103c:	6a 00                	push   $0x0
  80103e:	e8 01 fd ff ff       	call   800d44 <sys_page_map>
  801043:	83 c4 20             	add    $0x20,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 14                	jns    80105e <pgfault+0xcb>
                panic("sys_page_map fails\n");
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	68 c0 2d 80 00       	push   $0x802dc0
  801052:	6a 2e                	push   $0x2e
  801054:	68 9f 2d 80 00       	push   $0x802d9f
  801059:	e8 3a f2 ff ff       	call   800298 <_panic>
        sys_page_unmap(0, PFTEMP); 
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	68 00 f0 7f 00       	push   $0x7ff000
  801066:	6a 00                	push   $0x0
  801068:	e8 19 fd ff ff       	call   800d86 <sys_page_unmap>
  80106d:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  801070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  80107e:	68 93 0f 80 00       	push   $0x800f93
  801083:	e8 92 13 00 00       	call   80241a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801088:	b8 07 00 00 00       	mov    $0x7,%eax
  80108d:	cd 30                	int    $0x30
  80108f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 12                	jns    8010ab <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801099:	50                   	push   %eax
  80109a:	68 d4 2d 80 00       	push   $0x802dd4
  80109f:	6a 6d                	push   $0x6d
  8010a1:	68 9f 2d 80 00       	push   $0x802d9f
  8010a6:	e8 ed f1 ff ff       	call   800298 <_panic>
  8010ab:	89 c7                	mov    %eax,%edi
  8010ad:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  8010b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010b6:	75 21                	jne    8010d9 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  8010b8:	e8 06 fc ff ff       	call   800cc3 <sys_getenvid>
  8010bd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010ca:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d4:	e9 9c 01 00 00       	jmp    801275 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	c1 e8 16             	shr    $0x16,%eax
  8010de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e5:	a8 01                	test   $0x1,%al
  8010e7:	0f 84 f3 00 00 00    	je     8011e0 <fork+0x16b>
  8010ed:	89 d8                	mov    %ebx,%eax
  8010ef:	c1 e8 0c             	shr    $0xc,%eax
  8010f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f9:	f6 c2 01             	test   $0x1,%dl
  8010fc:	0f 84 de 00 00 00    	je     8011e0 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  801102:	89 c6                	mov    %eax,%esi
  801104:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801107:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110e:	f6 c6 04             	test   $0x4,%dh
  801111:	74 37                	je     80114a <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801113:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	25 07 0e 00 00       	and    $0xe07,%eax
  801122:	50                   	push   %eax
  801123:	56                   	push   %esi
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	6a 00                	push   $0x0
  801128:	e8 17 fc ff ff       	call   800d44 <sys_page_map>
  80112d:	83 c4 20             	add    $0x20,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	0f 89 a8 00 00 00    	jns    8011e0 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  801138:	50                   	push   %eax
  801139:	68 30 2d 80 00       	push   $0x802d30
  80113e:	6a 49                	push   $0x49
  801140:	68 9f 2d 80 00       	push   $0x802d9f
  801145:	e8 4e f1 ff ff       	call   800298 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  80114a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801151:	f6 c6 08             	test   $0x8,%dh
  801154:	75 0b                	jne    801161 <fork+0xec>
  801156:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115d:	a8 02                	test   $0x2,%al
  80115f:	74 57                	je     8011b8 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	68 05 08 00 00       	push   $0x805
  801169:	56                   	push   %esi
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	6a 00                	push   $0x0
  80116e:	e8 d1 fb ff ff       	call   800d44 <sys_page_map>
  801173:	83 c4 20             	add    $0x20,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	79 12                	jns    80118c <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  80117a:	50                   	push   %eax
  80117b:	68 30 2d 80 00       	push   $0x802d30
  801180:	6a 4c                	push   $0x4c
  801182:	68 9f 2d 80 00       	push   $0x802d9f
  801187:	e8 0c f1 ff ff       	call   800298 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	68 05 08 00 00       	push   $0x805
  801194:	56                   	push   %esi
  801195:	6a 00                	push   $0x0
  801197:	56                   	push   %esi
  801198:	6a 00                	push   $0x0
  80119a:	e8 a5 fb ff ff       	call   800d44 <sys_page_map>
  80119f:	83 c4 20             	add    $0x20,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	79 3a                	jns    8011e0 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  8011a6:	50                   	push   %eax
  8011a7:	68 54 2d 80 00       	push   $0x802d54
  8011ac:	6a 4e                	push   $0x4e
  8011ae:	68 9f 2d 80 00       	push   $0x802d9f
  8011b3:	e8 e0 f0 ff ff       	call   800298 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  8011b8:	83 ec 0c             	sub    $0xc,%esp
  8011bb:	6a 05                	push   $0x5
  8011bd:	56                   	push   %esi
  8011be:	57                   	push   %edi
  8011bf:	56                   	push   %esi
  8011c0:	6a 00                	push   $0x0
  8011c2:	e8 7d fb ff ff       	call   800d44 <sys_page_map>
  8011c7:	83 c4 20             	add    $0x20,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	79 12                	jns    8011e0 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  8011ce:	50                   	push   %eax
  8011cf:	68 7c 2d 80 00       	push   $0x802d7c
  8011d4:	6a 50                	push   $0x50
  8011d6:	68 9f 2d 80 00       	push   $0x802d9f
  8011db:	e8 b8 f0 ff ff       	call   800298 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8011e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011e6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011ec:	0f 85 e7 fe ff ff    	jne    8010d9 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	6a 07                	push   $0x7
  8011f7:	68 00 f0 bf ee       	push   $0xeebff000
  8011fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ff:	e8 fd fa ff ff       	call   800d01 <sys_page_alloc>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	79 14                	jns    80121f <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	68 e4 2d 80 00       	push   $0x802de4
  801213:	6a 76                	push   $0x76
  801215:	68 9f 2d 80 00       	push   $0x802d9f
  80121a:	e8 79 f0 ff ff       	call   800298 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	68 89 24 80 00       	push   $0x802489
  801227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122a:	e8 1d fc ff ff       	call   800e4c <sys_env_set_pgfault_upcall>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	79 14                	jns    80124a <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801236:	ff 75 e4             	pushl  -0x1c(%ebp)
  801239:	68 fe 2d 80 00       	push   $0x802dfe
  80123e:	6a 79                	push   $0x79
  801240:	68 9f 2d 80 00       	push   $0x802d9f
  801245:	e8 4e f0 ff ff       	call   800298 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	6a 02                	push   $0x2
  80124f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801252:	e8 71 fb ff ff       	call   800dc8 <sys_env_set_status>
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	79 14                	jns    801272 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80125e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801261:	68 1b 2e 80 00       	push   $0x802e1b
  801266:	6a 7b                	push   $0x7b
  801268:	68 9f 2d 80 00       	push   $0x802d9f
  80126d:	e8 26 f0 ff ff       	call   800298 <_panic>
        return forkid;
  801272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sfork>:

// Challenge!
int
sfork(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801283:	68 32 2e 80 00       	push   $0x802e32
  801288:	68 83 00 00 00       	push   $0x83
  80128d:	68 9f 2d 80 00       	push   $0x802d9f
  801292:	e8 01 f0 ff ff       	call   800298 <_panic>

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
	int i;
	for (i = 0; devtab[i]; i++)
  80136c:	ba 00 00 00 00       	mov    $0x0,%edx
  801371:	eb 13                	jmp    801386 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801373:	39 08                	cmp    %ecx,(%eax)
  801375:	75 0c                	jne    801383 <dev_lookup+0x20>
			*dev = devtab[i];
  801377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137c:	b8 00 00 00 00       	mov    $0x0,%eax
  801381:	eb 36                	jmp    8013b9 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801383:	83 c2 01             	add    $0x1,%edx
  801386:	8b 04 95 c4 2e 80 00 	mov    0x802ec4(,%edx,4),%eax
  80138d:	85 c0                	test   %eax,%eax
  80138f:	75 e2                	jne    801373 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801391:	a1 08 50 80 00       	mov    0x805008,%eax
  801396:	8b 40 48             	mov    0x48(%eax),%eax
  801399:	83 ec 04             	sub    $0x4,%esp
  80139c:	51                   	push   %ecx
  80139d:	50                   	push   %eax
  80139e:	68 48 2e 80 00       	push   $0x802e48
  8013a3:	e8 c9 ef ff ff       	call   800371 <cprintf>
	*dev = 0;
  8013a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 10             	sub    $0x10,%esp
  8013c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013cd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013d3:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d6:	50                   	push   %eax
  8013d7:	e8 31 ff ff ff       	call   80130d <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 05                	js     8013e8 <fd_close+0x2d>
	    || fd != fd2)
  8013e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013e6:	74 0c                	je     8013f4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013e8:	84 db                	test   %bl,%bl
  8013ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ef:	0f 44 c2             	cmove  %edx,%eax
  8013f2:	eb 41                	jmp    801435 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	ff 36                	pushl  (%esi)
  8013fd:	e8 61 ff ff ff       	call   801363 <dev_lookup>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 1a                	js     801425 <fd_close+0x6a>
		if (dev->dev_close)
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801411:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801416:	85 c0                	test   %eax,%eax
  801418:	74 0b                	je     801425 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	56                   	push   %esi
  80141e:	ff d0                	call   *%eax
  801420:	89 c3                	mov    %eax,%ebx
  801422:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	56                   	push   %esi
  801429:	6a 00                	push   $0x0
  80142b:	e8 56 f9 ff ff       	call   800d86 <sys_page_unmap>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 d8                	mov    %ebx,%eax
}
  801435:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	e8 bf fe ff ff       	call   80130d <fd_lookup>
  80144e:	89 c2                	mov    %eax,%edx
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	85 d2                	test   %edx,%edx
  801455:	78 10                	js     801467 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	6a 01                	push   $0x1
  80145c:	ff 75 f4             	pushl  -0xc(%ebp)
  80145f:	e8 57 ff ff ff       	call   8013bb <fd_close>
  801464:	83 c4 10             	add    $0x10,%esp
}
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <close_all>:

void
close_all(void)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	53                   	push   %ebx
  80146d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801470:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	53                   	push   %ebx
  801479:	e8 be ff ff ff       	call   80143c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80147e:	83 c3 01             	add    $0x1,%ebx
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	83 fb 20             	cmp    $0x20,%ebx
  801487:	75 ec                	jne    801475 <close_all+0xc>
		close(i);
}
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	83 ec 2c             	sub    $0x2c,%esp
  801497:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80149a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	ff 75 08             	pushl  0x8(%ebp)
  8014a1:	e8 67 fe ff ff       	call   80130d <fd_lookup>
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	0f 88 c1 00 00 00    	js     801574 <dup+0xe6>
		return r;
	close(newfdnum);
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	56                   	push   %esi
  8014b7:	e8 80 ff ff ff       	call   80143c <close>

	newfd = INDEX2FD(newfdnum);
  8014bc:	89 f3                	mov    %esi,%ebx
  8014be:	c1 e3 0c             	shl    $0xc,%ebx
  8014c1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014c7:	83 c4 04             	add    $0x4,%esp
  8014ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014cd:	e8 d5 fd ff ff       	call   8012a7 <fd2data>
  8014d2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014d4:	89 1c 24             	mov    %ebx,(%esp)
  8014d7:	e8 cb fd ff ff       	call   8012a7 <fd2data>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014e2:	89 f8                	mov    %edi,%eax
  8014e4:	c1 e8 16             	shr    $0x16,%eax
  8014e7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014ee:	a8 01                	test   $0x1,%al
  8014f0:	74 37                	je     801529 <dup+0x9b>
  8014f2:	89 f8                	mov    %edi,%eax
  8014f4:	c1 e8 0c             	shr    $0xc,%eax
  8014f7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014fe:	f6 c2 01             	test   $0x1,%dl
  801501:	74 26                	je     801529 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801503:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150a:	83 ec 0c             	sub    $0xc,%esp
  80150d:	25 07 0e 00 00       	and    $0xe07,%eax
  801512:	50                   	push   %eax
  801513:	ff 75 d4             	pushl  -0x2c(%ebp)
  801516:	6a 00                	push   $0x0
  801518:	57                   	push   %edi
  801519:	6a 00                	push   $0x0
  80151b:	e8 24 f8 ff ff       	call   800d44 <sys_page_map>
  801520:	89 c7                	mov    %eax,%edi
  801522:	83 c4 20             	add    $0x20,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 2e                	js     801557 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801529:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80152c:	89 d0                	mov    %edx,%eax
  80152e:	c1 e8 0c             	shr    $0xc,%eax
  801531:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	25 07 0e 00 00       	and    $0xe07,%eax
  801540:	50                   	push   %eax
  801541:	53                   	push   %ebx
  801542:	6a 00                	push   $0x0
  801544:	52                   	push   %edx
  801545:	6a 00                	push   $0x0
  801547:	e8 f8 f7 ff ff       	call   800d44 <sys_page_map>
  80154c:	89 c7                	mov    %eax,%edi
  80154e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801551:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801553:	85 ff                	test   %edi,%edi
  801555:	79 1d                	jns    801574 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	53                   	push   %ebx
  80155b:	6a 00                	push   $0x0
  80155d:	e8 24 f8 ff ff       	call   800d86 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801562:	83 c4 08             	add    $0x8,%esp
  801565:	ff 75 d4             	pushl  -0x2c(%ebp)
  801568:	6a 00                	push   $0x0
  80156a:	e8 17 f8 ff ff       	call   800d86 <sys_page_unmap>
	return r;
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	89 f8                	mov    %edi,%eax
}
  801574:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801577:	5b                   	pop    %ebx
  801578:	5e                   	pop    %esi
  801579:	5f                   	pop    %edi
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	53                   	push   %ebx
  801580:	83 ec 14             	sub    $0x14,%esp
  801583:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801586:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	53                   	push   %ebx
  80158b:	e8 7d fd ff ff       	call   80130d <fd_lookup>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	89 c2                	mov    %eax,%edx
  801595:	85 c0                	test   %eax,%eax
  801597:	78 6d                	js     801606 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a3:	ff 30                	pushl  (%eax)
  8015a5:	e8 b9 fd ff ff       	call   801363 <dev_lookup>
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 4c                	js     8015fd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015b4:	8b 42 08             	mov    0x8(%edx),%eax
  8015b7:	83 e0 03             	and    $0x3,%eax
  8015ba:	83 f8 01             	cmp    $0x1,%eax
  8015bd:	75 21                	jne    8015e0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015bf:	a1 08 50 80 00       	mov    0x805008,%eax
  8015c4:	8b 40 48             	mov    0x48(%eax),%eax
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	50                   	push   %eax
  8015cc:	68 89 2e 80 00       	push   $0x802e89
  8015d1:	e8 9b ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015de:	eb 26                	jmp    801606 <read+0x8a>
	}
	if (!dev->dev_read)
  8015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e3:	8b 40 08             	mov    0x8(%eax),%eax
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	74 17                	je     801601 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ea:	83 ec 04             	sub    $0x4,%esp
  8015ed:	ff 75 10             	pushl  0x10(%ebp)
  8015f0:	ff 75 0c             	pushl  0xc(%ebp)
  8015f3:	52                   	push   %edx
  8015f4:	ff d0                	call   *%eax
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	eb 09                	jmp    801606 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	eb 05                	jmp    801606 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801601:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801606:	89 d0                	mov    %edx,%eax
  801608:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	57                   	push   %edi
  801611:	56                   	push   %esi
  801612:	53                   	push   %ebx
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	8b 7d 08             	mov    0x8(%ebp),%edi
  801619:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801621:	eb 21                	jmp    801644 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801623:	83 ec 04             	sub    $0x4,%esp
  801626:	89 f0                	mov    %esi,%eax
  801628:	29 d8                	sub    %ebx,%eax
  80162a:	50                   	push   %eax
  80162b:	89 d8                	mov    %ebx,%eax
  80162d:	03 45 0c             	add    0xc(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	57                   	push   %edi
  801632:	e8 45 ff ff ff       	call   80157c <read>
		if (m < 0)
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 0c                	js     80164a <readn+0x3d>
			return m;
		if (m == 0)
  80163e:	85 c0                	test   %eax,%eax
  801640:	74 06                	je     801648 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801642:	01 c3                	add    %eax,%ebx
  801644:	39 f3                	cmp    %esi,%ebx
  801646:	72 db                	jb     801623 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801648:	89 d8                	mov    %ebx,%eax
}
  80164a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5f                   	pop    %edi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 14             	sub    $0x14,%esp
  801659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	53                   	push   %ebx
  801661:	e8 a7 fc ff ff       	call   80130d <fd_lookup>
  801666:	83 c4 08             	add    $0x8,%esp
  801669:	89 c2                	mov    %eax,%edx
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 68                	js     8016d7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	ff 30                	pushl  (%eax)
  80167b:	e8 e3 fc ff ff       	call   801363 <dev_lookup>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 47                	js     8016ce <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168e:	75 21                	jne    8016b1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801690:	a1 08 50 80 00       	mov    0x805008,%eax
  801695:	8b 40 48             	mov    0x48(%eax),%eax
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	53                   	push   %ebx
  80169c:	50                   	push   %eax
  80169d:	68 a5 2e 80 00       	push   $0x802ea5
  8016a2:	e8 ca ec ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016af:	eb 26                	jmp    8016d7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b7:	85 d2                	test   %edx,%edx
  8016b9:	74 17                	je     8016d2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	ff 75 10             	pushl  0x10(%ebp)
  8016c1:	ff 75 0c             	pushl  0xc(%ebp)
  8016c4:	50                   	push   %eax
  8016c5:	ff d2                	call   *%edx
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	eb 09                	jmp    8016d7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ce:	89 c2                	mov    %eax,%edx
  8016d0:	eb 05                	jmp    8016d7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016d7:	89 d0                	mov    %edx,%eax
  8016d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <seek>:

int
seek(int fdnum, off_t offset)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	ff 75 08             	pushl  0x8(%ebp)
  8016eb:	e8 1d fc ff ff       	call   80130d <fd_lookup>
  8016f0:	83 c4 08             	add    $0x8,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 0e                	js     801705 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	83 ec 14             	sub    $0x14,%esp
  80170e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801711:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	53                   	push   %ebx
  801716:	e8 f2 fb ff ff       	call   80130d <fd_lookup>
  80171b:	83 c4 08             	add    $0x8,%esp
  80171e:	89 c2                	mov    %eax,%edx
  801720:	85 c0                	test   %eax,%eax
  801722:	78 65                	js     801789 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172e:	ff 30                	pushl  (%eax)
  801730:	e8 2e fc ff ff       	call   801363 <dev_lookup>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 44                	js     801780 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801743:	75 21                	jne    801766 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801745:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80174a:	8b 40 48             	mov    0x48(%eax),%eax
  80174d:	83 ec 04             	sub    $0x4,%esp
  801750:	53                   	push   %ebx
  801751:	50                   	push   %eax
  801752:	68 68 2e 80 00       	push   $0x802e68
  801757:	e8 15 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801764:	eb 23                	jmp    801789 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801766:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801769:	8b 52 18             	mov    0x18(%edx),%edx
  80176c:	85 d2                	test   %edx,%edx
  80176e:	74 14                	je     801784 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	50                   	push   %eax
  801777:	ff d2                	call   *%edx
  801779:	89 c2                	mov    %eax,%edx
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	eb 09                	jmp    801789 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801780:	89 c2                	mov    %eax,%edx
  801782:	eb 05                	jmp    801789 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801784:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801789:	89 d0                	mov    %edx,%eax
  80178b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 14             	sub    $0x14,%esp
  801797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179d:	50                   	push   %eax
  80179e:	ff 75 08             	pushl  0x8(%ebp)
  8017a1:	e8 67 fb ff ff       	call   80130d <fd_lookup>
  8017a6:	83 c4 08             	add    $0x8,%esp
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 58                	js     801807 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b5:	50                   	push   %eax
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	ff 30                	pushl  (%eax)
  8017bb:	e8 a3 fb ff ff       	call   801363 <dev_lookup>
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 37                	js     8017fe <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ce:	74 32                	je     801802 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017da:	00 00 00 
	stat->st_isdir = 0;
  8017dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e4:	00 00 00 
	stat->st_dev = dev;
  8017e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	53                   	push   %ebx
  8017f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f4:	ff 50 14             	call   *0x14(%eax)
  8017f7:	89 c2                	mov    %eax,%edx
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	eb 09                	jmp    801807 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	eb 05                	jmp    801807 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801802:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801807:	89 d0                	mov    %edx,%eax
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	6a 00                	push   $0x0
  801818:	ff 75 08             	pushl  0x8(%ebp)
  80181b:	e8 09 02 00 00       	call   801a29 <open>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 db                	test   %ebx,%ebx
  801827:	78 1b                	js     801844 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	ff 75 0c             	pushl  0xc(%ebp)
  80182f:	53                   	push   %ebx
  801830:	e8 5b ff ff ff       	call   801790 <fstat>
  801835:	89 c6                	mov    %eax,%esi
	close(fd);
  801837:	89 1c 24             	mov    %ebx,(%esp)
  80183a:	e8 fd fb ff ff       	call   80143c <close>
	return r;
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	89 f0                	mov    %esi,%eax
}
  801844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	89 c6                	mov    %eax,%esi
  801852:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801854:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80185b:	75 12                	jne    80186f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	6a 01                	push   $0x1
  801862:	e8 03 0d 00 00       	call   80256a <ipc_find_env>
  801867:	a3 00 50 80 00       	mov    %eax,0x805000
  80186c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186f:	6a 07                	push   $0x7
  801871:	68 00 60 80 00       	push   $0x806000
  801876:	56                   	push   %esi
  801877:	ff 35 00 50 80 00    	pushl  0x805000
  80187d:	e8 94 0c 00 00       	call   802516 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801882:	83 c4 0c             	add    $0xc,%esp
  801885:	6a 00                	push   $0x0
  801887:	53                   	push   %ebx
  801888:	6a 00                	push   $0x0
  80188a:	e8 1e 0c 00 00       	call   8024ad <ipc_recv>
}
  80188f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801892:	5b                   	pop    %ebx
  801893:	5e                   	pop    %esi
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8018a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018aa:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b9:	e8 8d ff ff ff       	call   80184b <fsipc>
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cc:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018db:	e8 6b ff ff ff       	call   80184b <fsipc>
}
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f2:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 05 00 00 00       	mov    $0x5,%eax
  801901:	e8 45 ff ff ff       	call   80184b <fsipc>
  801906:	89 c2                	mov    %eax,%edx
  801908:	85 d2                	test   %edx,%edx
  80190a:	78 2c                	js     801938 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	68 00 60 80 00       	push   $0x806000
  801914:	53                   	push   %ebx
  801915:	e8 de ef ff ff       	call   8008f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80191a:	a1 80 60 80 00       	mov    0x806080,%eax
  80191f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801925:	a1 84 60 80 00       	mov    0x806084,%eax
  80192a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801938:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	57                   	push   %edi
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	83 ec 0c             	sub    $0xc,%esp
  801946:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8b 40 0c             	mov    0xc(%eax),%eax
  80194f:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801954:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801957:	eb 3d                	jmp    801996 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801959:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80195f:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801964:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801967:	83 ec 04             	sub    $0x4,%esp
  80196a:	57                   	push   %edi
  80196b:	53                   	push   %ebx
  80196c:	68 08 60 80 00       	push   $0x806008
  801971:	e8 14 f1 ff ff       	call   800a8a <memmove>
                fsipcbuf.write.req_n = tmp; 
  801976:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80197c:	ba 00 00 00 00       	mov    $0x0,%edx
  801981:	b8 04 00 00 00       	mov    $0x4,%eax
  801986:	e8 c0 fe ff ff       	call   80184b <fsipc>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 0d                	js     80199f <devfile_write+0x62>
		        return r;
                n -= tmp;
  801992:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801994:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801996:	85 f6                	test   %esi,%esi
  801998:	75 bf                	jne    801959 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80199f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5f                   	pop    %edi
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
  8019ac:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019af:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8019ba:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ca:	e8 7c fe ff ff       	call   80184b <fsipc>
  8019cf:	89 c3                	mov    %eax,%ebx
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 4b                	js     801a20 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019d5:	39 c6                	cmp    %eax,%esi
  8019d7:	73 16                	jae    8019ef <devfile_read+0x48>
  8019d9:	68 d8 2e 80 00       	push   $0x802ed8
  8019de:	68 df 2e 80 00       	push   $0x802edf
  8019e3:	6a 7c                	push   $0x7c
  8019e5:	68 f4 2e 80 00       	push   $0x802ef4
  8019ea:	e8 a9 e8 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  8019ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f4:	7e 16                	jle    801a0c <devfile_read+0x65>
  8019f6:	68 ff 2e 80 00       	push   $0x802eff
  8019fb:	68 df 2e 80 00       	push   $0x802edf
  801a00:	6a 7d                	push   $0x7d
  801a02:	68 f4 2e 80 00       	push   $0x802ef4
  801a07:	e8 8c e8 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a0c:	83 ec 04             	sub    $0x4,%esp
  801a0f:	50                   	push   %eax
  801a10:	68 00 60 80 00       	push   $0x806000
  801a15:	ff 75 0c             	pushl  0xc(%ebp)
  801a18:	e8 6d f0 ff ff       	call   800a8a <memmove>
	return r;
  801a1d:	83 c4 10             	add    $0x10,%esp
}
  801a20:	89 d8                	mov    %ebx,%eax
  801a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 20             	sub    $0x20,%esp
  801a30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a33:	53                   	push   %ebx
  801a34:	e8 86 ee ff ff       	call   8008bf <strlen>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a41:	7f 67                	jg     801aaa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 6f f8 ff ff       	call   8012be <fd_alloc>
  801a4f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a52:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 57                	js     801aaf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	53                   	push   %ebx
  801a5c:	68 00 60 80 00       	push   $0x806000
  801a61:	e8 92 ee ff ff       	call   8008f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a69:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a71:	b8 01 00 00 00       	mov    $0x1,%eax
  801a76:	e8 d0 fd ff ff       	call   80184b <fsipc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	85 c0                	test   %eax,%eax
  801a82:	79 14                	jns    801a98 <open+0x6f>
		fd_close(fd, 0);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	6a 00                	push   $0x0
  801a89:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8c:	e8 2a f9 ff ff       	call   8013bb <fd_close>
		return r;
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	eb 17                	jmp    801aaf <open+0x86>
	}

	return fd2num(fd);
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9e:	e8 f4 f7 ff ff       	call   801297 <fd2num>
  801aa3:	89 c2                	mov    %eax,%edx
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	eb 05                	jmp    801aaf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aaa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aaf:	89 d0                	mov    %edx,%eax
  801ab1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801abc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ac6:	e8 80 fd ff ff       	call   80184b <fsipc>
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ad3:	68 0b 2f 80 00       	push   $0x802f0b
  801ad8:	ff 75 0c             	pushl  0xc(%ebp)
  801adb:	e8 18 ee ff ff       	call   8008f8 <strcpy>
	return 0;
}
  801ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 10             	sub    $0x10,%esp
  801aee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801af1:	53                   	push   %ebx
  801af2:	e8 ab 0a 00 00       	call   8025a2 <pageref>
  801af7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801afa:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801aff:	83 f8 01             	cmp    $0x1,%eax
  801b02:	75 10                	jne    801b14 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	ff 73 0c             	pushl  0xc(%ebx)
  801b0a:	e8 ca 02 00 00       	call   801dd9 <nsipc_close>
  801b0f:	89 c2                	mov    %eax,%edx
  801b11:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b14:	89 d0                	mov    %edx,%eax
  801b16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b21:	6a 00                	push   $0x0
  801b23:	ff 75 10             	pushl  0x10(%ebp)
  801b26:	ff 75 0c             	pushl  0xc(%ebp)
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	ff 70 0c             	pushl  0xc(%eax)
  801b2f:	e8 82 03 00 00       	call   801eb6 <nsipc_send>
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b3c:	6a 00                	push   $0x0
  801b3e:	ff 75 10             	pushl  0x10(%ebp)
  801b41:	ff 75 0c             	pushl  0xc(%ebp)
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	ff 70 0c             	pushl  0xc(%eax)
  801b4a:	e8 fb 02 00 00       	call   801e4a <nsipc_recv>
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b57:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b5a:	52                   	push   %edx
  801b5b:	50                   	push   %eax
  801b5c:	e8 ac f7 ff ff       	call   80130d <fd_lookup>
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 17                	js     801b7f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6b:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801b71:	39 08                	cmp    %ecx,(%eax)
  801b73:	75 05                	jne    801b7a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b75:	8b 40 0c             	mov    0xc(%eax),%eax
  801b78:	eb 05                	jmp    801b7f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b7a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 1c             	sub    $0x1c,%esp
  801b89:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8e:	50                   	push   %eax
  801b8f:	e8 2a f7 ff ff       	call   8012be <fd_alloc>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 1b                	js     801bb8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b9d:	83 ec 04             	sub    $0x4,%esp
  801ba0:	68 07 04 00 00       	push   $0x407
  801ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 52 f1 ff ff       	call   800d01 <sys_page_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 10                	jns    801bc8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	56                   	push   %esi
  801bbc:	e8 18 02 00 00       	call   801dd9 <nsipc_close>
		return r;
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	eb 24                	jmp    801bec <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bc8:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd6:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801bdd:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	52                   	push   %edx
  801be4:	e8 ae f6 ff ff       	call   801297 <fd2num>
  801be9:	83 c4 10             	add    $0x10,%esp
}
  801bec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	e8 50 ff ff ff       	call   801b51 <fd2sockid>
		return r;
  801c01:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 1f                	js     801c26 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c07:	83 ec 04             	sub    $0x4,%esp
  801c0a:	ff 75 10             	pushl  0x10(%ebp)
  801c0d:	ff 75 0c             	pushl  0xc(%ebp)
  801c10:	50                   	push   %eax
  801c11:	e8 1c 01 00 00       	call   801d32 <nsipc_accept>
  801c16:	83 c4 10             	add    $0x10,%esp
		return r;
  801c19:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 07                	js     801c26 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c1f:	e8 5d ff ff ff       	call   801b81 <alloc_sockfd>
  801c24:	89 c1                	mov    %eax,%ecx
}
  801c26:	89 c8                	mov    %ecx,%eax
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	e8 19 ff ff ff       	call   801b51 <fd2sockid>
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	85 d2                	test   %edx,%edx
  801c3c:	78 12                	js     801c50 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801c3e:	83 ec 04             	sub    $0x4,%esp
  801c41:	ff 75 10             	pushl  0x10(%ebp)
  801c44:	ff 75 0c             	pushl  0xc(%ebp)
  801c47:	52                   	push   %edx
  801c48:	e8 35 01 00 00       	call   801d82 <nsipc_bind>
  801c4d:	83 c4 10             	add    $0x10,%esp
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <shutdown>:

int
shutdown(int s, int how)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	e8 f1 fe ff ff       	call   801b51 <fd2sockid>
  801c60:	89 c2                	mov    %eax,%edx
  801c62:	85 d2                	test   %edx,%edx
  801c64:	78 0f                	js     801c75 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c66:	83 ec 08             	sub    $0x8,%esp
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	52                   	push   %edx
  801c6d:	e8 45 01 00 00       	call   801db7 <nsipc_shutdown>
  801c72:	83 c4 10             	add    $0x10,%esp
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	e8 cc fe ff ff       	call   801b51 <fd2sockid>
  801c85:	89 c2                	mov    %eax,%edx
  801c87:	85 d2                	test   %edx,%edx
  801c89:	78 12                	js     801c9d <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c8b:	83 ec 04             	sub    $0x4,%esp
  801c8e:	ff 75 10             	pushl  0x10(%ebp)
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	52                   	push   %edx
  801c95:	e8 59 01 00 00       	call   801df3 <nsipc_connect>
  801c9a:	83 c4 10             	add    $0x10,%esp
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <listen>:

int
listen(int s, int backlog)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	e8 a4 fe ff ff       	call   801b51 <fd2sockid>
  801cad:	89 c2                	mov    %eax,%edx
  801caf:	85 d2                	test   %edx,%edx
  801cb1:	78 0f                	js     801cc2 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	ff 75 0c             	pushl  0xc(%ebp)
  801cb9:	52                   	push   %edx
  801cba:	e8 69 01 00 00       	call   801e28 <nsipc_listen>
  801cbf:	83 c4 10             	add    $0x10,%esp
}
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cca:	ff 75 10             	pushl  0x10(%ebp)
  801ccd:	ff 75 0c             	pushl  0xc(%ebp)
  801cd0:	ff 75 08             	pushl  0x8(%ebp)
  801cd3:	e8 3c 02 00 00       	call   801f14 <nsipc_socket>
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 d2                	test   %edx,%edx
  801cdf:	78 05                	js     801ce6 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801ce1:	e8 9b fe ff ff       	call   801b81 <alloc_sockfd>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 04             	sub    $0x4,%esp
  801cef:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cf1:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801cf8:	75 12                	jne    801d0c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cfa:	83 ec 0c             	sub    $0xc,%esp
  801cfd:	6a 02                	push   $0x2
  801cff:	e8 66 08 00 00       	call   80256a <ipc_find_env>
  801d04:	a3 04 50 80 00       	mov    %eax,0x805004
  801d09:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d0c:	6a 07                	push   $0x7
  801d0e:	68 00 70 80 00       	push   $0x807000
  801d13:	53                   	push   %ebx
  801d14:	ff 35 04 50 80 00    	pushl  0x805004
  801d1a:	e8 f7 07 00 00       	call   802516 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d1f:	83 c4 0c             	add    $0xc,%esp
  801d22:	6a 00                	push   $0x0
  801d24:	6a 00                	push   $0x0
  801d26:	6a 00                	push   $0x0
  801d28:	e8 80 07 00 00       	call   8024ad <ipc_recv>
}
  801d2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	56                   	push   %esi
  801d36:	53                   	push   %ebx
  801d37:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d42:	8b 06                	mov    (%esi),%eax
  801d44:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d49:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4e:	e8 95 ff ff ff       	call   801ce8 <nsipc>
  801d53:	89 c3                	mov    %eax,%ebx
  801d55:	85 c0                	test   %eax,%eax
  801d57:	78 20                	js     801d79 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	ff 35 10 70 80 00    	pushl  0x807010
  801d62:	68 00 70 80 00       	push   $0x807000
  801d67:	ff 75 0c             	pushl  0xc(%ebp)
  801d6a:	e8 1b ed ff ff       	call   800a8a <memmove>
		*addrlen = ret->ret_addrlen;
  801d6f:	a1 10 70 80 00       	mov    0x807010,%eax
  801d74:	89 06                	mov    %eax,(%esi)
  801d76:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d79:	89 d8                	mov    %ebx,%eax
  801d7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	53                   	push   %ebx
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d94:	53                   	push   %ebx
  801d95:	ff 75 0c             	pushl  0xc(%ebp)
  801d98:	68 04 70 80 00       	push   $0x807004
  801d9d:	e8 e8 ec ff ff       	call   800a8a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801da2:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801da8:	b8 02 00 00 00       	mov    $0x2,%eax
  801dad:	e8 36 ff ff ff       	call   801ce8 <nsipc>
}
  801db2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801dcd:	b8 03 00 00 00       	mov    $0x3,%eax
  801dd2:	e8 11 ff ff ff       	call   801ce8 <nsipc>
}
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    

00801dd9 <nsipc_close>:

int
nsipc_close(int s)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801de7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dec:	e8 f7 fe ff ff       	call   801ce8 <nsipc>
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	53                   	push   %ebx
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e05:	53                   	push   %ebx
  801e06:	ff 75 0c             	pushl  0xc(%ebp)
  801e09:	68 04 70 80 00       	push   $0x807004
  801e0e:	e8 77 ec ff ff       	call   800a8a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e13:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e19:	b8 05 00 00 00       	mov    $0x5,%eax
  801e1e:	e8 c5 fe ff ff       	call   801ce8 <nsipc>
}
  801e23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e39:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e3e:	b8 06 00 00 00       	mov    $0x6,%eax
  801e43:	e8 a0 fe ff ff       	call   801ce8 <nsipc>
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	56                   	push   %esi
  801e4e:	53                   	push   %ebx
  801e4f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e5a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e60:	8b 45 14             	mov    0x14(%ebp),%eax
  801e63:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e68:	b8 07 00 00 00       	mov    $0x7,%eax
  801e6d:	e8 76 fe ff ff       	call   801ce8 <nsipc>
  801e72:	89 c3                	mov    %eax,%ebx
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 35                	js     801ead <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e78:	39 f0                	cmp    %esi,%eax
  801e7a:	7f 07                	jg     801e83 <nsipc_recv+0x39>
  801e7c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e81:	7e 16                	jle    801e99 <nsipc_recv+0x4f>
  801e83:	68 17 2f 80 00       	push   $0x802f17
  801e88:	68 df 2e 80 00       	push   $0x802edf
  801e8d:	6a 62                	push   $0x62
  801e8f:	68 2c 2f 80 00       	push   $0x802f2c
  801e94:	e8 ff e3 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e99:	83 ec 04             	sub    $0x4,%esp
  801e9c:	50                   	push   %eax
  801e9d:	68 00 70 80 00       	push   $0x807000
  801ea2:	ff 75 0c             	pushl  0xc(%ebp)
  801ea5:	e8 e0 eb ff ff       	call   800a8a <memmove>
  801eaa:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ead:	89 d8                	mov    %ebx,%eax
  801eaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb2:	5b                   	pop    %ebx
  801eb3:	5e                   	pop    %esi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	53                   	push   %ebx
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec3:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ec8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ece:	7e 16                	jle    801ee6 <nsipc_send+0x30>
  801ed0:	68 38 2f 80 00       	push   $0x802f38
  801ed5:	68 df 2e 80 00       	push   $0x802edf
  801eda:	6a 6d                	push   $0x6d
  801edc:	68 2c 2f 80 00       	push   $0x802f2c
  801ee1:	e8 b2 e3 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ee6:	83 ec 04             	sub    $0x4,%esp
  801ee9:	53                   	push   %ebx
  801eea:	ff 75 0c             	pushl  0xc(%ebp)
  801eed:	68 0c 70 80 00       	push   $0x80700c
  801ef2:	e8 93 eb ff ff       	call   800a8a <memmove>
	nsipcbuf.send.req_size = size;
  801ef7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801efd:	8b 45 14             	mov    0x14(%ebp),%eax
  801f00:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f05:	b8 08 00 00 00       	mov    $0x8,%eax
  801f0a:	e8 d9 fd ff ff       	call   801ce8 <nsipc>
}
  801f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801f22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f25:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801f2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801f32:	b8 09 00 00 00       	mov    $0x9,%eax
  801f37:	e8 ac fd ff ff       	call   801ce8 <nsipc>
}
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	ff 75 08             	pushl  0x8(%ebp)
  801f4c:	e8 56 f3 ff ff       	call   8012a7 <fd2data>
  801f51:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f53:	83 c4 08             	add    $0x8,%esp
  801f56:	68 44 2f 80 00       	push   $0x802f44
  801f5b:	53                   	push   %ebx
  801f5c:	e8 97 e9 ff ff       	call   8008f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f61:	8b 56 04             	mov    0x4(%esi),%edx
  801f64:	89 d0                	mov    %edx,%eax
  801f66:	2b 06                	sub    (%esi),%eax
  801f68:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f6e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f75:	00 00 00 
	stat->st_dev = &devpipe;
  801f78:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  801f7f:	40 80 00 
	return 0;
}
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
  801f87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8a:	5b                   	pop    %ebx
  801f8b:	5e                   	pop    %esi
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	53                   	push   %ebx
  801f92:	83 ec 0c             	sub    $0xc,%esp
  801f95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f98:	53                   	push   %ebx
  801f99:	6a 00                	push   $0x0
  801f9b:	e8 e6 ed ff ff       	call   800d86 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa0:	89 1c 24             	mov    %ebx,(%esp)
  801fa3:	e8 ff f2 ff ff       	call   8012a7 <fd2data>
  801fa8:	83 c4 08             	add    $0x8,%esp
  801fab:	50                   	push   %eax
  801fac:	6a 00                	push   $0x0
  801fae:	e8 d3 ed ff ff       	call   800d86 <sys_page_unmap>
}
  801fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	57                   	push   %edi
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 1c             	sub    $0x1c,%esp
  801fc1:	89 c6                	mov    %eax,%esi
  801fc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fc6:	a1 08 50 80 00       	mov    0x805008,%eax
  801fcb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	56                   	push   %esi
  801fd2:	e8 cb 05 00 00       	call   8025a2 <pageref>
  801fd7:	89 c7                	mov    %eax,%edi
  801fd9:	83 c4 04             	add    $0x4,%esp
  801fdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fdf:	e8 be 05 00 00       	call   8025a2 <pageref>
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	39 c7                	cmp    %eax,%edi
  801fe9:	0f 94 c2             	sete   %dl
  801fec:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801fef:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  801ff5:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ff8:	39 fb                	cmp    %edi,%ebx
  801ffa:	74 19                	je     802015 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801ffc:	84 d2                	test   %dl,%dl
  801ffe:	74 c6                	je     801fc6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802000:	8b 51 58             	mov    0x58(%ecx),%edx
  802003:	50                   	push   %eax
  802004:	52                   	push   %edx
  802005:	53                   	push   %ebx
  802006:	68 4b 2f 80 00       	push   $0x802f4b
  80200b:	e8 61 e3 ff ff       	call   800371 <cprintf>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	eb b1                	jmp    801fc6 <_pipeisclosed+0xe>
	}
}
  802015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	57                   	push   %edi
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	83 ec 28             	sub    $0x28,%esp
  802026:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802029:	56                   	push   %esi
  80202a:	e8 78 f2 ff ff       	call   8012a7 <fd2data>
  80202f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	bf 00 00 00 00       	mov    $0x0,%edi
  802039:	eb 4b                	jmp    802086 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80203b:	89 da                	mov    %ebx,%edx
  80203d:	89 f0                	mov    %esi,%eax
  80203f:	e8 74 ff ff ff       	call   801fb8 <_pipeisclosed>
  802044:	85 c0                	test   %eax,%eax
  802046:	75 48                	jne    802090 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802048:	e8 95 ec ff ff       	call   800ce2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80204d:	8b 43 04             	mov    0x4(%ebx),%eax
  802050:	8b 0b                	mov    (%ebx),%ecx
  802052:	8d 51 20             	lea    0x20(%ecx),%edx
  802055:	39 d0                	cmp    %edx,%eax
  802057:	73 e2                	jae    80203b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802059:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802060:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802063:	89 c2                	mov    %eax,%edx
  802065:	c1 fa 1f             	sar    $0x1f,%edx
  802068:	89 d1                	mov    %edx,%ecx
  80206a:	c1 e9 1b             	shr    $0x1b,%ecx
  80206d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802070:	83 e2 1f             	and    $0x1f,%edx
  802073:	29 ca                	sub    %ecx,%edx
  802075:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802079:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80207d:	83 c0 01             	add    $0x1,%eax
  802080:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802083:	83 c7 01             	add    $0x1,%edi
  802086:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802089:	75 c2                	jne    80204d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80208b:	8b 45 10             	mov    0x10(%ebp),%eax
  80208e:	eb 05                	jmp    802095 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802090:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5f                   	pop    %edi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	57                   	push   %edi
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 18             	sub    $0x18,%esp
  8020a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020a9:	57                   	push   %edi
  8020aa:	e8 f8 f1 ff ff       	call   8012a7 <fd2data>
  8020af:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020b9:	eb 3d                	jmp    8020f8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020bb:	85 db                	test   %ebx,%ebx
  8020bd:	74 04                	je     8020c3 <devpipe_read+0x26>
				return i;
  8020bf:	89 d8                	mov    %ebx,%eax
  8020c1:	eb 44                	jmp    802107 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	89 f8                	mov    %edi,%eax
  8020c7:	e8 ec fe ff ff       	call   801fb8 <_pipeisclosed>
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	75 32                	jne    802102 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020d0:	e8 0d ec ff ff       	call   800ce2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020d5:	8b 06                	mov    (%esi),%eax
  8020d7:	3b 46 04             	cmp    0x4(%esi),%eax
  8020da:	74 df                	je     8020bb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020dc:	99                   	cltd   
  8020dd:	c1 ea 1b             	shr    $0x1b,%edx
  8020e0:	01 d0                	add    %edx,%eax
  8020e2:	83 e0 1f             	and    $0x1f,%eax
  8020e5:	29 d0                	sub    %edx,%eax
  8020e7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ef:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020f2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f5:	83 c3 01             	add    $0x1,%ebx
  8020f8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020fb:	75 d8                	jne    8020d5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020fd:	8b 45 10             	mov    0x10(%ebp),%eax
  802100:	eb 05                	jmp    802107 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802102:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80210a:	5b                   	pop    %ebx
  80210b:	5e                   	pop    %esi
  80210c:	5f                   	pop    %edi
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    

0080210f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802117:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211a:	50                   	push   %eax
  80211b:	e8 9e f1 ff ff       	call   8012be <fd_alloc>
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	89 c2                	mov    %eax,%edx
  802125:	85 c0                	test   %eax,%eax
  802127:	0f 88 2c 01 00 00    	js     802259 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212d:	83 ec 04             	sub    $0x4,%esp
  802130:	68 07 04 00 00       	push   $0x407
  802135:	ff 75 f4             	pushl  -0xc(%ebp)
  802138:	6a 00                	push   $0x0
  80213a:	e8 c2 eb ff ff       	call   800d01 <sys_page_alloc>
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	89 c2                	mov    %eax,%edx
  802144:	85 c0                	test   %eax,%eax
  802146:	0f 88 0d 01 00 00    	js     802259 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80214c:	83 ec 0c             	sub    $0xc,%esp
  80214f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802152:	50                   	push   %eax
  802153:	e8 66 f1 ff ff       	call   8012be <fd_alloc>
  802158:	89 c3                	mov    %eax,%ebx
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	85 c0                	test   %eax,%eax
  80215f:	0f 88 e2 00 00 00    	js     802247 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802165:	83 ec 04             	sub    $0x4,%esp
  802168:	68 07 04 00 00       	push   $0x407
  80216d:	ff 75 f0             	pushl  -0x10(%ebp)
  802170:	6a 00                	push   $0x0
  802172:	e8 8a eb ff ff       	call   800d01 <sys_page_alloc>
  802177:	89 c3                	mov    %eax,%ebx
  802179:	83 c4 10             	add    $0x10,%esp
  80217c:	85 c0                	test   %eax,%eax
  80217e:	0f 88 c3 00 00 00    	js     802247 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802184:	83 ec 0c             	sub    $0xc,%esp
  802187:	ff 75 f4             	pushl  -0xc(%ebp)
  80218a:	e8 18 f1 ff ff       	call   8012a7 <fd2data>
  80218f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802191:	83 c4 0c             	add    $0xc,%esp
  802194:	68 07 04 00 00       	push   $0x407
  802199:	50                   	push   %eax
  80219a:	6a 00                	push   $0x0
  80219c:	e8 60 eb ff ff       	call   800d01 <sys_page_alloc>
  8021a1:	89 c3                	mov    %eax,%ebx
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	0f 88 89 00 00 00    	js     802237 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ae:	83 ec 0c             	sub    $0xc,%esp
  8021b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b4:	e8 ee f0 ff ff       	call   8012a7 <fd2data>
  8021b9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021c0:	50                   	push   %eax
  8021c1:	6a 00                	push   $0x0
  8021c3:	56                   	push   %esi
  8021c4:	6a 00                	push   $0x0
  8021c6:	e8 79 eb ff ff       	call   800d44 <sys_page_map>
  8021cb:	89 c3                	mov    %eax,%ebx
  8021cd:	83 c4 20             	add    $0x20,%esp
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 55                	js     802229 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021d4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021e9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8021ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021fe:	83 ec 0c             	sub    $0xc,%esp
  802201:	ff 75 f4             	pushl  -0xc(%ebp)
  802204:	e8 8e f0 ff ff       	call   801297 <fd2num>
  802209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80220c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80220e:	83 c4 04             	add    $0x4,%esp
  802211:	ff 75 f0             	pushl  -0x10(%ebp)
  802214:	e8 7e f0 ff ff       	call   801297 <fd2num>
  802219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80221c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	ba 00 00 00 00       	mov    $0x0,%edx
  802227:	eb 30                	jmp    802259 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	56                   	push   %esi
  80222d:	6a 00                	push   $0x0
  80222f:	e8 52 eb ff ff       	call   800d86 <sys_page_unmap>
  802234:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802237:	83 ec 08             	sub    $0x8,%esp
  80223a:	ff 75 f0             	pushl  -0x10(%ebp)
  80223d:	6a 00                	push   $0x0
  80223f:	e8 42 eb ff ff       	call   800d86 <sys_page_unmap>
  802244:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802247:	83 ec 08             	sub    $0x8,%esp
  80224a:	ff 75 f4             	pushl  -0xc(%ebp)
  80224d:	6a 00                	push   $0x0
  80224f:	e8 32 eb ff ff       	call   800d86 <sys_page_unmap>
  802254:	83 c4 10             	add    $0x10,%esp
  802257:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802259:	89 d0                	mov    %edx,%eax
  80225b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    

00802262 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226b:	50                   	push   %eax
  80226c:	ff 75 08             	pushl  0x8(%ebp)
  80226f:	e8 99 f0 ff ff       	call   80130d <fd_lookup>
  802274:	89 c2                	mov    %eax,%edx
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	85 d2                	test   %edx,%edx
  80227b:	78 18                	js     802295 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80227d:	83 ec 0c             	sub    $0xc,%esp
  802280:	ff 75 f4             	pushl  -0xc(%ebp)
  802283:	e8 1f f0 ff ff       	call   8012a7 <fd2data>
	return _pipeisclosed(fd, p);
  802288:	89 c2                	mov    %eax,%edx
  80228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228d:	e8 26 fd ff ff       	call   801fb8 <_pipeisclosed>
  802292:	83 c4 10             	add    $0x10,%esp
}
  802295:	c9                   	leave  
  802296:	c3                   	ret    

00802297 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80229a:	b8 00 00 00 00       	mov    $0x0,%eax
  80229f:	5d                   	pop    %ebp
  8022a0:	c3                   	ret    

008022a1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a7:	68 5e 2f 80 00       	push   $0x802f5e
  8022ac:	ff 75 0c             	pushl  0xc(%ebp)
  8022af:	e8 44 e6 ff ff       	call   8008f8 <strcpy>
	return 0;
}
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    

008022bb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	57                   	push   %edi
  8022bf:	56                   	push   %esi
  8022c0:	53                   	push   %ebx
  8022c1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022cc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d2:	eb 2d                	jmp    802301 <devcons_write+0x46>
		m = n - tot;
  8022d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022d9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022dc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022e1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022e4:	83 ec 04             	sub    $0x4,%esp
  8022e7:	53                   	push   %ebx
  8022e8:	03 45 0c             	add    0xc(%ebp),%eax
  8022eb:	50                   	push   %eax
  8022ec:	57                   	push   %edi
  8022ed:	e8 98 e7 ff ff       	call   800a8a <memmove>
		sys_cputs(buf, m);
  8022f2:	83 c4 08             	add    $0x8,%esp
  8022f5:	53                   	push   %ebx
  8022f6:	57                   	push   %edi
  8022f7:	e8 49 e9 ff ff       	call   800c45 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022fc:	01 de                	add    %ebx,%esi
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	89 f0                	mov    %esi,%eax
  802303:	3b 75 10             	cmp    0x10(%ebp),%esi
  802306:	72 cc                	jb     8022d4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802308:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230b:	5b                   	pop    %ebx
  80230c:	5e                   	pop    %esi
  80230d:	5f                   	pop    %edi
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    

00802310 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802316:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80231b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80231f:	75 07                	jne    802328 <devcons_read+0x18>
  802321:	eb 28                	jmp    80234b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802323:	e8 ba e9 ff ff       	call   800ce2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802328:	e8 36 e9 ff ff       	call   800c63 <sys_cgetc>
  80232d:	85 c0                	test   %eax,%eax
  80232f:	74 f2                	je     802323 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802331:	85 c0                	test   %eax,%eax
  802333:	78 16                	js     80234b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802335:	83 f8 04             	cmp    $0x4,%eax
  802338:	74 0c                	je     802346 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80233a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233d:	88 02                	mov    %al,(%edx)
	return 1;
  80233f:	b8 01 00 00 00       	mov    $0x1,%eax
  802344:	eb 05                	jmp    80234b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802346:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80234b:	c9                   	leave  
  80234c:	c3                   	ret    

0080234d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802353:	8b 45 08             	mov    0x8(%ebp),%eax
  802356:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802359:	6a 01                	push   $0x1
  80235b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80235e:	50                   	push   %eax
  80235f:	e8 e1 e8 ff ff       	call   800c45 <sys_cputs>
  802364:	83 c4 10             	add    $0x10,%esp
}
  802367:	c9                   	leave  
  802368:	c3                   	ret    

00802369 <getchar>:

int
getchar(void)
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80236f:	6a 01                	push   $0x1
  802371:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802374:	50                   	push   %eax
  802375:	6a 00                	push   $0x0
  802377:	e8 00 f2 ff ff       	call   80157c <read>
	if (r < 0)
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	85 c0                	test   %eax,%eax
  802381:	78 0f                	js     802392 <getchar+0x29>
		return r;
	if (r < 1)
  802383:	85 c0                	test   %eax,%eax
  802385:	7e 06                	jle    80238d <getchar+0x24>
		return -E_EOF;
	return c;
  802387:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80238b:	eb 05                	jmp    802392 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80238d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802392:	c9                   	leave  
  802393:	c3                   	ret    

00802394 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80239a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239d:	50                   	push   %eax
  80239e:	ff 75 08             	pushl  0x8(%ebp)
  8023a1:	e8 67 ef ff ff       	call   80130d <fd_lookup>
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 11                	js     8023be <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8023b6:	39 10                	cmp    %edx,(%eax)
  8023b8:	0f 94 c0             	sete   %al
  8023bb:	0f b6 c0             	movzbl %al,%eax
}
  8023be:	c9                   	leave  
  8023bf:	c3                   	ret    

008023c0 <opencons>:

int
opencons(void)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c9:	50                   	push   %eax
  8023ca:	e8 ef ee ff ff       	call   8012be <fd_alloc>
  8023cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8023d2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d4:	85 c0                	test   %eax,%eax
  8023d6:	78 3e                	js     802416 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d8:	83 ec 04             	sub    $0x4,%esp
  8023db:	68 07 04 00 00       	push   $0x407
  8023e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e3:	6a 00                	push   $0x0
  8023e5:	e8 17 e9 ff ff       	call   800d01 <sys_page_alloc>
  8023ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8023ed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 23                	js     802416 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023f3:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802401:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802408:	83 ec 0c             	sub    $0xc,%esp
  80240b:	50                   	push   %eax
  80240c:	e8 86 ee ff ff       	call   801297 <fd2num>
  802411:	89 c2                	mov    %eax,%edx
  802413:	83 c4 10             	add    $0x10,%esp
}
  802416:	89 d0                	mov    %edx,%eax
  802418:	c9                   	leave  
  802419:	c3                   	ret    

0080241a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80241a:	55                   	push   %ebp
  80241b:	89 e5                	mov    %esp,%ebp
  80241d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802420:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802427:	75 2c                	jne    802455 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802429:	83 ec 04             	sub    $0x4,%esp
  80242c:	6a 07                	push   $0x7
  80242e:	68 00 f0 bf ee       	push   $0xeebff000
  802433:	6a 00                	push   $0x0
  802435:	e8 c7 e8 ff ff       	call   800d01 <sys_page_alloc>
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	85 c0                	test   %eax,%eax
  80243f:	74 14                	je     802455 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802441:	83 ec 04             	sub    $0x4,%esp
  802444:	68 6c 2f 80 00       	push   $0x802f6c
  802449:	6a 21                	push   $0x21
  80244b:	68 d0 2f 80 00       	push   $0x802fd0
  802450:	e8 43 de ff ff       	call   800298 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802455:	8b 45 08             	mov    0x8(%ebp),%eax
  802458:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80245d:	83 ec 08             	sub    $0x8,%esp
  802460:	68 89 24 80 00       	push   $0x802489
  802465:	6a 00                	push   $0x0
  802467:	e8 e0 e9 ff ff       	call   800e4c <sys_env_set_pgfault_upcall>
  80246c:	83 c4 10             	add    $0x10,%esp
  80246f:	85 c0                	test   %eax,%eax
  802471:	79 14                	jns    802487 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802473:	83 ec 04             	sub    $0x4,%esp
  802476:	68 98 2f 80 00       	push   $0x802f98
  80247b:	6a 29                	push   $0x29
  80247d:	68 d0 2f 80 00       	push   $0x802fd0
  802482:	e8 11 de ff ff       	call   800298 <_panic>
}
  802487:	c9                   	leave  
  802488:	c3                   	ret    

00802489 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802489:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80248a:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80248f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802491:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802494:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802499:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80249d:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8024a1:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8024a3:	83 c4 08             	add    $0x8,%esp
        popal
  8024a6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8024a7:	83 c4 04             	add    $0x4,%esp
        popfl
  8024aa:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8024ab:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8024ac:	c3                   	ret    

008024ad <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	56                   	push   %esi
  8024b1:	53                   	push   %ebx
  8024b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8024bb:	85 c0                	test   %eax,%eax
  8024bd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024c2:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8024c5:	83 ec 0c             	sub    $0xc,%esp
  8024c8:	50                   	push   %eax
  8024c9:	e8 e3 e9 ff ff       	call   800eb1 <sys_ipc_recv>
  8024ce:	83 c4 10             	add    $0x10,%esp
  8024d1:	85 c0                	test   %eax,%eax
  8024d3:	79 16                	jns    8024eb <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8024d5:	85 f6                	test   %esi,%esi
  8024d7:	74 06                	je     8024df <ipc_recv+0x32>
  8024d9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8024df:	85 db                	test   %ebx,%ebx
  8024e1:	74 2c                	je     80250f <ipc_recv+0x62>
  8024e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024e9:	eb 24                	jmp    80250f <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8024eb:	85 f6                	test   %esi,%esi
  8024ed:	74 0a                	je     8024f9 <ipc_recv+0x4c>
  8024ef:	a1 08 50 80 00       	mov    0x805008,%eax
  8024f4:	8b 40 74             	mov    0x74(%eax),%eax
  8024f7:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8024f9:	85 db                	test   %ebx,%ebx
  8024fb:	74 0a                	je     802507 <ipc_recv+0x5a>
  8024fd:	a1 08 50 80 00       	mov    0x805008,%eax
  802502:	8b 40 78             	mov    0x78(%eax),%eax
  802505:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802507:	a1 08 50 80 00       	mov    0x805008,%eax
  80250c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80250f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802512:	5b                   	pop    %ebx
  802513:	5e                   	pop    %esi
  802514:	5d                   	pop    %ebp
  802515:	c3                   	ret    

00802516 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802516:	55                   	push   %ebp
  802517:	89 e5                	mov    %esp,%ebp
  802519:	57                   	push   %edi
  80251a:	56                   	push   %esi
  80251b:	53                   	push   %ebx
  80251c:	83 ec 0c             	sub    $0xc,%esp
  80251f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802522:	8b 75 0c             	mov    0xc(%ebp),%esi
  802525:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802528:	85 db                	test   %ebx,%ebx
  80252a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80252f:	0f 44 d8             	cmove  %eax,%ebx
  802532:	eb 1c                	jmp    802550 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802534:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802537:	74 12                	je     80254b <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802539:	50                   	push   %eax
  80253a:	68 de 2f 80 00       	push   $0x802fde
  80253f:	6a 39                	push   $0x39
  802541:	68 f9 2f 80 00       	push   $0x802ff9
  802546:	e8 4d dd ff ff       	call   800298 <_panic>
                 sys_yield();
  80254b:	e8 92 e7 ff ff       	call   800ce2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802550:	ff 75 14             	pushl  0x14(%ebp)
  802553:	53                   	push   %ebx
  802554:	56                   	push   %esi
  802555:	57                   	push   %edi
  802556:	e8 33 e9 ff ff       	call   800e8e <sys_ipc_try_send>
  80255b:	83 c4 10             	add    $0x10,%esp
  80255e:	85 c0                	test   %eax,%eax
  802560:	78 d2                	js     802534 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802562:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802565:	5b                   	pop    %ebx
  802566:	5e                   	pop    %esi
  802567:	5f                   	pop    %edi
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    

0080256a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802570:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802575:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802578:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80257e:	8b 52 50             	mov    0x50(%edx),%edx
  802581:	39 ca                	cmp    %ecx,%edx
  802583:	75 0d                	jne    802592 <ipc_find_env+0x28>
			return envs[i].env_id;
  802585:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802588:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80258d:	8b 40 08             	mov    0x8(%eax),%eax
  802590:	eb 0e                	jmp    8025a0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802592:	83 c0 01             	add    $0x1,%eax
  802595:	3d 00 04 00 00       	cmp    $0x400,%eax
  80259a:	75 d9                	jne    802575 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80259c:	66 b8 00 00          	mov    $0x0,%ax
}
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    

008025a2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025a2:	55                   	push   %ebp
  8025a3:	89 e5                	mov    %esp,%ebp
  8025a5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025a8:	89 d0                	mov    %edx,%eax
  8025aa:	c1 e8 16             	shr    $0x16,%eax
  8025ad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025b4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b9:	f6 c1 01             	test   $0x1,%cl
  8025bc:	74 1d                	je     8025db <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025be:	c1 ea 0c             	shr    $0xc,%edx
  8025c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025c8:	f6 c2 01             	test   $0x1,%dl
  8025cb:	74 0e                	je     8025db <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025cd:	c1 ea 0c             	shr    $0xc,%edx
  8025d0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025d7:	ef 
  8025d8:	0f b7 c0             	movzwl %ax,%eax
}
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    
  8025dd:	66 90                	xchg   %ax,%ax
  8025df:	90                   	nop

008025e0 <__udivdi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	83 ec 10             	sub    $0x10,%esp
  8025e6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8025ea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8025ee:	8b 74 24 24          	mov    0x24(%esp),%esi
  8025f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8025f6:	85 d2                	test   %edx,%edx
  8025f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025fc:	89 34 24             	mov    %esi,(%esp)
  8025ff:	89 c8                	mov    %ecx,%eax
  802601:	75 35                	jne    802638 <__udivdi3+0x58>
  802603:	39 f1                	cmp    %esi,%ecx
  802605:	0f 87 bd 00 00 00    	ja     8026c8 <__udivdi3+0xe8>
  80260b:	85 c9                	test   %ecx,%ecx
  80260d:	89 cd                	mov    %ecx,%ebp
  80260f:	75 0b                	jne    80261c <__udivdi3+0x3c>
  802611:	b8 01 00 00 00       	mov    $0x1,%eax
  802616:	31 d2                	xor    %edx,%edx
  802618:	f7 f1                	div    %ecx
  80261a:	89 c5                	mov    %eax,%ebp
  80261c:	89 f0                	mov    %esi,%eax
  80261e:	31 d2                	xor    %edx,%edx
  802620:	f7 f5                	div    %ebp
  802622:	89 c6                	mov    %eax,%esi
  802624:	89 f8                	mov    %edi,%eax
  802626:	f7 f5                	div    %ebp
  802628:	89 f2                	mov    %esi,%edx
  80262a:	83 c4 10             	add    $0x10,%esp
  80262d:	5e                   	pop    %esi
  80262e:	5f                   	pop    %edi
  80262f:	5d                   	pop    %ebp
  802630:	c3                   	ret    
  802631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802638:	3b 14 24             	cmp    (%esp),%edx
  80263b:	77 7b                	ja     8026b8 <__udivdi3+0xd8>
  80263d:	0f bd f2             	bsr    %edx,%esi
  802640:	83 f6 1f             	xor    $0x1f,%esi
  802643:	0f 84 97 00 00 00    	je     8026e0 <__udivdi3+0x100>
  802649:	bd 20 00 00 00       	mov    $0x20,%ebp
  80264e:	89 d7                	mov    %edx,%edi
  802650:	89 f1                	mov    %esi,%ecx
  802652:	29 f5                	sub    %esi,%ebp
  802654:	d3 e7                	shl    %cl,%edi
  802656:	89 c2                	mov    %eax,%edx
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	d3 ea                	shr    %cl,%edx
  80265c:	89 f1                	mov    %esi,%ecx
  80265e:	09 fa                	or     %edi,%edx
  802660:	8b 3c 24             	mov    (%esp),%edi
  802663:	d3 e0                	shl    %cl,%eax
  802665:	89 54 24 08          	mov    %edx,0x8(%esp)
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80266f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802673:	89 fa                	mov    %edi,%edx
  802675:	d3 ea                	shr    %cl,%edx
  802677:	89 f1                	mov    %esi,%ecx
  802679:	d3 e7                	shl    %cl,%edi
  80267b:	89 e9                	mov    %ebp,%ecx
  80267d:	d3 e8                	shr    %cl,%eax
  80267f:	09 c7                	or     %eax,%edi
  802681:	89 f8                	mov    %edi,%eax
  802683:	f7 74 24 08          	divl   0x8(%esp)
  802687:	89 d5                	mov    %edx,%ebp
  802689:	89 c7                	mov    %eax,%edi
  80268b:	f7 64 24 0c          	mull   0xc(%esp)
  80268f:	39 d5                	cmp    %edx,%ebp
  802691:	89 14 24             	mov    %edx,(%esp)
  802694:	72 11                	jb     8026a7 <__udivdi3+0xc7>
  802696:	8b 54 24 04          	mov    0x4(%esp),%edx
  80269a:	89 f1                	mov    %esi,%ecx
  80269c:	d3 e2                	shl    %cl,%edx
  80269e:	39 c2                	cmp    %eax,%edx
  8026a0:	73 5e                	jae    802700 <__udivdi3+0x120>
  8026a2:	3b 2c 24             	cmp    (%esp),%ebp
  8026a5:	75 59                	jne    802700 <__udivdi3+0x120>
  8026a7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8026aa:	31 f6                	xor    %esi,%esi
  8026ac:	89 f2                	mov    %esi,%edx
  8026ae:	83 c4 10             	add    $0x10,%esp
  8026b1:	5e                   	pop    %esi
  8026b2:	5f                   	pop    %edi
  8026b3:	5d                   	pop    %ebp
  8026b4:	c3                   	ret    
  8026b5:	8d 76 00             	lea    0x0(%esi),%esi
  8026b8:	31 f6                	xor    %esi,%esi
  8026ba:	31 c0                	xor    %eax,%eax
  8026bc:	89 f2                	mov    %esi,%edx
  8026be:	83 c4 10             	add    $0x10,%esp
  8026c1:	5e                   	pop    %esi
  8026c2:	5f                   	pop    %edi
  8026c3:	5d                   	pop    %ebp
  8026c4:	c3                   	ret    
  8026c5:	8d 76 00             	lea    0x0(%esi),%esi
  8026c8:	89 f2                	mov    %esi,%edx
  8026ca:	31 f6                	xor    %esi,%esi
  8026cc:	89 f8                	mov    %edi,%eax
  8026ce:	f7 f1                	div    %ecx
  8026d0:	89 f2                	mov    %esi,%edx
  8026d2:	83 c4 10             	add    $0x10,%esp
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8026e4:	76 0b                	jbe    8026f1 <__udivdi3+0x111>
  8026e6:	31 c0                	xor    %eax,%eax
  8026e8:	3b 14 24             	cmp    (%esp),%edx
  8026eb:	0f 83 37 ff ff ff    	jae    802628 <__udivdi3+0x48>
  8026f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f6:	e9 2d ff ff ff       	jmp    802628 <__udivdi3+0x48>
  8026fb:	90                   	nop
  8026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802700:	89 f8                	mov    %edi,%eax
  802702:	31 f6                	xor    %esi,%esi
  802704:	e9 1f ff ff ff       	jmp    802628 <__udivdi3+0x48>
  802709:	66 90                	xchg   %ax,%ax
  80270b:	66 90                	xchg   %ax,%ax
  80270d:	66 90                	xchg   %ax,%ax
  80270f:	90                   	nop

00802710 <__umoddi3>:
  802710:	55                   	push   %ebp
  802711:	57                   	push   %edi
  802712:	56                   	push   %esi
  802713:	83 ec 20             	sub    $0x20,%esp
  802716:	8b 44 24 34          	mov    0x34(%esp),%eax
  80271a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80271e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802722:	89 c6                	mov    %eax,%esi
  802724:	89 44 24 10          	mov    %eax,0x10(%esp)
  802728:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80272c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802730:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802734:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802738:	89 74 24 18          	mov    %esi,0x18(%esp)
  80273c:	85 c0                	test   %eax,%eax
  80273e:	89 c2                	mov    %eax,%edx
  802740:	75 1e                	jne    802760 <__umoddi3+0x50>
  802742:	39 f7                	cmp    %esi,%edi
  802744:	76 52                	jbe    802798 <__umoddi3+0x88>
  802746:	89 c8                	mov    %ecx,%eax
  802748:	89 f2                	mov    %esi,%edx
  80274a:	f7 f7                	div    %edi
  80274c:	89 d0                	mov    %edx,%eax
  80274e:	31 d2                	xor    %edx,%edx
  802750:	83 c4 20             	add    $0x20,%esp
  802753:	5e                   	pop    %esi
  802754:	5f                   	pop    %edi
  802755:	5d                   	pop    %ebp
  802756:	c3                   	ret    
  802757:	89 f6                	mov    %esi,%esi
  802759:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802760:	39 f0                	cmp    %esi,%eax
  802762:	77 5c                	ja     8027c0 <__umoddi3+0xb0>
  802764:	0f bd e8             	bsr    %eax,%ebp
  802767:	83 f5 1f             	xor    $0x1f,%ebp
  80276a:	75 64                	jne    8027d0 <__umoddi3+0xc0>
  80276c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802770:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802774:	0f 86 f6 00 00 00    	jbe    802870 <__umoddi3+0x160>
  80277a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80277e:	0f 82 ec 00 00 00    	jb     802870 <__umoddi3+0x160>
  802784:	8b 44 24 14          	mov    0x14(%esp),%eax
  802788:	8b 54 24 18          	mov    0x18(%esp),%edx
  80278c:	83 c4 20             	add    $0x20,%esp
  80278f:	5e                   	pop    %esi
  802790:	5f                   	pop    %edi
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    
  802793:	90                   	nop
  802794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802798:	85 ff                	test   %edi,%edi
  80279a:	89 fd                	mov    %edi,%ebp
  80279c:	75 0b                	jne    8027a9 <__umoddi3+0x99>
  80279e:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a3:	31 d2                	xor    %edx,%edx
  8027a5:	f7 f7                	div    %edi
  8027a7:	89 c5                	mov    %eax,%ebp
  8027a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8027ad:	31 d2                	xor    %edx,%edx
  8027af:	f7 f5                	div    %ebp
  8027b1:	89 c8                	mov    %ecx,%eax
  8027b3:	f7 f5                	div    %ebp
  8027b5:	eb 95                	jmp    80274c <__umoddi3+0x3c>
  8027b7:	89 f6                	mov    %esi,%esi
  8027b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 f2                	mov    %esi,%edx
  8027c4:	83 c4 20             	add    $0x20,%esp
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
  8027cb:	90                   	nop
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	b8 20 00 00 00       	mov    $0x20,%eax
  8027d5:	89 e9                	mov    %ebp,%ecx
  8027d7:	29 e8                	sub    %ebp,%eax
  8027d9:	d3 e2                	shl    %cl,%edx
  8027db:	89 c7                	mov    %eax,%edi
  8027dd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8027e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027e5:	89 f9                	mov    %edi,%ecx
  8027e7:	d3 e8                	shr    %cl,%eax
  8027e9:	89 c1                	mov    %eax,%ecx
  8027eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027ef:	09 d1                	or     %edx,%ecx
  8027f1:	89 fa                	mov    %edi,%edx
  8027f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8027f7:	89 e9                	mov    %ebp,%ecx
  8027f9:	d3 e0                	shl    %cl,%eax
  8027fb:	89 f9                	mov    %edi,%ecx
  8027fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802801:	89 f0                	mov    %esi,%eax
  802803:	d3 e8                	shr    %cl,%eax
  802805:	89 e9                	mov    %ebp,%ecx
  802807:	89 c7                	mov    %eax,%edi
  802809:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80280d:	d3 e6                	shl    %cl,%esi
  80280f:	89 d1                	mov    %edx,%ecx
  802811:	89 fa                	mov    %edi,%edx
  802813:	d3 e8                	shr    %cl,%eax
  802815:	89 e9                	mov    %ebp,%ecx
  802817:	09 f0                	or     %esi,%eax
  802819:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80281d:	f7 74 24 10          	divl   0x10(%esp)
  802821:	d3 e6                	shl    %cl,%esi
  802823:	89 d1                	mov    %edx,%ecx
  802825:	f7 64 24 0c          	mull   0xc(%esp)
  802829:	39 d1                	cmp    %edx,%ecx
  80282b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80282f:	89 d7                	mov    %edx,%edi
  802831:	89 c6                	mov    %eax,%esi
  802833:	72 0a                	jb     80283f <__umoddi3+0x12f>
  802835:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802839:	73 10                	jae    80284b <__umoddi3+0x13b>
  80283b:	39 d1                	cmp    %edx,%ecx
  80283d:	75 0c                	jne    80284b <__umoddi3+0x13b>
  80283f:	89 d7                	mov    %edx,%edi
  802841:	89 c6                	mov    %eax,%esi
  802843:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802847:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80284b:	89 ca                	mov    %ecx,%edx
  80284d:	89 e9                	mov    %ebp,%ecx
  80284f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802853:	29 f0                	sub    %esi,%eax
  802855:	19 fa                	sbb    %edi,%edx
  802857:	d3 e8                	shr    %cl,%eax
  802859:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80285e:	89 d7                	mov    %edx,%edi
  802860:	d3 e7                	shl    %cl,%edi
  802862:	89 e9                	mov    %ebp,%ecx
  802864:	09 f8                	or     %edi,%eax
  802866:	d3 ea                	shr    %cl,%edx
  802868:	83 c4 20             	add    $0x20,%esp
  80286b:	5e                   	pop    %esi
  80286c:	5f                   	pop    %edi
  80286d:	5d                   	pop    %ebp
  80286e:	c3                   	ret    
  80286f:	90                   	nop
  802870:	8b 74 24 10          	mov    0x10(%esp),%esi
  802874:	29 f9                	sub    %edi,%ecx
  802876:	19 c6                	sbb    %eax,%esi
  802878:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80287c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802880:	e9 ff fe ff ff       	jmp    802784 <__umoddi3+0x74>
