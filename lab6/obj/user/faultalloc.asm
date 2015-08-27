
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 24 80 00       	push   $0x802440
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 35 0b 00 00       	call   800b93 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 24 80 00       	push   $0x802460
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 24 80 00       	push   $0x80244a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 24 80 00       	push   $0x80248c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ae 06 00 00       	call   800737 <snprintf>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 84 0d 00 00       	call   800e25 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 24 80 00       	push   $0x80245c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 24 80 00       	push   $0x80245c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp
}
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000d5:	e8 7b 0a 00 00       	call   800b55 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
  800106:	83 c4 10             	add    $0x10,%esp
}
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 6f 0f 00 00       	call   80108a <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 ef 09 00 00       	call   800b14 <sys_env_destroy>
  800125:	83 c4 10             	add    $0x10,%esp
}
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 18 0a 00 00       	call   800b55 <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 b8 24 80 00       	push   $0x8024b8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 d4 29 80 00 	movl   $0x8029d4,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 37 09 00 00       	call   800ad7 <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 4f 01 00 00       	call   800335 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 dc 08 00 00       	call   800ad7 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 d1                	mov    %edx,%ecx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800242:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800245:	72 05                	jb     80024c <printnum+0x35>
  800247:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024a:	77 3e                	ja     80028a <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	53                   	push   %ebx
  800256:	50                   	push   %eax
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 05 1f 00 00       	call   802170 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 13                	jmp    800291 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	7f ed                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	83 ec 04             	sub    $0x4,%esp
  800298:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029b:	ff 75 e0             	pushl  -0x20(%ebp)
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	e8 f7 1f 00 00       	call   8022a0 <__umoddi3>
  8002a9:	83 c4 14             	add    $0x14,%esp
  8002ac:	0f be 80 db 24 80 00 	movsbl 0x8024db(%eax),%eax
  8002b3:	50                   	push   %eax
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
}
  8002b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5e                   	pop    %esi
  8002be:	5f                   	pop    %edi
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c4:	83 fa 01             	cmp    $0x1,%edx
  8002c7:	7e 0e                	jle    8002d7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	8b 52 04             	mov    0x4(%edx),%edx
  8002d5:	eb 22                	jmp    8002f9 <getuint+0x38>
	else if (lflag)
  8002d7:	85 d2                	test   %edx,%edx
  8002d9:	74 10                	je     8002eb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e9:	eb 0e                	jmp    8002f9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800301:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800305:	8b 10                	mov    (%eax),%edx
  800307:	3b 50 04             	cmp    0x4(%eax),%edx
  80030a:	73 0a                	jae    800316 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	88 02                	mov    %al,(%edx)
}
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 05 00 00 00       	call   800335 <vprintfmt>
	va_end(ap);
  800330:	83 c4 10             	add    $0x10,%esp
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 2c             	sub    $0x2c,%esp
  80033e:	8b 75 08             	mov    0x8(%ebp),%esi
  800341:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800344:	8b 7d 10             	mov    0x10(%ebp),%edi
  800347:	eb 12                	jmp    80035b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800349:	85 c0                	test   %eax,%eax
  80034b:	0f 84 90 03 00 00    	je     8006e1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	53                   	push   %ebx
  800355:	50                   	push   %eax
  800356:	ff d6                	call   *%esi
  800358:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035b:	83 c7 01             	add    $0x1,%edi
  80035e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800362:	83 f8 25             	cmp    $0x25,%eax
  800365:	75 e2                	jne    800349 <vprintfmt+0x14>
  800367:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800372:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800379:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
  800385:	eb 07                	jmp    80038e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8d 47 01             	lea    0x1(%edi),%eax
  800391:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800394:	0f b6 07             	movzbl (%edi),%eax
  800397:	0f b6 c8             	movzbl %al,%ecx
  80039a:	83 e8 23             	sub    $0x23,%eax
  80039d:	3c 55                	cmp    $0x55,%al
  80039f:	0f 87 21 03 00 00    	ja     8006c6 <vprintfmt+0x391>
  8003a5:	0f b6 c0             	movzbl %al,%eax
  8003a8:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b6:	eb d6                	jmp    80038e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ca:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d0:	83 fa 09             	cmp    $0x9,%edx
  8003d3:	77 39                	ja     80040e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d8:	eb e9                	jmp    8003c3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003eb:	eb 27                	jmp    800414 <vprintfmt+0xdf>
  8003ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	0f 49 c8             	cmovns %eax,%ecx
  8003fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800400:	eb 8c                	jmp    80038e <vprintfmt+0x59>
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800405:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040c:	eb 80                	jmp    80038e <vprintfmt+0x59>
  80040e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800411:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 89 70 ff ff ff    	jns    80038e <vprintfmt+0x59>
				width = precision, precision = -1;
  80041e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800424:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042b:	e9 5e ff ff ff       	jmp    80038e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800430:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800436:	e9 53 ff ff ff       	jmp    80038e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	ff 30                	pushl  (%eax)
  80044a:	ff d6                	call   *%esi
			break;
  80044c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800452:	e9 04 ff ff ff       	jmp    80035b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	8b 00                	mov    (%eax),%eax
  800462:	99                   	cltd   
  800463:	31 d0                	xor    %edx,%eax
  800465:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800467:	83 f8 0f             	cmp    $0xf,%eax
  80046a:	7f 0b                	jg     800477 <vprintfmt+0x142>
  80046c:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800473:	85 d2                	test   %edx,%edx
  800475:	75 18                	jne    80048f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800477:	50                   	push   %eax
  800478:	68 f3 24 80 00       	push   $0x8024f3
  80047d:	53                   	push   %ebx
  80047e:	56                   	push   %esi
  80047f:	e8 94 fe ff ff       	call   800318 <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048a:	e9 cc fe ff ff       	jmp    80035b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048f:	52                   	push   %edx
  800490:	68 69 29 80 00       	push   $0x802969
  800495:	53                   	push   %ebx
  800496:	56                   	push   %esi
  800497:	e8 7c fe ff ff       	call   800318 <printfmt>
  80049c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a2:	e9 b4 fe ff ff       	jmp    80035b <vprintfmt+0x26>
  8004a7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004bb:	85 ff                	test   %edi,%edi
  8004bd:	ba ec 24 80 00       	mov    $0x8024ec,%edx
  8004c2:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c9:	0f 84 92 00 00 00    	je     800561 <vprintfmt+0x22c>
  8004cf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d3:	0f 8e 96 00 00 00    	jle    80056f <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	51                   	push   %ecx
  8004dd:	57                   	push   %edi
  8004de:	e8 86 02 00 00       	call   800769 <strnlen>
  8004e3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fa:	eb 0f                	jmp    80050b <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	ff 75 e0             	pushl  -0x20(%ebp)
  800503:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	85 ff                	test   %edi,%edi
  80050d:	7f ed                	jg     8004fc <vprintfmt+0x1c7>
  80050f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800512:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800515:	85 c9                	test   %ecx,%ecx
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
  80051c:	0f 49 c1             	cmovns %ecx,%eax
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	89 cb                	mov    %ecx,%ebx
  80052c:	eb 4d                	jmp    80057b <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800532:	74 1b                	je     80054f <vprintfmt+0x21a>
  800534:	0f be c0             	movsbl %al,%eax
  800537:	83 e8 20             	sub    $0x20,%eax
  80053a:	83 f8 5e             	cmp    $0x5e,%eax
  80053d:	76 10                	jbe    80054f <vprintfmt+0x21a>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	6a 3f                	push   $0x3f
  800547:	ff 55 08             	call   *0x8(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 0d                	jmp    80055c <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	52                   	push   %edx
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055c:	83 eb 01             	sub    $0x1,%ebx
  80055f:	eb 1a                	jmp    80057b <vprintfmt+0x246>
  800561:	89 75 08             	mov    %esi,0x8(%ebp)
  800564:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	eb 0c                	jmp    80057b <vprintfmt+0x246>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	83 c7 01             	add    $0x1,%edi
  80057e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800582:	0f be d0             	movsbl %al,%edx
  800585:	85 d2                	test   %edx,%edx
  800587:	74 23                	je     8005ac <vprintfmt+0x277>
  800589:	85 f6                	test   %esi,%esi
  80058b:	78 a1                	js     80052e <vprintfmt+0x1f9>
  80058d:	83 ee 01             	sub    $0x1,%esi
  800590:	79 9c                	jns    80052e <vprintfmt+0x1f9>
  800592:	89 df                	mov    %ebx,%edi
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	eb 18                	jmp    8005b4 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 20                	push   $0x20
  8005a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 ef 01             	sub    $0x1,%edi
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	eb 08                	jmp    8005b4 <vprintfmt+0x27f>
  8005ac:	89 df                	mov    %ebx,%edi
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	85 ff                	test   %edi,%edi
  8005b6:	7f e4                	jg     80059c <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 9b fd ff ff       	jmp    80035b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 fa 01             	cmp    $0x1,%edx
  8005c3:	7e 16                	jle    8005db <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 08             	lea    0x8(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d9:	eb 32                	jmp    80060d <vprintfmt+0x2d8>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	eb 16                	jmp    80060d <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800610:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800613:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800618:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061c:	79 74                	jns    800692 <vprintfmt+0x35d>
				putch('-', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 2d                	push   $0x2d
  800624:	ff d6                	call   *%esi
				num = -(long long) num;
  800626:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800629:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062c:	f7 d8                	neg    %eax
  80062e:	83 d2 00             	adc    $0x0,%edx
  800631:	f7 da                	neg    %edx
  800633:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800636:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063b:	eb 55                	jmp    800692 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063d:	8d 45 14             	lea    0x14(%ebp),%eax
  800640:	e8 7c fc ff ff       	call   8002c1 <getuint>
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064a:	eb 46                	jmp    800692 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 6d fc ff ff       	call   8002c1 <getuint>
                        base = 8;
  800654:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800659:	eb 37                	jmp    800692 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 30                	push   $0x30
  800661:	ff d6                	call   *%esi
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 78                	push   $0x78
  800669:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800674:	8b 00                	mov    (%eax),%eax
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800683:	eb 0d                	jmp    800692 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	e8 34 fc ff ff       	call   8002c1 <getuint>
			base = 16;
  80068d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800692:	83 ec 0c             	sub    $0xc,%esp
  800695:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800699:	57                   	push   %edi
  80069a:	ff 75 e0             	pushl  -0x20(%ebp)
  80069d:	51                   	push   %ecx
  80069e:	52                   	push   %edx
  80069f:	50                   	push   %eax
  8006a0:	89 da                	mov    %ebx,%edx
  8006a2:	89 f0                	mov    %esi,%eax
  8006a4:	e8 6e fb ff ff       	call   800217 <printnum>
			break;
  8006a9:	83 c4 20             	add    $0x20,%esp
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	e9 a7 fc ff ff       	jmp    80035b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	51                   	push   %ecx
  8006b9:	ff d6                	call   *%esi
			break;
  8006bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c1:	e9 95 fc ff ff       	jmp    80035b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 25                	push   $0x25
  8006cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 03                	jmp    8006d6 <vprintfmt+0x3a1>
  8006d3:	83 ef 01             	sub    $0x1,%edi
  8006d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006da:	75 f7                	jne    8006d3 <vprintfmt+0x39e>
  8006dc:	e9 7a fc ff ff       	jmp    80035b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e4:	5b                   	pop    %ebx
  8006e5:	5e                   	pop    %esi
  8006e6:	5f                   	pop    %edi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800706:	85 c0                	test   %eax,%eax
  800708:	74 26                	je     800730 <vsnprintf+0x47>
  80070a:	85 d2                	test   %edx,%edx
  80070c:	7e 22                	jle    800730 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070e:	ff 75 14             	pushl  0x14(%ebp)
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	68 fb 02 80 00       	push   $0x8002fb
  80071d:	e8 13 fc ff ff       	call   800335 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800725:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 05                	jmp    800735 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    

00800737 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800740:	50                   	push   %eax
  800741:	ff 75 10             	pushl  0x10(%ebp)
  800744:	ff 75 0c             	pushl  0xc(%ebp)
  800747:	ff 75 08             	pushl  0x8(%ebp)
  80074a:	e8 9a ff ff ff       	call   8006e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	eb 03                	jmp    800761 <strlen+0x10>
		n++;
  80075e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800765:	75 f7                	jne    80075e <strlen+0xd>
		n++;
	return n;
}
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800772:	ba 00 00 00 00       	mov    $0x0,%edx
  800777:	eb 03                	jmp    80077c <strnlen+0x13>
		n++;
  800779:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	39 c2                	cmp    %eax,%edx
  80077e:	74 08                	je     800788 <strnlen+0x1f>
  800780:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800784:	75 f3                	jne    800779 <strnlen+0x10>
  800786:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800794:	89 c2                	mov    %eax,%edx
  800796:	83 c2 01             	add    $0x1,%edx
  800799:	83 c1 01             	add    $0x1,%ecx
  80079c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ef                	jne    800796 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a7:	5b                   	pop    %ebx
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b1:	53                   	push   %ebx
  8007b2:	e8 9a ff ff ff       	call   800751 <strlen>
  8007b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	01 d8                	add    %ebx,%eax
  8007bf:	50                   	push   %eax
  8007c0:	e8 c5 ff ff ff       	call   80078a <strcpy>
	return dst;
}
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	89 f3                	mov    %esi,%ebx
  8007d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	89 f2                	mov    %esi,%edx
  8007de:	eb 0f                	jmp    8007ef <strncpy+0x23>
		*dst++ = *src;
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	0f b6 01             	movzbl (%ecx),%eax
  8007e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ef:	39 da                	cmp    %ebx,%edx
  8007f1:	75 ed                	jne    8007e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	5b                   	pop    %ebx
  8007f6:	5e                   	pop    %esi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800804:	8b 55 10             	mov    0x10(%ebp),%edx
  800807:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 21                	je     80082e <strlcpy+0x35>
  80080d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800811:	89 f2                	mov    %esi,%edx
  800813:	eb 09                	jmp    80081e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800815:	83 c2 01             	add    $0x1,%edx
  800818:	83 c1 01             	add    $0x1,%ecx
  80081b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081e:	39 c2                	cmp    %eax,%edx
  800820:	74 09                	je     80082b <strlcpy+0x32>
  800822:	0f b6 19             	movzbl (%ecx),%ebx
  800825:	84 db                	test   %bl,%bl
  800827:	75 ec                	jne    800815 <strlcpy+0x1c>
  800829:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80082b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082e:	29 f0                	sub    %esi,%eax
}
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083d:	eb 06                	jmp    800845 <strcmp+0x11>
		p++, q++;
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800845:	0f b6 01             	movzbl (%ecx),%eax
  800848:	84 c0                	test   %al,%al
  80084a:	74 04                	je     800850 <strcmp+0x1c>
  80084c:	3a 02                	cmp    (%edx),%al
  80084e:	74 ef                	je     80083f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	0f b6 c0             	movzbl %al,%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
  800864:	89 c3                	mov    %eax,%ebx
  800866:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800869:	eb 06                	jmp    800871 <strncmp+0x17>
		n--, p++, q++;
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800871:	39 d8                	cmp    %ebx,%eax
  800873:	74 15                	je     80088a <strncmp+0x30>
  800875:	0f b6 08             	movzbl (%eax),%ecx
  800878:	84 c9                	test   %cl,%cl
  80087a:	74 04                	je     800880 <strncmp+0x26>
  80087c:	3a 0a                	cmp    (%edx),%cl
  80087e:	74 eb                	je     80086b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800880:	0f b6 00             	movzbl (%eax),%eax
  800883:	0f b6 12             	movzbl (%edx),%edx
  800886:	29 d0                	sub    %edx,%eax
  800888:	eb 05                	jmp    80088f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089c:	eb 07                	jmp    8008a5 <strchr+0x13>
		if (*s == c)
  80089e:	38 ca                	cmp    %cl,%dl
  8008a0:	74 0f                	je     8008b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	0f b6 10             	movzbl (%eax),%edx
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	75 f2                	jne    80089e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 03                	jmp    8008c2 <strfind+0xf>
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 04                	je     8008cd <strfind+0x1a>
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	75 f2                	jne    8008bf <strfind+0xc>
			break;
	return (char *) s;
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008db:	85 c9                	test   %ecx,%ecx
  8008dd:	74 36                	je     800915 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e5:	75 28                	jne    80090f <memset+0x40>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 23                	jne    80090f <memset+0x40>
		c &= 0xFF;
  8008ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f0:	89 d3                	mov    %edx,%ebx
  8008f2:	c1 e3 08             	shl    $0x8,%ebx
  8008f5:	89 d6                	mov    %edx,%esi
  8008f7:	c1 e6 18             	shl    $0x18,%esi
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	c1 e0 10             	shl    $0x10,%eax
  8008ff:	09 f0                	or     %esi,%eax
  800901:	09 c2                	or     %eax,%edx
  800903:	89 d0                	mov    %edx,%eax
  800905:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800907:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80090a:	fc                   	cld    
  80090b:	f3 ab                	rep stos %eax,%es:(%edi)
  80090d:	eb 06                	jmp    800915 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	fc                   	cld    
  800913:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800915:	89 f8                	mov    %edi,%eax
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 75 0c             	mov    0xc(%ebp),%esi
  800927:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092a:	39 c6                	cmp    %eax,%esi
  80092c:	73 35                	jae    800963 <memmove+0x47>
  80092e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800931:	39 d0                	cmp    %edx,%eax
  800933:	73 2e                	jae    800963 <memmove+0x47>
		s += n;
		d += n;
  800935:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800938:	89 d6                	mov    %edx,%esi
  80093a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800942:	75 13                	jne    800957 <memmove+0x3b>
  800944:	f6 c1 03             	test   $0x3,%cl
  800947:	75 0e                	jne    800957 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800949:	83 ef 04             	sub    $0x4,%edi
  80094c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800952:	fd                   	std    
  800953:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800955:	eb 09                	jmp    800960 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800957:	83 ef 01             	sub    $0x1,%edi
  80095a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095d:	fd                   	std    
  80095e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800960:	fc                   	cld    
  800961:	eb 1d                	jmp    800980 <memmove+0x64>
  800963:	89 f2                	mov    %esi,%edx
  800965:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	f6 c2 03             	test   $0x3,%dl
  80096a:	75 0f                	jne    80097b <memmove+0x5f>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 0a                	jne    80097b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800971:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800979:	eb 05                	jmp    800980 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800987:	ff 75 10             	pushl  0x10(%ebp)
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	ff 75 08             	pushl  0x8(%ebp)
  800990:	e8 87 ff ff ff       	call   80091c <memmove>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a2:	89 c6                	mov    %eax,%esi
  8009a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	eb 1a                	jmp    8009c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a9:	0f b6 08             	movzbl (%eax),%ecx
  8009ac:	0f b6 1a             	movzbl (%edx),%ebx
  8009af:	38 d9                	cmp    %bl,%cl
  8009b1:	74 0a                	je     8009bd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b3:	0f b6 c1             	movzbl %cl,%eax
  8009b6:	0f b6 db             	movzbl %bl,%ebx
  8009b9:	29 d8                	sub    %ebx,%eax
  8009bb:	eb 0f                	jmp    8009cc <memcmp+0x35>
		s1++, s2++;
  8009bd:	83 c0 01             	add    $0x1,%eax
  8009c0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	39 f0                	cmp    %esi,%eax
  8009c5:	75 e2                	jne    8009a9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d9:	89 c2                	mov    %eax,%edx
  8009db:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009de:	eb 07                	jmp    8009e7 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e0:	38 08                	cmp    %cl,(%eax)
  8009e2:	74 07                	je     8009eb <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	39 d0                	cmp    %edx,%eax
  8009e9:	72 f5                	jb     8009e0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f9:	eb 03                	jmp    8009fe <strtol+0x11>
		s++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fe:	0f b6 01             	movzbl (%ecx),%eax
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f6                	je     8009fb <strtol+0xe>
  800a05:	3c 20                	cmp    $0x20,%al
  800a07:	74 f2                	je     8009fb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a09:	3c 2b                	cmp    $0x2b,%al
  800a0b:	75 0a                	jne    800a17 <strtol+0x2a>
		s++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
  800a15:	eb 10                	jmp    800a27 <strtol+0x3a>
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1c:	3c 2d                	cmp    $0x2d,%al
  800a1e:	75 07                	jne    800a27 <strtol+0x3a>
		s++, neg = 1;
  800a20:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a27:	85 db                	test   %ebx,%ebx
  800a29:	0f 94 c0             	sete   %al
  800a2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a32:	75 19                	jne    800a4d <strtol+0x60>
  800a34:	80 39 30             	cmpb   $0x30,(%ecx)
  800a37:	75 14                	jne    800a4d <strtol+0x60>
  800a39:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3d:	0f 85 82 00 00 00    	jne    800ac5 <strtol+0xd8>
		s += 2, base = 16;
  800a43:	83 c1 02             	add    $0x2,%ecx
  800a46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4b:	eb 16                	jmp    800a63 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4d:	84 c0                	test   %al,%al
  800a4f:	74 12                	je     800a63 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	80 39 30             	cmpb   $0x30,(%ecx)
  800a59:	75 08                	jne    800a63 <strtol+0x76>
		s++, base = 8;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6b:	0f b6 11             	movzbl (%ecx),%edx
  800a6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 09             	cmp    $0x9,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x93>
			dig = *s - '0';
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 30             	sub    $0x30,%edx
  800a7e:	eb 22                	jmp    800aa2 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 57             	sub    $0x57,%edx
  800a90:	eb 10                	jmp    800aa2 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 16                	ja     800ab2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a9c:	0f be d2             	movsbl %dl,%edx
  800a9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa5:	7d 0f                	jge    800ab6 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab0:	eb b9                	jmp    800a6b <strtol+0x7e>
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	eb 02                	jmp    800ab8 <strtol+0xcb>
  800ab6:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ab8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abc:	74 0d                	je     800acb <strtol+0xde>
		*endptr = (char *) s;
  800abe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac1:	89 0e                	mov    %ecx,(%esi)
  800ac3:	eb 06                	jmp    800acb <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac5:	84 c0                	test   %al,%al
  800ac7:	75 92                	jne    800a5b <strtol+0x6e>
  800ac9:	eb 98                	jmp    800a63 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acb:	f7 da                	neg    %edx
  800acd:	85 ff                	test   %edi,%edi
  800acf:	0f 45 c2             	cmovne %edx,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	89 c7                	mov    %eax,%edi
  800aec:	89 c6                	mov    %eax,%esi
  800aee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 01 00 00 00       	mov    $0x1,%eax
  800b05:	89 d1                	mov    %edx,%ecx
  800b07:	89 d3                	mov    %edx,%ebx
  800b09:	89 d7                	mov    %edx,%edi
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b22:	b8 03 00 00 00       	mov    $0x3,%eax
  800b27:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2a:	89 cb                	mov    %ecx,%ebx
  800b2c:	89 cf                	mov    %ecx,%edi
  800b2e:	89 ce                	mov    %ecx,%esi
  800b30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b32:	85 c0                	test   %eax,%eax
  800b34:	7e 17                	jle    800b4d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	50                   	push   %eax
  800b3a:	6a 03                	push   $0x3
  800b3c:	68 1f 28 80 00       	push   $0x80281f
  800b41:	6a 22                	push   $0x22
  800b43:	68 3c 28 80 00       	push   $0x80283c
  800b48:	e8 dd f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 02 00 00 00       	mov    $0x2,%eax
  800b65:	89 d1                	mov    %edx,%ecx
  800b67:	89 d3                	mov    %edx,%ebx
  800b69:	89 d7                	mov    %edx,%edi
  800b6b:	89 d6                	mov    %edx,%esi
  800b6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_yield>:

void
sys_yield(void)
{      
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ba1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	89 f7                	mov    %esi,%edi
  800bb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 04                	push   $0x4
  800bbd:	68 1f 28 80 00       	push   $0x80281f
  800bc2:	6a 22                	push   $0x22
  800bc4:	68 3c 28 80 00       	push   $0x80283c
  800bc9:	e8 5c f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bed:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf0:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7e 17                	jle    800c10 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 05                	push   $0x5
  800bff:	68 1f 28 80 00       	push   $0x80281f
  800c04:	6a 22                	push   $0x22
  800c06:	68 3c 28 80 00       	push   $0x80283c
  800c0b:	e8 1a f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c26:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 df                	mov    %ebx,%edi
  800c33:	89 de                	mov    %ebx,%esi
  800c35:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7e 17                	jle    800c52 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 06                	push   $0x6
  800c41:	68 1f 28 80 00       	push   $0x80281f
  800c46:	6a 22                	push   $0x22
  800c48:	68 3c 28 80 00       	push   $0x80283c
  800c4d:	e8 d8 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 17                	jle    800c94 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 08                	push   $0x8
  800c83:	68 1f 28 80 00       	push   $0x80281f
  800c88:	6a 22                	push   $0x22
  800c8a:	68 3c 28 80 00       	push   $0x80283c
  800c8f:	e8 96 f4 ff ff       	call   80012a <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	b8 09 00 00 00       	mov    $0x9,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 09                	push   $0x9
  800cc5:	68 1f 28 80 00       	push   $0x80281f
  800cca:	6a 22                	push   $0x22
  800ccc:	68 3c 28 80 00       	push   $0x80283c
  800cd1:	e8 54 f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 17                	jle    800d18 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 0a                	push   $0xa
  800d07:	68 1f 28 80 00       	push   $0x80281f
  800d0c:	6a 22                	push   $0x22
  800d0e:	68 3c 28 80 00       	push   $0x80283c
  800d13:	e8 12 f4 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d26:	be 00 00 00 00       	mov    $0x0,%esi
  800d2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 cb                	mov    %ecx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	89 ce                	mov    %ecx,%esi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 0d                	push   $0xd
  800d6b:	68 1f 28 80 00       	push   $0x80281f
  800d70:	6a 22                	push   $0x22
  800d72:	68 3c 28 80 00       	push   $0x80283c
  800d77:	e8 ae f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d94:	89 d1                	mov    %edx,%ecx
  800d96:	89 d3                	mov    %edx,%ebx
  800d98:	89 d7                	mov    %edx,%edi
  800d9a:	89 d6                	mov    %edx,%esi
  800d9c:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 cb                	mov    %ecx,%ebx
  800dbb:	89 cf                	mov    %ecx,%edi
  800dbd:	89 ce                	mov    %ecx,%esi
  800dbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 17                	jle    800ddc <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 0f                	push   $0xf
  800dcb:	68 1f 28 80 00       	push   $0x80281f
  800dd0:	6a 22                	push   $0x22
  800dd2:	68 3c 28 80 00       	push   $0x80283c
  800dd7:	e8 4e f3 ff ff       	call   80012a <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_recv>:

int
sys_recv(void *addr)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ded:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df2:	b8 10 00 00 00       	mov    $0x10,%eax
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 cb                	mov    %ecx,%ebx
  800dfc:	89 cf                	mov    %ecx,%edi
  800dfe:	89 ce                	mov    %ecx,%esi
  800e00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 17                	jle    800e1d <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	50                   	push   %eax
  800e0a:	6a 10                	push   $0x10
  800e0c:	68 1f 28 80 00       	push   $0x80281f
  800e11:	6a 22                	push   $0x22
  800e13:	68 3c 28 80 00       	push   $0x80283c
  800e18:	e8 0d f3 ff ff       	call   80012a <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e2b:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e32:	75 2c                	jne    800e60 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	6a 07                	push   $0x7
  800e39:	68 00 f0 bf ee       	push   $0xeebff000
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 4e fd ff ff       	call   800b93 <sys_page_alloc>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	74 14                	je     800e60 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	68 4c 28 80 00       	push   $0x80284c
  800e54:	6a 21                	push   $0x21
  800e56:	68 ae 28 80 00       	push   $0x8028ae
  800e5b:	e8 ca f2 ff ff       	call   80012a <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	a3 0c 40 80 00       	mov    %eax,0x80400c
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	68 94 0e 80 00       	push   $0x800e94
  800e70:	6a 00                	push   $0x0
  800e72:	e8 67 fe ff ff       	call   800cde <sys_env_set_pgfault_upcall>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	79 14                	jns    800e92 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	68 78 28 80 00       	push   $0x802878
  800e86:	6a 29                	push   $0x29
  800e88:	68 ae 28 80 00       	push   $0x8028ae
  800e8d:	e8 98 f2 ff ff       	call   80012a <_panic>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e94:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e95:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e9a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e9c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800e9f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800ea4:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800ea8:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800eac:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800eae:	83 c4 08             	add    $0x8,%esp
        popal
  800eb1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800eb2:	83 c4 04             	add    $0x4,%esp
        popfl
  800eb5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800eb6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800eb7:	c3                   	ret    

00800eb8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ed3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eea:	89 c2                	mov    %eax,%edx
  800eec:	c1 ea 16             	shr    $0x16,%edx
  800eef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef6:	f6 c2 01             	test   $0x1,%dl
  800ef9:	74 11                	je     800f0c <fd_alloc+0x2d>
  800efb:	89 c2                	mov    %eax,%edx
  800efd:	c1 ea 0c             	shr    $0xc,%edx
  800f00:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f07:	f6 c2 01             	test   $0x1,%dl
  800f0a:	75 09                	jne    800f15 <fd_alloc+0x36>
			*fd_store = fd;
  800f0c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	eb 17                	jmp    800f2c <fd_alloc+0x4d>
  800f15:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f1a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1f:	75 c9                	jne    800eea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f27:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f34:	83 f8 1f             	cmp    $0x1f,%eax
  800f37:	77 36                	ja     800f6f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f39:	c1 e0 0c             	shl    $0xc,%eax
  800f3c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f41:	89 c2                	mov    %eax,%edx
  800f43:	c1 ea 16             	shr    $0x16,%edx
  800f46:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4d:	f6 c2 01             	test   $0x1,%dl
  800f50:	74 24                	je     800f76 <fd_lookup+0x48>
  800f52:	89 c2                	mov    %eax,%edx
  800f54:	c1 ea 0c             	shr    $0xc,%edx
  800f57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5e:	f6 c2 01             	test   $0x1,%dl
  800f61:	74 1a                	je     800f7d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f66:	89 02                	mov    %eax,(%edx)
	return 0;
  800f68:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6d:	eb 13                	jmp    800f82 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f74:	eb 0c                	jmp    800f82 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7b:	eb 05                	jmp    800f82 <fd_lookup+0x54>
  800f7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f92:	eb 13                	jmp    800fa7 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f94:	39 08                	cmp    %ecx,(%eax)
  800f96:	75 0c                	jne    800fa4 <dev_lookup+0x20>
			*dev = devtab[i];
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	eb 36                	jmp    800fda <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fa4:	83 c2 01             	add    $0x1,%edx
  800fa7:	8b 04 95 3c 29 80 00 	mov    0x80293c(,%edx,4),%eax
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	75 e2                	jne    800f94 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb2:	a1 08 40 80 00       	mov    0x804008,%eax
  800fb7:	8b 40 48             	mov    0x48(%eax),%eax
  800fba:	83 ec 04             	sub    $0x4,%esp
  800fbd:	51                   	push   %ecx
  800fbe:	50                   	push   %eax
  800fbf:	68 bc 28 80 00       	push   $0x8028bc
  800fc4:	e8 3a f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 10             	sub    $0x10,%esp
  800fe4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fee:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ff4:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff7:	50                   	push   %eax
  800ff8:	e8 31 ff ff ff       	call   800f2e <fd_lookup>
  800ffd:	83 c4 08             	add    $0x8,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 05                	js     801009 <fd_close+0x2d>
	    || fd != fd2)
  801004:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801007:	74 0c                	je     801015 <fd_close+0x39>
		return (must_exist ? r : 0);
  801009:	84 db                	test   %bl,%bl
  80100b:	ba 00 00 00 00       	mov    $0x0,%edx
  801010:	0f 44 c2             	cmove  %edx,%eax
  801013:	eb 41                	jmp    801056 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801015:	83 ec 08             	sub    $0x8,%esp
  801018:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101b:	50                   	push   %eax
  80101c:	ff 36                	pushl  (%esi)
  80101e:	e8 61 ff ff ff       	call   800f84 <dev_lookup>
  801023:	89 c3                	mov    %eax,%ebx
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 1a                	js     801046 <fd_close+0x6a>
		if (dev->dev_close)
  80102c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80102f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801032:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801037:	85 c0                	test   %eax,%eax
  801039:	74 0b                	je     801046 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	56                   	push   %esi
  80103f:	ff d0                	call   *%eax
  801041:	89 c3                	mov    %eax,%ebx
  801043:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	56                   	push   %esi
  80104a:	6a 00                	push   $0x0
  80104c:	e8 c7 fb ff ff       	call   800c18 <sys_page_unmap>
	return r;
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	89 d8                	mov    %ebx,%eax
}
  801056:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801059:	5b                   	pop    %ebx
  80105a:	5e                   	pop    %esi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	ff 75 08             	pushl  0x8(%ebp)
  80106a:	e8 bf fe ff ff       	call   800f2e <fd_lookup>
  80106f:	89 c2                	mov    %eax,%edx
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	85 d2                	test   %edx,%edx
  801076:	78 10                	js     801088 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	6a 01                	push   $0x1
  80107d:	ff 75 f4             	pushl  -0xc(%ebp)
  801080:	e8 57 ff ff ff       	call   800fdc <fd_close>
  801085:	83 c4 10             	add    $0x10,%esp
}
  801088:	c9                   	leave  
  801089:	c3                   	ret    

