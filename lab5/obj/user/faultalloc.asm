
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
  800040:	68 40 1f 80 00       	push   $0x801f40
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
  80006a:	68 60 1f 80 00       	push   $0x801f60
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 1f 80 00       	push   $0x801f4a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 1f 80 00       	push   $0x801f8c
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
  80009c:	e8 e3 0c 00 00       	call   800d84 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 1f 80 00       	push   $0x801f5c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 1f 80 00       	push   $0x801f5c
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
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800116:	e8 c9 0e 00 00       	call   800fe4 <close_all>
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
  800148:	68 b8 1f 80 00       	push   $0x801fb8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 97 24 80 00 	movl   $0x802497,(%esp)
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
  800266:	e8 f5 19 00 00       	call   801c60 <__udivdi3>
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
  8002a4:	e8 e7 1a 00 00       	call   801d90 <__umoddi3>
  8002a9:	83 c4 14             	add    $0x14,%esp
  8002ac:	0f be 80 db 1f 80 00 	movsbl 0x801fdb(%eax),%eax
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
  8003a8:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
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
  80046c:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  800473:	85 d2                	test   %edx,%edx
  800475:	75 18                	jne    80048f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800477:	50                   	push   %eax
  800478:	68 f3 1f 80 00       	push   $0x801ff3
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
  800490:	68 65 24 80 00       	push   $0x802465
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
  8004bd:	ba ec 1f 80 00       	mov    $0x801fec,%edx
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
  800b3c:	68 1f 23 80 00       	push   $0x80231f
  800b41:	6a 23                	push   $0x23
  800b43:	68 3c 23 80 00       	push   $0x80233c
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
  800bbd:	68 1f 23 80 00       	push   $0x80231f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 3c 23 80 00       	push   $0x80233c
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
  800bff:	68 1f 23 80 00       	push   $0x80231f
  800c04:	6a 23                	push   $0x23
  800c06:	68 3c 23 80 00       	push   $0x80233c
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
  800c41:	68 1f 23 80 00       	push   $0x80231f
  800c46:	6a 23                	push   $0x23
  800c48:	68 3c 23 80 00       	push   $0x80233c
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
  800c83:	68 1f 23 80 00       	push   $0x80231f
  800c88:	6a 23                	push   $0x23
  800c8a:	68 3c 23 80 00       	push   $0x80233c
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
  800cc5:	68 1f 23 80 00       	push   $0x80231f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 3c 23 80 00       	push   $0x80233c
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
  800d07:	68 1f 23 80 00       	push   $0x80231f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 3c 23 80 00       	push   $0x80233c
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
  800d6b:	68 1f 23 80 00       	push   $0x80231f
  800d70:	6a 23                	push   $0x23
  800d72:	68 3c 23 80 00       	push   $0x80233c
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

00800d84 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d8a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d91:	75 2c                	jne    800dbf <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	6a 07                	push   $0x7
  800d98:	68 00 f0 bf ee       	push   $0xeebff000
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 ef fd ff ff       	call   800b93 <sys_page_alloc>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	74 14                	je     800dbf <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	68 4c 23 80 00       	push   $0x80234c
  800db3:	6a 21                	push   $0x21
  800db5:	68 ae 23 80 00       	push   $0x8023ae
  800dba:	e8 6b f3 ff ff       	call   80012a <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	a3 08 40 80 00       	mov    %eax,0x804008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800dc7:	83 ec 08             	sub    $0x8,%esp
  800dca:	68 f3 0d 80 00       	push   $0x800df3
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 08 ff ff ff       	call   800cde <sys_env_set_pgfault_upcall>
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	79 14                	jns    800df1 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800ddd:	83 ec 04             	sub    $0x4,%esp
  800de0:	68 78 23 80 00       	push   $0x802378
  800de5:	6a 29                	push   $0x29
  800de7:	68 ae 23 80 00       	push   $0x8023ae
  800dec:	e8 39 f3 ff ff       	call   80012a <_panic>
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800df3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800df4:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800df9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dfb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800dfe:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800e03:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800e07:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800e0b:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800e0d:	83 c4 08             	add    $0x8,%esp
        popal
  800e10:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800e11:	83 c4 04             	add    $0x4,%esp
        popfl
  800e14:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800e15:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e16:	c3                   	ret    

00800e17 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e22:	c1 e8 0c             	shr    $0xc,%eax
}
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e37:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e44:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e49:	89 c2                	mov    %eax,%edx
  800e4b:	c1 ea 16             	shr    $0x16,%edx
  800e4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e55:	f6 c2 01             	test   $0x1,%dl
  800e58:	74 11                	je     800e6b <fd_alloc+0x2d>
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	c1 ea 0c             	shr    $0xc,%edx
  800e5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e66:	f6 c2 01             	test   $0x1,%dl
  800e69:	75 09                	jne    800e74 <fd_alloc+0x36>
			*fd_store = fd;
  800e6b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e72:	eb 17                	jmp    800e8b <fd_alloc+0x4d>
  800e74:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e79:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e7e:	75 c9                	jne    800e49 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e80:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e86:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e93:	83 f8 1f             	cmp    $0x1f,%eax
  800e96:	77 36                	ja     800ece <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e98:	c1 e0 0c             	shl    $0xc,%eax
  800e9b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea0:	89 c2                	mov    %eax,%edx
  800ea2:	c1 ea 16             	shr    $0x16,%edx
  800ea5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eac:	f6 c2 01             	test   $0x1,%dl
  800eaf:	74 24                	je     800ed5 <fd_lookup+0x48>
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	c1 ea 0c             	shr    $0xc,%edx
  800eb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebd:	f6 c2 01             	test   $0x1,%dl
  800ec0:	74 1a                	je     800edc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec5:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecc:	eb 13                	jmp    800ee1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ece:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed3:	eb 0c                	jmp    800ee1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eda:	eb 05                	jmp    800ee1 <fd_lookup+0x54>
  800edc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eec:	ba 3c 24 80 00       	mov    $0x80243c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ef1:	eb 13                	jmp    800f06 <dev_lookup+0x23>
  800ef3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ef6:	39 08                	cmp    %ecx,(%eax)
  800ef8:	75 0c                	jne    800f06 <dev_lookup+0x23>
			*dev = devtab[i];
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eff:	b8 00 00 00 00       	mov    $0x0,%eax
  800f04:	eb 2e                	jmp    800f34 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f06:	8b 02                	mov    (%edx),%eax
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	75 e7                	jne    800ef3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f0c:	a1 04 40 80 00       	mov    0x804004,%eax
  800f11:	8b 40 48             	mov    0x48(%eax),%eax
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	51                   	push   %ecx
  800f18:	50                   	push   %eax
  800f19:	68 bc 23 80 00       	push   $0x8023bc
  800f1e:	e8 e0 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 10             	sub    $0x10,%esp
  800f3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f47:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f48:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f4e:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f51:	50                   	push   %eax
  800f52:	e8 36 ff ff ff       	call   800e8d <fd_lookup>
  800f57:	83 c4 08             	add    $0x8,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 05                	js     800f63 <fd_close+0x2d>
	    || fd != fd2)
  800f5e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f61:	74 0c                	je     800f6f <fd_close+0x39>
		return (must_exist ? r : 0);
  800f63:	84 db                	test   %bl,%bl
  800f65:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6a:	0f 44 c2             	cmove  %edx,%eax
  800f6d:	eb 41                	jmp    800fb0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	ff 36                	pushl  (%esi)
  800f78:	e8 66 ff ff ff       	call   800ee3 <dev_lookup>
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	78 1a                	js     800fa0 <fd_close+0x6a>
		if (dev->dev_close)
  800f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f89:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f8c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	74 0b                	je     800fa0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	56                   	push   %esi
  800f99:	ff d0                	call   *%eax
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	56                   	push   %esi
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 6d fc ff ff       	call   800c18 <sys_page_unmap>
	return r;
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	89 d8                	mov    %ebx,%eax
}
  800fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb3:	5b                   	pop    %ebx
  800fb4:	5e                   	pop    %esi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 75 08             	pushl  0x8(%ebp)
  800fc4:	e8 c4 fe ff ff       	call   800e8d <fd_lookup>
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	85 d2                	test   %edx,%edx
  800fd0:	78 10                	js     800fe2 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fd2:	83 ec 08             	sub    $0x8,%esp
  800fd5:	6a 01                	push   $0x1
  800fd7:	ff 75 f4             	pushl  -0xc(%ebp)
  800fda:	e8 57 ff ff ff       	call   800f36 <fd_close>
  800fdf:	83 c4 10             	add    $0x10,%esp
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <close_all>:

void
close_all(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	53                   	push   %ebx
  800ff4:	e8 be ff ff ff       	call   800fb7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff9:	83 c3 01             	add    $0x1,%ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	83 fb 20             	cmp    $0x20,%ebx
  801002:	75 ec                	jne    800ff0 <close_all+0xc>
		close(i);
}
  801004:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 2c             	sub    $0x2c,%esp
  801012:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801015:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	ff 75 08             	pushl  0x8(%ebp)
  80101c:	e8 6c fe ff ff       	call   800e8d <fd_lookup>
  801021:	89 c2                	mov    %eax,%edx
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	85 d2                	test   %edx,%edx
  801028:	0f 88 c1 00 00 00    	js     8010ef <dup+0xe6>
		return r;
	close(newfdnum);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	56                   	push   %esi
  801032:	e8 80 ff ff ff       	call   800fb7 <close>

	newfd = INDEX2FD(newfdnum);
  801037:	89 f3                	mov    %esi,%ebx
  801039:	c1 e3 0c             	shl    $0xc,%ebx
  80103c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801042:	83 c4 04             	add    $0x4,%esp
  801045:	ff 75 e4             	pushl  -0x1c(%ebp)
  801048:	e8 da fd ff ff       	call   800e27 <fd2data>
  80104d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80104f:	89 1c 24             	mov    %ebx,(%esp)
  801052:	e8 d0 fd ff ff       	call   800e27 <fd2data>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80105d:	89 f8                	mov    %edi,%eax
  80105f:	c1 e8 16             	shr    $0x16,%eax
  801062:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801069:	a8 01                	test   $0x1,%al
  80106b:	74 37                	je     8010a4 <dup+0x9b>
  80106d:	89 f8                	mov    %edi,%eax
  80106f:	c1 e8 0c             	shr    $0xc,%eax
  801072:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801079:	f6 c2 01             	test   $0x1,%dl
  80107c:	74 26                	je     8010a4 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	25 07 0e 00 00       	and    $0xe07,%eax
  80108d:	50                   	push   %eax
  80108e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801091:	6a 00                	push   $0x0
  801093:	57                   	push   %edi
  801094:	6a 00                	push   $0x0
  801096:	e8 3b fb ff ff       	call   800bd6 <sys_page_map>
  80109b:	89 c7                	mov    %eax,%edi
  80109d:	83 c4 20             	add    $0x20,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 2e                	js     8010d2 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010a7:	89 d0                	mov    %edx,%eax
  8010a9:	c1 e8 0c             	shr    $0xc,%eax
  8010ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010bb:	50                   	push   %eax
  8010bc:	53                   	push   %ebx
  8010bd:	6a 00                	push   $0x0
  8010bf:	52                   	push   %edx
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 0f fb ff ff       	call   800bd6 <sys_page_map>
  8010c7:	89 c7                	mov    %eax,%edi
  8010c9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010cc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ce:	85 ff                	test   %edi,%edi
  8010d0:	79 1d                	jns    8010ef <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010d2:	83 ec 08             	sub    $0x8,%esp
  8010d5:	53                   	push   %ebx
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 3b fb ff ff       	call   800c18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010dd:	83 c4 08             	add    $0x8,%esp
  8010e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 2e fb ff ff       	call   800c18 <sys_page_unmap>
	return r;
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	89 f8                	mov    %edi,%eax
}
  8010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 14             	sub    $0x14,%esp
  8010fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801101:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	53                   	push   %ebx
  801106:	e8 82 fd ff ff       	call   800e8d <fd_lookup>
  80110b:	83 c4 08             	add    $0x8,%esp
  80110e:	89 c2                	mov    %eax,%edx
  801110:	85 c0                	test   %eax,%eax
  801112:	78 6d                	js     801181 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801114:	83 ec 08             	sub    $0x8,%esp
  801117:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111e:	ff 30                	pushl  (%eax)
  801120:	e8 be fd ff ff       	call   800ee3 <dev_lookup>
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	78 4c                	js     801178 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80112c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80112f:	8b 42 08             	mov    0x8(%edx),%eax
  801132:	83 e0 03             	and    $0x3,%eax
  801135:	83 f8 01             	cmp    $0x1,%eax
  801138:	75 21                	jne    80115b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80113a:	a1 04 40 80 00       	mov    0x804004,%eax
  80113f:	8b 40 48             	mov    0x48(%eax),%eax
  801142:	83 ec 04             	sub    $0x4,%esp
  801145:	53                   	push   %ebx
  801146:	50                   	push   %eax
  801147:	68 00 24 80 00       	push   $0x802400
  80114c:	e8 b2 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801159:	eb 26                	jmp    801181 <read+0x8a>
	}
	if (!dev->dev_read)
  80115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115e:	8b 40 08             	mov    0x8(%eax),%eax
  801161:	85 c0                	test   %eax,%eax
  801163:	74 17                	je     80117c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	ff 75 10             	pushl  0x10(%ebp)
  80116b:	ff 75 0c             	pushl  0xc(%ebp)
  80116e:	52                   	push   %edx
  80116f:	ff d0                	call   *%eax
  801171:	89 c2                	mov    %eax,%edx
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	eb 09                	jmp    801181 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801178:	89 c2                	mov    %eax,%edx
  80117a:	eb 05                	jmp    801181 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80117c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801181:	89 d0                	mov    %edx,%eax
  801183:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801186:	c9                   	leave  
  801187:	c3                   	ret    

