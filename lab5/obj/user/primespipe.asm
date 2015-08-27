
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
  80004c:	e8 16 15 00 00       	call   801567 <readn>
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
  800068:	68 80 23 80 00       	push   $0x802380
  80006d:	6a 15                	push   $0x15
  80006f:	68 af 23 80 00       	push   $0x8023af
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 d7 28 80 00       	push   $0x8028d7
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 67 1b 00 00       	call   801bf8 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 c1 23 80 00       	push   $0x8023c1
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 af 23 80 00       	push   $0x8023af
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 22 0f 00 00       	call   800fd4 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 9b 28 80 00       	push   $0x80289b
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 af 23 80 00       	push   $0x8023af
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 c1 12 00 00       	call   801396 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 b6 12 00 00       	call   801396 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 a0 12 00 00       	call   801396 <close>
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
  800106:	e8 5c 14 00 00       	call   801567 <readn>
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
  800126:	68 ca 23 80 00       	push   $0x8023ca
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 af 23 80 00       	push   $0x8023af
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
  800149:	e8 5e 14 00 00       	call   8015ac <write>
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
  800168:	68 e6 23 80 00       	push   $0x8023e6
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 af 23 80 00       	push   $0x8023af
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
  800180:	c7 05 00 30 80 00 00 	movl   $0x802400,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 65 1a 00 00       	call   801bf8 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 c1 23 80 00       	push   $0x8023c1
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 af 23 80 00       	push   $0x8023af
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 20 0e 00 00       	call   800fd4 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 9b 28 80 00       	push   $0x80289b
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 af 23 80 00       	push   $0x8023af
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 bd 11 00 00       	call   801396 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 a7 11 00 00       	call   801396 <close>

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
  800205:	e8 a2 13 00 00       	call   8015ac <write>
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
  800221:	68 0b 24 80 00       	push   $0x80240b
  800226:	6a 4a                	push   $0x4a
  800228:	68 af 23 80 00       	push   $0x8023af
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
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800284:	e8 3a 11 00 00       	call   8013c3 <close_all>
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
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 18 0a 00 00       	call   800cc3 <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 30 24 80 00       	push   $0x802430
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 d9 28 80 00 	movl   $0x8028d9,(%esp)
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
  8003d4:	e8 f7 1c 00 00       	call   8020d0 <__udivdi3>
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
  800412:	e8 e9 1d 00 00       	call   802200 <__umoddi3>
  800417:	83 c4 14             	add    $0x14,%esp
  80041a:	0f be 80 53 24 80 00 	movsbl 0x802453(%eax),%eax
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
  800516:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
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
  8005da:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8005e1:	85 d2                	test   %edx,%edx
  8005e3:	75 18                	jne    8005fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005e5:	50                   	push   %eax
  8005e6:	68 6b 24 80 00       	push   $0x80246b
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
  8005fe:	68 ad 29 80 00       	push   $0x8029ad
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
  80062b:	ba 64 24 80 00       	mov    $0x802464,%edx
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
  800caa:	68 9f 27 80 00       	push   $0x80279f
  800caf:	6a 23                	push   $0x23
  800cb1:	68 bc 27 80 00       	push   $0x8027bc
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
  800d2b:	68 9f 27 80 00       	push   $0x80279f
  800d30:	6a 23                	push   $0x23
  800d32:	68 bc 27 80 00       	push   $0x8027bc
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
  800d6d:	68 9f 27 80 00       	push   $0x80279f
  800d72:	6a 23                	push   $0x23
  800d74:	68 bc 27 80 00       	push   $0x8027bc
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
  800daf:	68 9f 27 80 00       	push   $0x80279f
  800db4:	6a 23                	push   $0x23
  800db6:	68 bc 27 80 00       	push   $0x8027bc
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
  800df1:	68 9f 27 80 00       	push   $0x80279f
  800df6:	6a 23                	push   $0x23
  800df8:	68 bc 27 80 00       	push   $0x8027bc
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
  800e33:	68 9f 27 80 00       	push   $0x80279f
  800e38:	6a 23                	push   $0x23
  800e3a:	68 bc 27 80 00       	push   $0x8027bc
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
  800e75:	68 9f 27 80 00       	push   $0x80279f
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 bc 27 80 00       	push   $0x8027bc
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
  800ed9:	68 9f 27 80 00       	push   $0x80279f
  800ede:	6a 23                	push   $0x23
  800ee0:	68 bc 27 80 00       	push   $0x8027bc
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

