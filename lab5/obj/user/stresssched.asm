
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
  800044:	e8 40 0e 00 00       	call   800e89 <fork>
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
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 40 22 80 00       	push   $0x802240
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 68 22 80 00       	push   $0x802268
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 7b 22 80 00       	push   $0x80227b
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
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800139:	e8 3a 11 00 00       	call   801278 <close_all>
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
  80016b:	68 a4 22 80 00       	push   $0x8022a4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 97 22 80 00 	movl   $0x802297,(%esp)
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
  800289:	e8 f2 1c 00 00       	call   801f80 <__udivdi3>
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
  8002c7:	e8 e4 1d 00 00       	call   8020b0 <__umoddi3>
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	0f be 80 c7 22 80 00 	movsbl 0x8022c7(%eax),%eax
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
  8003cb:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
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
  80048f:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	75 18                	jne    8004b2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049a:	50                   	push   %eax
  80049b:	68 df 22 80 00       	push   $0x8022df
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
  8004b3:	68 ed 27 80 00       	push   $0x8027ed
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
  8004e0:	ba d8 22 80 00       	mov    $0x8022d8,%edx
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
  800b5f:	68 df 25 80 00       	push   $0x8025df
  800b64:	6a 23                	push   $0x23
  800b66:	68 fc 25 80 00       	push   $0x8025fc
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
  800be0:	68 df 25 80 00       	push   $0x8025df
  800be5:	6a 23                	push   $0x23
  800be7:	68 fc 25 80 00       	push   $0x8025fc
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
  800c22:	68 df 25 80 00       	push   $0x8025df
  800c27:	6a 23                	push   $0x23
  800c29:	68 fc 25 80 00       	push   $0x8025fc
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
  800c64:	68 df 25 80 00       	push   $0x8025df
  800c69:	6a 23                	push   $0x23
  800c6b:	68 fc 25 80 00       	push   $0x8025fc
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
  800ca6:	68 df 25 80 00       	push   $0x8025df
  800cab:	6a 23                	push   $0x23
  800cad:	68 fc 25 80 00       	push   $0x8025fc
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
  800ce8:	68 df 25 80 00       	push   $0x8025df
  800ced:	6a 23                	push   $0x23
  800cef:	68 fc 25 80 00       	push   $0x8025fc
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
  800d2a:	68 df 25 80 00       	push   $0x8025df
  800d2f:	6a 23                	push   $0x23
  800d31:	68 fc 25 80 00       	push   $0x8025fc
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
  800d8e:	68 df 25 80 00       	push   $0x8025df
  800d93:	6a 23                	push   $0x23
  800d95:	68 fc 25 80 00       	push   $0x8025fc
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

00800da7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	53                   	push   %ebx
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800db1:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800db3:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800db7:	74 2e                	je     800de7 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	c1 ea 16             	shr    $0x16,%edx
  800dbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc5:	f6 c2 01             	test   $0x1,%dl
  800dc8:	74 1d                	je     800de7 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dca:	89 c2                	mov    %eax,%edx
  800dcc:	c1 ea 0c             	shr    $0xc,%edx
  800dcf:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800dd6:	f6 c1 01             	test   $0x1,%cl
  800dd9:	74 0c                	je     800de7 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ddb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800de2:	f6 c6 08             	test   $0x8,%dh
  800de5:	75 14                	jne    800dfb <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	68 0c 26 80 00       	push   $0x80260c
  800def:	6a 21                	push   $0x21
  800df1:	68 9f 26 80 00       	push   $0x80269f
  800df6:	e8 52 f3 ff ff       	call   80014d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800dfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e00:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	6a 07                	push   $0x7
  800e07:	68 00 f0 7f 00       	push   $0x7ff000
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 a3 fd ff ff       	call   800bb6 <sys_page_alloc>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	79 14                	jns    800e2e <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	68 aa 26 80 00       	push   $0x8026aa
  800e22:	6a 2b                	push   $0x2b
  800e24:	68 9f 26 80 00       	push   $0x80269f
  800e29:	e8 1f f3 ff ff       	call   80014d <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 00 10 00 00       	push   $0x1000
  800e36:	53                   	push   %ebx
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	e8 fe fa ff ff       	call   80093f <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e41:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e48:	53                   	push   %ebx
  800e49:	6a 00                	push   $0x0
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	6a 00                	push   $0x0
  800e52:	e8 a2 fd ff ff       	call   800bf9 <sys_page_map>
  800e57:	83 c4 20             	add    $0x20,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	79 14                	jns    800e72 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e5e:	83 ec 04             	sub    $0x4,%esp
  800e61:	68 c0 26 80 00       	push   $0x8026c0
  800e66:	6a 2e                	push   $0x2e
  800e68:	68 9f 26 80 00       	push   $0x80269f
  800e6d:	e8 db f2 ff ff       	call   80014d <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	68 00 f0 7f 00       	push   $0x7ff000
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 ba fd ff ff       	call   800c3b <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e92:	68 a7 0d 80 00       	push   $0x800da7
  800e97:	e8 1c 0f 00 00       	call   801db8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e9c:	b8 07 00 00 00       	mov    $0x7,%eax
  800ea1:	cd 30                	int    $0x30
  800ea3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 12                	jns    800ebf <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800ead:	50                   	push   %eax
  800eae:	68 d4 26 80 00       	push   $0x8026d4
  800eb3:	6a 6d                	push   $0x6d
  800eb5:	68 9f 26 80 00       	push   $0x80269f
  800eba:	e8 8e f2 ff ff       	call   80014d <_panic>
  800ebf:	89 c7                	mov    %eax,%edi
  800ec1:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800ec6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eca:	75 21                	jne    800eed <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800ecc:	e8 a7 fc ff ff       	call   800b78 <sys_getenvid>
  800ed1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ede:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	e9 9c 01 00 00       	jmp    801089 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800eed:	89 d8                	mov    %ebx,%eax
  800eef:	c1 e8 16             	shr    $0x16,%eax
  800ef2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef9:	a8 01                	test   $0x1,%al
  800efb:	0f 84 f3 00 00 00    	je     800ff4 <fork+0x16b>
  800f01:	89 d8                	mov    %ebx,%eax
  800f03:	c1 e8 0c             	shr    $0xc,%eax
  800f06:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0d:	f6 c2 01             	test   $0x1,%dl
  800f10:	0f 84 de 00 00 00    	je     800ff4 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f16:	89 c6                	mov    %eax,%esi
  800f18:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f1b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f22:	f6 c6 04             	test   $0x4,%dh
  800f25:	74 37                	je     800f5e <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f27:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	25 07 0e 00 00       	and    $0xe07,%eax
  800f36:	50                   	push   %eax
  800f37:	56                   	push   %esi
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 b8 fc ff ff       	call   800bf9 <sys_page_map>
  800f41:	83 c4 20             	add    $0x20,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	0f 89 a8 00 00 00    	jns    800ff4 <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800f4c:	50                   	push   %eax
  800f4d:	68 30 26 80 00       	push   $0x802630
  800f52:	6a 49                	push   $0x49
  800f54:	68 9f 26 80 00       	push   $0x80269f
  800f59:	e8 ef f1 ff ff       	call   80014d <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f65:	f6 c6 08             	test   $0x8,%dh
  800f68:	75 0b                	jne    800f75 <fork+0xec>
  800f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f71:	a8 02                	test   $0x2,%al
  800f73:	74 57                	je     800fcc <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	68 05 08 00 00       	push   $0x805
  800f7d:	56                   	push   %esi
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	6a 00                	push   $0x0
  800f82:	e8 72 fc ff ff       	call   800bf9 <sys_page_map>
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	79 12                	jns    800fa0 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800f8e:	50                   	push   %eax
  800f8f:	68 30 26 80 00       	push   $0x802630
  800f94:	6a 4c                	push   $0x4c
  800f96:	68 9f 26 80 00       	push   $0x80269f
  800f9b:	e8 ad f1 ff ff       	call   80014d <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	68 05 08 00 00       	push   $0x805
  800fa8:	56                   	push   %esi
  800fa9:	6a 00                	push   $0x0
  800fab:	56                   	push   %esi
  800fac:	6a 00                	push   $0x0
  800fae:	e8 46 fc ff ff       	call   800bf9 <sys_page_map>
  800fb3:	83 c4 20             	add    $0x20,%esp
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	79 3a                	jns    800ff4 <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  800fba:	50                   	push   %eax
  800fbb:	68 54 26 80 00       	push   $0x802654
  800fc0:	6a 4e                	push   $0x4e
  800fc2:	68 9f 26 80 00       	push   $0x80269f
  800fc7:	e8 81 f1 ff ff       	call   80014d <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	6a 05                	push   $0x5
  800fd1:	56                   	push   %esi
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 1e fc ff ff       	call   800bf9 <sys_page_map>
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 12                	jns    800ff4 <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  800fe2:	50                   	push   %eax
  800fe3:	68 7c 26 80 00       	push   $0x80267c
  800fe8:	6a 50                	push   $0x50
  800fea:	68 9f 26 80 00       	push   $0x80269f
  800fef:	e8 59 f1 ff ff       	call   80014d <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800ff4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffa:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801000:	0f 85 e7 fe ff ff    	jne    800eed <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	6a 07                	push   $0x7
  80100b:	68 00 f0 bf ee       	push   $0xeebff000
  801010:	ff 75 e4             	pushl  -0x1c(%ebp)
  801013:	e8 9e fb ff ff       	call   800bb6 <sys_page_alloc>
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	79 14                	jns    801033 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 e4 26 80 00       	push   $0x8026e4
  801027:	6a 76                	push   $0x76
  801029:	68 9f 26 80 00       	push   $0x80269f
  80102e:	e8 1a f1 ff ff       	call   80014d <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	68 27 1e 80 00       	push   $0x801e27
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	e8 be fc ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 14                	jns    80105e <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  80104a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104d:	68 fe 26 80 00       	push   $0x8026fe
  801052:	6a 79                	push   $0x79
  801054:	68 9f 26 80 00       	push   $0x80269f
  801059:	e8 ef f0 ff ff       	call   80014d <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	6a 02                	push   $0x2
  801063:	ff 75 e4             	pushl  -0x1c(%ebp)
  801066:	e8 12 fc ff ff       	call   800c7d <sys_env_set_status>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 14                	jns    801086 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801072:	ff 75 e4             	pushl  -0x1c(%ebp)
  801075:	68 1b 27 80 00       	push   $0x80271b
  80107a:	6a 7b                	push   $0x7b
  80107c:	68 9f 26 80 00       	push   $0x80269f
  801081:	e8 c7 f0 ff ff       	call   80014d <_panic>
        return forkid;
  801086:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sfork>:

// Challenge!
int
sfork(void)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801097:	68 32 27 80 00       	push   $0x802732
  80109c:	68 83 00 00 00       	push   $0x83
  8010a1:	68 9f 26 80 00       	push   $0x80269f
  8010a6:	e8 a2 f0 ff ff       	call   80014d <_panic>

008010ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8010c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	c1 ea 16             	shr    $0x16,%edx
  8010e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e9:	f6 c2 01             	test   $0x1,%dl
  8010ec:	74 11                	je     8010ff <fd_alloc+0x2d>
  8010ee:	89 c2                	mov    %eax,%edx
  8010f0:	c1 ea 0c             	shr    $0xc,%edx
  8010f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fa:	f6 c2 01             	test   $0x1,%dl
  8010fd:	75 09                	jne    801108 <fd_alloc+0x36>
			*fd_store = fd;
  8010ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
  801106:	eb 17                	jmp    80111f <fd_alloc+0x4d>
  801108:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80110d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801112:	75 c9                	jne    8010dd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801114:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80111a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801127:	83 f8 1f             	cmp    $0x1f,%eax
  80112a:	77 36                	ja     801162 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80112c:	c1 e0 0c             	shl    $0xc,%eax
  80112f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801134:	89 c2                	mov    %eax,%edx
  801136:	c1 ea 16             	shr    $0x16,%edx
  801139:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	74 24                	je     801169 <fd_lookup+0x48>
  801145:	89 c2                	mov    %eax,%edx
  801147:	c1 ea 0c             	shr    $0xc,%edx
  80114a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801151:	f6 c2 01             	test   $0x1,%dl
  801154:	74 1a                	je     801170 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801156:	8b 55 0c             	mov    0xc(%ebp),%edx
  801159:	89 02                	mov    %eax,(%edx)
	return 0;
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
  801160:	eb 13                	jmp    801175 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801167:	eb 0c                	jmp    801175 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116e:	eb 05                	jmp    801175 <fd_lookup+0x54>
  801170:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801180:	ba c4 27 80 00       	mov    $0x8027c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801185:	eb 13                	jmp    80119a <dev_lookup+0x23>
  801187:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80118a:	39 08                	cmp    %ecx,(%eax)
  80118c:	75 0c                	jne    80119a <dev_lookup+0x23>
			*dev = devtab[i];
  80118e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801191:	89 01                	mov    %eax,(%ecx)
			return 0;
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
  801198:	eb 2e                	jmp    8011c8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80119a:	8b 02                	mov    (%edx),%eax
  80119c:	85 c0                	test   %eax,%eax
  80119e:	75 e7                	jne    801187 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	51                   	push   %ecx
  8011ac:	50                   	push   %eax
  8011ad:	68 48 27 80 00       	push   $0x802748
  8011b2:	e8 6f f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	56                   	push   %esi
  8011ce:	53                   	push   %ebx
  8011cf:	83 ec 10             	sub    $0x10,%esp
  8011d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011dc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e2:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e5:	50                   	push   %eax
  8011e6:	e8 36 ff ff ff       	call   801121 <fd_lookup>
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 05                	js     8011f7 <fd_close+0x2d>
	    || fd != fd2)
  8011f2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011f5:	74 0c                	je     801203 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011f7:	84 db                	test   %bl,%bl
  8011f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fe:	0f 44 c2             	cmove  %edx,%eax
  801201:	eb 41                	jmp    801244 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	ff 36                	pushl  (%esi)
  80120c:	e8 66 ff ff ff       	call   801177 <dev_lookup>
  801211:	89 c3                	mov    %eax,%ebx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 1a                	js     801234 <fd_close+0x6a>
		if (dev->dev_close)
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801225:	85 c0                	test   %eax,%eax
  801227:	74 0b                	je     801234 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	56                   	push   %esi
  80122d:	ff d0                	call   *%eax
  80122f:	89 c3                	mov    %eax,%ebx
  801231:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801234:	83 ec 08             	sub    $0x8,%esp
  801237:	56                   	push   %esi
  801238:	6a 00                	push   $0x0
  80123a:	e8 fc f9 ff ff       	call   800c3b <sys_page_unmap>
	return r;
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	89 d8                	mov    %ebx,%eax
}
  801244:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801251:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801254:	50                   	push   %eax
  801255:	ff 75 08             	pushl  0x8(%ebp)
  801258:	e8 c4 fe ff ff       	call   801121 <fd_lookup>
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	83 c4 08             	add    $0x8,%esp
  801262:	85 d2                	test   %edx,%edx
  801264:	78 10                	js     801276 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	6a 01                	push   $0x1
  80126b:	ff 75 f4             	pushl  -0xc(%ebp)
  80126e:	e8 57 ff ff ff       	call   8011ca <fd_close>
  801273:	83 c4 10             	add    $0x10,%esp
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <close_all>:

void
close_all(void)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80127f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	53                   	push   %ebx
  801288:	e8 be ff ff ff       	call   80124b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80128d:	83 c3 01             	add    $0x1,%ebx
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	83 fb 20             	cmp    $0x20,%ebx
  801296:	75 ec                	jne    801284 <close_all+0xc>
		close(i);
}
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 2c             	sub    $0x2c,%esp
  8012a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 08             	pushl  0x8(%ebp)
  8012b0:	e8 6c fe ff ff       	call   801121 <fd_lookup>
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	0f 88 c1 00 00 00    	js     801383 <dup+0xe6>
		return r;
	close(newfdnum);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	56                   	push   %esi
  8012c6:	e8 80 ff ff ff       	call   80124b <close>

	newfd = INDEX2FD(newfdnum);
  8012cb:	89 f3                	mov    %esi,%ebx
  8012cd:	c1 e3 0c             	shl    $0xc,%ebx
  8012d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d6:	83 c4 04             	add    $0x4,%esp
  8012d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012dc:	e8 da fd ff ff       	call   8010bb <fd2data>
  8012e1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e3:	89 1c 24             	mov    %ebx,(%esp)
  8012e6:	e8 d0 fd ff ff       	call   8010bb <fd2data>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f1:	89 f8                	mov    %edi,%eax
  8012f3:	c1 e8 16             	shr    $0x16,%eax
  8012f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fd:	a8 01                	test   $0x1,%al
  8012ff:	74 37                	je     801338 <dup+0x9b>
  801301:	89 f8                	mov    %edi,%eax
  801303:	c1 e8 0c             	shr    $0xc,%eax
  801306:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130d:	f6 c2 01             	test   $0x1,%dl
  801310:	74 26                	je     801338 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801312:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	25 07 0e 00 00       	and    $0xe07,%eax
  801321:	50                   	push   %eax
  801322:	ff 75 d4             	pushl  -0x2c(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	57                   	push   %edi
  801328:	6a 00                	push   $0x0
  80132a:	e8 ca f8 ff ff       	call   800bf9 <sys_page_map>
  80132f:	89 c7                	mov    %eax,%edi
  801331:	83 c4 20             	add    $0x20,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 2e                	js     801366 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
  801340:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	25 07 0e 00 00       	and    $0xe07,%eax
  80134f:	50                   	push   %eax
  801350:	53                   	push   %ebx
  801351:	6a 00                	push   $0x0
  801353:	52                   	push   %edx
  801354:	6a 00                	push   $0x0
  801356:	e8 9e f8 ff ff       	call   800bf9 <sys_page_map>
  80135b:	89 c7                	mov    %eax,%edi
  80135d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801360:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	85 ff                	test   %edi,%edi
  801364:	79 1d                	jns    801383 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	53                   	push   %ebx
  80136a:	6a 00                	push   $0x0
  80136c:	e8 ca f8 ff ff       	call   800c3b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801371:	83 c4 08             	add    $0x8,%esp
  801374:	ff 75 d4             	pushl  -0x2c(%ebp)
  801377:	6a 00                	push   $0x0
  801379:	e8 bd f8 ff ff       	call   800c3b <sys_page_unmap>
	return r;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 f8                	mov    %edi,%eax
}
  801383:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	83 ec 14             	sub    $0x14,%esp
  801392:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	53                   	push   %ebx
  80139a:	e8 82 fd ff ff       	call   801121 <fd_lookup>
  80139f:	83 c4 08             	add    $0x8,%esp
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 6d                	js     801415 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	ff 30                	pushl  (%eax)
  8013b4:	e8 be fd ff ff       	call   801177 <dev_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 4c                	js     80140c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c3:	8b 42 08             	mov    0x8(%edx),%eax
  8013c6:	83 e0 03             	and    $0x3,%eax
  8013c9:	83 f8 01             	cmp    $0x1,%eax
  8013cc:	75 21                	jne    8013ef <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ce:	a1 08 40 80 00       	mov    0x804008,%eax
  8013d3:	8b 40 48             	mov    0x48(%eax),%eax
  8013d6:	83 ec 04             	sub    $0x4,%esp
  8013d9:	53                   	push   %ebx
  8013da:	50                   	push   %eax
  8013db:	68 89 27 80 00       	push   $0x802789
  8013e0:	e8 41 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ed:	eb 26                	jmp    801415 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f2:	8b 40 08             	mov    0x8(%eax),%eax
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	74 17                	je     801410 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	ff 75 10             	pushl  0x10(%ebp)
  8013ff:	ff 75 0c             	pushl  0xc(%ebp)
  801402:	52                   	push   %edx
  801403:	ff d0                	call   *%eax
  801405:	89 c2                	mov    %eax,%edx
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	eb 09                	jmp    801415 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140c:	89 c2                	mov    %eax,%edx
  80140e:	eb 05                	jmp    801415 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801410:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801415:	89 d0                	mov    %edx,%eax
  801417:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	57                   	push   %edi
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	83 ec 0c             	sub    $0xc,%esp
  801425:	8b 7d 08             	mov    0x8(%ebp),%edi
  801428:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801430:	eb 21                	jmp    801453 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	89 f0                	mov    %esi,%eax
  801437:	29 d8                	sub    %ebx,%eax
  801439:	50                   	push   %eax
  80143a:	89 d8                	mov    %ebx,%eax
  80143c:	03 45 0c             	add    0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	57                   	push   %edi
  801441:	e8 45 ff ff ff       	call   80138b <read>
		if (m < 0)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 0c                	js     801459 <readn+0x3d>
			return m;
		if (m == 0)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	74 06                	je     801457 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801451:	01 c3                	add    %eax,%ebx
  801453:	39 f3                	cmp    %esi,%ebx
  801455:	72 db                	jb     801432 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801457:	89 d8                	mov    %ebx,%eax
}
  801459:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	5f                   	pop    %edi
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    