0080108a <close_all>:

void
close_all(void)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	53                   	push   %ebx
  80108e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801091:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	53                   	push   %ebx
  80109a:	e8 be ff ff ff       	call   80105d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80109f:	83 c3 01             	add    $0x1,%ebx
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	83 fb 20             	cmp    $0x20,%ebx
  8010a8:	75 ec                	jne    801096 <close_all+0xc>
		close(i);
}
  8010aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 2c             	sub    $0x2c,%esp
  8010b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	e8 67 fe ff ff       	call   800f2e <fd_lookup>
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	85 d2                	test   %edx,%edx
  8010ce:	0f 88 c1 00 00 00    	js     801195 <dup+0xe6>
		return r;
	close(newfdnum);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	56                   	push   %esi
  8010d8:	e8 80 ff ff ff       	call   80105d <close>

	newfd = INDEX2FD(newfdnum);
  8010dd:	89 f3                	mov    %esi,%ebx
  8010df:	c1 e3 0c             	shl    $0xc,%ebx
  8010e2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010e8:	83 c4 04             	add    $0x4,%esp
  8010eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ee:	e8 d5 fd ff ff       	call   800ec8 <fd2data>
  8010f3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010f5:	89 1c 24             	mov    %ebx,(%esp)
  8010f8:	e8 cb fd ff ff       	call   800ec8 <fd2data>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801103:	89 f8                	mov    %edi,%eax
  801105:	c1 e8 16             	shr    $0x16,%eax
  801108:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110f:	a8 01                	test   $0x1,%al
  801111:	74 37                	je     80114a <dup+0x9b>
  801113:	89 f8                	mov    %edi,%eax
  801115:	c1 e8 0c             	shr    $0xc,%eax
  801118:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 26                	je     80114a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801124:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	25 07 0e 00 00       	and    $0xe07,%eax
  801133:	50                   	push   %eax
  801134:	ff 75 d4             	pushl  -0x2c(%ebp)
  801137:	6a 00                	push   $0x0
  801139:	57                   	push   %edi
  80113a:	6a 00                	push   $0x0
  80113c:	e8 95 fa ff ff       	call   800bd6 <sys_page_map>
  801141:	89 c7                	mov    %eax,%edi
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 2e                	js     801178 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80114d:	89 d0                	mov    %edx,%eax
  80114f:	c1 e8 0c             	shr    $0xc,%eax
  801152:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	25 07 0e 00 00       	and    $0xe07,%eax
  801161:	50                   	push   %eax
  801162:	53                   	push   %ebx
  801163:	6a 00                	push   $0x0
  801165:	52                   	push   %edx
  801166:	6a 00                	push   $0x0
  801168:	e8 69 fa ff ff       	call   800bd6 <sys_page_map>
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801172:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801174:	85 ff                	test   %edi,%edi
  801176:	79 1d                	jns    801195 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	53                   	push   %ebx
  80117c:	6a 00                	push   $0x0
  80117e:	e8 95 fa ff ff       	call   800c18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801183:	83 c4 08             	add    $0x8,%esp
  801186:	ff 75 d4             	pushl  -0x2c(%ebp)
  801189:	6a 00                	push   $0x0
  80118b:	e8 88 fa ff ff       	call   800c18 <sys_page_unmap>
	return r;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	89 f8                	mov    %edi,%eax
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 14             	sub    $0x14,%esp
  8011a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	53                   	push   %ebx
  8011ac:	e8 7d fd ff ff       	call   800f2e <fd_lookup>
  8011b1:	83 c4 08             	add    $0x8,%esp
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 6d                	js     801227 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 b9 fd ff ff       	call   800f84 <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 4c                	js     80121e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d5:	8b 42 08             	mov    0x8(%edx),%eax
  8011d8:	83 e0 03             	and    $0x3,%eax
  8011db:	83 f8 01             	cmp    $0x1,%eax
  8011de:	75 21                	jne    801201 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e5:	8b 40 48             	mov    0x48(%eax),%eax
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	50                   	push   %eax
  8011ed:	68 00 29 80 00       	push   $0x802900
  8011f2:	e8 0c f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ff:	eb 26                	jmp    801227 <read+0x8a>
	}
	if (!dev->dev_read)
  801201:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801204:	8b 40 08             	mov    0x8(%eax),%eax
  801207:	85 c0                	test   %eax,%eax
  801209:	74 17                	je     801222 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	ff 75 10             	pushl  0x10(%ebp)
  801211:	ff 75 0c             	pushl  0xc(%ebp)
  801214:	52                   	push   %edx
  801215:	ff d0                	call   *%eax
  801217:	89 c2                	mov    %eax,%edx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	eb 09                	jmp    801227 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	89 c2                	mov    %eax,%edx
  801220:	eb 05                	jmp    801227 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801222:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801227:	89 d0                	mov    %edx,%eax
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	eb 21                	jmp    801265 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	89 f0                	mov    %esi,%eax
  801249:	29 d8                	sub    %ebx,%eax
  80124b:	50                   	push   %eax
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	03 45 0c             	add    0xc(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	57                   	push   %edi
  801253:	e8 45 ff ff ff       	call   80119d <read>
		if (m < 0)
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 0c                	js     80126b <readn+0x3d>
			return m;
		if (m == 0)
  80125f:	85 c0                	test   %eax,%eax
  801261:	74 06                	je     801269 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801263:	01 c3                	add    %eax,%ebx
  801265:	39 f3                	cmp    %esi,%ebx
  801267:	72 db                	jb     801244 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801269:	89 d8                	mov    %ebx,%eax
}
  80126b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	53                   	push   %ebx
  801277:	83 ec 14             	sub    $0x14,%esp
  80127a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	53                   	push   %ebx
  801282:	e8 a7 fc ff ff       	call   800f2e <fd_lookup>
  801287:	83 c4 08             	add    $0x8,%esp
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 68                	js     8012f8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	ff 30                	pushl  (%eax)
  80129c:	e8 e3 fc ff ff       	call   800f84 <dev_lookup>
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 47                	js     8012ef <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012af:	75 21                	jne    8012d2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b6:	8b 40 48             	mov    0x48(%eax),%eax
  8012b9:	83 ec 04             	sub    $0x4,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	50                   	push   %eax
  8012be:	68 1c 29 80 00       	push   $0x80291c
  8012c3:	e8 3b ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d0:	eb 26                	jmp    8012f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d8:	85 d2                	test   %edx,%edx
  8012da:	74 17                	je     8012f3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	ff 75 10             	pushl  0x10(%ebp)
  8012e2:	ff 75 0c             	pushl  0xc(%ebp)
  8012e5:	50                   	push   %eax
  8012e6:	ff d2                	call   *%edx
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	eb 09                	jmp    8012f8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	eb 05                	jmp    8012f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012f8:	89 d0                	mov    %edx,%eax
  8012fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801305:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	ff 75 08             	pushl  0x8(%ebp)
  80130c:	e8 1d fc ff ff       	call   800f2e <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 0e                	js     801326 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801318:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80131b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801321:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	83 ec 14             	sub    $0x14,%esp
  80132f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801332:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	53                   	push   %ebx
  801337:	e8 f2 fb ff ff       	call   800f2e <fd_lookup>
  80133c:	83 c4 08             	add    $0x8,%esp
  80133f:	89 c2                	mov    %eax,%edx
  801341:	85 c0                	test   %eax,%eax
  801343:	78 65                	js     8013aa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	ff 30                	pushl  (%eax)
  801351:	e8 2e fc ff ff       	call   800f84 <dev_lookup>
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 44                	js     8013a1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801360:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801364:	75 21                	jne    801387 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801366:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136b:	8b 40 48             	mov    0x48(%eax),%eax
  80136e:	83 ec 04             	sub    $0x4,%esp
  801371:	53                   	push   %ebx
  801372:	50                   	push   %eax
  801373:	68 dc 28 80 00       	push   $0x8028dc
  801378:	e8 86 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801385:	eb 23                	jmp    8013aa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801387:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138a:	8b 52 18             	mov    0x18(%edx),%edx
  80138d:	85 d2                	test   %edx,%edx
  80138f:	74 14                	je     8013a5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	ff 75 0c             	pushl  0xc(%ebp)
  801397:	50                   	push   %eax
  801398:	ff d2                	call   *%edx
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	eb 09                	jmp    8013aa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	eb 05                	jmp    8013aa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013aa:	89 d0                	mov    %edx,%eax
  8013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 14             	sub    $0x14,%esp
  8013b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013be:	50                   	push   %eax
  8013bf:	ff 75 08             	pushl  0x8(%ebp)
  8013c2:	e8 67 fb ff ff       	call   800f2e <fd_lookup>
  8013c7:	83 c4 08             	add    $0x8,%esp
  8013ca:	89 c2                	mov    %eax,%edx
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 58                	js     801428 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013da:	ff 30                	pushl  (%eax)
  8013dc:	e8 a3 fb ff ff       	call   800f84 <dev_lookup>
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 37                	js     80141f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ef:	74 32                	je     801423 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013fb:	00 00 00 
	stat->st_isdir = 0;
  8013fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801405:	00 00 00 
	stat->st_dev = dev;
  801408:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	53                   	push   %ebx
  801412:	ff 75 f0             	pushl  -0x10(%ebp)
  801415:	ff 50 14             	call   *0x14(%eax)
  801418:	89 c2                	mov    %eax,%edx
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	eb 09                	jmp    801428 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141f:	89 c2                	mov    %eax,%edx
  801421:	eb 05                	jmp    801428 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801423:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801428:	89 d0                	mov    %edx,%eax
  80142a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	6a 00                	push   $0x0
  801439:	ff 75 08             	pushl  0x8(%ebp)
  80143c:	e8 09 02 00 00       	call   80164a <open>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 db                	test   %ebx,%ebx
  801448:	78 1b                	js     801465 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	ff 75 0c             	pushl  0xc(%ebp)
  801450:	53                   	push   %ebx
  801451:	e8 5b ff ff ff       	call   8013b1 <fstat>
  801456:	89 c6                	mov    %eax,%esi
	close(fd);
  801458:	89 1c 24             	mov    %ebx,(%esp)
  80145b:	e8 fd fb ff ff       	call   80105d <close>
	return r;
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	89 f0                	mov    %esi,%eax
}
  801465:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	56                   	push   %esi
  801470:	53                   	push   %ebx
  801471:	89 c6                	mov    %eax,%esi
  801473:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801475:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80147c:	75 12                	jne    801490 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80147e:	83 ec 0c             	sub    $0xc,%esp
  801481:	6a 01                	push   $0x1
  801483:	e8 70 0c 00 00       	call   8020f8 <ipc_find_env>
  801488:	a3 00 40 80 00       	mov    %eax,0x804000
  80148d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801490:	6a 07                	push   $0x7
  801492:	68 00 50 80 00       	push   $0x805000
  801497:	56                   	push   %esi
  801498:	ff 35 00 40 80 00    	pushl  0x804000
  80149e:	e8 01 0c 00 00       	call   8020a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014a3:	83 c4 0c             	add    $0xc,%esp
  8014a6:	6a 00                	push   $0x0
  8014a8:	53                   	push   %ebx
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 8b 0b 00 00       	call   80203b <ipc_recv>
}
  8014b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8014da:	e8 8d ff ff ff       	call   80146c <fsipc>
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8014fc:	e8 6b ff ff ff       	call   80146c <fsipc>
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80150d:	8b 45 08             	mov    0x8(%ebp),%eax
  801510:	8b 40 0c             	mov    0xc(%eax),%eax
  801513:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801518:	ba 00 00 00 00       	mov    $0x0,%edx
  80151d:	b8 05 00 00 00       	mov    $0x5,%eax
  801522:	e8 45 ff ff ff       	call   80146c <fsipc>
  801527:	89 c2                	mov    %eax,%edx
  801529:	85 d2                	test   %edx,%edx
  80152b:	78 2c                	js     801559 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	68 00 50 80 00       	push   $0x805000
  801535:	53                   	push   %ebx
  801536:	e8 4f f2 ff ff       	call   80078a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153b:	a1 80 50 80 00       	mov    0x805080,%eax
  801540:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801546:	a1 84 50 80 00       	mov    0x805084,%eax
  80154b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155c:	c9                   	leave  
  80155d:	c3                   	ret    