00800ef2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800efc:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800efe:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f02:	74 2e                	je     800f32 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f04:	89 c2                	mov    %eax,%edx
  800f06:	c1 ea 16             	shr    $0x16,%edx
  800f09:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f10:	f6 c2 01             	test   $0x1,%dl
  800f13:	74 1d                	je     800f32 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f15:	89 c2                	mov    %eax,%edx
  800f17:	c1 ea 0c             	shr    $0xc,%edx
  800f1a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800f21:	f6 c1 01             	test   $0x1,%cl
  800f24:	74 0c                	je     800f32 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800f2d:	f6 c6 08             	test   $0x8,%dh
  800f30:	75 14                	jne    800f46 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	68 cc 27 80 00       	push   $0x8027cc
  800f3a:	6a 21                	push   $0x21
  800f3c:	68 5f 28 80 00       	push   $0x80285f
  800f41:	e8 52 f3 ff ff       	call   800298 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800f46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f4b:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800f4d:	83 ec 04             	sub    $0x4,%esp
  800f50:	6a 07                	push   $0x7
  800f52:	68 00 f0 7f 00       	push   $0x7ff000
  800f57:	6a 00                	push   $0x0
  800f59:	e8 a3 fd ff ff       	call   800d01 <sys_page_alloc>
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 14                	jns    800f79 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	68 6a 28 80 00       	push   $0x80286a
  800f6d:	6a 2b                	push   $0x2b
  800f6f:	68 5f 28 80 00       	push   $0x80285f
  800f74:	e8 1f f3 ff ff       	call   800298 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	68 00 10 00 00       	push   $0x1000
  800f81:	53                   	push   %ebx
  800f82:	68 00 f0 7f 00       	push   $0x7ff000
  800f87:	e8 fe fa ff ff       	call   800a8a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800f8c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f93:	53                   	push   %ebx
  800f94:	6a 00                	push   $0x0
  800f96:	68 00 f0 7f 00       	push   $0x7ff000
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 a2 fd ff ff       	call   800d44 <sys_page_map>
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 14                	jns    800fbd <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	68 80 28 80 00       	push   $0x802880
  800fb1:	6a 2e                	push   $0x2e
  800fb3:	68 5f 28 80 00       	push   $0x80285f
  800fb8:	e8 db f2 ff ff       	call   800298 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	68 00 f0 7f 00       	push   $0x7ff000
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 ba fd ff ff       	call   800d86 <sys_page_unmap>
  800fcc:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800fdd:	68 f2 0e 80 00       	push   $0x800ef2
  800fe2:	e8 1c 0f 00 00       	call   801f03 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fe7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fec:	cd 30                	int    $0x30
  800fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	79 12                	jns    80100a <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800ff8:	50                   	push   %eax
  800ff9:	68 94 28 80 00       	push   $0x802894
  800ffe:	6a 6d                	push   $0x6d
  801000:	68 5f 28 80 00       	push   $0x80285f
  801005:	e8 8e f2 ff ff       	call   800298 <_panic>
  80100a:	89 c7                	mov    %eax,%edi
  80100c:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  801011:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801015:	75 21                	jne    801038 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801017:	e8 a7 fc ff ff       	call   800cc3 <sys_getenvid>
  80101c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801021:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801029:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80102e:	b8 00 00 00 00       	mov    $0x0,%eax
  801033:	e9 9c 01 00 00       	jmp    8011d4 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	c1 e8 16             	shr    $0x16,%eax
  80103d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801044:	a8 01                	test   $0x1,%al
  801046:	0f 84 f3 00 00 00    	je     80113f <fork+0x16b>
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	0f 84 de 00 00 00    	je     80113f <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  801061:	89 c6                	mov    %eax,%esi
  801063:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801066:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106d:	f6 c6 04             	test   $0x4,%dh
  801070:	74 37                	je     8010a9 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801072:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	25 07 0e 00 00       	and    $0xe07,%eax
  801081:	50                   	push   %eax
  801082:	56                   	push   %esi
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	6a 00                	push   $0x0
  801087:	e8 b8 fc ff ff       	call   800d44 <sys_page_map>
  80108c:	83 c4 20             	add    $0x20,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	0f 89 a8 00 00 00    	jns    80113f <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  801097:	50                   	push   %eax
  801098:	68 f0 27 80 00       	push   $0x8027f0
  80109d:	6a 49                	push   $0x49
  80109f:	68 5f 28 80 00       	push   $0x80285f
  8010a4:	e8 ef f1 ff ff       	call   800298 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8010a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b0:	f6 c6 08             	test   $0x8,%dh
  8010b3:	75 0b                	jne    8010c0 <fork+0xec>
  8010b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bc:	a8 02                	test   $0x2,%al
  8010be:	74 57                	je     801117 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	68 05 08 00 00       	push   $0x805
  8010c8:	56                   	push   %esi
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 72 fc ff ff       	call   800d44 <sys_page_map>
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 12                	jns    8010eb <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  8010d9:	50                   	push   %eax
  8010da:	68 f0 27 80 00       	push   $0x8027f0
  8010df:	6a 4c                	push   $0x4c
  8010e1:	68 5f 28 80 00       	push   $0x80285f
  8010e6:	e8 ad f1 ff ff       	call   800298 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	68 05 08 00 00       	push   $0x805
  8010f3:	56                   	push   %esi
  8010f4:	6a 00                	push   $0x0
  8010f6:	56                   	push   %esi
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 46 fc ff ff       	call   800d44 <sys_page_map>
  8010fe:	83 c4 20             	add    $0x20,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	79 3a                	jns    80113f <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  801105:	50                   	push   %eax
  801106:	68 14 28 80 00       	push   $0x802814
  80110b:	6a 4e                	push   $0x4e
  80110d:	68 5f 28 80 00       	push   $0x80285f
  801112:	e8 81 f1 ff ff       	call   800298 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	6a 05                	push   $0x5
  80111c:	56                   	push   %esi
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	6a 00                	push   $0x0
  801121:	e8 1e fc ff ff       	call   800d44 <sys_page_map>
  801126:	83 c4 20             	add    $0x20,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	79 12                	jns    80113f <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  80112d:	50                   	push   %eax
  80112e:	68 3c 28 80 00       	push   $0x80283c
  801133:	6a 50                	push   $0x50
  801135:	68 5f 28 80 00       	push   $0x80285f
  80113a:	e8 59 f1 ff ff       	call   800298 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80113f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801145:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80114b:	0f 85 e7 fe ff ff    	jne    801038 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	6a 07                	push   $0x7
  801156:	68 00 f0 bf ee       	push   $0xeebff000
  80115b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115e:	e8 9e fb ff ff       	call   800d01 <sys_page_alloc>
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	79 14                	jns    80117e <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	68 a4 28 80 00       	push   $0x8028a4
  801172:	6a 76                	push   $0x76
  801174:	68 5f 28 80 00       	push   $0x80285f
  801179:	e8 1a f1 ff ff       	call   800298 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	68 72 1f 80 00       	push   $0x801f72
  801186:	ff 75 e4             	pushl  -0x1c(%ebp)
  801189:	e8 be fc ff ff       	call   800e4c <sys_env_set_pgfault_upcall>
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	79 14                	jns    8011a9 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801195:	ff 75 e4             	pushl  -0x1c(%ebp)
  801198:	68 be 28 80 00       	push   $0x8028be
  80119d:	6a 79                	push   $0x79
  80119f:	68 5f 28 80 00       	push   $0x80285f
  8011a4:	e8 ef f0 ff ff       	call   800298 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	6a 02                	push   $0x2
  8011ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b1:	e8 12 fc ff ff       	call   800dc8 <sys_env_set_status>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	79 14                	jns    8011d1 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	68 db 28 80 00       	push   $0x8028db
  8011c5:	6a 7b                	push   $0x7b
  8011c7:	68 5f 28 80 00       	push   $0x80285f
  8011cc:	e8 c7 f0 ff ff       	call   800298 <_panic>
        return forkid;
  8011d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <sfork>:

// Challenge!
int
sfork(void)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011e2:	68 f2 28 80 00       	push   $0x8028f2
  8011e7:	68 83 00 00 00       	push   $0x83
  8011ec:	68 5f 28 80 00       	push   $0x80285f
  8011f1:	e8 a2 f0 ff ff       	call   800298 <_panic>

008011f6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	05 00 00 00 30       	add    $0x30000000,%eax
  801201:	c1 e8 0c             	shr    $0xc,%eax
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801211:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801216:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801223:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801228:	89 c2                	mov    %eax,%edx
  80122a:	c1 ea 16             	shr    $0x16,%edx
  80122d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801234:	f6 c2 01             	test   $0x1,%dl
  801237:	74 11                	je     80124a <fd_alloc+0x2d>
  801239:	89 c2                	mov    %eax,%edx
  80123b:	c1 ea 0c             	shr    $0xc,%edx
  80123e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801245:	f6 c2 01             	test   $0x1,%dl
  801248:	75 09                	jne    801253 <fd_alloc+0x36>
			*fd_store = fd;
  80124a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
  801251:	eb 17                	jmp    80126a <fd_alloc+0x4d>
  801253:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801258:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125d:	75 c9                	jne    801228 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80125f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801265:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801272:	83 f8 1f             	cmp    $0x1f,%eax
  801275:	77 36                	ja     8012ad <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801277:	c1 e0 0c             	shl    $0xc,%eax
  80127a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80127f:	89 c2                	mov    %eax,%edx
  801281:	c1 ea 16             	shr    $0x16,%edx
  801284:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128b:	f6 c2 01             	test   $0x1,%dl
  80128e:	74 24                	je     8012b4 <fd_lookup+0x48>
  801290:	89 c2                	mov    %eax,%edx
  801292:	c1 ea 0c             	shr    $0xc,%edx
  801295:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129c:	f6 c2 01             	test   $0x1,%dl
  80129f:	74 1a                	je     8012bb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a4:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ab:	eb 13                	jmp    8012c0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b2:	eb 0c                	jmp    8012c0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b9:	eb 05                	jmp    8012c0 <fd_lookup+0x54>
  8012bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cb:	ba 84 29 80 00       	mov    $0x802984,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d0:	eb 13                	jmp    8012e5 <dev_lookup+0x23>
  8012d2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012d5:	39 08                	cmp    %ecx,(%eax)
  8012d7:	75 0c                	jne    8012e5 <dev_lookup+0x23>
			*dev = devtab[i];
  8012d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e3:	eb 2e                	jmp    801313 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e5:	8b 02                	mov    (%edx),%eax
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	75 e7                	jne    8012d2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f0:	8b 40 48             	mov    0x48(%eax),%eax
  8012f3:	83 ec 04             	sub    $0x4,%esp
  8012f6:	51                   	push   %ecx
  8012f7:	50                   	push   %eax
  8012f8:	68 08 29 80 00       	push   $0x802908
  8012fd:	e8 6f f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801302:	8b 45 0c             	mov    0xc(%ebp),%eax
  801305:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	56                   	push   %esi
  801319:	53                   	push   %ebx
  80131a:	83 ec 10             	sub    $0x10,%esp
  80131d:	8b 75 08             	mov    0x8(%ebp),%esi
  801320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801327:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80132d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801330:	50                   	push   %eax
  801331:	e8 36 ff ff ff       	call   80126c <fd_lookup>
  801336:	83 c4 08             	add    $0x8,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 05                	js     801342 <fd_close+0x2d>
	    || fd != fd2)
  80133d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801340:	74 0c                	je     80134e <fd_close+0x39>
		return (must_exist ? r : 0);
  801342:	84 db                	test   %bl,%bl
  801344:	ba 00 00 00 00       	mov    $0x0,%edx
  801349:	0f 44 c2             	cmove  %edx,%eax
  80134c:	eb 41                	jmp    80138f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 36                	pushl  (%esi)
  801357:	e8 66 ff ff ff       	call   8012c2 <dev_lookup>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 1a                	js     80137f <fd_close+0x6a>
		if (dev->dev_close)
  801365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801368:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80136b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801370:	85 c0                	test   %eax,%eax
  801372:	74 0b                	je     80137f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	56                   	push   %esi
  801378:	ff d0                	call   *%eax
  80137a:	89 c3                	mov    %eax,%ebx
  80137c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	56                   	push   %esi
  801383:	6a 00                	push   $0x0
  801385:	e8 fc f9 ff ff       	call   800d86 <sys_page_unmap>
	return r;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	89 d8                	mov    %ebx,%eax
}
  80138f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801392:	5b                   	pop    %ebx
  801393:	5e                   	pop    %esi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80139c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	ff 75 08             	pushl  0x8(%ebp)
  8013a3:	e8 c4 fe ff ff       	call   80126c <fd_lookup>
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	85 d2                	test   %edx,%edx
  8013af:	78 10                	js     8013c1 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	6a 01                	push   $0x1
  8013b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b9:	e8 57 ff ff ff       	call   801315 <fd_close>
  8013be:	83 c4 10             	add    $0x10,%esp
}
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <close_all>:

void
close_all(void)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	53                   	push   %ebx
  8013d3:	e8 be ff ff ff       	call   801396 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d8:	83 c3 01             	add    $0x1,%ebx
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	83 fb 20             	cmp    $0x20,%ebx
  8013e1:	75 ec                	jne    8013cf <close_all+0xc>
		close(i);
}
  8013e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	57                   	push   %edi
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 2c             	sub    $0x2c,%esp
  8013f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	ff 75 08             	pushl  0x8(%ebp)
  8013fb:	e8 6c fe ff ff       	call   80126c <fd_lookup>
  801400:	89 c2                	mov    %eax,%edx
  801402:	83 c4 08             	add    $0x8,%esp
  801405:	85 d2                	test   %edx,%edx
  801407:	0f 88 c1 00 00 00    	js     8014ce <dup+0xe6>
		return r;
	close(newfdnum);
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	56                   	push   %esi
  801411:	e8 80 ff ff ff       	call   801396 <close>

	newfd = INDEX2FD(newfdnum);
  801416:	89 f3                	mov    %esi,%ebx
  801418:	c1 e3 0c             	shl    $0xc,%ebx
  80141b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801421:	83 c4 04             	add    $0x4,%esp
  801424:	ff 75 e4             	pushl  -0x1c(%ebp)
  801427:	e8 da fd ff ff       	call   801206 <fd2data>
  80142c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80142e:	89 1c 24             	mov    %ebx,(%esp)
  801431:	e8 d0 fd ff ff       	call   801206 <fd2data>
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143c:	89 f8                	mov    %edi,%eax
  80143e:	c1 e8 16             	shr    $0x16,%eax
  801441:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801448:	a8 01                	test   $0x1,%al
  80144a:	74 37                	je     801483 <dup+0x9b>
  80144c:	89 f8                	mov    %edi,%eax
  80144e:	c1 e8 0c             	shr    $0xc,%eax
  801451:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801458:	f6 c2 01             	test   $0x1,%dl
  80145b:	74 26                	je     801483 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80145d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	25 07 0e 00 00       	and    $0xe07,%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801470:	6a 00                	push   $0x0
  801472:	57                   	push   %edi
  801473:	6a 00                	push   $0x0
  801475:	e8 ca f8 ff ff       	call   800d44 <sys_page_map>
  80147a:	89 c7                	mov    %eax,%edi
  80147c:	83 c4 20             	add    $0x20,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 2e                	js     8014b1 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801483:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801486:	89 d0                	mov    %edx,%eax
  801488:	c1 e8 0c             	shr    $0xc,%eax
  80148b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	25 07 0e 00 00       	and    $0xe07,%eax
  80149a:	50                   	push   %eax
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	52                   	push   %edx
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 9e f8 ff ff       	call   800d44 <sys_page_map>
  8014a6:	89 c7                	mov    %eax,%edi
  8014a8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ab:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ad:	85 ff                	test   %edi,%edi
  8014af:	79 1d                	jns    8014ce <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 ca f8 ff ff       	call   800d86 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 bd f8 ff ff       	call   800d86 <sys_page_unmap>
	return r;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	89 f8                	mov    %edi,%eax
}
  8014ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 14             	sub    $0x14,%esp
  8014dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	53                   	push   %ebx
  8014e5:	e8 82 fd ff ff       	call   80126c <fd_lookup>
  8014ea:	83 c4 08             	add    $0x8,%esp
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 6d                	js     801560 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	ff 30                	pushl  (%eax)
  8014ff:	e8 be fd ff ff       	call   8012c2 <dev_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 4c                	js     801557 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150e:	8b 42 08             	mov    0x8(%edx),%eax
  801511:	83 e0 03             	and    $0x3,%eax
  801514:	83 f8 01             	cmp    $0x1,%eax
  801517:	75 21                	jne    80153a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801519:	a1 04 40 80 00       	mov    0x804004,%eax
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 49 29 80 00       	push   $0x802949
  80152b:	e8 41 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801538:	eb 26                	jmp    801560 <read+0x8a>
	}
	if (!dev->dev_read)
  80153a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153d:	8b 40 08             	mov    0x8(%eax),%eax
  801540:	85 c0                	test   %eax,%eax
  801542:	74 17                	je     80155b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	ff 75 10             	pushl  0x10(%ebp)
  80154a:	ff 75 0c             	pushl  0xc(%ebp)
  80154d:	52                   	push   %edx
  80154e:	ff d0                	call   *%eax
  801550:	89 c2                	mov    %eax,%edx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	eb 09                	jmp    801560 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801557:	89 c2                	mov    %eax,%edx
  801559:	eb 05                	jmp    801560 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80155b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801560:	89 d0                	mov    %edx,%eax
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	57                   	push   %edi
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	8b 7d 08             	mov    0x8(%ebp),%edi
  801573:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801576:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157b:	eb 21                	jmp    80159e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	89 f0                	mov    %esi,%eax
  801582:	29 d8                	sub    %ebx,%eax
  801584:	50                   	push   %eax
  801585:	89 d8                	mov    %ebx,%eax
  801587:	03 45 0c             	add    0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	57                   	push   %edi
  80158c:	e8 45 ff ff ff       	call   8014d6 <read>
		if (m < 0)
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 0c                	js     8015a4 <readn+0x3d>
			return m;
		if (m == 0)
  801598:	85 c0                	test   %eax,%eax
  80159a:	74 06                	je     8015a2 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159c:	01 c3                	add    %eax,%ebx
  80159e:	39 f3                	cmp    %esi,%ebx
  8015a0:	72 db                	jb     80157d <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015a2:	89 d8                	mov    %ebx,%eax
}
  8015a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	53                   	push   %ebx
  8015bb:	e8 ac fc ff ff       	call   80126c <fd_lookup>
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 68                	js     801631 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d3:	ff 30                	pushl  (%eax)
  8015d5:	e8 e8 fc ff ff       	call   8012c2 <dev_lookup>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 47                	js     801628 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e8:	75 21                	jne    80160b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ef:	8b 40 48             	mov    0x48(%eax),%eax
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	53                   	push   %ebx
  8015f6:	50                   	push   %eax
  8015f7:	68 65 29 80 00       	push   $0x802965
  8015fc:	e8 70 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801609:	eb 26                	jmp    801631 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160e:	8b 52 0c             	mov    0xc(%edx),%edx
  801611:	85 d2                	test   %edx,%edx
  801613:	74 17                	je     80162c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801615:	83 ec 04             	sub    $0x4,%esp
  801618:	ff 75 10             	pushl  0x10(%ebp)
  80161b:	ff 75 0c             	pushl  0xc(%ebp)
  80161e:	50                   	push   %eax
  80161f:	ff d2                	call   *%edx
  801621:	89 c2                	mov    %eax,%edx
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 09                	jmp    801631 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801628:	89 c2                	mov    %eax,%edx
  80162a:	eb 05                	jmp    801631 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80162c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801631:	89 d0                	mov    %edx,%eax
  801633:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <seek>:

