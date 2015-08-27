
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 33 0b 00 00       	call   800b70 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 f6 0d 00 00       	call   800e3f <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 2e 0b 00 00       	call   800b8f <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 05 0b 00 00       	call   800b8f <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 80 13 80 00       	push   $0x801380
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 a8 13 80 00       	push   $0x8013a8
  8000c4:	e8 7c 00 00 00       	call   800145 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 bb 13 80 00       	push   $0x8013bb
  8000de:	e8 3b 01 00 00       	call   80021e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000f8:	e8 73 0a 00 00       	call   800b70 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
  800129:	83 c4 10             	add    $0x10,%esp
}
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 ef 09 00 00       	call   800b2f <sys_env_destroy>
  800140:	83 c4 10             	add    $0x10,%esp
}
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800153:	e8 18 0a 00 00       	call   800b70 <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	56                   	push   %esi
  800162:	50                   	push   %eax
  800163:	68 e4 13 80 00       	push   $0x8013e4
  800168:	e8 b1 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	pushl  0x10(%ebp)
  800174:	e8 54 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 d7 13 80 00 	movl   $0x8013d7,(%esp)
  800180:	e8 99 00 00 00       	call   80021e <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800188:	cc                   	int3   
  800189:	eb fd                	jmp    800188 <_panic+0x43>

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 13                	mov    (%ebx),%edx
  800197:	8d 42 01             	lea    0x1(%edx),%eax
  80019a:	89 03                	mov    %eax,(%ebx)
  80019c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	75 1a                	jne    8001c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 37 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 8b 01 80 00       	push   $0x80018b
  8001fc:	e8 4f 01 00 00       	call   800350 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 dc 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	pushl  0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 d1                	mov    %edx,%ecx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800256:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025d:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800260:	72 05                	jb     800267 <printnum+0x35>
  800262:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800265:	77 3e                	ja     8002a5 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	ff 75 18             	pushl  0x18(%ebp)
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	53                   	push   %ebx
  800271:	50                   	push   %eax
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 3a 0e 00 00       	call   8010c0 <__udivdi3>
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	89 f2                	mov    %esi,%edx
  80028d:	89 f8                	mov    %edi,%eax
  80028f:	e8 9e ff ff ff       	call   800232 <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 13                	jmp    8002ac <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	ff 75 18             	pushl  0x18(%ebp)
  8002a0:	ff d7                	call   *%edi
  8002a2:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f ed                	jg     800299 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bf:	e8 2c 0f 00 00       	call   8011f0 <__umoddi3>
  8002c4:	83 c4 14             	add    $0x14,%esp
  8002c7:	0f be 80 07 14 80 00 	movsbl 0x801407(%eax),%eax
  8002ce:	50                   	push   %eax
  8002cf:	ff d7                	call   *%edi
  8002d1:	83 c4 10             	add    $0x10,%esp
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002df:	83 fa 01             	cmp    $0x1,%edx
  8002e2:	7e 0e                	jle    8002f2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	8b 52 04             	mov    0x4(%edx),%edx
  8002f0:	eb 22                	jmp    800314 <getuint+0x38>
	else if (lflag)
  8002f2:	85 d2                	test   %edx,%edx
  8002f4:	74 10                	je     800306 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800304:	eb 0e                	jmp    800314 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800320:	8b 10                	mov    (%eax),%edx
  800322:	3b 50 04             	cmp    0x4(%eax),%edx
  800325:	73 0a                	jae    800331 <sprintputch+0x1b>
		*b->buf++ = ch;
  800327:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	88 02                	mov    %al,(%edx)
}
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800339:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033c:	50                   	push   %eax
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	e8 05 00 00 00       	call   800350 <vprintfmt>
	va_end(ap);
  80034b:	83 c4 10             	add    $0x10,%esp
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 2c             	sub    $0x2c,%esp
  800359:	8b 75 08             	mov    0x8(%ebp),%esi
  80035c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800362:	eb 12                	jmp    800376 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800364:	85 c0                	test   %eax,%eax
  800366:	0f 84 90 03 00 00    	je     8006fc <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	53                   	push   %ebx
  800370:	50                   	push   %eax
  800371:	ff d6                	call   *%esi
  800373:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800376:	83 c7 01             	add    $0x1,%edi
  800379:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037d:	83 f8 25             	cmp    $0x25,%eax
  800380:	75 e2                	jne    800364 <vprintfmt+0x14>
  800382:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800386:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800394:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	eb 07                	jmp    8003a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8d 47 01             	lea    0x1(%edi),%eax
  8003ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003af:	0f b6 07             	movzbl (%edi),%eax
  8003b2:	0f b6 c8             	movzbl %al,%ecx
  8003b5:	83 e8 23             	sub    $0x23,%eax
  8003b8:	3c 55                	cmp    $0x55,%al
  8003ba:	0f 87 21 03 00 00    	ja     8006e1 <vprintfmt+0x391>
  8003c0:	0f b6 c0             	movzbl %al,%eax
  8003c3:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d1:	eb d6                	jmp    8003a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003eb:	83 fa 09             	cmp    $0x9,%edx
  8003ee:	77 39                	ja     800429 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f3:	eb e9                	jmp    8003de <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800406:	eb 27                	jmp    80042f <vprintfmt+0xdf>
  800408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	0f 49 c8             	cmovns %eax,%ecx
  800415:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	eb 8c                	jmp    8003a9 <vprintfmt+0x59>
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800420:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800427:	eb 80                	jmp    8003a9 <vprintfmt+0x59>
  800429:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	0f 89 70 ff ff ff    	jns    8003a9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800439:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800446:	e9 5e ff ff ff       	jmp    8003a9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800451:	e9 53 ff ff ff       	jmp    8003a9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 30                	pushl  (%eax)
  800465:	ff d6                	call   *%esi
			break;
  800467:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046d:	e9 04 ff ff ff       	jmp    800376 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	99                   	cltd   
  80047e:	31 d0                	xor    %edx,%eax
  800480:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800482:	83 f8 09             	cmp    $0x9,%eax
  800485:	7f 0b                	jg     800492 <vprintfmt+0x142>
  800487:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	75 18                	jne    8004aa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800492:	50                   	push   %eax
  800493:	68 1f 14 80 00       	push   $0x80141f
  800498:	53                   	push   %ebx
  800499:	56                   	push   %esi
  80049a:	e8 94 fe ff ff       	call   800333 <printfmt>
  80049f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a5:	e9 cc fe ff ff       	jmp    800376 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004aa:	52                   	push   %edx
  8004ab:	68 28 14 80 00       	push   $0x801428
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 7c fe ff ff       	call   800333 <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bd:	e9 b4 fe ff ff       	jmp    800376 <vprintfmt+0x26>
  8004c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d6:	85 ff                	test   %edi,%edi
  8004d8:	ba 18 14 80 00       	mov    $0x801418,%edx
  8004dd:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004e0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e4:	0f 84 92 00 00 00    	je     80057c <vprintfmt+0x22c>
  8004ea:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004ee:	0f 8e 96 00 00 00    	jle    80058a <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	51                   	push   %ecx
  8004f8:	57                   	push   %edi
  8004f9:	e8 86 02 00 00       	call   800784 <strnlen>
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	29 c1                	sub    %eax,%ecx
  800503:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800506:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800509:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800510:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800513:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	eb 0f                	jmp    800526 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	53                   	push   %ebx
  80051b:	ff 75 e0             	pushl  -0x20(%ebp)
  80051e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800520:	83 ef 01             	sub    $0x1,%edi
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	85 ff                	test   %edi,%edi
  800528:	7f ed                	jg     800517 <vprintfmt+0x1c7>
  80052a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800530:	85 c9                	test   %ecx,%ecx
  800532:	b8 00 00 00 00       	mov    $0x0,%eax
  800537:	0f 49 c1             	cmovns %ecx,%eax
  80053a:	29 c1                	sub    %eax,%ecx
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800545:	89 cb                	mov    %ecx,%ebx
  800547:	eb 4d                	jmp    800596 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054d:	74 1b                	je     80056a <vprintfmt+0x21a>
  80054f:	0f be c0             	movsbl %al,%eax
  800552:	83 e8 20             	sub    $0x20,%eax
  800555:	83 f8 5e             	cmp    $0x5e,%eax
  800558:	76 10                	jbe    80056a <vprintfmt+0x21a>
					putch('?', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	ff 75 0c             	pushl  0xc(%ebp)
  800560:	6a 3f                	push   $0x3f
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	eb 0d                	jmp    800577 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	ff 75 0c             	pushl  0xc(%ebp)
  800570:	52                   	push   %edx
  800571:	ff 55 08             	call   *0x8(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800577:	83 eb 01             	sub    $0x1,%ebx
  80057a:	eb 1a                	jmp    800596 <vprintfmt+0x246>
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800585:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800588:	eb 0c                	jmp    800596 <vprintfmt+0x246>
  80058a:	89 75 08             	mov    %esi,0x8(%ebp)
  80058d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800590:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800593:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800596:	83 c7 01             	add    $0x1,%edi
  800599:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059d:	0f be d0             	movsbl %al,%edx
  8005a0:	85 d2                	test   %edx,%edx
  8005a2:	74 23                	je     8005c7 <vprintfmt+0x277>
  8005a4:	85 f6                	test   %esi,%esi
  8005a6:	78 a1                	js     800549 <vprintfmt+0x1f9>
  8005a8:	83 ee 01             	sub    $0x1,%esi
  8005ab:	79 9c                	jns    800549 <vprintfmt+0x1f9>
  8005ad:	89 df                	mov    %ebx,%edi
  8005af:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b5:	eb 18                	jmp    8005cf <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 20                	push   $0x20
  8005bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bf:	83 ef 01             	sub    $0x1,%edi
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	eb 08                	jmp    8005cf <vprintfmt+0x27f>
  8005c7:	89 df                	mov    %ebx,%edi
  8005c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cf:	85 ff                	test   %edi,%edi
  8005d1:	7f e4                	jg     8005b7 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d6:	e9 9b fd ff ff       	jmp    800376 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005db:	83 fa 01             	cmp    $0x1,%edx
  8005de:	7e 16                	jle    8005f6 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 08             	lea    0x8(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 50 04             	mov    0x4(%eax),%edx
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f4:	eb 32                	jmp    800628 <vprintfmt+0x2d8>
	else if (lflag)
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	74 18                	je     800612 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 c1                	mov    %eax,%ecx
  80060a:	c1 f9 1f             	sar    $0x1f,%ecx
  80060d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800610:	eb 16                	jmp    800628 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 c1                	mov    %eax,%ecx
  800622:	c1 f9 1f             	sar    $0x1f,%ecx
  800625:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800628:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800633:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800637:	79 74                	jns    8006ad <vprintfmt+0x35d>
				putch('-', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 2d                	push   $0x2d
  80063f:	ff d6                	call   *%esi
				num = -(long long) num;
  800641:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800644:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800647:	f7 d8                	neg    %eax
  800649:	83 d2 00             	adc    $0x0,%edx
  80064c:	f7 da                	neg    %edx
  80064e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800651:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800656:	eb 55                	jmp    8006ad <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
  80065b:	e8 7c fc ff ff       	call   8002dc <getuint>
			base = 10;
  800660:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800665:	eb 46                	jmp    8006ad <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 6d fc ff ff       	call   8002dc <getuint>
                        base = 8;
  80066f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800674:	eb 37                	jmp    8006ad <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 30                	push   $0x30
  80067c:	ff d6                	call   *%esi
			putch('x', putdat);
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 78                	push   $0x78
  800684:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800696:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069e:	eb 0d                	jmp    8006ad <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a3:	e8 34 fc ff ff       	call   8002dc <getuint>
			base = 16;
  8006a8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b4:	57                   	push   %edi
  8006b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b8:	51                   	push   %ecx
  8006b9:	52                   	push   %edx
  8006ba:	50                   	push   %eax
  8006bb:	89 da                	mov    %ebx,%edx
  8006bd:	89 f0                	mov    %esi,%eax
  8006bf:	e8 6e fb ff ff       	call   800232 <printnum>
			break;
  8006c4:	83 c4 20             	add    $0x20,%esp
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 a7 fc ff ff       	jmp    800376 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	51                   	push   %ecx
  8006d4:	ff d6                	call   *%esi
			break;
  8006d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006dc:	e9 95 fc ff ff       	jmp    800376 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 25                	push   $0x25
  8006e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 03                	jmp    8006f1 <vprintfmt+0x3a1>
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f5:	75 f7                	jne    8006ee <vprintfmt+0x39e>
  8006f7:	e9 7a fc ff ff       	jmp    800376 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 18             	sub    $0x18,%esp
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800710:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800713:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800717:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800721:	85 c0                	test   %eax,%eax
  800723:	74 26                	je     80074b <vsnprintf+0x47>
  800725:	85 d2                	test   %edx,%edx
  800727:	7e 22                	jle    80074b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800729:	ff 75 14             	pushl  0x14(%ebp)
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	68 16 03 80 00       	push   $0x800316
  800738:	e8 13 fc ff ff       	call   800350 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800740:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 05                	jmp    800750 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075b:	50                   	push   %eax
  80075c:	ff 75 10             	pushl  0x10(%ebp)
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	ff 75 08             	pushl  0x8(%ebp)
  800765:	e8 9a ff ff ff       	call   800704 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 03                	jmp    80077c <strlen+0x10>
		n++;
  800779:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800780:	75 f7                	jne    800779 <strlen+0xd>
		n++;
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
  800792:	eb 03                	jmp    800797 <strnlen+0x13>
		n++;
  800794:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800797:	39 c2                	cmp    %eax,%edx
  800799:	74 08                	je     8007a3 <strnlen+0x1f>
  80079b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079f:	75 f3                	jne    800794 <strnlen+0x10>
  8007a1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007af:	89 c2                	mov    %eax,%edx
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	83 c1 01             	add    $0x1,%ecx
  8007b7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007be:	84 db                	test   %bl,%bl
  8007c0:	75 ef                	jne    8007b1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	53                   	push   %ebx
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cc:	53                   	push   %ebx
  8007cd:	e8 9a ff ff ff       	call   80076c <strlen>
  8007d2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	01 d8                	add    %ebx,%eax
  8007da:	50                   	push   %eax
  8007db:	e8 c5 ff ff ff       	call   8007a5 <strcpy>
	return dst;
}
  8007e0:	89 d8                	mov    %ebx,%eax
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f2:	89 f3                	mov    %esi,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f7:	89 f2                	mov    %esi,%edx
  8007f9:	eb 0f                	jmp    80080a <strncpy+0x23>
		*dst++ = *src;
  8007fb:	83 c2 01             	add    $0x1,%edx
  8007fe:	0f b6 01             	movzbl (%ecx),%eax
  800801:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800804:	80 39 01             	cmpb   $0x1,(%ecx)
  800807:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	39 da                	cmp    %ebx,%edx
  80080c:	75 ed                	jne    8007fb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080e:	89 f0                	mov    %esi,%eax
  800810:	5b                   	pop    %ebx
  800811:	5e                   	pop    %esi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	8b 75 08             	mov    0x8(%ebp),%esi
  80081c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081f:	8b 55 10             	mov    0x10(%ebp),%edx
  800822:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800824:	85 d2                	test   %edx,%edx
  800826:	74 21                	je     800849 <strlcpy+0x35>
  800828:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082c:	89 f2                	mov    %esi,%edx
  80082e:	eb 09                	jmp    800839 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	83 c1 01             	add    $0x1,%ecx
  800836:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800839:	39 c2                	cmp    %eax,%edx
  80083b:	74 09                	je     800846 <strlcpy+0x32>
  80083d:	0f b6 19             	movzbl (%ecx),%ebx
  800840:	84 db                	test   %bl,%bl
  800842:	75 ec                	jne    800830 <strlcpy+0x1c>
  800844:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800846:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800849:	29 f0                	sub    %esi,%eax
}
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800858:	eb 06                	jmp    800860 <strcmp+0x11>
		p++, q++;
  80085a:	83 c1 01             	add    $0x1,%ecx
  80085d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	84 c0                	test   %al,%al
  800865:	74 04                	je     80086b <strcmp+0x1c>
  800867:	3a 02                	cmp    (%edx),%al
  800869:	74 ef                	je     80085a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 c0             	movzbl %al,%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	89 c3                	mov    %eax,%ebx
  800881:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800884:	eb 06                	jmp    80088c <strncmp+0x17>
		n--, p++, q++;
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088c:	39 d8                	cmp    %ebx,%eax
  80088e:	74 15                	je     8008a5 <strncmp+0x30>
  800890:	0f b6 08             	movzbl (%eax),%ecx
  800893:	84 c9                	test   %cl,%cl
  800895:	74 04                	je     80089b <strncmp+0x26>
  800897:	3a 0a                	cmp    (%edx),%cl
  800899:	74 eb                	je     800886 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089b:	0f b6 00             	movzbl (%eax),%eax
  80089e:	0f b6 12             	movzbl (%edx),%edx
  8008a1:	29 d0                	sub    %edx,%eax
  8008a3:	eb 05                	jmp    8008aa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b7:	eb 07                	jmp    8008c0 <strchr+0x13>
		if (*s == c)
  8008b9:	38 ca                	cmp    %cl,%dl
  8008bb:	74 0f                	je     8008cc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	0f b6 10             	movzbl (%eax),%edx
  8008c3:	84 d2                	test   %dl,%dl
  8008c5:	75 f2                	jne    8008b9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d8:	eb 03                	jmp    8008dd <strfind+0xf>
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	74 04                	je     8008e8 <strfind+0x1a>
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	75 f2                	jne    8008da <strfind+0xc>
			break;
	return (char *) s;
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f6:	85 c9                	test   %ecx,%ecx
  8008f8:	74 36                	je     800930 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800900:	75 28                	jne    80092a <memset+0x40>
  800902:	f6 c1 03             	test   $0x3,%cl
  800905:	75 23                	jne    80092a <memset+0x40>
		c &= 0xFF;
  800907:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090b:	89 d3                	mov    %edx,%ebx
  80090d:	c1 e3 08             	shl    $0x8,%ebx
  800910:	89 d6                	mov    %edx,%esi
  800912:	c1 e6 18             	shl    $0x18,%esi
  800915:	89 d0                	mov    %edx,%eax
  800917:	c1 e0 10             	shl    $0x10,%eax
  80091a:	09 f0                	or     %esi,%eax
  80091c:	09 c2                	or     %eax,%edx
  80091e:	89 d0                	mov    %edx,%eax
  800920:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800922:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800925:	fc                   	cld    
  800926:	f3 ab                	rep stos %eax,%es:(%edi)
  800928:	eb 06                	jmp    800930 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	fc                   	cld    
  80092e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800930:	89 f8                	mov    %edi,%eax
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800945:	39 c6                	cmp    %eax,%esi
  800947:	73 35                	jae    80097e <memmove+0x47>
  800949:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094c:	39 d0                	cmp    %edx,%eax
  80094e:	73 2e                	jae    80097e <memmove+0x47>
		s += n;
		d += n;
  800950:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800953:	89 d6                	mov    %edx,%esi
  800955:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095d:	75 13                	jne    800972 <memmove+0x3b>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 0e                	jne    800972 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800964:	83 ef 04             	sub    $0x4,%edi
  800967:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096d:	fd                   	std    
  80096e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800970:	eb 09                	jmp    80097b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800972:	83 ef 01             	sub    $0x1,%edi
  800975:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	fd                   	std    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097b:	fc                   	cld    
  80097c:	eb 1d                	jmp    80099b <memmove+0x64>
  80097e:	89 f2                	mov    %esi,%edx
  800980:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800982:	f6 c2 03             	test   $0x3,%dl
  800985:	75 0f                	jne    800996 <memmove+0x5f>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 0a                	jne    800996 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098f:	89 c7                	mov    %eax,%edi
  800991:	fc                   	cld    
  800992:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800994:	eb 05                	jmp    80099b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	ff 75 08             	pushl  0x8(%ebp)
  8009ab:	e8 87 ff ff ff       	call   800937 <memmove>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	89 c6                	mov    %eax,%esi
  8009bf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c2:	eb 1a                	jmp    8009de <memcmp+0x2c>
		if (*s1 != *s2)
  8009c4:	0f b6 08             	movzbl (%eax),%ecx
  8009c7:	0f b6 1a             	movzbl (%edx),%ebx
  8009ca:	38 d9                	cmp    %bl,%cl
  8009cc:	74 0a                	je     8009d8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ce:	0f b6 c1             	movzbl %cl,%eax
  8009d1:	0f b6 db             	movzbl %bl,%ebx
  8009d4:	29 d8                	sub    %ebx,%eax
  8009d6:	eb 0f                	jmp    8009e7 <memcmp+0x35>
		s1++, s2++;
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	39 f0                	cmp    %esi,%eax
  8009e0:	75 e2                	jne    8009c4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f4:	89 c2                	mov    %eax,%edx
  8009f6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f9:	eb 07                	jmp    800a02 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fb:	38 08                	cmp    %cl,(%eax)
  8009fd:	74 07                	je     800a06 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	72 f5                	jb     8009fb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	eb 03                	jmp    800a19 <strtol+0x11>
		s++;
  800a16:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a19:	0f b6 01             	movzbl (%ecx),%eax
  800a1c:	3c 09                	cmp    $0x9,%al
  800a1e:	74 f6                	je     800a16 <strtol+0xe>
  800a20:	3c 20                	cmp    $0x20,%al
  800a22:	74 f2                	je     800a16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a24:	3c 2b                	cmp    $0x2b,%al
  800a26:	75 0a                	jne    800a32 <strtol+0x2a>
		s++;
  800a28:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a30:	eb 10                	jmp    800a42 <strtol+0x3a>
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a37:	3c 2d                	cmp    $0x2d,%al
  800a39:	75 07                	jne    800a42 <strtol+0x3a>
		s++, neg = 1;
  800a3b:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a3e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	0f 94 c0             	sete   %al
  800a47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4d:	75 19                	jne    800a68 <strtol+0x60>
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 14                	jne    800a68 <strtol+0x60>
  800a54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a58:	0f 85 82 00 00 00    	jne    800ae0 <strtol+0xd8>
		s += 2, base = 16;
  800a5e:	83 c1 02             	add    $0x2,%ecx
  800a61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a66:	eb 16                	jmp    800a7e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a68:	84 c0                	test   %al,%al
  800a6a:	74 12                	je     800a7e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a71:	80 39 30             	cmpb   $0x30,(%ecx)
  800a74:	75 08                	jne    800a7e <strtol+0x76>
		s++, base = 8;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a86:	0f b6 11             	movzbl (%ecx),%edx
  800a89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 09             	cmp    $0x9,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x93>
			dig = *s - '0';
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 30             	sub    $0x30,%edx
  800a99:	eb 22                	jmp    800abd <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 08                	ja     800aad <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 57             	sub    $0x57,%edx
  800aab:	eb 10                	jmp    800abd <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aad:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 16                	ja     800acd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac0:	7d 0f                	jge    800ad1 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acb:	eb b9                	jmp    800a86 <strtol+0x7e>
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	eb 02                	jmp    800ad3 <strtol+0xcb>
  800ad1:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ad3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad7:	74 0d                	je     800ae6 <strtol+0xde>
		*endptr = (char *) s;
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adc:	89 0e                	mov    %ecx,(%esi)
  800ade:	eb 06                	jmp    800ae6 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae0:	84 c0                	test   %al,%al
  800ae2:	75 92                	jne    800a76 <strtol+0x6e>
  800ae4:	eb 98                	jmp    800a7e <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 48 16 80 00       	push   $0x801648
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 65 16 80 00       	push   $0x801665
  800b63:	e8 dd f5 ff ff       	call   800145 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 48 16 80 00       	push   $0x801648
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 65 16 80 00       	push   $0x801665
  800be4:	e8 5c f5 ff ff       	call   800145 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 48 16 80 00       	push   $0x801648
  800c1f:	6a 23                	push   $0x23
  800c21:	68 65 16 80 00       	push   $0x801665
  800c26:	e8 1a f5 ff ff       	call   800145 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 48 16 80 00       	push   $0x801648
  800c61:	6a 23                	push   $0x23
  800c63:	68 65 16 80 00       	push   $0x801665
  800c68:	e8 d8 f4 ff ff       	call   800145 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 48 16 80 00       	push   $0x801648
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 65 16 80 00       	push   $0x801665
  800caa:	e8 96 f4 ff ff       	call   800145 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 48 16 80 00       	push   $0x801648
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 65 16 80 00       	push   $0x801665
  800cec:	e8 54 f4 ff ff       	call   800145 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	be 00 00 00 00       	mov    $0x0,%esi
  800d04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	89 cb                	mov    %ecx,%ebx
  800d34:	89 cf                	mov    %ecx,%edi
  800d36:	89 ce                	mov    %ecx,%esi
  800d38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 0c                	push   $0xc
  800d44:	68 48 16 80 00       	push   $0x801648
  800d49:	6a 23                	push   $0x23
  800d4b:	68 65 16 80 00       	push   $0x801665
  800d50:	e8 f0 f3 ff ff       	call   800145 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	53                   	push   %ebx
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d67:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d69:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d6d:	74 2e                	je     800d9d <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	c1 ea 16             	shr    $0x16,%edx
  800d74:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d7b:	f6 c2 01             	test   $0x1,%dl
  800d7e:	74 1d                	je     800d9d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	c1 ea 0c             	shr    $0xc,%edx
  800d85:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d8c:	f6 c1 01             	test   $0x1,%cl
  800d8f:	74 0c                	je     800d9d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d98:	f6 c6 08             	test   $0x8,%dh
  800d9b:	75 14                	jne    800db1 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	68 74 16 80 00       	push   $0x801674
  800da5:	6a 21                	push   $0x21
  800da7:	68 07 17 80 00       	push   $0x801707
  800dac:	e8 94 f3 ff ff       	call   800145 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800db6:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800db8:	83 ec 04             	sub    $0x4,%esp
  800dbb:	6a 07                	push   $0x7
  800dbd:	68 00 f0 7f 00       	push   $0x7ff000
  800dc2:	6a 00                	push   $0x0
  800dc4:	e8 e5 fd ff ff       	call   800bae <sys_page_alloc>
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	79 14                	jns    800de4 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	68 12 17 80 00       	push   $0x801712
  800dd8:	6a 2b                	push   $0x2b
  800dda:	68 07 17 80 00       	push   $0x801707
  800ddf:	e8 61 f3 ff ff       	call   800145 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	68 00 10 00 00       	push   $0x1000
  800dec:	53                   	push   %ebx
  800ded:	68 00 f0 7f 00       	push   $0x7ff000
  800df2:	e8 40 fb ff ff       	call   800937 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800df7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dfe:	53                   	push   %ebx
  800dff:	6a 00                	push   $0x0
  800e01:	68 00 f0 7f 00       	push   $0x7ff000
  800e06:	6a 00                	push   $0x0
  800e08:	e8 e4 fd ff ff       	call   800bf1 <sys_page_map>
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	79 14                	jns    800e28 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	68 28 17 80 00       	push   $0x801728
  800e1c:	6a 2e                	push   $0x2e
  800e1e:	68 07 17 80 00       	push   $0x801707
  800e23:	e8 1d f3 ff ff       	call   800145 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	68 00 f0 7f 00       	push   $0x7ff000
  800e30:	6a 00                	push   $0x0
  800e32:	e8 fc fd ff ff       	call   800c33 <sys_page_unmap>
  800e37:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e48:	68 5d 0d 80 00       	push   $0x800d5d
  800e4d:	e8 cc 01 00 00       	call   80101e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e52:	b8 07 00 00 00       	mov    $0x7,%eax
  800e57:	cd 30                	int    $0x30
  800e59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 12                	jns    800e75 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e63:	50                   	push   %eax
  800e64:	68 3c 17 80 00       	push   $0x80173c
  800e69:	6a 6d                	push   $0x6d
  800e6b:	68 07 17 80 00       	push   $0x801707
  800e70:	e8 d0 f2 ff ff       	call   800145 <_panic>
  800e75:	89 c7                	mov    %eax,%edi
  800e77:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e80:	75 21                	jne    800ea3 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e82:	e8 e9 fc ff ff       	call   800b70 <sys_getenvid>
  800e87:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e8f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e94:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	e9 59 01 00 00       	jmp    800ffc <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800ea3:	89 d8                	mov    %ebx,%eax
  800ea5:	c1 e8 16             	shr    $0x16,%eax
  800ea8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eaf:	a8 01                	test   $0x1,%al
  800eb1:	0f 84 b0 00 00 00    	je     800f67 <fork+0x128>
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	c1 e8 0c             	shr    $0xc,%eax
  800ebc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec3:	f6 c2 01             	test   $0x1,%dl
  800ec6:	0f 84 9b 00 00 00    	je     800f67 <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800ecc:	89 c6                	mov    %eax,%esi
  800ece:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800ed1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed8:	f6 c6 08             	test   $0x8,%dh
  800edb:	75 0b                	jne    800ee8 <fork+0xa9>
  800edd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee4:	a8 02                	test   $0x2,%al
  800ee6:	74 57                	je     800f3f <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	68 05 08 00 00       	push   $0x805
  800ef0:	56                   	push   %esi
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	6a 00                	push   $0x0
  800ef5:	e8 f7 fc ff ff       	call   800bf1 <sys_page_map>
  800efa:	83 c4 20             	add    $0x20,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 12                	jns    800f13 <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800f01:	50                   	push   %eax
  800f02:	68 98 16 80 00       	push   $0x801698
  800f07:	6a 4a                	push   $0x4a
  800f09:	68 07 17 80 00       	push   $0x801707
  800f0e:	e8 32 f2 ff ff       	call   800145 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	68 05 08 00 00       	push   $0x805
  800f1b:	56                   	push   %esi
  800f1c:	6a 00                	push   $0x0
  800f1e:	56                   	push   %esi
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 cb fc ff ff       	call   800bf1 <sys_page_map>
  800f26:	83 c4 20             	add    $0x20,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 3a                	jns    800f67 <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 bc 16 80 00       	push   $0x8016bc
  800f33:	6a 4c                	push   $0x4c
  800f35:	68 07 17 80 00       	push   $0x801707
  800f3a:	e8 06 f2 ff ff       	call   800145 <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	6a 05                	push   $0x5
  800f44:	56                   	push   %esi
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	6a 00                	push   $0x0
  800f49:	e8 a3 fc ff ff       	call   800bf1 <sys_page_map>
  800f4e:	83 c4 20             	add    $0x20,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	79 12                	jns    800f67 <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800f55:	50                   	push   %eax
  800f56:	68 e4 16 80 00       	push   $0x8016e4
  800f5b:	6a 4f                	push   $0x4f
  800f5d:	68 07 17 80 00       	push   $0x801707
  800f62:	e8 de f1 ff ff       	call   800145 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800f67:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f6d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f73:	0f 85 2a ff ff ff    	jne    800ea3 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	6a 07                	push   $0x7
  800f7e:	68 00 f0 bf ee       	push   $0xeebff000
  800f83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f86:	e8 23 fc ff ff       	call   800bae <sys_page_alloc>
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	79 14                	jns    800fa6 <fork+0x167>
                panic("user stack alloc failure\n");	
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 4c 17 80 00       	push   $0x80174c
  800f9a:	6a 76                	push   $0x76
  800f9c:	68 07 17 80 00       	push   $0x801707
  800fa1:	e8 9f f1 ff ff       	call   800145 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800fa6:	83 ec 08             	sub    $0x8,%esp
  800fa9:	68 8d 10 80 00       	push   $0x80108d
  800fae:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb1:	e8 01 fd ff ff       	call   800cb7 <sys_env_set_pgfault_upcall>
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 14                	jns    800fd1 <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  800fbd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc0:	68 66 17 80 00       	push   $0x801766
  800fc5:	6a 79                	push   $0x79
  800fc7:	68 07 17 80 00       	push   $0x801707
  800fcc:	e8 74 f1 ff ff       	call   800145 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800fd1:	83 ec 08             	sub    $0x8,%esp
  800fd4:	6a 02                	push   $0x2
  800fd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd9:	e8 97 fc ff ff       	call   800c75 <sys_env_set_status>
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 14                	jns    800ff9 <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  800fe5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe8:	68 83 17 80 00       	push   $0x801783
  800fed:	6a 7b                	push   $0x7b
  800fef:	68 07 17 80 00       	push   $0x801707
  800ff4:	e8 4c f1 ff ff       	call   800145 <_panic>
        return forkid;
  800ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <sfork>:

// Challenge!
int
sfork(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80100a:	68 9a 17 80 00       	push   $0x80179a
  80100f:	68 83 00 00 00       	push   $0x83
  801014:	68 07 17 80 00       	push   $0x801707
  801019:	e8 27 f1 ff ff       	call   800145 <_panic>

0080101e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801024:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80102b:	75 2c                	jne    801059 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	6a 07                	push   $0x7
  801032:	68 00 f0 bf ee       	push   $0xeebff000
  801037:	6a 00                	push   $0x0
  801039:	e8 70 fb ff ff       	call   800bae <sys_page_alloc>
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	74 14                	je     801059 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	68 b0 17 80 00       	push   $0x8017b0
  80104d:	6a 21                	push   $0x21
  80104f:	68 14 18 80 00       	push   $0x801814
  801054:	e8 ec f0 ff ff       	call   800145 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	a3 0c 20 80 00       	mov    %eax,0x80200c
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	68 8d 10 80 00       	push   $0x80108d
  801069:	6a 00                	push   $0x0
  80106b:	e8 47 fc ff ff       	call   800cb7 <sys_env_set_pgfault_upcall>
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	79 14                	jns    80108b <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	68 dc 17 80 00       	push   $0x8017dc
  80107f:	6a 29                	push   $0x29
  801081:	68 14 18 80 00       	push   $0x801814
  801086:	e8 ba f0 ff ff       	call   800145 <_panic>
}
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80108d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80108e:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801093:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801095:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801098:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80109d:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8010a1:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8010a5:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8010a7:	83 c4 08             	add    $0x8,%esp
        popal
  8010aa:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8010ab:	83 c4 04             	add    $0x4,%esp
        popfl
  8010ae:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8010af:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8010b0:	c3                   	ret    
  8010b1:	66 90                	xchg   %ax,%ax
  8010b3:	66 90                	xchg   %ax,%ax
  8010b5:	66 90                	xchg   %ax,%ax
  8010b7:	66 90                	xchg   %ax,%ax
  8010b9:	66 90                	xchg   %ax,%ax
  8010bb:	66 90                	xchg   %ax,%ax
  8010bd:	66 90                	xchg   %ax,%ax
  8010bf:	90                   	nop

008010c0 <__udivdi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	83 ec 10             	sub    $0x10,%esp
  8010c6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8010ca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8010ce:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010d2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010d6:	85 d2                	test   %edx,%edx
  8010d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010dc:	89 34 24             	mov    %esi,(%esp)
  8010df:	89 c8                	mov    %ecx,%eax
  8010e1:	75 35                	jne    801118 <__udivdi3+0x58>
  8010e3:	39 f1                	cmp    %esi,%ecx
  8010e5:	0f 87 bd 00 00 00    	ja     8011a8 <__udivdi3+0xe8>
  8010eb:	85 c9                	test   %ecx,%ecx
  8010ed:	89 cd                	mov    %ecx,%ebp
  8010ef:	75 0b                	jne    8010fc <__udivdi3+0x3c>
  8010f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f6:	31 d2                	xor    %edx,%edx
  8010f8:	f7 f1                	div    %ecx
  8010fa:	89 c5                	mov    %eax,%ebp
  8010fc:	89 f0                	mov    %esi,%eax
  8010fe:	31 d2                	xor    %edx,%edx
  801100:	f7 f5                	div    %ebp
  801102:	89 c6                	mov    %eax,%esi
  801104:	89 f8                	mov    %edi,%eax
  801106:	f7 f5                	div    %ebp
  801108:	89 f2                	mov    %esi,%edx
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    
  801111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801118:	3b 14 24             	cmp    (%esp),%edx
  80111b:	77 7b                	ja     801198 <__udivdi3+0xd8>
  80111d:	0f bd f2             	bsr    %edx,%esi
  801120:	83 f6 1f             	xor    $0x1f,%esi
  801123:	0f 84 97 00 00 00    	je     8011c0 <__udivdi3+0x100>
  801129:	bd 20 00 00 00       	mov    $0x20,%ebp
  80112e:	89 d7                	mov    %edx,%edi
  801130:	89 f1                	mov    %esi,%ecx
  801132:	29 f5                	sub    %esi,%ebp
  801134:	d3 e7                	shl    %cl,%edi
  801136:	89 c2                	mov    %eax,%edx
  801138:	89 e9                	mov    %ebp,%ecx
  80113a:	d3 ea                	shr    %cl,%edx
  80113c:	89 f1                	mov    %esi,%ecx
  80113e:	09 fa                	or     %edi,%edx
  801140:	8b 3c 24             	mov    (%esp),%edi
  801143:	d3 e0                	shl    %cl,%eax
  801145:	89 54 24 08          	mov    %edx,0x8(%esp)
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801153:	89 fa                	mov    %edi,%edx
  801155:	d3 ea                	shr    %cl,%edx
  801157:	89 f1                	mov    %esi,%ecx
  801159:	d3 e7                	shl    %cl,%edi
  80115b:	89 e9                	mov    %ebp,%ecx
  80115d:	d3 e8                	shr    %cl,%eax
  80115f:	09 c7                	or     %eax,%edi
  801161:	89 f8                	mov    %edi,%eax
  801163:	f7 74 24 08          	divl   0x8(%esp)
  801167:	89 d5                	mov    %edx,%ebp
  801169:	89 c7                	mov    %eax,%edi
  80116b:	f7 64 24 0c          	mull   0xc(%esp)
  80116f:	39 d5                	cmp    %edx,%ebp
  801171:	89 14 24             	mov    %edx,(%esp)
  801174:	72 11                	jb     801187 <__udivdi3+0xc7>
  801176:	8b 54 24 04          	mov    0x4(%esp),%edx
  80117a:	89 f1                	mov    %esi,%ecx
  80117c:	d3 e2                	shl    %cl,%edx
  80117e:	39 c2                	cmp    %eax,%edx
  801180:	73 5e                	jae    8011e0 <__udivdi3+0x120>
  801182:	3b 2c 24             	cmp    (%esp),%ebp
  801185:	75 59                	jne    8011e0 <__udivdi3+0x120>
  801187:	8d 47 ff             	lea    -0x1(%edi),%eax
  80118a:	31 f6                	xor    %esi,%esi
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	5e                   	pop    %esi
  801192:	5f                   	pop    %edi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    
  801195:	8d 76 00             	lea    0x0(%esi),%esi
  801198:	31 f6                	xor    %esi,%esi
  80119a:	31 c0                	xor    %eax,%eax
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    
  8011a5:	8d 76 00             	lea    0x0(%esi),%esi
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	31 f6                	xor    %esi,%esi
  8011ac:	89 f8                	mov    %edi,%eax
  8011ae:	f7 f1                	div    %ecx
  8011b0:	89 f2                	mov    %esi,%edx
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    
  8011b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8011c4:	76 0b                	jbe    8011d1 <__udivdi3+0x111>
  8011c6:	31 c0                	xor    %eax,%eax
  8011c8:	3b 14 24             	cmp    (%esp),%edx
  8011cb:	0f 83 37 ff ff ff    	jae    801108 <__udivdi3+0x48>
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d6:	e9 2d ff ff ff       	jmp    801108 <__udivdi3+0x48>
  8011db:	90                   	nop
  8011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	89 f8                	mov    %edi,%eax
  8011e2:	31 f6                	xor    %esi,%esi
  8011e4:	e9 1f ff ff ff       	jmp    801108 <__udivdi3+0x48>
  8011e9:	66 90                	xchg   %ax,%ax
  8011eb:	66 90                	xchg   %ax,%ax
  8011ed:	66 90                	xchg   %ax,%ax
  8011ef:	90                   	nop

008011f0 <__umoddi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	83 ec 20             	sub    $0x20,%esp
  8011f6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8011fa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011fe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801202:	89 c6                	mov    %eax,%esi
  801204:	89 44 24 10          	mov    %eax,0x10(%esp)
  801208:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80120c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801210:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801214:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801218:	89 74 24 18          	mov    %esi,0x18(%esp)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	89 c2                	mov    %eax,%edx
  801220:	75 1e                	jne    801240 <__umoddi3+0x50>
  801222:	39 f7                	cmp    %esi,%edi
  801224:	76 52                	jbe    801278 <__umoddi3+0x88>
  801226:	89 c8                	mov    %ecx,%eax
  801228:	89 f2                	mov    %esi,%edx
  80122a:	f7 f7                	div    %edi
  80122c:	89 d0                	mov    %edx,%eax
  80122e:	31 d2                	xor    %edx,%edx
  801230:	83 c4 20             	add    $0x20,%esp
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    
  801237:	89 f6                	mov    %esi,%esi
  801239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801240:	39 f0                	cmp    %esi,%eax
  801242:	77 5c                	ja     8012a0 <__umoddi3+0xb0>
  801244:	0f bd e8             	bsr    %eax,%ebp
  801247:	83 f5 1f             	xor    $0x1f,%ebp
  80124a:	75 64                	jne    8012b0 <__umoddi3+0xc0>
  80124c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801250:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801254:	0f 86 f6 00 00 00    	jbe    801350 <__umoddi3+0x160>
  80125a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80125e:	0f 82 ec 00 00 00    	jb     801350 <__umoddi3+0x160>
  801264:	8b 44 24 14          	mov    0x14(%esp),%eax
  801268:	8b 54 24 18          	mov    0x18(%esp),%edx
  80126c:	83 c4 20             	add    $0x20,%esp
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	85 ff                	test   %edi,%edi
  80127a:	89 fd                	mov    %edi,%ebp
  80127c:	75 0b                	jne    801289 <__umoddi3+0x99>
  80127e:	b8 01 00 00 00       	mov    $0x1,%eax
  801283:	31 d2                	xor    %edx,%edx
  801285:	f7 f7                	div    %edi
  801287:	89 c5                	mov    %eax,%ebp
  801289:	8b 44 24 10          	mov    0x10(%esp),%eax
  80128d:	31 d2                	xor    %edx,%edx
  80128f:	f7 f5                	div    %ebp
  801291:	89 c8                	mov    %ecx,%eax
  801293:	f7 f5                	div    %ebp
  801295:	eb 95                	jmp    80122c <__umoddi3+0x3c>
  801297:	89 f6                	mov    %esi,%esi
  801299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8012a0:	89 c8                	mov    %ecx,%eax
  8012a2:	89 f2                	mov    %esi,%edx
  8012a4:	83 c4 20             	add    $0x20,%esp
  8012a7:	5e                   	pop    %esi
  8012a8:	5f                   	pop    %edi
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    
  8012ab:	90                   	nop
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	b8 20 00 00 00       	mov    $0x20,%eax
  8012b5:	89 e9                	mov    %ebp,%ecx
  8012b7:	29 e8                	sub    %ebp,%eax
  8012b9:	d3 e2                	shl    %cl,%edx
  8012bb:	89 c7                	mov    %eax,%edi
  8012bd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8012c1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8012c5:	89 f9                	mov    %edi,%ecx
  8012c7:	d3 e8                	shr    %cl,%eax
  8012c9:	89 c1                	mov    %eax,%ecx
  8012cb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8012cf:	09 d1                	or     %edx,%ecx
  8012d1:	89 fa                	mov    %edi,%edx
  8012d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012d7:	89 e9                	mov    %ebp,%ecx
  8012d9:	d3 e0                	shl    %cl,%eax
  8012db:	89 f9                	mov    %edi,%ecx
  8012dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e1:	89 f0                	mov    %esi,%eax
  8012e3:	d3 e8                	shr    %cl,%eax
  8012e5:	89 e9                	mov    %ebp,%ecx
  8012e7:	89 c7                	mov    %eax,%edi
  8012e9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8012ed:	d3 e6                	shl    %cl,%esi
  8012ef:	89 d1                	mov    %edx,%ecx
  8012f1:	89 fa                	mov    %edi,%edx
  8012f3:	d3 e8                	shr    %cl,%eax
  8012f5:	89 e9                	mov    %ebp,%ecx
  8012f7:	09 f0                	or     %esi,%eax
  8012f9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8012fd:	f7 74 24 10          	divl   0x10(%esp)
  801301:	d3 e6                	shl    %cl,%esi
  801303:	89 d1                	mov    %edx,%ecx
  801305:	f7 64 24 0c          	mull   0xc(%esp)
  801309:	39 d1                	cmp    %edx,%ecx
  80130b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80130f:	89 d7                	mov    %edx,%edi
  801311:	89 c6                	mov    %eax,%esi
  801313:	72 0a                	jb     80131f <__umoddi3+0x12f>
  801315:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801319:	73 10                	jae    80132b <__umoddi3+0x13b>
  80131b:	39 d1                	cmp    %edx,%ecx
  80131d:	75 0c                	jne    80132b <__umoddi3+0x13b>
  80131f:	89 d7                	mov    %edx,%edi
  801321:	89 c6                	mov    %eax,%esi
  801323:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801327:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80132b:	89 ca                	mov    %ecx,%edx
  80132d:	89 e9                	mov    %ebp,%ecx
  80132f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801333:	29 f0                	sub    %esi,%eax
  801335:	19 fa                	sbb    %edi,%edx
  801337:	d3 e8                	shr    %cl,%eax
  801339:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80133e:	89 d7                	mov    %edx,%edi
  801340:	d3 e7                	shl    %cl,%edi
  801342:	89 e9                	mov    %ebp,%ecx
  801344:	09 f8                	or     %edi,%eax
  801346:	d3 ea                	shr    %cl,%edx
  801348:	83 c4 20             	add    $0x20,%esp
  80134b:	5e                   	pop    %esi
  80134c:	5f                   	pop    %edi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    
  80134f:	90                   	nop
  801350:	8b 74 24 10          	mov    0x10(%esp),%esi
  801354:	29 f9                	sub    %edi,%ecx
  801356:	19 c6                	sbb    %eax,%esi
  801358:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80135c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801360:	e9 ff fe ff ff       	jmp    801264 <__umoddi3+0x74>
