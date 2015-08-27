
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 6a 10 00 00       	call   8010b6 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 22 80 00       	push   $0x802240
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 2a 0e 00 00       	call   800e94 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 9b 26 80 00       	push   $0x80269b
  800079:	6a 1a                	push   $0x1a
  80007b:	68 4c 22 80 00       	push   $0x80224c
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 1d 10 00 00       	call   8010b6 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 6f 10 00 00       	call   80111f <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 d5 0d 00 00       	call   800e94 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 9b 26 80 00       	push   $0x80269b
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 4c 22 80 00       	push   $0x80224c
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 2f 10 00 00       	call   80111f <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
		ipc_send(id, i, 0, 0);
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800103:	e8 7b 0a 00 00       	call   800b83 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
  800134:	83 c4 10             	add    $0x10,%esp
}
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 2f 12 00 00       	call   801378 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 ef 09 00 00       	call   800b42 <sys_env_destroy>
  800153:	83 c4 10             	add    $0x10,%esp
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 18 0a 00 00       	call   800b83 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 64 22 80 00       	push   $0x802264
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 d9 26 80 00 	movl   $0x8026d9,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 37 09 00 00       	call   800b05 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 4f 01 00 00       	call   800363 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 dc 08 00 00       	call   800b05 <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 d1                	mov    %edx,%ecx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800269:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800270:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800273:	72 05                	jb     80027a <printnum+0x35>
  800275:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800278:	77 3e                	ja     8002b8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	pushl  0x18(%ebp)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 f7 1c 00 00       	call   801f90 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 13                	jmp    8002bf <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	7f ed                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d2:	e8 e9 1d 00 00       	call   8020c0 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
  8002e4:	83 c4 10             	add    $0x10,%esp
}
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f2:	83 fa 01             	cmp    $0x1,%edx
  8002f5:	7e 0e                	jle    800305 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	8b 52 04             	mov    0x4(%edx),%edx
  800303:	eb 22                	jmp    800327 <getuint+0x38>
	else if (lflag)
  800305:	85 d2                	test   %edx,%edx
  800307:	74 10                	je     800319 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030e:	89 08                	mov    %ecx,(%eax)
  800310:	8b 02                	mov    (%edx),%eax
  800312:	ba 00 00 00 00       	mov    $0x0,%edx
  800317:	eb 0e                	jmp    800327 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800333:	8b 10                	mov    (%eax),%edx
  800335:	3b 50 04             	cmp    0x4(%eax),%edx
  800338:	73 0a                	jae    800344 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	88 02                	mov    %al,(%edx)
}
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034f:	50                   	push   %eax
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	e8 05 00 00 00       	call   800363 <vprintfmt>
	va_end(ap);
  80035e:	83 c4 10             	add    $0x10,%esp
}
  800361:	c9                   	leave  
  800362:	c3                   	ret    