int
seek(int fdnum, off_t offset)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	ff 75 08             	pushl  0x8(%ebp)
  801645:	e8 22 fc ff ff       	call   80126c <fd_lookup>
  80164a:	83 c4 08             	add    $0x8,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 0e                	js     80165f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801651:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801654:	8b 55 0c             	mov    0xc(%ebp),%edx
  801657:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	53                   	push   %ebx
  801665:	83 ec 14             	sub    $0x14,%esp
  801668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	53                   	push   %ebx
  801670:	e8 f7 fb ff ff       	call   80126c <fd_lookup>
  801675:	83 c4 08             	add    $0x8,%esp
  801678:	89 c2                	mov    %eax,%edx
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 65                	js     8016e3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801688:	ff 30                	pushl  (%eax)
  80168a:	e8 33 fc ff ff       	call   8012c2 <dev_lookup>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 44                	js     8016da <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801699:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169d:	75 21                	jne    8016c0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80169f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a4:	8b 40 48             	mov    0x48(%eax),%eax
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	53                   	push   %ebx
  8016ab:	50                   	push   %eax
  8016ac:	68 28 29 80 00       	push   $0x802928
  8016b1:	e8 bb ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016be:	eb 23                	jmp    8016e3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c3:	8b 52 18             	mov    0x18(%edx),%edx
  8016c6:	85 d2                	test   %edx,%edx
  8016c8:	74 14                	je     8016de <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	50                   	push   %eax
  8016d1:	ff d2                	call   *%edx
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb 09                	jmp    8016e3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	eb 05                	jmp    8016e3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e3:	89 d0                	mov    %edx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 14             	sub    $0x14,%esp
  8016f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	ff 75 08             	pushl  0x8(%ebp)
  8016fb:	e8 6c fb ff ff       	call   80126c <fd_lookup>
  801700:	83 c4 08             	add    $0x8,%esp
  801703:	89 c2                	mov    %eax,%edx
  801705:	85 c0                	test   %eax,%eax
  801707:	78 58                	js     801761 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801713:	ff 30                	pushl  (%eax)
  801715:	e8 a8 fb ff ff       	call   8012c2 <dev_lookup>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 37                	js     801758 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801721:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801724:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801728:	74 32                	je     80175c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80172a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80172d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801734:	00 00 00 
	stat->st_isdir = 0;
  801737:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80173e:	00 00 00 
	stat->st_dev = dev;
  801741:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	53                   	push   %ebx
  80174b:	ff 75 f0             	pushl  -0x10(%ebp)
  80174e:	ff 50 14             	call   *0x14(%eax)
  801751:	89 c2                	mov    %eax,%edx
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	eb 09                	jmp    801761 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801758:	89 c2                	mov    %eax,%edx
  80175a:	eb 05                	jmp    801761 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80175c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801761:	89 d0                	mov    %edx,%eax
  801763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	6a 00                	push   $0x0
  801772:	ff 75 08             	pushl  0x8(%ebp)
  801775:	e8 09 02 00 00       	call   801983 <open>
  80177a:	89 c3                	mov    %eax,%ebx
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	85 db                	test   %ebx,%ebx
  801781:	78 1b                	js     80179e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	ff 75 0c             	pushl  0xc(%ebp)
  801789:	53                   	push   %ebx
  80178a:	e8 5b ff ff ff       	call   8016ea <fstat>
  80178f:	89 c6                	mov    %eax,%esi
	close(fd);
  801791:	89 1c 24             	mov    %ebx,(%esp)
  801794:	e8 fd fb ff ff       	call   801396 <close>
	return r;
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	89 f0                	mov    %esi,%eax
}
  80179e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	56                   	push   %esi
  8017a9:	53                   	push   %ebx
  8017aa:	89 c6                	mov    %eax,%esi
  8017ac:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ae:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b5:	75 12                	jne    8017c9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	6a 01                	push   $0x1
  8017bc:	e8 92 08 00 00       	call   802053 <ipc_find_env>
  8017c1:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c9:	6a 07                	push   $0x7
  8017cb:	68 00 50 80 00       	push   $0x805000
  8017d0:	56                   	push   %esi
  8017d1:	ff 35 00 40 80 00    	pushl  0x804000
  8017d7:	e8 23 08 00 00       	call   801fff <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017dc:	83 c4 0c             	add    $0xc,%esp
  8017df:	6a 00                	push   $0x0
  8017e1:	53                   	push   %ebx
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 ad 07 00 00       	call   801f96 <ipc_recv>
}
  8017e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 02 00 00 00       	mov    $0x2,%eax
  801813:	e8 8d ff ff ff       	call   8017a5 <fsipc>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	8b 40 0c             	mov    0xc(%eax),%eax
  801826:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	b8 06 00 00 00       	mov    $0x6,%eax
  801835:	e8 6b ff ff ff       	call   8017a5 <fsipc>
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	53                   	push   %ebx
  801840:	83 ec 04             	sub    $0x4,%esp
  801843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	8b 40 0c             	mov    0xc(%eax),%eax
  80184c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 05 00 00 00       	mov    $0x5,%eax
  80185b:	e8 45 ff ff ff       	call   8017a5 <fsipc>
  801860:	89 c2                	mov    %eax,%edx
  801862:	85 d2                	test   %edx,%edx
  801864:	78 2c                	js     801892 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	68 00 50 80 00       	push   $0x805000
  80186e:	53                   	push   %ebx
  80186f:	e8 84 f0 ff ff       	call   8008f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801874:	a1 80 50 80 00       	mov    0x805080,%eax
  801879:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187f:	a1 84 50 80 00       	mov    0x805084,%eax
  801884:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	57                   	push   %edi
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a9:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8018ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018b1:	eb 3d                	jmp    8018f0 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8018b3:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8018b9:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8018be:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	57                   	push   %edi
  8018c5:	53                   	push   %ebx
  8018c6:	68 08 50 80 00       	push   $0x805008
  8018cb:	e8 ba f1 ff ff       	call   800a8a <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018d0:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018db:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e0:	e8 c0 fe ff ff       	call   8017a5 <fsipc>
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 0d                	js     8018f9 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8018ec:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8018ee:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018f0:	85 f6                	test   %esi,%esi
  8018f2:	75 bf                	jne    8018b3 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8018f4:	89 d8                	mov    %ebx,%eax
  8018f6:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8018f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5f                   	pop    %edi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	56                   	push   %esi
  801905:	53                   	push   %ebx
  801906:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	8b 40 0c             	mov    0xc(%eax),%eax
  80190f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801914:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80191a:	ba 00 00 00 00       	mov    $0x0,%edx
  80191f:	b8 03 00 00 00       	mov    $0x3,%eax
  801924:	e8 7c fe ff ff       	call   8017a5 <fsipc>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 4b                	js     80197a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80192f:	39 c6                	cmp    %eax,%esi
  801931:	73 16                	jae    801949 <devfile_read+0x48>
  801933:	68 94 29 80 00       	push   $0x802994
  801938:	68 9b 29 80 00       	push   $0x80299b
  80193d:	6a 7c                	push   $0x7c
  80193f:	68 b0 29 80 00       	push   $0x8029b0
  801944:	e8 4f e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801949:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194e:	7e 16                	jle    801966 <devfile_read+0x65>
  801950:	68 bb 29 80 00       	push   $0x8029bb
  801955:	68 9b 29 80 00       	push   $0x80299b
  80195a:	6a 7d                	push   $0x7d
  80195c:	68 b0 29 80 00       	push   $0x8029b0
  801961:	e8 32 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	50                   	push   %eax
  80196a:	68 00 50 80 00       	push   $0x805000
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	e8 13 f1 ff ff       	call   800a8a <memmove>
	return r;
  801977:	83 c4 10             	add    $0x10,%esp
}
  80197a:	89 d8                	mov    %ebx,%eax
  80197c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	53                   	push   %ebx
  801987:	83 ec 20             	sub    $0x20,%esp
  80198a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80198d:	53                   	push   %ebx
  80198e:	e8 2c ef ff ff       	call   8008bf <strlen>
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80199b:	7f 67                	jg     801a04 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a3:	50                   	push   %eax
  8019a4:	e8 74 f8 ff ff       	call   80121d <fd_alloc>
  8019a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ac:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 57                	js     801a09 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b2:	83 ec 08             	sub    $0x8,%esp
  8019b5:	53                   	push   %ebx
  8019b6:	68 00 50 80 00       	push   $0x805000
  8019bb:	e8 38 ef ff ff       	call   8008f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d0:	e8 d0 fd ff ff       	call   8017a5 <fsipc>
  8019d5:	89 c3                	mov    %eax,%ebx
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	79 14                	jns    8019f2 <open+0x6f>
		fd_close(fd, 0);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	6a 00                	push   $0x0
  8019e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e6:	e8 2a f9 ff ff       	call   801315 <fd_close>
		return r;
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	89 da                	mov    %ebx,%edx
  8019f0:	eb 17                	jmp    801a09 <open+0x86>
	}

	return fd2num(fd);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f8:	e8 f9 f7 ff ff       	call   8011f6 <fd2num>
  8019fd:	89 c2                	mov    %eax,%edx
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	eb 05                	jmp    801a09 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a04:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a09:	89 d0                	mov    %edx,%eax
  801a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a20:	e8 80 fd ff ff       	call   8017a5 <fsipc>
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	ff 75 08             	pushl  0x8(%ebp)
  801a35:	e8 cc f7 ff ff       	call   801206 <fd2data>
  801a3a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a3c:	83 c4 08             	add    $0x8,%esp
  801a3f:	68 c7 29 80 00       	push   $0x8029c7
  801a44:	53                   	push   %ebx
  801a45:	e8 ae ee ff ff       	call   8008f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a4a:	8b 56 04             	mov    0x4(%esi),%edx
  801a4d:	89 d0                	mov    %edx,%eax
  801a4f:	2b 06                	sub    (%esi),%eax
  801a51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a57:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a5e:	00 00 00 
	stat->st_dev = &devpipe;
  801a61:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a68:	30 80 00 
	return 0;
}
  801a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a81:	53                   	push   %ebx
  801a82:	6a 00                	push   $0x0
  801a84:	e8 fd f2 ff ff       	call   800d86 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a89:	89 1c 24             	mov    %ebx,(%esp)
  801a8c:	e8 75 f7 ff ff       	call   801206 <fd2data>
  801a91:	83 c4 08             	add    $0x8,%esp
  801a94:	50                   	push   %eax
  801a95:	6a 00                	push   $0x0
  801a97:	e8 ea f2 ff ff       	call   800d86 <sys_page_unmap>
}
  801a9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	57                   	push   %edi
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 1c             	sub    $0x1c,%esp
  801aaa:	89 c6                	mov    %eax,%esi
  801aac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	56                   	push   %esi
  801abb:	e8 cb 05 00 00       	call   80208b <pageref>
  801ac0:	89 c7                	mov    %eax,%edi
  801ac2:	83 c4 04             	add    $0x4,%esp
  801ac5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac8:	e8 be 05 00 00       	call   80208b <pageref>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	39 c7                	cmp    %eax,%edi
  801ad2:	0f 94 c2             	sete   %dl
  801ad5:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801ad8:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801ade:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ae1:	39 fb                	cmp    %edi,%ebx
  801ae3:	74 19                	je     801afe <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801ae5:	84 d2                	test   %dl,%dl
  801ae7:	74 c6                	je     801aaf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae9:	8b 51 58             	mov    0x58(%ecx),%edx
  801aec:	50                   	push   %eax
  801aed:	52                   	push   %edx
  801aee:	53                   	push   %ebx
  801aef:	68 ce 29 80 00       	push   $0x8029ce
  801af4:	e8 78 e8 ff ff       	call   800371 <cprintf>
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	eb b1                	jmp    801aaf <_pipeisclosed+0xe>
	}
}
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	57                   	push   %edi
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 28             	sub    $0x28,%esp
  801b0f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b12:	56                   	push   %esi
  801b13:	e8 ee f6 ff ff       	call   801206 <fd2data>
  801b18:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	bf 00 00 00 00       	mov    $0x0,%edi
  801b22:	eb 4b                	jmp    801b6f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b24:	89 da                	mov    %ebx,%edx
  801b26:	89 f0                	mov    %esi,%eax
  801b28:	e8 74 ff ff ff       	call   801aa1 <_pipeisclosed>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	75 48                	jne    801b79 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b31:	e8 ac f1 ff ff       	call   800ce2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b36:	8b 43 04             	mov    0x4(%ebx),%eax
  801b39:	8b 0b                	mov    (%ebx),%ecx
  801b3b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3e:	39 d0                	cmp    %edx,%eax
  801b40:	73 e2                	jae    801b24 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b45:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b49:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4c:	89 c2                	mov    %eax,%edx
  801b4e:	c1 fa 1f             	sar    $0x1f,%edx
  801b51:	89 d1                	mov    %edx,%ecx
  801b53:	c1 e9 1b             	shr    $0x1b,%ecx
  801b56:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b59:	83 e2 1f             	and    $0x1f,%edx
  801b5c:	29 ca                	sub    %ecx,%edx
  801b5e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b62:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b66:	83 c0 01             	add    $0x1,%eax
  801b69:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6c:	83 c7 01             	add    $0x1,%edi
  801b6f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b72:	75 c2                	jne    801b36 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b74:	8b 45 10             	mov    0x10(%ebp),%eax
  801b77:	eb 05                	jmp    801b7e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5f                   	pop    %edi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	57                   	push   %edi
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 18             	sub    $0x18,%esp
  801b8f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b92:	57                   	push   %edi
  801b93:	e8 6e f6 ff ff       	call   801206 <fd2data>
  801b98:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba2:	eb 3d                	jmp    801be1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba4:	85 db                	test   %ebx,%ebx
  801ba6:	74 04                	je     801bac <devpipe_read+0x26>
				return i;
  801ba8:	89 d8                	mov    %ebx,%eax
  801baa:	eb 44                	jmp    801bf0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bac:	89 f2                	mov    %esi,%edx
  801bae:	89 f8                	mov    %edi,%eax
  801bb0:	e8 ec fe ff ff       	call   801aa1 <_pipeisclosed>
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	75 32                	jne    801beb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb9:	e8 24 f1 ff ff       	call   800ce2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bbe:	8b 06                	mov    (%esi),%eax
  801bc0:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc3:	74 df                	je     801ba4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc5:	99                   	cltd   
  801bc6:	c1 ea 1b             	shr    $0x1b,%edx
  801bc9:	01 d0                	add    %edx,%eax
  801bcb:	83 e0 1f             	and    $0x1f,%eax
  801bce:	29 d0                	sub    %edx,%eax
  801bd0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bdb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bde:	83 c3 01             	add    $0x1,%ebx
  801be1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be4:	75 d8                	jne    801bbe <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be6:	8b 45 10             	mov    0x10(%ebp),%eax
  801be9:	eb 05                	jmp    801bf0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c03:	50                   	push   %eax
  801c04:	e8 14 f6 ff ff       	call   80121d <fd_alloc>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	89 c2                	mov    %eax,%edx
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	0f 88 2c 01 00 00    	js     801d42 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	68 07 04 00 00       	push   $0x407
  801c1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c21:	6a 00                	push   $0x0
  801c23:	e8 d9 f0 ff ff       	call   800d01 <sys_page_alloc>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 0d 01 00 00    	js     801d42 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3b:	50                   	push   %eax
  801c3c:	e8 dc f5 ff ff       	call   80121d <fd_alloc>
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	0f 88 e2 00 00 00    	js     801d30 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4e:	83 ec 04             	sub    $0x4,%esp
  801c51:	68 07 04 00 00       	push   $0x407
  801c56:	ff 75 f0             	pushl  -0x10(%ebp)
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 a1 f0 ff ff       	call   800d01 <sys_page_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	0f 88 c3 00 00 00    	js     801d30 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6d:	83 ec 0c             	sub    $0xc,%esp
  801c70:	ff 75 f4             	pushl  -0xc(%ebp)
  801c73:	e8 8e f5 ff ff       	call   801206 <fd2data>
  801c78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7a:	83 c4 0c             	add    $0xc,%esp
  801c7d:	68 07 04 00 00       	push   $0x407
  801c82:	50                   	push   %eax
  801c83:	6a 00                	push   $0x0
  801c85:	e8 77 f0 ff ff       	call   800d01 <sys_page_alloc>
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	0f 88 89 00 00 00    	js     801d20 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c97:	83 ec 0c             	sub    $0xc,%esp
  801c9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9d:	e8 64 f5 ff ff       	call   801206 <fd2data>
  801ca2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca9:	50                   	push   %eax
  801caa:	6a 00                	push   $0x0
  801cac:	56                   	push   %esi
  801cad:	6a 00                	push   $0x0
  801caf:	e8 90 f0 ff ff       	call   800d44 <sys_page_map>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	83 c4 20             	add    $0x20,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 55                	js     801d12 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	e8 04 f5 ff ff       	call   8011f6 <fd2num>
  801cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf7:	83 c4 04             	add    $0x4,%esp
  801cfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfd:	e8 f4 f4 ff ff       	call   8011f6 <fd2num>
  801d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d05:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d10:	eb 30                	jmp    801d42 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d12:	83 ec 08             	sub    $0x8,%esp
  801d15:	56                   	push   %esi
  801d16:	6a 00                	push   $0x0
  801d18:	e8 69 f0 ff ff       	call   800d86 <sys_page_unmap>
  801d1d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d20:	83 ec 08             	sub    $0x8,%esp
  801d23:	ff 75 f0             	pushl  -0x10(%ebp)
  801d26:	6a 00                	push   $0x0
  801d28:	e8 59 f0 ff ff       	call   800d86 <sys_page_unmap>
  801d2d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d30:	83 ec 08             	sub    $0x8,%esp
  801d33:	ff 75 f4             	pushl  -0xc(%ebp)
  801d36:	6a 00                	push   $0x0
  801d38:	e8 49 f0 ff ff       	call   800d86 <sys_page_unmap>
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d42:	89 d0                	mov    %edx,%eax
  801d44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	50                   	push   %eax
  801d55:	ff 75 08             	pushl  0x8(%ebp)
  801d58:	e8 0f f5 ff ff       	call   80126c <fd_lookup>
  801d5d:	89 c2                	mov    %eax,%edx
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 d2                	test   %edx,%edx
  801d64:	78 18                	js     801d7e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6c:	e8 95 f4 ff ff       	call   801206 <fd2data>
	return _pipeisclosed(fd, p);
  801d71:	89 c2                	mov    %eax,%edx
  801d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d76:	e8 26 fd ff ff       	call   801aa1 <_pipeisclosed>
  801d7b:	83 c4 10             	add    $0x10,%esp
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d90:	68 e1 29 80 00       	push   $0x8029e1
  801d95:	ff 75 0c             	pushl  0xc(%ebp)
  801d98:	e8 5b eb ff ff       	call   8008f8 <strcpy>
	return 0;
}
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	57                   	push   %edi
  801da8:	56                   	push   %esi
  801da9:	53                   	push   %ebx
  801daa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	eb 2d                	jmp    801dea <devcons_write+0x46>
		m = n - tot;
  801dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dc2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dca:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dcd:	83 ec 04             	sub    $0x4,%esp
  801dd0:	53                   	push   %ebx
  801dd1:	03 45 0c             	add    0xc(%ebp),%eax
  801dd4:	50                   	push   %eax
  801dd5:	57                   	push   %edi
  801dd6:	e8 af ec ff ff       	call   800a8a <memmove>
		sys_cputs(buf, m);
  801ddb:	83 c4 08             	add    $0x8,%esp
  801dde:	53                   	push   %ebx
  801ddf:	57                   	push   %edi
  801de0:	e8 60 ee ff ff       	call   800c45 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de5:	01 de                	add    %ebx,%esi
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	89 f0                	mov    %esi,%eax
  801dec:	3b 75 10             	cmp    0x10(%ebp),%esi
  801def:	72 cc                	jb     801dbd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801e04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e08:	75 07                	jne    801e11 <devcons_read+0x18>
  801e0a:	eb 28                	jmp    801e34 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e0c:	e8 d1 ee ff ff       	call   800ce2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e11:	e8 4d ee ff ff       	call   800c63 <sys_cgetc>
  801e16:	85 c0                	test   %eax,%eax
  801e18:	74 f2                	je     801e0c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	78 16                	js     801e34 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1e:	83 f8 04             	cmp    $0x4,%eax
  801e21:	74 0c                	je     801e2f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e26:	88 02                	mov    %al,(%edx)
	return 1;
  801e28:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2d:	eb 05                	jmp    801e34 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e42:	6a 01                	push   $0x1
  801e44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 f8 ed ff ff       	call   800c45 <sys_cputs>
  801e4d:	83 c4 10             	add    $0x10,%esp
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <getchar>:

int
getchar(void)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e58:	6a 01                	push   $0x1
  801e5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 71 f6 ff ff       	call   8014d6 <read>
	if (r < 0)
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 0f                	js     801e7b <getchar+0x29>
		return r;
	if (r < 1)
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	7e 06                	jle    801e76 <getchar+0x24>
		return -E_EOF;
	return c;
  801e70:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e74:	eb 05                	jmp    801e7b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e76:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e86:	50                   	push   %eax
  801e87:	ff 75 08             	pushl  0x8(%ebp)
  801e8a:	e8 dd f3 ff ff       	call   80126c <fd_lookup>
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 11                	js     801ea7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9f:	39 10                	cmp    %edx,(%eax)
  801ea1:	0f 94 c0             	sete   %al
  801ea4:	0f b6 c0             	movzbl %al,%eax
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <opencons>:

int
opencons(void)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb2:	50                   	push   %eax
  801eb3:	e8 65 f3 ff ff       	call   80121d <fd_alloc>
  801eb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 3e                	js     801eff <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec1:	83 ec 04             	sub    $0x4,%esp
  801ec4:	68 07 04 00 00       	push   $0x407
  801ec9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 2e ee ff ff       	call   800d01 <sys_page_alloc>
  801ed3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 23                	js     801eff <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801edc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	50                   	push   %eax
  801ef5:	e8 fc f2 ff ff       	call   8011f6 <fd2num>
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	83 c4 10             	add    $0x10,%esp
}
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f09:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f10:	75 2c                	jne    801f3e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801f12:	83 ec 04             	sub    $0x4,%esp
  801f15:	6a 07                	push   $0x7
  801f17:	68 00 f0 bf ee       	push   $0xeebff000
  801f1c:	6a 00                	push   $0x0
  801f1e:	e8 de ed ff ff       	call   800d01 <sys_page_alloc>
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	74 14                	je     801f3e <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801f2a:	83 ec 04             	sub    $0x4,%esp
  801f2d:	68 f0 29 80 00       	push   $0x8029f0
  801f32:	6a 21                	push   $0x21
  801f34:	68 54 2a 80 00       	push   $0x802a54
  801f39:	e8 5a e3 ff ff       	call   800298 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f41:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f46:	83 ec 08             	sub    $0x8,%esp
  801f49:	68 72 1f 80 00       	push   $0x801f72
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 f7 ee ff ff       	call   800e4c <sys_env_set_pgfault_upcall>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	79 14                	jns    801f70 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f5c:	83 ec 04             	sub    $0x4,%esp
  801f5f:	68 1c 2a 80 00       	push   $0x802a1c
  801f64:	6a 29                	push   $0x29
  801f66:	68 54 2a 80 00       	push   $0x802a54
  801f6b:	e8 28 e3 ff ff       	call   800298 <_panic>
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f72:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f73:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f78:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f7a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801f7d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801f82:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801f86:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801f8a:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801f8c:	83 c4 08             	add    $0x8,%esp
        popal
  801f8f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f90:	83 c4 04             	add    $0x4,%esp
        popfl
  801f93:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801f94:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f95:	c3                   	ret    

