
obj/user/stresssched.debug:     file format elf32-i386


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
  800038:	e8 3b 0b 00 00       	call   800b78 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 e1 0e 00 00       	call   800f2a <fork>
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
  80005c:	e8 36 0b 00 00       	call   800b97 <sys_yield>
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
  800085:	e8 0d 0b 00 00       	call   800b97 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
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
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 80 27 80 00       	push   $0x802780
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 a8 27 80 00       	push   $0x8027a8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 bb 27 80 00       	push   $0x8027bb
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
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
  8000f8:	e8 7b 0a 00 00       	call   800b78 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 e0 11 00 00       	call   80131e <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 ef 09 00 00       	call   800b37 <sys_env_destroy>
  800148:	83 c4 10             	add    $0x10,%esp
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 18 0a 00 00       	call   800b78 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 e4 27 80 00       	push   $0x8027e4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 d7 27 80 00 	movl   $0x8027d7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 37 09 00 00       	call   800afa <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 4f 01 00 00       	call   800358 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 dc 08 00 00       	call   800afa <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 d1                	mov    %edx,%ecx
  80024f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800252:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800265:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800268:	72 05                	jb     80026f <printnum+0x35>
  80026a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80026d:	77 3e                	ja     8002ad <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	ff 75 18             	pushl  0x18(%ebp)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	53                   	push   %ebx
  800279:	50                   	push   %eax
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 12 22 00 00       	call   8024a0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 13                	jmp    8002b4 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ad:	83 eb 01             	sub    $0x1,%ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ed                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002be:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c7:	e8 04 23 00 00       	call   8025d0 <__umoddi3>
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	0f be 80 07 28 80 00 	movsbl 0x802807(%eax),%eax
  8002d6:	50                   	push   %eax
  8002d7:	ff d7                	call   *%edi
  8002d9:	83 c4 10             	add    $0x10,%esp
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    