00801461 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	53                   	push   %ebx
  801465:	83 ec 14             	sub    $0x14,%esp
  801468:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	53                   	push   %ebx
  801470:	e8 ac fc ff ff       	call   801121 <fd_lookup>
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	89 c2                	mov    %eax,%edx
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 68                	js     8014e6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801488:	ff 30                	pushl  (%eax)
  80148a:	e8 e8 fc ff ff       	call   801177 <dev_lookup>
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 47                	js     8014dd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801499:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80149d:	75 21                	jne    8014c0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80149f:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a4:	8b 40 48             	mov    0x48(%eax),%eax
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	50                   	push   %eax
  8014ac:	68 a5 27 80 00       	push   $0x8027a5
  8014b1:	e8 70 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014be:	eb 26                	jmp    8014e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	74 17                	je     8014e1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ca:	83 ec 04             	sub    $0x4,%esp
  8014cd:	ff 75 10             	pushl  0x10(%ebp)
  8014d0:	ff 75 0c             	pushl  0xc(%ebp)
  8014d3:	50                   	push   %eax
  8014d4:	ff d2                	call   *%edx
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb 09                	jmp    8014e6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	eb 05                	jmp    8014e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	ff 75 08             	pushl  0x8(%ebp)
  8014fa:	e8 22 fc ff ff       	call   801121 <fd_lookup>
  8014ff:	83 c4 08             	add    $0x8,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 0e                	js     801514 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801506:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801509:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80150f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801520:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	53                   	push   %ebx
  801525:	e8 f7 fb ff ff       	call   801121 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 65                	js     801598 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	ff 30                	pushl  (%eax)
  80153f:	e8 33 fc ff ff       	call   801177 <dev_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 44                	js     80158f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801552:	75 21                	jne    801575 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801554:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801559:	8b 40 48             	mov    0x48(%eax),%eax
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	53                   	push   %ebx
  801560:	50                   	push   %eax
  801561:	68 68 27 80 00       	push   $0x802768
  801566:	e8 bb ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801573:	eb 23                	jmp    801598 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801575:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801578:	8b 52 18             	mov    0x18(%edx),%edx
  80157b:	85 d2                	test   %edx,%edx
  80157d:	74 14                	je     801593 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	50                   	push   %eax
  801586:	ff d2                	call   *%edx
  801588:	89 c2                	mov    %eax,%edx
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	eb 09                	jmp    801598 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	89 c2                	mov    %eax,%edx
  801591:	eb 05                	jmp    801598 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801593:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801598:	89 d0                	mov    %edx,%eax
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 14             	sub    $0x14,%esp
  8015a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	ff 75 08             	pushl  0x8(%ebp)
  8015b0:	e8 6c fb ff ff       	call   801121 <fd_lookup>
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 58                	js     801616 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	ff 30                	pushl  (%eax)
  8015ca:	e8 a8 fb ff ff       	call   801177 <dev_lookup>
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 37                	js     80160d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015dd:	74 32                	je     801611 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015df:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e9:	00 00 00 
	stat->st_isdir = 0;
  8015ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f3:	00 00 00 
	stat->st_dev = dev;
  8015f6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	53                   	push   %ebx
  801600:	ff 75 f0             	pushl  -0x10(%ebp)
  801603:	ff 50 14             	call   *0x14(%eax)
  801606:	89 c2                	mov    %eax,%edx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 09                	jmp    801616 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	eb 05                	jmp    801616 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801611:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	6a 00                	push   $0x0
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 09 02 00 00       	call   801838 <open>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 db                	test   %ebx,%ebx
  801636:	78 1b                	js     801653 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	ff 75 0c             	pushl  0xc(%ebp)
  80163e:	53                   	push   %ebx
  80163f:	e8 5b ff ff ff       	call   80159f <fstat>
  801644:	89 c6                	mov    %eax,%esi
	close(fd);
  801646:	89 1c 24             	mov    %ebx,(%esp)
  801649:	e8 fd fb ff ff       	call   80124b <close>
	return r;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	89 f0                	mov    %esi,%eax
}
  801653:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	89 c6                	mov    %eax,%esi
  801661:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801663:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80166a:	75 12                	jne    80167e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80166c:	83 ec 0c             	sub    $0xc,%esp
  80166f:	6a 01                	push   $0x1
  801671:	e8 92 08 00 00       	call   801f08 <ipc_find_env>
  801676:	a3 00 40 80 00       	mov    %eax,0x804000
  80167b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80167e:	6a 07                	push   $0x7
  801680:	68 00 50 80 00       	push   $0x805000
  801685:	56                   	push   %esi
  801686:	ff 35 00 40 80 00    	pushl  0x804000
  80168c:	e8 23 08 00 00       	call   801eb4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801691:	83 c4 0c             	add    $0xc,%esp
  801694:	6a 00                	push   $0x0
  801696:	53                   	push   %ebx
  801697:	6a 00                	push   $0x0
  801699:	e8 ad 07 00 00       	call   801e4b <ipc_recv>
}
  80169e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c8:	e8 8d ff ff ff       	call   80165a <fsipc>
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016db:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ea:	e8 6b ff ff ff       	call   80165a <fsipc>
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 04             	sub    $0x4,%esp
  8016f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	b8 05 00 00 00       	mov    $0x5,%eax
  801710:	e8 45 ff ff ff       	call   80165a <fsipc>
  801715:	89 c2                	mov    %eax,%edx
  801717:	85 d2                	test   %edx,%edx
  801719:	78 2c                	js     801747 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	68 00 50 80 00       	push   $0x805000
  801723:	53                   	push   %ebx
  801724:	e8 84 f0 ff ff       	call   8007ad <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801729:	a1 80 50 80 00       	mov    0x805080,%eax
  80172e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801734:	a1 84 50 80 00       	mov    0x805084,%eax
  801739:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 40 0c             	mov    0xc(%eax),%eax
  80175e:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801766:	eb 3d                	jmp    8017a5 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801768:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80176e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801773:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	57                   	push   %edi
  80177a:	53                   	push   %ebx
  80177b:	68 08 50 80 00       	push   $0x805008
  801780:	e8 ba f1 ff ff       	call   80093f <memmove>
                fsipcbuf.write.req_n = tmp; 
  801785:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	b8 04 00 00 00       	mov    $0x4,%eax
  801795:	e8 c0 fe ff ff       	call   80165a <fsipc>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 0d                	js     8017ae <devfile_write+0x62>
		        return r;
                n -= tmp;
  8017a1:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8017a3:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017a5:	85 f6                	test   %esi,%esi
  8017a7:	75 bf                	jne    801768 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8017a9:	89 d8                	mov    %ebx,%eax
  8017ab:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8017ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5f                   	pop    %edi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017c9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d9:	e8 7c fe ff ff       	call   80165a <fsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	78 4b                	js     80182f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e4:	39 c6                	cmp    %eax,%esi
  8017e6:	73 16                	jae    8017fe <devfile_read+0x48>
  8017e8:	68 d4 27 80 00       	push   $0x8027d4
  8017ed:	68 db 27 80 00       	push   $0x8027db
  8017f2:	6a 7c                	push   $0x7c
  8017f4:	68 f0 27 80 00       	push   $0x8027f0
  8017f9:	e8 4f e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8017fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801803:	7e 16                	jle    80181b <devfile_read+0x65>
  801805:	68 fb 27 80 00       	push   $0x8027fb
  80180a:	68 db 27 80 00       	push   $0x8027db
  80180f:	6a 7d                	push   $0x7d
  801811:	68 f0 27 80 00       	push   $0x8027f0
  801816:	e8 32 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	50                   	push   %eax
  80181f:	68 00 50 80 00       	push   $0x805000
  801824:	ff 75 0c             	pushl  0xc(%ebp)
  801827:	e8 13 f1 ff ff       	call   80093f <memmove>
	return r;
  80182c:	83 c4 10             	add    $0x10,%esp
}
  80182f:	89 d8                	mov    %ebx,%eax
  801831:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	53                   	push   %ebx
  80183c:	83 ec 20             	sub    $0x20,%esp
  80183f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801842:	53                   	push   %ebx
  801843:	e8 2c ef ff ff       	call   800774 <strlen>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801850:	7f 67                	jg     8018b9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	e8 74 f8 ff ff       	call   8010d2 <fd_alloc>
  80185e:	83 c4 10             	add    $0x10,%esp
		return r;
  801861:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801863:	85 c0                	test   %eax,%eax
  801865:	78 57                	js     8018be <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	53                   	push   %ebx
  80186b:	68 00 50 80 00       	push   $0x805000
  801870:	e8 38 ef ff ff       	call   8007ad <strcpy>
	fsipcbuf.open.req_omode = mode;
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	b8 01 00 00 00       	mov    $0x1,%eax
  801885:	e8 d0 fd ff ff       	call   80165a <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 14                	jns    8018a7 <open+0x6f>
		fd_close(fd, 0);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	6a 00                	push   $0x0
  801898:	ff 75 f4             	pushl  -0xc(%ebp)
  80189b:	e8 2a f9 ff ff       	call   8011ca <fd_close>
		return r;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	89 da                	mov    %ebx,%edx
  8018a5:	eb 17                	jmp    8018be <open+0x86>
	}

	return fd2num(fd);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	e8 f9 f7 ff ff       	call   8010ab <fd2num>
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	eb 05                	jmp    8018be <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018be:	89 d0                	mov    %edx,%eax
  8018c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d5:	e8 80 fd ff ff       	call   80165a <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 08             	pushl  0x8(%ebp)
  8018ea:	e8 cc f7 ff ff       	call   8010bb <fd2data>
  8018ef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	68 07 28 80 00       	push   $0x802807
  8018f9:	53                   	push   %ebx
  8018fa:	e8 ae ee ff ff       	call   8007ad <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018ff:	8b 56 04             	mov    0x4(%esi),%edx
  801902:	89 d0                	mov    %edx,%eax
  801904:	2b 06                	sub    (%esi),%eax
  801906:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80190c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801913:	00 00 00 
	stat->st_dev = &devpipe;
  801916:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80191d:	30 80 00 
	return 0;
}
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
  801925:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	53                   	push   %ebx
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801936:	53                   	push   %ebx
  801937:	6a 00                	push   $0x0
  801939:	e8 fd f2 ff ff       	call   800c3b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80193e:	89 1c 24             	mov    %ebx,(%esp)
  801941:	e8 75 f7 ff ff       	call   8010bb <fd2data>
  801946:	83 c4 08             	add    $0x8,%esp
  801949:	50                   	push   %eax
  80194a:	6a 00                	push   $0x0
  80194c:	e8 ea f2 ff ff       	call   800c3b <sys_page_unmap>
}
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	83 ec 1c             	sub    $0x1c,%esp
  80195f:	89 c6                	mov    %eax,%esi
  801961:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801964:	a1 08 40 80 00       	mov    0x804008,%eax
  801969:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	56                   	push   %esi
  801970:	e8 cb 05 00 00       	call   801f40 <pageref>
  801975:	89 c7                	mov    %eax,%edi
  801977:	83 c4 04             	add    $0x4,%esp
  80197a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80197d:	e8 be 05 00 00       	call   801f40 <pageref>
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	39 c7                	cmp    %eax,%edi
  801987:	0f 94 c2             	sete   %dl
  80198a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80198d:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801993:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801996:	39 fb                	cmp    %edi,%ebx
  801998:	74 19                	je     8019b3 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80199a:	84 d2                	test   %dl,%dl
  80199c:	74 c6                	je     801964 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80199e:	8b 51 58             	mov    0x58(%ecx),%edx
  8019a1:	50                   	push   %eax
  8019a2:	52                   	push   %edx
  8019a3:	53                   	push   %ebx
  8019a4:	68 0e 28 80 00       	push   $0x80280e
  8019a9:	e8 78 e8 ff ff       	call   800226 <cprintf>
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	eb b1                	jmp    801964 <_pipeisclosed+0xe>
	}
}
  8019b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5f                   	pop    %edi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	57                   	push   %edi
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 28             	sub    $0x28,%esp
  8019c4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019c7:	56                   	push   %esi
  8019c8:	e8 ee f6 ff ff       	call   8010bb <fd2data>
  8019cd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d7:	eb 4b                	jmp    801a24 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019d9:	89 da                	mov    %ebx,%edx
  8019db:	89 f0                	mov    %esi,%eax
  8019dd:	e8 74 ff ff ff       	call   801956 <_pipeisclosed>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	75 48                	jne    801a2e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019e6:	e8 ac f1 ff ff       	call   800b97 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ee:	8b 0b                	mov    (%ebx),%ecx
  8019f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f3:	39 d0                	cmp    %edx,%eax
  8019f5:	73 e2                	jae    8019d9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a01:	89 c2                	mov    %eax,%edx
  801a03:	c1 fa 1f             	sar    $0x1f,%edx
  801a06:	89 d1                	mov    %edx,%ecx
  801a08:	c1 e9 1b             	shr    $0x1b,%ecx
  801a0b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a0e:	83 e2 1f             	and    $0x1f,%edx
  801a11:	29 ca                	sub    %ecx,%edx
  801a13:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a17:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a1b:	83 c0 01             	add    $0x1,%eax
  801a1e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a21:	83 c7 01             	add    $0x1,%edi
  801a24:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a27:	75 c2                	jne    8019eb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a29:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2c:	eb 05                	jmp    801a33 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	57                   	push   %edi
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	83 ec 18             	sub    $0x18,%esp
  801a44:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a47:	57                   	push   %edi
  801a48:	e8 6e f6 ff ff       	call   8010bb <fd2data>
  801a4d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a57:	eb 3d                	jmp    801a96 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a59:	85 db                	test   %ebx,%ebx
  801a5b:	74 04                	je     801a61 <devpipe_read+0x26>
				return i;
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	eb 44                	jmp    801aa5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a61:	89 f2                	mov    %esi,%edx
  801a63:	89 f8                	mov    %edi,%eax
  801a65:	e8 ec fe ff ff       	call   801956 <_pipeisclosed>
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	75 32                	jne    801aa0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a6e:	e8 24 f1 ff ff       	call   800b97 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a73:	8b 06                	mov    (%esi),%eax
  801a75:	3b 46 04             	cmp    0x4(%esi),%eax
  801a78:	74 df                	je     801a59 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7a:	99                   	cltd   
  801a7b:	c1 ea 1b             	shr    $0x1b,%edx
  801a7e:	01 d0                	add    %edx,%eax
  801a80:	83 e0 1f             	and    $0x1f,%eax
  801a83:	29 d0                	sub    %edx,%eax
  801a85:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a90:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a93:	83 c3 01             	add    $0x1,%ebx
  801a96:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a99:	75 d8                	jne    801a73 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9e:	eb 05                	jmp    801aa5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	e8 14 f6 ff ff       	call   8010d2 <fd_alloc>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	0f 88 2c 01 00 00    	js     801bf7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	68 07 04 00 00       	push   $0x407
  801ad3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 d9 f0 ff ff       	call   800bb6 <sys_page_alloc>
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	89 c2                	mov    %eax,%edx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	0f 88 0d 01 00 00    	js     801bf7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af0:	50                   	push   %eax
  801af1:	e8 dc f5 ff ff       	call   8010d2 <fd_alloc>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	0f 88 e2 00 00 00    	js     801be5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b03:	83 ec 04             	sub    $0x4,%esp
  801b06:	68 07 04 00 00       	push   $0x407
  801b0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0e:	6a 00                	push   $0x0
  801b10:	e8 a1 f0 ff ff       	call   800bb6 <sys_page_alloc>
  801b15:	89 c3                	mov    %eax,%ebx
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	0f 88 c3 00 00 00    	js     801be5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	e8 8e f5 ff ff       	call   8010bb <fd2data>
  801b2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2f:	83 c4 0c             	add    $0xc,%esp
  801b32:	68 07 04 00 00       	push   $0x407
  801b37:	50                   	push   %eax
  801b38:	6a 00                	push   $0x0
  801b3a:	e8 77 f0 ff ff       	call   800bb6 <sys_page_alloc>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 89 00 00 00    	js     801bd5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4c:	83 ec 0c             	sub    $0xc,%esp
  801b4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b52:	e8 64 f5 ff ff       	call   8010bb <fd2data>
  801b57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b5e:	50                   	push   %eax
  801b5f:	6a 00                	push   $0x0
  801b61:	56                   	push   %esi
  801b62:	6a 00                	push   $0x0
  801b64:	e8 90 f0 ff ff       	call   800bf9 <sys_page_map>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	83 c4 20             	add    $0x20,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 55                	js     801bc7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b72:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b90:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 04 f5 ff ff       	call   8010ab <fd2num>
  801ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bac:	83 c4 04             	add    $0x4,%esp
  801baf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb2:	e8 f4 f4 ff ff       	call   8010ab <fd2num>
  801bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc5:	eb 30                	jmp    801bf7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bc7:	83 ec 08             	sub    $0x8,%esp
  801bca:	56                   	push   %esi
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 69 f0 ff ff       	call   800c3b <sys_page_unmap>
  801bd2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 59 f0 ff ff       	call   800c3b <sys_page_unmap>
  801be2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be5:	83 ec 08             	sub    $0x8,%esp
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 49 f0 ff ff       	call   800c3b <sys_page_unmap>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bf7:	89 d0                	mov    %edx,%eax
  801bf9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	ff 75 08             	pushl  0x8(%ebp)
  801c0d:	e8 0f f5 ff ff       	call   801121 <fd_lookup>
  801c12:	89 c2                	mov    %eax,%edx
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 d2                	test   %edx,%edx
  801c19:	78 18                	js     801c33 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c21:	e8 95 f4 ff ff       	call   8010bb <fd2data>
	return _pipeisclosed(fd, p);
  801c26:	89 c2                	mov    %eax,%edx
  801c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2b:	e8 26 fd ff ff       	call   801956 <_pipeisclosed>
  801c30:	83 c4 10             	add    $0x10,%esp
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c45:	68 26 28 80 00       	push   $0x802826
  801c4a:	ff 75 0c             	pushl  0xc(%ebp)
  801c4d:	e8 5b eb ff ff       	call   8007ad <strcpy>
	return 0;
}
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	57                   	push   %edi
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
  801c5f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c65:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c70:	eb 2d                	jmp    801c9f <devcons_write+0x46>
		m = n - tot;
  801c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c75:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c77:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c7a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c7f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	53                   	push   %ebx
  801c86:	03 45 0c             	add    0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	57                   	push   %edi
  801c8b:	e8 af ec ff ff       	call   80093f <memmove>
		sys_cputs(buf, m);
  801c90:	83 c4 08             	add    $0x8,%esp
  801c93:	53                   	push   %ebx
  801c94:	57                   	push   %edi
  801c95:	e8 60 ee ff ff       	call   800afa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9a:	01 de                	add    %ebx,%esi
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	89 f0                	mov    %esi,%eax
  801ca1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca4:	72 cc                	jb     801c72 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5f                   	pop    %edi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801cb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbd:	75 07                	jne    801cc6 <devcons_read+0x18>
  801cbf:	eb 28                	jmp    801ce9 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc1:	e8 d1 ee ff ff       	call   800b97 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc6:	e8 4d ee ff ff       	call   800b18 <sys_cgetc>
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	74 f2                	je     801cc1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 16                	js     801ce9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd3:	83 f8 04             	cmp    $0x4,%eax
  801cd6:	74 0c                	je     801ce4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdb:	88 02                	mov    %al,(%edx)
	return 1;
  801cdd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce2:	eb 05                	jmp    801ce9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cf7:	6a 01                	push   $0x1
  801cf9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	e8 f8 ed ff ff       	call   800afa <sys_cputs>
  801d02:	83 c4 10             	add    $0x10,%esp
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <getchar>:

int
getchar(void)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d0d:	6a 01                	push   $0x1
  801d0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	6a 00                	push   $0x0
  801d15:	e8 71 f6 ff ff       	call   80138b <read>
	if (r < 0)
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 0f                	js     801d30 <getchar+0x29>
		return r;
	if (r < 1)
  801d21:	85 c0                	test   %eax,%eax
  801d23:	7e 06                	jle    801d2b <getchar+0x24>
		return -E_EOF;
	return c;
  801d25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d29:	eb 05                	jmp    801d30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	ff 75 08             	pushl  0x8(%ebp)
  801d3f:	e8 dd f3 ff ff       	call   801121 <fd_lookup>
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 11                	js     801d5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d54:	39 10                	cmp    %edx,(%eax)
  801d56:	0f 94 c0             	sete   %al
  801d59:	0f b6 c0             	movzbl %al,%eax
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <opencons>:

int
opencons(void)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	e8 65 f3 ff ff       	call   8010d2 <fd_alloc>
  801d6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801d70:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 3e                	js     801db4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d76:	83 ec 04             	sub    $0x4,%esp
  801d79:	68 07 04 00 00       	push   $0x407
  801d7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d81:	6a 00                	push   $0x0
  801d83:	e8 2e ee ff ff       	call   800bb6 <sys_page_alloc>
  801d88:	83 c4 10             	add    $0x10,%esp
		return r;
  801d8b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 23                	js     801db4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	50                   	push   %eax
  801daa:	e8 fc f2 ff ff       	call   8010ab <fd2num>
  801daf:	89 c2                	mov    %eax,%edx
  801db1:	83 c4 10             	add    $0x10,%esp
}
  801db4:	89 d0                	mov    %edx,%eax
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dbe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc5:	75 2c                	jne    801df3 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801dc7:	83 ec 04             	sub    $0x4,%esp
  801dca:	6a 07                	push   $0x7
  801dcc:	68 00 f0 bf ee       	push   $0xeebff000
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 de ed ff ff       	call   800bb6 <sys_page_alloc>
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	74 14                	je     801df3 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801ddf:	83 ec 04             	sub    $0x4,%esp
  801de2:	68 34 28 80 00       	push   $0x802834
  801de7:	6a 21                	push   $0x21
  801de9:	68 98 28 80 00       	push   $0x802898
  801dee:	e8 5a e3 ff ff       	call   80014d <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df3:	8b 45 08             	mov    0x8(%ebp),%eax
  801df6:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801dfb:	83 ec 08             	sub    $0x8,%esp
  801dfe:	68 27 1e 80 00       	push   $0x801e27
  801e03:	6a 00                	push   $0x0
  801e05:	e8 f7 ee ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	79 14                	jns    801e25 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	68 60 28 80 00       	push   $0x802860
  801e19:	6a 29                	push   $0x29
  801e1b:	68 98 28 80 00       	push   $0x802898
  801e20:	e8 28 e3 ff ff       	call   80014d <_panic>
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e27:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e28:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e2d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e2f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801e32:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801e37:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801e3b:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801e3f:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801e41:	83 c4 08             	add    $0x8,%esp
        popal
  801e44:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801e45:	83 c4 04             	add    $0x4,%esp
        popfl
  801e48:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801e49:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e4a:	c3                   	ret    