00801f96 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fab:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801fae:	83 ec 0c             	sub    $0xc,%esp
  801fb1:	50                   	push   %eax
  801fb2:	e8 fa ee ff ff       	call   800eb1 <sys_ipc_recv>
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	79 16                	jns    801fd4 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801fbe:	85 f6                	test   %esi,%esi
  801fc0:	74 06                	je     801fc8 <ipc_recv+0x32>
  801fc2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801fc8:	85 db                	test   %ebx,%ebx
  801fca:	74 2c                	je     801ff8 <ipc_recv+0x62>
  801fcc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fd2:	eb 24                	jmp    801ff8 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801fd4:	85 f6                	test   %esi,%esi
  801fd6:	74 0a                	je     801fe2 <ipc_recv+0x4c>
  801fd8:	a1 04 40 80 00       	mov    0x804004,%eax
  801fdd:	8b 40 74             	mov    0x74(%eax),%eax
  801fe0:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801fe2:	85 db                	test   %ebx,%ebx
  801fe4:	74 0a                	je     801ff0 <ipc_recv+0x5a>
  801fe6:	a1 04 40 80 00       	mov    0x804004,%eax
  801feb:	8b 40 78             	mov    0x78(%eax),%eax
  801fee:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801ff0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ff5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ff8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffb:	5b                   	pop    %ebx
  801ffc:	5e                   	pop    %esi
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	57                   	push   %edi
  802003:	56                   	push   %esi
  802004:	53                   	push   %ebx
  802005:	83 ec 0c             	sub    $0xc,%esp
  802008:	8b 7d 08             	mov    0x8(%ebp),%edi
  80200b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80200e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802011:	85 db                	test   %ebx,%ebx
  802013:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802018:	0f 44 d8             	cmove  %eax,%ebx
  80201b:	eb 1c                	jmp    802039 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80201d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802020:	74 12                	je     802034 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802022:	50                   	push   %eax
  802023:	68 62 2a 80 00       	push   $0x802a62
  802028:	6a 39                	push   $0x39
  80202a:	68 7d 2a 80 00       	push   $0x802a7d
  80202f:	e8 64 e2 ff ff       	call   800298 <_panic>
                 sys_yield();
  802034:	e8 a9 ec ff ff       	call   800ce2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802039:	ff 75 14             	pushl  0x14(%ebp)
  80203c:	53                   	push   %ebx
  80203d:	56                   	push   %esi
  80203e:	57                   	push   %edi
  80203f:	e8 4a ee ff ff       	call   800e8e <sys_ipc_try_send>
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	85 c0                	test   %eax,%eax
  802049:	78 d2                	js     80201d <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80204b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802059:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80205e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802061:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802067:	8b 52 50             	mov    0x50(%edx),%edx
  80206a:	39 ca                	cmp    %ecx,%edx
  80206c:	75 0d                	jne    80207b <ipc_find_env+0x28>
			return envs[i].env_id;
  80206e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802071:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802076:	8b 40 08             	mov    0x8(%eax),%eax
  802079:	eb 0e                	jmp    802089 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80207b:	83 c0 01             	add    $0x1,%eax
  80207e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802083:	75 d9                	jne    80205e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802085:	66 b8 00 00          	mov    $0x0,%ax
}
  802089:	5d                   	pop    %ebp
  80208a:	c3                   	ret    