00800363 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
  800369:	83 ec 2c             	sub    $0x2c,%esp
  80036c:	8b 75 08             	mov    0x8(%ebp),%esi
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800372:	8b 7d 10             	mov    0x10(%ebp),%edi
  800375:	eb 12                	jmp    800389 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800377:	85 c0                	test   %eax,%eax
  800379:	0f 84 90 03 00 00    	je     80070f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	53                   	push   %ebx
  800383:	50                   	push   %eax
  800384:	ff d6                	call   *%esi
  800386:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800389:	83 c7 01             	add    $0x1,%edi
  80038c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800390:	83 f8 25             	cmp    $0x25,%eax
  800393:	75 e2                	jne    800377 <vprintfmt+0x14>
  800395:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800399:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 07                	jmp    8003bc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8d 47 01             	lea    0x1(%edi),%eax
  8003bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c2:	0f b6 07             	movzbl (%edi),%eax
  8003c5:	0f b6 c8             	movzbl %al,%ecx
  8003c8:	83 e8 23             	sub    $0x23,%eax
  8003cb:	3c 55                	cmp    $0x55,%al
  8003cd:	0f 87 21 03 00 00    	ja     8006f4 <vprintfmt+0x391>
  8003d3:	0f b6 c0             	movzbl %al,%eax
  8003d6:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e4:	eb d6                	jmp    8003bc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003fb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003fe:	83 fa 09             	cmp    $0x9,%edx
  800401:	77 39                	ja     80043c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800403:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800406:	eb e9                	jmp    8003f1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 48 04             	lea    0x4(%eax),%ecx
  80040e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800411:	8b 00                	mov    (%eax),%eax
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800419:	eb 27                	jmp    800442 <vprintfmt+0xdf>
  80041b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041e:	85 c0                	test   %eax,%eax
  800420:	b9 00 00 00 00       	mov    $0x0,%ecx
  800425:	0f 49 c8             	cmovns %eax,%ecx
  800428:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042e:	eb 8c                	jmp    8003bc <vprintfmt+0x59>
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800433:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043a:	eb 80                	jmp    8003bc <vprintfmt+0x59>
  80043c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800442:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800446:	0f 89 70 ff ff ff    	jns    8003bc <vprintfmt+0x59>
				width = precision, precision = -1;
  80044c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800452:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800459:	e9 5e ff ff ff       	jmp    8003bc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800464:	e9 53 ff ff ff       	jmp    8003bc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 50 04             	lea    0x4(%eax),%edx
  80046f:	89 55 14             	mov    %edx,0x14(%ebp)
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	53                   	push   %ebx
  800476:	ff 30                	pushl  (%eax)
  800478:	ff d6                	call   *%esi
			break;
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800480:	e9 04 ff ff ff       	jmp    800389 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	99                   	cltd   
  800491:	31 d0                	xor    %edx,%eax
  800493:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800495:	83 f8 0f             	cmp    $0xf,%eax
  800498:	7f 0b                	jg     8004a5 <vprintfmt+0x142>
  80049a:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	75 18                	jne    8004bd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a5:	50                   	push   %eax
  8004a6:	68 9f 22 80 00       	push   $0x80229f
  8004ab:	53                   	push   %ebx
  8004ac:	56                   	push   %esi
  8004ad:	e8 94 fe ff ff       	call   800346 <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b8:	e9 cc fe ff ff       	jmp    800389 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004bd:	52                   	push   %edx
  8004be:	68 d5 27 80 00       	push   $0x8027d5
  8004c3:	53                   	push   %ebx
  8004c4:	56                   	push   %esi
  8004c5:	e8 7c fe ff ff       	call   800346 <printfmt>
  8004ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d0:	e9 b4 fe ff ff       	jmp    800389 <vprintfmt+0x26>
  8004d5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004db:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 50 04             	lea    0x4(%eax),%edx
  8004e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	ba 98 22 80 00       	mov    $0x802298,%edx
  8004f0:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f7:	0f 84 92 00 00 00    	je     80058f <vprintfmt+0x22c>
  8004fd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800501:	0f 8e 96 00 00 00    	jle    80059d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	51                   	push   %ecx
  80050b:	57                   	push   %edi
  80050c:	e8 86 02 00 00       	call   800797 <strnlen>
  800511:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800514:	29 c1                	sub    %eax,%ecx
  800516:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800520:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800523:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800526:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	eb 0f                	jmp    800539 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	ff 75 e0             	pushl  -0x20(%ebp)
  800531:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	85 ff                	test   %edi,%edi
  80053b:	7f ed                	jg     80052a <vprintfmt+0x1c7>
  80053d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800540:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800543:	85 c9                	test   %ecx,%ecx
  800545:	b8 00 00 00 00       	mov    $0x0,%eax
  80054a:	0f 49 c1             	cmovns %ecx,%eax
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	89 cb                	mov    %ecx,%ebx
  80055a:	eb 4d                	jmp    8005a9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800560:	74 1b                	je     80057d <vprintfmt+0x21a>
  800562:	0f be c0             	movsbl %al,%eax
  800565:	83 e8 20             	sub    $0x20,%eax
  800568:	83 f8 5e             	cmp    $0x5e,%eax
  80056b:	76 10                	jbe    80057d <vprintfmt+0x21a>
					putch('?', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	6a 3f                	push   $0x3f
  800575:	ff 55 08             	call   *0x8(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 0d                	jmp    80058a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	ff 75 0c             	pushl  0xc(%ebp)
  800583:	52                   	push   %edx
  800584:	ff 55 08             	call   *0x8(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	eb 1a                	jmp    8005a9 <vprintfmt+0x246>
  80058f:	89 75 08             	mov    %esi,0x8(%ebp)
  800592:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800595:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800598:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059b:	eb 0c                	jmp    8005a9 <vprintfmt+0x246>
  80059d:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a9:	83 c7 01             	add    $0x1,%edi
  8005ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b0:	0f be d0             	movsbl %al,%edx
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	74 23                	je     8005da <vprintfmt+0x277>
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	78 a1                	js     80055c <vprintfmt+0x1f9>
  8005bb:	83 ee 01             	sub    $0x1,%esi
  8005be:	79 9c                	jns    80055c <vprintfmt+0x1f9>
  8005c0:	89 df                	mov    %ebx,%edi
  8005c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c8:	eb 18                	jmp    8005e2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 20                	push   $0x20
  8005d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 08                	jmp    8005e2 <vprintfmt+0x27f>
  8005da:	89 df                	mov    %ebx,%edi
  8005dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e2:	85 ff                	test   %edi,%edi
  8005e4:	7f e4                	jg     8005ca <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e9:	e9 9b fd ff ff       	jmp    800389 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ee:	83 fa 01             	cmp    $0x1,%edx
  8005f1:	7e 16                	jle    800609 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 08             	lea    0x8(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 50 04             	mov    0x4(%eax),%edx
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800607:	eb 32                	jmp    80063b <vprintfmt+0x2d8>
	else if (lflag)
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 18                	je     800625 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	89 c1                	mov    %eax,%ecx
  80061d:	c1 f9 1f             	sar    $0x1f,%ecx
  800620:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800623:	eb 16                	jmp    80063b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 00                	mov    (%eax),%eax
  800630:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800633:	89 c1                	mov    %eax,%ecx
  800635:	c1 f9 1f             	sar    $0x1f,%ecx
  800638:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800641:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800646:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064a:	79 74                	jns    8006c0 <vprintfmt+0x35d>
				putch('-', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 2d                	push   $0x2d
  800652:	ff d6                	call   *%esi
				num = -(long long) num;
  800654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800657:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065a:	f7 d8                	neg    %eax
  80065c:	83 d2 00             	adc    $0x0,%edx
  80065f:	f7 da                	neg    %edx
  800661:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800664:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800669:	eb 55                	jmp    8006c0 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 7c fc ff ff       	call   8002ef <getuint>
			base = 10;
  800673:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800678:	eb 46                	jmp    8006c0 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	e8 6d fc ff ff       	call   8002ef <getuint>
                        base = 8;
  800682:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800687:	eb 37                	jmp    8006c0 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 30                	push   $0x30
  80068f:	ff d6                	call   *%esi
			putch('x', putdat);
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 78                	push   $0x78
  800697:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 50 04             	lea    0x4(%eax),%edx
  80069f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a2:	8b 00                	mov    (%eax),%eax
  8006a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b1:	eb 0d                	jmp    8006c0 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 34 fc ff ff       	call   8002ef <getuint>
			base = 16;
  8006bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c7:	57                   	push   %edi
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	51                   	push   %ecx
  8006cc:	52                   	push   %edx
  8006cd:	50                   	push   %eax
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 6e fb ff ff       	call   800245 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 a7 fc ff ff       	jmp    800389 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	51                   	push   %ecx
  8006e7:	ff d6                	call   *%esi
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ef:	e9 95 fc ff ff       	jmp    800389 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	6a 25                	push   $0x25
  8006fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 03                	jmp    800704 <vprintfmt+0x3a1>
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800708:	75 f7                	jne    800701 <vprintfmt+0x39e>
  80070a:	e9 7a fc ff ff       	jmp    800389 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 22                	jle    80075e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 29 03 80 00       	push   $0x800329
  80074b:	e8 13 fc ff ff       	call   800363 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9a ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 03                	jmp    80078f <strlen+0x10>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	75 f7                	jne    80078c <strlen+0xd>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	eb 03                	jmp    8007aa <strnlen+0x13>
		n++;
  8007a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 08                	je     8007b6 <strnlen+0x1f>
  8007ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b2:	75 f3                	jne    8007a7 <strnlen+0x10>
  8007b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ef                	jne    8007c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007df:	53                   	push   %ebx
  8007e0:	e8 9a ff ff ff       	call   80077f <strlen>
  8007e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c5 ff ff ff       	call   8007b8 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	89 f3                	mov    %esi,%ebx
  800807:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 0f                	jmp    80081d <strncpy+0x23>
		*dst++ = *src;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800817:	80 39 01             	cmpb   $0x1,(%ecx)
  80081a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	39 da                	cmp    %ebx,%edx
  80081f:	75 ed                	jne    80080e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	89 f0                	mov    %esi,%eax
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 55 10             	mov    0x10(%ebp),%edx
  800835:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800837:	85 d2                	test   %edx,%edx
  800839:	74 21                	je     80085c <strlcpy+0x35>
  80083b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083f:	89 f2                	mov    %esi,%edx
  800841:	eb 09                	jmp    80084c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 09                	je     800859 <strlcpy+0x32>
  800850:	0f b6 19             	movzbl (%ecx),%ebx
  800853:	84 db                	test   %bl,%bl
  800855:	75 ec                	jne    800843 <strlcpy+0x1c>
  800857:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085c:	29 f0                	sub    %esi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strcmp+0x11>
		p++, q++;
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 04                	je     80087e <strcmp+0x1c>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	74 ef                	je     80086d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 c3                	mov    %eax,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800897:	eb 06                	jmp    80089f <strncmp+0x17>
		n--, p++, q++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 15                	je     8008b8 <strncmp+0x30>
  8008a3:	0f b6 08             	movzbl (%eax),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	74 04                	je     8008ae <strncmp+0x26>
  8008aa:	3a 0a                	cmp    (%edx),%cl
  8008ac:	74 eb                	je     800899 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 00             	movzbl (%eax),%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
  8008b6:	eb 05                	jmp    8008bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 07                	jmp    8008d3 <strchr+0x13>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0f                	je     8008df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 10             	movzbl (%eax),%edx
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008eb:	eb 03                	jmp    8008f0 <strfind+0xf>
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	74 04                	je     8008fb <strfind+0x1a>
  8008f7:	38 ca                	cmp    %cl,%dl
  8008f9:	75 f2                	jne    8008ed <strfind+0xc>
			break;
	return (char *) s;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 36                	je     800943 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 28                	jne    80093d <memset+0x40>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 23                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d6                	mov    %edx,%esi
  800925:	c1 e6 18             	shl    $0x18,%esi
  800928:	89 d0                	mov    %edx,%eax
  80092a:	c1 e0 10             	shl    $0x10,%eax
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 c2                	or     %eax,%edx
  800931:	89 d0                	mov    %edx,%eax
  800933:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800935:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 06                	jmp    800943 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	fc                   	cld    
  800941:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800943:	89 f8                	mov    %edi,%eax
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 75 0c             	mov    0xc(%ebp),%esi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 35                	jae    800991 <memmove+0x47>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2e                	jae    800991 <memmove+0x47>
		s += n;
		d += n;
  800963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800966:	89 d6                	mov    %edx,%esi
  800968:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x3b>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0e                	jne    800985 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800977:	83 ef 04             	sub    $0x4,%edi
  80097a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800980:	fd                   	std    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 09                	jmp    80098e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 1d                	jmp    8009ae <memmove+0x64>
  800991:	89 f2                	mov    %esi,%edx
  800993:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0f                	jne    8009a9 <memmove+0x5f>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0a                	jne    8009a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 05                	jmp    8009ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 87 ff ff ff       	call   80094a <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c6                	mov    %eax,%esi
  8009d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	eb 1a                	jmp    8009f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	0f b6 1a             	movzbl (%edx),%ebx
  8009dd:	38 d9                	cmp    %bl,%cl
  8009df:	74 0a                	je     8009eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c1             	movzbl %cl,%eax
  8009e4:	0f b6 db             	movzbl %bl,%ebx
  8009e7:	29 d8                	sub    %ebx,%eax
  8009e9:	eb 0f                	jmp    8009fa <memcmp+0x35>
		s1++, s2++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	39 f0                	cmp    %esi,%eax
  8009f3:	75 e2                	jne    8009d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a07:	89 c2                	mov    %eax,%edx
  800a09:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0c:	eb 07                	jmp    800a15 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	38 08                	cmp    %cl,(%eax)
  800a10:	74 07                	je     800a19 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	39 d0                	cmp    %edx,%eax
  800a17:	72 f5                	jb     800a0e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a27:	eb 03                	jmp    800a2c <strtol+0x11>
		s++;
  800a29:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2c:	0f b6 01             	movzbl (%ecx),%eax
  800a2f:	3c 09                	cmp    $0x9,%al
  800a31:	74 f6                	je     800a29 <strtol+0xe>
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f2                	je     800a29 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a37:	3c 2b                	cmp    $0x2b,%al
  800a39:	75 0a                	jne    800a45 <strtol+0x2a>
		s++;
  800a3b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a43:	eb 10                	jmp    800a55 <strtol+0x3a>
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4a:	3c 2d                	cmp    $0x2d,%al
  800a4c:	75 07                	jne    800a55 <strtol+0x3a>
		s++, neg = 1;
  800a4e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a51:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	0f 94 c0             	sete   %al
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 19                	jne    800a7b <strtol+0x60>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 14                	jne    800a7b <strtol+0x60>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	0f 85 82 00 00 00    	jne    800af3 <strtol+0xd8>
		s += 2, base = 16;
  800a71:	83 c1 02             	add    $0x2,%ecx
  800a74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a79:	eb 16                	jmp    800a91 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a7b:	84 c0                	test   %al,%al
  800a7d:	74 12                	je     800a91 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 08                	jne    800a91 <strtol+0x76>
		s++, base = 8;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a99:	0f b6 11             	movzbl (%ecx),%edx
  800a9c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 09             	cmp    $0x9,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x93>
			dig = *s - '0';
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 30             	sub    $0x30,%edx
  800aac:	eb 22                	jmp    800ad0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 57             	sub    $0x57,%edx
  800abe:	eb 10                	jmp    800ad0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 16                	ja     800ae0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad3:	7d 0f                	jge    800ae4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ade:	eb b9                	jmp    800a99 <strtol+0x7e>
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	eb 02                	jmp    800ae6 <strtol+0xcb>
  800ae4:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 0d                	je     800af9 <strtol+0xde>
		*endptr = (char *) s;
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	89 0e                	mov    %ecx,(%esi)
  800af1:	eb 06                	jmp    800af9 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	84 c0                	test   %al,%al
  800af5:	75 92                	jne    800a89 <strtol+0x6e>
  800af7:	eb 98                	jmp    800a91 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af9:	f7 da                	neg    %edx
  800afb:	85 ff                	test   %edi,%edi
  800afd:	0f 45 c2             	cmovne %edx,%eax
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	89 c6                	mov    %eax,%esi
  800b1c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b50:	b8 03 00 00 00       	mov    $0x3,%eax
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	89 cb                	mov    %ecx,%ebx
  800b5a:	89 cf                	mov    %ecx,%edi
  800b5c:	89 ce                	mov    %ecx,%esi
  800b5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 03                	push   $0x3
  800b6a:	68 9f 25 80 00       	push   $0x80259f
  800b6f:	6a 23                	push   $0x23
  800b71:	68 bc 25 80 00       	push   $0x8025bc
  800b76:	e8 dd f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_yield>:

void
sys_yield(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	be 00 00 00 00       	mov    $0x0,%esi
  800bcf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	89 f7                	mov    %esi,%edi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 04                	push   $0x4
  800beb:	68 9f 25 80 00       	push   $0x80259f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 bc 25 80 00       	push   $0x8025bc
  800bf7:	e8 5c f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 05                	push   $0x5
  800c2d:	68 9f 25 80 00       	push   $0x80259f
  800c32:	6a 23                	push   $0x23
  800c34:	68 bc 25 80 00       	push   $0x8025bc
  800c39:	e8 1a f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 06 00 00 00       	mov    $0x6,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 06                	push   $0x6
  800c6f:	68 9f 25 80 00       	push   $0x80259f
  800c74:	6a 23                	push   $0x23
  800c76:	68 bc 25 80 00       	push   $0x8025bc
  800c7b:	e8 d8 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 08                	push   $0x8
  800cb1:	68 9f 25 80 00       	push   $0x80259f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 bc 25 80 00       	push   $0x8025bc
  800cbd:	e8 96 f4 ff ff       	call   800158 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 09                	push   $0x9
  800cf3:	68 9f 25 80 00       	push   $0x80259f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 bc 25 80 00       	push   $0x8025bc
  800cff:	e8 54 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 0a                	push   $0xa
  800d35:	68 9f 25 80 00       	push   $0x80259f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 bc 25 80 00       	push   $0x8025bc
  800d41:	e8 12 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	be 00 00 00 00       	mov    $0x0,%esi
  800d59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	89 cb                	mov    %ecx,%ebx
  800d89:	89 cf                	mov    %ecx,%edi
  800d8b:	89 ce                	mov    %ecx,%esi
  800d8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 17                	jle    800daa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 0d                	push   $0xd
  800d99:	68 9f 25 80 00       	push   $0x80259f
  800d9e:	6a 23                	push   $0x23
  800da0:	68 bc 25 80 00       	push   $0x8025bc
  800da5:	e8 ae f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	53                   	push   %ebx
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dbc:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800dbe:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dc2:	74 2e                	je     800df2 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800dc4:	89 c2                	mov    %eax,%edx
  800dc6:	c1 ea 16             	shr    $0x16,%edx
  800dc9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd0:	f6 c2 01             	test   $0x1,%dl
  800dd3:	74 1d                	je     800df2 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 0c             	shr    $0xc,%edx
  800dda:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800de1:	f6 c1 01             	test   $0x1,%cl
  800de4:	74 0c                	je     800df2 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800de6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ded:	f6 c6 08             	test   $0x8,%dh
  800df0:	75 14                	jne    800e06 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 cc 25 80 00       	push   $0x8025cc
  800dfa:	6a 21                	push   $0x21
  800dfc:	68 5f 26 80 00       	push   $0x80265f
  800e01:	e8 52 f3 ff ff       	call   800158 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0b:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	6a 07                	push   $0x7
  800e12:	68 00 f0 7f 00       	push   $0x7ff000
  800e17:	6a 00                	push   $0x0
  800e19:	e8 a3 fd ff ff       	call   800bc1 <sys_page_alloc>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	79 14                	jns    800e39 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	68 6a 26 80 00       	push   $0x80266a
  800e2d:	6a 2b                	push   $0x2b
  800e2f:	68 5f 26 80 00       	push   $0x80265f
  800e34:	e8 1f f3 ff ff       	call   800158 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 00 10 00 00       	push   $0x1000
  800e41:	53                   	push   %ebx
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	e8 fe fa ff ff       	call   80094a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e4c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e53:	53                   	push   %ebx
  800e54:	6a 00                	push   $0x0
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 a2 fd ff ff       	call   800c04 <sys_page_map>
  800e62:	83 c4 20             	add    $0x20,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 14                	jns    800e7d <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	68 80 26 80 00       	push   $0x802680
  800e71:	6a 2e                	push   $0x2e
  800e73:	68 5f 26 80 00       	push   $0x80265f
  800e78:	e8 db f2 ff ff       	call   800158 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 ba fd ff ff       	call   800c46 <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e9d:	68 b2 0d 80 00       	push   $0x800db2
  800ea2:	e8 11 10 00 00       	call   801eb8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ea7:	b8 07 00 00 00       	mov    $0x7,%eax
  800eac:	cd 30                	int    $0x30
  800eae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	79 12                	jns    800eca <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800eb8:	50                   	push   %eax
  800eb9:	68 94 26 80 00       	push   $0x802694
  800ebe:	6a 6d                	push   $0x6d
  800ec0:	68 5f 26 80 00       	push   $0x80265f
  800ec5:	e8 8e f2 ff ff       	call   800158 <_panic>
  800eca:	89 c7                	mov    %eax,%edi
  800ecc:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800ed1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ed5:	75 21                	jne    800ef8 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800ed7:	e8 a7 fc ff ff       	call   800b83 <sys_getenvid>
  800edc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee9:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	e9 9c 01 00 00       	jmp    801094 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	c1 e8 16             	shr    $0x16,%eax
  800efd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f04:	a8 01                	test   $0x1,%al
  800f06:	0f 84 f3 00 00 00    	je     800fff <fork+0x16b>
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	c1 e8 0c             	shr    $0xc,%eax
  800f11:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f18:	f6 c2 01             	test   $0x1,%dl
  800f1b:	0f 84 de 00 00 00    	je     800fff <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f21:	89 c6                	mov    %eax,%esi
  800f23:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f26:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2d:	f6 c6 04             	test   $0x4,%dh
  800f30:	74 37                	je     800f69 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	25 07 0e 00 00       	and    $0xe07,%eax
  800f41:	50                   	push   %eax
  800f42:	56                   	push   %esi
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	6a 00                	push   $0x0
  800f47:	e8 b8 fc ff ff       	call   800c04 <sys_page_map>
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	0f 89 a8 00 00 00    	jns    800fff <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800f57:	50                   	push   %eax
  800f58:	68 f0 25 80 00       	push   $0x8025f0
  800f5d:	6a 49                	push   $0x49
  800f5f:	68 5f 26 80 00       	push   $0x80265f
  800f64:	e8 ef f1 ff ff       	call   800158 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f69:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f70:	f6 c6 08             	test   $0x8,%dh
  800f73:	75 0b                	jne    800f80 <fork+0xec>
  800f75:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7c:	a8 02                	test   $0x2,%al
  800f7e:	74 57                	je     800fd7 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	68 05 08 00 00       	push   $0x805
  800f88:	56                   	push   %esi
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 72 fc ff ff       	call   800c04 <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 12                	jns    800fab <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800f99:	50                   	push   %eax
  800f9a:	68 f0 25 80 00       	push   $0x8025f0
  800f9f:	6a 4c                	push   $0x4c
  800fa1:	68 5f 26 80 00       	push   $0x80265f
  800fa6:	e8 ad f1 ff ff       	call   800158 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	68 05 08 00 00       	push   $0x805
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 46 fc ff ff       	call   800c04 <sys_page_map>
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	79 3a                	jns    800fff <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  800fc5:	50                   	push   %eax
  800fc6:	68 14 26 80 00       	push   $0x802614
  800fcb:	6a 4e                	push   $0x4e
  800fcd:	68 5f 26 80 00       	push   $0x80265f
  800fd2:	e8 81 f1 ff ff       	call   800158 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	6a 05                	push   $0x5
  800fdc:	56                   	push   %esi
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 1e fc ff ff       	call   800c04 <sys_page_map>
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	79 12                	jns    800fff <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  800fed:	50                   	push   %eax
  800fee:	68 3c 26 80 00       	push   $0x80263c
  800ff3:	6a 50                	push   $0x50
  800ff5:	68 5f 26 80 00       	push   $0x80265f
  800ffa:	e8 59 f1 ff ff       	call   800158 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800fff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801005:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80100b:	0f 85 e7 fe ff ff    	jne    800ef8 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	6a 07                	push   $0x7
  801016:	68 00 f0 bf ee       	push   $0xeebff000
  80101b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101e:	e8 9e fb ff ff       	call   800bc1 <sys_page_alloc>
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	79 14                	jns    80103e <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80102a:	83 ec 04             	sub    $0x4,%esp
  80102d:	68 a4 26 80 00       	push   $0x8026a4
  801032:	6a 76                	push   $0x76
  801034:	68 5f 26 80 00       	push   $0x80265f
  801039:	e8 1a f1 ff ff       	call   800158 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	68 27 1f 80 00       	push   $0x801f27
  801046:	ff 75 e4             	pushl  -0x1c(%ebp)
  801049:	e8 be fc ff ff       	call   800d0c <sys_env_set_pgfault_upcall>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	79 14                	jns    801069 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801055:	ff 75 e4             	pushl  -0x1c(%ebp)
  801058:	68 be 26 80 00       	push   $0x8026be
  80105d:	6a 79                	push   $0x79
  80105f:	68 5f 26 80 00       	push   $0x80265f
  801064:	e8 ef f0 ff ff       	call   800158 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	6a 02                	push   $0x2
  80106e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801071:	e8 12 fc ff ff       	call   800c88 <sys_env_set_status>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	79 14                	jns    801091 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80107d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801080:	68 db 26 80 00       	push   $0x8026db
  801085:	6a 7b                	push   $0x7b
  801087:	68 5f 26 80 00       	push   $0x80265f
  80108c:	e8 c7 f0 ff ff       	call   800158 <_panic>
        return forkid;
  801091:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <sfork>:

// Challenge!
int
sfork(void)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a2:	68 f2 26 80 00       	push   $0x8026f2
  8010a7:	68 83 00 00 00       	push   $0x83
  8010ac:	68 5f 26 80 00       	push   $0x80265f
  8010b1:	e8 a2 f0 ff ff       	call   800158 <_panic>

008010b6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
  8010bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8010be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010cb:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	50                   	push   %eax
  8010d2:	e8 9a fc ff ff       	call   800d71 <sys_ipc_recv>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 16                	jns    8010f4 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8010de:	85 f6                	test   %esi,%esi
  8010e0:	74 06                	je     8010e8 <ipc_recv+0x32>
  8010e2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8010e8:	85 db                	test   %ebx,%ebx
  8010ea:	74 2c                	je     801118 <ipc_recv+0x62>
  8010ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f2:	eb 24                	jmp    801118 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8010f4:	85 f6                	test   %esi,%esi
  8010f6:	74 0a                	je     801102 <ipc_recv+0x4c>
  8010f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fd:	8b 40 74             	mov    0x74(%eax),%eax
  801100:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801102:	85 db                	test   %ebx,%ebx
  801104:	74 0a                	je     801110 <ipc_recv+0x5a>
  801106:	a1 04 40 80 00       	mov    0x804004,%eax
  80110b:	8b 40 78             	mov    0x78(%eax),%eax
  80110e:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801110:	a1 04 40 80 00       	mov    0x804004,%eax
  801115:	8b 40 70             	mov    0x70(%eax),%eax
}
  801118:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80112e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801131:	85 db                	test   %ebx,%ebx
  801133:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801138:	0f 44 d8             	cmove  %eax,%ebx
  80113b:	eb 1c                	jmp    801159 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80113d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801140:	74 12                	je     801154 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801142:	50                   	push   %eax
  801143:	68 08 27 80 00       	push   $0x802708
  801148:	6a 39                	push   $0x39
  80114a:	68 23 27 80 00       	push   $0x802723
  80114f:	e8 04 f0 ff ff       	call   800158 <_panic>
                 sys_yield();
  801154:	e8 49 fa ff ff       	call   800ba2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801159:	ff 75 14             	pushl  0x14(%ebp)
  80115c:	53                   	push   %ebx
  80115d:	56                   	push   %esi
  80115e:	57                   	push   %edi
  80115f:	e8 ea fb ff ff       	call   800d4e <sys_ipc_try_send>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 d2                	js     80113d <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80117e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801181:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801187:	8b 52 50             	mov    0x50(%edx),%edx
  80118a:	39 ca                	cmp    %ecx,%edx
  80118c:	75 0d                	jne    80119b <ipc_find_env+0x28>
			return envs[i].env_id;
  80118e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801191:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801196:	8b 40 08             	mov    0x8(%eax),%eax
  801199:	eb 0e                	jmp    8011a9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80119b:	83 c0 01             	add    $0x1,%eax
  80119e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011a3:	75 d9                	jne    80117e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011a5:	66 b8 00 00          	mov    $0x0,%ax
}
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 ea 16             	shr    $0x16,%edx
  8011e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	74 11                	je     8011ff <fd_alloc+0x2d>
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	c1 ea 0c             	shr    $0xc,%edx
  8011f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fa:	f6 c2 01             	test   $0x1,%dl
  8011fd:	75 09                	jne    801208 <fd_alloc+0x36>
			*fd_store = fd;
  8011ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801201:	b8 00 00 00 00       	mov    $0x0,%eax
  801206:	eb 17                	jmp    80121f <fd_alloc+0x4d>
  801208:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80120d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801212:	75 c9                	jne    8011dd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801214:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80121a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801227:	83 f8 1f             	cmp    $0x1f,%eax
  80122a:	77 36                	ja     801262 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122c:	c1 e0 0c             	shl    $0xc,%eax
  80122f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801234:	89 c2                	mov    %eax,%edx
  801236:	c1 ea 16             	shr    $0x16,%edx
  801239:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801240:	f6 c2 01             	test   $0x1,%dl
  801243:	74 24                	je     801269 <fd_lookup+0x48>
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 0c             	shr    $0xc,%edx
  80124a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 1a                	je     801270 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801256:	8b 55 0c             	mov    0xc(%ebp),%edx
  801259:	89 02                	mov    %eax,(%edx)
	return 0;
  80125b:	b8 00 00 00 00       	mov    $0x0,%eax
  801260:	eb 13                	jmp    801275 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801267:	eb 0c                	jmp    801275 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb 05                	jmp    801275 <fd_lookup+0x54>
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801280:	ba ac 27 80 00       	mov    $0x8027ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801285:	eb 13                	jmp    80129a <dev_lookup+0x23>
  801287:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80128a:	39 08                	cmp    %ecx,(%eax)
  80128c:	75 0c                	jne    80129a <dev_lookup+0x23>
			*dev = devtab[i];
  80128e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801291:	89 01                	mov    %eax,(%ecx)
			return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
  801298:	eb 2e                	jmp    8012c8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80129a:	8b 02                	mov    (%edx),%eax
  80129c:	85 c0                	test   %eax,%eax
  80129e:	75 e7                	jne    801287 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a5:	8b 40 48             	mov    0x48(%eax),%eax
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	51                   	push   %ecx
  8012ac:	50                   	push   %eax
  8012ad:	68 30 27 80 00       	push   $0x802730
  8012b2:	e8 7a ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  8012b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 10             	sub    $0x10,%esp
  8012d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012db:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012dc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e2:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e5:	50                   	push   %eax
  8012e6:	e8 36 ff ff ff       	call   801221 <fd_lookup>
  8012eb:	83 c4 08             	add    $0x8,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 05                	js     8012f7 <fd_close+0x2d>
	    || fd != fd2)
  8012f2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f5:	74 0c                	je     801303 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012f7:	84 db                	test   %bl,%bl
  8012f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fe:	0f 44 c2             	cmove  %edx,%eax
  801301:	eb 41                	jmp    801344 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 36                	pushl  (%esi)
  80130c:	e8 66 ff ff ff       	call   801277 <dev_lookup>
  801311:	89 c3                	mov    %eax,%ebx
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 1a                	js     801334 <fd_close+0x6a>
		if (dev->dev_close)
  80131a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801320:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801325:	85 c0                	test   %eax,%eax
  801327:	74 0b                	je     801334 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	56                   	push   %esi
  80132d:	ff d0                	call   *%eax
  80132f:	89 c3                	mov    %eax,%ebx
  801331:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	56                   	push   %esi
  801338:	6a 00                	push   $0x0
  80133a:	e8 07 f9 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 d8                	mov    %ebx,%eax
}
  801344:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 c4 fe ff ff       	call   801221 <fd_lookup>
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	85 d2                	test   %edx,%edx
  801364:	78 10                	js     801376 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	6a 01                	push   $0x1
  80136b:	ff 75 f4             	pushl  -0xc(%ebp)
  80136e:	e8 57 ff ff ff       	call   8012ca <fd_close>
  801373:	83 c4 10             	add    $0x10,%esp
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <close_all>:

void
close_all(void)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	53                   	push   %ebx
  801388:	e8 be ff ff ff       	call   80134b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80138d:	83 c3 01             	add    $0x1,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	83 fb 20             	cmp    $0x20,%ebx
  801396:	75 ec                	jne    801384 <close_all+0xc>
		close(i);
}
  801398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 2c             	sub    $0x2c,%esp
  8013a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 6c fe ff ff       	call   801221 <fd_lookup>
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	83 c4 08             	add    $0x8,%esp
  8013ba:	85 d2                	test   %edx,%edx
  8013bc:	0f 88 c1 00 00 00    	js     801483 <dup+0xe6>
		return r;
	close(newfdnum);
  8013c2:	83 ec 0c             	sub    $0xc,%esp
  8013c5:	56                   	push   %esi
  8013c6:	e8 80 ff ff ff       	call   80134b <close>

	newfd = INDEX2FD(newfdnum);
  8013cb:	89 f3                	mov    %esi,%ebx
  8013cd:	c1 e3 0c             	shl    $0xc,%ebx
  8013d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d6:	83 c4 04             	add    $0x4,%esp
  8013d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013dc:	e8 da fd ff ff       	call   8011bb <fd2data>
  8013e1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 d0 fd ff ff       	call   8011bb <fd2data>
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f1:	89 f8                	mov    %edi,%eax
  8013f3:	c1 e8 16             	shr    $0x16,%eax
  8013f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fd:	a8 01                	test   $0x1,%al
  8013ff:	74 37                	je     801438 <dup+0x9b>
  801401:	89 f8                	mov    %edi,%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
  801406:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140d:	f6 c2 01             	test   $0x1,%dl
  801410:	74 26                	je     801438 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801412:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	25 07 0e 00 00       	and    $0xe07,%eax
  801421:	50                   	push   %eax
  801422:	ff 75 d4             	pushl  -0x2c(%ebp)
  801425:	6a 00                	push   $0x0
  801427:	57                   	push   %edi
  801428:	6a 00                	push   $0x0
  80142a:	e8 d5 f7 ff ff       	call   800c04 <sys_page_map>
  80142f:	89 c7                	mov    %eax,%edi
  801431:	83 c4 20             	add    $0x20,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 2e                	js     801466 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801438:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80143b:	89 d0                	mov    %edx,%eax
  80143d:	c1 e8 0c             	shr    $0xc,%eax
  801440:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	25 07 0e 00 00       	and    $0xe07,%eax
  80144f:	50                   	push   %eax
  801450:	53                   	push   %ebx
  801451:	6a 00                	push   $0x0
  801453:	52                   	push   %edx
  801454:	6a 00                	push   $0x0
  801456:	e8 a9 f7 ff ff       	call   800c04 <sys_page_map>
  80145b:	89 c7                	mov    %eax,%edi
  80145d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801460:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801462:	85 ff                	test   %edi,%edi
  801464:	79 1d                	jns    801483 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	53                   	push   %ebx
  80146a:	6a 00                	push   $0x0
  80146c:	e8 d5 f7 ff ff       	call   800c46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801471:	83 c4 08             	add    $0x8,%esp
  801474:	ff 75 d4             	pushl  -0x2c(%ebp)
  801477:	6a 00                	push   $0x0
  801479:	e8 c8 f7 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	89 f8                	mov    %edi,%eax
}
  801483:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	83 ec 14             	sub    $0x14,%esp
  801492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801495:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	53                   	push   %ebx
  80149a:	e8 82 fd ff ff       	call   801221 <fd_lookup>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 6d                	js     801515 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	ff 30                	pushl  (%eax)
  8014b4:	e8 be fd ff ff       	call   801277 <dev_lookup>
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 4c                	js     80150c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c3:	8b 42 08             	mov    0x8(%edx),%eax
  8014c6:	83 e0 03             	and    $0x3,%eax
  8014c9:	83 f8 01             	cmp    $0x1,%eax
  8014cc:	75 21                	jne    8014ef <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d3:	8b 40 48             	mov    0x48(%eax),%eax
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	53                   	push   %ebx
  8014da:	50                   	push   %eax
  8014db:	68 71 27 80 00       	push   $0x802771
  8014e0:	e8 4c ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ed:	eb 26                	jmp    801515 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f2:	8b 40 08             	mov    0x8(%eax),%eax
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	74 17                	je     801510 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	ff 75 10             	pushl  0x10(%ebp)
  8014ff:	ff 75 0c             	pushl  0xc(%ebp)
  801502:	52                   	push   %edx
  801503:	ff d0                	call   *%eax
  801505:	89 c2                	mov    %eax,%edx
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	eb 09                	jmp    801515 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	eb 05                	jmp    801515 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801510:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801515:	89 d0                	mov    %edx,%eax
  801517:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151a:	c9                   	leave  
  80151b:	c3                   	ret    