00801188 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	8b 7d 08             	mov    0x8(%ebp),%edi
  801194:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	eb 21                	jmp    8011bf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	89 f0                	mov    %esi,%eax
  8011a3:	29 d8                	sub    %ebx,%eax
  8011a5:	50                   	push   %eax
  8011a6:	89 d8                	mov    %ebx,%eax
  8011a8:	03 45 0c             	add    0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	57                   	push   %edi
  8011ad:	e8 45 ff ff ff       	call   8010f7 <read>
		if (m < 0)
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	78 0c                	js     8011c5 <readn+0x3d>
			return m;
		if (m == 0)
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	74 06                	je     8011c3 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011bd:	01 c3                	add    %eax,%ebx
  8011bf:	39 f3                	cmp    %esi,%ebx
  8011c1:	72 db                	jb     80119e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011c3:	89 d8                	mov    %ebx,%eax
}
  8011c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 14             	sub    $0x14,%esp
  8011d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	53                   	push   %ebx
  8011dc:	e8 ac fc ff ff       	call   800e8d <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 68                	js     801252 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	ff 30                	pushl  (%eax)
  8011f6:	e8 e8 fc ff ff       	call   800ee3 <dev_lookup>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 47                	js     801249 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801209:	75 21                	jne    80122c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80120b:	a1 04 40 80 00       	mov    0x804004,%eax
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	53                   	push   %ebx
  801217:	50                   	push   %eax
  801218:	68 1c 24 80 00       	push   $0x80241c
  80121d:	e8 e1 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80122a:	eb 26                	jmp    801252 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80122c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122f:	8b 52 0c             	mov    0xc(%edx),%edx
  801232:	85 d2                	test   %edx,%edx
  801234:	74 17                	je     80124d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	ff 75 10             	pushl  0x10(%ebp)
  80123c:	ff 75 0c             	pushl  0xc(%ebp)
  80123f:	50                   	push   %eax
  801240:	ff d2                	call   *%edx
  801242:	89 c2                	mov    %eax,%edx
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	eb 09                	jmp    801252 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	89 c2                	mov    %eax,%edx
  80124b:	eb 05                	jmp    801252 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80124d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801252:	89 d0                	mov    %edx,%eax
  801254:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <seek>:

int
seek(int fdnum, off_t offset)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	ff 75 08             	pushl  0x8(%ebp)
  801266:	e8 22 fc ff ff       	call   800e8d <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 0e                	js     801280 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801272:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801275:	8b 55 0c             	mov    0xc(%ebp),%edx
  801278:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	53                   	push   %ebx
  801286:	83 ec 14             	sub    $0x14,%esp
  801289:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	53                   	push   %ebx
  801291:	e8 f7 fb ff ff       	call   800e8d <fd_lookup>
  801296:	83 c4 08             	add    $0x8,%esp
  801299:	89 c2                	mov    %eax,%edx
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 65                	js     801304 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	ff 30                	pushl  (%eax)
  8012ab:	e8 33 fc ff ff       	call   800ee3 <dev_lookup>
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 44                	js     8012fb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012be:	75 21                	jne    8012e1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012c0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c5:	8b 40 48             	mov    0x48(%eax),%eax
  8012c8:	83 ec 04             	sub    $0x4,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	50                   	push   %eax
  8012cd:	68 dc 23 80 00       	push   $0x8023dc
  8012d2:	e8 2c ef ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012df:	eb 23                	jmp    801304 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e4:	8b 52 18             	mov    0x18(%edx),%edx
  8012e7:	85 d2                	test   %edx,%edx
  8012e9:	74 14                	je     8012ff <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	ff 75 0c             	pushl  0xc(%ebp)
  8012f1:	50                   	push   %eax
  8012f2:	ff d2                	call   *%edx
  8012f4:	89 c2                	mov    %eax,%edx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	eb 09                	jmp    801304 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	eb 05                	jmp    801304 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801304:	89 d0                	mov    %edx,%eax
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	53                   	push   %ebx
  80130f:	83 ec 14             	sub    $0x14,%esp
  801312:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801315:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 6c fb ff ff       	call   800e8d <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	89 c2                	mov    %eax,%edx
  801326:	85 c0                	test   %eax,%eax
  801328:	78 58                	js     801382 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	ff 30                	pushl  (%eax)
  801336:	e8 a8 fb ff ff       	call   800ee3 <dev_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 37                	js     801379 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801345:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801349:	74 32                	je     80137d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80134b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801355:	00 00 00 
	stat->st_isdir = 0;
  801358:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135f:	00 00 00 
	stat->st_dev = dev;
  801362:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	53                   	push   %ebx
  80136c:	ff 75 f0             	pushl  -0x10(%ebp)
  80136f:	ff 50 14             	call   *0x14(%eax)
  801372:	89 c2                	mov    %eax,%edx
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	eb 09                	jmp    801382 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	89 c2                	mov    %eax,%edx
  80137b:	eb 05                	jmp    801382 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80137d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801382:	89 d0                	mov    %edx,%eax
  801384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	6a 00                	push   $0x0
  801393:	ff 75 08             	pushl  0x8(%ebp)
  801396:	e8 09 02 00 00       	call   8015a4 <open>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 db                	test   %ebx,%ebx
  8013a2:	78 1b                	js     8013bf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	ff 75 0c             	pushl  0xc(%ebp)
  8013aa:	53                   	push   %ebx
  8013ab:	e8 5b ff ff ff       	call   80130b <fstat>
  8013b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b2:	89 1c 24             	mov    %ebx,(%esp)
  8013b5:	e8 fd fb ff ff       	call   800fb7 <close>
	return r;
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	89 f0                	mov    %esi,%eax
}
  8013bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	89 c6                	mov    %eax,%esi
  8013cd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013cf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d6:	75 12                	jne    8013ea <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	6a 01                	push   $0x1
  8013dd:	e8 ff 07 00 00       	call   801be1 <ipc_find_env>
  8013e2:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ea:	6a 07                	push   $0x7
  8013ec:	68 00 50 80 00       	push   $0x805000
  8013f1:	56                   	push   %esi
  8013f2:	ff 35 00 40 80 00    	pushl  0x804000
  8013f8:	e8 90 07 00 00       	call   801b8d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013fd:	83 c4 0c             	add    $0xc,%esp
  801400:	6a 00                	push   $0x0
  801402:	53                   	push   %ebx
  801403:	6a 00                	push   $0x0
  801405:	e8 1a 07 00 00       	call   801b24 <ipc_recv>
}
  80140a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	8b 40 0c             	mov    0xc(%eax),%eax
  80141d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801422:	8b 45 0c             	mov    0xc(%ebp),%eax
  801425:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80142a:	ba 00 00 00 00       	mov    $0x0,%edx
  80142f:	b8 02 00 00 00       	mov    $0x2,%eax
  801434:	e8 8d ff ff ff       	call   8013c6 <fsipc>
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	8b 40 0c             	mov    0xc(%eax),%eax
  801447:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80144c:	ba 00 00 00 00       	mov    $0x0,%edx
  801451:	b8 06 00 00 00       	mov    $0x6,%eax
  801456:	e8 6b ff ff ff       	call   8013c6 <fsipc>
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	53                   	push   %ebx
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
  80146a:	8b 40 0c             	mov    0xc(%eax),%eax
  80146d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801472:	ba 00 00 00 00       	mov    $0x0,%edx
  801477:	b8 05 00 00 00       	mov    $0x5,%eax
  80147c:	e8 45 ff ff ff       	call   8013c6 <fsipc>
  801481:	89 c2                	mov    %eax,%edx
  801483:	85 d2                	test   %edx,%edx
  801485:	78 2c                	js     8014b3 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	68 00 50 80 00       	push   $0x805000
  80148f:	53                   	push   %ebx
  801490:	e8 f5 f2 ff ff       	call   80078a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801495:	a1 80 50 80 00       	mov    0x805080,%eax
  80149a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	57                   	push   %edi
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ca:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014d2:	eb 3d                	jmp    801511 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014d4:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014da:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014df:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	57                   	push   %edi
  8014e6:	53                   	push   %ebx
  8014e7:	68 08 50 80 00       	push   $0x805008
  8014ec:	e8 2b f4 ff ff       	call   80091c <memmove>
                fsipcbuf.write.req_n = tmp; 
  8014f1:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801501:	e8 c0 fe ff ff       	call   8013c6 <fsipc>
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 0d                	js     80151a <devfile_write+0x62>
		        return r;
                n -= tmp;
  80150d:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80150f:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801511:	85 f6                	test   %esi,%esi
  801513:	75 bf                	jne    8014d4 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801515:	89 d8                	mov    %ebx,%eax
  801517:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80151a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5f                   	pop    %edi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	56                   	push   %esi
  801526:	53                   	push   %ebx
  801527:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152a:	8b 45 08             	mov    0x8(%ebp),%eax
  80152d:	8b 40 0c             	mov    0xc(%eax),%eax
  801530:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801535:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 03 00 00 00       	mov    $0x3,%eax
  801545:	e8 7c fe ff ff       	call   8013c6 <fsipc>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 4b                	js     80159b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801550:	39 c6                	cmp    %eax,%esi
  801552:	73 16                	jae    80156a <devfile_read+0x48>
  801554:	68 4c 24 80 00       	push   $0x80244c
  801559:	68 53 24 80 00       	push   $0x802453
  80155e:	6a 7c                	push   $0x7c
  801560:	68 68 24 80 00       	push   $0x802468
  801565:	e8 c0 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  80156a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156f:	7e 16                	jle    801587 <devfile_read+0x65>
  801571:	68 73 24 80 00       	push   $0x802473
  801576:	68 53 24 80 00       	push   $0x802453
  80157b:	6a 7d                	push   $0x7d
  80157d:	68 68 24 80 00       	push   $0x802468
  801582:	e8 a3 eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801587:	83 ec 04             	sub    $0x4,%esp
  80158a:	50                   	push   %eax
  80158b:	68 00 50 80 00       	push   $0x805000
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	e8 84 f3 ff ff       	call   80091c <memmove>
	return r;
  801598:	83 c4 10             	add    $0x10,%esp
}
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 20             	sub    $0x20,%esp
  8015ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ae:	53                   	push   %ebx
  8015af:	e8 9d f1 ff ff       	call   800751 <strlen>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015bc:	7f 67                	jg     801625 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	e8 74 f8 ff ff       	call   800e3e <fd_alloc>
  8015ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8015cd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 57                	js     80162a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	53                   	push   %ebx
  8015d7:	68 00 50 80 00       	push   $0x805000
  8015dc:	e8 a9 f1 ff ff       	call   80078a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f1:	e8 d0 fd ff ff       	call   8013c6 <fsipc>
  8015f6:	89 c3                	mov    %eax,%ebx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	79 14                	jns    801613 <open+0x6f>
		fd_close(fd, 0);
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	6a 00                	push   $0x0
  801604:	ff 75 f4             	pushl  -0xc(%ebp)
  801607:	e8 2a f9 ff ff       	call   800f36 <fd_close>
		return r;
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	89 da                	mov    %ebx,%edx
  801611:	eb 17                	jmp    80162a <open+0x86>
	}

	return fd2num(fd);
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	ff 75 f4             	pushl  -0xc(%ebp)
  801619:	e8 f9 f7 ff ff       	call   800e17 <fd2num>
  80161e:	89 c2                	mov    %eax,%edx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 05                	jmp    80162a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801625:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80162a:	89 d0                	mov    %edx,%eax
  80162c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801637:	ba 00 00 00 00       	mov    $0x0,%edx
  80163c:	b8 08 00 00 00       	mov    $0x8,%eax
  801641:	e8 80 fd ff ff       	call   8013c6 <fsipc>
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801650:	83 ec 0c             	sub    $0xc,%esp
  801653:	ff 75 08             	pushl  0x8(%ebp)
  801656:	e8 cc f7 ff ff       	call   800e27 <fd2data>
  80165b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80165d:	83 c4 08             	add    $0x8,%esp
  801660:	68 7f 24 80 00       	push   $0x80247f
  801665:	53                   	push   %ebx
  801666:	e8 1f f1 ff ff       	call   80078a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80166b:	8b 56 04             	mov    0x4(%esi),%edx
  80166e:	89 d0                	mov    %edx,%eax
  801670:	2b 06                	sub    (%esi),%eax
  801672:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801678:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167f:	00 00 00 
	stat->st_dev = &devpipe;
  801682:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801689:	30 80 00 
	return 0;
}
  80168c:	b8 00 00 00 00       	mov    $0x0,%eax
  801691:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a2:	53                   	push   %ebx
  8016a3:	6a 00                	push   $0x0
  8016a5:	e8 6e f5 ff ff       	call   800c18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016aa:	89 1c 24             	mov    %ebx,(%esp)
  8016ad:	e8 75 f7 ff ff       	call   800e27 <fd2data>
  8016b2:	83 c4 08             	add    $0x8,%esp
  8016b5:	50                   	push   %eax
  8016b6:	6a 00                	push   $0x0
  8016b8:	e8 5b f5 ff ff       	call   800c18 <sys_page_unmap>
}
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	57                   	push   %edi
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 1c             	sub    $0x1c,%esp
  8016cb:	89 c6                	mov    %eax,%esi
  8016cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	56                   	push   %esi
  8016dc:	e8 38 05 00 00       	call   801c19 <pageref>
  8016e1:	89 c7                	mov    %eax,%edi
  8016e3:	83 c4 04             	add    $0x4,%esp
  8016e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e9:	e8 2b 05 00 00       	call   801c19 <pageref>
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	39 c7                	cmp    %eax,%edi
  8016f3:	0f 94 c2             	sete   %dl
  8016f6:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8016f9:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8016ff:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801702:	39 fb                	cmp    %edi,%ebx
  801704:	74 19                	je     80171f <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801706:	84 d2                	test   %dl,%dl
  801708:	74 c6                	je     8016d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80170a:	8b 51 58             	mov    0x58(%ecx),%edx
  80170d:	50                   	push   %eax
  80170e:	52                   	push   %edx
  80170f:	53                   	push   %ebx
  801710:	68 86 24 80 00       	push   $0x802486
  801715:	e8 e9 ea ff ff       	call   800203 <cprintf>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	eb b1                	jmp    8016d0 <_pipeisclosed+0xe>
	}
}
  80171f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5f                   	pop    %edi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 28             	sub    $0x28,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801733:	56                   	push   %esi
  801734:	e8 ee f6 ff ff       	call   800e27 <fd2data>
  801739:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	bf 00 00 00 00       	mov    $0x0,%edi
  801743:	eb 4b                	jmp    801790 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801745:	89 da                	mov    %ebx,%edx
  801747:	89 f0                	mov    %esi,%eax
  801749:	e8 74 ff ff ff       	call   8016c2 <_pipeisclosed>
  80174e:	85 c0                	test   %eax,%eax
  801750:	75 48                	jne    80179a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801752:	e8 1d f4 ff ff       	call   800b74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801757:	8b 43 04             	mov    0x4(%ebx),%eax
  80175a:	8b 0b                	mov    (%ebx),%ecx
  80175c:	8d 51 20             	lea    0x20(%ecx),%edx
  80175f:	39 d0                	cmp    %edx,%eax
  801761:	73 e2                	jae    801745 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801766:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80176a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	c1 fa 1f             	sar    $0x1f,%edx
  801772:	89 d1                	mov    %edx,%ecx
  801774:	c1 e9 1b             	shr    $0x1b,%ecx
  801777:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80177a:	83 e2 1f             	and    $0x1f,%edx
  80177d:	29 ca                	sub    %ecx,%edx
  80177f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801783:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801787:	83 c0 01             	add    $0x1,%eax
  80178a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178d:	83 c7 01             	add    $0x1,%edi
  801790:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801793:	75 c2                	jne    801757 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801795:	8b 45 10             	mov    0x10(%ebp),%eax
  801798:	eb 05                	jmp    80179f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80179f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5f                   	pop    %edi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	57                   	push   %edi
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 18             	sub    $0x18,%esp
  8017b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017b3:	57                   	push   %edi
  8017b4:	e8 6e f6 ff ff       	call   800e27 <fd2data>
  8017b9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c3:	eb 3d                	jmp    801802 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017c5:	85 db                	test   %ebx,%ebx
  8017c7:	74 04                	je     8017cd <devpipe_read+0x26>
				return i;
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	eb 44                	jmp    801811 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017cd:	89 f2                	mov    %esi,%edx
  8017cf:	89 f8                	mov    %edi,%eax
  8017d1:	e8 ec fe ff ff       	call   8016c2 <_pipeisclosed>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	75 32                	jne    80180c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017da:	e8 95 f3 ff ff       	call   800b74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017df:	8b 06                	mov    (%esi),%eax
  8017e1:	3b 46 04             	cmp    0x4(%esi),%eax
  8017e4:	74 df                	je     8017c5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e6:	99                   	cltd   
  8017e7:	c1 ea 1b             	shr    $0x1b,%edx
  8017ea:	01 d0                	add    %edx,%eax
  8017ec:	83 e0 1f             	and    $0x1f,%eax
  8017ef:	29 d0                	sub    %edx,%eax
  8017f1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017fc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ff:	83 c3 01             	add    $0x1,%ebx
  801802:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801805:	75 d8                	jne    8017df <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801807:	8b 45 10             	mov    0x10(%ebp),%eax
  80180a:	eb 05                	jmp    801811 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801811:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801814:	5b                   	pop    %ebx
  801815:	5e                   	pop    %esi
  801816:	5f                   	pop    %edi
  801817:	5d                   	pop    %ebp
  801818:	c3                   	ret    