00801e4b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	8b 75 08             	mov    0x8(%ebp),%esi
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e60:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	50                   	push   %eax
  801e67:	e8 fa ee ff ff       	call   800d66 <sys_ipc_recv>
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	79 16                	jns    801e89 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801e73:	85 f6                	test   %esi,%esi
  801e75:	74 06                	je     801e7d <ipc_recv+0x32>
  801e77:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801e7d:	85 db                	test   %ebx,%ebx
  801e7f:	74 2c                	je     801ead <ipc_recv+0x62>
  801e81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e87:	eb 24                	jmp    801ead <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801e89:	85 f6                	test   %esi,%esi
  801e8b:	74 0a                	je     801e97 <ipc_recv+0x4c>
  801e8d:	a1 08 40 80 00       	mov    0x804008,%eax
  801e92:	8b 40 74             	mov    0x74(%eax),%eax
  801e95:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801e97:	85 db                	test   %ebx,%ebx
  801e99:	74 0a                	je     801ea5 <ipc_recv+0x5a>
  801e9b:	a1 08 40 80 00       	mov    0x804008,%eax
  801ea0:	8b 40 78             	mov    0x78(%eax),%eax
  801ea3:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801ea5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eaa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb0:	5b                   	pop    %ebx
  801eb1:	5e                   	pop    %esi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	57                   	push   %edi
  801eb8:	56                   	push   %esi
  801eb9:	53                   	push   %ebx
  801eba:	83 ec 0c             	sub    $0xc,%esp
  801ebd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801ec6:	85 db                	test   %ebx,%ebx
  801ec8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ecd:	0f 44 d8             	cmove  %eax,%ebx
  801ed0:	eb 1c                	jmp    801eee <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801ed2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed5:	74 12                	je     801ee9 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ed7:	50                   	push   %eax
  801ed8:	68 a6 28 80 00       	push   $0x8028a6
  801edd:	6a 39                	push   $0x39
  801edf:	68 c1 28 80 00       	push   $0x8028c1
  801ee4:	e8 64 e2 ff ff       	call   80014d <_panic>
                 sys_yield();
  801ee9:	e8 a9 ec ff ff       	call   800b97 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801eee:	ff 75 14             	pushl  0x14(%ebp)
  801ef1:	53                   	push   %ebx
  801ef2:	56                   	push   %esi
  801ef3:	57                   	push   %edi
  801ef4:	e8 4a ee ff ff       	call   800d43 <sys_ipc_try_send>
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 d2                	js     801ed2 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f13:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f16:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f1c:	8b 52 50             	mov    0x50(%edx),%edx
  801f1f:	39 ca                	cmp    %ecx,%edx
  801f21:	75 0d                	jne    801f30 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f23:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f26:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801f2b:	8b 40 08             	mov    0x8(%eax),%eax
  801f2e:	eb 0e                	jmp    801f3e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f30:	83 c0 01             	add    $0x1,%eax
  801f33:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f38:	75 d9                	jne    801f13 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f3a:	66 b8 00 00          	mov    $0x0,%ax
}
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f46:	89 d0                	mov    %edx,%eax
  801f48:	c1 e8 16             	shr    $0x16,%eax
  801f4b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f57:	f6 c1 01             	test   $0x1,%cl
  801f5a:	74 1d                	je     801f79 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f5c:	c1 ea 0c             	shr    $0xc,%edx
  801f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f66:	f6 c2 01             	test   $0x1,%dl
  801f69:	74 0e                	je     801f79 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f6b:	c1 ea 0c             	shr    $0xc,%edx
  801f6e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f75:	ef 
  801f76:	0f b7 c0             	movzwl %ax,%eax
}
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
  801f7b:	66 90                	xchg   %ax,%ax
  801f7d:	66 90                	xchg   %ax,%ax
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	83 ec 10             	sub    $0x10,%esp
  801f86:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f8a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f8e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f96:	85 d2                	test   %edx,%edx
  801f98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f9c:	89 34 24             	mov    %esi,(%esp)
  801f9f:	89 c8                	mov    %ecx,%eax
  801fa1:	75 35                	jne    801fd8 <__udivdi3+0x58>
  801fa3:	39 f1                	cmp    %esi,%ecx
  801fa5:	0f 87 bd 00 00 00    	ja     802068 <__udivdi3+0xe8>
  801fab:	85 c9                	test   %ecx,%ecx
  801fad:	89 cd                	mov    %ecx,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f1                	div    %ecx
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 f0                	mov    %esi,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c6                	mov    %eax,%esi
  801fc4:	89 f8                	mov    %edi,%eax
  801fc6:	f7 f5                	div    %ebp
  801fc8:	89 f2                	mov    %esi,%edx
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	5e                   	pop    %esi
  801fce:	5f                   	pop    %edi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    
  801fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	3b 14 24             	cmp    (%esp),%edx
  801fdb:	77 7b                	ja     802058 <__udivdi3+0xd8>
  801fdd:	0f bd f2             	bsr    %edx,%esi
  801fe0:	83 f6 1f             	xor    $0x1f,%esi
  801fe3:	0f 84 97 00 00 00    	je     802080 <__udivdi3+0x100>
  801fe9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801fee:	89 d7                	mov    %edx,%edi
  801ff0:	89 f1                	mov    %esi,%ecx
  801ff2:	29 f5                	sub    %esi,%ebp
  801ff4:	d3 e7                	shl    %cl,%edi
  801ff6:	89 c2                	mov    %eax,%edx
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	d3 ea                	shr    %cl,%edx
  801ffc:	89 f1                	mov    %esi,%ecx
  801ffe:	09 fa                	or     %edi,%edx
  802000:	8b 3c 24             	mov    (%esp),%edi
  802003:	d3 e0                	shl    %cl,%eax
  802005:	89 54 24 08          	mov    %edx,0x8(%esp)
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802013:	89 fa                	mov    %edi,%edx
  802015:	d3 ea                	shr    %cl,%edx
  802017:	89 f1                	mov    %esi,%ecx
  802019:	d3 e7                	shl    %cl,%edi
  80201b:	89 e9                	mov    %ebp,%ecx
  80201d:	d3 e8                	shr    %cl,%eax
  80201f:	09 c7                	or     %eax,%edi
  802021:	89 f8                	mov    %edi,%eax
  802023:	f7 74 24 08          	divl   0x8(%esp)
  802027:	89 d5                	mov    %edx,%ebp
  802029:	89 c7                	mov    %eax,%edi
  80202b:	f7 64 24 0c          	mull   0xc(%esp)
  80202f:	39 d5                	cmp    %edx,%ebp
  802031:	89 14 24             	mov    %edx,(%esp)
  802034:	72 11                	jb     802047 <__udivdi3+0xc7>
  802036:	8b 54 24 04          	mov    0x4(%esp),%edx
  80203a:	89 f1                	mov    %esi,%ecx
  80203c:	d3 e2                	shl    %cl,%edx
  80203e:	39 c2                	cmp    %eax,%edx
  802040:	73 5e                	jae    8020a0 <__udivdi3+0x120>
  802042:	3b 2c 24             	cmp    (%esp),%ebp
  802045:	75 59                	jne    8020a0 <__udivdi3+0x120>
  802047:	8d 47 ff             	lea    -0x1(%edi),%eax
  80204a:	31 f6                	xor    %esi,%esi
  80204c:	89 f2                	mov    %esi,%edx
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    
  802055:	8d 76 00             	lea    0x0(%esi),%esi
  802058:	31 f6                	xor    %esi,%esi
  80205a:	31 c0                	xor    %eax,%eax
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
  802068:	89 f2                	mov    %esi,%edx
  80206a:	31 f6                	xor    %esi,%esi
  80206c:	89 f8                	mov    %edi,%eax
  80206e:	f7 f1                	div    %ecx
  802070:	89 f2                	mov    %esi,%edx
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802084:	76 0b                	jbe    802091 <__udivdi3+0x111>
  802086:	31 c0                	xor    %eax,%eax
  802088:	3b 14 24             	cmp    (%esp),%edx
  80208b:	0f 83 37 ff ff ff    	jae    801fc8 <__udivdi3+0x48>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	e9 2d ff ff ff       	jmp    801fc8 <__udivdi3+0x48>
  80209b:	90                   	nop
  80209c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 f8                	mov    %edi,%eax
  8020a2:	31 f6                	xor    %esi,%esi
  8020a4:	e9 1f ff ff ff       	jmp    801fc8 <__udivdi3+0x48>
  8020a9:	66 90                	xchg   %ax,%ax
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	83 ec 20             	sub    $0x20,%esp
  8020b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8020ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c2:	89 c6                	mov    %eax,%esi
  8020c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	89 c2                	mov    %eax,%edx
  8020e0:	75 1e                	jne    802100 <__umoddi3+0x50>
  8020e2:	39 f7                	cmp    %esi,%edi
  8020e4:	76 52                	jbe    802138 <__umoddi3+0x88>
  8020e6:	89 c8                	mov    %ecx,%eax
  8020e8:	89 f2                	mov    %esi,%edx
  8020ea:	f7 f7                	div    %edi
  8020ec:	89 d0                	mov    %edx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	83 c4 20             	add    $0x20,%esp
  8020f3:	5e                   	pop    %esi
  8020f4:	5f                   	pop    %edi
  8020f5:	5d                   	pop    %ebp
  8020f6:	c3                   	ret    
  8020f7:	89 f6                	mov    %esi,%esi
  8020f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802100:	39 f0                	cmp    %esi,%eax
  802102:	77 5c                	ja     802160 <__umoddi3+0xb0>
  802104:	0f bd e8             	bsr    %eax,%ebp
  802107:	83 f5 1f             	xor    $0x1f,%ebp
  80210a:	75 64                	jne    802170 <__umoddi3+0xc0>
  80210c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802110:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802114:	0f 86 f6 00 00 00    	jbe    802210 <__umoddi3+0x160>
  80211a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80211e:	0f 82 ec 00 00 00    	jb     802210 <__umoddi3+0x160>
  802124:	8b 44 24 14          	mov    0x14(%esp),%eax
  802128:	8b 54 24 18          	mov    0x18(%esp),%edx
  80212c:	83 c4 20             	add    $0x20,%esp
  80212f:	5e                   	pop    %esi
  802130:	5f                   	pop    %edi
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    
  802133:	90                   	nop
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	85 ff                	test   %edi,%edi
  80213a:	89 fd                	mov    %edi,%ebp
  80213c:	75 0b                	jne    802149 <__umoddi3+0x99>
  80213e:	b8 01 00 00 00       	mov    $0x1,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f7                	div    %edi
  802147:	89 c5                	mov    %eax,%ebp
  802149:	8b 44 24 10          	mov    0x10(%esp),%eax
  80214d:	31 d2                	xor    %edx,%edx
  80214f:	f7 f5                	div    %ebp
  802151:	89 c8                	mov    %ecx,%eax
  802153:	f7 f5                	div    %ebp
  802155:	eb 95                	jmp    8020ec <__umoddi3+0x3c>
  802157:	89 f6                	mov    %esi,%esi
  802159:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 20             	add    $0x20,%esp
  802167:	5e                   	pop    %esi
  802168:	5f                   	pop    %edi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    
  80216b:	90                   	nop
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	b8 20 00 00 00       	mov    $0x20,%eax
  802175:	89 e9                	mov    %ebp,%ecx
  802177:	29 e8                	sub    %ebp,%eax
  802179:	d3 e2                	shl    %cl,%edx
  80217b:	89 c7                	mov    %eax,%edi
  80217d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802181:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 c1                	mov    %eax,%ecx
  80218b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80218f:	09 d1                	or     %edx,%ecx
  802191:	89 fa                	mov    %edi,%edx
  802193:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802197:	89 e9                	mov    %ebp,%ecx
  802199:	d3 e0                	shl    %cl,%eax
  80219b:	89 f9                	mov    %edi,%ecx
  80219d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	d3 e8                	shr    %cl,%eax
  8021a5:	89 e9                	mov    %ebp,%ecx
  8021a7:	89 c7                	mov    %eax,%edi
  8021a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021ad:	d3 e6                	shl    %cl,%esi
  8021af:	89 d1                	mov    %edx,%ecx
  8021b1:	89 fa                	mov    %edi,%edx
  8021b3:	d3 e8                	shr    %cl,%eax
  8021b5:	89 e9                	mov    %ebp,%ecx
  8021b7:	09 f0                	or     %esi,%eax
  8021b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8021bd:	f7 74 24 10          	divl   0x10(%esp)
  8021c1:	d3 e6                	shl    %cl,%esi
  8021c3:	89 d1                	mov    %edx,%ecx
  8021c5:	f7 64 24 0c          	mull   0xc(%esp)
  8021c9:	39 d1                	cmp    %edx,%ecx
  8021cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8021cf:	89 d7                	mov    %edx,%edi
  8021d1:	89 c6                	mov    %eax,%esi
  8021d3:	72 0a                	jb     8021df <__umoddi3+0x12f>
  8021d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021d9:	73 10                	jae    8021eb <__umoddi3+0x13b>
  8021db:	39 d1                	cmp    %edx,%ecx
  8021dd:	75 0c                	jne    8021eb <__umoddi3+0x13b>
  8021df:	89 d7                	mov    %edx,%edi
  8021e1:	89 c6                	mov    %eax,%esi
  8021e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021eb:	89 ca                	mov    %ecx,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021f3:	29 f0                	sub    %esi,%eax
  8021f5:	19 fa                	sbb    %edi,%edx
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8021fe:	89 d7                	mov    %edx,%edi
  802200:	d3 e7                	shl    %cl,%edi
  802202:	89 e9                	mov    %ebp,%ecx
  802204:	09 f8                	or     %edi,%eax
  802206:	d3 ea                	shr    %cl,%edx
  802208:	83 c4 20             	add    $0x20,%esp
  80220b:	5e                   	pop    %esi
  80220c:	5f                   	pop    %edi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    
  80220f:	90                   	nop
  802210:	8b 74 24 10          	mov    0x10(%esp),%esi
  802214:	29 f9                	sub    %edi,%ecx
  802216:	19 c6                	sbb    %eax,%esi
  802218:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80221c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802220:	e9 ff fe ff ff       	jmp    802124 <__umoddi3+0x74>
