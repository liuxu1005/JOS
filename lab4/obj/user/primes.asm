
obj/user/primes:     file format elf32-i386


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
  800047:	e8 dd 0f 00 00       	call   801029 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 80 14 80 00       	push   $0x801480
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 e0 0d 00 00       	call   800e4a <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 03 18 80 00       	push   $0x801803
  800079:	6a 1a                	push   $0x1a
  80007b:	68 8c 14 80 00       	push   $0x80148c
  800080:	e8 cb 00 00 00       	call   800150 <_panic>
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
  800094:	e8 90 0f 00 00       	call   801029 <ipc_recv>
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
  8000ab:	e8 e2 0f 00 00       	call   801092 <ipc_send>
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
  8000ba:	e8 8b 0d 00 00       	call   800e4a <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 03 18 80 00       	push   $0x801803
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 8c 14 80 00       	push   $0x80148c
  8000d2:	e8 79 00 00 00       	call   800150 <_panic>
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
  8000eb:	e8 a2 0f 00 00       	call   801092 <ipc_send>
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
  800103:	e8 73 0a 00 00       	call   800b7b <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800141:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800144:	6a 00                	push   $0x0
  800146:	e8 ef 09 00 00       	call   800b3a <sys_env_destroy>
  80014b:	83 c4 10             	add    $0x10,%esp
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015e:	e8 18 0a 00 00       	call   800b7b <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 a4 14 80 00       	push   $0x8014a4
  800173:	e8 b1 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 54 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  80018b:	e8 99 00 00 00       	call   800229 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 37 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 96 01 80 00       	push   $0x800196
  800207:	e8 4f 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 dc 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 d1                	mov    %edx,%ecx
  800252:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800255:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800261:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800268:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80026b:	72 05                	jb     800272 <printnum+0x35>
  80026d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800270:	77 3e                	ja     8002b0 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	ff 75 18             	pushl  0x18(%ebp)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	53                   	push   %ebx
  80027c:	50                   	push   %eax
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 2f 0f 00 00       	call   8011c0 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	89 f8                	mov    %edi,%eax
  80029a:	e8 9e ff ff ff       	call   80023d <printnum>
  80029f:	83 c4 20             	add    $0x20,%esp
  8002a2:	eb 13                	jmp    8002b7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
  8002ad:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	85 db                	test   %ebx,%ebx
  8002b5:	7f ed                	jg     8002a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	56                   	push   %esi
  8002bb:	83 ec 04             	sub    $0x4,%esp
  8002be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ca:	e8 21 10 00 00       	call   8012f0 <__umoddi3>
  8002cf:	83 c4 14             	add    $0x14,%esp
  8002d2:	0f be 80 c7 14 80 00 	movsbl 0x8014c7(%eax),%eax
  8002d9:	50                   	push   %eax
  8002da:	ff d7                	call   *%edi
  8002dc:	83 c4 10             	add    $0x10,%esp
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ea:	83 fa 01             	cmp    $0x1,%edx
  8002ed:	7e 0e                	jle    8002fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	8b 52 04             	mov    0x4(%edx),%edx
  8002fb:	eb 22                	jmp    80031f <getuint+0x38>
	else if (lflag)
  8002fd:	85 d2                	test   %edx,%edx
  8002ff:	74 10                	je     800311 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	eb 0e                	jmp    80031f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800311:	8b 10                	mov    (%eax),%edx
  800313:	8d 4a 04             	lea    0x4(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 02                	mov    (%edx),%eax
  80031a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800327:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	3b 50 04             	cmp    0x4(%eax),%edx
  800330:	73 0a                	jae    80033c <sprintputch+0x1b>
		*b->buf++ = ch;
  800332:	8d 4a 01             	lea    0x1(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	88 02                	mov    %al,(%edx)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	50                   	push   %eax
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	ff 75 0c             	pushl  0xc(%ebp)
  80034e:	ff 75 08             	pushl  0x8(%ebp)
  800351:	e8 05 00 00 00       	call   80035b <vprintfmt>
	va_end(ap);
  800356:	83 c4 10             	add    $0x10,%esp
}
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
  800361:	83 ec 2c             	sub    $0x2c,%esp
  800364:	8b 75 08             	mov    0x8(%ebp),%esi
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036d:	eb 12                	jmp    800381 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036f:	85 c0                	test   %eax,%eax
  800371:	0f 84 90 03 00 00    	je     800707 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	53                   	push   %ebx
  80037b:	50                   	push   %eax
  80037c:	ff d6                	call   *%esi
  80037e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	83 c7 01             	add    $0x1,%edi
  800384:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800388:	83 f8 25             	cmp    $0x25,%eax
  80038b:	75 e2                	jne    80036f <vprintfmt+0x14>
  80038d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800391:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800398:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ab:	eb 07                	jmp    8003b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8d 47 01             	lea    0x1(%edi),%eax
  8003b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ba:	0f b6 07             	movzbl (%edi),%eax
  8003bd:	0f b6 c8             	movzbl %al,%ecx
  8003c0:	83 e8 23             	sub    $0x23,%eax
  8003c3:	3c 55                	cmp    $0x55,%al
  8003c5:	0f 87 21 03 00 00    	ja     8006ec <vprintfmt+0x391>
  8003cb:	0f b6 c0             	movzbl %al,%eax
  8003ce:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003dc:	eb d6                	jmp    8003b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ec:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f6:	83 fa 09             	cmp    $0x9,%edx
  8003f9:	77 39                	ja     800434 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fe:	eb e9                	jmp    8003e9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 48 04             	lea    0x4(%eax),%ecx
  800406:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800411:	eb 27                	jmp    80043a <vprintfmt+0xdf>
  800413:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800416:	85 c0                	test   %eax,%eax
  800418:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041d:	0f 49 c8             	cmovns %eax,%ecx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800426:	eb 8c                	jmp    8003b4 <vprintfmt+0x59>
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800432:	eb 80                	jmp    8003b4 <vprintfmt+0x59>
  800434:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800437:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043e:	0f 89 70 ff ff ff    	jns    8003b4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800444:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800451:	e9 5e ff ff ff       	jmp    8003b4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800456:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045c:	e9 53 ff ff ff       	jmp    8003b4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 30                	pushl  (%eax)
  800470:	ff d6                	call   *%esi
			break;
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800478:	e9 04 ff ff ff       	jmp    800381 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	99                   	cltd   
  800489:	31 d0                	xor    %edx,%eax
  80048b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048d:	83 f8 09             	cmp    $0x9,%eax
  800490:	7f 0b                	jg     80049d <vprintfmt+0x142>
  800492:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  800499:	85 d2                	test   %edx,%edx
  80049b:	75 18                	jne    8004b5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049d:	50                   	push   %eax
  80049e:	68 df 14 80 00       	push   $0x8014df
  8004a3:	53                   	push   %ebx
  8004a4:	56                   	push   %esi
  8004a5:	e8 94 fe ff ff       	call   80033e <printfmt>
  8004aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b0:	e9 cc fe ff ff       	jmp    800381 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b5:	52                   	push   %edx
  8004b6:	68 e8 14 80 00       	push   $0x8014e8
  8004bb:	53                   	push   %ebx
  8004bc:	56                   	push   %esi
  8004bd:	e8 7c fe ff ff       	call   80033e <printfmt>
  8004c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c8:	e9 b4 fe ff ff       	jmp    800381 <vprintfmt+0x26>
  8004cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 50 04             	lea    0x4(%eax),%edx
  8004dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004df:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	ba d8 14 80 00       	mov    $0x8014d8,%edx
  8004e8:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ef:	0f 84 92 00 00 00    	je     800587 <vprintfmt+0x22c>
  8004f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f9:	0f 8e 96 00 00 00    	jle    800595 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	51                   	push   %ecx
  800503:	57                   	push   %edi
  800504:	e8 86 02 00 00       	call   80078f <strnlen>
  800509:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80050c:	29 c1                	sub    %eax,%ecx
  80050e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800514:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800518:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800520:	eb 0f                	jmp    800531 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	ff 75 e0             	pushl  -0x20(%ebp)
  800529:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 ff                	test   %edi,%edi
  800533:	7f ed                	jg     800522 <vprintfmt+0x1c7>
  800535:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800538:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053b:	85 c9                	test   %ecx,%ecx
  80053d:	b8 00 00 00 00       	mov    $0x0,%eax
  800542:	0f 49 c1             	cmovns %ecx,%eax
  800545:	29 c1                	sub    %eax,%ecx
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	89 cb                	mov    %ecx,%ebx
  800552:	eb 4d                	jmp    8005a1 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800554:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800558:	74 1b                	je     800575 <vprintfmt+0x21a>
  80055a:	0f be c0             	movsbl %al,%eax
  80055d:	83 e8 20             	sub    $0x20,%eax
  800560:	83 f8 5e             	cmp    $0x5e,%eax
  800563:	76 10                	jbe    800575 <vprintfmt+0x21a>
					putch('?', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	ff 75 0c             	pushl  0xc(%ebp)
  80056b:	6a 3f                	push   $0x3f
  80056d:	ff 55 08             	call   *0x8(%ebp)
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb 0d                	jmp    800582 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	ff 75 0c             	pushl  0xc(%ebp)
  80057b:	52                   	push   %edx
  80057c:	ff 55 08             	call   *0x8(%ebp)
  80057f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	eb 1a                	jmp    8005a1 <vprintfmt+0x246>
  800587:	89 75 08             	mov    %esi,0x8(%ebp)
  80058a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800590:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800593:	eb 0c                	jmp    8005a1 <vprintfmt+0x246>
  800595:	89 75 08             	mov    %esi,0x8(%ebp)
  800598:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a1:	83 c7 01             	add    $0x1,%edi
  8005a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a8:	0f be d0             	movsbl %al,%edx
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	74 23                	je     8005d2 <vprintfmt+0x277>
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	78 a1                	js     800554 <vprintfmt+0x1f9>
  8005b3:	83 ee 01             	sub    $0x1,%esi
  8005b6:	79 9c                	jns    800554 <vprintfmt+0x1f9>
  8005b8:	89 df                	mov    %ebx,%edi
  8005ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c0:	eb 18                	jmp    8005da <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 20                	push   $0x20
  8005c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ca:	83 ef 01             	sub    $0x1,%edi
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	eb 08                	jmp    8005da <vprintfmt+0x27f>
  8005d2:	89 df                	mov    %ebx,%edi
  8005d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005da:	85 ff                	test   %edi,%edi
  8005dc:	7f e4                	jg     8005c2 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e1:	e9 9b fd ff ff       	jmp    800381 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e6:	83 fa 01             	cmp    $0x1,%edx
  8005e9:	7e 16                	jle    800601 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 08             	lea    0x8(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 50 04             	mov    0x4(%eax),%edx
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ff:	eb 32                	jmp    800633 <vprintfmt+0x2d8>
	else if (lflag)
  800601:	85 d2                	test   %edx,%edx
  800603:	74 18                	je     80061d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800613:	89 c1                	mov    %eax,%ecx
  800615:	c1 f9 1f             	sar    $0x1f,%ecx
  800618:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061b:	eb 16                	jmp    800633 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	89 c1                	mov    %eax,%ecx
  80062d:	c1 f9 1f             	sar    $0x1f,%ecx
  800630:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800633:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800636:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800639:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800642:	79 74                	jns    8006b8 <vprintfmt+0x35d>
				putch('-', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 2d                	push   $0x2d
  80064a:	ff d6                	call   *%esi
				num = -(long long) num;
  80064c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800652:	f7 d8                	neg    %eax
  800654:	83 d2 00             	adc    $0x0,%edx
  800657:	f7 da                	neg    %edx
  800659:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800661:	eb 55                	jmp    8006b8 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 7c fc ff ff       	call   8002e7 <getuint>
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800670:	eb 46                	jmp    8006b8 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 6d fc ff ff       	call   8002e7 <getuint>
                        base = 8;
  80067a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80067f:	eb 37                	jmp    8006b8 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 30                	push   $0x30
  800687:	ff d6                	call   *%esi
			putch('x', putdat);
  800689:	83 c4 08             	add    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 78                	push   $0x78
  80068f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a9:	eb 0d                	jmp    8006b8 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 34 fc ff ff       	call   8002e7 <getuint>
			base = 16;
  8006b3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b8:	83 ec 0c             	sub    $0xc,%esp
  8006bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bf:	57                   	push   %edi
  8006c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c3:	51                   	push   %ecx
  8006c4:	52                   	push   %edx
  8006c5:	50                   	push   %eax
  8006c6:	89 da                	mov    %ebx,%edx
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	e8 6e fb ff ff       	call   80023d <printnum>
			break;
  8006cf:	83 c4 20             	add    $0x20,%esp
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	e9 a7 fc ff ff       	jmp    800381 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	51                   	push   %ecx
  8006df:	ff d6                	call   *%esi
			break;
  8006e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e7:	e9 95 fc ff ff       	jmp    800381 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	6a 25                	push   $0x25
  8006f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 03                	jmp    8006fc <vprintfmt+0x3a1>
  8006f9:	83 ef 01             	sub    $0x1,%edi
  8006fc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800700:	75 f7                	jne    8006f9 <vprintfmt+0x39e>
  800702:	e9 7a fc ff ff       	jmp    800381 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070a:	5b                   	pop    %ebx
  80070b:	5e                   	pop    %esi
  80070c:	5f                   	pop    %edi
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 18             	sub    $0x18,%esp
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800722:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800725:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 26                	je     800756 <vsnprintf+0x47>
  800730:	85 d2                	test   %edx,%edx
  800732:	7e 22                	jle    800756 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800734:	ff 75 14             	pushl  0x14(%ebp)
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	68 21 03 80 00       	push   $0x800321
  800743:	e8 13 fc ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	eb 05                	jmp    80075b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	50                   	push   %eax
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	ff 75 0c             	pushl  0xc(%ebp)
  80076d:	ff 75 08             	pushl  0x8(%ebp)
  800770:	e8 9a ff ff ff       	call   80070f <vsnprintf>
	va_end(ap);

	return rc;
}
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	eb 03                	jmp    800787 <strlen+0x10>
		n++;
  800784:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800787:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078b:	75 f7                	jne    800784 <strlen+0xd>
		n++;
	return n;
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	ba 00 00 00 00       	mov    $0x0,%edx
  80079d:	eb 03                	jmp    8007a2 <strnlen+0x13>
		n++;
  80079f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	39 c2                	cmp    %eax,%edx
  8007a4:	74 08                	je     8007ae <strnlen+0x1f>
  8007a6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007aa:	75 f3                	jne    80079f <strnlen+0x10>
  8007ac:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ba:	89 c2                	mov    %eax,%edx
  8007bc:	83 c2 01             	add    $0x1,%edx
  8007bf:	83 c1 01             	add    $0x1,%ecx
  8007c2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c9:	84 db                	test   %bl,%bl
  8007cb:	75 ef                	jne    8007bc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d7:	53                   	push   %ebx
  8007d8:	e8 9a ff ff ff       	call   800777 <strlen>
  8007dd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	01 d8                	add    %ebx,%eax
  8007e5:	50                   	push   %eax
  8007e6:	e8 c5 ff ff ff       	call   8007b0 <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	89 f3                	mov    %esi,%ebx
  8007ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800802:	89 f2                	mov    %esi,%edx
  800804:	eb 0f                	jmp    800815 <strncpy+0x23>
		*dst++ = *src;
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	0f b6 01             	movzbl (%ecx),%eax
  80080c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080f:	80 39 01             	cmpb   $0x1,(%ecx)
  800812:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800815:	39 da                	cmp    %ebx,%edx
  800817:	75 ed                	jne    800806 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800819:	89 f0                	mov    %esi,%eax
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 75 08             	mov    0x8(%ebp),%esi
  800827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082a:	8b 55 10             	mov    0x10(%ebp),%edx
  80082d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082f:	85 d2                	test   %edx,%edx
  800831:	74 21                	je     800854 <strlcpy+0x35>
  800833:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800837:	89 f2                	mov    %esi,%edx
  800839:	eb 09                	jmp    800844 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	83 c1 01             	add    $0x1,%ecx
  800841:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800844:	39 c2                	cmp    %eax,%edx
  800846:	74 09                	je     800851 <strlcpy+0x32>
  800848:	0f b6 19             	movzbl (%ecx),%ebx
  80084b:	84 db                	test   %bl,%bl
  80084d:	75 ec                	jne    80083b <strlcpy+0x1c>
  80084f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800851:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800854:	29 f0                	sub    %esi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800863:	eb 06                	jmp    80086b <strcmp+0x11>
		p++, q++;
  800865:	83 c1 01             	add    $0x1,%ecx
  800868:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086b:	0f b6 01             	movzbl (%ecx),%eax
  80086e:	84 c0                	test   %al,%al
  800870:	74 04                	je     800876 <strcmp+0x1c>
  800872:	3a 02                	cmp    (%edx),%al
  800874:	74 ef                	je     800865 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 c0             	movzbl %al,%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	89 c3                	mov    %eax,%ebx
  80088c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088f:	eb 06                	jmp    800897 <strncmp+0x17>
		n--, p++, q++;
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800897:	39 d8                	cmp    %ebx,%eax
  800899:	74 15                	je     8008b0 <strncmp+0x30>
  80089b:	0f b6 08             	movzbl (%eax),%ecx
  80089e:	84 c9                	test   %cl,%cl
  8008a0:	74 04                	je     8008a6 <strncmp+0x26>
  8008a2:	3a 0a                	cmp    (%edx),%cl
  8008a4:	74 eb                	je     800891 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a6:	0f b6 00             	movzbl (%eax),%eax
  8008a9:	0f b6 12             	movzbl (%edx),%edx
  8008ac:	29 d0                	sub    %edx,%eax
  8008ae:	eb 05                	jmp    8008b5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	eb 07                	jmp    8008cb <strchr+0x13>
		if (*s == c)
  8008c4:	38 ca                	cmp    %cl,%dl
  8008c6:	74 0f                	je     8008d7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	0f b6 10             	movzbl (%eax),%edx
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	75 f2                	jne    8008c4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e3:	eb 03                	jmp    8008e8 <strfind+0xf>
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	74 04                	je     8008f3 <strfind+0x1a>
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	75 f2                	jne    8008e5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	57                   	push   %edi
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800901:	85 c9                	test   %ecx,%ecx
  800903:	74 36                	je     80093b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800905:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090b:	75 28                	jne    800935 <memset+0x40>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 23                	jne    800935 <memset+0x40>
		c &= 0xFF;
  800912:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800916:	89 d3                	mov    %edx,%ebx
  800918:	c1 e3 08             	shl    $0x8,%ebx
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	c1 e6 18             	shl    $0x18,%esi
  800920:	89 d0                	mov    %edx,%eax
  800922:	c1 e0 10             	shl    $0x10,%eax
  800925:	09 f0                	or     %esi,%eax
  800927:	09 c2                	or     %eax,%edx
  800929:	89 d0                	mov    %edx,%eax
  80092b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800930:	fc                   	cld    
  800931:	f3 ab                	rep stos %eax,%es:(%edi)
  800933:	eb 06                	jmp    80093b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800935:	8b 45 0c             	mov    0xc(%ebp),%eax
  800938:	fc                   	cld    
  800939:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093b:	89 f8                	mov    %edi,%eax
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5f                   	pop    %edi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800950:	39 c6                	cmp    %eax,%esi
  800952:	73 35                	jae    800989 <memmove+0x47>
  800954:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800957:	39 d0                	cmp    %edx,%eax
  800959:	73 2e                	jae    800989 <memmove+0x47>
		s += n;
		d += n;
  80095b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80095e:	89 d6                	mov    %edx,%esi
  800960:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800968:	75 13                	jne    80097d <memmove+0x3b>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0e                	jne    80097d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096f:	83 ef 04             	sub    $0x4,%edi
  800972:	8d 72 fc             	lea    -0x4(%edx),%esi
  800975:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800978:	fd                   	std    
  800979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097b:	eb 09                	jmp    800986 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097d:	83 ef 01             	sub    $0x1,%edi
  800980:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	fd                   	std    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800986:	fc                   	cld    
  800987:	eb 1d                	jmp    8009a6 <memmove+0x64>
  800989:	89 f2                	mov    %esi,%edx
  80098b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098d:	f6 c2 03             	test   $0x3,%dl
  800990:	75 0f                	jne    8009a1 <memmove+0x5f>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 0a                	jne    8009a1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800997:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 05                	jmp    8009a6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ad:	ff 75 10             	pushl  0x10(%ebp)
  8009b0:	ff 75 0c             	pushl  0xc(%ebp)
  8009b3:	ff 75 08             	pushl  0x8(%ebp)
  8009b6:	e8 87 ff ff ff       	call   800942 <memmove>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c8:	89 c6                	mov    %eax,%esi
  8009ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	eb 1a                	jmp    8009e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cf:	0f b6 08             	movzbl (%eax),%ecx
  8009d2:	0f b6 1a             	movzbl (%edx),%ebx
  8009d5:	38 d9                	cmp    %bl,%cl
  8009d7:	74 0a                	je     8009e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c1             	movzbl %cl,%eax
  8009dc:	0f b6 db             	movzbl %bl,%ebx
  8009df:	29 d8                	sub    %ebx,%eax
  8009e1:	eb 0f                	jmp    8009f2 <memcmp+0x35>
		s1++, s2++;
  8009e3:	83 c0 01             	add    $0x1,%eax
  8009e6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e9:	39 f0                	cmp    %esi,%eax
  8009eb:	75 e2                	jne    8009cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a04:	eb 07                	jmp    800a0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	38 08                	cmp    %cl,(%eax)
  800a08:	74 07                	je     800a11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	72 f5                	jb     800a06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	eb 03                	jmp    800a24 <strtol+0x11>
		s++;
  800a21:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a24:	0f b6 01             	movzbl (%ecx),%eax
  800a27:	3c 09                	cmp    $0x9,%al
  800a29:	74 f6                	je     800a21 <strtol+0xe>
  800a2b:	3c 20                	cmp    $0x20,%al
  800a2d:	74 f2                	je     800a21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2f:	3c 2b                	cmp    $0x2b,%al
  800a31:	75 0a                	jne    800a3d <strtol+0x2a>
		s++;
  800a33:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a36:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3b:	eb 10                	jmp    800a4d <strtol+0x3a>
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a42:	3c 2d                	cmp    $0x2d,%al
  800a44:	75 07                	jne    800a4d <strtol+0x3a>
		s++, neg = 1;
  800a46:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a49:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	0f 94 c0             	sete   %al
  800a52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a58:	75 19                	jne    800a73 <strtol+0x60>
  800a5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5d:	75 14                	jne    800a73 <strtol+0x60>
  800a5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a63:	0f 85 82 00 00 00    	jne    800aeb <strtol+0xd8>
		s += 2, base = 16;
  800a69:	83 c1 02             	add    $0x2,%ecx
  800a6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a71:	eb 16                	jmp    800a89 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a73:	84 c0                	test   %al,%al
  800a75:	74 12                	je     800a89 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a77:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7f:	75 08                	jne    800a89 <strtol+0x76>
		s++, base = 8;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a91:	0f b6 11             	movzbl (%ecx),%edx
  800a94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 09             	cmp    $0x9,%bl
  800a9c:	77 08                	ja     800aa6 <strtol+0x93>
			dig = *s - '0';
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 30             	sub    $0x30,%edx
  800aa4:	eb 22                	jmp    800ac8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800aa6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa9:	89 f3                	mov    %esi,%ebx
  800aab:	80 fb 19             	cmp    $0x19,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ab0:	0f be d2             	movsbl %dl,%edx
  800ab3:	83 ea 57             	sub    $0x57,%edx
  800ab6:	eb 10                	jmp    800ac8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ab8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abb:	89 f3                	mov    %esi,%ebx
  800abd:	80 fb 19             	cmp    $0x19,%bl
  800ac0:	77 16                	ja     800ad8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac2:	0f be d2             	movsbl %dl,%edx
  800ac5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acb:	7d 0f                	jge    800adc <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800acd:	83 c1 01             	add    $0x1,%ecx
  800ad0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad6:	eb b9                	jmp    800a91 <strtol+0x7e>
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	eb 02                	jmp    800ade <strtol+0xcb>
  800adc:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ade:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae2:	74 0d                	je     800af1 <strtol+0xde>
		*endptr = (char *) s;
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	89 0e                	mov    %ecx,(%esi)
  800ae9:	eb 06                	jmp    800af1 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aeb:	84 c0                	test   %al,%al
  800aed:	75 92                	jne    800a81 <strtol+0x6e>
  800aef:	eb 98                	jmp    800a89 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 08 17 80 00       	push   $0x801708
  800b67:	6a 23                	push   $0x23
  800b69:	68 25 17 80 00       	push   $0x801725
  800b6e:	e8 dd f5 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 08 17 80 00       	push   $0x801708
  800be8:	6a 23                	push   $0x23
  800bea:	68 25 17 80 00       	push   $0x801725
  800bef:	e8 5c f5 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 08 17 80 00       	push   $0x801708
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 25 17 80 00       	push   $0x801725
  800c31:	e8 1a f5 ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 08 17 80 00       	push   $0x801708
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 25 17 80 00       	push   $0x801725
  800c73:	e8 d8 f4 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 08 17 80 00       	push   $0x801708
  800cae:	6a 23                	push   $0x23
  800cb0:	68 25 17 80 00       	push   $0x801725
  800cb5:	e8 96 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 08 17 80 00       	push   $0x801708
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 25 17 80 00       	push   $0x801725
  800cf7:	e8 54 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d20:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 cb                	mov    %ecx,%ebx
  800d3f:	89 cf                	mov    %ecx,%edi
  800d41:	89 ce                	mov    %ecx,%esi
  800d43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0c                	push   $0xc
  800d4f:	68 08 17 80 00       	push   $0x801708
  800d54:	6a 23                	push   $0x23
  800d56:	68 25 17 80 00       	push   $0x801725
  800d5b:	e8 f0 f3 ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d72:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d74:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d78:	74 2e                	je     800da8 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	c1 ea 16             	shr    $0x16,%edx
  800d7f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d86:	f6 c2 01             	test   $0x1,%dl
  800d89:	74 1d                	je     800da8 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d8b:	89 c2                	mov    %eax,%edx
  800d8d:	c1 ea 0c             	shr    $0xc,%edx
  800d90:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d97:	f6 c1 01             	test   $0x1,%cl
  800d9a:	74 0c                	je     800da8 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800da3:	f6 c6 08             	test   $0x8,%dh
  800da6:	75 14                	jne    800dbc <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	68 34 17 80 00       	push   $0x801734
  800db0:	6a 21                	push   $0x21
  800db2:	68 c7 17 80 00       	push   $0x8017c7
  800db7:	e8 94 f3 ff ff       	call   800150 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800dbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc1:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800dc3:	83 ec 04             	sub    $0x4,%esp
  800dc6:	6a 07                	push   $0x7
  800dc8:	68 00 f0 7f 00       	push   $0x7ff000
  800dcd:	6a 00                	push   $0x0
  800dcf:	e8 e5 fd ff ff       	call   800bb9 <sys_page_alloc>
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	79 14                	jns    800def <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	68 d2 17 80 00       	push   $0x8017d2
  800de3:	6a 2b                	push   $0x2b
  800de5:	68 c7 17 80 00       	push   $0x8017c7
  800dea:	e8 61 f3 ff ff       	call   800150 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	68 00 10 00 00       	push   $0x1000
  800df7:	53                   	push   %ebx
  800df8:	68 00 f0 7f 00       	push   $0x7ff000
  800dfd:	e8 40 fb ff ff       	call   800942 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e02:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e09:	53                   	push   %ebx
  800e0a:	6a 00                	push   $0x0
  800e0c:	68 00 f0 7f 00       	push   $0x7ff000
  800e11:	6a 00                	push   $0x0
  800e13:	e8 e4 fd ff ff       	call   800bfc <sys_page_map>
  800e18:	83 c4 20             	add    $0x20,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	79 14                	jns    800e33 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 e8 17 80 00       	push   $0x8017e8
  800e27:	6a 2e                	push   $0x2e
  800e29:	68 c7 17 80 00       	push   $0x8017c7
  800e2e:	e8 1d f3 ff ff       	call   800150 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e33:	83 ec 08             	sub    $0x8,%esp
  800e36:	68 00 f0 7f 00       	push   $0x7ff000
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 fc fd ff ff       	call   800c3e <sys_page_unmap>
  800e42:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e53:	68 68 0d 80 00       	push   $0x800d68
  800e58:	e8 c1 02 00 00       	call   80111e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e5d:	b8 07 00 00 00       	mov    $0x7,%eax
  800e62:	cd 30                	int    $0x30
  800e64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	79 12                	jns    800e80 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e6e:	50                   	push   %eax
  800e6f:	68 fc 17 80 00       	push   $0x8017fc
  800e74:	6a 6d                	push   $0x6d
  800e76:	68 c7 17 80 00       	push   $0x8017c7
  800e7b:	e8 d0 f2 ff ff       	call   800150 <_panic>
  800e80:	89 c7                	mov    %eax,%edi
  800e82:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e87:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e8b:	75 21                	jne    800eae <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e8d:	e8 e9 fc ff ff       	call   800b7b <sys_getenvid>
  800e92:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e97:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e9a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e9f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	e9 59 01 00 00       	jmp    801007 <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800eae:	89 d8                	mov    %ebx,%eax
  800eb0:	c1 e8 16             	shr    $0x16,%eax
  800eb3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eba:	a8 01                	test   $0x1,%al
  800ebc:	0f 84 b0 00 00 00    	je     800f72 <fork+0x128>
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	c1 e8 0c             	shr    $0xc,%eax
  800ec7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ece:	f6 c2 01             	test   $0x1,%dl
  800ed1:	0f 84 9b 00 00 00    	je     800f72 <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800ed7:	89 c6                	mov    %eax,%esi
  800ed9:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800edc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee3:	f6 c6 08             	test   $0x8,%dh
  800ee6:	75 0b                	jne    800ef3 <fork+0xa9>
  800ee8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eef:	a8 02                	test   $0x2,%al
  800ef1:	74 57                	je     800f4a <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	68 05 08 00 00       	push   $0x805
  800efb:	56                   	push   %esi
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	6a 00                	push   $0x0
  800f00:	e8 f7 fc ff ff       	call   800bfc <sys_page_map>
  800f05:	83 c4 20             	add    $0x20,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	79 12                	jns    800f1e <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800f0c:	50                   	push   %eax
  800f0d:	68 58 17 80 00       	push   $0x801758
  800f12:	6a 4a                	push   $0x4a
  800f14:	68 c7 17 80 00       	push   $0x8017c7
  800f19:	e8 32 f2 ff ff       	call   800150 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	68 05 08 00 00       	push   $0x805
  800f26:	56                   	push   %esi
  800f27:	6a 00                	push   $0x0
  800f29:	56                   	push   %esi
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 cb fc ff ff       	call   800bfc <sys_page_map>
  800f31:	83 c4 20             	add    $0x20,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 3a                	jns    800f72 <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800f38:	50                   	push   %eax
  800f39:	68 7c 17 80 00       	push   $0x80177c
  800f3e:	6a 4c                	push   $0x4c
  800f40:	68 c7 17 80 00       	push   $0x8017c7
  800f45:	e8 06 f2 ff ff       	call   800150 <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	6a 05                	push   $0x5
  800f4f:	56                   	push   %esi
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 a3 fc ff ff       	call   800bfc <sys_page_map>
  800f59:	83 c4 20             	add    $0x20,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	79 12                	jns    800f72 <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800f60:	50                   	push   %eax
  800f61:	68 a4 17 80 00       	push   $0x8017a4
  800f66:	6a 4f                	push   $0x4f
  800f68:	68 c7 17 80 00       	push   $0x8017c7
  800f6d:	e8 de f1 ff ff       	call   800150 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800f72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f78:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f7e:	0f 85 2a ff ff ff    	jne    800eae <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	6a 07                	push   $0x7
  800f89:	68 00 f0 bf ee       	push   $0xeebff000
  800f8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f91:	e8 23 fc ff ff       	call   800bb9 <sys_page_alloc>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 14                	jns    800fb1 <fork+0x167>
                panic("user stack alloc failure\n");	
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	68 0c 18 80 00       	push   $0x80180c
  800fa5:	6a 76                	push   $0x76
  800fa7:	68 c7 17 80 00       	push   $0x8017c7
  800fac:	e8 9f f1 ff ff       	call   800150 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	68 8d 11 80 00       	push   $0x80118d
  800fb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fbc:	e8 01 fd ff ff       	call   800cc2 <sys_env_set_pgfault_upcall>
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 14                	jns    800fdc <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  800fc8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fcb:	68 26 18 80 00       	push   $0x801826
  800fd0:	6a 79                	push   $0x79
  800fd2:	68 c7 17 80 00       	push   $0x8017c7
  800fd7:	e8 74 f1 ff ff       	call   800150 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800fdc:	83 ec 08             	sub    $0x8,%esp
  800fdf:	6a 02                	push   $0x2
  800fe1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe4:	e8 97 fc ff ff       	call   800c80 <sys_env_set_status>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	79 14                	jns    801004 <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  800ff0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff3:	68 43 18 80 00       	push   $0x801843
  800ff8:	6a 7b                	push   $0x7b
  800ffa:	68 c7 17 80 00       	push   $0x8017c7
  800fff:	e8 4c f1 ff ff       	call   800150 <_panic>
        return forkid;
  801004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <sfork>:

// Challenge!
int
sfork(void)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801015:	68 5a 18 80 00       	push   $0x80185a
  80101a:	68 83 00 00 00       	push   $0x83
  80101f:	68 c7 17 80 00       	push   $0x8017c7
  801024:	e8 27 f1 ff ff       	call   800150 <_panic>

00801029 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	56                   	push   %esi
  80102d:	53                   	push   %ebx
  80102e:	8b 75 08             	mov    0x8(%ebp),%esi
  801031:	8b 45 0c             	mov    0xc(%ebp),%eax
  801034:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801037:	85 c0                	test   %eax,%eax
  801039:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80103e:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	50                   	push   %eax
  801045:	e8 dd fc ff ff       	call   800d27 <sys_ipc_recv>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	79 16                	jns    801067 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801051:	85 f6                	test   %esi,%esi
  801053:	74 06                	je     80105b <ipc_recv+0x32>
  801055:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80105b:	85 db                	test   %ebx,%ebx
  80105d:	74 2c                	je     80108b <ipc_recv+0x62>
  80105f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801065:	eb 24                	jmp    80108b <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801067:	85 f6                	test   %esi,%esi
  801069:	74 0a                	je     801075 <ipc_recv+0x4c>
  80106b:	a1 04 20 80 00       	mov    0x802004,%eax
  801070:	8b 40 74             	mov    0x74(%eax),%eax
  801073:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801075:	85 db                	test   %ebx,%ebx
  801077:	74 0a                	je     801083 <ipc_recv+0x5a>
  801079:	a1 04 20 80 00       	mov    0x802004,%eax
  80107e:	8b 40 78             	mov    0x78(%eax),%eax
  801081:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801083:	a1 04 20 80 00       	mov    0x802004,%eax
  801088:	8b 40 70             	mov    0x70(%eax),%eax
}
  80108b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8010a4:	85 db                	test   %ebx,%ebx
  8010a6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010ab:	0f 44 d8             	cmove  %eax,%ebx
  8010ae:	eb 1c                	jmp    8010cc <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8010b0:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010b3:	74 12                	je     8010c7 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8010b5:	50                   	push   %eax
  8010b6:	68 70 18 80 00       	push   $0x801870
  8010bb:	6a 39                	push   $0x39
  8010bd:	68 8b 18 80 00       	push   $0x80188b
  8010c2:	e8 89 f0 ff ff       	call   800150 <_panic>
                 sys_yield();
  8010c7:	e8 ce fa ff ff       	call   800b9a <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8010cc:	ff 75 14             	pushl  0x14(%ebp)
  8010cf:	53                   	push   %ebx
  8010d0:	56                   	push   %esi
  8010d1:	57                   	push   %edi
  8010d2:	e8 2d fc ff ff       	call   800d04 <sys_ipc_try_send>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 d2                	js     8010b0 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010ec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010f1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010f4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010fa:	8b 52 50             	mov    0x50(%edx),%edx
  8010fd:	39 ca                	cmp    %ecx,%edx
  8010ff:	75 0d                	jne    80110e <ipc_find_env+0x28>
			return envs[i].env_id;
  801101:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801104:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801109:	8b 40 08             	mov    0x8(%eax),%eax
  80110c:	eb 0e                	jmp    80111c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80110e:	83 c0 01             	add    $0x1,%eax
  801111:	3d 00 04 00 00       	cmp    $0x400,%eax
  801116:	75 d9                	jne    8010f1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801118:	66 b8 00 00          	mov    $0x0,%ax
}
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801124:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80112b:	75 2c                	jne    801159 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	6a 07                	push   $0x7
  801132:	68 00 f0 bf ee       	push   $0xeebff000
  801137:	6a 00                	push   $0x0
  801139:	e8 7b fa ff ff       	call   800bb9 <sys_page_alloc>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	74 14                	je     801159 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	68 98 18 80 00       	push   $0x801898
  80114d:	6a 21                	push   $0x21
  80114f:	68 fc 18 80 00       	push   $0x8018fc
  801154:	e8 f7 ef ff ff       	call   800150 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	68 8d 11 80 00       	push   $0x80118d
  801169:	6a 00                	push   $0x0
  80116b:	e8 52 fb ff ff       	call   800cc2 <sys_env_set_pgfault_upcall>
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	79 14                	jns    80118b <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	68 c4 18 80 00       	push   $0x8018c4
  80117f:	6a 29                	push   $0x29
  801181:	68 fc 18 80 00       	push   $0x8018fc
  801186:	e8 c5 ef ff ff       	call   800150 <_panic>
}
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80118d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80118e:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801193:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801195:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801198:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80119d:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8011a1:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8011a5:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8011a7:	83 c4 08             	add    $0x8,%esp
        popal
  8011aa:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8011ab:	83 c4 04             	add    $0x4,%esp
        popfl
  8011ae:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8011af:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8011b0:	c3                   	ret    
  8011b1:	66 90                	xchg   %ax,%ax
  8011b3:	66 90                	xchg   %ax,%ax
  8011b5:	66 90                	xchg   %ax,%ax
  8011b7:	66 90                	xchg   %ax,%ax
  8011b9:	66 90                	xchg   %ax,%ax
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 10             	sub    $0x10,%esp
  8011c6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8011ca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8011ce:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011d2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011dc:	89 34 24             	mov    %esi,(%esp)
  8011df:	89 c8                	mov    %ecx,%eax
  8011e1:	75 35                	jne    801218 <__udivdi3+0x58>
  8011e3:	39 f1                	cmp    %esi,%ecx
  8011e5:	0f 87 bd 00 00 00    	ja     8012a8 <__udivdi3+0xe8>
  8011eb:	85 c9                	test   %ecx,%ecx
  8011ed:	89 cd                	mov    %ecx,%ebp
  8011ef:	75 0b                	jne    8011fc <__udivdi3+0x3c>
  8011f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f6:	31 d2                	xor    %edx,%edx
  8011f8:	f7 f1                	div    %ecx
  8011fa:	89 c5                	mov    %eax,%ebp
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	31 d2                	xor    %edx,%edx
  801200:	f7 f5                	div    %ebp
  801202:	89 c6                	mov    %eax,%esi
  801204:	89 f8                	mov    %edi,%eax
  801206:	f7 f5                	div    %ebp
  801208:	89 f2                	mov    %esi,%edx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	3b 14 24             	cmp    (%esp),%edx
  80121b:	77 7b                	ja     801298 <__udivdi3+0xd8>
  80121d:	0f bd f2             	bsr    %edx,%esi
  801220:	83 f6 1f             	xor    $0x1f,%esi
  801223:	0f 84 97 00 00 00    	je     8012c0 <__udivdi3+0x100>
  801229:	bd 20 00 00 00       	mov    $0x20,%ebp
  80122e:	89 d7                	mov    %edx,%edi
  801230:	89 f1                	mov    %esi,%ecx
  801232:	29 f5                	sub    %esi,%ebp
  801234:	d3 e7                	shl    %cl,%edi
  801236:	89 c2                	mov    %eax,%edx
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	d3 ea                	shr    %cl,%edx
  80123c:	89 f1                	mov    %esi,%ecx
  80123e:	09 fa                	or     %edi,%edx
  801240:	8b 3c 24             	mov    (%esp),%edi
  801243:	d3 e0                	shl    %cl,%eax
  801245:	89 54 24 08          	mov    %edx,0x8(%esp)
  801249:	89 e9                	mov    %ebp,%ecx
  80124b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801253:	89 fa                	mov    %edi,%edx
  801255:	d3 ea                	shr    %cl,%edx
  801257:	89 f1                	mov    %esi,%ecx
  801259:	d3 e7                	shl    %cl,%edi
  80125b:	89 e9                	mov    %ebp,%ecx
  80125d:	d3 e8                	shr    %cl,%eax
  80125f:	09 c7                	or     %eax,%edi
  801261:	89 f8                	mov    %edi,%eax
  801263:	f7 74 24 08          	divl   0x8(%esp)
  801267:	89 d5                	mov    %edx,%ebp
  801269:	89 c7                	mov    %eax,%edi
  80126b:	f7 64 24 0c          	mull   0xc(%esp)
  80126f:	39 d5                	cmp    %edx,%ebp
  801271:	89 14 24             	mov    %edx,(%esp)
  801274:	72 11                	jb     801287 <__udivdi3+0xc7>
  801276:	8b 54 24 04          	mov    0x4(%esp),%edx
  80127a:	89 f1                	mov    %esi,%ecx
  80127c:	d3 e2                	shl    %cl,%edx
  80127e:	39 c2                	cmp    %eax,%edx
  801280:	73 5e                	jae    8012e0 <__udivdi3+0x120>
  801282:	3b 2c 24             	cmp    (%esp),%ebp
  801285:	75 59                	jne    8012e0 <__udivdi3+0x120>
  801287:	8d 47 ff             	lea    -0x1(%edi),%eax
  80128a:	31 f6                	xor    %esi,%esi
  80128c:	89 f2                	mov    %esi,%edx
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	31 f6                	xor    %esi,%esi
  80129a:	31 c0                	xor    %eax,%eax
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	89 f2                	mov    %esi,%edx
  8012aa:	31 f6                	xor    %esi,%esi
  8012ac:	89 f8                	mov    %edi,%eax
  8012ae:	f7 f1                	div    %ecx
  8012b0:	89 f2                	mov    %esi,%edx
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8012c4:	76 0b                	jbe    8012d1 <__udivdi3+0x111>
  8012c6:	31 c0                	xor    %eax,%eax
  8012c8:	3b 14 24             	cmp    (%esp),%edx
  8012cb:	0f 83 37 ff ff ff    	jae    801208 <__udivdi3+0x48>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	e9 2d ff ff ff       	jmp    801208 <__udivdi3+0x48>
  8012db:	90                   	nop
  8012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 f8                	mov    %edi,%eax
  8012e2:	31 f6                	xor    %esi,%esi
  8012e4:	e9 1f ff ff ff       	jmp    801208 <__udivdi3+0x48>
  8012e9:	66 90                	xchg   %ax,%ax
  8012eb:	66 90                	xchg   %ax,%ax
  8012ed:	66 90                	xchg   %ax,%ax
  8012ef:	90                   	nop