00801819 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801824:	50                   	push   %eax
  801825:	e8 14 f6 ff ff       	call   800e3e <fd_alloc>
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	85 c0                	test   %eax,%eax
  801831:	0f 88 2c 01 00 00    	js     801963 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	68 07 04 00 00       	push   $0x407
  80183f:	ff 75 f4             	pushl  -0xc(%ebp)
  801842:	6a 00                	push   $0x0
  801844:	e8 4a f3 ff ff       	call   800b93 <sys_page_alloc>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 c2                	mov    %eax,%edx
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 0d 01 00 00    	js     801963 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	e8 dc f5 ff ff       	call   800e3e <fd_alloc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 88 e2 00 00 00    	js     801951 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	68 07 04 00 00       	push   $0x407
  801877:	ff 75 f0             	pushl  -0x10(%ebp)
  80187a:	6a 00                	push   $0x0
  80187c:	e8 12 f3 ff ff       	call   800b93 <sys_page_alloc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	0f 88 c3 00 00 00    	js     801951 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	ff 75 f4             	pushl  -0xc(%ebp)
  801894:	e8 8e f5 ff ff       	call   800e27 <fd2data>
  801899:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	83 c4 0c             	add    $0xc,%esp
  80189e:	68 07 04 00 00       	push   $0x407
  8018a3:	50                   	push   %eax
  8018a4:	6a 00                	push   $0x0
  8018a6:	e8 e8 f2 ff ff       	call   800b93 <sys_page_alloc>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	0f 88 89 00 00 00    	js     801941 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8018be:	e8 64 f5 ff ff       	call   800e27 <fd2data>
  8018c3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ca:	50                   	push   %eax
  8018cb:	6a 00                	push   $0x0
  8018cd:	56                   	push   %esi
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 01 f3 ff ff       	call   800bd6 <sys_page_map>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 20             	add    $0x20,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 55                	js     801933 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018de:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801901:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 04 f5 ff ff       	call   800e17 <fd2num>
  801913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801916:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801918:	83 c4 04             	add    $0x4,%esp
  80191b:	ff 75 f0             	pushl  -0x10(%ebp)
  80191e:	e8 f4 f4 ff ff       	call   800e17 <fd2num>
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801926:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	eb 30                	jmp    801963 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	56                   	push   %esi
  801937:	6a 00                	push   $0x0
  801939:	e8 da f2 ff ff       	call   800c18 <sys_page_unmap>
  80193e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	ff 75 f0             	pushl  -0x10(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 ca f2 ff ff       	call   800c18 <sys_page_unmap>
  80194e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	6a 00                	push   $0x0
  801959:	e8 ba f2 ff ff       	call   800c18 <sys_page_unmap>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801963:	89 d0                	mov    %edx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	ff 75 08             	pushl  0x8(%ebp)
  801979:	e8 0f f5 ff ff       	call   800e8d <fd_lookup>
  80197e:	89 c2                	mov    %eax,%edx
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 d2                	test   %edx,%edx
  801985:	78 18                	js     80199f <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	e8 95 f4 ff ff       	call   800e27 <fd2data>
	return _pipeisclosed(fd, p);
  801992:	89 c2                	mov    %eax,%edx
  801994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801997:	e8 26 fd ff ff       	call   8016c2 <_pipeisclosed>
  80199c:	83 c4 10             	add    $0x10,%esp
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019b1:	68 9e 24 80 00       	push   $0x80249e
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	e8 cc ed ff ff       	call   80078a <strcpy>
	return 0;
}
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	57                   	push   %edi
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019dc:	eb 2d                	jmp    801a0b <devcons_write+0x46>
		m = n - tot;
  8019de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019e1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019e3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019e6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019eb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ee:	83 ec 04             	sub    $0x4,%esp
  8019f1:	53                   	push   %ebx
  8019f2:	03 45 0c             	add    0xc(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	57                   	push   %edi
  8019f7:	e8 20 ef ff ff       	call   80091c <memmove>
		sys_cputs(buf, m);
  8019fc:	83 c4 08             	add    $0x8,%esp
  8019ff:	53                   	push   %ebx
  801a00:	57                   	push   %edi
  801a01:	e8 d1 f0 ff ff       	call   800ad7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a06:	01 de                	add    %ebx,%esi
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	89 f0                	mov    %esi,%eax
  801a0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a10:	72 cc                	jb     8019de <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a29:	75 07                	jne    801a32 <devcons_read+0x18>
  801a2b:	eb 28                	jmp    801a55 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a2d:	e8 42 f1 ff ff       	call   800b74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a32:	e8 be f0 ff ff       	call   800af5 <sys_cgetc>
  801a37:	85 c0                	test   %eax,%eax
  801a39:	74 f2                	je     801a2d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 16                	js     801a55 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a3f:	83 f8 04             	cmp    $0x4,%eax
  801a42:	74 0c                	je     801a50 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a47:	88 02                	mov    %al,(%edx)
	return 1;
  801a49:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4e:	eb 05                	jmp    801a55 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a63:	6a 01                	push   $0x1
  801a65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	e8 69 f0 ff ff       	call   800ad7 <sys_cputs>
  801a6e:	83 c4 10             	add    $0x10,%esp
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <getchar>:

int
getchar(void)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a79:	6a 01                	push   $0x1
  801a7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a7e:	50                   	push   %eax
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 71 f6 ff ff       	call   8010f7 <read>
	if (r < 0)
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 0f                	js     801a9c <getchar+0x29>
		return r;
	if (r < 1)
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	7e 06                	jle    801a97 <getchar+0x24>
		return -E_EOF;
	return c;
  801a91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a95:	eb 05                	jmp    801a9c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	ff 75 08             	pushl  0x8(%ebp)
  801aab:	e8 dd f3 ff ff       	call   800e8d <fd_lookup>
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 11                	js     801ac8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac0:	39 10                	cmp    %edx,(%eax)
  801ac2:	0f 94 c0             	sete   %al
  801ac5:	0f b6 c0             	movzbl %al,%eax
}
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <opencons>:

int
opencons(void)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	e8 65 f3 ff ff       	call   800e3e <fd_alloc>
  801ad9:	83 c4 10             	add    $0x10,%esp
		return r;
  801adc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 3e                	js     801b20 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	ff 75 f4             	pushl  -0xc(%ebp)
  801aed:	6a 00                	push   $0x0
  801aef:	e8 9f f0 ff ff       	call   800b93 <sys_page_alloc>
  801af4:	83 c4 10             	add    $0x10,%esp
		return r;
  801af7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 23                	js     801b20 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801afd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	50                   	push   %eax
  801b16:	e8 fc f2 ff ff       	call   800e17 <fd2num>
  801b1b:	89 c2                	mov    %eax,%edx
  801b1d:	83 c4 10             	add    $0x10,%esp
}
  801b20:	89 d0                	mov    %edx,%eax
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801b32:	85 c0                	test   %eax,%eax
  801b34:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b39:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801b3c:	83 ec 0c             	sub    $0xc,%esp
  801b3f:	50                   	push   %eax
  801b40:	e8 fe f1 ff ff       	call   800d43 <sys_ipc_recv>
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	79 16                	jns    801b62 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801b4c:	85 f6                	test   %esi,%esi
  801b4e:	74 06                	je     801b56 <ipc_recv+0x32>
  801b50:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801b56:	85 db                	test   %ebx,%ebx
  801b58:	74 2c                	je     801b86 <ipc_recv+0x62>
  801b5a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b60:	eb 24                	jmp    801b86 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b62:	85 f6                	test   %esi,%esi
  801b64:	74 0a                	je     801b70 <ipc_recv+0x4c>
  801b66:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6b:	8b 40 74             	mov    0x74(%eax),%eax
  801b6e:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801b70:	85 db                	test   %ebx,%ebx
  801b72:	74 0a                	je     801b7e <ipc_recv+0x5a>
  801b74:	a1 04 40 80 00       	mov    0x804004,%eax
  801b79:	8b 40 78             	mov    0x78(%eax),%eax
  801b7c:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801b7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b83:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	57                   	push   %edi
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801b9f:	85 db                	test   %ebx,%ebx
  801ba1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ba6:	0f 44 d8             	cmove  %eax,%ebx
  801ba9:	eb 1c                	jmp    801bc7 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801bab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bae:	74 12                	je     801bc2 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801bb0:	50                   	push   %eax
  801bb1:	68 aa 24 80 00       	push   $0x8024aa
  801bb6:	6a 39                	push   $0x39
  801bb8:	68 c5 24 80 00       	push   $0x8024c5
  801bbd:	e8 68 e5 ff ff       	call   80012a <_panic>
                 sys_yield();
  801bc2:	e8 ad ef ff ff       	call   800b74 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bc7:	ff 75 14             	pushl  0x14(%ebp)
  801bca:	53                   	push   %ebx
  801bcb:	56                   	push   %esi
  801bcc:	57                   	push   %edi
  801bcd:	e8 4e f1 ff ff       	call   800d20 <sys_ipc_try_send>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 d2                	js     801bab <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5f                   	pop    %edi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf5:	8b 52 50             	mov    0x50(%edx),%edx
  801bf8:	39 ca                	cmp    %ecx,%edx
  801bfa:	75 0d                	jne    801c09 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bfc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bff:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801c04:	8b 40 08             	mov    0x8(%eax),%eax
  801c07:	eb 0e                	jmp    801c17 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c09:	83 c0 01             	add    $0x1,%eax
  801c0c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c11:	75 d9                	jne    801bec <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c13:	66 b8 00 00          	mov    $0x0,%ax
}
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	c1 e8 16             	shr    $0x16,%eax
  801c24:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c30:	f6 c1 01             	test   $0x1,%cl
  801c33:	74 1d                	je     801c52 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c35:	c1 ea 0c             	shr    $0xc,%edx
  801c38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c3f:	f6 c2 01             	test   $0x1,%dl
  801c42:	74 0e                	je     801c52 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c44:	c1 ea 0c             	shr    $0xc,%edx
  801c47:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c4e:	ef 
  801c4f:	0f b7 c0             	movzwl %ax,%eax
}
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__udivdi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	83 ec 10             	sub    $0x10,%esp
  801c66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801c6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801c6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801c72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c76:	85 d2                	test   %edx,%edx
  801c78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c7c:	89 34 24             	mov    %esi,(%esp)
  801c7f:	89 c8                	mov    %ecx,%eax
  801c81:	75 35                	jne    801cb8 <__udivdi3+0x58>
  801c83:	39 f1                	cmp    %esi,%ecx
  801c85:	0f 87 bd 00 00 00    	ja     801d48 <__udivdi3+0xe8>
  801c8b:	85 c9                	test   %ecx,%ecx
  801c8d:	89 cd                	mov    %ecx,%ebp
  801c8f:	75 0b                	jne    801c9c <__udivdi3+0x3c>
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	31 d2                	xor    %edx,%edx
  801c98:	f7 f1                	div    %ecx
  801c9a:	89 c5                	mov    %eax,%ebp
  801c9c:	89 f0                	mov    %esi,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	f7 f5                	div    %ebp
  801ca2:	89 c6                	mov    %eax,%esi
  801ca4:	89 f8                	mov    %edi,%eax
  801ca6:	f7 f5                	div    %ebp
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    
  801cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	3b 14 24             	cmp    (%esp),%edx
  801cbb:	77 7b                	ja     801d38 <__udivdi3+0xd8>
  801cbd:	0f bd f2             	bsr    %edx,%esi
  801cc0:	83 f6 1f             	xor    $0x1f,%esi
  801cc3:	0f 84 97 00 00 00    	je     801d60 <__udivdi3+0x100>
  801cc9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801cce:	89 d7                	mov    %edx,%edi
  801cd0:	89 f1                	mov    %esi,%ecx
  801cd2:	29 f5                	sub    %esi,%ebp
  801cd4:	d3 e7                	shl    %cl,%edi
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	89 e9                	mov    %ebp,%ecx
  801cda:	d3 ea                	shr    %cl,%edx
  801cdc:	89 f1                	mov    %esi,%ecx
  801cde:	09 fa                	or     %edi,%edx
  801ce0:	8b 3c 24             	mov    (%esp),%edi
  801ce3:	d3 e0                	shl    %cl,%eax
  801ce5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ce9:	89 e9                	mov    %ebp,%ecx
  801ceb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cef:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cf3:	89 fa                	mov    %edi,%edx
  801cf5:	d3 ea                	shr    %cl,%edx
  801cf7:	89 f1                	mov    %esi,%ecx
  801cf9:	d3 e7                	shl    %cl,%edi
  801cfb:	89 e9                	mov    %ebp,%ecx
  801cfd:	d3 e8                	shr    %cl,%eax
  801cff:	09 c7                	or     %eax,%edi
  801d01:	89 f8                	mov    %edi,%eax
  801d03:	f7 74 24 08          	divl   0x8(%esp)
  801d07:	89 d5                	mov    %edx,%ebp
  801d09:	89 c7                	mov    %eax,%edi
  801d0b:	f7 64 24 0c          	mull   0xc(%esp)
  801d0f:	39 d5                	cmp    %edx,%ebp
  801d11:	89 14 24             	mov    %edx,(%esp)
  801d14:	72 11                	jb     801d27 <__udivdi3+0xc7>
  801d16:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d1a:	89 f1                	mov    %esi,%ecx
  801d1c:	d3 e2                	shl    %cl,%edx
  801d1e:	39 c2                	cmp    %eax,%edx
  801d20:	73 5e                	jae    801d80 <__udivdi3+0x120>
  801d22:	3b 2c 24             	cmp    (%esp),%ebp
  801d25:	75 59                	jne    801d80 <__udivdi3+0x120>
  801d27:	8d 47 ff             	lea    -0x1(%edi),%eax
  801d2a:	31 f6                	xor    %esi,%esi
  801d2c:	89 f2                	mov    %esi,%edx
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    
  801d35:	8d 76 00             	lea    0x0(%esi),%esi
  801d38:	31 f6                	xor    %esi,%esi
  801d3a:	31 c0                	xor    %eax,%eax
  801d3c:	89 f2                	mov    %esi,%edx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	31 f6                	xor    %esi,%esi
  801d4c:	89 f8                	mov    %edi,%eax
  801d4e:	f7 f1                	div    %ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d64:	76 0b                	jbe    801d71 <__udivdi3+0x111>
  801d66:	31 c0                	xor    %eax,%eax
  801d68:	3b 14 24             	cmp    (%esp),%edx
  801d6b:	0f 83 37 ff ff ff    	jae    801ca8 <__udivdi3+0x48>
  801d71:	b8 01 00 00 00       	mov    $0x1,%eax
  801d76:	e9 2d ff ff ff       	jmp    801ca8 <__udivdi3+0x48>
  801d7b:	90                   	nop
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 f8                	mov    %edi,%eax
  801d82:	31 f6                	xor    %esi,%esi
  801d84:	e9 1f ff ff ff       	jmp    801ca8 <__udivdi3+0x48>
  801d89:	66 90                	xchg   %ax,%ax
  801d8b:	66 90                	xchg   %ax,%ax
  801d8d:	66 90                	xchg   %ax,%ax
  801d8f:	90                   	nop