008002e4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e7:	83 fa 01             	cmp    $0x1,%edx
  8002ea:	7e 0e                	jle    8002fa <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f1:	89 08                	mov    %ecx,(%eax)
  8002f3:	8b 02                	mov    (%edx),%eax
  8002f5:	8b 52 04             	mov    0x4(%edx),%edx
  8002f8:	eb 22                	jmp    80031c <getuint+0x38>
	else if (lflag)
  8002fa:	85 d2                	test   %edx,%edx
  8002fc:	74 10                	je     80030e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 04             	lea    0x4(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	eb 0e                	jmp    80031c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800324:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	3b 50 04             	cmp    0x4(%eax),%edx
  80032d:	73 0a                	jae    800339 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800332:	89 08                	mov    %ecx,(%eax)
  800334:	8b 45 08             	mov    0x8(%ebp),%eax
  800337:	88 02                	mov    %al,(%edx)
}
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800341:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800344:	50                   	push   %eax
  800345:	ff 75 10             	pushl  0x10(%ebp)
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	e8 05 00 00 00       	call   800358 <vprintfmt>
	va_end(ap);
  800353:	83 c4 10             	add    $0x10,%esp
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
  80035e:	83 ec 2c             	sub    $0x2c,%esp
  800361:	8b 75 08             	mov    0x8(%ebp),%esi
  800364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800367:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036a:	eb 12                	jmp    80037e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036c:	85 c0                	test   %eax,%eax
  80036e:	0f 84 90 03 00 00    	je     800704 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	53                   	push   %ebx
  800378:	50                   	push   %eax
  800379:	ff d6                	call   *%esi
  80037b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037e:	83 c7 01             	add    $0x1,%edi
  800381:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e2                	jne    80036c <vprintfmt+0x14>
  80038a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80038e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800395:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a8:	eb 07                	jmp    8003b1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ad:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8d 47 01             	lea    0x1(%edi),%eax
  8003b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b7:	0f b6 07             	movzbl (%edi),%eax
  8003ba:	0f b6 c8             	movzbl %al,%ecx
  8003bd:	83 e8 23             	sub    $0x23,%eax
  8003c0:	3c 55                	cmp    $0x55,%al
  8003c2:	0f 87 21 03 00 00    	ja     8006e9 <vprintfmt+0x391>
  8003c8:	0f b6 c0             	movzbl %al,%eax
  8003cb:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d9:	eb d6                	jmp    8003b1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003de:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ed:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f3:	83 fa 09             	cmp    $0x9,%edx
  8003f6:	77 39                	ja     800431 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fb:	eb e9                	jmp    8003e6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 48 04             	lea    0x4(%eax),%ecx
  800403:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800406:	8b 00                	mov    (%eax),%eax
  800408:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040e:	eb 27                	jmp    800437 <vprintfmt+0xdf>
  800410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800413:	85 c0                	test   %eax,%eax
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	0f 49 c8             	cmovns %eax,%ecx
  80041d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800423:	eb 8c                	jmp    8003b1 <vprintfmt+0x59>
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800428:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042f:	eb 80                	jmp    8003b1 <vprintfmt+0x59>
  800431:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800434:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800437:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043b:	0f 89 70 ff ff ff    	jns    8003b1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800441:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800447:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044e:	e9 5e ff ff ff       	jmp    8003b1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800453:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800459:	e9 53 ff ff ff       	jmp    8003b1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	ff 30                	pushl  (%eax)
  80046d:	ff d6                	call   *%esi
			break;
  80046f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800475:	e9 04 ff ff ff       	jmp    80037e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 50 04             	lea    0x4(%eax),%edx
  800480:	89 55 14             	mov    %edx,0x14(%ebp)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	99                   	cltd   
  800486:	31 d0                	xor    %edx,%eax
  800488:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048a:	83 f8 0f             	cmp    $0xf,%eax
  80048d:	7f 0b                	jg     80049a <vprintfmt+0x142>
  80048f:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	75 18                	jne    8004b2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049a:	50                   	push   %eax
  80049b:	68 1f 28 80 00       	push   $0x80281f
  8004a0:	53                   	push   %ebx
  8004a1:	56                   	push   %esi
  8004a2:	e8 94 fe ff ff       	call   80033b <printfmt>
  8004a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ad:	e9 cc fe ff ff       	jmp    80037e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b2:	52                   	push   %edx
  8004b3:	68 31 2d 80 00       	push   $0x802d31
  8004b8:	53                   	push   %ebx
  8004b9:	56                   	push   %esi
  8004ba:	e8 7c fe ff ff       	call   80033b <printfmt>
  8004bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c5:	e9 b4 fe ff ff       	jmp    80037e <vprintfmt+0x26>
  8004ca:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d0:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004de:	85 ff                	test   %edi,%edi
  8004e0:	ba 18 28 80 00       	mov    $0x802818,%edx
  8004e5:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ec:	0f 84 92 00 00 00    	je     800584 <vprintfmt+0x22c>
  8004f2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f6:	0f 8e 96 00 00 00    	jle    800592 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	51                   	push   %ecx
  800500:	57                   	push   %edi
  800501:	e8 86 02 00 00       	call   80078c <strnlen>
  800506:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800509:	29 c1                	sub    %eax,%ecx
  80050b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800511:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800515:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800518:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	eb 0f                	jmp    80052e <vprintfmt+0x1d6>
					putch(padc, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	ff 75 e0             	pushl  -0x20(%ebp)
  800526:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	83 ef 01             	sub    $0x1,%edi
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	85 ff                	test   %edi,%edi
  800530:	7f ed                	jg     80051f <vprintfmt+0x1c7>
  800532:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800535:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800538:	85 c9                	test   %ecx,%ecx
  80053a:	b8 00 00 00 00       	mov    $0x0,%eax
  80053f:	0f 49 c1             	cmovns %ecx,%eax
  800542:	29 c1                	sub    %eax,%ecx
  800544:	89 75 08             	mov    %esi,0x8(%ebp)
  800547:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054d:	89 cb                	mov    %ecx,%ebx
  80054f:	eb 4d                	jmp    80059e <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800555:	74 1b                	je     800572 <vprintfmt+0x21a>
  800557:	0f be c0             	movsbl %al,%eax
  80055a:	83 e8 20             	sub    $0x20,%eax
  80055d:	83 f8 5e             	cmp    $0x5e,%eax
  800560:	76 10                	jbe    800572 <vprintfmt+0x21a>
					putch('?', putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 0c             	pushl  0xc(%ebp)
  800568:	6a 3f                	push   $0x3f
  80056a:	ff 55 08             	call   *0x8(%ebp)
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 0d                	jmp    80057f <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	52                   	push   %edx
  800579:	ff 55 08             	call   *0x8(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057f:	83 eb 01             	sub    $0x1,%ebx
  800582:	eb 1a                	jmp    80059e <vprintfmt+0x246>
  800584:	89 75 08             	mov    %esi,0x8(%ebp)
  800587:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800590:	eb 0c                	jmp    80059e <vprintfmt+0x246>
  800592:	89 75 08             	mov    %esi,0x8(%ebp)
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800598:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059e:	83 c7 01             	add    $0x1,%edi
  8005a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a5:	0f be d0             	movsbl %al,%edx
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	74 23                	je     8005cf <vprintfmt+0x277>
  8005ac:	85 f6                	test   %esi,%esi
  8005ae:	78 a1                	js     800551 <vprintfmt+0x1f9>
  8005b0:	83 ee 01             	sub    $0x1,%esi
  8005b3:	79 9c                	jns    800551 <vprintfmt+0x1f9>
  8005b5:	89 df                	mov    %ebx,%edi
  8005b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bd:	eb 18                	jmp    8005d7 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 20                	push   $0x20
  8005c5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c7:	83 ef 01             	sub    $0x1,%edi
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	eb 08                	jmp    8005d7 <vprintfmt+0x27f>
  8005cf:	89 df                	mov    %ebx,%edi
  8005d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d7:	85 ff                	test   %edi,%edi
  8005d9:	7f e4                	jg     8005bf <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005de:	e9 9b fd ff ff       	jmp    80037e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e3:	83 fa 01             	cmp    $0x1,%edx
  8005e6:	7e 16                	jle    8005fe <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 08             	lea    0x8(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 50 04             	mov    0x4(%eax),%edx
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fc:	eb 32                	jmp    800630 <vprintfmt+0x2d8>
	else if (lflag)
  8005fe:	85 d2                	test   %edx,%edx
  800600:	74 18                	je     80061a <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 04             	lea    0x4(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 00                	mov    (%eax),%eax
  80060d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800610:	89 c1                	mov    %eax,%ecx
  800612:	c1 f9 1f             	sar    $0x1f,%ecx
  800615:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800618:	eb 16                	jmp    800630 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800628:	89 c1                	mov    %eax,%ecx
  80062a:	c1 f9 1f             	sar    $0x1f,%ecx
  80062d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800630:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800633:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800636:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063f:	79 74                	jns    8006b5 <vprintfmt+0x35d>
				putch('-', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 2d                	push   $0x2d
  800647:	ff d6                	call   *%esi
				num = -(long long) num;
  800649:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064f:	f7 d8                	neg    %eax
  800651:	83 d2 00             	adc    $0x0,%edx
  800654:	f7 da                	neg    %edx
  800656:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800659:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065e:	eb 55                	jmp    8006b5 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 7c fc ff ff       	call   8002e4 <getuint>
			base = 10;
  800668:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066d:	eb 46                	jmp    8006b5 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 6d fc ff ff       	call   8002e4 <getuint>
                        base = 8;
  800677:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80067c:	eb 37                	jmp    8006b5 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 30                	push   $0x30
  800684:	ff d6                	call   *%esi
			putch('x', putdat);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 78                	push   $0x78
  80068c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800697:	8b 00                	mov    (%eax),%eax
  800699:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a6:	eb 0d                	jmp    8006b5 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ab:	e8 34 fc ff ff       	call   8002e4 <getuint>
			base = 16;
  8006b0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b5:	83 ec 0c             	sub    $0xc,%esp
  8006b8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bc:	57                   	push   %edi
  8006bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c0:	51                   	push   %ecx
  8006c1:	52                   	push   %edx
  8006c2:	50                   	push   %eax
  8006c3:	89 da                	mov    %ebx,%edx
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	e8 6e fb ff ff       	call   80023a <printnum>
			break;
  8006cc:	83 c4 20             	add    $0x20,%esp
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d2:	e9 a7 fc ff ff       	jmp    80037e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	51                   	push   %ecx
  8006dc:	ff d6                	call   *%esi
			break;
  8006de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e4:	e9 95 fc ff ff       	jmp    80037e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	6a 25                	push   $0x25
  8006ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb 03                	jmp    8006f9 <vprintfmt+0x3a1>
  8006f6:	83 ef 01             	sub    $0x1,%edi
  8006f9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fd:	75 f7                	jne    8006f6 <vprintfmt+0x39e>
  8006ff:	e9 7a fc ff ff       	jmp    80037e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	83 ec 18             	sub    $0x18,%esp
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800718:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 26                	je     800753 <vsnprintf+0x47>
  80072d:	85 d2                	test   %edx,%edx
  80072f:	7e 22                	jle    800753 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800731:	ff 75 14             	pushl  0x14(%ebp)
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073a:	50                   	push   %eax
  80073b:	68 1e 03 80 00       	push   $0x80031e
  800740:	e8 13 fc ff ff       	call   800358 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800745:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800748:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 05                	jmp    800758 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800763:	50                   	push   %eax
  800764:	ff 75 10             	pushl  0x10(%ebp)
  800767:	ff 75 0c             	pushl  0xc(%ebp)
  80076a:	ff 75 08             	pushl  0x8(%ebp)
  80076d:	e8 9a ff ff ff       	call   80070c <vsnprintf>
	va_end(ap);

	return rc;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	eb 03                	jmp    800784 <strlen+0x10>
		n++;
  800781:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800788:	75 f7                	jne    800781 <strlen+0xd>
		n++;
	return n;
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	ba 00 00 00 00       	mov    $0x0,%edx
  80079a:	eb 03                	jmp    80079f <strnlen+0x13>
		n++;
  80079c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	39 c2                	cmp    %eax,%edx
  8007a1:	74 08                	je     8007ab <strnlen+0x1f>
  8007a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a7:	75 f3                	jne    80079c <strnlen+0x10>
  8007a9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	53                   	push   %ebx
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	83 c2 01             	add    $0x1,%edx
  8007bc:	83 c1 01             	add    $0x1,%ecx
  8007bf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c6:	84 db                	test   %bl,%bl
  8007c8:	75 ef                	jne    8007b9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d4:	53                   	push   %ebx
  8007d5:	e8 9a ff ff ff       	call   800774 <strlen>
  8007da:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	01 d8                	add    %ebx,%eax
  8007e2:	50                   	push   %eax
  8007e3:	e8 c5 ff ff ff       	call   8007ad <strcpy>
	return dst;
}
  8007e8:	89 d8                	mov    %ebx,%eax
  8007ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	89 f3                	mov    %esi,%ebx
  8007fc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	89 f2                	mov    %esi,%edx
  800801:	eb 0f                	jmp    800812 <strncpy+0x23>
		*dst++ = *src;
  800803:	83 c2 01             	add    $0x1,%edx
  800806:	0f b6 01             	movzbl (%ecx),%eax
  800809:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080c:	80 39 01             	cmpb   $0x1,(%ecx)
  80080f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	39 da                	cmp    %ebx,%edx
  800814:	75 ed                	jne    800803 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800816:	89 f0                	mov    %esi,%eax
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	8b 55 10             	mov    0x10(%ebp),%edx
  80082a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	85 d2                	test   %edx,%edx
  80082e:	74 21                	je     800851 <strlcpy+0x35>
  800830:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800834:	89 f2                	mov    %esi,%edx
  800836:	eb 09                	jmp    800841 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800838:	83 c2 01             	add    $0x1,%edx
  80083b:	83 c1 01             	add    $0x1,%ecx
  80083e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800841:	39 c2                	cmp    %eax,%edx
  800843:	74 09                	je     80084e <strlcpy+0x32>
  800845:	0f b6 19             	movzbl (%ecx),%ebx
  800848:	84 db                	test   %bl,%bl
  80084a:	75 ec                	jne    800838 <strlcpy+0x1c>
  80084c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800851:	29 f0                	sub    %esi,%eax
}
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800860:	eb 06                	jmp    800868 <strcmp+0x11>
		p++, q++;
  800862:	83 c1 01             	add    $0x1,%ecx
  800865:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	84 c0                	test   %al,%al
  80086d:	74 04                	je     800873 <strcmp+0x1c>
  80086f:	3a 02                	cmp    (%edx),%al
  800871:	74 ef                	je     800862 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 c0             	movzbl %al,%eax
  800876:	0f b6 12             	movzbl (%edx),%edx
  800879:	29 d0                	sub    %edx,%eax
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	53                   	push   %ebx
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
  800887:	89 c3                	mov    %eax,%ebx
  800889:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088c:	eb 06                	jmp    800894 <strncmp+0x17>
		n--, p++, q++;
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800894:	39 d8                	cmp    %ebx,%eax
  800896:	74 15                	je     8008ad <strncmp+0x30>
  800898:	0f b6 08             	movzbl (%eax),%ecx
  80089b:	84 c9                	test   %cl,%cl
  80089d:	74 04                	je     8008a3 <strncmp+0x26>
  80089f:	3a 0a                	cmp    (%edx),%cl
  8008a1:	74 eb                	je     80088e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 00             	movzbl (%eax),%eax
  8008a6:	0f b6 12             	movzbl (%edx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
  8008ab:	eb 05                	jmp    8008b2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bf:	eb 07                	jmp    8008c8 <strchr+0x13>
		if (*s == c)
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	74 0f                	je     8008d4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	0f b6 10             	movzbl (%eax),%edx
  8008cb:	84 d2                	test   %dl,%dl
  8008cd:	75 f2                	jne    8008c1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e0:	eb 03                	jmp    8008e5 <strfind+0xf>
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	74 04                	je     8008f0 <strfind+0x1a>
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	75 f2                	jne    8008e2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	57                   	push   %edi
  8008f6:	56                   	push   %esi
  8008f7:	53                   	push   %ebx
  8008f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fe:	85 c9                	test   %ecx,%ecx
  800900:	74 36                	je     800938 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800902:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800908:	75 28                	jne    800932 <memset+0x40>
  80090a:	f6 c1 03             	test   $0x3,%cl
  80090d:	75 23                	jne    800932 <memset+0x40>
		c &= 0xFF;
  80090f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800913:	89 d3                	mov    %edx,%ebx
  800915:	c1 e3 08             	shl    $0x8,%ebx
  800918:	89 d6                	mov    %edx,%esi
  80091a:	c1 e6 18             	shl    $0x18,%esi
  80091d:	89 d0                	mov    %edx,%eax
  80091f:	c1 e0 10             	shl    $0x10,%eax
  800922:	09 f0                	or     %esi,%eax
  800924:	09 c2                	or     %eax,%edx
  800926:	89 d0                	mov    %edx,%eax
  800928:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80092d:	fc                   	cld    
  80092e:	f3 ab                	rep stos %eax,%es:(%edi)
  800930:	eb 06                	jmp    800938 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
  800935:	fc                   	cld    
  800936:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800938:	89 f8                	mov    %edi,%eax
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094d:	39 c6                	cmp    %eax,%esi
  80094f:	73 35                	jae    800986 <memmove+0x47>
  800951:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800954:	39 d0                	cmp    %edx,%eax
  800956:	73 2e                	jae    800986 <memmove+0x47>
		s += n;
		d += n;
  800958:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80095b:	89 d6                	mov    %edx,%esi
  80095d:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800965:	75 13                	jne    80097a <memmove+0x3b>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	75 0e                	jne    80097a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096c:	83 ef 04             	sub    $0x4,%edi
  80096f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800972:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800975:	fd                   	std    
  800976:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800978:	eb 09                	jmp    800983 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097a:	83 ef 01             	sub    $0x1,%edi
  80097d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800980:	fd                   	std    
  800981:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800983:	fc                   	cld    
  800984:	eb 1d                	jmp    8009a3 <memmove+0x64>
  800986:	89 f2                	mov    %esi,%edx
  800988:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	f6 c2 03             	test   $0x3,%dl
  80098d:	75 0f                	jne    80099e <memmove+0x5f>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	75 0a                	jne    80099e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800994:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800997:	89 c7                	mov    %eax,%edi
  800999:	fc                   	cld    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099c:	eb 05                	jmp    8009a3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009aa:	ff 75 10             	pushl  0x10(%ebp)
  8009ad:	ff 75 0c             	pushl  0xc(%ebp)
  8009b0:	ff 75 08             	pushl  0x8(%ebp)
  8009b3:	e8 87 ff ff ff       	call   80093f <memmove>
}
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c5:	89 c6                	mov    %eax,%esi
  8009c7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ca:	eb 1a                	jmp    8009e6 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cc:	0f b6 08             	movzbl (%eax),%ecx
  8009cf:	0f b6 1a             	movzbl (%edx),%ebx
  8009d2:	38 d9                	cmp    %bl,%cl
  8009d4:	74 0a                	je     8009e0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d6:	0f b6 c1             	movzbl %cl,%eax
  8009d9:	0f b6 db             	movzbl %bl,%ebx
  8009dc:	29 d8                	sub    %ebx,%eax
  8009de:	eb 0f                	jmp    8009ef <memcmp+0x35>
		s1++, s2++;
  8009e0:	83 c0 01             	add    $0x1,%eax
  8009e3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e6:	39 f0                	cmp    %esi,%eax
  8009e8:	75 e2                	jne    8009cc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fc:	89 c2                	mov    %eax,%edx
  8009fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a01:	eb 07                	jmp    800a0a <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	38 08                	cmp    %cl,(%eax)
  800a05:	74 07                	je     800a0e <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	72 f5                	jb     800a03 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1c:	eb 03                	jmp    800a21 <strtol+0x11>
		s++;
  800a1e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	0f b6 01             	movzbl (%ecx),%eax
  800a24:	3c 09                	cmp    $0x9,%al
  800a26:	74 f6                	je     800a1e <strtol+0xe>
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f2                	je     800a1e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2c:	3c 2b                	cmp    $0x2b,%al
  800a2e:	75 0a                	jne    800a3a <strtol+0x2a>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
  800a38:	eb 10                	jmp    800a4a <strtol+0x3a>
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3f:	3c 2d                	cmp    $0x2d,%al
  800a41:	75 07                	jne    800a4a <strtol+0x3a>
		s++, neg = 1;
  800a43:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a46:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	0f 94 c0             	sete   %al
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 19                	jne    800a70 <strtol+0x60>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 14                	jne    800a70 <strtol+0x60>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	0f 85 82 00 00 00    	jne    800ae8 <strtol+0xd8>
		s += 2, base = 16;
  800a66:	83 c1 02             	add    $0x2,%ecx
  800a69:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6e:	eb 16                	jmp    800a86 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a70:	84 c0                	test   %al,%al
  800a72:	74 12                	je     800a86 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a74:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a79:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7c:	75 08                	jne    800a86 <strtol+0x76>
		s++, base = 8;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8e:	0f b6 11             	movzbl (%ecx),%edx
  800a91:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a94:	89 f3                	mov    %esi,%ebx
  800a96:	80 fb 09             	cmp    $0x9,%bl
  800a99:	77 08                	ja     800aa3 <strtol+0x93>
			dig = *s - '0';
  800a9b:	0f be d2             	movsbl %dl,%edx
  800a9e:	83 ea 30             	sub    $0x30,%edx
  800aa1:	eb 22                	jmp    800ac5 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800aa3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 19             	cmp    $0x19,%bl
  800aab:	77 08                	ja     800ab5 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 57             	sub    $0x57,%edx
  800ab3:	eb 10                	jmp    800ac5 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ab5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 19             	cmp    $0x19,%bl
  800abd:	77 16                	ja     800ad5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac8:	7d 0f                	jge    800ad9 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad3:	eb b9                	jmp    800a8e <strtol+0x7e>
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	eb 02                	jmp    800adb <strtol+0xcb>
  800ad9:	89 c2                	mov    %eax,%edx

	if (endptr)
  800adb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adf:	74 0d                	je     800aee <strtol+0xde>
		*endptr = (char *) s;
  800ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae4:	89 0e                	mov    %ecx,(%esi)
  800ae6:	eb 06                	jmp    800aee <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	84 c0                	test   %al,%al
  800aea:	75 92                	jne    800a7e <strtol+0x6e>
  800aec:	eb 98                	jmp    800a86 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aee:	f7 da                	neg    %edx
  800af0:	85 ff                	test   %edi,%edi
  800af2:	0f 45 c2             	cmovne %edx,%eax
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	89 c6                	mov    %eax,%esi
  800b11:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 01 00 00 00       	mov    $0x1,%eax
  800b28:	89 d1                	mov    %edx,%ecx
  800b2a:	89 d3                	mov    %edx,%ebx
  800b2c:	89 d7                	mov    %edx,%edi
  800b2e:	89 d6                	mov    %edx,%esi
  800b30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b45:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 cb                	mov    %ecx,%ebx
  800b4f:	89 cf                	mov    %ecx,%edi
  800b51:	89 ce                	mov    %ecx,%esi
  800b53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 17                	jle    800b70 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 1f 2b 80 00       	push   $0x802b1f
  800b64:	6a 22                	push   $0x22
  800b66:	68 3c 2b 80 00       	push   $0x802b3c
  800b6b:	e8 dd f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 02 00 00 00       	mov    $0x2,%eax
  800b88:	89 d1                	mov    %edx,%ecx
  800b8a:	89 d3                	mov    %edx,%ebx
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_yield>:

void
sys_yield(void)
{      
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bbf:	be 00 00 00 00       	mov    $0x0,%esi
  800bc4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	89 f7                	mov    %esi,%edi
  800bd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 1f 2b 80 00       	push   $0x802b1f
  800be5:	6a 22                	push   $0x22
  800be7:	68 3c 2b 80 00       	push   $0x802b3c
  800bec:	e8 5c f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c13:	8b 75 18             	mov    0x18(%ebp),%esi
  800c16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 1f 2b 80 00       	push   $0x802b1f
  800c27:	6a 22                	push   $0x22
  800c29:	68 3c 2b 80 00       	push   $0x802b3c
  800c2e:	e8 1a f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 1f 2b 80 00       	push   $0x802b1f
  800c69:	6a 22                	push   $0x22
  800c6b:	68 3c 2b 80 00       	push   $0x802b3c
  800c70:	e8 d8 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 1f 2b 80 00       	push   $0x802b1f
  800cab:	6a 22                	push   $0x22
  800cad:	68 3c 2b 80 00       	push   $0x802b3c
  800cb2:	e8 96 f4 ff ff       	call   80014d <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 1f 2b 80 00       	push   $0x802b1f
  800ced:	6a 22                	push   $0x22
  800cef:	68 3c 2b 80 00       	push   $0x802b3c
  800cf4:	e8 54 f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 0a                	push   $0xa
  800d2a:	68 1f 2b 80 00       	push   $0x802b1f
  800d2f:	6a 22                	push   $0x22
  800d31:	68 3c 2b 80 00       	push   $0x802b3c
  800d36:	e8 12 f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d49:	be 00 00 00 00       	mov    $0x0,%esi
  800d4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d74:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 cb                	mov    %ecx,%ebx
  800d7e:	89 cf                	mov    %ecx,%edi
  800d80:	89 ce                	mov    %ecx,%esi
  800d82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0d                	push   $0xd
  800d8e:	68 1f 2b 80 00       	push   $0x802b1f
  800d93:	6a 22                	push   $0x22
  800d95:	68 3c 2b 80 00       	push   $0x802b3c
  800d9a:	e8 ae f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dad:	ba 00 00 00 00       	mov    $0x0,%edx
  800db2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db7:	89 d1                	mov    %edx,%ecx
  800db9:	89 d3                	mov    %edx,%ebx
  800dbb:	89 d7                	mov    %edx,%edi
  800dbd:	89 d6                	mov    %edx,%esi
  800dbf:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd4:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 cb                	mov    %ecx,%ebx
  800dde:	89 cf                	mov    %ecx,%edi
  800de0:	89 ce                	mov    %ecx,%esi
  800de2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7e 17                	jle    800dff <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	50                   	push   %eax
  800dec:	6a 0f                	push   $0xf
  800dee:	68 1f 2b 80 00       	push   $0x802b1f
  800df3:	6a 22                	push   $0x22
  800df5:	68 3c 2b 80 00       	push   $0x802b3c
  800dfa:	e8 4e f3 ff ff       	call   80014d <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_recv>:

int
sys_recv(void *addr)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e15:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	89 cb                	mov    %ecx,%ebx
  800e1f:	89 cf                	mov    %ecx,%edi
  800e21:	89 ce                	mov    %ecx,%esi
  800e23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e25:	85 c0                	test   %eax,%eax
  800e27:	7e 17                	jle    800e40 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	50                   	push   %eax
  800e2d:	6a 10                	push   $0x10
  800e2f:	68 1f 2b 80 00       	push   $0x802b1f
  800e34:	6a 22                	push   $0x22
  800e36:	68 3c 2b 80 00       	push   $0x802b3c
  800e3b:	e8 0d f3 ff ff       	call   80014d <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e52:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e54:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e58:	74 2e                	je     800e88 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	c1 ea 16             	shr    $0x16,%edx
  800e5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e66:	f6 c2 01             	test   $0x1,%dl
  800e69:	74 1d                	je     800e88 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	c1 ea 0c             	shr    $0xc,%edx
  800e70:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e77:	f6 c1 01             	test   $0x1,%cl
  800e7a:	74 0c                	je     800e88 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e83:	f6 c6 08             	test   $0x8,%dh
  800e86:	75 14                	jne    800e9c <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	68 4c 2b 80 00       	push   $0x802b4c
  800e90:	6a 21                	push   $0x21
  800e92:	68 df 2b 80 00       	push   $0x802bdf
  800e97:	e8 b1 f2 ff ff       	call   80014d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea1:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	6a 07                	push   $0x7
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 02 fd ff ff       	call   800bb6 <sys_page_alloc>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 14                	jns    800ecf <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	68 ea 2b 80 00       	push   $0x802bea
  800ec3:	6a 2b                	push   $0x2b
  800ec5:	68 df 2b 80 00       	push   $0x802bdf
  800eca:	e8 7e f2 ff ff       	call   80014d <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 00 10 00 00       	push   $0x1000
  800ed7:	53                   	push   %ebx
  800ed8:	68 00 f0 7f 00       	push   $0x7ff000
  800edd:	e8 5d fa ff ff       	call   80093f <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800ee2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee9:	53                   	push   %ebx
  800eea:	6a 00                	push   $0x0
  800eec:	68 00 f0 7f 00       	push   $0x7ff000
  800ef1:	6a 00                	push   $0x0
  800ef3:	e8 01 fd ff ff       	call   800bf9 <sys_page_map>
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 14                	jns    800f13 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	68 00 2c 80 00       	push   $0x802c00
  800f07:	6a 2e                	push   $0x2e
  800f09:	68 df 2b 80 00       	push   $0x802bdf
  800f0e:	e8 3a f2 ff ff       	call   80014d <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	68 00 f0 7f 00       	push   $0x7ff000
  800f1b:	6a 00                	push   $0x0
  800f1d:	e8 19 fd ff ff       	call   800c3b <sys_page_unmap>
  800f22:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f33:	68 48 0e 80 00       	push   $0x800e48
  800f38:	e8 92 13 00 00       	call   8022cf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f3d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f42:	cd 30                	int    $0x30
  800f44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 12                	jns    800f60 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f4e:	50                   	push   %eax
  800f4f:	68 14 2c 80 00       	push   $0x802c14
  800f54:	6a 6d                	push   $0x6d
  800f56:	68 df 2b 80 00       	push   $0x802bdf
  800f5b:	e8 ed f1 ff ff       	call   80014d <_panic>
  800f60:	89 c7                	mov    %eax,%edi
  800f62:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f67:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f6b:	75 21                	jne    800f8e <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f6d:	e8 06 fc ff ff       	call   800b78 <sys_getenvid>
  800f72:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f7f:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	e9 9c 01 00 00       	jmp    80112a <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f8e:	89 d8                	mov    %ebx,%eax
  800f90:	c1 e8 16             	shr    $0x16,%eax
  800f93:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9a:	a8 01                	test   $0x1,%al
  800f9c:	0f 84 f3 00 00 00    	je     801095 <fork+0x16b>
  800fa2:	89 d8                	mov    %ebx,%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fae:	f6 c2 01             	test   $0x1,%dl
  800fb1:	0f 84 de 00 00 00    	je     801095 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800fb7:	89 c6                	mov    %eax,%esi
  800fb9:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800fbc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc3:	f6 c6 04             	test   $0x4,%dh
  800fc6:	74 37                	je     800fff <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800fc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd7:	50                   	push   %eax
  800fd8:	56                   	push   %esi
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 17 fc ff ff       	call   800bf9 <sys_page_map>
  800fe2:	83 c4 20             	add    $0x20,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	0f 89 a8 00 00 00    	jns    801095 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  800fed:	50                   	push   %eax
  800fee:	68 70 2b 80 00       	push   $0x802b70
  800ff3:	6a 49                	push   $0x49
  800ff5:	68 df 2b 80 00       	push   $0x802bdf
  800ffa:	e8 4e f1 ff ff       	call   80014d <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800fff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801006:	f6 c6 08             	test   $0x8,%dh
  801009:	75 0b                	jne    801016 <fork+0xec>
  80100b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801012:	a8 02                	test   $0x2,%al
  801014:	74 57                	je     80106d <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 05 08 00 00       	push   $0x805
  80101e:	56                   	push   %esi
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	6a 00                	push   $0x0
  801023:	e8 d1 fb ff ff       	call   800bf9 <sys_page_map>
  801028:	83 c4 20             	add    $0x20,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	79 12                	jns    801041 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  80102f:	50                   	push   %eax
  801030:	68 70 2b 80 00       	push   $0x802b70
  801035:	6a 4c                	push   $0x4c
  801037:	68 df 2b 80 00       	push   $0x802bdf
  80103c:	e8 0c f1 ff ff       	call   80014d <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	68 05 08 00 00       	push   $0x805
  801049:	56                   	push   %esi
  80104a:	6a 00                	push   $0x0
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 a5 fb ff ff       	call   800bf9 <sys_page_map>
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 3a                	jns    801095 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  80105b:	50                   	push   %eax
  80105c:	68 94 2b 80 00       	push   $0x802b94
  801061:	6a 4e                	push   $0x4e
  801063:	68 df 2b 80 00       	push   $0x802bdf
  801068:	e8 e0 f0 ff ff       	call   80014d <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	6a 05                	push   $0x5
  801072:	56                   	push   %esi
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	6a 00                	push   $0x0
  801077:	e8 7d fb ff ff       	call   800bf9 <sys_page_map>
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 12                	jns    801095 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  801083:	50                   	push   %eax
  801084:	68 bc 2b 80 00       	push   $0x802bbc
  801089:	6a 50                	push   $0x50
  80108b:	68 df 2b 80 00       	push   $0x802bdf
  801090:	e8 b8 f0 ff ff       	call   80014d <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801095:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010a1:	0f 85 e7 fe ff ff    	jne    800f8e <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	6a 07                	push   $0x7
  8010ac:	68 00 f0 bf ee       	push   $0xeebff000
  8010b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b4:	e8 fd fa ff ff       	call   800bb6 <sys_page_alloc>
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	79 14                	jns    8010d4 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	68 24 2c 80 00       	push   $0x802c24
  8010c8:	6a 76                	push   $0x76
  8010ca:	68 df 2b 80 00       	push   $0x802bdf
  8010cf:	e8 79 f0 ff ff       	call   80014d <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	68 3e 23 80 00       	push   $0x80233e
  8010dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010df:	e8 1d fc ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 14                	jns    8010ff <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8010eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ee:	68 3e 2c 80 00       	push   $0x802c3e
  8010f3:	6a 79                	push   $0x79
  8010f5:	68 df 2b 80 00       	push   $0x802bdf
  8010fa:	e8 4e f0 ff ff       	call   80014d <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	6a 02                	push   $0x2
  801104:	ff 75 e4             	pushl  -0x1c(%ebp)
  801107:	e8 71 fb ff ff       	call   800c7d <sys_env_set_status>
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 14                	jns    801127 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801113:	ff 75 e4             	pushl  -0x1c(%ebp)
  801116:	68 5b 2c 80 00       	push   $0x802c5b
  80111b:	6a 7b                	push   $0x7b
  80111d:	68 df 2b 80 00       	push   $0x802bdf
  801122:	e8 26 f0 ff ff       	call   80014d <_panic>
        return forkid;
  801127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80112a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <sfork>:

// Challenge!
int
sfork(void)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801138:	68 72 2c 80 00       	push   $0x802c72
  80113d:	68 83 00 00 00       	push   $0x83
  801142:	68 df 2b 80 00       	push   $0x802bdf
  801147:	e8 01 f0 ff ff       	call   80014d <_panic>

0080114c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	05 00 00 00 30       	add    $0x30000000,%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801167:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801179:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117e:	89 c2                	mov    %eax,%edx
  801180:	c1 ea 16             	shr    $0x16,%edx
  801183:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	74 11                	je     8011a0 <fd_alloc+0x2d>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	c1 ea 0c             	shr    $0xc,%edx
  801194:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119b:	f6 c2 01             	test   $0x1,%dl
  80119e:	75 09                	jne    8011a9 <fd_alloc+0x36>
			*fd_store = fd;
  8011a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	eb 17                	jmp    8011c0 <fd_alloc+0x4d>
  8011a9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b3:	75 c9                	jne    80117e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c8:	83 f8 1f             	cmp    $0x1f,%eax
  8011cb:	77 36                	ja     801203 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011cd:	c1 e0 0c             	shl    $0xc,%eax
  8011d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	c1 ea 16             	shr    $0x16,%edx
  8011da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e1:	f6 c2 01             	test   $0x1,%dl
  8011e4:	74 24                	je     80120a <fd_lookup+0x48>
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	c1 ea 0c             	shr    $0xc,%edx
  8011eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f2:	f6 c2 01             	test   $0x1,%dl
  8011f5:	74 1a                	je     801211 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb 13                	jmp    801216 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb 0c                	jmp    801216 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120f:	eb 05                	jmp    801216 <fd_lookup+0x54>
  801211:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 08             	sub    $0x8,%esp
  80121e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801221:	ba 00 00 00 00       	mov    $0x0,%edx
  801226:	eb 13                	jmp    80123b <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801228:	39 08                	cmp    %ecx,(%eax)
  80122a:	75 0c                	jne    801238 <dev_lookup+0x20>
			*dev = devtab[i];
  80122c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 36                	jmp    80126e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801238:	83 c2 01             	add    $0x1,%edx
  80123b:	8b 04 95 04 2d 80 00 	mov    0x802d04(,%edx,4),%eax
  801242:	85 c0                	test   %eax,%eax
  801244:	75 e2                	jne    801228 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801246:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80124b:	8b 40 48             	mov    0x48(%eax),%eax
  80124e:	83 ec 04             	sub    $0x4,%esp
  801251:	51                   	push   %ecx
  801252:	50                   	push   %eax
  801253:	68 88 2c 80 00       	push   $0x802c88
  801258:	e8 c9 ef ff ff       	call   800226 <cprintf>
	*dev = 0;
  80125d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801260:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 10             	sub    $0x10,%esp
  801278:	8b 75 08             	mov    0x8(%ebp),%esi
  80127b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801281:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801282:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801288:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128b:	50                   	push   %eax
  80128c:	e8 31 ff ff ff       	call   8011c2 <fd_lookup>
  801291:	83 c4 08             	add    $0x8,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	78 05                	js     80129d <fd_close+0x2d>
	    || fd != fd2)
  801298:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129b:	74 0c                	je     8012a9 <fd_close+0x39>
		return (must_exist ? r : 0);
  80129d:	84 db                	test   %bl,%bl
  80129f:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a4:	0f 44 c2             	cmove  %edx,%eax
  8012a7:	eb 41                	jmp    8012ea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	ff 36                	pushl  (%esi)
  8012b2:	e8 61 ff ff ff       	call   801218 <dev_lookup>
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 1a                	js     8012da <fd_close+0x6a>
		if (dev->dev_close)
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	74 0b                	je     8012da <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	56                   	push   %esi
  8012d3:	ff d0                	call   *%eax
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	56                   	push   %esi
  8012de:	6a 00                	push   $0x0
  8012e0:	e8 56 f9 ff ff       	call   800c3b <sys_page_unmap>
	return r;
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	89 d8                	mov    %ebx,%eax
}
  8012ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	ff 75 08             	pushl  0x8(%ebp)
  8012fe:	e8 bf fe ff ff       	call   8011c2 <fd_lookup>
  801303:	89 c2                	mov    %eax,%edx
  801305:	83 c4 08             	add    $0x8,%esp
  801308:	85 d2                	test   %edx,%edx
  80130a:	78 10                	js     80131c <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	6a 01                	push   $0x1
  801311:	ff 75 f4             	pushl  -0xc(%ebp)
  801314:	e8 57 ff ff ff       	call   801270 <fd_close>
  801319:	83 c4 10             	add    $0x10,%esp
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <close_all>:

void
close_all(void)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	53                   	push   %ebx
  801322:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801325:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	53                   	push   %ebx
  80132e:	e8 be ff ff ff       	call   8012f1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801333:	83 c3 01             	add    $0x1,%ebx
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	83 fb 20             	cmp    $0x20,%ebx
  80133c:	75 ec                	jne    80132a <close_all+0xc>
		close(i);
}
  80133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	57                   	push   %edi
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
  801349:	83 ec 2c             	sub    $0x2c,%esp
  80134c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 67 fe ff ff       	call   8011c2 <fd_lookup>
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	85 d2                	test   %edx,%edx
  801362:	0f 88 c1 00 00 00    	js     801429 <dup+0xe6>
		return r;
	close(newfdnum);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	56                   	push   %esi
  80136c:	e8 80 ff ff ff       	call   8012f1 <close>

	newfd = INDEX2FD(newfdnum);
  801371:	89 f3                	mov    %esi,%ebx
  801373:	c1 e3 0c             	shl    $0xc,%ebx
  801376:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80137c:	83 c4 04             	add    $0x4,%esp
  80137f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801382:	e8 d5 fd ff ff       	call   80115c <fd2data>
  801387:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801389:	89 1c 24             	mov    %ebx,(%esp)
  80138c:	e8 cb fd ff ff       	call   80115c <fd2data>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801397:	89 f8                	mov    %edi,%eax
  801399:	c1 e8 16             	shr    $0x16,%eax
  80139c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a3:	a8 01                	test   $0x1,%al
  8013a5:	74 37                	je     8013de <dup+0x9b>
  8013a7:	89 f8                	mov    %edi,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	74 26                	je     8013de <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cb:	6a 00                	push   $0x0
  8013cd:	57                   	push   %edi
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 24 f8 ff ff       	call   800bf9 <sys_page_map>
  8013d5:	89 c7                	mov    %eax,%edi
  8013d7:	83 c4 20             	add    $0x20,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 2e                	js     80140c <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e1:	89 d0                	mov    %edx,%eax
  8013e3:	c1 e8 0c             	shr    $0xc,%eax
  8013e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f5:	50                   	push   %eax
  8013f6:	53                   	push   %ebx
  8013f7:	6a 00                	push   $0x0
  8013f9:	52                   	push   %edx
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 f8 f7 ff ff       	call   800bf9 <sys_page_map>
  801401:	89 c7                	mov    %eax,%edi
  801403:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801406:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801408:	85 ff                	test   %edi,%edi
  80140a:	79 1d                	jns    801429 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	6a 00                	push   $0x0
  801412:	e8 24 f8 ff ff       	call   800c3b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801417:	83 c4 08             	add    $0x8,%esp
  80141a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141d:	6a 00                	push   $0x0
  80141f:	e8 17 f8 ff ff       	call   800c3b <sys_page_unmap>
	return r;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	89 f8                	mov    %edi,%eax
}
  801429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5f                   	pop    %edi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 14             	sub    $0x14,%esp
  801438:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	53                   	push   %ebx
  801440:	e8 7d fd ff ff       	call   8011c2 <fd_lookup>
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	89 c2                	mov    %eax,%edx
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 6d                	js     8014bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801458:	ff 30                	pushl  (%eax)
  80145a:	e8 b9 fd ff ff       	call   801218 <dev_lookup>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 4c                	js     8014b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801466:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801469:	8b 42 08             	mov    0x8(%edx),%eax
  80146c:	83 e0 03             	and    $0x3,%eax
  80146f:	83 f8 01             	cmp    $0x1,%eax
  801472:	75 21                	jne    801495 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801474:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801479:	8b 40 48             	mov    0x48(%eax),%eax
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	53                   	push   %ebx
  801480:	50                   	push   %eax
  801481:	68 c9 2c 80 00       	push   $0x802cc9
  801486:	e8 9b ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801493:	eb 26                	jmp    8014bb <read+0x8a>
	}
	if (!dev->dev_read)
  801495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801498:	8b 40 08             	mov    0x8(%eax),%eax
  80149b:	85 c0                	test   %eax,%eax
  80149d:	74 17                	je     8014b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	ff 75 10             	pushl  0x10(%ebp)
  8014a5:	ff 75 0c             	pushl  0xc(%ebp)
  8014a8:	52                   	push   %edx
  8014a9:	ff d0                	call   *%eax
  8014ab:	89 c2                	mov    %eax,%edx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb 09                	jmp    8014bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	eb 05                	jmp    8014bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014bb:	89 d0                	mov    %edx,%eax
  8014bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	57                   	push   %edi
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d6:	eb 21                	jmp    8014f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	89 f0                	mov    %esi,%eax
  8014dd:	29 d8                	sub    %ebx,%eax
  8014df:	50                   	push   %eax
  8014e0:	89 d8                	mov    %ebx,%eax
  8014e2:	03 45 0c             	add    0xc(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	57                   	push   %edi
  8014e7:	e8 45 ff ff ff       	call   801431 <read>
		if (m < 0)
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 0c                	js     8014ff <readn+0x3d>
			return m;
		if (m == 0)
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	74 06                	je     8014fd <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f7:	01 c3                	add    %eax,%ebx
  8014f9:	39 f3                	cmp    %esi,%ebx
  8014fb:	72 db                	jb     8014d8 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014fd:	89 d8                	mov    %ebx,%eax
}
  8014ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5f                   	pop    %edi
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 14             	sub    $0x14,%esp
  80150e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801511:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	53                   	push   %ebx
  801516:	e8 a7 fc ff ff       	call   8011c2 <fd_lookup>
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	89 c2                	mov    %eax,%edx
  801520:	85 c0                	test   %eax,%eax
  801522:	78 68                	js     80158c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	ff 30                	pushl  (%eax)
  801530:	e8 e3 fc ff ff       	call   801218 <dev_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 47                	js     801583 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801543:	75 21                	jne    801566 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801545:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80154a:	8b 40 48             	mov    0x48(%eax),%eax
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	53                   	push   %ebx
  801551:	50                   	push   %eax
  801552:	68 e5 2c 80 00       	push   $0x802ce5
  801557:	e8 ca ec ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801564:	eb 26                	jmp    80158c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801566:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801569:	8b 52 0c             	mov    0xc(%edx),%edx
  80156c:	85 d2                	test   %edx,%edx
  80156e:	74 17                	je     801587 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	ff 75 10             	pushl  0x10(%ebp)
  801576:	ff 75 0c             	pushl  0xc(%ebp)
  801579:	50                   	push   %eax
  80157a:	ff d2                	call   *%edx
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 09                	jmp    80158c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	89 c2                	mov    %eax,%edx
  801585:	eb 05                	jmp    80158c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801587:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158c:	89 d0                	mov    %edx,%eax
  80158e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <seek>:

int
seek(int fdnum, off_t offset)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801599:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 1d fc ff ff       	call   8011c2 <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 0e                	js     8015ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 14             	sub    $0x14,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	e8 f2 fb ff ff       	call   8011c2 <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 65                	js     80163e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e3:	ff 30                	pushl  (%eax)
  8015e5:	e8 2e fc ff ff       	call   801218 <dev_lookup>
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 44                	js     801635 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f8:	75 21                	jne    80161b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fa:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ff:	8b 40 48             	mov    0x48(%eax),%eax
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	53                   	push   %ebx
  801606:	50                   	push   %eax
  801607:	68 a8 2c 80 00       	push   $0x802ca8
  80160c:	e8 15 ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801619:	eb 23                	jmp    80163e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161e:	8b 52 18             	mov    0x18(%edx),%edx
  801621:	85 d2                	test   %edx,%edx
  801623:	74 14                	je     801639 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	50                   	push   %eax
  80162c:	ff d2                	call   *%edx
  80162e:	89 c2                	mov    %eax,%edx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 09                	jmp    80163e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801635:	89 c2                	mov    %eax,%edx
  801637:	eb 05                	jmp    80163e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801639:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163e:	89 d0                	mov    %edx,%eax
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 14             	sub    $0x14,%esp
  80164c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	ff 75 08             	pushl  0x8(%ebp)
  801656:	e8 67 fb ff ff       	call   8011c2 <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	89 c2                	mov    %eax,%edx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 58                	js     8016bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	ff 30                	pushl  (%eax)
  801670:	e8 a3 fb ff ff       	call   801218 <dev_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 37                	js     8016b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801683:	74 32                	je     8016b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801685:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801688:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168f:	00 00 00 
	stat->st_isdir = 0;
  801692:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801699:	00 00 00 
	stat->st_dev = dev;
  80169c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	53                   	push   %ebx
  8016a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a9:	ff 50 14             	call   *0x14(%eax)
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	eb 09                	jmp    8016bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b3:	89 c2                	mov    %eax,%edx
  8016b5:	eb 05                	jmp    8016bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bc:	89 d0                	mov    %edx,%eax
  8016be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	6a 00                	push   $0x0
  8016cd:	ff 75 08             	pushl  0x8(%ebp)
  8016d0:	e8 09 02 00 00       	call   8018de <open>
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	85 db                	test   %ebx,%ebx
  8016dc:	78 1b                	js     8016f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	53                   	push   %ebx
  8016e5:	e8 5b ff ff ff       	call   801645 <fstat>
  8016ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ec:	89 1c 24             	mov    %ebx,(%esp)
  8016ef:	e8 fd fb ff ff       	call   8012f1 <close>
	return r;
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	89 f0                	mov    %esi,%eax
}
  8016f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5e                   	pop    %esi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	89 c6                	mov    %eax,%esi
  801707:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801709:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801710:	75 12                	jne    801724 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801712:	83 ec 0c             	sub    $0xc,%esp
  801715:	6a 01                	push   $0x1
  801717:	e8 03 0d 00 00       	call   80241f <ipc_find_env>
  80171c:	a3 00 40 80 00       	mov    %eax,0x804000
  801721:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801724:	6a 07                	push   $0x7
  801726:	68 00 50 80 00       	push   $0x805000
  80172b:	56                   	push   %esi
  80172c:	ff 35 00 40 80 00    	pushl  0x804000
  801732:	e8 94 0c 00 00       	call   8023cb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801737:	83 c4 0c             	add    $0xc,%esp
  80173a:	6a 00                	push   $0x0
  80173c:	53                   	push   %ebx
  80173d:	6a 00                	push   $0x0
  80173f:	e8 1e 0c 00 00       	call   802362 <ipc_recv>
}
  801744:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	8b 40 0c             	mov    0xc(%eax),%eax
  801757:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 02 00 00 00       	mov    $0x2,%eax
  80176e:	e8 8d ff ff ff       	call   801700 <fsipc>
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	8b 40 0c             	mov    0xc(%eax),%eax
  801781:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801786:	ba 00 00 00 00       	mov    $0x0,%edx
  80178b:	b8 06 00 00 00       	mov    $0x6,%eax
  801790:	e8 6b ff ff ff       	call   801700 <fsipc>
}
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	53                   	push   %ebx
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b6:	e8 45 ff ff ff       	call   801700 <fsipc>
  8017bb:	89 c2                	mov    %eax,%edx
  8017bd:	85 d2                	test   %edx,%edx
  8017bf:	78 2c                	js     8017ed <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c1:	83 ec 08             	sub    $0x8,%esp
  8017c4:	68 00 50 80 00       	push   $0x805000
  8017c9:	53                   	push   %ebx
  8017ca:	e8 de ef ff ff       	call   8007ad <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017da:	a1 84 50 80 00       	mov    0x805084,%eax
  8017df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	57                   	push   %edi
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80180c:	eb 3d                	jmp    80184b <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80180e:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801814:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801819:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	57                   	push   %edi
  801820:	53                   	push   %ebx
  801821:	68 08 50 80 00       	push   $0x805008
  801826:	e8 14 f1 ff ff       	call   80093f <memmove>
                fsipcbuf.write.req_n = tmp; 
  80182b:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801831:	ba 00 00 00 00       	mov    $0x0,%edx
  801836:	b8 04 00 00 00       	mov    $0x4,%eax
  80183b:	e8 c0 fe ff ff       	call   801700 <fsipc>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 0d                	js     801854 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801847:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801849:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80184b:	85 f6                	test   %esi,%esi
  80184d:	75 bf                	jne    80180e <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80184f:	89 d8                	mov    %ebx,%eax
  801851:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801854:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5f                   	pop    %edi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	8b 40 0c             	mov    0xc(%eax),%eax
  80186a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80186f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 03 00 00 00       	mov    $0x3,%eax
  80187f:	e8 7c fe ff ff       	call   801700 <fsipc>
  801884:	89 c3                	mov    %eax,%ebx
  801886:	85 c0                	test   %eax,%eax
  801888:	78 4b                	js     8018d5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188a:	39 c6                	cmp    %eax,%esi
  80188c:	73 16                	jae    8018a4 <devfile_read+0x48>
  80188e:	68 18 2d 80 00       	push   $0x802d18
  801893:	68 1f 2d 80 00       	push   $0x802d1f
  801898:	6a 7c                	push   $0x7c
  80189a:	68 34 2d 80 00       	push   $0x802d34
  80189f:	e8 a9 e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8018a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a9:	7e 16                	jle    8018c1 <devfile_read+0x65>
  8018ab:	68 3f 2d 80 00       	push   $0x802d3f
  8018b0:	68 1f 2d 80 00       	push   $0x802d1f
  8018b5:	6a 7d                	push   $0x7d
  8018b7:	68 34 2d 80 00       	push   $0x802d34
  8018bc:	e8 8c e8 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	50                   	push   %eax
  8018c5:	68 00 50 80 00       	push   $0x805000
  8018ca:	ff 75 0c             	pushl  0xc(%ebp)
  8018cd:	e8 6d f0 ff ff       	call   80093f <memmove>
	return r;
  8018d2:	83 c4 10             	add    $0x10,%esp
}
  8018d5:	89 d8                	mov    %ebx,%eax
  8018d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 20             	sub    $0x20,%esp
  8018e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e8:	53                   	push   %ebx
  8018e9:	e8 86 ee ff ff       	call   800774 <strlen>
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f6:	7f 67                	jg     80195f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fe:	50                   	push   %eax
  8018ff:	e8 6f f8 ff ff       	call   801173 <fd_alloc>
  801904:	83 c4 10             	add    $0x10,%esp
		return r;
  801907:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 57                	js     801964 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	53                   	push   %ebx
  801911:	68 00 50 80 00       	push   $0x805000
  801916:	e8 92 ee ff ff       	call   8007ad <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801923:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801926:	b8 01 00 00 00       	mov    $0x1,%eax
  80192b:	e8 d0 fd ff ff       	call   801700 <fsipc>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	79 14                	jns    80194d <open+0x6f>
		fd_close(fd, 0);
  801939:	83 ec 08             	sub    $0x8,%esp
  80193c:	6a 00                	push   $0x0
  80193e:	ff 75 f4             	pushl  -0xc(%ebp)
  801941:	e8 2a f9 ff ff       	call   801270 <fd_close>
		return r;
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	89 da                	mov    %ebx,%edx
  80194b:	eb 17                	jmp    801964 <open+0x86>
	}

	return fd2num(fd);
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff 75 f4             	pushl  -0xc(%ebp)
  801953:	e8 f4 f7 ff ff       	call   80114c <fd2num>
  801958:	89 c2                	mov    %eax,%edx
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	eb 05                	jmp    801964 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80195f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801964:	89 d0                	mov    %edx,%eax
  801966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801971:	ba 00 00 00 00       	mov    $0x0,%edx
  801976:	b8 08 00 00 00       	mov    $0x8,%eax
  80197b:	e8 80 fd ff ff       	call   801700 <fsipc>
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801988:	68 4b 2d 80 00       	push   $0x802d4b
  80198d:	ff 75 0c             	pushl  0xc(%ebp)
  801990:	e8 18 ee ff ff       	call   8007ad <strcpy>
	return 0;
}
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 10             	sub    $0x10,%esp
  8019a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019a6:	53                   	push   %ebx
  8019a7:	e8 ab 0a 00 00       	call   802457 <pageref>
  8019ac:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019b4:	83 f8 01             	cmp    $0x1,%eax
  8019b7:	75 10                	jne    8019c9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	ff 73 0c             	pushl  0xc(%ebx)
  8019bf:	e8 ca 02 00 00       	call   801c8e <nsipc_close>
  8019c4:	89 c2                	mov    %eax,%edx
  8019c6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019c9:	89 d0                	mov    %edx,%eax
  8019cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019d6:	6a 00                	push   $0x0
  8019d8:	ff 75 10             	pushl  0x10(%ebp)
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	ff 70 0c             	pushl  0xc(%eax)
  8019e4:	e8 82 03 00 00       	call   801d6b <nsipc_send>
}
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019f1:	6a 00                	push   $0x0
  8019f3:	ff 75 10             	pushl  0x10(%ebp)
  8019f6:	ff 75 0c             	pushl  0xc(%ebp)
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	ff 70 0c             	pushl  0xc(%eax)
  8019ff:	e8 fb 02 00 00       	call   801cff <nsipc_recv>
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a0c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a0f:	52                   	push   %edx
  801a10:	50                   	push   %eax
  801a11:	e8 ac f7 ff ff       	call   8011c2 <fd_lookup>
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 17                	js     801a34 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a26:	39 08                	cmp    %ecx,(%eax)
  801a28:	75 05                	jne    801a2f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2d:	eb 05                	jmp    801a34 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a2f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 1c             	sub    $0x1c,%esp
  801a3e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	e8 2a f7 ff ff       	call   801173 <fd_alloc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	78 1b                	js     801a6d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a52:	83 ec 04             	sub    $0x4,%esp
  801a55:	68 07 04 00 00       	push   $0x407
  801a5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5d:	6a 00                	push   $0x0
  801a5f:	e8 52 f1 ff ff       	call   800bb6 <sys_page_alloc>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	79 10                	jns    801a7d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	56                   	push   %esi
  801a71:	e8 18 02 00 00       	call   801c8e <nsipc_close>
		return r;
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	89 d8                	mov    %ebx,%eax
  801a7b:	eb 24                	jmp    801aa1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a86:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a8b:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801a92:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	52                   	push   %edx
  801a99:	e8 ae f6 ff ff       	call   80114c <fd2num>
  801a9e:	83 c4 10             	add    $0x10,%esp
}
  801aa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	e8 50 ff ff ff       	call   801a06 <fd2sockid>
		return r;
  801ab6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	78 1f                	js     801adb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	ff 75 10             	pushl  0x10(%ebp)
  801ac2:	ff 75 0c             	pushl  0xc(%ebp)
  801ac5:	50                   	push   %eax
  801ac6:	e8 1c 01 00 00       	call   801be7 <nsipc_accept>
  801acb:	83 c4 10             	add    $0x10,%esp
		return r;
  801ace:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 07                	js     801adb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ad4:	e8 5d ff ff ff       	call   801a36 <alloc_sockfd>
  801ad9:	89 c1                	mov    %eax,%ecx
}
  801adb:	89 c8                	mov    %ecx,%eax
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	e8 19 ff ff ff       	call   801a06 <fd2sockid>
  801aed:	89 c2                	mov    %eax,%edx
  801aef:	85 d2                	test   %edx,%edx
  801af1:	78 12                	js     801b05 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	ff 75 10             	pushl  0x10(%ebp)
  801af9:	ff 75 0c             	pushl  0xc(%ebp)
  801afc:	52                   	push   %edx
  801afd:	e8 35 01 00 00       	call   801c37 <nsipc_bind>
  801b02:	83 c4 10             	add    $0x10,%esp
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <shutdown>:

int
shutdown(int s, int how)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b10:	e8 f1 fe ff ff       	call   801a06 <fd2sockid>
  801b15:	89 c2                	mov    %eax,%edx
  801b17:	85 d2                	test   %edx,%edx
  801b19:	78 0f                	js     801b2a <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	ff 75 0c             	pushl  0xc(%ebp)
  801b21:	52                   	push   %edx
  801b22:	e8 45 01 00 00       	call   801c6c <nsipc_shutdown>
  801b27:	83 c4 10             	add    $0x10,%esp
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
  801b35:	e8 cc fe ff ff       	call   801a06 <fd2sockid>
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	85 d2                	test   %edx,%edx
  801b3e:	78 12                	js     801b52 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	ff 75 10             	pushl  0x10(%ebp)
  801b46:	ff 75 0c             	pushl  0xc(%ebp)
  801b49:	52                   	push   %edx
  801b4a:	e8 59 01 00 00       	call   801ca8 <nsipc_connect>
  801b4f:	83 c4 10             	add    $0x10,%esp
}
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <listen>:

int
listen(int s, int backlog)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	e8 a4 fe ff ff       	call   801a06 <fd2sockid>
  801b62:	89 c2                	mov    %eax,%edx
  801b64:	85 d2                	test   %edx,%edx
  801b66:	78 0f                	js     801b77 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801b68:	83 ec 08             	sub    $0x8,%esp
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	52                   	push   %edx
  801b6f:	e8 69 01 00 00       	call   801cdd <nsipc_listen>
  801b74:	83 c4 10             	add    $0x10,%esp
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b7f:	ff 75 10             	pushl  0x10(%ebp)
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	ff 75 08             	pushl  0x8(%ebp)
  801b88:	e8 3c 02 00 00       	call   801dc9 <nsipc_socket>
  801b8d:	89 c2                	mov    %eax,%edx
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 d2                	test   %edx,%edx
  801b94:	78 05                	js     801b9b <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801b96:	e8 9b fe ff ff       	call   801a36 <alloc_sockfd>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bad:	75 12                	jne    801bc1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	6a 02                	push   $0x2
  801bb4:	e8 66 08 00 00       	call   80241f <ipc_find_env>
  801bb9:	a3 04 40 80 00       	mov    %eax,0x804004
  801bbe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc1:	6a 07                	push   $0x7
  801bc3:	68 00 60 80 00       	push   $0x806000
  801bc8:	53                   	push   %ebx
  801bc9:	ff 35 04 40 80 00    	pushl  0x804004
  801bcf:	e8 f7 07 00 00       	call   8023cb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd4:	83 c4 0c             	add    $0xc,%esp
  801bd7:	6a 00                	push   $0x0
  801bd9:	6a 00                	push   $0x0
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 80 07 00 00       	call   802362 <ipc_recv>
}
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf7:	8b 06                	mov    (%esi),%eax
  801bf9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801c03:	e8 95 ff ff ff       	call   801b9d <nsipc>
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	78 20                	js     801c2e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c0e:	83 ec 04             	sub    $0x4,%esp
  801c11:	ff 35 10 60 80 00    	pushl  0x806010
  801c17:	68 00 60 80 00       	push   $0x806000
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	e8 1b ed ff ff       	call   80093f <memmove>
		*addrlen = ret->ret_addrlen;
  801c24:	a1 10 60 80 00       	mov    0x806010,%eax
  801c29:	89 06                	mov    %eax,(%esi)
  801c2b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c2e:	89 d8                	mov    %ebx,%eax
  801c30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 08             	sub    $0x8,%esp
  801c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c49:	53                   	push   %ebx
  801c4a:	ff 75 0c             	pushl  0xc(%ebp)
  801c4d:	68 04 60 80 00       	push   $0x806004
  801c52:	e8 e8 ec ff ff       	call   80093f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c57:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c5d:	b8 02 00 00 00       	mov    $0x2,%eax
  801c62:	e8 36 ff ff ff       	call   801b9d <nsipc>
}
  801c67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c82:	b8 03 00 00 00       	mov    $0x3,%eax
  801c87:	e8 11 ff ff ff       	call   801b9d <nsipc>
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <nsipc_close>:

int
nsipc_close(int s)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c9c:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca1:	e8 f7 fe ff ff       	call   801b9d <nsipc>
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	53                   	push   %ebx
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cba:	53                   	push   %ebx
  801cbb:	ff 75 0c             	pushl  0xc(%ebp)
  801cbe:	68 04 60 80 00       	push   $0x806004
  801cc3:	e8 77 ec ff ff       	call   80093f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cce:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd3:	e8 c5 fe ff ff       	call   801b9d <nsipc>
}
  801cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cee:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cf3:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf8:	e8 a0 fe ff ff       	call   801b9d <nsipc>
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d0f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d15:	8b 45 14             	mov    0x14(%ebp),%eax
  801d18:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d1d:	b8 07 00 00 00       	mov    $0x7,%eax
  801d22:	e8 76 fe ff ff       	call   801b9d <nsipc>
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 35                	js     801d62 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d2d:	39 f0                	cmp    %esi,%eax
  801d2f:	7f 07                	jg     801d38 <nsipc_recv+0x39>
  801d31:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d36:	7e 16                	jle    801d4e <nsipc_recv+0x4f>
  801d38:	68 57 2d 80 00       	push   $0x802d57
  801d3d:	68 1f 2d 80 00       	push   $0x802d1f
  801d42:	6a 62                	push   $0x62
  801d44:	68 6c 2d 80 00       	push   $0x802d6c
  801d49:	e8 ff e3 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	50                   	push   %eax
  801d52:	68 00 60 80 00       	push   $0x806000
  801d57:	ff 75 0c             	pushl  0xc(%ebp)
  801d5a:	e8 e0 eb ff ff       	call   80093f <memmove>
  801d5f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d62:	89 d8                	mov    %ebx,%eax
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d75:	8b 45 08             	mov    0x8(%ebp),%eax
  801d78:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d7d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d83:	7e 16                	jle    801d9b <nsipc_send+0x30>
  801d85:	68 78 2d 80 00       	push   $0x802d78
  801d8a:	68 1f 2d 80 00       	push   $0x802d1f
  801d8f:	6a 6d                	push   $0x6d
  801d91:	68 6c 2d 80 00       	push   $0x802d6c
  801d96:	e8 b2 e3 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	53                   	push   %ebx
  801d9f:	ff 75 0c             	pushl  0xc(%ebp)
  801da2:	68 0c 60 80 00       	push   $0x80600c
  801da7:	e8 93 eb ff ff       	call   80093f <memmove>
	nsipcbuf.send.req_size = size;
  801dac:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801db2:	8b 45 14             	mov    0x14(%ebp),%eax
  801db5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dba:	b8 08 00 00 00       	mov    $0x8,%eax
  801dbf:	e8 d9 fd ff ff       	call   801b9d <nsipc>
}
  801dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dda:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ddf:	8b 45 10             	mov    0x10(%ebp),%eax
  801de2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de7:	b8 09 00 00 00       	mov    $0x9,%eax
  801dec:	e8 ac fd ff ff       	call   801b9d <nsipc>
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	ff 75 08             	pushl  0x8(%ebp)
  801e01:	e8 56 f3 ff ff       	call   80115c <fd2data>
  801e06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e08:	83 c4 08             	add    $0x8,%esp
  801e0b:	68 84 2d 80 00       	push   $0x802d84
  801e10:	53                   	push   %ebx
  801e11:	e8 97 e9 ff ff       	call   8007ad <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e16:	8b 56 04             	mov    0x4(%esi),%edx
  801e19:	89 d0                	mov    %edx,%eax
  801e1b:	2b 06                	sub    (%esi),%eax
  801e1d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e23:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e2a:	00 00 00 
	stat->st_dev = &devpipe;
  801e2d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e34:	30 80 00 
	return 0;
}
  801e37:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    