0080151c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	57                   	push   %edi
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 0c             	sub    $0xc,%esp
  801525:	8b 7d 08             	mov    0x8(%ebp),%edi
  801528:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801530:	eb 21                	jmp    801553 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	89 f0                	mov    %esi,%eax
  801537:	29 d8                	sub    %ebx,%eax
  801539:	50                   	push   %eax
  80153a:	89 d8                	mov    %ebx,%eax
  80153c:	03 45 0c             	add    0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	57                   	push   %edi
  801541:	e8 45 ff ff ff       	call   80148b <read>
		if (m < 0)
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 0c                	js     801559 <readn+0x3d>
			return m;
		if (m == 0)
  80154d:	85 c0                	test   %eax,%eax
  80154f:	74 06                	je     801557 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801551:	01 c3                	add    %eax,%ebx
  801553:	39 f3                	cmp    %esi,%ebx
  801555:	72 db                	jb     801532 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801557:	89 d8                	mov    %ebx,%eax
}
  801559:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	53                   	push   %ebx
  801565:	83 ec 14             	sub    $0x14,%esp
  801568:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	53                   	push   %ebx
  801570:	e8 ac fc ff ff       	call   801221 <fd_lookup>
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	89 c2                	mov    %eax,%edx
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 68                	js     8015e6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801588:	ff 30                	pushl  (%eax)
  80158a:	e8 e8 fc ff ff       	call   801277 <dev_lookup>
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 47                	js     8015dd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801599:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159d:	75 21                	jne    8015c0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80159f:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a4:	8b 40 48             	mov    0x48(%eax),%eax
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	50                   	push   %eax
  8015ac:	68 8d 27 80 00       	push   $0x80278d
  8015b1:	e8 7b ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015be:	eb 26                	jmp    8015e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c6:	85 d2                	test   %edx,%edx
  8015c8:	74 17                	je     8015e1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	ff 75 10             	pushl  0x10(%ebp)
  8015d0:	ff 75 0c             	pushl  0xc(%ebp)
  8015d3:	50                   	push   %eax
  8015d4:	ff d2                	call   *%edx
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb 09                	jmp    8015e6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	eb 05                	jmp    8015e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015e6:	89 d0                	mov    %edx,%eax
  8015e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	ff 75 08             	pushl  0x8(%ebp)
  8015fa:	e8 22 fc ff ff       	call   801221 <fd_lookup>
  8015ff:	83 c4 08             	add    $0x8,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 0e                	js     801614 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801606:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801609:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80160f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 14             	sub    $0x14,%esp
  80161d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801620:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	53                   	push   %ebx
  801625:	e8 f7 fb ff ff       	call   801221 <fd_lookup>
  80162a:	83 c4 08             	add    $0x8,%esp
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 65                	js     801698 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	ff 30                	pushl  (%eax)
  80163f:	e8 33 fc ff ff       	call   801277 <dev_lookup>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 44                	js     80168f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801652:	75 21                	jne    801675 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801654:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801659:	8b 40 48             	mov    0x48(%eax),%eax
  80165c:	83 ec 04             	sub    $0x4,%esp
  80165f:	53                   	push   %ebx
  801660:	50                   	push   %eax
  801661:	68 50 27 80 00       	push   $0x802750
  801666:	e8 c6 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801673:	eb 23                	jmp    801698 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801675:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801678:	8b 52 18             	mov    0x18(%edx),%edx
  80167b:	85 d2                	test   %edx,%edx
  80167d:	74 14                	je     801693 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	ff 75 0c             	pushl  0xc(%ebp)
  801685:	50                   	push   %eax
  801686:	ff d2                	call   *%edx
  801688:	89 c2                	mov    %eax,%edx
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	eb 09                	jmp    801698 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168f:	89 c2                	mov    %eax,%edx
  801691:	eb 05                	jmp    801698 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801693:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801698:	89 d0                	mov    %edx,%eax
  80169a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 14             	sub    $0x14,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 6c fb ff ff       	call   801221 <fd_lookup>
  8016b5:	83 c4 08             	add    $0x8,%esp
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 58                	js     801716 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c8:	ff 30                	pushl  (%eax)
  8016ca:	e8 a8 fb ff ff       	call   801277 <dev_lookup>
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 37                	js     80170d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016dd:	74 32                	je     801711 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016df:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e9:	00 00 00 
	stat->st_isdir = 0;
  8016ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f3:	00 00 00 
	stat->st_dev = dev;
  8016f6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	53                   	push   %ebx
  801700:	ff 75 f0             	pushl  -0x10(%ebp)
  801703:	ff 50 14             	call   *0x14(%eax)
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 09                	jmp    801716 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	eb 05                	jmp    801716 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801716:	89 d0                	mov    %edx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	6a 00                	push   $0x0
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 09 02 00 00       	call   801938 <open>
  80172f:	89 c3                	mov    %eax,%ebx
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 db                	test   %ebx,%ebx
  801736:	78 1b                	js     801753 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	53                   	push   %ebx
  80173f:	e8 5b ff ff ff       	call   80169f <fstat>
  801744:	89 c6                	mov    %eax,%esi
	close(fd);
  801746:	89 1c 24             	mov    %ebx,(%esp)
  801749:	e8 fd fb ff ff       	call   80134b <close>
	return r;
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	89 f0                	mov    %esi,%eax
}
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	89 c6                	mov    %eax,%esi
  801761:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801763:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80176a:	75 12                	jne    80177e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	6a 01                	push   $0x1
  801771:	e8 fd f9 ff ff       	call   801173 <ipc_find_env>
  801776:	a3 00 40 80 00       	mov    %eax,0x804000
  80177b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177e:	6a 07                	push   $0x7
  801780:	68 00 50 80 00       	push   $0x805000
  801785:	56                   	push   %esi
  801786:	ff 35 00 40 80 00    	pushl  0x804000
  80178c:	e8 8e f9 ff ff       	call   80111f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801791:	83 c4 0c             	add    $0xc,%esp
  801794:	6a 00                	push   $0x0
  801796:	53                   	push   %ebx
  801797:	6a 00                	push   $0x0
  801799:	e8 18 f9 ff ff       	call   8010b6 <ipc_recv>
}
  80179e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c8:	e8 8d ff ff ff       	call   80175a <fsipc>
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017db:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ea:	e8 6b ff ff ff       	call   80175a <fsipc>
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 04             	sub    $0x4,%esp
  8017f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	b8 05 00 00 00       	mov    $0x5,%eax
  801810:	e8 45 ff ff ff       	call   80175a <fsipc>
  801815:	89 c2                	mov    %eax,%edx
  801817:	85 d2                	test   %edx,%edx
  801819:	78 2c                	js     801847 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	68 00 50 80 00       	push   $0x805000
  801823:	53                   	push   %ebx
  801824:	e8 8f ef ff ff       	call   8007b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801829:	a1 80 50 80 00       	mov    0x805080,%eax
  80182e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801834:	a1 84 50 80 00       	mov    0x805084,%eax
  801839:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	57                   	push   %edi
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 40 0c             	mov    0xc(%eax),%eax
  80185e:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801863:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801866:	eb 3d                	jmp    8018a5 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801868:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80186e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801873:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	57                   	push   %edi
  80187a:	53                   	push   %ebx
  80187b:	68 08 50 80 00       	push   $0x805008
  801880:	e8 c5 f0 ff ff       	call   80094a <memmove>
                fsipcbuf.write.req_n = tmp; 
  801885:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 04 00 00 00       	mov    $0x4,%eax
  801895:	e8 c0 fe ff ff       	call   80175a <fsipc>
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 0d                	js     8018ae <devfile_write+0x62>
		        return r;
                n -= tmp;
  8018a1:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8018a3:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018a5:	85 f6                	test   %esi,%esi
  8018a7:	75 bf                	jne    801868 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8018a9:	89 d8                	mov    %ebx,%eax
  8018ab:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8018ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	56                   	push   %esi
  8018ba:	53                   	push   %ebx
  8018bb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d9:	e8 7c fe ff ff       	call   80175a <fsipc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 4b                	js     80192f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e4:	39 c6                	cmp    %eax,%esi
  8018e6:	73 16                	jae    8018fe <devfile_read+0x48>
  8018e8:	68 bc 27 80 00       	push   $0x8027bc
  8018ed:	68 c3 27 80 00       	push   $0x8027c3
  8018f2:	6a 7c                	push   $0x7c
  8018f4:	68 d8 27 80 00       	push   $0x8027d8
  8018f9:	e8 5a e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8018fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801903:	7e 16                	jle    80191b <devfile_read+0x65>
  801905:	68 e3 27 80 00       	push   $0x8027e3
  80190a:	68 c3 27 80 00       	push   $0x8027c3
  80190f:	6a 7d                	push   $0x7d
  801911:	68 d8 27 80 00       	push   $0x8027d8
  801916:	e8 3d e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	50                   	push   %eax
  80191f:	68 00 50 80 00       	push   $0x805000
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	e8 1e f0 ff ff       	call   80094a <memmove>
	return r;
  80192c:	83 c4 10             	add    $0x10,%esp
}
  80192f:	89 d8                	mov    %ebx,%eax
  801931:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	53                   	push   %ebx
  80193c:	83 ec 20             	sub    $0x20,%esp
  80193f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801942:	53                   	push   %ebx
  801943:	e8 37 ee ff ff       	call   80077f <strlen>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801950:	7f 67                	jg     8019b9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801958:	50                   	push   %eax
  801959:	e8 74 f8 ff ff       	call   8011d2 <fd_alloc>
  80195e:	83 c4 10             	add    $0x10,%esp
		return r;
  801961:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801963:	85 c0                	test   %eax,%eax
  801965:	78 57                	js     8019be <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	53                   	push   %ebx
  80196b:	68 00 50 80 00       	push   $0x805000
  801970:	e8 43 ee ff ff       	call   8007b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801975:	8b 45 0c             	mov    0xc(%ebp),%eax
  801978:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801980:	b8 01 00 00 00       	mov    $0x1,%eax
  801985:	e8 d0 fd ff ff       	call   80175a <fsipc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	79 14                	jns    8019a7 <open+0x6f>
		fd_close(fd, 0);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	6a 00                	push   $0x0
  801998:	ff 75 f4             	pushl  -0xc(%ebp)
  80199b:	e8 2a f9 ff ff       	call   8012ca <fd_close>
		return r;
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	89 da                	mov    %ebx,%edx
  8019a5:	eb 17                	jmp    8019be <open+0x86>
	}

	return fd2num(fd);
  8019a7:	83 ec 0c             	sub    $0xc,%esp
  8019aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ad:	e8 f9 f7 ff ff       	call   8011ab <fd2num>
  8019b2:	89 c2                	mov    %eax,%edx
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	eb 05                	jmp    8019be <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019be:	89 d0                	mov    %edx,%eax
  8019c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d5:	e8 80 fd ff ff       	call   80175a <fsipc>
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	ff 75 08             	pushl  0x8(%ebp)
  8019ea:	e8 cc f7 ff ff       	call   8011bb <fd2data>
  8019ef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	68 ef 27 80 00       	push   $0x8027ef
  8019f9:	53                   	push   %ebx
  8019fa:	e8 b9 ed ff ff       	call   8007b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ff:	8b 56 04             	mov    0x4(%esi),%edx
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	2b 06                	sub    (%esi),%eax
  801a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a13:	00 00 00 
	stat->st_dev = &devpipe;
  801a16:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a1d:	30 80 00 
	return 0;
}
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
  801a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5e                   	pop    %esi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	53                   	push   %ebx
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a36:	53                   	push   %ebx
  801a37:	6a 00                	push   $0x0
  801a39:	e8 08 f2 ff ff       	call   800c46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a3e:	89 1c 24             	mov    %ebx,(%esp)
  801a41:	e8 75 f7 ff ff       	call   8011bb <fd2data>
  801a46:	83 c4 08             	add    $0x8,%esp
  801a49:	50                   	push   %eax
  801a4a:	6a 00                	push   $0x0
  801a4c:	e8 f5 f1 ff ff       	call   800c46 <sys_page_unmap>
}
  801a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	57                   	push   %edi
  801a5a:	56                   	push   %esi
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 1c             	sub    $0x1c,%esp
  801a5f:	89 c6                	mov    %eax,%esi
  801a61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a64:	a1 04 40 80 00       	mov    0x804004,%eax
  801a69:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	56                   	push   %esi
  801a70:	e8 d6 04 00 00       	call   801f4b <pageref>
  801a75:	89 c7                	mov    %eax,%edi
  801a77:	83 c4 04             	add    $0x4,%esp
  801a7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a7d:	e8 c9 04 00 00       	call   801f4b <pageref>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	39 c7                	cmp    %eax,%edi
  801a87:	0f 94 c2             	sete   %dl
  801a8a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a8d:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a93:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a96:	39 fb                	cmp    %edi,%ebx
  801a98:	74 19                	je     801ab3 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801a9a:	84 d2                	test   %dl,%dl
  801a9c:	74 c6                	je     801a64 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9e:	8b 51 58             	mov    0x58(%ecx),%edx
  801aa1:	50                   	push   %eax
  801aa2:	52                   	push   %edx
  801aa3:	53                   	push   %ebx
  801aa4:	68 f6 27 80 00       	push   $0x8027f6
  801aa9:	e8 83 e7 ff ff       	call   800231 <cprintf>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	eb b1                	jmp    801a64 <_pipeisclosed+0xe>
	}
}
  801ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5f                   	pop    %edi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 28             	sub    $0x28,%esp
  801ac4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ac7:	56                   	push   %esi
  801ac8:	e8 ee f6 ff ff       	call   8011bb <fd2data>
  801acd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad7:	eb 4b                	jmp    801b24 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad9:	89 da                	mov    %ebx,%edx
  801adb:	89 f0                	mov    %esi,%eax
  801add:	e8 74 ff ff ff       	call   801a56 <_pipeisclosed>
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	75 48                	jne    801b2e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae6:	e8 b7 f0 ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aeb:	8b 43 04             	mov    0x4(%ebx),%eax
  801aee:	8b 0b                	mov    (%ebx),%ecx
  801af0:	8d 51 20             	lea    0x20(%ecx),%edx
  801af3:	39 d0                	cmp    %edx,%eax
  801af5:	73 e2                	jae    801ad9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801afe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	c1 fa 1f             	sar    $0x1f,%edx
  801b06:	89 d1                	mov    %edx,%ecx
  801b08:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b0e:	83 e2 1f             	and    $0x1f,%edx
  801b11:	29 ca                	sub    %ecx,%edx
  801b13:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b17:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1b:	83 c0 01             	add    $0x1,%eax
  801b1e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b21:	83 c7 01             	add    $0x1,%edi
  801b24:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b27:	75 c2                	jne    801aeb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b29:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2c:	eb 05                	jmp    801b33 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b36:	5b                   	pop    %ebx
  801b37:	5e                   	pop    %esi
  801b38:	5f                   	pop    %edi
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	57                   	push   %edi
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	83 ec 18             	sub    $0x18,%esp
  801b44:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b47:	57                   	push   %edi
  801b48:	e8 6e f6 ff ff       	call   8011bb <fd2data>
  801b4d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b57:	eb 3d                	jmp    801b96 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b59:	85 db                	test   %ebx,%ebx
  801b5b:	74 04                	je     801b61 <devpipe_read+0x26>
				return i;
  801b5d:	89 d8                	mov    %ebx,%eax
  801b5f:	eb 44                	jmp    801ba5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b61:	89 f2                	mov    %esi,%edx
  801b63:	89 f8                	mov    %edi,%eax
  801b65:	e8 ec fe ff ff       	call   801a56 <_pipeisclosed>
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	75 32                	jne    801ba0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b6e:	e8 2f f0 ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b73:	8b 06                	mov    (%esi),%eax
  801b75:	3b 46 04             	cmp    0x4(%esi),%eax
  801b78:	74 df                	je     801b59 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7a:	99                   	cltd   
  801b7b:	c1 ea 1b             	shr    $0x1b,%edx
  801b7e:	01 d0                	add    %edx,%eax
  801b80:	83 e0 1f             	and    $0x1f,%eax
  801b83:	29 d0                	sub    %edx,%eax
  801b85:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b90:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b93:	83 c3 01             	add    $0x1,%ebx
  801b96:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b99:	75 d8                	jne    801b73 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9e:	eb 05                	jmp    801ba5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5f                   	pop    %edi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb8:	50                   	push   %eax
  801bb9:	e8 14 f6 ff ff       	call   8011d2 <fd_alloc>
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	0f 88 2c 01 00 00    	js     801cf7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcb:	83 ec 04             	sub    $0x4,%esp
  801bce:	68 07 04 00 00       	push   $0x407
  801bd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 e4 ef ff ff       	call   800bc1 <sys_page_alloc>
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	89 c2                	mov    %eax,%edx
  801be2:	85 c0                	test   %eax,%eax
  801be4:	0f 88 0d 01 00 00    	js     801cf7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf0:	50                   	push   %eax
  801bf1:	e8 dc f5 ff ff       	call   8011d2 <fd_alloc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	0f 88 e2 00 00 00    	js     801ce5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c03:	83 ec 04             	sub    $0x4,%esp
  801c06:	68 07 04 00 00       	push   $0x407
  801c0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0e:	6a 00                	push   $0x0
  801c10:	e8 ac ef ff ff       	call   800bc1 <sys_page_alloc>
  801c15:	89 c3                	mov    %eax,%ebx
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	0f 88 c3 00 00 00    	js     801ce5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	ff 75 f4             	pushl  -0xc(%ebp)
  801c28:	e8 8e f5 ff ff       	call   8011bb <fd2data>
  801c2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2f:	83 c4 0c             	add    $0xc,%esp
  801c32:	68 07 04 00 00       	push   $0x407
  801c37:	50                   	push   %eax
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 82 ef ff ff       	call   800bc1 <sys_page_alloc>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	0f 88 89 00 00 00    	js     801cd5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c52:	e8 64 f5 ff ff       	call   8011bb <fd2data>
  801c57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	56                   	push   %esi
  801c62:	6a 00                	push   $0x0
  801c64:	e8 9b ef ff ff       	call   800c04 <sys_page_map>
  801c69:	89 c3                	mov    %eax,%ebx
  801c6b:	83 c4 20             	add    $0x20,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	78 55                	js     801cc7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c72:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c90:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	e8 04 f5 ff ff       	call   8011ab <fd2num>
  801ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801caa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cac:	83 c4 04             	add    $0x4,%esp
  801caf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb2:	e8 f4 f4 ff ff       	call   8011ab <fd2num>
  801cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc5:	eb 30                	jmp    801cf7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cc7:	83 ec 08             	sub    $0x8,%esp
  801cca:	56                   	push   %esi
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 74 ef ff ff       	call   800c46 <sys_page_unmap>
  801cd2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 64 ef ff ff       	call   800c46 <sys_page_unmap>
  801ce2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce5:	83 ec 08             	sub    $0x8,%esp
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 54 ef ff ff       	call   800c46 <sys_page_unmap>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cf7:	89 d0                	mov    %edx,%eax
  801cf9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d09:	50                   	push   %eax
  801d0a:	ff 75 08             	pushl  0x8(%ebp)
  801d0d:	e8 0f f5 ff ff       	call   801221 <fd_lookup>
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	85 d2                	test   %edx,%edx
  801d19:	78 18                	js     801d33 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d21:	e8 95 f4 ff ff       	call   8011bb <fd2data>
	return _pipeisclosed(fd, p);
  801d26:	89 c2                	mov    %eax,%edx
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	e8 26 fd ff ff       	call   801a56 <_pipeisclosed>
  801d30:	83 c4 10             	add    $0x10,%esp
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    