00801d90 <__umoddi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	83 ec 20             	sub    $0x20,%esp
  801d96:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d9a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da2:	89 c6                	mov    %eax,%esi
  801da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801da8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801db0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801db4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801db8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	75 1e                	jne    801de0 <__umoddi3+0x50>
  801dc2:	39 f7                	cmp    %esi,%edi
  801dc4:	76 52                	jbe    801e18 <__umoddi3+0x88>
  801dc6:	89 c8                	mov    %ecx,%eax
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	f7 f7                	div    %edi
  801dcc:	89 d0                	mov    %edx,%eax
  801dce:	31 d2                	xor    %edx,%edx
  801dd0:	83 c4 20             	add    $0x20,%esp
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    
  801dd7:	89 f6                	mov    %esi,%esi
  801dd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801de0:	39 f0                	cmp    %esi,%eax
  801de2:	77 5c                	ja     801e40 <__umoddi3+0xb0>
  801de4:	0f bd e8             	bsr    %eax,%ebp
  801de7:	83 f5 1f             	xor    $0x1f,%ebp
  801dea:	75 64                	jne    801e50 <__umoddi3+0xc0>
  801dec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801df0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801df4:	0f 86 f6 00 00 00    	jbe    801ef0 <__umoddi3+0x160>
  801dfa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801dfe:	0f 82 ec 00 00 00    	jb     801ef0 <__umoddi3+0x160>
  801e04:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e08:	8b 54 24 18          	mov    0x18(%esp),%edx
  801e0c:	83 c4 20             	add    $0x20,%esp
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
  801e13:	90                   	nop
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	85 ff                	test   %edi,%edi
  801e1a:	89 fd                	mov    %edi,%ebp
  801e1c:	75 0b                	jne    801e29 <__umoddi3+0x99>
  801e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f7                	div    %edi
  801e27:	89 c5                	mov    %eax,%ebp
  801e29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e2d:	31 d2                	xor    %edx,%edx
  801e2f:	f7 f5                	div    %ebp
  801e31:	89 c8                	mov    %ecx,%eax
  801e33:	f7 f5                	div    %ebp
  801e35:	eb 95                	jmp    801dcc <__umoddi3+0x3c>
  801e37:	89 f6                	mov    %esi,%esi
  801e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e40:	89 c8                	mov    %ecx,%eax
  801e42:	89 f2                	mov    %esi,%edx
  801e44:	83 c4 20             	add    $0x20,%esp
  801e47:	5e                   	pop    %esi
  801e48:	5f                   	pop    %edi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    
  801e4b:	90                   	nop
  801e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e50:	b8 20 00 00 00       	mov    $0x20,%eax
  801e55:	89 e9                	mov    %ebp,%ecx
  801e57:	29 e8                	sub    %ebp,%eax
  801e59:	d3 e2                	shl    %cl,%edx
  801e5b:	89 c7                	mov    %eax,%edi
  801e5d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 c1                	mov    %eax,%ecx
  801e6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e6f:	09 d1                	or     %edx,%ecx
  801e71:	89 fa                	mov    %edi,%edx
  801e73:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e77:	89 e9                	mov    %ebp,%ecx
  801e79:	d3 e0                	shl    %cl,%eax
  801e7b:	89 f9                	mov    %edi,%ecx
  801e7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e81:	89 f0                	mov    %esi,%eax
  801e83:	d3 e8                	shr    %cl,%eax
  801e85:	89 e9                	mov    %ebp,%ecx
  801e87:	89 c7                	mov    %eax,%edi
  801e89:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e8d:	d3 e6                	shl    %cl,%esi
  801e8f:	89 d1                	mov    %edx,%ecx
  801e91:	89 fa                	mov    %edi,%edx
  801e93:	d3 e8                	shr    %cl,%eax
  801e95:	89 e9                	mov    %ebp,%ecx
  801e97:	09 f0                	or     %esi,%eax
  801e99:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e9d:	f7 74 24 10          	divl   0x10(%esp)
  801ea1:	d3 e6                	shl    %cl,%esi
  801ea3:	89 d1                	mov    %edx,%ecx
  801ea5:	f7 64 24 0c          	mull   0xc(%esp)
  801ea9:	39 d1                	cmp    %edx,%ecx
  801eab:	89 74 24 14          	mov    %esi,0x14(%esp)
  801eaf:	89 d7                	mov    %edx,%edi
  801eb1:	89 c6                	mov    %eax,%esi
  801eb3:	72 0a                	jb     801ebf <__umoddi3+0x12f>
  801eb5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801eb9:	73 10                	jae    801ecb <__umoddi3+0x13b>
  801ebb:	39 d1                	cmp    %edx,%ecx
  801ebd:	75 0c                	jne    801ecb <__umoddi3+0x13b>
  801ebf:	89 d7                	mov    %edx,%edi
  801ec1:	89 c6                	mov    %eax,%esi
  801ec3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801ec7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801ecb:	89 ca                	mov    %ecx,%edx
  801ecd:	89 e9                	mov    %ebp,%ecx
  801ecf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed3:	29 f0                	sub    %esi,%eax
  801ed5:	19 fa                	sbb    %edi,%edx
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801ede:	89 d7                	mov    %edx,%edi
  801ee0:	d3 e7                	shl    %cl,%edi
  801ee2:	89 e9                	mov    %ebp,%ecx
  801ee4:	09 f8                	or     %edi,%eax
  801ee6:	d3 ea                	shr    %cl,%edx
  801ee8:	83 c4 20             	add    $0x20,%esp
  801eeb:	5e                   	pop    %esi
  801eec:	5f                   	pop    %edi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    
  801eef:	90                   	nop
  801ef0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ef4:	29 f9                	sub    %edi,%ecx
  801ef6:	19 c6                	sbb    %eax,%esi
  801ef8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801efc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801f00:	e9 ff fe ff ff       	jmp    801e04 <__umoddi3+0x74>