00801e43 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	53                   	push   %ebx
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4d:	53                   	push   %ebx
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 e6 ed ff ff       	call   800c3b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e55:	89 1c 24             	mov    %ebx,(%esp)
  801e58:	e8 ff f2 ff ff       	call   80115c <fd2data>
  801e5d:	83 c4 08             	add    $0x8,%esp
  801e60:	50                   	push   %eax
  801e61:	6a 00                	push   $0x0
  801e63:	e8 d3 ed ff ff       	call   800c3b <sys_page_unmap>
}
  801e68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	57                   	push   %edi
  801e71:	56                   	push   %esi
  801e72:	53                   	push   %ebx
  801e73:	83 ec 1c             	sub    $0x1c,%esp
  801e76:	89 c6                	mov    %eax,%esi
  801e78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e7b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801e80:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e83:	83 ec 0c             	sub    $0xc,%esp
  801e86:	56                   	push   %esi
  801e87:	e8 cb 05 00 00       	call   802457 <pageref>
  801e8c:	89 c7                	mov    %eax,%edi
  801e8e:	83 c4 04             	add    $0x4,%esp
  801e91:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e94:	e8 be 05 00 00       	call   802457 <pageref>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	39 c7                	cmp    %eax,%edi
  801e9e:	0f 94 c2             	sete   %dl
  801ea1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801ea4:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801eaa:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ead:	39 fb                	cmp    %edi,%ebx
  801eaf:	74 19                	je     801eca <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801eb1:	84 d2                	test   %dl,%dl
  801eb3:	74 c6                	je     801e7b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb5:	8b 51 58             	mov    0x58(%ecx),%edx
  801eb8:	50                   	push   %eax
  801eb9:	52                   	push   %edx
  801eba:	53                   	push   %ebx
  801ebb:	68 8b 2d 80 00       	push   $0x802d8b
  801ec0:	e8 61 e3 ff ff       	call   800226 <cprintf>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	eb b1                	jmp    801e7b <_pipeisclosed+0xe>
	}
}
  801eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 28             	sub    $0x28,%esp
  801edb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ede:	56                   	push   %esi
  801edf:	e8 78 f2 ff ff       	call   80115c <fd2data>
  801ee4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	bf 00 00 00 00       	mov    $0x0,%edi
  801eee:	eb 4b                	jmp    801f3b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef0:	89 da                	mov    %ebx,%edx
  801ef2:	89 f0                	mov    %esi,%eax
  801ef4:	e8 74 ff ff ff       	call   801e6d <_pipeisclosed>
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	75 48                	jne    801f45 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801efd:	e8 95 ec ff ff       	call   800b97 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f02:	8b 43 04             	mov    0x4(%ebx),%eax
  801f05:	8b 0b                	mov    (%ebx),%ecx
  801f07:	8d 51 20             	lea    0x20(%ecx),%edx
  801f0a:	39 d0                	cmp    %edx,%eax
  801f0c:	73 e2                	jae    801ef0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	c1 fa 1f             	sar    $0x1f,%edx
  801f1d:	89 d1                	mov    %edx,%ecx
  801f1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f25:	83 e2 1f             	and    $0x1f,%edx
  801f28:	29 ca                	sub    %ecx,%edx
  801f2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f32:	83 c0 01             	add    $0x1,%eax
  801f35:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f38:	83 c7 01             	add    $0x1,%edi
  801f3b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f3e:	75 c2                	jne    801f02 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f40:	8b 45 10             	mov    0x10(%ebp),%eax
  801f43:	eb 05                	jmp    801f4a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	83 ec 18             	sub    $0x18,%esp
  801f5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f5e:	57                   	push   %edi
  801f5f:	e8 f8 f1 ff ff       	call   80115c <fd2data>
  801f64:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f6e:	eb 3d                	jmp    801fad <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f70:	85 db                	test   %ebx,%ebx
  801f72:	74 04                	je     801f78 <devpipe_read+0x26>
				return i;
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	eb 44                	jmp    801fbc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f78:	89 f2                	mov    %esi,%edx
  801f7a:	89 f8                	mov    %edi,%eax
  801f7c:	e8 ec fe ff ff       	call   801e6d <_pipeisclosed>
  801f81:	85 c0                	test   %eax,%eax
  801f83:	75 32                	jne    801fb7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f85:	e8 0d ec ff ff       	call   800b97 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f8a:	8b 06                	mov    (%esi),%eax
  801f8c:	3b 46 04             	cmp    0x4(%esi),%eax
  801f8f:	74 df                	je     801f70 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f91:	99                   	cltd   
  801f92:	c1 ea 1b             	shr    $0x1b,%edx
  801f95:	01 d0                	add    %edx,%eax
  801f97:	83 e0 1f             	and    $0x1f,%eax
  801f9a:	29 d0                	sub    %edx,%eax
  801f9c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fa7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801faa:	83 c3 01             	add    $0x1,%ebx
  801fad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb0:	75 d8                	jne    801f8a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb5:	eb 05                	jmp    801fbc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5f                   	pop    %edi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	e8 9e f1 ff ff       	call   801173 <fd_alloc>
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	89 c2                	mov    %eax,%edx
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	0f 88 2c 01 00 00    	js     80210e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	68 07 04 00 00       	push   $0x407
  801fea:	ff 75 f4             	pushl  -0xc(%ebp)
  801fed:	6a 00                	push   $0x0
  801fef:	e8 c2 eb ff ff       	call   800bb6 <sys_page_alloc>
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	89 c2                	mov    %eax,%edx
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	0f 88 0d 01 00 00    	js     80210e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802007:	50                   	push   %eax
  802008:	e8 66 f1 ff ff       	call   801173 <fd_alloc>
  80200d:	89 c3                	mov    %eax,%ebx
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	85 c0                	test   %eax,%eax
  802014:	0f 88 e2 00 00 00    	js     8020fc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201a:	83 ec 04             	sub    $0x4,%esp
  80201d:	68 07 04 00 00       	push   $0x407
  802022:	ff 75 f0             	pushl  -0x10(%ebp)
  802025:	6a 00                	push   $0x0
  802027:	e8 8a eb ff ff       	call   800bb6 <sys_page_alloc>
  80202c:	89 c3                	mov    %eax,%ebx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	0f 88 c3 00 00 00    	js     8020fc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	ff 75 f4             	pushl  -0xc(%ebp)
  80203f:	e8 18 f1 ff ff       	call   80115c <fd2data>
  802044:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802046:	83 c4 0c             	add    $0xc,%esp
  802049:	68 07 04 00 00       	push   $0x407
  80204e:	50                   	push   %eax
  80204f:	6a 00                	push   $0x0
  802051:	e8 60 eb ff ff       	call   800bb6 <sys_page_alloc>
  802056:	89 c3                	mov    %eax,%ebx
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	0f 88 89 00 00 00    	js     8020ec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802063:	83 ec 0c             	sub    $0xc,%esp
  802066:	ff 75 f0             	pushl  -0x10(%ebp)
  802069:	e8 ee f0 ff ff       	call   80115c <fd2data>
  80206e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802075:	50                   	push   %eax
  802076:	6a 00                	push   $0x0
  802078:	56                   	push   %esi
  802079:	6a 00                	push   $0x0
  80207b:	e8 79 eb ff ff       	call   800bf9 <sys_page_map>
  802080:	89 c3                	mov    %eax,%ebx
  802082:	83 c4 20             	add    $0x20,%esp
  802085:	85 c0                	test   %eax,%eax
  802087:	78 55                	js     8020de <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802089:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802092:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802097:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80209e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b3:	83 ec 0c             	sub    $0xc,%esp
  8020b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b9:	e8 8e f0 ff ff       	call   80114c <fd2num>
  8020be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c3:	83 c4 04             	add    $0x4,%esp
  8020c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c9:	e8 7e f0 ff ff       	call   80114c <fd2num>
  8020ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8020dc:	eb 30                	jmp    80210e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020de:	83 ec 08             	sub    $0x8,%esp
  8020e1:	56                   	push   %esi
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 52 eb ff ff       	call   800c3b <sys_page_unmap>
  8020e9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 42 eb ff ff       	call   800c3b <sys_page_unmap>
  8020f9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020fc:	83 ec 08             	sub    $0x8,%esp
  8020ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802102:	6a 00                	push   $0x0
  802104:	e8 32 eb ff ff       	call   800c3b <sys_page_unmap>
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80210e:	89 d0                	mov    %edx,%eax
  802110:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    