008012f0 <__umoddi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 20             	sub    $0x20,%esp
  8012f6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8012fa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012fe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801302:	89 c6                	mov    %eax,%esi
  801304:	89 44 24 10          	mov    %eax,0x10(%esp)
  801308:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80130c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801310:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801314:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801318:	89 74 24 18          	mov    %esi,0x18(%esp)
  80131c:	85 c0                	test   %eax,%eax
  80131e:	89 c2                	mov    %eax,%edx
  801320:	75 1e                	jne    801340 <__umoddi3+0x50>
  801322:	39 f7                	cmp    %esi,%edi
  801324:	76 52                	jbe    801378 <__umoddi3+0x88>
  801326:	89 c8                	mov    %ecx,%eax
  801328:	89 f2                	mov    %esi,%edx
  80132a:	f7 f7                	div    %edi
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	31 d2                	xor    %edx,%edx
  801330:	83 c4 20             	add    $0x20,%esp
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    
  801337:	89 f6                	mov    %esi,%esi
  801339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801340:	39 f0                	cmp    %esi,%eax
  801342:	77 5c                	ja     8013a0 <__umoddi3+0xb0>
  801344:	0f bd e8             	bsr    %eax,%ebp
  801347:	83 f5 1f             	xor    $0x1f,%ebp
  80134a:	75 64                	jne    8013b0 <__umoddi3+0xc0>
  80134c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801350:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801354:	0f 86 f6 00 00 00    	jbe    801450 <__umoddi3+0x160>
  80135a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80135e:	0f 82 ec 00 00 00    	jb     801450 <__umoddi3+0x160>
  801364:	8b 44 24 14          	mov    0x14(%esp),%eax
  801368:	8b 54 24 18          	mov    0x18(%esp),%edx
  80136c:	83 c4 20             	add    $0x20,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	85 ff                	test   %edi,%edi
  80137a:	89 fd                	mov    %edi,%ebp
  80137c:	75 0b                	jne    801389 <__umoddi3+0x99>
  80137e:	b8 01 00 00 00       	mov    $0x1,%eax
  801383:	31 d2                	xor    %edx,%edx
  801385:	f7 f7                	div    %edi
  801387:	89 c5                	mov    %eax,%ebp
  801389:	8b 44 24 10          	mov    0x10(%esp),%eax
  80138d:	31 d2                	xor    %edx,%edx
  80138f:	f7 f5                	div    %ebp
  801391:	89 c8                	mov    %ecx,%eax
  801393:	f7 f5                	div    %ebp
  801395:	eb 95                	jmp    80132c <__umoddi3+0x3c>
  801397:	89 f6                	mov    %esi,%esi
  801399:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	83 c4 20             	add    $0x20,%esp
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
  8013ab:	90                   	nop
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b5:	89 e9                	mov    %ebp,%ecx
  8013b7:	29 e8                	sub    %ebp,%eax
  8013b9:	d3 e2                	shl    %cl,%edx
  8013bb:	89 c7                	mov    %eax,%edi
  8013bd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8013c1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013c5:	89 f9                	mov    %edi,%ecx
  8013c7:	d3 e8                	shr    %cl,%eax
  8013c9:	89 c1                	mov    %eax,%ecx
  8013cb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013cf:	09 d1                	or     %edx,%ecx
  8013d1:	89 fa                	mov    %edi,%edx
  8013d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013d7:	89 e9                	mov    %ebp,%ecx
  8013d9:	d3 e0                	shl    %cl,%eax
  8013db:	89 f9                	mov    %edi,%ecx
  8013dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e1:	89 f0                	mov    %esi,%eax
  8013e3:	d3 e8                	shr    %cl,%eax
  8013e5:	89 e9                	mov    %ebp,%ecx
  8013e7:	89 c7                	mov    %eax,%edi
  8013e9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013ed:	d3 e6                	shl    %cl,%esi
  8013ef:	89 d1                	mov    %edx,%ecx
  8013f1:	89 fa                	mov    %edi,%edx
  8013f3:	d3 e8                	shr    %cl,%eax
  8013f5:	89 e9                	mov    %ebp,%ecx
  8013f7:	09 f0                	or     %esi,%eax
  8013f9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8013fd:	f7 74 24 10          	divl   0x10(%esp)
  801401:	d3 e6                	shl    %cl,%esi
  801403:	89 d1                	mov    %edx,%ecx
  801405:	f7 64 24 0c          	mull   0xc(%esp)
  801409:	39 d1                	cmp    %edx,%ecx
  80140b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80140f:	89 d7                	mov    %edx,%edi
  801411:	89 c6                	mov    %eax,%esi
  801413:	72 0a                	jb     80141f <__umoddi3+0x12f>
  801415:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801419:	73 10                	jae    80142b <__umoddi3+0x13b>
  80141b:	39 d1                	cmp    %edx,%ecx
  80141d:	75 0c                	jne    80142b <__umoddi3+0x13b>
  80141f:	89 d7                	mov    %edx,%edi
  801421:	89 c6                	mov    %eax,%esi
  801423:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801427:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80142b:	89 ca                	mov    %ecx,%edx
  80142d:	89 e9                	mov    %ebp,%ecx
  80142f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801433:	29 f0                	sub    %esi,%eax
  801435:	19 fa                	sbb    %edi,%edx
  801437:	d3 e8                	shr    %cl,%eax
  801439:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80143e:	89 d7                	mov    %edx,%edi
  801440:	d3 e7                	shl    %cl,%edi
  801442:	89 e9                	mov    %ebp,%ecx
  801444:	09 f8                	or     %edi,%eax
  801446:	d3 ea                	shr    %cl,%edx
  801448:	83 c4 20             	add    $0x20,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	8b 74 24 10          	mov    0x10(%esp),%esi
  801454:	29 f9                	sub    %edi,%ecx
  801456:	19 c6                	sbb    %eax,%esi
  801458:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80145c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801460:	e9 ff fe ff ff       	jmp    801364 <__umoddi3+0x74>
