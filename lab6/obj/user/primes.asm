
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
  800047:	e8 0b 11 00 00       	call   801157 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 80 27 80 00       	push   $0x802780
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 cb 0e 00 00       	call   800f35 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 db 2b 80 00       	push   $0x802bdb
  800079:	6a 1a                	push   $0x1a
  80007b:	68 8c 27 80 00       	push   $0x80278c
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
  800094:	e8 be 10 00 00       	call   801157 <ipc_recv>
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
  8000ab:	e8 10 11 00 00       	call   8011c0 <ipc_send>
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
  8000ba:	e8 76 0e 00 00       	call   800f35 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 db 2b 80 00       	push   $0x802bdb
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 8c 27 80 00       	push   $0x80278c
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
  8000eb:	e8 d0 10 00 00       	call   8011c0 <ipc_send>
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
  800115:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800144:	e8 d5 12 00 00       	call   80141e <close_all>
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
  800176:	68 a4 27 80 00       	push   $0x8027a4
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 19 2c 80 00 	movl   $0x802c19,(%esp)
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
  800294:	e8 07 22 00 00       	call   8024a0 <__udivdi3>
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
  8002d2:	e8 f9 22 00 00       	call   8025d0 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 c7 27 80 00 	movsbl 0x8027c7(%eax),%eax
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
  8003d6:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
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
  80049a:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	75 18                	jne    8004bd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a5:	50                   	push   %eax
  8004a6:	68 df 27 80 00       	push   $0x8027df
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
  8004be:	68 19 2d 80 00       	push   $0x802d19
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
  8004eb:	ba d8 27 80 00       	mov    $0x8027d8,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800b6a:	68 df 2a 80 00       	push   $0x802adf
  800b6f:	6a 22                	push   $0x22
  800b71:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
	// return value.
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
	// return value.
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
  800beb:	68 df 2a 80 00       	push   $0x802adf
  800bf0:	6a 22                	push   $0x22
  800bf2:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
  800c2d:	68 df 2a 80 00       	push   $0x802adf
  800c32:	6a 22                	push   $0x22
  800c34:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
  800c6f:	68 df 2a 80 00       	push   $0x802adf
  800c74:	6a 22                	push   $0x22
  800c76:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
  800cb1:	68 df 2a 80 00       	push   $0x802adf
  800cb6:	6a 22                	push   $0x22
  800cb8:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
  800cf3:	68 df 2a 80 00       	push   $0x802adf
  800cf8:	6a 22                	push   $0x22
  800cfa:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
  800d35:	68 df 2a 80 00       	push   $0x802adf
  800d3a:	6a 22                	push   $0x22
  800d3c:	68 fc 2a 80 00       	push   $0x802afc
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
	// return value.
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
	// return value.
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
  800d99:	68 df 2a 80 00       	push   $0x802adf
  800d9e:	6a 22                	push   $0x22
  800da0:	68 fc 2a 80 00       	push   $0x802afc
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

00800db2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800db8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	89 d7                	mov    %edx,%edi
  800dc8:	89 d6                	mov    %edx,%esi
  800dca:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 cb                	mov    %ecx,%ebx
  800de9:	89 cf                	mov    %ecx,%edi
  800deb:	89 ce                	mov    %ecx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 0f                	push   $0xf
  800df9:	68 df 2a 80 00       	push   $0x802adf
  800dfe:	6a 22                	push   $0x22
  800e00:	68 fc 2a 80 00       	push   $0x802afc
  800e05:	e8 4e f3 ff ff       	call   800158 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_recv>:

int
sys_recv(void *addr)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e20:	b8 10 00 00 00       	mov    $0x10,%eax
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 cb                	mov    %ecx,%ebx
  800e2a:	89 cf                	mov    %ecx,%edi
  800e2c:	89 ce                	mov    %ecx,%esi
  800e2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7e 17                	jle    800e4b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	50                   	push   %eax
  800e38:	6a 10                	push   $0x10
  800e3a:	68 df 2a 80 00       	push   $0x802adf
  800e3f:	6a 22                	push   $0x22
  800e41:	68 fc 2a 80 00       	push   $0x802afc
  800e46:	e8 0d f3 ff ff       	call   800158 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e5d:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e5f:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e63:	74 2e                	je     800e93 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 16             	shr    $0x16,%edx
  800e6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 1d                	je     800e93 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 0c             	shr    $0xc,%edx
  800e7b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e82:	f6 c1 01             	test   $0x1,%cl
  800e85:	74 0c                	je     800e93 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e8e:	f6 c6 08             	test   $0x8,%dh
  800e91:	75 14                	jne    800ea7 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 0c 2b 80 00       	push   $0x802b0c
  800e9b:	6a 21                	push   $0x21
  800e9d:	68 9f 2b 80 00       	push   $0x802b9f
  800ea2:	e8 b1 f2 ff ff       	call   800158 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800ea7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eac:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	6a 07                	push   $0x7
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 02 fd ff ff       	call   800bc1 <sys_page_alloc>
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	79 14                	jns    800eda <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800ec6:	83 ec 04             	sub    $0x4,%esp
  800ec9:	68 aa 2b 80 00       	push   $0x802baa
  800ece:	6a 2b                	push   $0x2b
  800ed0:	68 9f 2b 80 00       	push   $0x802b9f
  800ed5:	e8 7e f2 ff ff       	call   800158 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	68 00 10 00 00       	push   $0x1000
  800ee2:	53                   	push   %ebx
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	e8 5d fa ff ff       	call   80094a <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800eed:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef4:	53                   	push   %ebx
  800ef5:	6a 00                	push   $0x0
  800ef7:	68 00 f0 7f 00       	push   $0x7ff000
  800efc:	6a 00                	push   $0x0
  800efe:	e8 01 fd ff ff       	call   800c04 <sys_page_map>
  800f03:	83 c4 20             	add    $0x20,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 14                	jns    800f1e <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 c0 2b 80 00       	push   $0x802bc0
  800f12:	6a 2e                	push   $0x2e
  800f14:	68 9f 2b 80 00       	push   $0x802b9f
  800f19:	e8 3a f2 ff ff       	call   800158 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f1e:	83 ec 08             	sub    $0x8,%esp
  800f21:	68 00 f0 7f 00       	push   $0x7ff000
  800f26:	6a 00                	push   $0x0
  800f28:	e8 19 fd ff ff       	call   800c46 <sys_page_unmap>
  800f2d:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f3e:	68 53 0e 80 00       	push   $0x800e53
  800f43:	e8 87 14 00 00       	call   8023cf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f48:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4d:	cd 30                	int    $0x30
  800f4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	79 12                	jns    800f6b <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f59:	50                   	push   %eax
  800f5a:	68 d4 2b 80 00       	push   $0x802bd4
  800f5f:	6a 6d                	push   $0x6d
  800f61:	68 9f 2b 80 00       	push   $0x802b9f
  800f66:	e8 ed f1 ff ff       	call   800158 <_panic>
  800f6b:	89 c7                	mov    %eax,%edi
  800f6d:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f72:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f76:	75 21                	jne    800f99 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f78:	e8 06 fc ff ff       	call   800b83 <sys_getenvid>
  800f7d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f82:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f85:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8a:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f94:	e9 9c 01 00 00       	jmp    801135 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f99:	89 d8                	mov    %ebx,%eax
  800f9b:	c1 e8 16             	shr    $0x16,%eax
  800f9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa5:	a8 01                	test   $0x1,%al
  800fa7:	0f 84 f3 00 00 00    	je     8010a0 <fork+0x16b>
  800fad:	89 d8                	mov    %ebx,%eax
  800faf:	c1 e8 0c             	shr    $0xc,%eax
  800fb2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb9:	f6 c2 01             	test   $0x1,%dl
  800fbc:	0f 84 de 00 00 00    	je     8010a0 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800fc2:	89 c6                	mov    %eax,%esi
  800fc4:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800fc7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fce:	f6 c6 04             	test   $0x4,%dh
  800fd1:	74 37                	je     80100a <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800fd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe2:	50                   	push   %eax
  800fe3:	56                   	push   %esi
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 17 fc ff ff       	call   800c04 <sys_page_map>
  800fed:	83 c4 20             	add    $0x20,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	0f 89 a8 00 00 00    	jns    8010a0 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  800ff8:	50                   	push   %eax
  800ff9:	68 30 2b 80 00       	push   $0x802b30
  800ffe:	6a 49                	push   $0x49
  801000:	68 9f 2b 80 00       	push   $0x802b9f
  801005:	e8 4e f1 ff ff       	call   800158 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  80100a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801011:	f6 c6 08             	test   $0x8,%dh
  801014:	75 0b                	jne    801021 <fork+0xec>
  801016:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101d:	a8 02                	test   $0x2,%al
  80101f:	74 57                	je     801078 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	68 05 08 00 00       	push   $0x805
  801029:	56                   	push   %esi
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	e8 d1 fb ff ff       	call   800c04 <sys_page_map>
  801033:	83 c4 20             	add    $0x20,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 12                	jns    80104c <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  80103a:	50                   	push   %eax
  80103b:	68 30 2b 80 00       	push   $0x802b30
  801040:	6a 4c                	push   $0x4c
  801042:	68 9f 2b 80 00       	push   $0x802b9f
  801047:	e8 0c f1 ff ff       	call   800158 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	56                   	push   %esi
  801055:	6a 00                	push   $0x0
  801057:	56                   	push   %esi
  801058:	6a 00                	push   $0x0
  80105a:	e8 a5 fb ff ff       	call   800c04 <sys_page_map>
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	79 3a                	jns    8010a0 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801066:	50                   	push   %eax
  801067:	68 54 2b 80 00       	push   $0x802b54
  80106c:	6a 4e                	push   $0x4e
  80106e:	68 9f 2b 80 00       	push   $0x802b9f
  801073:	e8 e0 f0 ff ff       	call   800158 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	6a 05                	push   $0x5
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	e8 7d fb ff ff       	call   800c04 <sys_page_map>
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	79 12                	jns    8010a0 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80108e:	50                   	push   %eax
  80108f:	68 7c 2b 80 00       	push   $0x802b7c
  801094:	6a 50                	push   $0x50
  801096:	68 9f 2b 80 00       	push   $0x802b9f
  80109b:	e8 b8 f0 ff ff       	call   800158 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8010a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010ac:	0f 85 e7 fe ff ff    	jne    800f99 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	6a 07                	push   $0x7
  8010b7:	68 00 f0 bf ee       	push   $0xeebff000
  8010bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bf:	e8 fd fa ff ff       	call   800bc1 <sys_page_alloc>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 14                	jns    8010df <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	68 e4 2b 80 00       	push   $0x802be4
  8010d3:	6a 76                	push   $0x76
  8010d5:	68 9f 2b 80 00       	push   $0x802b9f
  8010da:	e8 79 f0 ff ff       	call   800158 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	68 3e 24 80 00       	push   $0x80243e
  8010e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ea:	e8 1d fc ff ff       	call   800d0c <sys_env_set_pgfault_upcall>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 14                	jns    80110a <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8010f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f9:	68 fe 2b 80 00       	push   $0x802bfe
  8010fe:	6a 79                	push   $0x79
  801100:	68 9f 2b 80 00       	push   $0x802b9f
  801105:	e8 4e f0 ff ff       	call   800158 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	6a 02                	push   $0x2
  80110f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801112:	e8 71 fb ff ff       	call   800c88 <sys_env_set_status>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 14                	jns    801132 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  80111e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801121:	68 1b 2c 80 00       	push   $0x802c1b
  801126:	6a 7b                	push   $0x7b
  801128:	68 9f 2b 80 00       	push   $0x802b9f
  80112d:	e8 26 f0 ff ff       	call   800158 <_panic>
        return forkid;
  801132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sfork>:

// Challenge!
int
sfork(void)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801143:	68 32 2c 80 00       	push   $0x802c32
  801148:	68 83 00 00 00       	push   $0x83
  80114d:	68 9f 2b 80 00       	push   $0x802b9f
  801152:	e8 01 f0 ff ff       	call   800158 <_panic>

00801157 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
  80115c:	8b 75 08             	mov    0x8(%ebp),%esi
  80115f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801162:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801165:	85 c0                	test   %eax,%eax
  801167:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80116c:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	50                   	push   %eax
  801173:	e8 f9 fb ff ff       	call   800d71 <sys_ipc_recv>
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 16                	jns    801195 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80117f:	85 f6                	test   %esi,%esi
  801181:	74 06                	je     801189 <ipc_recv+0x32>
  801183:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801189:	85 db                	test   %ebx,%ebx
  80118b:	74 2c                	je     8011b9 <ipc_recv+0x62>
  80118d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801193:	eb 24                	jmp    8011b9 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801195:	85 f6                	test   %esi,%esi
  801197:	74 0a                	je     8011a3 <ipc_recv+0x4c>
  801199:	a1 08 40 80 00       	mov    0x804008,%eax
  80119e:	8b 40 74             	mov    0x74(%eax),%eax
  8011a1:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8011a3:	85 db                	test   %ebx,%ebx
  8011a5:	74 0a                	je     8011b1 <ipc_recv+0x5a>
  8011a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ac:	8b 40 78             	mov    0x78(%eax),%eax
  8011af:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8011b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8011d2:	85 db                	test   %ebx,%ebx
  8011d4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011d9:	0f 44 d8             	cmove  %eax,%ebx
  8011dc:	eb 1c                	jmp    8011fa <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8011de:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011e1:	74 12                	je     8011f5 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8011e3:	50                   	push   %eax
  8011e4:	68 48 2c 80 00       	push   $0x802c48
  8011e9:	6a 39                	push   $0x39
  8011eb:	68 63 2c 80 00       	push   $0x802c63
  8011f0:	e8 63 ef ff ff       	call   800158 <_panic>
                 sys_yield();
  8011f5:	e8 a8 f9 ff ff       	call   800ba2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011fa:	ff 75 14             	pushl  0x14(%ebp)
  8011fd:	53                   	push   %ebx
  8011fe:	56                   	push   %esi
  8011ff:	57                   	push   %edi
  801200:	e8 49 fb ff ff       	call   800d4e <sys_ipc_try_send>
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 d2                	js     8011de <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80120c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80121f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801222:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801228:	8b 52 50             	mov    0x50(%edx),%edx
  80122b:	39 ca                	cmp    %ecx,%edx
  80122d:	75 0d                	jne    80123c <ipc_find_env+0x28>
			return envs[i].env_id;
  80122f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801232:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801237:	8b 40 08             	mov    0x8(%eax),%eax
  80123a:	eb 0e                	jmp    80124a <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80123c:	83 c0 01             	add    $0x1,%eax
  80123f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801244:	75 d9                	jne    80121f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801246:	66 b8 00 00          	mov    $0x0,%ax
}
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	05 00 00 00 30       	add    $0x30000000,%eax
  801257:	c1 e8 0c             	shr    $0xc,%eax
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801267:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80126c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801279:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80127e:	89 c2                	mov    %eax,%edx
  801280:	c1 ea 16             	shr    $0x16,%edx
  801283:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128a:	f6 c2 01             	test   $0x1,%dl
  80128d:	74 11                	je     8012a0 <fd_alloc+0x2d>
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 ea 0c             	shr    $0xc,%edx
  801294:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	75 09                	jne    8012a9 <fd_alloc+0x36>
			*fd_store = fd;
  8012a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 17                	jmp    8012c0 <fd_alloc+0x4d>
  8012a9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b3:	75 c9                	jne    80127e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c8:	83 f8 1f             	cmp    $0x1f,%eax
  8012cb:	77 36                	ja     801303 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012cd:	c1 e0 0c             	shl    $0xc,%eax
  8012d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 16             	shr    $0x16,%edx
  8012da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e1:	f6 c2 01             	test   $0x1,%dl
  8012e4:	74 24                	je     80130a <fd_lookup+0x48>
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	c1 ea 0c             	shr    $0xc,%edx
  8012eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	74 1a                	je     801311 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	eb 13                	jmp    801316 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801308:	eb 0c                	jmp    801316 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130f:	eb 05                	jmp    801316 <fd_lookup+0x54>
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801321:	ba 00 00 00 00       	mov    $0x0,%edx
  801326:	eb 13                	jmp    80133b <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801328:	39 08                	cmp    %ecx,(%eax)
  80132a:	75 0c                	jne    801338 <dev_lookup+0x20>
			*dev = devtab[i];
  80132c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 36                	jmp    80136e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801338:	83 c2 01             	add    $0x1,%edx
  80133b:	8b 04 95 ec 2c 80 00 	mov    0x802cec(,%edx,4),%eax
  801342:	85 c0                	test   %eax,%eax
  801344:	75 e2                	jne    801328 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801346:	a1 08 40 80 00       	mov    0x804008,%eax
  80134b:	8b 40 48             	mov    0x48(%eax),%eax
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	51                   	push   %ecx
  801352:	50                   	push   %eax
  801353:	68 70 2c 80 00       	push   $0x802c70
  801358:	e8 d4 ee ff ff       	call   800231 <cprintf>
	*dev = 0;
  80135d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801360:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 10             	sub    $0x10,%esp
  801378:	8b 75 08             	mov    0x8(%ebp),%esi
  80137b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801381:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801382:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801388:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138b:	50                   	push   %eax
  80138c:	e8 31 ff ff ff       	call   8012c2 <fd_lookup>
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 05                	js     80139d <fd_close+0x2d>
	    || fd != fd2)
  801398:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139b:	74 0c                	je     8013a9 <fd_close+0x39>
		return (must_exist ? r : 0);
  80139d:	84 db                	test   %bl,%bl
  80139f:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a4:	0f 44 c2             	cmove  %edx,%eax
  8013a7:	eb 41                	jmp    8013ea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 36                	pushl  (%esi)
  8013b2:	e8 61 ff ff ff       	call   801318 <dev_lookup>
  8013b7:	89 c3                	mov    %eax,%ebx
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 1a                	js     8013da <fd_close+0x6a>
		if (dev->dev_close)
  8013c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	74 0b                	je     8013da <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	56                   	push   %esi
  8013d3:	ff d0                	call   *%eax
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	56                   	push   %esi
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 61 f8 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	89 d8                	mov    %ebx,%eax
}
  8013ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 08             	pushl  0x8(%ebp)
  8013fe:	e8 bf fe ff ff       	call   8012c2 <fd_lookup>
  801403:	89 c2                	mov    %eax,%edx
  801405:	83 c4 08             	add    $0x8,%esp
  801408:	85 d2                	test   %edx,%edx
  80140a:	78 10                	js     80141c <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	6a 01                	push   $0x1
  801411:	ff 75 f4             	pushl  -0xc(%ebp)
  801414:	e8 57 ff ff ff       	call   801370 <fd_close>
  801419:	83 c4 10             	add    $0x10,%esp
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <close_all>:

void
close_all(void)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801425:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	53                   	push   %ebx
  80142e:	e8 be ff ff ff       	call   8013f1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801433:	83 c3 01             	add    $0x1,%ebx
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	83 fb 20             	cmp    $0x20,%ebx
  80143c:	75 ec                	jne    80142a <close_all+0xc>
		close(i);
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	57                   	push   %edi
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 2c             	sub    $0x2c,%esp
  80144c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80144f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	ff 75 08             	pushl  0x8(%ebp)
  801456:	e8 67 fe ff ff       	call   8012c2 <fd_lookup>
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	85 d2                	test   %edx,%edx
  801462:	0f 88 c1 00 00 00    	js     801529 <dup+0xe6>
		return r;
	close(newfdnum);
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	56                   	push   %esi
  80146c:	e8 80 ff ff ff       	call   8013f1 <close>

	newfd = INDEX2FD(newfdnum);
  801471:	89 f3                	mov    %esi,%ebx
  801473:	c1 e3 0c             	shl    $0xc,%ebx
  801476:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80147c:	83 c4 04             	add    $0x4,%esp
  80147f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801482:	e8 d5 fd ff ff       	call   80125c <fd2data>
  801487:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801489:	89 1c 24             	mov    %ebx,(%esp)
  80148c:	e8 cb fd ff ff       	call   80125c <fd2data>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801497:	89 f8                	mov    %edi,%eax
  801499:	c1 e8 16             	shr    $0x16,%eax
  80149c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a3:	a8 01                	test   $0x1,%al
  8014a5:	74 37                	je     8014de <dup+0x9b>
  8014a7:	89 f8                	mov    %edi,%eax
  8014a9:	c1 e8 0c             	shr    $0xc,%eax
  8014ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 26                	je     8014de <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	57                   	push   %edi
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 2f f7 ff ff       	call   800c04 <sys_page_map>
  8014d5:	89 c7                	mov    %eax,%edi
  8014d7:	83 c4 20             	add    $0x20,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 2e                	js     80150c <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	c1 e8 0c             	shr    $0xc,%eax
  8014e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f5:	50                   	push   %eax
  8014f6:	53                   	push   %ebx
  8014f7:	6a 00                	push   $0x0
  8014f9:	52                   	push   %edx
  8014fa:	6a 00                	push   $0x0
  8014fc:	e8 03 f7 ff ff       	call   800c04 <sys_page_map>
  801501:	89 c7                	mov    %eax,%edi
  801503:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801506:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801508:	85 ff                	test   %edi,%edi
  80150a:	79 1d                	jns    801529 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	53                   	push   %ebx
  801510:	6a 00                	push   $0x0
  801512:	e8 2f f7 ff ff       	call   800c46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151d:	6a 00                	push   $0x0
  80151f:	e8 22 f7 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 f8                	mov    %edi,%eax
}
  801529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5f                   	pop    %edi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 14             	sub    $0x14,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	53                   	push   %ebx
  801540:	e8 7d fd ff ff       	call   8012c2 <fd_lookup>
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	89 c2                	mov    %eax,%edx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 6d                	js     8015bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	ff 30                	pushl  (%eax)
  80155a:	e8 b9 fd ff ff       	call   801318 <dev_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 4c                	js     8015b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801566:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801569:	8b 42 08             	mov    0x8(%edx),%eax
  80156c:	83 e0 03             	and    $0x3,%eax
  80156f:	83 f8 01             	cmp    $0x1,%eax
  801572:	75 21                	jne    801595 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801574:	a1 08 40 80 00       	mov    0x804008,%eax
  801579:	8b 40 48             	mov    0x48(%eax),%eax
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	53                   	push   %ebx
  801580:	50                   	push   %eax
  801581:	68 b1 2c 80 00       	push   $0x802cb1
  801586:	e8 a6 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801593:	eb 26                	jmp    8015bb <read+0x8a>
	}
	if (!dev->dev_read)
  801595:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801598:	8b 40 08             	mov    0x8(%eax),%eax
  80159b:	85 c0                	test   %eax,%eax
  80159d:	74 17                	je     8015b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	ff 75 10             	pushl  0x10(%ebp)
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	52                   	push   %edx
  8015a9:	ff d0                	call   *%eax
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 09                	jmp    8015bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	eb 05                	jmp    8015bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d6:	eb 21                	jmp    8015f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	89 f0                	mov    %esi,%eax
  8015dd:	29 d8                	sub    %ebx,%eax
  8015df:	50                   	push   %eax
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	03 45 0c             	add    0xc(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	57                   	push   %edi
  8015e7:	e8 45 ff ff ff       	call   801531 <read>
		if (m < 0)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 0c                	js     8015ff <readn+0x3d>
			return m;
		if (m == 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	74 06                	je     8015fd <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	01 c3                	add    %eax,%ebx
  8015f9:	39 f3                	cmp    %esi,%ebx
  8015fb:	72 db                	jb     8015d8 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015fd:	89 d8                	mov    %ebx,%eax
}
  8015ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 14             	sub    $0x14,%esp
  80160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	53                   	push   %ebx
  801616:	e8 a7 fc ff ff       	call   8012c2 <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	89 c2                	mov    %eax,%edx
  801620:	85 c0                	test   %eax,%eax
  801622:	78 68                	js     80168c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162e:	ff 30                	pushl  (%eax)
  801630:	e8 e3 fc ff ff       	call   801318 <dev_lookup>
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 47                	js     801683 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801643:	75 21                	jne    801666 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801645:	a1 08 40 80 00       	mov    0x804008,%eax
  80164a:	8b 40 48             	mov    0x48(%eax),%eax
  80164d:	83 ec 04             	sub    $0x4,%esp
  801650:	53                   	push   %ebx
  801651:	50                   	push   %eax
  801652:	68 cd 2c 80 00       	push   $0x802ccd
  801657:	e8 d5 eb ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801664:	eb 26                	jmp    80168c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801666:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801669:	8b 52 0c             	mov    0xc(%edx),%edx
  80166c:	85 d2                	test   %edx,%edx
  80166e:	74 17                	je     801687 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801670:	83 ec 04             	sub    $0x4,%esp
  801673:	ff 75 10             	pushl  0x10(%ebp)
  801676:	ff 75 0c             	pushl  0xc(%ebp)
  801679:	50                   	push   %eax
  80167a:	ff d2                	call   *%edx
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	eb 09                	jmp    80168c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	89 c2                	mov    %eax,%edx
  801685:	eb 05                	jmp    80168c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801687:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80168c:	89 d0                	mov    %edx,%eax
  80168e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <seek>:

int
seek(int fdnum, off_t offset)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801699:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	ff 75 08             	pushl  0x8(%ebp)
  8016a0:	e8 1d fc ff ff       	call   8012c2 <fd_lookup>
  8016a5:	83 c4 08             	add    $0x8,%esp
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 0e                	js     8016ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 14             	sub    $0x14,%esp
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	53                   	push   %ebx
  8016cb:	e8 f2 fb ff ff       	call   8012c2 <fd_lookup>
  8016d0:	83 c4 08             	add    $0x8,%esp
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 65                	js     80173e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e3:	ff 30                	pushl  (%eax)
  8016e5:	e8 2e fc ff ff       	call   801318 <dev_lookup>
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 44                	js     801735 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f8:	75 21                	jne    80171b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fa:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ff:	8b 40 48             	mov    0x48(%eax),%eax
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	53                   	push   %ebx
  801706:	50                   	push   %eax
  801707:	68 90 2c 80 00       	push   $0x802c90
  80170c:	e8 20 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801719:	eb 23                	jmp    80173e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80171b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171e:	8b 52 18             	mov    0x18(%edx),%edx
  801721:	85 d2                	test   %edx,%edx
  801723:	74 14                	je     801739 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	ff 75 0c             	pushl  0xc(%ebp)
  80172b:	50                   	push   %eax
  80172c:	ff d2                	call   *%edx
  80172e:	89 c2                	mov    %eax,%edx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb 09                	jmp    80173e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801735:	89 c2                	mov    %eax,%edx
  801737:	eb 05                	jmp    80173e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801739:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80173e:	89 d0                	mov    %edx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 14             	sub    $0x14,%esp
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	ff 75 08             	pushl  0x8(%ebp)
  801756:	e8 67 fb ff ff       	call   8012c2 <fd_lookup>
  80175b:	83 c4 08             	add    $0x8,%esp
  80175e:	89 c2                	mov    %eax,%edx
  801760:	85 c0                	test   %eax,%eax
  801762:	78 58                	js     8017bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176e:	ff 30                	pushl  (%eax)
  801770:	e8 a3 fb ff ff       	call   801318 <dev_lookup>
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 37                	js     8017b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801783:	74 32                	je     8017b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801785:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801788:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80178f:	00 00 00 
	stat->st_isdir = 0;
  801792:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801799:	00 00 00 
	stat->st_dev = dev;
  80179c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	53                   	push   %ebx
  8017a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a9:	ff 50 14             	call   *0x14(%eax)
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	eb 09                	jmp    8017bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	eb 05                	jmp    8017bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017bc:	89 d0                	mov    %edx,%eax
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	6a 00                	push   $0x0
  8017cd:	ff 75 08             	pushl  0x8(%ebp)
  8017d0:	e8 09 02 00 00       	call   8019de <open>
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 db                	test   %ebx,%ebx
  8017dc:	78 1b                	js     8017f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	ff 75 0c             	pushl  0xc(%ebp)
  8017e4:	53                   	push   %ebx
  8017e5:	e8 5b ff ff ff       	call   801745 <fstat>
  8017ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ec:	89 1c 24             	mov    %ebx,(%esp)
  8017ef:	e8 fd fb ff ff       	call   8013f1 <close>
	return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	89 f0                	mov    %esi,%eax
}
  8017f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	89 c6                	mov    %eax,%esi
  801807:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801809:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801810:	75 12                	jne    801824 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	6a 01                	push   $0x1
  801817:	e8 f8 f9 ff ff       	call   801214 <ipc_find_env>
  80181c:	a3 00 40 80 00       	mov    %eax,0x804000
  801821:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801824:	6a 07                	push   $0x7
  801826:	68 00 50 80 00       	push   $0x805000
  80182b:	56                   	push   %esi
  80182c:	ff 35 00 40 80 00    	pushl  0x804000
  801832:	e8 89 f9 ff ff       	call   8011c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801837:	83 c4 0c             	add    $0xc,%esp
  80183a:	6a 00                	push   $0x0
  80183c:	53                   	push   %ebx
  80183d:	6a 00                	push   $0x0
  80183f:	e8 13 f9 ff ff       	call   801157 <ipc_recv>
}
  801844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	8b 40 0c             	mov    0xc(%eax),%eax
  801857:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801864:	ba 00 00 00 00       	mov    $0x0,%edx
  801869:	b8 02 00 00 00       	mov    $0x2,%eax
  80186e:	e8 8d ff ff ff       	call   801800 <fsipc>
}
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 40 0c             	mov    0xc(%eax),%eax
  801881:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801886:	ba 00 00 00 00       	mov    $0x0,%edx
  80188b:	b8 06 00 00 00       	mov    $0x6,%eax
  801890:	e8 6b ff ff ff       	call   801800 <fsipc>
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	53                   	push   %ebx
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b6:	e8 45 ff ff ff       	call   801800 <fsipc>
  8018bb:	89 c2                	mov    %eax,%edx
  8018bd:	85 d2                	test   %edx,%edx
  8018bf:	78 2c                	js     8018ed <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	68 00 50 80 00       	push   $0x805000
  8018c9:	53                   	push   %ebx
  8018ca:	e8 e9 ee ff ff       	call   8007b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018da:	a1 84 50 80 00       	mov    0x805084,%eax
  8018df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	57                   	push   %edi
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	8b 40 0c             	mov    0xc(%eax),%eax
  801904:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801909:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80190c:	eb 3d                	jmp    80194b <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80190e:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801914:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801919:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80191c:	83 ec 04             	sub    $0x4,%esp
  80191f:	57                   	push   %edi
  801920:	53                   	push   %ebx
  801921:	68 08 50 80 00       	push   $0x805008
  801926:	e8 1f f0 ff ff       	call   80094a <memmove>
                fsipcbuf.write.req_n = tmp; 
  80192b:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
  801936:	b8 04 00 00 00       	mov    $0x4,%eax
  80193b:	e8 c0 fe ff ff       	call   801800 <fsipc>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	78 0d                	js     801954 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801947:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801949:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80194b:	85 f6                	test   %esi,%esi
  80194d:	75 bf                	jne    80190e <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80194f:	89 d8                	mov    %ebx,%eax
  801951:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801954:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801957:	5b                   	pop    %ebx
  801958:	5e                   	pop    %esi
  801959:	5f                   	pop    %edi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801964:	8b 45 08             	mov    0x8(%ebp),%eax
  801967:	8b 40 0c             	mov    0xc(%eax),%eax
  80196a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80196f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801975:	ba 00 00 00 00       	mov    $0x0,%edx
  80197a:	b8 03 00 00 00       	mov    $0x3,%eax
  80197f:	e8 7c fe ff ff       	call   801800 <fsipc>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	85 c0                	test   %eax,%eax
  801988:	78 4b                	js     8019d5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80198a:	39 c6                	cmp    %eax,%esi
  80198c:	73 16                	jae    8019a4 <devfile_read+0x48>
  80198e:	68 00 2d 80 00       	push   $0x802d00
  801993:	68 07 2d 80 00       	push   $0x802d07
  801998:	6a 7c                	push   $0x7c
  80199a:	68 1c 2d 80 00       	push   $0x802d1c
  80199f:	e8 b4 e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8019a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a9:	7e 16                	jle    8019c1 <devfile_read+0x65>
  8019ab:	68 27 2d 80 00       	push   $0x802d27
  8019b0:	68 07 2d 80 00       	push   $0x802d07
  8019b5:	6a 7d                	push   $0x7d
  8019b7:	68 1c 2d 80 00       	push   $0x802d1c
  8019bc:	e8 97 e7 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	50                   	push   %eax
  8019c5:	68 00 50 80 00       	push   $0x805000
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	e8 78 ef ff ff       	call   80094a <memmove>
	return r;
  8019d2:	83 c4 10             	add    $0x10,%esp
}
  8019d5:	89 d8                	mov    %ebx,%eax
  8019d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 20             	sub    $0x20,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e8:	53                   	push   %ebx
  8019e9:	e8 91 ed ff ff       	call   80077f <strlen>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f6:	7f 67                	jg     801a5f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	50                   	push   %eax
  8019ff:	e8 6f f8 ff ff       	call   801273 <fd_alloc>
  801a04:	83 c4 10             	add    $0x10,%esp
		return r;
  801a07:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	78 57                	js     801a64 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0d:	83 ec 08             	sub    $0x8,%esp
  801a10:	53                   	push   %ebx
  801a11:	68 00 50 80 00       	push   $0x805000
  801a16:	e8 9d ed ff ff       	call   8007b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a26:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2b:	e8 d0 fd ff ff       	call   801800 <fsipc>
  801a30:	89 c3                	mov    %eax,%ebx
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	85 c0                	test   %eax,%eax
  801a37:	79 14                	jns    801a4d <open+0x6f>
		fd_close(fd, 0);
  801a39:	83 ec 08             	sub    $0x8,%esp
  801a3c:	6a 00                	push   $0x0
  801a3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a41:	e8 2a f9 ff ff       	call   801370 <fd_close>
		return r;
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	89 da                	mov    %ebx,%edx
  801a4b:	eb 17                	jmp    801a64 <open+0x86>
	}

	return fd2num(fd);
  801a4d:	83 ec 0c             	sub    $0xc,%esp
  801a50:	ff 75 f4             	pushl  -0xc(%ebp)
  801a53:	e8 f4 f7 ff ff       	call   80124c <fd2num>
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	eb 05                	jmp    801a64 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a5f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a64:	89 d0                	mov    %edx,%eax
  801a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7b:	e8 80 fd ff ff       	call   801800 <fsipc>
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a88:	68 33 2d 80 00       	push   $0x802d33
  801a8d:	ff 75 0c             	pushl  0xc(%ebp)
  801a90:	e8 23 ed ff ff       	call   8007b8 <strcpy>
	return 0;
}
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 10             	sub    $0x10,%esp
  801aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801aa6:	53                   	push   %ebx
  801aa7:	e8 b6 09 00 00       	call   802462 <pageref>
  801aac:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ab4:	83 f8 01             	cmp    $0x1,%eax
  801ab7:	75 10                	jne    801ac9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	ff 73 0c             	pushl  0xc(%ebx)
  801abf:	e8 ca 02 00 00       	call   801d8e <nsipc_close>
  801ac4:	89 c2                	mov    %eax,%edx
  801ac6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ac9:	89 d0                	mov    %edx,%eax
  801acb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ad6:	6a 00                	push   $0x0
  801ad8:	ff 75 10             	pushl  0x10(%ebp)
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	ff 70 0c             	pushl  0xc(%eax)
  801ae4:	e8 82 03 00 00       	call   801e6b <nsipc_send>
}
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801af1:	6a 00                	push   $0x0
  801af3:	ff 75 10             	pushl  0x10(%ebp)
  801af6:	ff 75 0c             	pushl  0xc(%ebp)
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	ff 70 0c             	pushl  0xc(%eax)
  801aff:	e8 fb 02 00 00       	call   801dff <nsipc_recv>
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b0c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b0f:	52                   	push   %edx
  801b10:	50                   	push   %eax
  801b11:	e8 ac f7 ff ff       	call   8012c2 <fd_lookup>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 17                	js     801b34 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b20:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b26:	39 08                	cmp    %ecx,(%eax)
  801b28:	75 05                	jne    801b2f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2d:	eb 05                	jmp    801b34 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b2f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 1c             	sub    $0x1c,%esp
  801b3e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b43:	50                   	push   %eax
  801b44:	e8 2a f7 ff ff       	call   801273 <fd_alloc>
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 1b                	js     801b6d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b52:	83 ec 04             	sub    $0x4,%esp
  801b55:	68 07 04 00 00       	push   $0x407
  801b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5d:	6a 00                	push   $0x0
  801b5f:	e8 5d f0 ff ff       	call   800bc1 <sys_page_alloc>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	79 10                	jns    801b7d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b6d:	83 ec 0c             	sub    $0xc,%esp
  801b70:	56                   	push   %esi
  801b71:	e8 18 02 00 00       	call   801d8e <nsipc_close>
		return r;
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	89 d8                	mov    %ebx,%eax
  801b7b:	eb 24                	jmp    801ba1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b86:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b8b:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b92:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	52                   	push   %edx
  801b99:	e8 ae f6 ff ff       	call   80124c <fd2num>
  801b9e:	83 c4 10             	add    $0x10,%esp
}
  801ba1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	e8 50 ff ff ff       	call   801b06 <fd2sockid>
		return r;
  801bb6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 1f                	js     801bdb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	ff 75 10             	pushl  0x10(%ebp)
  801bc2:	ff 75 0c             	pushl  0xc(%ebp)
  801bc5:	50                   	push   %eax
  801bc6:	e8 1c 01 00 00       	call   801ce7 <nsipc_accept>
  801bcb:	83 c4 10             	add    $0x10,%esp
		return r;
  801bce:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	78 07                	js     801bdb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bd4:	e8 5d ff ff ff       	call   801b36 <alloc_sockfd>
  801bd9:	89 c1                	mov    %eax,%ecx
}
  801bdb:	89 c8                	mov    %ecx,%eax
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	e8 19 ff ff ff       	call   801b06 <fd2sockid>
  801bed:	89 c2                	mov    %eax,%edx
  801bef:	85 d2                	test   %edx,%edx
  801bf1:	78 12                	js     801c05 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	ff 75 10             	pushl  0x10(%ebp)
  801bf9:	ff 75 0c             	pushl  0xc(%ebp)
  801bfc:	52                   	push   %edx
  801bfd:	e8 35 01 00 00       	call   801d37 <nsipc_bind>
  801c02:	83 c4 10             	add    $0x10,%esp
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <shutdown>:

int
shutdown(int s, int how)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	e8 f1 fe ff ff       	call   801b06 <fd2sockid>
  801c15:	89 c2                	mov    %eax,%edx
  801c17:	85 d2                	test   %edx,%edx
  801c19:	78 0f                	js     801c2a <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	ff 75 0c             	pushl  0xc(%ebp)
  801c21:	52                   	push   %edx
  801c22:	e8 45 01 00 00       	call   801d6c <nsipc_shutdown>
  801c27:	83 c4 10             	add    $0x10,%esp
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	e8 cc fe ff ff       	call   801b06 <fd2sockid>
  801c3a:	89 c2                	mov    %eax,%edx
  801c3c:	85 d2                	test   %edx,%edx
  801c3e:	78 12                	js     801c52 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	ff 75 10             	pushl  0x10(%ebp)
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	52                   	push   %edx
  801c4a:	e8 59 01 00 00       	call   801da8 <nsipc_connect>
  801c4f:	83 c4 10             	add    $0x10,%esp
}
  801c52:	c9                   	leave  
  801c53:	c3                   	ret    

00801c54 <listen>:

int
listen(int s, int backlog)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	e8 a4 fe ff ff       	call   801b06 <fd2sockid>
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	85 d2                	test   %edx,%edx
  801c66:	78 0f                	js     801c77 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c68:	83 ec 08             	sub    $0x8,%esp
  801c6b:	ff 75 0c             	pushl  0xc(%ebp)
  801c6e:	52                   	push   %edx
  801c6f:	e8 69 01 00 00       	call   801ddd <nsipc_listen>
  801c74:	83 c4 10             	add    $0x10,%esp
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c7f:	ff 75 10             	pushl  0x10(%ebp)
  801c82:	ff 75 0c             	pushl  0xc(%ebp)
  801c85:	ff 75 08             	pushl  0x8(%ebp)
  801c88:	e8 3c 02 00 00       	call   801ec9 <nsipc_socket>
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	85 d2                	test   %edx,%edx
  801c94:	78 05                	js     801c9b <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801c96:	e8 9b fe ff ff       	call   801b36 <alloc_sockfd>
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ca6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cad:	75 12                	jne    801cc1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	6a 02                	push   $0x2
  801cb4:	e8 5b f5 ff ff       	call   801214 <ipc_find_env>
  801cb9:	a3 04 40 80 00       	mov    %eax,0x804004
  801cbe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cc1:	6a 07                	push   $0x7
  801cc3:	68 00 60 80 00       	push   $0x806000
  801cc8:	53                   	push   %ebx
  801cc9:	ff 35 04 40 80 00    	pushl  0x804004
  801ccf:	e8 ec f4 ff ff       	call   8011c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cd4:	83 c4 0c             	add    $0xc,%esp
  801cd7:	6a 00                	push   $0x0
  801cd9:	6a 00                	push   $0x0
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 75 f4 ff ff       	call   801157 <ipc_recv>
}
  801ce2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cf7:	8b 06                	mov    (%esi),%eax
  801cf9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801d03:	e8 95 ff ff ff       	call   801c9d <nsipc>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 20                	js     801d2e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	ff 35 10 60 80 00    	pushl  0x806010
  801d17:	68 00 60 80 00       	push   $0x806000
  801d1c:	ff 75 0c             	pushl  0xc(%ebp)
  801d1f:	e8 26 ec ff ff       	call   80094a <memmove>
		*addrlen = ret->ret_addrlen;
  801d24:	a1 10 60 80 00       	mov    0x806010,%eax
  801d29:	89 06                	mov    %eax,(%esi)
  801d2b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d2e:	89 d8                	mov    %ebx,%eax
  801d30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	53                   	push   %ebx
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d41:	8b 45 08             	mov    0x8(%ebp),%eax
  801d44:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d49:	53                   	push   %ebx
  801d4a:	ff 75 0c             	pushl  0xc(%ebp)
  801d4d:	68 04 60 80 00       	push   $0x806004
  801d52:	e8 f3 eb ff ff       	call   80094a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d57:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d5d:	b8 02 00 00 00       	mov    $0x2,%eax
  801d62:	e8 36 ff ff ff       	call   801c9d <nsipc>
}
  801d67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d82:	b8 03 00 00 00       	mov    $0x3,%eax
  801d87:	e8 11 ff ff ff       	call   801c9d <nsipc>
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <nsipc_close>:

int
nsipc_close(int s)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d9c:	b8 04 00 00 00       	mov    $0x4,%eax
  801da1:	e8 f7 fe ff ff       	call   801c9d <nsipc>
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	53                   	push   %ebx
  801dac:	83 ec 08             	sub    $0x8,%esp
  801daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dba:	53                   	push   %ebx
  801dbb:	ff 75 0c             	pushl  0xc(%ebp)
  801dbe:	68 04 60 80 00       	push   $0x806004
  801dc3:	e8 82 eb ff ff       	call   80094a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dc8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801dce:	b8 05 00 00 00       	mov    $0x5,%eax
  801dd3:	e8 c5 fe ff ff       	call   801c9d <nsipc>
}
  801dd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ddb:	c9                   	leave  
  801ddc:	c3                   	ret    

00801ddd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dee:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801df3:	b8 06 00 00 00       	mov    $0x6,%eax
  801df8:	e8 a0 fe ff ff       	call   801c9d <nsipc>
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e07:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e0f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e15:	8b 45 14             	mov    0x14(%ebp),%eax
  801e18:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e1d:	b8 07 00 00 00       	mov    $0x7,%eax
  801e22:	e8 76 fe ff ff       	call   801c9d <nsipc>
  801e27:	89 c3                	mov    %eax,%ebx
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 35                	js     801e62 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e2d:	39 f0                	cmp    %esi,%eax
  801e2f:	7f 07                	jg     801e38 <nsipc_recv+0x39>
  801e31:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e36:	7e 16                	jle    801e4e <nsipc_recv+0x4f>
  801e38:	68 3f 2d 80 00       	push   $0x802d3f
  801e3d:	68 07 2d 80 00       	push   $0x802d07
  801e42:	6a 62                	push   $0x62
  801e44:	68 54 2d 80 00       	push   $0x802d54
  801e49:	e8 0a e3 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e4e:	83 ec 04             	sub    $0x4,%esp
  801e51:	50                   	push   %eax
  801e52:	68 00 60 80 00       	push   $0x806000
  801e57:	ff 75 0c             	pushl  0xc(%ebp)
  801e5a:	e8 eb ea ff ff       	call   80094a <memmove>
  801e5f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e62:	89 d8                	mov    %ebx,%eax
  801e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	53                   	push   %ebx
  801e6f:	83 ec 04             	sub    $0x4,%esp
  801e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e75:	8b 45 08             	mov    0x8(%ebp),%eax
  801e78:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e7d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e83:	7e 16                	jle    801e9b <nsipc_send+0x30>
  801e85:	68 60 2d 80 00       	push   $0x802d60
  801e8a:	68 07 2d 80 00       	push   $0x802d07
  801e8f:	6a 6d                	push   $0x6d
  801e91:	68 54 2d 80 00       	push   $0x802d54
  801e96:	e8 bd e2 ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e9b:	83 ec 04             	sub    $0x4,%esp
  801e9e:	53                   	push   %ebx
  801e9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ea2:	68 0c 60 80 00       	push   $0x80600c
  801ea7:	e8 9e ea ff ff       	call   80094a <memmove>
	nsipcbuf.send.req_size = size;
  801eac:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801eb2:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801eba:	b8 08 00 00 00       	mov    $0x8,%eax
  801ebf:	e8 d9 fd ff ff       	call   801c9d <nsipc>
}
  801ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eda:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801edf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ee7:	b8 09 00 00 00       	mov    $0x9,%eax
  801eec:	e8 ac fd ff ff       	call   801c9d <nsipc>
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	56                   	push   %esi
  801ef7:	53                   	push   %ebx
  801ef8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	ff 75 08             	pushl  0x8(%ebp)
  801f01:	e8 56 f3 ff ff       	call   80125c <fd2data>
  801f06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f08:	83 c4 08             	add    $0x8,%esp
  801f0b:	68 6c 2d 80 00       	push   $0x802d6c
  801f10:	53                   	push   %ebx
  801f11:	e8 a2 e8 ff ff       	call   8007b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f16:	8b 56 04             	mov    0x4(%esi),%edx
  801f19:	89 d0                	mov    %edx,%eax
  801f1b:	2b 06                	sub    (%esi),%eax
  801f1d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f23:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f2a:	00 00 00 
	stat->st_dev = &devpipe;
  801f2d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f34:	30 80 00 
	return 0;
}
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    

00801f43 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	53                   	push   %ebx
  801f47:	83 ec 0c             	sub    $0xc,%esp
  801f4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f4d:	53                   	push   %ebx
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 f1 ec ff ff       	call   800c46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f55:	89 1c 24             	mov    %ebx,(%esp)
  801f58:	e8 ff f2 ff ff       	call   80125c <fd2data>
  801f5d:	83 c4 08             	add    $0x8,%esp
  801f60:	50                   	push   %eax
  801f61:	6a 00                	push   $0x0
  801f63:	e8 de ec ff ff       	call   800c46 <sys_page_unmap>
}
  801f68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    