00801d3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d45:	68 0e 28 80 00       	push   $0x80280e
  801d4a:	ff 75 0c             	pushl  0xc(%ebp)
  801d4d:	e8 66 ea ff ff       	call   8007b8 <strcpy>
	return 0;
}
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	57                   	push   %edi
  801d5d:	56                   	push   %esi
  801d5e:	53                   	push   %ebx
  801d5f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d65:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d70:	eb 2d                	jmp    801d9f <devcons_write+0x46>
		m = n - tot;
  801d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d75:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d77:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d7a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d7f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d82:	83 ec 04             	sub    $0x4,%esp
  801d85:	53                   	push   %ebx
  801d86:	03 45 0c             	add    0xc(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	57                   	push   %edi
  801d8b:	e8 ba eb ff ff       	call   80094a <memmove>
		sys_cputs(buf, m);
  801d90:	83 c4 08             	add    $0x8,%esp
  801d93:	53                   	push   %ebx
  801d94:	57                   	push   %edi
  801d95:	e8 6b ed ff ff       	call   800b05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9a:	01 de                	add    %ebx,%esi
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da4:	72 cc                	jb     801d72 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5f                   	pop    %edi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801db4:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801db9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dbd:	75 07                	jne    801dc6 <devcons_read+0x18>
  801dbf:	eb 28                	jmp    801de9 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc1:	e8 dc ed ff ff       	call   800ba2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dc6:	e8 58 ed ff ff       	call   800b23 <sys_cgetc>
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	74 f2                	je     801dc1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 16                	js     801de9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dd3:	83 f8 04             	cmp    $0x4,%eax
  801dd6:	74 0c                	je     801de4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddb:	88 02                	mov    %al,(%edx)
	return 1;
  801ddd:	b8 01 00 00 00       	mov    $0x1,%eax
  801de2:	eb 05                	jmp    801de9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801df1:	8b 45 08             	mov    0x8(%ebp),%eax
  801df4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df7:	6a 01                	push   $0x1
  801df9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	e8 03 ed ff ff       	call   800b05 <sys_cputs>
  801e02:	83 c4 10             	add    $0x10,%esp
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <getchar>:

int
getchar(void)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e0d:	6a 01                	push   $0x1
  801e0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e12:	50                   	push   %eax
  801e13:	6a 00                	push   $0x0
  801e15:	e8 71 f6 ff ff       	call   80148b <read>
	if (r < 0)
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 0f                	js     801e30 <getchar+0x29>
		return r;
	if (r < 1)
  801e21:	85 c0                	test   %eax,%eax
  801e23:	7e 06                	jle    801e2b <getchar+0x24>
		return -E_EOF;
	return c;
  801e25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e29:	eb 05                	jmp    801e30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	ff 75 08             	pushl  0x8(%ebp)
  801e3f:	e8 dd f3 ff ff       	call   801221 <fd_lookup>
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 11                	js     801e5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e54:	39 10                	cmp    %edx,(%eax)
  801e56:	0f 94 c0             	sete   %al
  801e59:	0f b6 c0             	movzbl %al,%eax
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <opencons>:

int
opencons(void)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e67:	50                   	push   %eax
  801e68:	e8 65 f3 ff ff       	call   8011d2 <fd_alloc>
  801e6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e70:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e72:	85 c0                	test   %eax,%eax
  801e74:	78 3e                	js     801eb4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	68 07 04 00 00       	push   $0x407
  801e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e81:	6a 00                	push   $0x0
  801e83:	e8 39 ed ff ff       	call   800bc1 <sys_page_alloc>
  801e88:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 23                	js     801eb4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	50                   	push   %eax
  801eaa:	e8 fc f2 ff ff       	call   8011ab <fd2num>
  801eaf:	89 c2                	mov    %eax,%edx
  801eb1:	83 c4 10             	add    $0x10,%esp
}
  801eb4:	89 d0                	mov    %edx,%eax
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ebe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ec5:	75 2c                	jne    801ef3 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801ec7:	83 ec 04             	sub    $0x4,%esp
  801eca:	6a 07                	push   $0x7
  801ecc:	68 00 f0 bf ee       	push   $0xeebff000
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 e9 ec ff ff       	call   800bc1 <sys_page_alloc>
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	74 14                	je     801ef3 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801edf:	83 ec 04             	sub    $0x4,%esp
  801ee2:	68 1c 28 80 00       	push   $0x80281c
  801ee7:	6a 21                	push   $0x21
  801ee9:	68 80 28 80 00       	push   $0x802880
  801eee:	e8 65 e2 ff ff       	call   800158 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef6:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801efb:	83 ec 08             	sub    $0x8,%esp
  801efe:	68 27 1f 80 00       	push   $0x801f27
  801f03:	6a 00                	push   $0x0
  801f05:	e8 02 ee ff ff       	call   800d0c <sys_env_set_pgfault_upcall>
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	79 14                	jns    801f25 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f11:	83 ec 04             	sub    $0x4,%esp
  801f14:	68 48 28 80 00       	push   $0x802848
  801f19:	6a 29                	push   $0x29
  801f1b:	68 80 28 80 00       	push   $0x802880
  801f20:	e8 33 e2 ff ff       	call   800158 <_panic>
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f27:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f28:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f2d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f2f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801f32:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801f37:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801f3b:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801f3f:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801f41:	83 c4 08             	add    $0x8,%esp
        popal
  801f44:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f45:	83 c4 04             	add    $0x4,%esp
        popfl
  801f48:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801f49:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f4a:	c3                   	ret    