0080155e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	57                   	push   %edi
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	8b 40 0c             	mov    0xc(%eax),%eax
  801570:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801578:	eb 3d                	jmp    8015b7 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80157a:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801580:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801585:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	57                   	push   %edi
  80158c:	53                   	push   %ebx
  80158d:	68 08 50 80 00       	push   $0x805008
  801592:	e8 85 f3 ff ff       	call   80091c <memmove>
                fsipcbuf.write.req_n = tmp; 
  801597:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80159d:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a7:	e8 c0 fe ff ff       	call   80146c <fsipc>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 0d                	js     8015c0 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8015b3:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8015b5:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015b7:	85 f6                	test   %esi,%esi
  8015b9:	75 bf                	jne    80157a <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8015c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5f                   	pop    %edi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015db:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8015eb:	e8 7c fe ff ff       	call   80146c <fsipc>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 4b                	js     801641 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015f6:	39 c6                	cmp    %eax,%esi
  8015f8:	73 16                	jae    801610 <devfile_read+0x48>
  8015fa:	68 50 29 80 00       	push   $0x802950
  8015ff:	68 57 29 80 00       	push   $0x802957
  801604:	6a 7c                	push   $0x7c
  801606:	68 6c 29 80 00       	push   $0x80296c
  80160b:	e8 1a eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801610:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801615:	7e 16                	jle    80162d <devfile_read+0x65>
  801617:	68 77 29 80 00       	push   $0x802977
  80161c:	68 57 29 80 00       	push   $0x802957
  801621:	6a 7d                	push   $0x7d
  801623:	68 6c 29 80 00       	push   $0x80296c
  801628:	e8 fd ea ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80162d:	83 ec 04             	sub    $0x4,%esp
  801630:	50                   	push   %eax
  801631:	68 00 50 80 00       	push   $0x805000
  801636:	ff 75 0c             	pushl  0xc(%ebp)
  801639:	e8 de f2 ff ff       	call   80091c <memmove>
	return r;
  80163e:	83 c4 10             	add    $0x10,%esp
}
  801641:	89 d8                	mov    %ebx,%eax
  801643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	53                   	push   %ebx
  80164e:	83 ec 20             	sub    $0x20,%esp
  801651:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801654:	53                   	push   %ebx
  801655:	e8 f7 f0 ff ff       	call   800751 <strlen>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801662:	7f 67                	jg     8016cb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801664:	83 ec 0c             	sub    $0xc,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	e8 6f f8 ff ff       	call   800edf <fd_alloc>
  801670:	83 c4 10             	add    $0x10,%esp
		return r;
  801673:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801675:	85 c0                	test   %eax,%eax
  801677:	78 57                	js     8016d0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	53                   	push   %ebx
  80167d:	68 00 50 80 00       	push   $0x805000
  801682:	e8 03 f1 ff ff       	call   80078a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801687:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801692:	b8 01 00 00 00       	mov    $0x1,%eax
  801697:	e8 d0 fd ff ff       	call   80146c <fsipc>
  80169c:	89 c3                	mov    %eax,%ebx
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	79 14                	jns    8016b9 <open+0x6f>
		fd_close(fd, 0);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	6a 00                	push   $0x0
  8016aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ad:	e8 2a f9 ff ff       	call   800fdc <fd_close>
		return r;
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	89 da                	mov    %ebx,%edx
  8016b7:	eb 17                	jmp    8016d0 <open+0x86>
	}

	return fd2num(fd);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bf:	e8 f4 f7 ff ff       	call   800eb8 <fd2num>
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	eb 05                	jmp    8016d0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016cb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016d0:	89 d0                	mov    %edx,%eax
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e7:	e8 80 fd ff ff       	call   80146c <fsipc>
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016f4:	68 83 29 80 00       	push   $0x802983
  8016f9:	ff 75 0c             	pushl  0xc(%ebp)
  8016fc:	e8 89 f0 ff ff       	call   80078a <strcpy>
	return 0;
}
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 10             	sub    $0x10,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801712:	53                   	push   %ebx
  801713:	e8 18 0a 00 00       	call   802130 <pageref>
  801718:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80171b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801720:	83 f8 01             	cmp    $0x1,%eax
  801723:	75 10                	jne    801735 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801725:	83 ec 0c             	sub    $0xc,%esp
  801728:	ff 73 0c             	pushl  0xc(%ebx)
  80172b:	e8 ca 02 00 00       	call   8019fa <nsipc_close>
  801730:	89 c2                	mov    %eax,%edx
  801732:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801735:	89 d0                	mov    %edx,%eax
  801737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801742:	6a 00                	push   $0x0
  801744:	ff 75 10             	pushl  0x10(%ebp)
  801747:	ff 75 0c             	pushl  0xc(%ebp)
  80174a:	8b 45 08             	mov    0x8(%ebp),%eax
  80174d:	ff 70 0c             	pushl  0xc(%eax)
  801750:	e8 82 03 00 00       	call   801ad7 <nsipc_send>
}
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80175d:	6a 00                	push   $0x0
  80175f:	ff 75 10             	pushl  0x10(%ebp)
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	8b 45 08             	mov    0x8(%ebp),%eax
  801768:	ff 70 0c             	pushl  0xc(%eax)
  80176b:	e8 fb 02 00 00       	call   801a6b <nsipc_recv>
}
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801778:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80177b:	52                   	push   %edx
  80177c:	50                   	push   %eax
  80177d:	e8 ac f7 ff ff       	call   800f2e <fd_lookup>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 17                	js     8017a0 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801792:	39 08                	cmp    %ecx,(%eax)
  801794:	75 05                	jne    80179b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801796:	8b 40 0c             	mov    0xc(%eax),%eax
  801799:	eb 05                	jmp    8017a0 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80179b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 1c             	sub    $0x1c,%esp
  8017aa:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8017ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	e8 2a f7 ff ff       	call   800edf <fd_alloc>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 1b                	js     8017d9 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	68 07 04 00 00       	push   $0x407
  8017c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 c3 f3 ff ff       	call   800b93 <sys_page_alloc>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	79 10                	jns    8017e9 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	56                   	push   %esi
  8017dd:	e8 18 02 00 00       	call   8019fa <nsipc_close>
		return r;
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	89 d8                	mov    %ebx,%eax
  8017e7:	eb 24                	jmp    80180d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017e9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f7:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8017fe:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	52                   	push   %edx
  801805:	e8 ae f6 ff ff       	call   800eb8 <fd2num>
  80180a:	83 c4 10             	add    $0x10,%esp
}
  80180d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	e8 50 ff ff ff       	call   801772 <fd2sockid>
		return r;
  801822:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801824:	85 c0                	test   %eax,%eax
  801826:	78 1f                	js     801847 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801828:	83 ec 04             	sub    $0x4,%esp
  80182b:	ff 75 10             	pushl  0x10(%ebp)
  80182e:	ff 75 0c             	pushl  0xc(%ebp)
  801831:	50                   	push   %eax
  801832:	e8 1c 01 00 00       	call   801953 <nsipc_accept>
  801837:	83 c4 10             	add    $0x10,%esp
		return r;
  80183a:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 07                	js     801847 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801840:	e8 5d ff ff ff       	call   8017a2 <alloc_sockfd>
  801845:	89 c1                	mov    %eax,%ecx
}
  801847:	89 c8                	mov    %ecx,%eax
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	e8 19 ff ff ff       	call   801772 <fd2sockid>
  801859:	89 c2                	mov    %eax,%edx
  80185b:	85 d2                	test   %edx,%edx
  80185d:	78 12                	js     801871 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	ff 75 10             	pushl  0x10(%ebp)
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	52                   	push   %edx
  801869:	e8 35 01 00 00       	call   8019a3 <nsipc_bind>
  80186e:	83 c4 10             	add    $0x10,%esp
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <shutdown>:

int
shutdown(int s, int how)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	e8 f1 fe ff ff       	call   801772 <fd2sockid>
  801881:	89 c2                	mov    %eax,%edx
  801883:	85 d2                	test   %edx,%edx
  801885:	78 0f                	js     801896 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	52                   	push   %edx
  80188e:	e8 45 01 00 00       	call   8019d8 <nsipc_shutdown>
  801893:	83 c4 10             	add    $0x10,%esp
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	e8 cc fe ff ff       	call   801772 <fd2sockid>
  8018a6:	89 c2                	mov    %eax,%edx
  8018a8:	85 d2                	test   %edx,%edx
  8018aa:	78 12                	js     8018be <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	ff 75 10             	pushl  0x10(%ebp)
  8018b2:	ff 75 0c             	pushl  0xc(%ebp)
  8018b5:	52                   	push   %edx
  8018b6:	e8 59 01 00 00       	call   801a14 <nsipc_connect>
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <listen>:

int
listen(int s, int backlog)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	e8 a4 fe ff ff       	call   801772 <fd2sockid>
  8018ce:	89 c2                	mov    %eax,%edx
  8018d0:	85 d2                	test   %edx,%edx
  8018d2:	78 0f                	js     8018e3 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	52                   	push   %edx
  8018db:	e8 69 01 00 00       	call   801a49 <nsipc_listen>
  8018e0:	83 c4 10             	add    $0x10,%esp
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018eb:	ff 75 10             	pushl  0x10(%ebp)
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	ff 75 08             	pushl  0x8(%ebp)
  8018f4:	e8 3c 02 00 00       	call   801b35 <nsipc_socket>
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 d2                	test   %edx,%edx
  801900:	78 05                	js     801907 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801902:	e8 9b fe ff ff       	call   8017a2 <alloc_sockfd>
}
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	53                   	push   %ebx
  80190d:	83 ec 04             	sub    $0x4,%esp
  801910:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801912:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801919:	75 12                	jne    80192d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	6a 02                	push   $0x2
  801920:	e8 d3 07 00 00       	call   8020f8 <ipc_find_env>
  801925:	a3 04 40 80 00       	mov    %eax,0x804004
  80192a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80192d:	6a 07                	push   $0x7
  80192f:	68 00 60 80 00       	push   $0x806000
  801934:	53                   	push   %ebx
  801935:	ff 35 04 40 80 00    	pushl  0x804004
  80193b:	e8 64 07 00 00       	call   8020a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801940:	83 c4 0c             	add    $0xc,%esp
  801943:	6a 00                	push   $0x0
  801945:	6a 00                	push   $0x0
  801947:	6a 00                	push   $0x0
  801949:	e8 ed 06 00 00       	call   80203b <ipc_recv>
}
  80194e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801963:	8b 06                	mov    (%esi),%eax
  801965:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80196a:	b8 01 00 00 00       	mov    $0x1,%eax
  80196f:	e8 95 ff ff ff       	call   801909 <nsipc>
  801974:	89 c3                	mov    %eax,%ebx
  801976:	85 c0                	test   %eax,%eax
  801978:	78 20                	js     80199a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80197a:	83 ec 04             	sub    $0x4,%esp
  80197d:	ff 35 10 60 80 00    	pushl  0x806010
  801983:	68 00 60 80 00       	push   $0x806000
  801988:	ff 75 0c             	pushl  0xc(%ebp)
  80198b:	e8 8c ef ff ff       	call   80091c <memmove>
		*addrlen = ret->ret_addrlen;
  801990:	a1 10 60 80 00       	mov    0x806010,%eax
  801995:	89 06                	mov    %eax,(%esi)
  801997:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	53                   	push   %ebx
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019b5:	53                   	push   %ebx
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	68 04 60 80 00       	push   $0x806004
  8019be:	e8 59 ef ff ff       	call   80091c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019c3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ce:	e8 36 ff ff ff       	call   801909 <nsipc>
}
  8019d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8019f3:	e8 11 ff ff ff       	call   801909 <nsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <nsipc_close>:

int
nsipc_close(int s)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a08:	b8 04 00 00 00       	mov    $0x4,%eax
  801a0d:	e8 f7 fe ff ff       	call   801909 <nsipc>
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	53                   	push   %ebx
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a26:	53                   	push   %ebx
  801a27:	ff 75 0c             	pushl  0xc(%ebp)
  801a2a:	68 04 60 80 00       	push   $0x806004
  801a2f:	e8 e8 ee ff ff       	call   80091c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a34:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a3a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a3f:	e8 c5 fe ff ff       	call   801909 <nsipc>
}
  801a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a5f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a64:	e8 a0 fe ff ff       	call   801909 <nsipc>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a7b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a81:	8b 45 14             	mov    0x14(%ebp),%eax
  801a84:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a89:	b8 07 00 00 00       	mov    $0x7,%eax
  801a8e:	e8 76 fe ff ff       	call   801909 <nsipc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 35                	js     801ace <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a99:	39 f0                	cmp    %esi,%eax
  801a9b:	7f 07                	jg     801aa4 <nsipc_recv+0x39>
  801a9d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801aa2:	7e 16                	jle    801aba <nsipc_recv+0x4f>
  801aa4:	68 8f 29 80 00       	push   $0x80298f
  801aa9:	68 57 29 80 00       	push   $0x802957
  801aae:	6a 62                	push   $0x62
  801ab0:	68 a4 29 80 00       	push   $0x8029a4
  801ab5:	e8 70 e6 ff ff       	call   80012a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aba:	83 ec 04             	sub    $0x4,%esp
  801abd:	50                   	push   %eax
  801abe:	68 00 60 80 00       	push   $0x806000
  801ac3:	ff 75 0c             	pushl  0xc(%ebp)
  801ac6:	e8 51 ee ff ff       	call   80091c <memmove>
  801acb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ace:	89 d8                	mov    %ebx,%eax
  801ad0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	53                   	push   %ebx
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ae9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801aef:	7e 16                	jle    801b07 <nsipc_send+0x30>
  801af1:	68 b0 29 80 00       	push   $0x8029b0
  801af6:	68 57 29 80 00       	push   $0x802957
  801afb:	6a 6d                	push   $0x6d
  801afd:	68 a4 29 80 00       	push   $0x8029a4
  801b02:	e8 23 e6 ff ff       	call   80012a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b07:	83 ec 04             	sub    $0x4,%esp
  801b0a:	53                   	push   %ebx
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	68 0c 60 80 00       	push   $0x80600c
  801b13:	e8 04 ee ff ff       	call   80091c <memmove>
	nsipcbuf.send.req_size = size;
  801b18:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b21:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b26:	b8 08 00 00 00       	mov    $0x8,%eax
  801b2b:	e8 d9 fd ff ff       	call   801909 <nsipc>
}
  801b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b46:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b53:	b8 09 00 00 00       	mov    $0x9,%eax
  801b58:	e8 ac fd ff ff       	call   801909 <nsipc>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 08             	pushl  0x8(%ebp)
  801b6d:	e8 56 f3 ff ff       	call   800ec8 <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b74:	83 c4 08             	add    $0x8,%esp
  801b77:	68 bc 29 80 00       	push   $0x8029bc
  801b7c:	53                   	push   %ebx
  801b7d:	e8 08 ec ff ff       	call   80078a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b82:	8b 56 04             	mov    0x4(%esi),%edx
  801b85:	89 d0                	mov    %edx,%eax
  801b87:	2b 06                	sub    (%esi),%eax
  801b89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b96:	00 00 00 
	stat->st_dev = &devpipe;
  801b99:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ba0:	30 80 00 
	return 0;
}
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb9:	53                   	push   %ebx
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 57 f0 ff ff       	call   800c18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc1:	89 1c 24             	mov    %ebx,(%esp)
  801bc4:	e8 ff f2 ff ff       	call   800ec8 <fd2data>
  801bc9:	83 c4 08             	add    $0x8,%esp
  801bcc:	50                   	push   %eax
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 44 f0 ff ff       	call   800c18 <sys_page_unmap>
}
  801bd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	57                   	push   %edi
  801bdd:	56                   	push   %esi
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 1c             	sub    $0x1c,%esp
  801be2:	89 c6                	mov    %eax,%esi
  801be4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be7:	a1 08 40 80 00       	mov    0x804008,%eax
  801bec:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	56                   	push   %esi
  801bf3:	e8 38 05 00 00       	call   802130 <pageref>
  801bf8:	89 c7                	mov    %eax,%edi
  801bfa:	83 c4 04             	add    $0x4,%esp
  801bfd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c00:	e8 2b 05 00 00       	call   802130 <pageref>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	39 c7                	cmp    %eax,%edi
  801c0a:	0f 94 c2             	sete   %dl
  801c0d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c10:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801c16:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c19:	39 fb                	cmp    %edi,%ebx
  801c1b:	74 19                	je     801c36 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801c1d:	84 d2                	test   %dl,%dl
  801c1f:	74 c6                	je     801be7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c21:	8b 51 58             	mov    0x58(%ecx),%edx
  801c24:	50                   	push   %eax
  801c25:	52                   	push   %edx
  801c26:	53                   	push   %ebx
  801c27:	68 c3 29 80 00       	push   $0x8029c3
  801c2c:	e8 d2 e5 ff ff       	call   800203 <cprintf>
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	eb b1                	jmp    801be7 <_pipeisclosed+0xe>
	}
}
  801c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 28             	sub    $0x28,%esp
  801c47:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c4a:	56                   	push   %esi
  801c4b:	e8 78 f2 ff ff       	call   800ec8 <fd2data>
  801c50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	bf 00 00 00 00       	mov    $0x0,%edi
  801c5a:	eb 4b                	jmp    801ca7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c5c:	89 da                	mov    %ebx,%edx
  801c5e:	89 f0                	mov    %esi,%eax
  801c60:	e8 74 ff ff ff       	call   801bd9 <_pipeisclosed>
  801c65:	85 c0                	test   %eax,%eax
  801c67:	75 48                	jne    801cb1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c69:	e8 06 ef ff ff       	call   800b74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c6e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c71:	8b 0b                	mov    (%ebx),%ecx
  801c73:	8d 51 20             	lea    0x20(%ecx),%edx
  801c76:	39 d0                	cmp    %edx,%eax
  801c78:	73 e2                	jae    801c5c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c81:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c84:	89 c2                	mov    %eax,%edx
  801c86:	c1 fa 1f             	sar    $0x1f,%edx
  801c89:	89 d1                	mov    %edx,%ecx
  801c8b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c8e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c91:	83 e2 1f             	and    $0x1f,%edx
  801c94:	29 ca                	sub    %ecx,%edx
  801c96:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c9a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c9e:	83 c0 01             	add    $0x1,%eax
  801ca1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca4:	83 c7 01             	add    $0x1,%edi
  801ca7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801caa:	75 c2                	jne    801c6e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cac:	8b 45 10             	mov    0x10(%ebp),%eax
  801caf:	eb 05                	jmp    801cb6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 18             	sub    $0x18,%esp
  801cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cca:	57                   	push   %edi
  801ccb:	e8 f8 f1 ff ff       	call   800ec8 <fd2data>
  801cd0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cda:	eb 3d                	jmp    801d19 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cdc:	85 db                	test   %ebx,%ebx
  801cde:	74 04                	je     801ce4 <devpipe_read+0x26>
				return i;
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	eb 44                	jmp    801d28 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ce4:	89 f2                	mov    %esi,%edx
  801ce6:	89 f8                	mov    %edi,%eax
  801ce8:	e8 ec fe ff ff       	call   801bd9 <_pipeisclosed>
  801ced:	85 c0                	test   %eax,%eax
  801cef:	75 32                	jne    801d23 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cf1:	e8 7e ee ff ff       	call   800b74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cf6:	8b 06                	mov    (%esi),%eax
  801cf8:	3b 46 04             	cmp    0x4(%esi),%eax
  801cfb:	74 df                	je     801cdc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cfd:	99                   	cltd   
  801cfe:	c1 ea 1b             	shr    $0x1b,%edx
  801d01:	01 d0                	add    %edx,%eax
  801d03:	83 e0 1f             	and    $0x1f,%eax
  801d06:	29 d0                	sub    %edx,%eax
  801d08:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d10:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d13:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d16:	83 c3 01             	add    $0x1,%ebx
  801d19:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d1c:	75 d8                	jne    801cf6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d21:	eb 05                	jmp    801d28 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	56                   	push   %esi
  801d34:	53                   	push   %ebx
  801d35:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	e8 9e f1 ff ff       	call   800edf <fd_alloc>
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	85 c0                	test   %eax,%eax
  801d48:	0f 88 2c 01 00 00    	js     801e7a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	68 07 04 00 00       	push   $0x407
  801d56:	ff 75 f4             	pushl  -0xc(%ebp)
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 33 ee ff ff       	call   800b93 <sys_page_alloc>
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	89 c2                	mov    %eax,%edx
  801d65:	85 c0                	test   %eax,%eax
  801d67:	0f 88 0d 01 00 00    	js     801e7a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	e8 66 f1 ff ff       	call   800edf <fd_alloc>
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	0f 88 e2 00 00 00    	js     801e68 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d86:	83 ec 04             	sub    $0x4,%esp
  801d89:	68 07 04 00 00       	push   $0x407
  801d8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d91:	6a 00                	push   $0x0
  801d93:	e8 fb ed ff ff       	call   800b93 <sys_page_alloc>
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	0f 88 c3 00 00 00    	js     801e68 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801da5:	83 ec 0c             	sub    $0xc,%esp
  801da8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dab:	e8 18 f1 ff ff       	call   800ec8 <fd2data>
  801db0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db2:	83 c4 0c             	add    $0xc,%esp
  801db5:	68 07 04 00 00       	push   $0x407
  801dba:	50                   	push   %eax
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 d1 ed ff ff       	call   800b93 <sys_page_alloc>
  801dc2:	89 c3                	mov    %eax,%ebx
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	0f 88 89 00 00 00    	js     801e58 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd5:	e8 ee f0 ff ff       	call   800ec8 <fd2data>
  801dda:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801de1:	50                   	push   %eax
  801de2:	6a 00                	push   $0x0
  801de4:	56                   	push   %esi
  801de5:	6a 00                	push   $0x0
  801de7:	e8 ea ed ff ff       	call   800bd6 <sys_page_map>
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	83 c4 20             	add    $0x20,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 55                	js     801e4a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801df5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	ff 75 f4             	pushl  -0xc(%ebp)
  801e25:	e8 8e f0 ff ff       	call   800eb8 <fd2num>
  801e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e2d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e2f:	83 c4 04             	add    $0x4,%esp
  801e32:	ff 75 f0             	pushl  -0x10(%ebp)
  801e35:	e8 7e f0 ff ff       	call   800eb8 <fd2num>
  801e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	ba 00 00 00 00       	mov    $0x0,%edx
  801e48:	eb 30                	jmp    801e7a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e4a:	83 ec 08             	sub    $0x8,%esp
  801e4d:	56                   	push   %esi
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 c3 ed ff ff       	call   800c18 <sys_page_unmap>
  801e55:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e58:	83 ec 08             	sub    $0x8,%esp
  801e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 b3 ed ff ff       	call   800c18 <sys_page_unmap>
  801e65:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 a3 ed ff ff       	call   800c18 <sys_page_unmap>
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e7a:	89 d0                	mov    %edx,%eax
  801e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	ff 75 08             	pushl  0x8(%ebp)
  801e90:	e8 99 f0 ff ff       	call   800f2e <fd_lookup>
  801e95:	89 c2                	mov    %eax,%edx
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 d2                	test   %edx,%edx
  801e9c:	78 18                	js     801eb6 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea4:	e8 1f f0 ff ff       	call   800ec8 <fd2data>
	return _pipeisclosed(fd, p);
  801ea9:	89 c2                	mov    %eax,%edx
  801eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eae:	e8 26 fd ff ff       	call   801bd9 <_pipeisclosed>
  801eb3:	83 c4 10             	add    $0x10,%esp
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ec8:	68 db 29 80 00       	push   $0x8029db
  801ecd:	ff 75 0c             	pushl  0xc(%ebp)
  801ed0:	e8 b5 e8 ff ff       	call   80078a <strcpy>
	return 0;
}
  801ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	57                   	push   %edi
  801ee0:	56                   	push   %esi
  801ee1:	53                   	push   %ebx
  801ee2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef3:	eb 2d                	jmp    801f22 <devcons_write+0x46>
		m = n - tot;
  801ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801efa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801efd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f02:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f05:	83 ec 04             	sub    $0x4,%esp
  801f08:	53                   	push   %ebx
  801f09:	03 45 0c             	add    0xc(%ebp),%eax
  801f0c:	50                   	push   %eax
  801f0d:	57                   	push   %edi
  801f0e:	e8 09 ea ff ff       	call   80091c <memmove>
		sys_cputs(buf, m);
  801f13:	83 c4 08             	add    $0x8,%esp
  801f16:	53                   	push   %ebx
  801f17:	57                   	push   %edi
  801f18:	e8 ba eb ff ff       	call   800ad7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1d:	01 de                	add    %ebx,%esi
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	89 f0                	mov    %esi,%eax
  801f24:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f27:	72 cc                	jb     801ef5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5f                   	pop    %edi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f40:	75 07                	jne    801f49 <devcons_read+0x18>
  801f42:	eb 28                	jmp    801f6c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f44:	e8 2b ec ff ff       	call   800b74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f49:	e8 a7 eb ff ff       	call   800af5 <sys_cgetc>
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	74 f2                	je     801f44 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 16                	js     801f6c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f56:	83 f8 04             	cmp    $0x4,%eax
  801f59:	74 0c                	je     801f67 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5e:	88 02                	mov    %al,(%edx)
	return 1;
  801f60:	b8 01 00 00 00       	mov    $0x1,%eax
  801f65:	eb 05                	jmp    801f6c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f74:	8b 45 08             	mov    0x8(%ebp),%eax
  801f77:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f7a:	6a 01                	push   $0x1
  801f7c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7f:	50                   	push   %eax
  801f80:	e8 52 eb ff ff       	call   800ad7 <sys_cputs>
  801f85:	83 c4 10             	add    $0x10,%esp
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <getchar>:

int
getchar(void)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f90:	6a 01                	push   $0x1
  801f92:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	6a 00                	push   $0x0
  801f98:	e8 00 f2 ff ff       	call   80119d <read>
	if (r < 0)
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 0f                	js     801fb3 <getchar+0x29>
		return r;
	if (r < 1)
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	7e 06                	jle    801fae <getchar+0x24>
		return -E_EOF;
	return c;
  801fa8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fac:	eb 05                	jmp    801fb3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbe:	50                   	push   %eax
  801fbf:	ff 75 08             	pushl  0x8(%ebp)
  801fc2:	e8 67 ef ff ff       	call   800f2e <fd_lookup>
  801fc7:	83 c4 10             	add    $0x10,%esp
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 11                	js     801fdf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fd7:	39 10                	cmp    %edx,(%eax)
  801fd9:	0f 94 c0             	sete   %al
  801fdc:	0f b6 c0             	movzbl %al,%eax
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <opencons>:

int
opencons(void)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fea:	50                   	push   %eax
  801feb:	e8 ef ee ff ff       	call   800edf <fd_alloc>
  801ff0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	78 3e                	js     802037 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff9:	83 ec 04             	sub    $0x4,%esp
  801ffc:	68 07 04 00 00       	push   $0x407
  802001:	ff 75 f4             	pushl  -0xc(%ebp)
  802004:	6a 00                	push   $0x0
  802006:	e8 88 eb ff ff       	call   800b93 <sys_page_alloc>
  80200b:	83 c4 10             	add    $0x10,%esp
		return r;
  80200e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802010:	85 c0                	test   %eax,%eax
  802012:	78 23                	js     802037 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802014:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80201f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802022:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	50                   	push   %eax
  80202d:	e8 86 ee ff ff       	call   800eb8 <fd2num>
  802032:	89 c2                	mov    %eax,%edx
  802034:	83 c4 10             	add    $0x10,%esp
}
  802037:	89 d0                	mov    %edx,%eax
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	56                   	push   %esi
  80203f:	53                   	push   %ebx
  802040:	8b 75 08             	mov    0x8(%ebp),%esi
  802043:	8b 45 0c             	mov    0xc(%ebp),%eax
  802046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802049:	85 c0                	test   %eax,%eax
  80204b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802050:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802053:	83 ec 0c             	sub    $0xc,%esp
  802056:	50                   	push   %eax
  802057:	e8 e7 ec ff ff       	call   800d43 <sys_ipc_recv>
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 16                	jns    802079 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802063:	85 f6                	test   %esi,%esi
  802065:	74 06                	je     80206d <ipc_recv+0x32>
  802067:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80206d:	85 db                	test   %ebx,%ebx
  80206f:	74 2c                	je     80209d <ipc_recv+0x62>
  802071:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802077:	eb 24                	jmp    80209d <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802079:	85 f6                	test   %esi,%esi
  80207b:	74 0a                	je     802087 <ipc_recv+0x4c>
  80207d:	a1 08 40 80 00       	mov    0x804008,%eax
  802082:	8b 40 74             	mov    0x74(%eax),%eax
  802085:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802087:	85 db                	test   %ebx,%ebx
  802089:	74 0a                	je     802095 <ipc_recv+0x5a>
  80208b:	a1 08 40 80 00       	mov    0x804008,%eax
  802090:	8b 40 78             	mov    0x78(%eax),%eax
  802093:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802095:	a1 08 40 80 00       	mov    0x804008,%eax
  80209a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80209d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a0:	5b                   	pop    %ebx
  8020a1:	5e                   	pop    %esi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	57                   	push   %edi
  8020a8:	56                   	push   %esi
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8020b6:	85 db                	test   %ebx,%ebx
  8020b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020bd:	0f 44 d8             	cmove  %eax,%ebx
  8020c0:	eb 1c                	jmp    8020de <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8020c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c5:	74 12                	je     8020d9 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8020c7:	50                   	push   %eax
  8020c8:	68 e7 29 80 00       	push   $0x8029e7
  8020cd:	6a 39                	push   $0x39
  8020cf:	68 02 2a 80 00       	push   $0x802a02
  8020d4:	e8 51 e0 ff ff       	call   80012a <_panic>
                 sys_yield();
  8020d9:	e8 96 ea ff ff       	call   800b74 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020de:	ff 75 14             	pushl  0x14(%ebp)
  8020e1:	53                   	push   %ebx
  8020e2:	56                   	push   %esi
  8020e3:	57                   	push   %edi
  8020e4:	e8 37 ec ff ff       	call   800d20 <sys_ipc_try_send>
  8020e9:	83 c4 10             	add    $0x10,%esp
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	78 d2                	js     8020c2 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8020f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802103:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802106:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80210c:	8b 52 50             	mov    0x50(%edx),%edx
  80210f:	39 ca                	cmp    %ecx,%edx
  802111:	75 0d                	jne    802120 <ipc_find_env+0x28>
			return envs[i].env_id;
  802113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802116:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80211b:	8b 40 08             	mov    0x8(%eax),%eax
  80211e:	eb 0e                	jmp    80212e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802120:	83 c0 01             	add    $0x1,%eax
  802123:	3d 00 04 00 00       	cmp    $0x400,%eax
  802128:	75 d9                	jne    802103 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80212a:	66 b8 00 00          	mov    $0x0,%ax
}
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802136:	89 d0                	mov    %edx,%eax
  802138:	c1 e8 16             	shr    $0x16,%eax
  80213b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802142:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802147:	f6 c1 01             	test   $0x1,%cl
  80214a:	74 1d                	je     802169 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214c:	c1 ea 0c             	shr    $0xc,%edx
  80214f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802156:	f6 c2 01             	test   $0x1,%dl
  802159:	74 0e                	je     802169 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215b:	c1 ea 0c             	shr    $0xc,%edx
  80215e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802165:	ef 
  802166:	0f b7 c0             	movzwl %ax,%eax
}
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    
  80216b:	66 90                	xchg   %ax,%ax
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	83 ec 10             	sub    $0x10,%esp
  802176:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80217a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80217e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802182:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802186:	85 d2                	test   %edx,%edx
  802188:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80218c:	89 34 24             	mov    %esi,(%esp)
  80218f:	89 c8                	mov    %ecx,%eax
  802191:	75 35                	jne    8021c8 <__udivdi3+0x58>
  802193:	39 f1                	cmp    %esi,%ecx
  802195:	0f 87 bd 00 00 00    	ja     802258 <__udivdi3+0xe8>
  80219b:	85 c9                	test   %ecx,%ecx
  80219d:	89 cd                	mov    %ecx,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f1                	div    %ecx
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 f0                	mov    %esi,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c6                	mov    %eax,%esi
  8021b4:	89 f8                	mov    %edi,%eax
  8021b6:	f7 f5                	div    %ebp
  8021b8:	89 f2                	mov    %esi,%edx
  8021ba:	83 c4 10             	add    $0x10,%esp
  8021bd:	5e                   	pop    %esi
  8021be:	5f                   	pop    %edi
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    
  8021c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	3b 14 24             	cmp    (%esp),%edx
  8021cb:	77 7b                	ja     802248 <__udivdi3+0xd8>
  8021cd:	0f bd f2             	bsr    %edx,%esi
  8021d0:	83 f6 1f             	xor    $0x1f,%esi
  8021d3:	0f 84 97 00 00 00    	je     802270 <__udivdi3+0x100>
  8021d9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021de:	89 d7                	mov    %edx,%edi
  8021e0:	89 f1                	mov    %esi,%ecx
  8021e2:	29 f5                	sub    %esi,%ebp
  8021e4:	d3 e7                	shl    %cl,%edi
  8021e6:	89 c2                	mov    %eax,%edx
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	d3 ea                	shr    %cl,%edx
  8021ec:	89 f1                	mov    %esi,%ecx
  8021ee:	09 fa                	or     %edi,%edx
  8021f0:	8b 3c 24             	mov    (%esp),%edi
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802203:	89 fa                	mov    %edi,%edx
  802205:	d3 ea                	shr    %cl,%edx
  802207:	89 f1                	mov    %esi,%ecx
  802209:	d3 e7                	shl    %cl,%edi
  80220b:	89 e9                	mov    %ebp,%ecx
  80220d:	d3 e8                	shr    %cl,%eax
  80220f:	09 c7                	or     %eax,%edi
  802211:	89 f8                	mov    %edi,%eax
  802213:	f7 74 24 08          	divl   0x8(%esp)
  802217:	89 d5                	mov    %edx,%ebp
  802219:	89 c7                	mov    %eax,%edi
  80221b:	f7 64 24 0c          	mull   0xc(%esp)
  80221f:	39 d5                	cmp    %edx,%ebp
  802221:	89 14 24             	mov    %edx,(%esp)
  802224:	72 11                	jb     802237 <__udivdi3+0xc7>
  802226:	8b 54 24 04          	mov    0x4(%esp),%edx
  80222a:	89 f1                	mov    %esi,%ecx
  80222c:	d3 e2                	shl    %cl,%edx
  80222e:	39 c2                	cmp    %eax,%edx
  802230:	73 5e                	jae    802290 <__udivdi3+0x120>
  802232:	3b 2c 24             	cmp    (%esp),%ebp
  802235:	75 59                	jne    802290 <__udivdi3+0x120>
  802237:	8d 47 ff             	lea    -0x1(%edi),%eax
  80223a:	31 f6                	xor    %esi,%esi
  80223c:	89 f2                	mov    %esi,%edx
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    
  802245:	8d 76 00             	lea    0x0(%esi),%esi
  802248:	31 f6                	xor    %esi,%esi
  80224a:	31 c0                	xor    %eax,%eax
  80224c:	89 f2                	mov    %esi,%edx
  80224e:	83 c4 10             	add    $0x10,%esp
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	89 f2                	mov    %esi,%edx
  80225a:	31 f6                	xor    %esi,%esi
  80225c:	89 f8                	mov    %edi,%eax
  80225e:	f7 f1                	div    %ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802274:	76 0b                	jbe    802281 <__udivdi3+0x111>
  802276:	31 c0                	xor    %eax,%eax
  802278:	3b 14 24             	cmp    (%esp),%edx
  80227b:	0f 83 37 ff ff ff    	jae    8021b8 <__udivdi3+0x48>
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	e9 2d ff ff ff       	jmp    8021b8 <__udivdi3+0x48>
  80228b:	90                   	nop
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 f8                	mov    %edi,%eax
  802292:	31 f6                	xor    %esi,%esi
  802294:	e9 1f ff ff ff       	jmp    8021b8 <__udivdi3+0x48>
  802299:	66 90                	xchg   %ax,%ax
  80229b:	66 90                	xchg   %ax,%ax
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	83 ec 20             	sub    $0x20,%esp
  8022a6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8022aa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b2:	89 c6                	mov    %eax,%esi
  8022b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022b8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8022c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022c8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	89 c2                	mov    %eax,%edx
  8022d0:	75 1e                	jne    8022f0 <__umoddi3+0x50>
  8022d2:	39 f7                	cmp    %esi,%edi
  8022d4:	76 52                	jbe    802328 <__umoddi3+0x88>
  8022d6:	89 c8                	mov    %ecx,%eax
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	f7 f7                	div    %edi
  8022dc:	89 d0                	mov    %edx,%eax
  8022de:	31 d2                	xor    %edx,%edx
  8022e0:	83 c4 20             	add    $0x20,%esp
  8022e3:	5e                   	pop    %esi
  8022e4:	5f                   	pop    %edi
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    
  8022e7:	89 f6                	mov    %esi,%esi
  8022e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022f0:	39 f0                	cmp    %esi,%eax
  8022f2:	77 5c                	ja     802350 <__umoddi3+0xb0>
  8022f4:	0f bd e8             	bsr    %eax,%ebp
  8022f7:	83 f5 1f             	xor    $0x1f,%ebp
  8022fa:	75 64                	jne    802360 <__umoddi3+0xc0>
  8022fc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802300:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802304:	0f 86 f6 00 00 00    	jbe    802400 <__umoddi3+0x160>
  80230a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80230e:	0f 82 ec 00 00 00    	jb     802400 <__umoddi3+0x160>
  802314:	8b 44 24 14          	mov    0x14(%esp),%eax
  802318:	8b 54 24 18          	mov    0x18(%esp),%edx
  80231c:	83 c4 20             	add    $0x20,%esp
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    
  802323:	90                   	nop
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	85 ff                	test   %edi,%edi
  80232a:	89 fd                	mov    %edi,%ebp
  80232c:	75 0b                	jne    802339 <__umoddi3+0x99>
  80232e:	b8 01 00 00 00       	mov    $0x1,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f7                	div    %edi
  802337:	89 c5                	mov    %eax,%ebp
  802339:	8b 44 24 10          	mov    0x10(%esp),%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	f7 f5                	div    %ebp
  802341:	89 c8                	mov    %ecx,%eax
  802343:	f7 f5                	div    %ebp
  802345:	eb 95                	jmp    8022dc <__umoddi3+0x3c>
  802347:	89 f6                	mov    %esi,%esi
  802349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 20             	add    $0x20,%esp
  802357:	5e                   	pop    %esi
  802358:	5f                   	pop    %edi
  802359:	5d                   	pop    %ebp
  80235a:	c3                   	ret    
  80235b:	90                   	nop
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	b8 20 00 00 00       	mov    $0x20,%eax
  802365:	89 e9                	mov    %ebp,%ecx
  802367:	29 e8                	sub    %ebp,%eax
  802369:	d3 e2                	shl    %cl,%edx
  80236b:	89 c7                	mov    %eax,%edi
  80236d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802371:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802375:	89 f9                	mov    %edi,%ecx
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 c1                	mov    %eax,%ecx
  80237b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80237f:	09 d1                	or     %edx,%ecx
  802381:	89 fa                	mov    %edi,%edx
  802383:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802387:	89 e9                	mov    %ebp,%ecx
  802389:	d3 e0                	shl    %cl,%eax
  80238b:	89 f9                	mov    %edi,%ecx
  80238d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802391:	89 f0                	mov    %esi,%eax
  802393:	d3 e8                	shr    %cl,%eax
  802395:	89 e9                	mov    %ebp,%ecx
  802397:	89 c7                	mov    %eax,%edi
  802399:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80239d:	d3 e6                	shl    %cl,%esi
  80239f:	89 d1                	mov    %edx,%ecx
  8023a1:	89 fa                	mov    %edi,%edx
  8023a3:	d3 e8                	shr    %cl,%eax
  8023a5:	89 e9                	mov    %ebp,%ecx
  8023a7:	09 f0                	or     %esi,%eax
  8023a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8023ad:	f7 74 24 10          	divl   0x10(%esp)
  8023b1:	d3 e6                	shl    %cl,%esi
  8023b3:	89 d1                	mov    %edx,%ecx
  8023b5:	f7 64 24 0c          	mull   0xc(%esp)
  8023b9:	39 d1                	cmp    %edx,%ecx
  8023bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8023bf:	89 d7                	mov    %edx,%edi
  8023c1:	89 c6                	mov    %eax,%esi
  8023c3:	72 0a                	jb     8023cf <__umoddi3+0x12f>
  8023c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8023c9:	73 10                	jae    8023db <__umoddi3+0x13b>
  8023cb:	39 d1                	cmp    %edx,%ecx
  8023cd:	75 0c                	jne    8023db <__umoddi3+0x13b>
  8023cf:	89 d7                	mov    %edx,%edi
  8023d1:	89 c6                	mov    %eax,%esi
  8023d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8023d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8023db:	89 ca                	mov    %ecx,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e3:	29 f0                	sub    %esi,%eax
  8023e5:	19 fa                	sbb    %edi,%edx
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8023ee:	89 d7                	mov    %edx,%edi
  8023f0:	d3 e7                	shl    %cl,%edi
  8023f2:	89 e9                	mov    %ebp,%ecx
  8023f4:	09 f8                	or     %edi,%eax
  8023f6:	d3 ea                	shr    %cl,%edx
  8023f8:	83 c4 20             	add    $0x20,%esp
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    
  8023ff:	90                   	nop
  802400:	8b 74 24 10          	mov    0x10(%esp),%esi
  802404:	29 f9                	sub    %edi,%ecx
  802406:	19 c6                	sbb    %eax,%esi
  802408:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80240c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802410:	e9 ff fe ff ff       	jmp    802314 <__umoddi3+0x74>