00802117 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802120:	50                   	push   %eax
  802121:	ff 75 08             	pushl  0x8(%ebp)
  802124:	e8 99 f0 ff ff       	call   8011c2 <fd_lookup>
  802129:	89 c2                	mov    %eax,%edx
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	85 d2                	test   %edx,%edx
  802130:	78 18                	js     80214a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802132:	83 ec 0c             	sub    $0xc,%esp
  802135:	ff 75 f4             	pushl  -0xc(%ebp)
  802138:	e8 1f f0 ff ff       	call   80115c <fd2data>
	return _pipeisclosed(fd, p);
  80213d:	89 c2                	mov    %eax,%edx
  80213f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802142:	e8 26 fd ff ff       	call   801e6d <_pipeisclosed>
  802147:	83 c4 10             	add    $0x10,%esp
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80214f:	b8 00 00 00 00       	mov    $0x0,%eax
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    

00802156 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80215c:	68 a3 2d 80 00       	push   $0x802da3
  802161:	ff 75 0c             	pushl  0xc(%ebp)
  802164:	e8 44 e6 ff ff       	call   8007ad <strcpy>
	return 0;
}
  802169:	b8 00 00 00 00       	mov    $0x0,%eax
  80216e:	c9                   	leave  
  80216f:	c3                   	ret    