00801f6d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	57                   	push   %edi
  801f71:	56                   	push   %esi
  801f72:	53                   	push   %ebx
  801f73:	83 ec 1c             	sub    $0x1c,%esp
  801f76:	89 c6                	mov    %eax,%esi
  801f78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f7b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f80:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f83:	83 ec 0c             	sub    $0xc,%esp
  801f86:	56                   	push   %esi
  801f87:	e8 d6 04 00 00       	call   802462 <pageref>
  801f8c:	89 c7                	mov    %eax,%edi
  801f8e:	83 c4 04             	add    $0x4,%esp
  801f91:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f94:	e8 c9 04 00 00       	call   802462 <pageref>
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	39 c7                	cmp    %eax,%edi
  801f9e:	0f 94 c2             	sete   %dl
  801fa1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801fa4:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801faa:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801fad:	39 fb                	cmp    %edi,%ebx
  801faf:	74 19                	je     801fca <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801fb1:	84 d2                	test   %dl,%dl
  801fb3:	74 c6                	je     801f7b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fb5:	8b 51 58             	mov    0x58(%ecx),%edx
  801fb8:	50                   	push   %eax
  801fb9:	52                   	push   %edx
  801fba:	53                   	push   %ebx
  801fbb:	68 73 2d 80 00       	push   $0x802d73
  801fc0:	e8 6c e2 ff ff       	call   800231 <cprintf>
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	eb b1                	jmp    801f7b <_pipeisclosed+0xe>
	}
}
  801fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	83 ec 28             	sub    $0x28,%esp
  801fdb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fde:	56                   	push   %esi
  801fdf:	e8 78 f2 ff ff       	call   80125c <fd2data>
  801fe4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	bf 00 00 00 00       	mov    $0x0,%edi
  801fee:	eb 4b                	jmp    80203b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ff0:	89 da                	mov    %ebx,%edx
  801ff2:	89 f0                	mov    %esi,%eax
  801ff4:	e8 74 ff ff ff       	call   801f6d <_pipeisclosed>
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	75 48                	jne    802045 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ffd:	e8 a0 eb ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802002:	8b 43 04             	mov    0x4(%ebx),%eax
  802005:	8b 0b                	mov    (%ebx),%ecx
  802007:	8d 51 20             	lea    0x20(%ecx),%edx
  80200a:	39 d0                	cmp    %edx,%eax
  80200c:	73 e2                	jae    801ff0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80200e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802011:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802015:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802018:	89 c2                	mov    %eax,%edx
  80201a:	c1 fa 1f             	sar    $0x1f,%edx
  80201d:	89 d1                	mov    %edx,%ecx
  80201f:	c1 e9 1b             	shr    $0x1b,%ecx
  802022:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802025:	83 e2 1f             	and    $0x1f,%edx
  802028:	29 ca                	sub    %ecx,%edx
  80202a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80202e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802032:	83 c0 01             	add    $0x1,%eax
  802035:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802038:	83 c7 01             	add    $0x1,%edi
  80203b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80203e:	75 c2                	jne    802002 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802040:	8b 45 10             	mov    0x10(%ebp),%eax
  802043:	eb 05                	jmp    80204a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80204a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    

00802052 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	57                   	push   %edi
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 18             	sub    $0x18,%esp
  80205b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80205e:	57                   	push   %edi
  80205f:	e8 f8 f1 ff ff       	call   80125c <fd2data>
  802064:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	bb 00 00 00 00       	mov    $0x0,%ebx
  80206e:	eb 3d                	jmp    8020ad <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802070:	85 db                	test   %ebx,%ebx
  802072:	74 04                	je     802078 <devpipe_read+0x26>
				return i;
  802074:	89 d8                	mov    %ebx,%eax
  802076:	eb 44                	jmp    8020bc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802078:	89 f2                	mov    %esi,%edx
  80207a:	89 f8                	mov    %edi,%eax
  80207c:	e8 ec fe ff ff       	call   801f6d <_pipeisclosed>
  802081:	85 c0                	test   %eax,%eax
  802083:	75 32                	jne    8020b7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802085:	e8 18 eb ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80208a:	8b 06                	mov    (%esi),%eax
  80208c:	3b 46 04             	cmp    0x4(%esi),%eax
  80208f:	74 df                	je     802070 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802091:	99                   	cltd   
  802092:	c1 ea 1b             	shr    $0x1b,%edx
  802095:	01 d0                	add    %edx,%eax
  802097:	83 e0 1f             	and    $0x1f,%eax
  80209a:	29 d0                	sub    %edx,%eax
  80209c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020a7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020aa:	83 c3 01             	add    $0x1,%ebx
  8020ad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020b0:	75 d8                	jne    80208a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b5:	eb 05                	jmp    8020bc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    

008020c4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	56                   	push   %esi
  8020c8:	53                   	push   %ebx
  8020c9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cf:	50                   	push   %eax
  8020d0:	e8 9e f1 ff ff       	call   801273 <fd_alloc>
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	89 c2                	mov    %eax,%edx
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	0f 88 2c 01 00 00    	js     80220e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e2:	83 ec 04             	sub    $0x4,%esp
  8020e5:	68 07 04 00 00       	push   $0x407
  8020ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ed:	6a 00                	push   $0x0
  8020ef:	e8 cd ea ff ff       	call   800bc1 <sys_page_alloc>
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	89 c2                	mov    %eax,%edx
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	0f 88 0d 01 00 00    	js     80220e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802101:	83 ec 0c             	sub    $0xc,%esp
  802104:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802107:	50                   	push   %eax
  802108:	e8 66 f1 ff ff       	call   801273 <fd_alloc>
  80210d:	89 c3                	mov    %eax,%ebx
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	85 c0                	test   %eax,%eax
  802114:	0f 88 e2 00 00 00    	js     8021fc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211a:	83 ec 04             	sub    $0x4,%esp
  80211d:	68 07 04 00 00       	push   $0x407
  802122:	ff 75 f0             	pushl  -0x10(%ebp)
  802125:	6a 00                	push   $0x0
  802127:	e8 95 ea ff ff       	call   800bc1 <sys_page_alloc>
  80212c:	89 c3                	mov    %eax,%ebx
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	85 c0                	test   %eax,%eax
  802133:	0f 88 c3 00 00 00    	js     8021fc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802139:	83 ec 0c             	sub    $0xc,%esp
  80213c:	ff 75 f4             	pushl  -0xc(%ebp)
  80213f:	e8 18 f1 ff ff       	call   80125c <fd2data>
  802144:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802146:	83 c4 0c             	add    $0xc,%esp
  802149:	68 07 04 00 00       	push   $0x407
  80214e:	50                   	push   %eax
  80214f:	6a 00                	push   $0x0
  802151:	e8 6b ea ff ff       	call   800bc1 <sys_page_alloc>
  802156:	89 c3                	mov    %eax,%ebx
  802158:	83 c4 10             	add    $0x10,%esp
  80215b:	85 c0                	test   %eax,%eax
  80215d:	0f 88 89 00 00 00    	js     8021ec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	ff 75 f0             	pushl  -0x10(%ebp)
  802169:	e8 ee f0 ff ff       	call   80125c <fd2data>
  80216e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802175:	50                   	push   %eax
  802176:	6a 00                	push   $0x0
  802178:	56                   	push   %esi
  802179:	6a 00                	push   $0x0
  80217b:	e8 84 ea ff ff       	call   800c04 <sys_page_map>
  802180:	89 c3                	mov    %eax,%ebx
  802182:	83 c4 20             	add    $0x20,%esp
  802185:	85 c0                	test   %eax,%eax
  802187:	78 55                	js     8021de <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802189:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802192:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802197:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80219e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021b3:	83 ec 0c             	sub    $0xc,%esp
  8021b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b9:	e8 8e f0 ff ff       	call   80124c <fd2num>
  8021be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021c1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021c3:	83 c4 04             	add    $0x4,%esp
  8021c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c9:	e8 7e f0 ff ff       	call   80124c <fd2num>
  8021ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021d1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8021dc:	eb 30                	jmp    80220e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021de:	83 ec 08             	sub    $0x8,%esp
  8021e1:	56                   	push   %esi
  8021e2:	6a 00                	push   $0x0
  8021e4:	e8 5d ea ff ff       	call   800c46 <sys_page_unmap>
  8021e9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021ec:	83 ec 08             	sub    $0x8,%esp
  8021ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f2:	6a 00                	push   $0x0
  8021f4:	e8 4d ea ff ff       	call   800c46 <sys_page_unmap>
  8021f9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021fc:	83 ec 08             	sub    $0x8,%esp
  8021ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802202:	6a 00                	push   $0x0
  802204:	e8 3d ea ff ff       	call   800c46 <sys_page_unmap>
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80220e:	89 d0                	mov    %edx,%eax
  802210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80221d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802220:	50                   	push   %eax
  802221:	ff 75 08             	pushl  0x8(%ebp)
  802224:	e8 99 f0 ff ff       	call   8012c2 <fd_lookup>
  802229:	89 c2                	mov    %eax,%edx
  80222b:	83 c4 10             	add    $0x10,%esp
  80222e:	85 d2                	test   %edx,%edx
  802230:	78 18                	js     80224a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802232:	83 ec 0c             	sub    $0xc,%esp
  802235:	ff 75 f4             	pushl  -0xc(%ebp)
  802238:	e8 1f f0 ff ff       	call   80125c <fd2data>
	return _pipeisclosed(fd, p);
  80223d:	89 c2                	mov    %eax,%edx
  80223f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802242:	e8 26 fd ff ff       	call   801f6d <_pipeisclosed>
  802247:	83 c4 10             	add    $0x10,%esp
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80224f:	b8 00 00 00 00       	mov    $0x0,%eax
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    