0080208b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802091:	89 d0                	mov    %edx,%eax
  802093:	c1 e8 16             	shr    $0x16,%eax
  802096:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80209d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a2:	f6 c1 01             	test   $0x1,%cl
  8020a5:	74 1d                	je     8020c4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a7:	c1 ea 0c             	shr    $0xc,%edx
  8020aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020b1:	f6 c2 01             	test   $0x1,%dl
  8020b4:	74 0e                	je     8020c4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b6:	c1 ea 0c             	shr    $0xc,%edx
  8020b9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020c0:	ef 
  8020c1:	0f b7 c0             	movzwl %ax,%eax
}
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	83 ec 10             	sub    $0x10,%esp
  8020d6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020da:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020de:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020e6:	85 d2                	test   %edx,%edx
  8020e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020ec:	89 34 24             	mov    %esi,(%esp)
  8020ef:	89 c8                	mov    %ecx,%eax
  8020f1:	75 35                	jne    802128 <__udivdi3+0x58>
  8020f3:	39 f1                	cmp    %esi,%ecx
  8020f5:	0f 87 bd 00 00 00    	ja     8021b8 <__udivdi3+0xe8>
  8020fb:	85 c9                	test   %ecx,%ecx
  8020fd:	89 cd                	mov    %ecx,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f1                	div    %ecx
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 f0                	mov    %esi,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c6                	mov    %eax,%esi
  802114:	89 f8                	mov    %edi,%eax
  802116:	f7 f5                	div    %ebp
  802118:	89 f2                	mov    %esi,%edx
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	5e                   	pop    %esi
  80211e:	5f                   	pop    %edi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    
  802121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802128:	3b 14 24             	cmp    (%esp),%edx
  80212b:	77 7b                	ja     8021a8 <__udivdi3+0xd8>
  80212d:	0f bd f2             	bsr    %edx,%esi
  802130:	83 f6 1f             	xor    $0x1f,%esi
  802133:	0f 84 97 00 00 00    	je     8021d0 <__udivdi3+0x100>
  802139:	bd 20 00 00 00       	mov    $0x20,%ebp
  80213e:	89 d7                	mov    %edx,%edi
  802140:	89 f1                	mov    %esi,%ecx
  802142:	29 f5                	sub    %esi,%ebp
  802144:	d3 e7                	shl    %cl,%edi
  802146:	89 c2                	mov    %eax,%edx
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	d3 ea                	shr    %cl,%edx
  80214c:	89 f1                	mov    %esi,%ecx
  80214e:	09 fa                	or     %edi,%edx
  802150:	8b 3c 24             	mov    (%esp),%edi
  802153:	d3 e0                	shl    %cl,%eax
  802155:	89 54 24 08          	mov    %edx,0x8(%esp)
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802163:	89 fa                	mov    %edi,%edx
  802165:	d3 ea                	shr    %cl,%edx
  802167:	89 f1                	mov    %esi,%ecx
  802169:	d3 e7                	shl    %cl,%edi
  80216b:	89 e9                	mov    %ebp,%ecx
  80216d:	d3 e8                	shr    %cl,%eax
  80216f:	09 c7                	or     %eax,%edi
  802171:	89 f8                	mov    %edi,%eax
  802173:	f7 74 24 08          	divl   0x8(%esp)
  802177:	89 d5                	mov    %edx,%ebp
  802179:	89 c7                	mov    %eax,%edi
  80217b:	f7 64 24 0c          	mull   0xc(%esp)
  80217f:	39 d5                	cmp    %edx,%ebp
  802181:	89 14 24             	mov    %edx,(%esp)
  802184:	72 11                	jb     802197 <__udivdi3+0xc7>
  802186:	8b 54 24 04          	mov    0x4(%esp),%edx
  80218a:	89 f1                	mov    %esi,%ecx
  80218c:	d3 e2                	shl    %cl,%edx
  80218e:	39 c2                	cmp    %eax,%edx
  802190:	73 5e                	jae    8021f0 <__udivdi3+0x120>
  802192:	3b 2c 24             	cmp    (%esp),%ebp
  802195:	75 59                	jne    8021f0 <__udivdi3+0x120>
  802197:	8d 47 ff             	lea    -0x1(%edi),%eax
  80219a:	31 f6                	xor    %esi,%esi
  80219c:	89 f2                	mov    %esi,%edx
  80219e:	83 c4 10             	add    $0x10,%esp
  8021a1:	5e                   	pop    %esi
  8021a2:	5f                   	pop    %edi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    
  8021a5:	8d 76 00             	lea    0x0(%esi),%esi
  8021a8:	31 f6                	xor    %esi,%esi
  8021aa:	31 c0                	xor    %eax,%eax
  8021ac:	89 f2                	mov    %esi,%edx
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	5e                   	pop    %esi
  8021b2:	5f                   	pop    %edi
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    
  8021b5:	8d 76 00             	lea    0x0(%esi),%esi
  8021b8:	89 f2                	mov    %esi,%edx
  8021ba:	31 f6                	xor    %esi,%esi
  8021bc:	89 f8                	mov    %edi,%eax
  8021be:	f7 f1                	div    %ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	83 c4 10             	add    $0x10,%esp
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021d4:	76 0b                	jbe    8021e1 <__udivdi3+0x111>
  8021d6:	31 c0                	xor    %eax,%eax
  8021d8:	3b 14 24             	cmp    (%esp),%edx
  8021db:	0f 83 37 ff ff ff    	jae    802118 <__udivdi3+0x48>
  8021e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e6:	e9 2d ff ff ff       	jmp    802118 <__udivdi3+0x48>
  8021eb:	90                   	nop
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 f8                	mov    %edi,%eax
  8021f2:	31 f6                	xor    %esi,%esi
  8021f4:	e9 1f ff ff ff       	jmp    802118 <__udivdi3+0x48>
  8021f9:	66 90                	xchg   %ax,%ax
  8021fb:	66 90                	xchg   %ax,%ax
  8021fd:	66 90                	xchg   %ax,%ax
  8021ff:	90                   	nop

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	83 ec 20             	sub    $0x20,%esp
  802206:	8b 44 24 34          	mov    0x34(%esp),%eax
  80220a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802212:	89 c6                	mov    %eax,%esi
  802214:	89 44 24 10          	mov    %eax,0x10(%esp)
  802218:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80221c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802220:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802224:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802228:	89 74 24 18          	mov    %esi,0x18(%esp)
  80222c:	85 c0                	test   %eax,%eax
  80222e:	89 c2                	mov    %eax,%edx
  802230:	75 1e                	jne    802250 <__umoddi3+0x50>
  802232:	39 f7                	cmp    %esi,%edi
  802234:	76 52                	jbe    802288 <__umoddi3+0x88>
  802236:	89 c8                	mov    %ecx,%eax
  802238:	89 f2                	mov    %esi,%edx
  80223a:	f7 f7                	div    %edi
  80223c:	89 d0                	mov    %edx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	83 c4 20             	add    $0x20,%esp
  802243:	5e                   	pop    %esi
  802244:	5f                   	pop    %edi
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    
  802247:	89 f6                	mov    %esi,%esi
  802249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802250:	39 f0                	cmp    %esi,%eax
  802252:	77 5c                	ja     8022b0 <__umoddi3+0xb0>
  802254:	0f bd e8             	bsr    %eax,%ebp
  802257:	83 f5 1f             	xor    $0x1f,%ebp
  80225a:	75 64                	jne    8022c0 <__umoddi3+0xc0>
  80225c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802260:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802264:	0f 86 f6 00 00 00    	jbe    802360 <__umoddi3+0x160>
  80226a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80226e:	0f 82 ec 00 00 00    	jb     802360 <__umoddi3+0x160>
  802274:	8b 44 24 14          	mov    0x14(%esp),%eax
  802278:	8b 54 24 18          	mov    0x18(%esp),%edx
  80227c:	83 c4 20             	add    $0x20,%esp
  80227f:	5e                   	pop    %esi
  802280:	5f                   	pop    %edi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    
  802283:	90                   	nop
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	85 ff                	test   %edi,%edi
  80228a:	89 fd                	mov    %edi,%ebp
  80228c:	75 0b                	jne    802299 <__umoddi3+0x99>
  80228e:	b8 01 00 00 00       	mov    $0x1,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f7                	div    %edi
  802297:	89 c5                	mov    %eax,%ebp
  802299:	8b 44 24 10          	mov    0x10(%esp),%eax
  80229d:	31 d2                	xor    %edx,%edx
  80229f:	f7 f5                	div    %ebp
  8022a1:	89 c8                	mov    %ecx,%eax
  8022a3:	f7 f5                	div    %ebp
  8022a5:	eb 95                	jmp    80223c <__umoddi3+0x3c>
  8022a7:	89 f6                	mov    %esi,%esi
  8022a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 20             	add    $0x20,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022c5:	89 e9                	mov    %ebp,%ecx
  8022c7:	29 e8                	sub    %ebp,%eax
  8022c9:	d3 e2                	shl    %cl,%edx
  8022cb:	89 c7                	mov    %eax,%edi
  8022cd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 c1                	mov    %eax,%ecx
  8022db:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022df:	09 d1                	or     %edx,%ecx
  8022e1:	89 fa                	mov    %edi,%edx
  8022e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022e7:	89 e9                	mov    %ebp,%ecx
  8022e9:	d3 e0                	shl    %cl,%eax
  8022eb:	89 f9                	mov    %edi,%ecx
  8022ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	d3 e8                	shr    %cl,%eax
  8022f5:	89 e9                	mov    %ebp,%ecx
  8022f7:	89 c7                	mov    %eax,%edi
  8022f9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022fd:	d3 e6                	shl    %cl,%esi
  8022ff:	89 d1                	mov    %edx,%ecx
  802301:	89 fa                	mov    %edi,%edx
  802303:	d3 e8                	shr    %cl,%eax
  802305:	89 e9                	mov    %ebp,%ecx
  802307:	09 f0                	or     %esi,%eax
  802309:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80230d:	f7 74 24 10          	divl   0x10(%esp)
  802311:	d3 e6                	shl    %cl,%esi
  802313:	89 d1                	mov    %edx,%ecx
  802315:	f7 64 24 0c          	mull   0xc(%esp)
  802319:	39 d1                	cmp    %edx,%ecx
  80231b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80231f:	89 d7                	mov    %edx,%edi
  802321:	89 c6                	mov    %eax,%esi
  802323:	72 0a                	jb     80232f <__umoddi3+0x12f>
  802325:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802329:	73 10                	jae    80233b <__umoddi3+0x13b>
  80232b:	39 d1                	cmp    %edx,%ecx
  80232d:	75 0c                	jne    80233b <__umoddi3+0x13b>
  80232f:	89 d7                	mov    %edx,%edi
  802331:	89 c6                	mov    %eax,%esi
  802333:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802337:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80233b:	89 ca                	mov    %ecx,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802343:	29 f0                	sub    %esi,%eax
  802345:	19 fa                	sbb    %edi,%edx
  802347:	d3 e8                	shr    %cl,%eax
  802349:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80234e:	89 d7                	mov    %edx,%edi
  802350:	d3 e7                	shl    %cl,%edi
  802352:	89 e9                	mov    %ebp,%ecx
  802354:	09 f8                	or     %edi,%eax
  802356:	d3 ea                	shr    %cl,%edx
  802358:	83 c4 20             	add    $0x20,%esp
  80235b:	5e                   	pop    %esi
  80235c:	5f                   	pop    %edi
  80235d:	5d                   	pop    %ebp
  80235e:	c3                   	ret    
  80235f:	90                   	nop
  802360:	8b 74 24 10          	mov    0x10(%esp),%esi
  802364:	29 f9                	sub    %edi,%ecx
  802366:	19 c6                	sbb    %eax,%esi
  802368:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80236c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802370:	e9 ff fe ff ff       	jmp    802274 <__umoddi3+0x74>