00801f4b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f51:	89 d0                	mov    %edx,%eax
  801f53:	c1 e8 16             	shr    $0x16,%eax
  801f56:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f62:	f6 c1 01             	test   $0x1,%cl
  801f65:	74 1d                	je     801f84 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f67:	c1 ea 0c             	shr    $0xc,%edx
  801f6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f71:	f6 c2 01             	test   $0x1,%dl
  801f74:	74 0e                	je     801f84 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f76:	c1 ea 0c             	shr    $0xc,%edx
  801f79:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f80:	ef 
  801f81:	0f b7 c0             	movzwl %ax,%eax
}
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	83 ec 10             	sub    $0x10,%esp
  801f96:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f9a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f9e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801fa2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801fa6:	85 d2                	test   %edx,%edx
  801fa8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fac:	89 34 24             	mov    %esi,(%esp)
  801faf:	89 c8                	mov    %ecx,%eax
  801fb1:	75 35                	jne    801fe8 <__udivdi3+0x58>
  801fb3:	39 f1                	cmp    %esi,%ecx
  801fb5:	0f 87 bd 00 00 00    	ja     802078 <__udivdi3+0xe8>
  801fbb:	85 c9                	test   %ecx,%ecx
  801fbd:	89 cd                	mov    %ecx,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f1                	div    %ecx
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 f0                	mov    %esi,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c6                	mov    %eax,%esi
  801fd4:	89 f8                	mov    %edi,%eax
  801fd6:	f7 f5                	div    %ebp
  801fd8:	89 f2                	mov    %esi,%edx
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    
  801fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	3b 14 24             	cmp    (%esp),%edx
  801feb:	77 7b                	ja     802068 <__udivdi3+0xd8>
  801fed:	0f bd f2             	bsr    %edx,%esi
  801ff0:	83 f6 1f             	xor    $0x1f,%esi
  801ff3:	0f 84 97 00 00 00    	je     802090 <__udivdi3+0x100>
  801ff9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801ffe:	89 d7                	mov    %edx,%edi
  802000:	89 f1                	mov    %esi,%ecx
  802002:	29 f5                	sub    %esi,%ebp
  802004:	d3 e7                	shl    %cl,%edi
  802006:	89 c2                	mov    %eax,%edx
  802008:	89 e9                	mov    %ebp,%ecx
  80200a:	d3 ea                	shr    %cl,%edx
  80200c:	89 f1                	mov    %esi,%ecx
  80200e:	09 fa                	or     %edi,%edx
  802010:	8b 3c 24             	mov    (%esp),%edi
  802013:	d3 e0                	shl    %cl,%eax
  802015:	89 54 24 08          	mov    %edx,0x8(%esp)
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802023:	89 fa                	mov    %edi,%edx
  802025:	d3 ea                	shr    %cl,%edx
  802027:	89 f1                	mov    %esi,%ecx
  802029:	d3 e7                	shl    %cl,%edi
  80202b:	89 e9                	mov    %ebp,%ecx
  80202d:	d3 e8                	shr    %cl,%eax
  80202f:	09 c7                	or     %eax,%edi
  802031:	89 f8                	mov    %edi,%eax
  802033:	f7 74 24 08          	divl   0x8(%esp)
  802037:	89 d5                	mov    %edx,%ebp
  802039:	89 c7                	mov    %eax,%edi
  80203b:	f7 64 24 0c          	mull   0xc(%esp)
  80203f:	39 d5                	cmp    %edx,%ebp
  802041:	89 14 24             	mov    %edx,(%esp)
  802044:	72 11                	jb     802057 <__udivdi3+0xc7>
  802046:	8b 54 24 04          	mov    0x4(%esp),%edx
  80204a:	89 f1                	mov    %esi,%ecx
  80204c:	d3 e2                	shl    %cl,%edx
  80204e:	39 c2                	cmp    %eax,%edx
  802050:	73 5e                	jae    8020b0 <__udivdi3+0x120>
  802052:	3b 2c 24             	cmp    (%esp),%ebp
  802055:	75 59                	jne    8020b0 <__udivdi3+0x120>
  802057:	8d 47 ff             	lea    -0x1(%edi),%eax
  80205a:	31 f6                	xor    %esi,%esi
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
  802068:	31 f6                	xor    %esi,%esi
  80206a:	31 c0                	xor    %eax,%eax
  80206c:	89 f2                	mov    %esi,%edx
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	5e                   	pop    %esi
  802072:	5f                   	pop    %edi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    
  802075:	8d 76 00             	lea    0x0(%esi),%esi
  802078:	89 f2                	mov    %esi,%edx
  80207a:	31 f6                	xor    %esi,%esi
  80207c:	89 f8                	mov    %edi,%eax
  80207e:	f7 f1                	div    %ecx
  802080:	89 f2                	mov    %esi,%edx
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802094:	76 0b                	jbe    8020a1 <__udivdi3+0x111>
  802096:	31 c0                	xor    %eax,%eax
  802098:	3b 14 24             	cmp    (%esp),%edx
  80209b:	0f 83 37 ff ff ff    	jae    801fd8 <__udivdi3+0x48>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	e9 2d ff ff ff       	jmp    801fd8 <__udivdi3+0x48>
  8020ab:	90                   	nop
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f8                	mov    %edi,%eax
  8020b2:	31 f6                	xor    %esi,%esi
  8020b4:	e9 1f ff ff ff       	jmp    801fd8 <__udivdi3+0x48>
  8020b9:	66 90                	xchg   %ax,%ax
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	83 ec 20             	sub    $0x20,%esp
  8020c6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8020ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d2:	89 c6                	mov    %eax,%esi
  8020d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020e8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	89 c2                	mov    %eax,%edx
  8020f0:	75 1e                	jne    802110 <__umoddi3+0x50>
  8020f2:	39 f7                	cmp    %esi,%edi
  8020f4:	76 52                	jbe    802148 <__umoddi3+0x88>
  8020f6:	89 c8                	mov    %ecx,%eax
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	f7 f7                	div    %edi
  8020fc:	89 d0                	mov    %edx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	83 c4 20             	add    $0x20,%esp
  802103:	5e                   	pop    %esi
  802104:	5f                   	pop    %edi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	89 f6                	mov    %esi,%esi
  802109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802110:	39 f0                	cmp    %esi,%eax
  802112:	77 5c                	ja     802170 <__umoddi3+0xb0>
  802114:	0f bd e8             	bsr    %eax,%ebp
  802117:	83 f5 1f             	xor    $0x1f,%ebp
  80211a:	75 64                	jne    802180 <__umoddi3+0xc0>
  80211c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802120:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802124:	0f 86 f6 00 00 00    	jbe    802220 <__umoddi3+0x160>
  80212a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80212e:	0f 82 ec 00 00 00    	jb     802220 <__umoddi3+0x160>
  802134:	8b 44 24 14          	mov    0x14(%esp),%eax
  802138:	8b 54 24 18          	mov    0x18(%esp),%edx
  80213c:	83 c4 20             	add    $0x20,%esp
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    
  802143:	90                   	nop
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	85 ff                	test   %edi,%edi
  80214a:	89 fd                	mov    %edi,%ebp
  80214c:	75 0b                	jne    802159 <__umoddi3+0x99>
  80214e:	b8 01 00 00 00       	mov    $0x1,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f7                	div    %edi
  802157:	89 c5                	mov    %eax,%ebp
  802159:	8b 44 24 10          	mov    0x10(%esp),%eax
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	f7 f5                	div    %ebp
  802161:	89 c8                	mov    %ecx,%eax
  802163:	f7 f5                	div    %ebp
  802165:	eb 95                	jmp    8020fc <__umoddi3+0x3c>
  802167:	89 f6                	mov    %esi,%esi
  802169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 20             	add    $0x20,%esp
  802177:	5e                   	pop    %esi
  802178:	5f                   	pop    %edi
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    
  80217b:	90                   	nop
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	b8 20 00 00 00       	mov    $0x20,%eax
  802185:	89 e9                	mov    %ebp,%ecx
  802187:	29 e8                	sub    %ebp,%eax
  802189:	d3 e2                	shl    %cl,%edx
  80218b:	89 c7                	mov    %eax,%edi
  80218d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802191:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 c1                	mov    %eax,%ecx
  80219b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80219f:	09 d1                	or     %edx,%ecx
  8021a1:	89 fa                	mov    %edi,%edx
  8021a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8021a7:	89 e9                	mov    %ebp,%ecx
  8021a9:	d3 e0                	shl    %cl,%eax
  8021ab:	89 f9                	mov    %edi,%ecx
  8021ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	d3 e8                	shr    %cl,%eax
  8021b5:	89 e9                	mov    %ebp,%ecx
  8021b7:	89 c7                	mov    %eax,%edi
  8021b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021bd:	d3 e6                	shl    %cl,%esi
  8021bf:	89 d1                	mov    %edx,%ecx
  8021c1:	89 fa                	mov    %edi,%edx
  8021c3:	d3 e8                	shr    %cl,%eax
  8021c5:	89 e9                	mov    %ebp,%ecx
  8021c7:	09 f0                	or     %esi,%eax
  8021c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8021cd:	f7 74 24 10          	divl   0x10(%esp)
  8021d1:	d3 e6                	shl    %cl,%esi
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	f7 64 24 0c          	mull   0xc(%esp)
  8021d9:	39 d1                	cmp    %edx,%ecx
  8021db:	89 74 24 14          	mov    %esi,0x14(%esp)
  8021df:	89 d7                	mov    %edx,%edi
  8021e1:	89 c6                	mov    %eax,%esi
  8021e3:	72 0a                	jb     8021ef <__umoddi3+0x12f>
  8021e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021e9:	73 10                	jae    8021fb <__umoddi3+0x13b>
  8021eb:	39 d1                	cmp    %edx,%ecx
  8021ed:	75 0c                	jne    8021fb <__umoddi3+0x13b>
  8021ef:	89 d7                	mov    %edx,%edi
  8021f1:	89 c6                	mov    %eax,%esi
  8021f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021fb:	89 ca                	mov    %ecx,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802203:	29 f0                	sub    %esi,%eax
  802205:	19 fa                	sbb    %edi,%edx
  802207:	d3 e8                	shr    %cl,%eax
  802209:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80220e:	89 d7                	mov    %edx,%edi
  802210:	d3 e7                	shl    %cl,%edi
  802212:	89 e9                	mov    %ebp,%ecx
  802214:	09 f8                	or     %edi,%eax
  802216:	d3 ea                	shr    %cl,%edx
  802218:	83 c4 20             	add    $0x20,%esp
  80221b:	5e                   	pop    %esi
  80221c:	5f                   	pop    %edi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    
  80221f:	90                   	nop
  802220:	8b 74 24 10          	mov    0x10(%esp),%esi
  802224:	29 f9                	sub    %edi,%ecx
  802226:	19 c6                	sbb    %eax,%esi
  802228:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80222c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802230:	e9 ff fe ff ff       	jmp    802134 <__umoddi3+0x74>