00802170 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	53                   	push   %ebx
  802176:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80217c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802181:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802187:	eb 2d                	jmp    8021b6 <devcons_write+0x46>
		m = n - tot;
  802189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80218e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802191:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802196:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802199:	83 ec 04             	sub    $0x4,%esp
  80219c:	53                   	push   %ebx
  80219d:	03 45 0c             	add    0xc(%ebp),%eax
  8021a0:	50                   	push   %eax
  8021a1:	57                   	push   %edi
  8021a2:	e8 98 e7 ff ff       	call   80093f <memmove>
		sys_cputs(buf, m);
  8021a7:	83 c4 08             	add    $0x8,%esp
  8021aa:	53                   	push   %ebx
  8021ab:	57                   	push   %edi
  8021ac:	e8 49 e9 ff ff       	call   800afa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b1:	01 de                	add    %ebx,%esi
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	89 f0                	mov    %esi,%eax
  8021b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021bb:	72 cc                	jb     802189 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    

008021c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021cb:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d4:	75 07                	jne    8021dd <devcons_read+0x18>
  8021d6:	eb 28                	jmp    802200 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d8:	e8 ba e9 ff ff       	call   800b97 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021dd:	e8 36 e9 ff ff       	call   800b18 <sys_cgetc>
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	74 f2                	je     8021d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	78 16                	js     802200 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ea:	83 f8 04             	cmp    $0x4,%eax
  8021ed:	74 0c                	je     8021fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f2:	88 02                	mov    %al,(%edx)
	return 1;
  8021f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f9:	eb 05                	jmp    802200 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80220e:	6a 01                	push   $0x1
  802210:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802213:	50                   	push   %eax
  802214:	e8 e1 e8 ff ff       	call   800afa <sys_cputs>
  802219:	83 c4 10             	add    $0x10,%esp
}
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <getchar>:

int
getchar(void)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802224:	6a 01                	push   $0x1
  802226:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802229:	50                   	push   %eax
  80222a:	6a 00                	push   $0x0
  80222c:	e8 00 f2 ff ff       	call   801431 <read>
	if (r < 0)
  802231:	83 c4 10             	add    $0x10,%esp
  802234:	85 c0                	test   %eax,%eax
  802236:	78 0f                	js     802247 <getchar+0x29>
		return r;
	if (r < 1)
  802238:	85 c0                	test   %eax,%eax
  80223a:	7e 06                	jle    802242 <getchar+0x24>
		return -E_EOF;
	return c;
  80223c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802240:	eb 05                	jmp    802247 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802242:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802247:	c9                   	leave  
  802248:	c3                   	ret    

00802249 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802252:	50                   	push   %eax
  802253:	ff 75 08             	pushl  0x8(%ebp)
  802256:	e8 67 ef ff ff       	call   8011c2 <fd_lookup>
  80225b:	83 c4 10             	add    $0x10,%esp
  80225e:	85 c0                	test   %eax,%eax
  802260:	78 11                	js     802273 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802265:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80226b:	39 10                	cmp    %edx,(%eax)
  80226d:	0f 94 c0             	sete   %al
  802270:	0f b6 c0             	movzbl %al,%eax
}
  802273:	c9                   	leave  
  802274:	c3                   	ret    

00802275 <opencons>:

int
opencons(void)
{
  802275:	55                   	push   %ebp
  802276:	89 e5                	mov    %esp,%ebp
  802278:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80227b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227e:	50                   	push   %eax
  80227f:	e8 ef ee ff ff       	call   801173 <fd_alloc>
  802284:	83 c4 10             	add    $0x10,%esp
		return r;
  802287:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802289:	85 c0                	test   %eax,%eax
  80228b:	78 3e                	js     8022cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228d:	83 ec 04             	sub    $0x4,%esp
  802290:	68 07 04 00 00       	push   $0x407
  802295:	ff 75 f4             	pushl  -0xc(%ebp)
  802298:	6a 00                	push   $0x0
  80229a:	e8 17 e9 ff ff       	call   800bb6 <sys_page_alloc>
  80229f:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	78 23                	js     8022cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022a8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022bd:	83 ec 0c             	sub    $0xc,%esp
  8022c0:	50                   	push   %eax
  8022c1:	e8 86 ee ff ff       	call   80114c <fd2num>
  8022c6:	89 c2                	mov    %eax,%edx
  8022c8:	83 c4 10             	add    $0x10,%esp
}
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	c9                   	leave  
  8022ce:	c3                   	ret    

008022cf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
  8022d2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022d5:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022dc:	75 2c                	jne    80230a <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8022de:	83 ec 04             	sub    $0x4,%esp
  8022e1:	6a 07                	push   $0x7
  8022e3:	68 00 f0 bf ee       	push   $0xeebff000
  8022e8:	6a 00                	push   $0x0
  8022ea:	e8 c7 e8 ff ff       	call   800bb6 <sys_page_alloc>
  8022ef:	83 c4 10             	add    $0x10,%esp
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	74 14                	je     80230a <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8022f6:	83 ec 04             	sub    $0x4,%esp
  8022f9:	68 b0 2d 80 00       	push   $0x802db0
  8022fe:	6a 21                	push   $0x21
  802300:	68 14 2e 80 00       	push   $0x802e14
  802305:	e8 43 de ff ff       	call   80014d <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80230a:	8b 45 08             	mov    0x8(%ebp),%eax
  80230d:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802312:	83 ec 08             	sub    $0x8,%esp
  802315:	68 3e 23 80 00       	push   $0x80233e
  80231a:	6a 00                	push   $0x0
  80231c:	e8 e0 e9 ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  802321:	83 c4 10             	add    $0x10,%esp
  802324:	85 c0                	test   %eax,%eax
  802326:	79 14                	jns    80233c <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802328:	83 ec 04             	sub    $0x4,%esp
  80232b:	68 dc 2d 80 00       	push   $0x802ddc
  802330:	6a 29                	push   $0x29
  802332:	68 14 2e 80 00       	push   $0x802e14
  802337:	e8 11 de ff ff       	call   80014d <_panic>
}
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    

0080233e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80233e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80233f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802344:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802346:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802349:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80234e:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802352:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802356:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802358:	83 c4 08             	add    $0x8,%esp
        popal
  80235b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80235c:	83 c4 04             	add    $0x4,%esp
        popfl
  80235f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802360:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802361:	c3                   	ret    

00802362 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	56                   	push   %esi
  802366:	53                   	push   %ebx
  802367:	8b 75 08             	mov    0x8(%ebp),%esi
  80236a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802370:	85 c0                	test   %eax,%eax
  802372:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802377:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80237a:	83 ec 0c             	sub    $0xc,%esp
  80237d:	50                   	push   %eax
  80237e:	e8 e3 e9 ff ff       	call   800d66 <sys_ipc_recv>
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	85 c0                	test   %eax,%eax
  802388:	79 16                	jns    8023a0 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80238a:	85 f6                	test   %esi,%esi
  80238c:	74 06                	je     802394 <ipc_recv+0x32>
  80238e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802394:	85 db                	test   %ebx,%ebx
  802396:	74 2c                	je     8023c4 <ipc_recv+0x62>
  802398:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80239e:	eb 24                	jmp    8023c4 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8023a0:	85 f6                	test   %esi,%esi
  8023a2:	74 0a                	je     8023ae <ipc_recv+0x4c>
  8023a4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023a9:	8b 40 74             	mov    0x74(%eax),%eax
  8023ac:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8023ae:	85 db                	test   %ebx,%ebx
  8023b0:	74 0a                	je     8023bc <ipc_recv+0x5a>
  8023b2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023b7:	8b 40 78             	mov    0x78(%eax),%eax
  8023ba:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8023bc:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023c1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    

008023cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	57                   	push   %edi
  8023cf:	56                   	push   %esi
  8023d0:	53                   	push   %ebx
  8023d1:	83 ec 0c             	sub    $0xc,%esp
  8023d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8023dd:	85 db                	test   %ebx,%ebx
  8023df:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023e4:	0f 44 d8             	cmove  %eax,%ebx
  8023e7:	eb 1c                	jmp    802405 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8023e9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023ec:	74 12                	je     802400 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8023ee:	50                   	push   %eax
  8023ef:	68 22 2e 80 00       	push   $0x802e22
  8023f4:	6a 39                	push   $0x39
  8023f6:	68 3d 2e 80 00       	push   $0x802e3d
  8023fb:	e8 4d dd ff ff       	call   80014d <_panic>
                 sys_yield();
  802400:	e8 92 e7 ff ff       	call   800b97 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802405:	ff 75 14             	pushl  0x14(%ebp)
  802408:	53                   	push   %ebx
  802409:	56                   	push   %esi
  80240a:	57                   	push   %edi
  80240b:	e8 33 e9 ff ff       	call   800d43 <sys_ipc_try_send>
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	85 c0                	test   %eax,%eax
  802415:	78 d2                	js     8023e9 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802417:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80241a:	5b                   	pop    %ebx
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    

0080241f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802425:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80242a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80242d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802433:	8b 52 50             	mov    0x50(%edx),%edx
  802436:	39 ca                	cmp    %ecx,%edx
  802438:	75 0d                	jne    802447 <ipc_find_env+0x28>
			return envs[i].env_id;
  80243a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80243d:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802442:	8b 40 08             	mov    0x8(%eax),%eax
  802445:	eb 0e                	jmp    802455 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802447:	83 c0 01             	add    $0x1,%eax
  80244a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80244f:	75 d9                	jne    80242a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802451:	66 b8 00 00          	mov    $0x0,%ax
}
  802455:	5d                   	pop    %ebp
  802456:	c3                   	ret    

00802457 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802457:	55                   	push   %ebp
  802458:	89 e5                	mov    %esp,%ebp
  80245a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80245d:	89 d0                	mov    %edx,%eax
  80245f:	c1 e8 16             	shr    $0x16,%eax
  802462:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802469:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246e:	f6 c1 01             	test   $0x1,%cl
  802471:	74 1d                	je     802490 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802473:	c1 ea 0c             	shr    $0xc,%edx
  802476:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80247d:	f6 c2 01             	test   $0x1,%dl
  802480:	74 0e                	je     802490 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802482:	c1 ea 0c             	shr    $0xc,%edx
  802485:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80248c:	ef 
  80248d:	0f b7 c0             	movzwl %ax,%eax
}
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    
  802492:	66 90                	xchg   %ax,%ax
  802494:	66 90                	xchg   %ax,%ax
  802496:	66 90                	xchg   %ax,%ax
  802498:	66 90                	xchg   %ax,%ax
  80249a:	66 90                	xchg   %ax,%ax
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

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