00802256 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80225c:	68 8b 2d 80 00       	push   $0x802d8b
  802261:	ff 75 0c             	pushl  0xc(%ebp)
  802264:	e8 4f e5 ff ff       	call   8007b8 <strcpy>
	return 0;
}
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	57                   	push   %edi
  802274:	56                   	push   %esi
  802275:	53                   	push   %ebx
  802276:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80227c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802281:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802287:	eb 2d                	jmp    8022b6 <devcons_write+0x46>
		m = n - tot;
  802289:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80228c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80228e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802291:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802296:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802299:	83 ec 04             	sub    $0x4,%esp
  80229c:	53                   	push   %ebx
  80229d:	03 45 0c             	add    0xc(%ebp),%eax
  8022a0:	50                   	push   %eax
  8022a1:	57                   	push   %edi
  8022a2:	e8 a3 e6 ff ff       	call   80094a <memmove>
		sys_cputs(buf, m);
  8022a7:	83 c4 08             	add    $0x8,%esp
  8022aa:	53                   	push   %ebx
  8022ab:	57                   	push   %edi
  8022ac:	e8 54 e8 ff ff       	call   800b05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b1:	01 de                	add    %ebx,%esi
  8022b3:	83 c4 10             	add    $0x10,%esp
  8022b6:	89 f0                	mov    %esi,%eax
  8022b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022bb:	72 cc                	jb     802289 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8022cb:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8022d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022d4:	75 07                	jne    8022dd <devcons_read+0x18>
  8022d6:	eb 28                	jmp    802300 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022d8:	e8 c5 e8 ff ff       	call   800ba2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022dd:	e8 41 e8 ff ff       	call   800b23 <sys_cgetc>
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	74 f2                	je     8022d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	78 16                	js     802300 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022ea:	83 f8 04             	cmp    $0x4,%eax
  8022ed:	74 0c                	je     8022fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f2:	88 02                	mov    %al,(%edx)
	return 1;
  8022f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f9:	eb 05                	jmp    802300 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802300:	c9                   	leave  
  802301:	c3                   	ret    

00802302 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802308:	8b 45 08             	mov    0x8(%ebp),%eax
  80230b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80230e:	6a 01                	push   $0x1
  802310:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802313:	50                   	push   %eax
  802314:	e8 ec e7 ff ff       	call   800b05 <sys_cputs>
  802319:	83 c4 10             	add    $0x10,%esp
}
  80231c:	c9                   	leave  
  80231d:	c3                   	ret    

0080231e <getchar>:

int
getchar(void)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802324:	6a 01                	push   $0x1
  802326:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802329:	50                   	push   %eax
  80232a:	6a 00                	push   $0x0
  80232c:	e8 00 f2 ff ff       	call   801531 <read>
	if (r < 0)
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	85 c0                	test   %eax,%eax
  802336:	78 0f                	js     802347 <getchar+0x29>
		return r;
	if (r < 1)
  802338:	85 c0                	test   %eax,%eax
  80233a:	7e 06                	jle    802342 <getchar+0x24>
		return -E_EOF;
	return c;
  80233c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802340:	eb 05                	jmp    802347 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802342:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802347:	c9                   	leave  
  802348:	c3                   	ret    

00802349 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802349:	55                   	push   %ebp
  80234a:	89 e5                	mov    %esp,%ebp
  80234c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80234f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802352:	50                   	push   %eax
  802353:	ff 75 08             	pushl  0x8(%ebp)
  802356:	e8 67 ef ff ff       	call   8012c2 <fd_lookup>
  80235b:	83 c4 10             	add    $0x10,%esp
  80235e:	85 c0                	test   %eax,%eax
  802360:	78 11                	js     802373 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802365:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80236b:	39 10                	cmp    %edx,(%eax)
  80236d:	0f 94 c0             	sete   %al
  802370:	0f b6 c0             	movzbl %al,%eax
}
  802373:	c9                   	leave  
  802374:	c3                   	ret    

00802375 <opencons>:

int
opencons(void)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80237b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237e:	50                   	push   %eax
  80237f:	e8 ef ee ff ff       	call   801273 <fd_alloc>
  802384:	83 c4 10             	add    $0x10,%esp
		return r;
  802387:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802389:	85 c0                	test   %eax,%eax
  80238b:	78 3e                	js     8023cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80238d:	83 ec 04             	sub    $0x4,%esp
  802390:	68 07 04 00 00       	push   $0x407
  802395:	ff 75 f4             	pushl  -0xc(%ebp)
  802398:	6a 00                	push   $0x0
  80239a:	e8 22 e8 ff ff       	call   800bc1 <sys_page_alloc>
  80239f:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	78 23                	js     8023cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023a8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023bd:	83 ec 0c             	sub    $0xc,%esp
  8023c0:	50                   	push   %eax
  8023c1:	e8 86 ee ff ff       	call   80124c <fd2num>
  8023c6:	89 c2                	mov    %eax,%edx
  8023c8:	83 c4 10             	add    $0x10,%esp
}
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	c9                   	leave  
  8023ce:	c3                   	ret    

008023cf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023d5:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023dc:	75 2c                	jne    80240a <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8023de:	83 ec 04             	sub    $0x4,%esp
  8023e1:	6a 07                	push   $0x7
  8023e3:	68 00 f0 bf ee       	push   $0xeebff000
  8023e8:	6a 00                	push   $0x0
  8023ea:	e8 d2 e7 ff ff       	call   800bc1 <sys_page_alloc>
  8023ef:	83 c4 10             	add    $0x10,%esp
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	74 14                	je     80240a <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8023f6:	83 ec 04             	sub    $0x4,%esp
  8023f9:	68 98 2d 80 00       	push   $0x802d98
  8023fe:	6a 21                	push   $0x21
  802400:	68 fc 2d 80 00       	push   $0x802dfc
  802405:	e8 4e dd ff ff       	call   800158 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80240a:	8b 45 08             	mov    0x8(%ebp),%eax
  80240d:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802412:	83 ec 08             	sub    $0x8,%esp
  802415:	68 3e 24 80 00       	push   $0x80243e
  80241a:	6a 00                	push   $0x0
  80241c:	e8 eb e8 ff ff       	call   800d0c <sys_env_set_pgfault_upcall>
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	85 c0                	test   %eax,%eax
  802426:	79 14                	jns    80243c <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802428:	83 ec 04             	sub    $0x4,%esp
  80242b:	68 c4 2d 80 00       	push   $0x802dc4
  802430:	6a 29                	push   $0x29
  802432:	68 fc 2d 80 00       	push   $0x802dfc
  802437:	e8 1c dd ff ff       	call   800158 <_panic>
}
  80243c:	c9                   	leave  
  80243d:	c3                   	ret    

0080243e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80243e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80243f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802444:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802446:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802449:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80244e:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802452:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802456:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802458:	83 c4 08             	add    $0x8,%esp
        popal
  80245b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80245c:	83 c4 04             	add    $0x4,%esp
        popfl
  80245f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802460:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802461:	c3                   	ret    

00802462 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802468:	89 d0                	mov    %edx,%eax
  80246a:	c1 e8 16             	shr    $0x16,%eax
  80246d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802474:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802479:	f6 c1 01             	test   $0x1,%cl
  80247c:	74 1d                	je     80249b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80247e:	c1 ea 0c             	shr    $0xc,%edx
  802481:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802488:	f6 c2 01             	test   $0x1,%dl
  80248b:	74 0e                	je     80249b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80248d:	c1 ea 0c             	shr    $0xc,%edx
  802490:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802497:	ef 
  802498:	0f b7 c0             	movzwl %ax,%eax
}
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    
  80249d:	66 90                	xchg   %ax,%ax
  80249f:	90                   	nop

008024a0 <__udivdi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	83 ec 10             	sub    $0x10,%esp
  8024a6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8024aa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8024ae:	8b 74 24 24          	mov    0x24(%esp),%esi
  8024b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024b6:	85 d2                	test   %edx,%edx
  8024b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024bc:	89 34 24             	mov    %esi,(%esp)
  8024bf:	89 c8                	mov    %ecx,%eax
  8024c1:	75 35                	jne    8024f8 <__udivdi3+0x58>
  8024c3:	39 f1                	cmp    %esi,%ecx
  8024c5:	0f 87 bd 00 00 00    	ja     802588 <__udivdi3+0xe8>
  8024cb:	85 c9                	test   %ecx,%ecx
  8024cd:	89 cd                	mov    %ecx,%ebp
  8024cf:	75 0b                	jne    8024dc <__udivdi3+0x3c>
  8024d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d6:	31 d2                	xor    %edx,%edx
  8024d8:	f7 f1                	div    %ecx
  8024da:	89 c5                	mov    %eax,%ebp
  8024dc:	89 f0                	mov    %esi,%eax
  8024de:	31 d2                	xor    %edx,%edx
  8024e0:	f7 f5                	div    %ebp
  8024e2:	89 c6                	mov    %eax,%esi
  8024e4:	89 f8                	mov    %edi,%eax
  8024e6:	f7 f5                	div    %ebp
  8024e8:	89 f2                	mov    %esi,%edx
  8024ea:	83 c4 10             	add    $0x10,%esp
  8024ed:	5e                   	pop    %esi
  8024ee:	5f                   	pop    %edi
  8024ef:	5d                   	pop    %ebp
  8024f0:	c3                   	ret    
  8024f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	3b 14 24             	cmp    (%esp),%edx
  8024fb:	77 7b                	ja     802578 <__udivdi3+0xd8>
  8024fd:	0f bd f2             	bsr    %edx,%esi
  802500:	83 f6 1f             	xor    $0x1f,%esi
  802503:	0f 84 97 00 00 00    	je     8025a0 <__udivdi3+0x100>
  802509:	bd 20 00 00 00       	mov    $0x20,%ebp
  80250e:	89 d7                	mov    %edx,%edi
  802510:	89 f1                	mov    %esi,%ecx
  802512:	29 f5                	sub    %esi,%ebp
  802514:	d3 e7                	shl    %cl,%edi
  802516:	89 c2                	mov    %eax,%edx
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	d3 ea                	shr    %cl,%edx
  80251c:	89 f1                	mov    %esi,%ecx
  80251e:	09 fa                	or     %edi,%edx
  802520:	8b 3c 24             	mov    (%esp),%edi
  802523:	d3 e0                	shl    %cl,%eax
  802525:	89 54 24 08          	mov    %edx,0x8(%esp)
  802529:	89 e9                	mov    %ebp,%ecx
  80252b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80252f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802533:	89 fa                	mov    %edi,%edx
  802535:	d3 ea                	shr    %cl,%edx
  802537:	89 f1                	mov    %esi,%ecx
  802539:	d3 e7                	shl    %cl,%edi
  80253b:	89 e9                	mov    %ebp,%ecx
  80253d:	d3 e8                	shr    %cl,%eax
  80253f:	09 c7                	or     %eax,%edi
  802541:	89 f8                	mov    %edi,%eax
  802543:	f7 74 24 08          	divl   0x8(%esp)
  802547:	89 d5                	mov    %edx,%ebp
  802549:	89 c7                	mov    %eax,%edi
  80254b:	f7 64 24 0c          	mull   0xc(%esp)
  80254f:	39 d5                	cmp    %edx,%ebp
  802551:	89 14 24             	mov    %edx,(%esp)
  802554:	72 11                	jb     802567 <__udivdi3+0xc7>
  802556:	8b 54 24 04          	mov    0x4(%esp),%edx
  80255a:	89 f1                	mov    %esi,%ecx
  80255c:	d3 e2                	shl    %cl,%edx
  80255e:	39 c2                	cmp    %eax,%edx
  802560:	73 5e                	jae    8025c0 <__udivdi3+0x120>
  802562:	3b 2c 24             	cmp    (%esp),%ebp
  802565:	75 59                	jne    8025c0 <__udivdi3+0x120>
  802567:	8d 47 ff             	lea    -0x1(%edi),%eax
  80256a:	31 f6                	xor    %esi,%esi
  80256c:	89 f2                	mov    %esi,%edx
  80256e:	83 c4 10             	add    $0x10,%esp
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    
  802575:	8d 76 00             	lea    0x0(%esi),%esi
  802578:	31 f6                	xor    %esi,%esi
  80257a:	31 c0                	xor    %eax,%eax
  80257c:	89 f2                	mov    %esi,%edx
  80257e:	83 c4 10             	add    $0x10,%esp
  802581:	5e                   	pop    %esi
  802582:	5f                   	pop    %edi
  802583:	5d                   	pop    %ebp
  802584:	c3                   	ret    
  802585:	8d 76 00             	lea    0x0(%esi),%esi
  802588:	89 f2                	mov    %esi,%edx
  80258a:	31 f6                	xor    %esi,%esi
  80258c:	89 f8                	mov    %edi,%eax
  80258e:	f7 f1                	div    %ecx
  802590:	89 f2                	mov    %esi,%edx
  802592:	83 c4 10             	add    $0x10,%esp
  802595:	5e                   	pop    %esi
  802596:	5f                   	pop    %edi
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8025a4:	76 0b                	jbe    8025b1 <__udivdi3+0x111>
  8025a6:	31 c0                	xor    %eax,%eax
  8025a8:	3b 14 24             	cmp    (%esp),%edx
  8025ab:	0f 83 37 ff ff ff    	jae    8024e8 <__udivdi3+0x48>
  8025b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b6:	e9 2d ff ff ff       	jmp    8024e8 <__udivdi3+0x48>
  8025bb:	90                   	nop
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	89 f8                	mov    %edi,%eax
  8025c2:	31 f6                	xor    %esi,%esi
  8025c4:	e9 1f ff ff ff       	jmp    8024e8 <__udivdi3+0x48>
  8025c9:	66 90                	xchg   %ax,%ax
  8025cb:	66 90                	xchg   %ax,%ax
  8025cd:	66 90                	xchg   %ax,%ax
  8025cf:	90                   	nop

008025d0 <__umoddi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	83 ec 20             	sub    $0x20,%esp
  8025d6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8025da:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025de:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025e2:	89 c6                	mov    %eax,%esi
  8025e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025e8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025ec:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8025f0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025f4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8025f8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8025fc:	85 c0                	test   %eax,%eax
  8025fe:	89 c2                	mov    %eax,%edx
  802600:	75 1e                	jne    802620 <__umoddi3+0x50>
  802602:	39 f7                	cmp    %esi,%edi
  802604:	76 52                	jbe    802658 <__umoddi3+0x88>
  802606:	89 c8                	mov    %ecx,%eax
  802608:	89 f2                	mov    %esi,%edx
  80260a:	f7 f7                	div    %edi
  80260c:	89 d0                	mov    %edx,%eax
  80260e:	31 d2                	xor    %edx,%edx
  802610:	83 c4 20             	add    $0x20,%esp
  802613:	5e                   	pop    %esi
  802614:	5f                   	pop    %edi
  802615:	5d                   	pop    %ebp
  802616:	c3                   	ret    
  802617:	89 f6                	mov    %esi,%esi
  802619:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802620:	39 f0                	cmp    %esi,%eax
  802622:	77 5c                	ja     802680 <__umoddi3+0xb0>
  802624:	0f bd e8             	bsr    %eax,%ebp
  802627:	83 f5 1f             	xor    $0x1f,%ebp
  80262a:	75 64                	jne    802690 <__umoddi3+0xc0>
  80262c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802630:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802634:	0f 86 f6 00 00 00    	jbe    802730 <__umoddi3+0x160>
  80263a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80263e:	0f 82 ec 00 00 00    	jb     802730 <__umoddi3+0x160>
  802644:	8b 44 24 14          	mov    0x14(%esp),%eax
  802648:	8b 54 24 18          	mov    0x18(%esp),%edx
  80264c:	83 c4 20             	add    $0x20,%esp
  80264f:	5e                   	pop    %esi
  802650:	5f                   	pop    %edi
  802651:	5d                   	pop    %ebp
  802652:	c3                   	ret    
  802653:	90                   	nop
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	85 ff                	test   %edi,%edi
  80265a:	89 fd                	mov    %edi,%ebp
  80265c:	75 0b                	jne    802669 <__umoddi3+0x99>
  80265e:	b8 01 00 00 00       	mov    $0x1,%eax
  802663:	31 d2                	xor    %edx,%edx
  802665:	f7 f7                	div    %edi
  802667:	89 c5                	mov    %eax,%ebp
  802669:	8b 44 24 10          	mov    0x10(%esp),%eax
  80266d:	31 d2                	xor    %edx,%edx
  80266f:	f7 f5                	div    %ebp
  802671:	89 c8                	mov    %ecx,%eax
  802673:	f7 f5                	div    %ebp
  802675:	eb 95                	jmp    80260c <__umoddi3+0x3c>
  802677:	89 f6                	mov    %esi,%esi
  802679:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 20             	add    $0x20,%esp
  802687:	5e                   	pop    %esi
  802688:	5f                   	pop    %edi
  802689:	5d                   	pop    %ebp
  80268a:	c3                   	ret    
  80268b:	90                   	nop
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	b8 20 00 00 00       	mov    $0x20,%eax
  802695:	89 e9                	mov    %ebp,%ecx
  802697:	29 e8                	sub    %ebp,%eax
  802699:	d3 e2                	shl    %cl,%edx
  80269b:	89 c7                	mov    %eax,%edi
  80269d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8026a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 c1                	mov    %eax,%ecx
  8026ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026af:	09 d1                	or     %edx,%ecx
  8026b1:	89 fa                	mov    %edi,%edx
  8026b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026b7:	89 e9                	mov    %ebp,%ecx
  8026b9:	d3 e0                	shl    %cl,%eax
  8026bb:	89 f9                	mov    %edi,%ecx
  8026bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026c1:	89 f0                	mov    %esi,%eax
  8026c3:	d3 e8                	shr    %cl,%eax
  8026c5:	89 e9                	mov    %ebp,%ecx
  8026c7:	89 c7                	mov    %eax,%edi
  8026c9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026cd:	d3 e6                	shl    %cl,%esi
  8026cf:	89 d1                	mov    %edx,%ecx
  8026d1:	89 fa                	mov    %edi,%edx
  8026d3:	d3 e8                	shr    %cl,%eax
  8026d5:	89 e9                	mov    %ebp,%ecx
  8026d7:	09 f0                	or     %esi,%eax
  8026d9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8026dd:	f7 74 24 10          	divl   0x10(%esp)
  8026e1:	d3 e6                	shl    %cl,%esi
  8026e3:	89 d1                	mov    %edx,%ecx
  8026e5:	f7 64 24 0c          	mull   0xc(%esp)
  8026e9:	39 d1                	cmp    %edx,%ecx
  8026eb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8026ef:	89 d7                	mov    %edx,%edi
  8026f1:	89 c6                	mov    %eax,%esi
  8026f3:	72 0a                	jb     8026ff <__umoddi3+0x12f>
  8026f5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8026f9:	73 10                	jae    80270b <__umoddi3+0x13b>
  8026fb:	39 d1                	cmp    %edx,%ecx
  8026fd:	75 0c                	jne    80270b <__umoddi3+0x13b>
  8026ff:	89 d7                	mov    %edx,%edi
  802701:	89 c6                	mov    %eax,%esi
  802703:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802707:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80270b:	89 ca                	mov    %ecx,%edx
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802713:	29 f0                	sub    %esi,%eax
  802715:	19 fa                	sbb    %edi,%edx
  802717:	d3 e8                	shr    %cl,%eax
  802719:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80271e:	89 d7                	mov    %edx,%edi
  802720:	d3 e7                	shl    %cl,%edi
  802722:	89 e9                	mov    %ebp,%ecx
  802724:	09 f8                	or     %edi,%eax
  802726:	d3 ea                	shr    %cl,%edx
  802728:	83 c4 20             	add    $0x20,%esp
  80272b:	5e                   	pop    %esi
  80272c:	5f                   	pop    %edi
  80272d:	5d                   	pop    %ebp
  80272e:	c3                   	ret    
  80272f:	90                   	nop
  802730:	8b 74 24 10          	mov    0x10(%esp),%esi
  802734:	29 f9                	sub    %edi,%ecx
  802736:	19 c6                	sbb    %eax,%esi
  802738:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80273c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802740:	e9 ff fe ff ff       	jmp    802644 <__umoddi3+0x74>
